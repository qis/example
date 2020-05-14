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

namespace detail {

template <typename Clock, typename Duration, typename FormatContext>
inline auto format_time_point(const std::chrono::time_point<Clock, Duration>& tp, FormatContext& context) {
  static_assert(std::is_same_v<Clock, std::chrono::system_clock> || std::is_same_v<Clock, date::local_t>);
  const auto tpd = std::chrono::floor<date::days>(tp);
  const auto ymd = date::year_month_day{ tpd };
  const auto y = static_cast<int>(ymd.year());
  const auto m = static_cast<unsigned int>(ymd.month());
  const auto d = static_cast<unsigned int>(ymd.day());
  if constexpr (std::ratio_less_equal_v<typename Duration::period, std::chrono::hours::period>) {
    const auto sec = std::chrono::time_point<Clock, std::chrono::seconds>{ tpd };
    const auto tod = date::time_of_day<Duration>{ std::chrono::floor<Duration>(tp - sec) }.to_duration();
    return fmt::format_to(context.out(), "{:04}-{:02}-{:02} {}", y, m, d, std::chrono::floor<Duration>(tod));
  } else {
    return fmt::format_to(context.out(), "{:04}-{:02}-{:02}", y, m, d);
  }
}

}  // namespace detail

template <typename Rep, typename Period>
struct fmt::formatter<std::chrono::duration<Rep, Period>> : fmt::formatter<std::string_view> {
  template <typename FormatContext>
  auto format(const std::chrono::duration<Rep, Period>& duration, FormatContext& context) {
    const auto h = std::chrono::floor<std::chrono::hours>(duration);
    if constexpr (std::ratio_less_equal_v<Period, std::chrono::minutes::period>) {
      const auto m = std::chrono::floor<std::chrono::minutes>(duration - h);
      if constexpr (std::ratio_less_equal_v<Period, std::chrono::seconds::period>) {
        const auto s = std::chrono::floor<std::chrono::seconds>(duration - h - m);
        if constexpr (std::ratio_less_equal_v<Period, std::chrono::nanoseconds::period>) {
          const auto ns = std::chrono::floor<std::chrono::nanoseconds>(duration - h - m - s);
          return format_to(context.out(), "{:02}:{:02}:{:02}.{:09}", h.count(), m.count(), s.count(), ns.count());
        } else if constexpr (std::ratio_less_equal_v<Period, std::chrono::microseconds::period>) {
          const auto us = std::chrono::floor<std::chrono::microseconds>(duration - h - m - s);
          return format_to(context.out(), "{:02}:{:02}:{:02}.{:06}", h.count(), m.count(), s.count(), us.count());
        } else if constexpr (std::ratio_less_equal_v<Period, std::chrono::milliseconds::period>) {
          const auto ms = std::chrono::floor<std::chrono::milliseconds>(duration - h - m - s);
          return format_to(context.out(), "{:02}:{:02}:{:02}.{:03}", h.count(), m.count(), s.count(), ms.count());
        } else {
          return format_to(context.out(), "{:02}:{:02}:{:02}", h.count(), m.count(), s.count());
        }
      } else {
        return format_to(context.out(), "{:02}:{:02}", h.count(), m.count());
      }
    } else {
      return format_to(context.out(), "{:02}:00", h.count());
    }
  }
};

template <typename Duration>
struct fmt::formatter<date::local_time<Duration>> : fmt::formatter<std::string_view> {
  template <typename FormatContext>
  auto format(const date::local_time<Duration>& tp, FormatContext& context) {
    return detail::format_time_point(tp, context);
  }
};

template <typename Duration>
struct fmt::formatter<date::sys_time<Duration>> {
  const date::time_zone* tz = nullptr;

  template <typename ParseContext>
  constexpr auto parse(ParseContext& context) {
    const auto beg = context.begin();
    const auto end = context.end();
    if (*beg != '}') {
      auto it = beg;
      while (it != end && *it != '}') {
        it = std::next(it);
      }
      tz = date::locate_zone({ beg, static_cast<std::size_t>(std::distance(beg, it)) });
      context.advance_to(it);
    }
    return context.begin();
  }

  template <typename FormatContext>
  auto format(const date::sys_time<Duration>& tp, FormatContext& context) {
    if (tz) {
      return detail::format_time_point(std::chrono::floor<Duration>(date::make_zoned(tz, tp).get_local_time()), context);
    }
    return detail::format_time_point(tp, context);
  }
};

template <typename Duration>
struct fmt::formatter<date::utc_time<Duration>> : fmt::formatter<date::sys_time<Duration>> {
  template <typename FormatContext>
  auto format(const date::utc_time<Duration>& tp, FormatContext& context) {
    using seconds = std::common_type_t<Duration, std::chrono::seconds>;
    const auto tpu = std::chrono::floor<seconds>(tp);
    const auto tps = date::sys_time<seconds>(tpu.time_since_epoch() - date::is_leap_second(tpu).second);
    return fmt::formatter<date::sys_time<Duration>>::format(std::chrono::floor<Duration>(tps), context);
  }
};

template <>
struct fmt::formatter<std::filesystem::path> : fmt::formatter<std::string_view> {
  template <typename FormatContext>
  auto format(const std::filesystem::path& path, FormatContext& context) {
    return fmt::formatter<std::string_view>::format(path.string(), context);
  }
};
