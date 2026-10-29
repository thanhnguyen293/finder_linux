#include "my_application.h"

#include <flutter_linux/flutter_linux.h>
#include <cstring>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

#include "flutter/generated_plugin_registrant.h"

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
  GtkWindow* window;
  FlMethodChannel* window_channel;
  // Last pointer press, needed to hand an in-progress drag to the compositor.
  GdkEvent* last_press;
  guint event_signal_id;
  gulong press_hook_id;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

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

static void start_window_drag(MyApplication* self) {
  if (self->last_press == nullptr) {
    g_warning("startDrag: no button press recorded, cannot move window");
    return;
  }
  GdkEventButton* press = reinterpret_cast<GdkEventButton*>(self->last_press);
  g_debug("startDrag: button %u at %.0f,%.0f", press->button, press->x_root,
          press->y_root);
  gtk_window_begin_move_drag(self->window, press->button,
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

  g_autoptr(GtkCssProvider) css = gtk_css_provider_new();
  gtk_css_provider_load_from_data(
      css,
      "window.finder-window { background-color: transparent; }"
      "window.finder-window decoration { border-radius: 10px; }",
      -1, nullptr);
  gtk_style_context_add_provider_for_screen(
      gtk_window_get_screen(window), GTK_STYLE_PROVIDER(css),
      GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);
  gtk_style_context_add_class(gtk_widget_get_style_context(GTK_WIDGET(window)),
                              "finder-window");
}

// Maximized, fullscreen and tiled windows have square corners, as on macOS.
static gboolean window_state_cb(GtkWidget* widget, GdkEventWindowState* event,
                                MyApplication* self) {
  const GdkWindowState square =
      static_cast<GdkWindowState>(GDK_WINDOW_STATE_MAXIMIZED |
                                  GDK_WINDOW_STATE_FULLSCREEN |
                                  GDK_WINDOW_STATE_TILED);
  if (self->window_channel != nullptr) {
    fl_method_channel_invoke_method(
        self->window_channel, "squareCornersChanged",
        fl_value_new_bool((event->new_window_state & square) != 0), nullptr,
        nullptr, nullptr);
  }
  return FALSE;
}

static void window_method_call_cb(FlMethodChannel* channel,
                                  FlMethodCall* method_call,
                                  gpointer user_data) {
  MyApplication* self = MY_APPLICATION(user_data);
  const gchar* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);
  g_autoptr(FlValue) result = nullptr;

  if (strcmp(method, "startDrag") == 0) {
    start_window_drag(self);
  } else if (strcmp(method, "minimize") == 0) {
    gtk_window_iconify(self->window);
  } else if (strcmp(method, "toggleMaximize") == 0) {
    if (gtk_window_is_maximized(self->window)) {
      gtk_window_unmaximize(self->window);
    } else {
      gtk_window_maximize(self->window);
    }
  } else if (strcmp(method, "close") == 0) {
    gtk_window_close(self->window);
  } else if (strcmp(method, "setTitle") == 0) {
    if (args != nullptr && fl_value_get_type(args) == FL_VALUE_TYPE_STRING) {
      gtk_window_set_title(self->window, fl_value_get_string(args));
    }
  } else {
    fl_method_call_respond_not_implemented(method_call, nullptr);
    return;
  }
  fl_method_call_respond_success(method_call, result, nullptr);
}

// Called when first Flutter frame received.
static void first_frame_cb(MyApplication* self, FlView* view) {
  gtk_widget_show(gtk_widget_get_toplevel(GTK_WIDGET(view)));
}

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

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
  self->event_signal_id = g_signal_lookup("event", GTK_TYPE_WIDGET);
  self->press_hook_id = g_signal_add_emission_hook(
      self->event_signal_id, 0, button_press_hook, self, nullptr);

  gtk_window_set_default_size(window, 1100, 680);

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(
      project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);
  GdkRGBA background_color;
  // Background defaults to black, override it here if necessary, e.g. #00000000
  // for transparent.
  gdk_rgba_parse(&background_color, "#00000000");
  fl_view_set_background_color(view, &background_color);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  // Show the window when Flutter renders.
  // Requires the view to be realized so we can start rendering.
  g_signal_connect_swapped(view, "first-frame", G_CALLBACK(first_frame_cb),
                           self);
  gtk_widget_realize(GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  self->window = window;
  self->window_channel = fl_method_channel_new(
      fl_engine_get_binary_messenger(fl_view_get_engine(view)),
      "finder/window", FL_METHOD_CODEC(fl_standard_method_codec_new()));
  fl_method_channel_set_method_call_handler(
      self->window_channel, window_method_call_cb, self, nullptr);
  g_signal_connect(window, "window-state-event", G_CALLBACK(window_state_cb),
                   self);

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

// Implements GApplication::local_command_line.
static gboolean my_application_local_command_line(GApplication* application,
                                                  gchar*** arguments,
                                                  int* exit_status) {
  MyApplication* self = MY_APPLICATION(application);
  // Strip out the first argument as it is the binary name.
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error)) {
    g_warning("Failed to register: %s", error->message);
    *exit_status = 1;
    return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  return TRUE;
}

// Implements GApplication::startup.
static void my_application_startup(GApplication* application) {
  // MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application startup.

  G_APPLICATION_CLASS(my_application_parent_class)->startup(application);
}

// Implements GApplication::shutdown.
static void my_application_shutdown(GApplication* application) {
  // MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application shutdown.

  G_APPLICATION_CLASS(my_application_parent_class)->shutdown(application);
}

// Implements GObject::dispose.
static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  if (self->press_hook_id != 0) {
    g_signal_remove_emission_hook(self->event_signal_id, self->press_hook_id);
    self->press_hook_id = 0;
  }
  g_clear_pointer(&self->last_press, gdk_event_free);
  g_clear_object(&self->window_channel);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line =
      my_application_local_command_line;
  G_APPLICATION_CLASS(klass)->startup = my_application_startup;
  G_APPLICATION_CLASS(klass)->shutdown = my_application_shutdown;
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
                                     G_APPLICATION_NON_UNIQUE, nullptr));
}
