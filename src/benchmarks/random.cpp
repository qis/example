#include <application/random.hpp>
#include <benchmark/benchmark.h>

static void random(benchmark::State& state)
{
  for (auto _ : state) {
    const auto str = application::random();
    benchmark::DoNotOptimize(str);
  }
}
BENCHMARK(random);
