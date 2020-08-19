#include <application/random.hpp>
#include <gtest/gtest.h>

TEST(application, random) {
  ASSERT_FALSE(application::random().empty());
}
