-- Test bitwise OR operator (|) against bit.bor as golden reference
local bit = require("bit")

local function test_bor_basic()
    print("Testing basic | operator...")
    
    -- Basic tests
    assert((1 | 2) == bit.bor(1, 2), "1 | 2 failed")
    assert((1 | 3) == bit.bor(1, 3), "1 | 3 failed")
    assert((0x0F | 0xF0) == bit.bor(0x0F, 0xF0), "0x0F | 0xF0 failed")
    
    -- Test with variables
    local a, b = 1, 2
    local c = a | b
    assert(c == bit.bor(a, b), "variable | failed")
    
    -- Test with zero
    assert((0 | 0) == bit.bor(0, 0), "0 | 0 failed")
    assert((0 | 1) == bit.bor(0, 1), "0 | 1 failed")
    assert((1 | 0) == bit.bor(1, 0), "1 | 0 failed")
    
    -- Test with -1 (all bits set)
    assert((0xFF | -1) == bit.bor(0xFF, -1), "0xFF | -1 failed")
    assert((-1 | 0xFF) == bit.bor(-1, 0xFF), "-1 | 0xFF failed")
    
    -- Test with larger values
    assert((0x12345678 | 0x87654321) == bit.bor(0x12345678, 0x87654321), "large values failed")
    
    -- Test all bits set
    assert((-1 | -1) == bit.bor(-1, -1), "-1 | -1 failed")
    
    print("Basic | tests passed!")
end

local function test_bor_edge_cases()
    print("Testing | edge cases...")
    
    -- Test with maxint
    local maxint = 0x7FFFFFFF
    assert((maxint | maxint) == bit.bor(maxint, maxint), "maxint | maxint failed")
    assert((maxint | 0) == bit.bor(maxint, 0), "maxint | 0 failed")
    
    -- Test with negative numbers
    assert(((-1) | (-2)) == bit.bor(-1, -2), "-1 | -2 failed")
    assert(((-5) | 3) == bit.bor(-5, 3), "-5 | 3 failed")
    
    -- Test chained operations
    assert((1 | 2 | 4) == bit.bor(bit.bor(1, 2), 4), "chained | failed")
    
    -- FFI cdata tests (ULL, LL)
    assert((8ULL | 4ULL) == bit.bor(8ULL, 4ULL), "8ULL | 4ULL failed")
    assert((0xF0ULL | 0x0F) == bit.bor(0xF0ULL, 0x0F), "0xF0ULL | 0x0F failed")
    assert((1 | 2ULL) == bit.bor(1, 2ULL), "1 | 2ULL failed")
    
    print("Edge case | tests passed!")
end

local function test_bor_jit()
    print("Testing | with JIT...")
    
    local function loop_test()
        local result = 0
        for i = 1, 100 do
            result = result | i
        end
        return result
    end
    
    local function loop_test_golden()
        local result = 0
        for i = 1, 100 do
            result = bit.bor(result, i)
        end
        return result
    end
    
    -- Run with JIT on
    jit.on()
    local result_jit = loop_test()
    local golden_jit = loop_test_golden()
    assert(result_jit == golden_jit, "JIT loop test failed")
    
    -- Run with JIT off
    jit.off()
    local result_no_jit = loop_test()
    local golden_no_jit = loop_test_golden()
    assert(result_no_jit == golden_no_jit, "No-JIT loop test failed")
    
    -- Both should produce the same result
    assert(result_jit == result_no_jit, "JIT vs no-JIT mismatch")
    
    jit.on()
    print("JIT | tests passed!")
end

-- Run all tests
test_bor_basic()
test_bor_edge_cases()
test_bor_jit()

print("All | operator tests passed!")
