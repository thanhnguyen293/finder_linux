#include "my_application.h"

#include <flutter_linux/flutter_linux.h>
#include <cstring>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

#include "flutter/generated_plugin_registrant.h"

// Every Finder window lives in this one process, each with its own Flutter
// engine, as Nautilus and Chrome keep all their windows in one process.
// The desktop then sees one app: new windows join the app's group (dock,
// Stage Manager) instead of looking like a separate program. Launching
// Finder again hands the command line to this process (GApplication's
// single instance over D-Bus), which opens a tab or a window for it.

// Must match newWindowFlag in lib/services/file_system_service.dart.
static const char kNewWindowFlag[] = "--new-window";
// Must match hostEngineFlag in lib/main.dart.
static const char kHostEngineFlag[] = "--host-engine";

struct _MyApplication {
  GtkApplication parent_instance;
  // Never shown; see start_host_engine().
  GtkWidget* host_window;
  // Windows opened so far; each gets the next as its index (never reused).
  guint windows_opened;
  // Last pointer press, needed to hand an in-progress drag to the compositor.
  GdkEvent* last_press;
  guint event_signal_id;
  gulong press_hook_id;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

// One window and the channel to the Flutter engine drawing it. Freed when
// the window is destroyed.
typedef struct {
  MyApplication* app;
  GtkWindow* window;
  FlMethodChannel* channel;
} FinderWindow;

static void create_window(MyApplication* self, char** args);

static FinderWindow* finder_window_of(GtkWindow* window) {
  return window == nullptr ? nullptr
                           : static_cast<FinderWindow*>(g_object_get_data(
                                 G_OBJECT(window), "finder-window"));
}

// Runs for every GtkWidget "event" emission. FlView consumes button presses,
// so they never bubble up to the window; an emission hook still sees them.
static gboolean button_press_hook(GSignalInvocationHint* hint,
                                  guint n_params, const GValue* params,
                                  gpointer user_data) {
  MyApplication* self = MY_APPLICATION(user_data);
  if (n_params < 2) return TRUE;
  GdkEvent* event = static_cast<GdkEvent*>(g_value_get_boxed(&params[1]));
  if (event != nullptr && event->type == GDK_BUTTON_PRESS) {
    g_clear_pointer(&self->last_press, gdk_event_free);
    self->last_press = gdk_event_copy(event);
  }
  return TRUE;  // Keep the hook installed.
}

static void start_window_drag(FinderWindow* fw) {
  MyApplication* self = fw->app;
  if (self->last_press == nullptr) {
    g_warning("startDrag: no button press recorded, cannot move window");
    return;
  }
  GdkEventButton* press = reinterpret_cast<GdkEventButton*>(self->last_press);
  gtk_window_begin_move_drag(fw->window, press->button,
                             static_cast<gint>(press->x_root),
                             static_cast<gint>(press->y_root), press->time);
  // The compositor now owns the pointer and Flutter never sees the release,
  // so synthesize one to keep its gesture state consistent.
  GdkEvent* release = gdk_event_copy(self->last_press);
  release->type = GDK_BUTTON_RELEASE;
  gtk_main_do_event(release);
  gdk_event_free(release);
}

// Lets the compositor show the desktop through the corners that Flutter
// leaves transparent, and rounds GTK's client-side shadow to match.
static void make_window_rounded(GtkWindow* window) {
  GdkVisual* visual = gdk_screen_get_rgba_visual(gtk_window_get_screen(window));
  if (visual != nullptr) gtk_widget_set_visual(GTK_WIDGET(window), visual);
  gtk_widget_set_app_paintable(GTK_WIDGET(window), TRUE);
  gtk_style_context_add_class(gtk_widget_get_style_context(GTK_WIDGET(window)),
                              "finder-window");
}

// Maximized, fullscreen and tiled windows have square corners, as on macOS.
static gboolean window_state_cb(GtkWidget* widget, GdkEventWindowState* event,
                                FinderWindow* fw) {
  const GdkWindowState square =
      static_cast<GdkWindowState>(GDK_WINDOW_STATE_MAXIMIZED |
                                  GDK_WINDOW_STATE_FULLSCREEN |
                                  GDK_WINDOW_STATE_TILED);
  fl_method_channel_invoke_method(
      fw->channel, "squareCornersChanged",
      fl_value_new_bool((event->new_window_state & square) != 0), nullptr,
      nullptr, nullptr);
  return FALSE;
}

// A string list from Dart (null or anything else counts as empty).
static GStrv strv_from_value(FlValue* value) {
  g_autoptr(GStrvBuilder) builder = g_strv_builder_new();
  if (value != nullptr && fl_value_get_type(value) == FL_VALUE_TYPE_LIST) {
    for (size_t i = 0; i < fl_value_get_length(value); i++) {
      FlValue* item = fl_value_get_list_value(value, i);
      if (fl_value_get_type(item) == FL_VALUE_TYPE_STRING) {
        g_strv_builder_add(builder, fl_value_get_string(item));
      }
    }
  }
  return g_strv_builder_end(builder);
}

static void window_method_call_cb(FlMethodChannel* channel,
                                  FlMethodCall* method_call,
                                  gpointer user_data) {
  FinderWindow* fw = static_cast<FinderWindow*>(user_data);
  const gchar* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);

