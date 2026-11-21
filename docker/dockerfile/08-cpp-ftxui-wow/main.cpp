#include <atomic>
#include <chrono>
#include <thread>
#include <ftxui/component/captured_mouse.hpp>
#include <ftxui/component/component.hpp>
#include <ftxui/component/component_options.hpp>
#include <ftxui/component/screen_interactive.hpp>
#include <ftxui/dom/elements.hpp>

using namespace ftxui;
using namespace std::chrono_literals;

int main() {
  auto screen = ScreenInteractive::TerminalOutput();
  std::atomic<float> value{0.5f};
  std::atomic<bool> increasing{true};
  std::atomic<bool> running{true};

  // Фоновый поток обновляет шкалу. Флаг running позволяет корректно его остановить
  // до разрушения screen (в источнике поток просто detach-ился).
  std::thread update([&] {
    while (running.load()) {
      std::this_thread::sleep_for(50ms);
      float current = value.load();
      bool up = increasing.load();
      if (up) {
        current += 0.01f;
        if (current > 1.0f) {
          current = 1.0f;
          increasing.store(false);
        }
      } else {
        current -= 0.01f;
        if (current < 0.0f) {
          current = 0.0f;
          increasing.store(true);
        }
      }
      value.store(current);
      screen.Post([] {});
    }
  });

  auto quit_button = Button("Exit", screen.ExitLoopClosure(), ButtonOption::Animated());
  auto component = Renderer(quit_button, [&] {
    return vbox({
             text("Hello from FTXUI!") | bold | color(Color::Cyan),
             separator(),
             hbox({
               text("Gauge:"),
               gauge(value.load()) | size(WIDTH, EQUAL, 30) | color(Color::Green),
             }),
             separator(),
             quit_button->Render(),
           }) | border;
  });

  screen.Loop(component);
  running.store(false);
  if (update.joinable()) update.join();
  return 0;
}
