#include "egl_display_guard.h"

#include <epoxy/egl.h>

// Every Finder window is a Flutter engine in this one process. When an
// engine shuts down (its window closed), Flutter's Linux embedder calls
// eglTerminate() on the EGL display it got for GDK's Wayland connection.
// That display is the same object for every engine and for GDK itself, so
// terminating it invalidates the OpenGL state of all the other windows,
// which then crash on their next frame.
//
// The embedder reaches EGL through libepoxy, whose entry points are
// process-wide function pointers; pointing eglTerminate's at a no-op keeps
// the display alive as long as the process, which is what a display shared
// by the whole process should do anyway. The OS reclaims it at exit.

static EGLBoolean keep_display(EGLDisplay /*display*/) {
  return EGL_TRUE;
}

void egl_display_guard_install() {
  epoxy_eglTerminate = keep_display;
}
