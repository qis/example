#include <gtest/gtest.h>
#include <application/random.hpp>

TEST(application, random)
{
  ASSERT_FALSE(application::random().empty());
}
