#define DOCTEST_CONFIG_IMPLEMENT
#include "doctest/doctest.h"
#include <application/random.hpp>

TEST_CASE("application::random")
{
  REQUIRE(!application::random().empty());
}

int main(int argc, char* argv[])
{
  doctest::Context context;
  context.applyCommandLine(argc, argv);
  context.setOption("no-version", 1);
  return context.run();
}
