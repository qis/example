#pragma once

// ============================================================================
// date
// ============================================================================
#include <date/date.h>
#include <date/tz.h>

// ============================================================================
// fmt
// ============================================================================
#include <fmt/format.h>
#include <fmt/ostream.h>

// ============================================================================

#include <algorithm>
#include <atomic>
#include <bitset>
#include <chrono>
#include <condition_variable>
#include <exception>
#include <filesystem>
#include <fstream>
#include <limits>
#include <memory>
#include <mutex>
#include <new>
#include <numeric>
#include <optional>
#include <random>
#include <regex>
#include <shared_mutex>
#include <sstream>
#include <stdexcept>
#include <string>
#include <string_view>
#include <system_error>
#include <thread>
#include <tuple>
#include <utility>
#include <variant>
#include <cmath>
#include <cstddef>
#include <cstdint>
#include <cstdio>
#include <cstdlib>

// ============================================================================

using namespace std::literals::chrono_literals;
using namespace std::literals::string_literals;
using namespace std::literals::string_view_literals;

// ============================================================================

template <>
struct fmt::formatter<std::filesystem::path> : fmt::formatter<std::string_view>
{
  template <typename FormatContext>
  auto format(const std::filesystem::path& path, FormatContext& context)
  {
    return fmt::formatter<std::string_view>::format(path.string(), context);
  }
};
