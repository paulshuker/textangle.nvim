-- Call to run all tests.
local TESTS = { "test_text" }

jit.off() -- Disable JIT compilation

print("Running " .. #TESTS .. " Test(s)")

for _, test in pairs(TESTS) do
   local script = require("tests." .. test)
   -- Every test class must have a run function.
   script.run()
   print("  " .. test .. ": PASSED")
end
