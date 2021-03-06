#include "random.hpp"
#include <fmt/core.h>
#include <random>

namespace application {

std::string random()
{
  static thread_local std::random_device rd;
  static thread_local std::uniform_int_distribution<std::size_t> dist(
    0, std::numeric_limits<std::size_t>::max());

  std::string result;
  for (auto i = 0; i < 1000; i++)
  {
    result = fmt::format("{}", dist(rd));
  }
  return result;
}

}  // namespace application