  if (strcmp(method, "startDrag") == 0) {
    start_window_drag(fw);
  } else if (strcmp(method, "minimize") == 0) {
    gtk_window_iconify(fw->window);
  } else if (strcmp(method, "toggleMaximize") == 0) {
    if (gtk_window_is_maximized(fw->window)) {
      gtk_window_unmaximize(fw->window);
    } else {
      gtk_window_maximize(fw->window);
    }
  } else if (strcmp(method, "present") == 0) {
    gtk_window_present(fw->window);
  } else if (strcmp(method, "close") == 0) {
    gtk_window_close(fw->window);
  } else if (strcmp(method, "setTitle") == 0) {
    if (args != nullptr && fl_value_get_type(args) == FL_VALUE_TYPE_STRING) {
      gtk_window_set_title(fw->window, fl_value_get_string(args));
    }
  } else if (strcmp(method, "openWindow") == 0) {
    // Ctrl+N, a torn-off tab: another window in this process.
    g_auto(GStrv) window_args = strv_from_value(args);
    create_window(fw->app, window_args);
  } else {
    fl_method_call_respond_not_implemented(method_call, nullptr);
    return;
  }
  fl_method_call_respond_success(method_call, nullptr, nullptr);
}

// Closing a window (its close button, Alt+F4, the dock) closes just that
// window. Connected before FlView's own handler, which would treat it as
// quitting the whole app and so close every other window too; returning
// TRUE stops the signal before it gets there. The last window closing
// still ends the app, as GtkApplication then has no windows left.
static gboolean destroy_when_idle(gpointer window) {
  gtk_widget_destroy(GTK_WIDGET(window));
  g_object_unref(window);
  return G_SOURCE_REMOVE;
}

static gboolean window_delete_cb(GtkWidget* window, GdkEvent* event,
                                 gpointer user_data) {
  // Hidden at once, destroyed once GTK is idle: the request may come from
  // this window's own engine (its close button), which must not be torn
  // down while it is still handling the call or drawing a frame.
  gtk_widget_hide(window);
  g_idle_add(destroy_when_idle, g_object_ref(window));
  return TRUE;
}

static void window_destroy_cb(GtkWidget* widget, FinderWindow* fw) {
  fl_method_channel_set_method_call_handler(fw->channel, nullptr, nullptr,
                                            nullptr);
  g_clear_object(&fw->channel);
  g_free(fw);
}

// Called when first Flutter frame received.
static void first_frame_cb(FlView* view, gpointer user_data) {
  gtk_widget_show(gtk_widget_get_toplevel(GTK_WIDGET(view)));
}

