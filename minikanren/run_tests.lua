-- Test runner for MicroKanren in Lua

-- Run core tests
print("Running core tests...")
require("tests.test_microkanren")
print("\n")

-- Run problem tests
print("Running problem tests...")
require("tests.test_problem1")
print("\n")

print("All tests completed successfully!")
