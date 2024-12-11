-- Call to run all tests.
local TESTS = { "test_checker", "test_text" }
local BENCHMARKS = { "benchmark_text" }

print("Running " .. #TESTS .. " Test(s):")

for _, test in ipairs(TESTS) do
   local script = require("lua.tests." .. test)
   -- Every test class must have a run function.
   script.run()
   print("  " .. test .. "... PASSED")
end

print("Running " .. #BENCHMARKS .. " Benchmark(s):")

for _, benchmark in ipairs(BENCHMARKS) do
   local script = require("lua.tests." .. benchmark)
   script.run()
   print("  " .. benchmark .. "... PASSED")
end
