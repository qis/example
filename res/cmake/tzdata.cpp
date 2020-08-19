#include <date/date.h>
#include <date/tz.h>
#include <filesystem>
#include <system_error>
#include <cstdio>
#include <cstdlib>
#include <windows.h>

namespace tzdata {

[[noreturn]] void exit(const char* message, std::error_code ec)
{
  std::fprintf(stderr, "%s: %s (%d)\n", message, ec.message().data(), ec.value());
  std::exit(ec.value());
}

const bool initialized = []() {
  std::string executable;
  DWORD size = 0;
  DWORD code = 0;
  do {
    executable.resize(executable.size() + MAX_PATH);
    size = GetModuleFileName(nullptr, executable.data(), static_cast<DWORD>(executable.size()));
    code = GetLastError();
  } while (code == ERROR_INSUFFICIENT_BUFFER);
  if (code) {
    const auto ec = std::error_code{ static_cast<int>(code), std::system_category() };
    exit("Could not locate executable", ec);
    return false;
  }
  executable.resize(size);
  const auto path = std::filesystem::path(executable).parent_path();
  auto tzdata = path / "tzdata";
  if (!std::filesystem::is_directory(tzdata)) {
    tzdata = path.parent_path() / "tzdata";
  }
  if (!std::filesystem::is_directory(tzdata)) {
    tzdata = path.parent_path() / "share" / "tzdata";
  }
  if (!std::filesystem::is_directory(tzdata)) {
    const auto ec = std::make_error_code(std::errc::no_such_file_or_directory);
    exit("Could not locate tzdata directory", ec);
    return false;
  }
  date::set_install(std::filesystem::canonical(tzdata).string());
  return true;
}();

}  // namespace tzdata
