-- Test bitwise XOR operator (~) against bit.bxor as golden reference
local bit = require("bit")

local function test_bxor_basic()
    print("Testing basic ~ operator (binary XOR)...")
    
    -- Basic tests
    assert((5 ~ 3) == bit.bxor(5, 3), "5 ~ 3 failed")
    assert((1 ~ 4) == bit.bxor(1, 4), "1 ~ 4 failed")
    assert((0xFF ~ 0x0F) == bit.bxor(0xFF, 0x0F), "0xFF ~ 0x0F failed")
    
    -- Test with variables
    local a, b = 5, 3
    local c = a ~ b
    assert(c == bit.bxor(a, b), "variable ~ failed")
    
    -- Test with zero
    assert((0 ~ 0) == bit.bxor(0, 0), "0 ~ 0 failed")
    assert((0 ~ 1) == bit.bxor(0, 1), "0 ~ 1 failed")
    assert((1 ~ 0) == bit.bxor(1, 0), "1 ~ 0 failed")
    
    -- XOR with itself should be 0
    assert((5 ~ 5) == bit.bxor(5, 5), "5 ~ 5 failed")
    assert((0xFF ~ 0xFF) == bit.bxor(0xFF, 0xFF), "0xFF ~ 0xFF failed")
    
    -- Test with -1 (all bits set)
    assert((0xFF ~ -1) == bit.bxor(0xFF, -1), "0xFF ~ -1 failed")
    assert((-1 ~ 0xFF) == bit.bxor(-1, 0xFF), "-1 ~ 0xFF failed")
    
    -- Test with larger values
    assert((0x12345678 ~ 0x87654321) == bit.bxor(0x12345678, 0x87654321), "large values failed")
    
    print("Basic ~ tests passed!")
end

local function test_bxor_edge_cases()
    print("Testing ~ edge cases...")
    
    -- Test with maxint
    local maxint = 0x7FFFFFFF
    assert((maxint ~ maxint) == bit.bxor(maxint, maxint), "maxint ~ maxint failed")
    assert((maxint ~ 0) == bit.bxor(maxint, 0), "maxint ~ 0 failed")
    
    -- Test with negative numbers
    assert(((-1) ~ (-2)) == bit.bxor(-1, -2), "-1 ~ -2 failed")
    assert(((-5) ~ 3) == bit.bxor(-5, 3), "-5 ~ 3 failed")
    
    -- Test chained operations (XOR is associative)
    assert((1 ~ 2 ~ 4) == bit.bxor(bit.bxor(1, 2), 4), "chained ~ failed")
    
    -- Double XOR should return original
    local x = 0x12345678
    local key = 0xABCDEF01
    assert((x ~ key ~ key) == x, "double XOR failed")
    
    -- FFI cdata tests (ULL, LL)
    assert((15ULL ~ 3ULL) == bit.bxor(15ULL, 3ULL), "15ULL ~ 3ULL failed")
    assert((0xFFULL ~ 0xAA) == bit.bxor(0xFFULL, 0xAA), "0xFFULL ~ 0xAA failed")
    assert((1 ~ 2ULL) == bit.bxor(1, 2ULL), "1 ~ 2ULL failed")
    
    print("Edge case ~ tests passed!")
end

local function test_bxor_jit()
    print("Testing ~ with JIT...")
    
    local function loop_test()
        local result = 0
        for i = 1, 100 do
            result = result ~ i
        end
        return result
    end
    
    local function loop_test_golden()
        local result = 0
        for i = 1, 100 do
            result = bit.bxor(result, i)
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
    print("JIT ~ tests passed!")
end

-- Run all tests
test_bxor_basic()
test_bxor_edge_cases()
test_bxor_jit()

print("All ~ operator tests passed!")
