#include <application/random.hpp>

int main()
{
  try {
    fmt::print("{}\n", application::random());
  }
  catch (const std::exception& e) {
    fmt::print(stderr, "error: {}\n", e.what());
    return EXIT_FAILURE;
  }
  return EXIT_SUCCESS;
}
