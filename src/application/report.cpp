#include "report.hpp"

namespace application {

void report() {
  const auto tp = std::chrono::floor<std::chrono::minutes>(date::utc_clock::now());

  fmt::print("Tokyo       : {:Asia/Tokyo}\n", tp);
  fmt::print("Moscow      : {:Europe/Moscow}\n", tp);
  fmt::print("Berlin      : {:Europe/Berlin}\n", tp);
  fmt::print("UTC         : {}\n", tp);
  fmt::print("US Eastern  : {:America/New_York}\n", tp);
  fmt::print("US Central  : {:America/Matamoros}\n", tp);
  fmt::print("US Mountain : {:America/Ojinaga}\n", tp);
  fmt::print("US Pacific  : {:America/Tijuana}\n", tp);

  std::regex re("^[a-z]+[0-9]+$", std::regex_constants::extended | std::regex_constants::nosubs);
  if (!std::regex_search("re0", re)) {
    throw std::runtime_error("Regex check failed.");
  }
}

}  // namespace application
