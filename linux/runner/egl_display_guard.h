#ifndef RUNNER_EGL_DISPLAY_GUARD_H_
#define RUNNER_EGL_DISPLAY_GUARD_H_

// Stops Flutter engines from terminating the process's shared EGL display
// when a window closes (see egl_display_guard.cc). Call before any engine
// starts.
void egl_display_guard_install();

#endif  // RUNNER_EGL_DISPLAY_GUARD_H_
