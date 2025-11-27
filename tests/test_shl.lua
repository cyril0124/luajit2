-- Test left shift operator (<<) against bit.lshift as golden reference
local bit = require("bit")

local function test_shl_basic()
    print("Testing basic << operator...")
    
    -- Basic tests
    assert((1 << 2) == bit.lshift(1, 2), "1 << 2 failed")
    assert((4 << 2) == bit.lshift(4, 2), "4 << 2 failed")
    assert((1 << 0) == bit.lshift(1, 0), "1 << 0 failed")
    assert((1 << 30) == bit.lshift(1, 30), "1 << 30 failed")
    
    -- Test with variables
    local a, b = 1, 8
    assert((a << b) == bit.lshift(a, b), "variable << failed")
    
    -- Test with zero
    assert((0 << 5) == bit.lshift(0, 5), "0 << 5 failed")
    assert((5 << 0) == bit.lshift(5, 0), "5 << 0 failed")
    
    -- Test common patterns
    assert((0xFF << 2) == bit.lshift(0xFF, 2), "0xFF << 2 failed")
    assert((0x01 << 16) == bit.lshift(0x01, 16), "0x01 << 16 failed")
    
    -- Larger shifts (should wrap around in 32-bit)
    assert((1 << 31) == bit.lshift(1, 31), "1 << 31 failed")
    
    print("Basic << tests passed!")
end

local function test_shl_edge_cases()
    print("Testing << edge cases...")
    
    -- Shift by more than 31 should wrap (modulo 32 in Lua 5.3)
    -- Note: bit.lshift only uses lower 5 bits of shift amount
    assert((1 << 32) == bit.lshift(1, 32), "1 << 32 failed")
    assert((1 << 33) == bit.lshift(1, 33), "1 << 33 failed")
    
    -- Test with negative shift amounts (undefined behavior, but should match)
    -- This might behave differently, so we test what we implement
    local result1 = 8 << -1
    local result2 = bit.lshift(8, -1)
    assert(result1 == result2, "8 << -1 behavior mismatch")
    
    -- Test with negative values
    assert(((-1) << 1) == bit.lshift(-1, 1), "-1 << 1 failed")
    assert(((-4) << 2) == bit.lshift(-4, 2), "-4 << 2 failed")
    
    -- FFI cdata tests (ULL, LL)
    assert((1ULL << 3) == bit.lshift(1ULL, 3), "1ULL << 3 failed")
    assert((0xFFULL << 8) == bit.lshift(0xFFULL, 8), "0xFFULL << 8 failed")
    assert((1 << 3ULL) == bit.lshift(1, 3ULL), "1 << 3ULL failed")
    
    print("Edge case << tests passed!")
end

local function test_shl_jit()
    print("Testing << with JIT...")
    
    local function loop_test()
        local sum = 0
        for i = 0, 15 do
            sum = sum + (1 << i)
        end
        return sum
    end
    
    local function loop_test_golden()
        local sum = 0
        for i = 0, 15 do
            sum = sum + bit.lshift(1, i)
        end
        return sum
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
    print("JIT << tests passed!")
end

local function test_shl_patterns()
    print("Testing << common patterns...")
    
    -- Powers of 2
    for i = 0, 30 do
        assert((1 << i) == bit.lshift(1, i), "power of 2 shift failed at " .. i)
    end
    
    -- Bit manipulation patterns
    local flags = 0
    flags = flags | (1 << 0)  -- Set bit 0
    flags = flags | (1 << 5)  -- Set bit 5
    flags = flags | (1 << 10) -- Set bit 10
    
    local golden_flags = 0
    golden_flags = bit.bor(golden_flags, bit.lshift(1, 0))
    golden_flags = bit.bor(golden_flags, bit.lshift(1, 5))
    golden_flags = bit.bor(golden_flags, bit.lshift(1, 10))
    
    assert(flags == golden_flags, "flag pattern failed")
    
    print("Pattern << tests passed!")
end

-- Run all tests
test_shl_basic()
test_shl_edge_cases()
test_shl_jit()
test_shl_patterns()

print("All << operator tests passed!")