// Opens a window whose Dart main() receives [args] (folder, flags).
static void create_window(MyApplication* self, char** args) {
  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(self)));

  // Finder draws its own toolbar with traffic-light buttons, so the GTK
  // header bar is installed (to keep client-side shadows and resize edges)
  // but hidden. FINDER_SYSTEM_TITLEBAR=1 restores the native title bar.
  GtkHeaderBar* header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
  gtk_header_bar_set_title(header_bar, "Finder");
  gtk_header_bar_set_show_close_button(header_bar, TRUE);
  gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));
  if (g_strcmp0(g_getenv("FINDER_SYSTEM_TITLEBAR"), "1") == 0) {
    gtk_widget_show(GTK_WIDGET(header_bar));
  }
  gtk_window_set_title(window, "Finder");
  make_window_rounded(window);
  gtk_window_set_default_size(window, 1100, 680);
  g_signal_connect(window, "delete-event", G_CALLBACK(window_delete_cb),
                   nullptr);

  // The index keeps the engines apart in the drag & drop plugin (see
  // isolateIdSalt in third_party/irondash_message_channel).
  g_autoptr(GStrvBuilder) builder = g_strv_builder_new();
  g_strv_builder_addv(builder, const_cast<const char**>(args));
  g_autofree gchar* index =
      g_strdup_printf("--window-index=%u", self->windows_opened++);
  g_strv_builder_add(builder, index);
  g_auto(GStrv) engine_args = g_strv_builder_end(builder);
  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(project, engine_args);

  FlView* view = fl_view_new(project);
  GdkRGBA background_color;
  gdk_rgba_parse(&background_color, "#00000000");
  fl_view_set_background_color(view, &background_color);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  // Show the window when Flutter renders.
  // Requires the view to be realized so we can start rendering.
  g_signal_connect(view, "first-frame", G_CALLBACK(first_frame_cb), nullptr);
  gtk_widget_realize(GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  FinderWindow* fw = g_new0(FinderWindow, 1);
  fw->app = self;
  fw->window = window;
  fw->channel = fl_method_channel_new(
      fl_engine_get_binary_messenger(fl_view_get_engine(view)),
      "finder/window", FL_METHOD_CODEC(fl_standard_method_codec_new()));
  fl_method_channel_set_method_call_handler(fw->channel, window_method_call_cb,
                                            fw, nullptr);
  g_object_set_data(G_OBJECT(window), "finder-window", fw);
  g_signal_connect(window, "window-state-event", G_CALLBACK(window_state_cb),
                   fw);
  g_signal_connect(window, "destroy", G_CALLBACK(window_destroy_cb), fw);

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

// The Dart VM is shared by every engine in the process, and it runs on the
// compiled Dart code (libapp.so) loaded by the engine that started first.
// When that engine shuts down it unloads its copy, and the other windows,
// still running on it, crash. So the first engine is one that never shuts
// down: its window is realized (FlView then starts the engine) but never
// shown, isn't one of the app's windows, and its Dart main() returns at
// once. Every real window is a later engine and can close safely.
static void start_host_engine(MyApplication* self) {
  self->host_window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
  g_autoptr(FlDartProject) project = fl_dart_project_new();
  char* args[] = {const_cast<char*>(kHostEngineFlag), nullptr};
  fl_dart_project_set_dart_entrypoint_arguments(project, args);
  FlView* view = fl_view_new(project);
  gtk_container_add(GTK_CONTAINER(self->host_window), GTK_WIDGET(view));
  gtk_widget_show(GTK_WIDGET(view));
  gtk_widget_realize(GTK_WIDGET(view));
}

// A launch that may become a tab of an open window ("open folders in
// tabs" is a Dart setting, so the window decides).
typedef struct {
  MyApplication* app;
  GStrv args;
} Launch;

static void launch_answered_cb(GObject* object, GAsyncResult* result,
                               gpointer user_data) {
  Launch* launch = static_cast<Launch*>(user_data);
  g_autoptr(GError) error = nullptr;
  g_autoptr(FlMethodResponse) response = fl_method_channel_invoke_method_finish(
      FL_METHOD_CHANNEL(object), result, &error);
  FlValue* taken = response == nullptr
                       ? nullptr
                       : fl_method_response_get_result(response, nullptr);
  const gboolean handled = taken != nullptr &&
                           fl_value_get_type(taken) == FL_VALUE_TYPE_BOOL &&
                           fl_value_get_bool(taken);
  if (!handled) create_window(launch->app, launch->args);
  g_application_release(G_APPLICATION(launch->app));
  g_strfreev(launch->args);
  g_free(launch);
}

// Opens what a command line asks for: the first window of the session, a
// tab in the active window, or one more window.
static void handle_launch(MyApplication* self, char** args) {
  GtkWindow* active = gtk_application_get_active_window(GTK_APPLICATION(self));
  FinderWindow* fw = finder_window_of(active);
  if (fw == nullptr) {
    create_window(self, args);
    return;
  }
  // Later windows never restore the saved tabs; only the first one does.
  g_autoptr(GStrvBuilder) builder = g_strv_builder_new();
  if (!g_strv_contains(args, kNewWindowFlag)) {
    g_strv_builder_add(builder, kNewWindowFlag);
  }
  g_strv_builder_addv(builder, const_cast<const char**>(args));
  Launch* launch = g_new0(Launch, 1);
  launch->app = self;
  launch->args = g_strv_builder_end(builder);
  g_application_hold(G_APPLICATION(self));
  g_autoptr(FlValue) list = fl_value_new_list();
  for (char** a = args; *a != nullptr; a++) {
    fl_value_append_take(list, fl_value_new_string(*a));
  }
  fl_method_channel_invoke_method(fw->channel, "launch", list, nullptr,
                                  launch_answered_cb, launch);
}

// Implements GApplication::command_line, in the first Finder process, for
// its own launch and every later one.
static int my_application_command_line(GApplication* application,
                                       GApplicationCommandLine* command_line) {
  MyApplication* self = MY_APPLICATION(application);
  gint argc = 0;
  g_auto(GStrv) argv =
      g_application_command_line_get_arguments(command_line, &argc);
  // Relative folders are relative to where that launch ran, not to us.
  const gchar* cwd = g_application_command_line_get_cwd(command_line);
  g_autoptr(GStrvBuilder) builder = g_strv_builder_new();
  for (gint i = 1; i < argc; i++) {
    const char* arg = argv[i];
    if (cwd != nullptr && arg[0] != '-' && arg[0] != '/' &&
        !g_str_has_prefix(arg, "file:")) {
      g_autofree gchar* absolute = g_build_filename(cwd, arg, nullptr);
      g_strv_builder_add(builder, absolute);
    } else {
      g_strv_builder_add(builder, arg);
    }
  }
  g_auto(GStrv) args = g_strv_builder_end(builder);
  handle_launch(self, args);
  return 0;
}

// Implements GApplication::startup.
static void my_application_startup(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  G_APPLICATION_CLASS(my_application_parent_class)->startup(application);

  g_autoptr(GtkCssProvider) css = gtk_css_provider_new();
  gtk_css_provider_load_from_data(
      css,
      "window.finder-window { background-color: transparent; }"
      "window.finder-window decoration { border-radius: 10px; }",
      -1, nullptr);
  gtk_style_context_add_provider_for_screen(
      gdk_screen_get_default(), GTK_STYLE_PROVIDER(css),
      GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);

  self->event_signal_id = g_signal_lookup("event", GTK_TYPE_WIDGET);
  self->press_hook_id = g_signal_add_emission_hook(
      self->event_signal_id, 0, button_press_hook, self, nullptr);

  start_host_engine(self);
}

// Implements GObject::dispose.
static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  if (self->press_hook_id != 0) {
    g_signal_remove_emission_hook(self->event_signal_id, self->press_hook_id);
    self->press_hook_id = 0;
  }
  g_clear_pointer(&self->last_press, gdk_event_free);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->command_line = my_application_command_line;
  G_APPLICATION_CLASS(klass)->startup = my_application_startup;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
  // Set the program name to the application ID, which helps various systems
  // like GTK and desktop environments map this running application to its
  // corresponding .desktop file. This ensures better integration by allowing
  // the application to be recognized beyond its binary name.
  g_set_prgname(APPLICATION_ID);

  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID, "flags",
                                     G_APPLICATION_HANDLES_COMMAND_LINE,
                                     nullptr));
}
