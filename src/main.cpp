#include <application/random.hpp>
#include <application/report.hpp>

int main() {
  try {
    fmt::print("{}\n", application::random());
    application::report();
  }
  catch (const std::exception& e) {
    fmt::print(stderr, "error: {}\n", e.what());
    return EXIT_FAILURE;
  }
  return EXIT_SUCCESS;
}
