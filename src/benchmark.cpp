#include "benchmark/benchmark.h"
#include <application/random.hpp>

static void random(benchmark::State& state)
{
  for (auto _ : state)
  {
    const auto str = application::random();
    benchmark::DoNotOptimize(str);
  }
}
BENCHMARK(random);

int main(int argc, char** argv)
{
  benchmark::Initialize(&argc, argv);
  if (benchmark::ReportUnrecognizedArguments(argc, argv))
  {
    return EXIT_FAILURE;
  }
  benchmark::RunSpecifiedBenchmarks();
}
