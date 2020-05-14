#include <application/random.hpp>
#include <catch.hpp>

TEST_CASE("application::random") {
  REQUIRE(!application::random().empty());
}
