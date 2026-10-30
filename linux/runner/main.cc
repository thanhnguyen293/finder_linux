#include "egl_display_guard.h"
#include "my_application.h"

int main(int argc, char** argv) {
  egl_display_guard_install();
  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
