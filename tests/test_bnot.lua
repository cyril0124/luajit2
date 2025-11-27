-- Test bitwise NOT operator (~) against bit.bnot as golden reference
local bit = require("bit")

local function test_bnot_basic()
    print("Testing basic unary ~ operator (NOT)...")
    
    -- Basic tests
    assert((~0) == bit.bnot(0), "~0 failed")
    assert((~1) == bit.bnot(1), "~1 failed")
    assert((~0xFF) == bit.bnot(0xFF), "~0xFF failed")
    assert((~0xFFFFFFFF) == bit.bnot(0xFFFFFFFF), "~0xFFFFFFFF failed")
    
    -- Test with variables
    local a = 0x12345678
    assert((~a) == bit.bnot(a), "variable ~ failed")
    
    -- Double NOT should return original (with 32-bit truncation)
    local x = 0x12345678
    assert((~~x) == bit.bnot(bit.bnot(x)), "double ~ failed")
    
    -- Test all bits set
    assert((~-1) == bit.bnot(-1), "~-1 failed")
    
    -- NOT of NOT should give back original
    for i = 0, 10 do
        assert((~~i) == bit.bnot(bit.bnot(i)), "double NOT failed for " .. i)
    end
    
    print("Basic unary ~ tests passed!")
end

local function test_bnot_edge_cases()
    print("Testing unary ~ edge cases...")
    
    -- Test with maxint
    local maxint = 0x7FFFFFFF
    assert((~maxint) == bit.bnot(maxint), "~maxint failed")
    
    -- Test with negative numbers
    assert((~(-1)) == bit.bnot(-1), "~-1 failed")
    assert((~(-2)) == bit.bnot(-2), "~-2 failed")
    
    -- Verify two's complement behavior: ~x + 1 == -x
    assert((~0 + 1) == -0, "two's complement check 1 failed")
    assert((~5 + 1) == -5, "two's complement check 2 failed")
    assert((~(-1) + 1) == -(-1), "two's complement check 3 failed")
    
    -- FFI cdata tests (ULL, LL)
    assert(~1ULL == bit.bnot(1ULL), "~1ULL failed")
    assert(~0xFFULL == bit.bnot(0xFFULL), "~0xFFULL failed")
    assert(~0x0ULL == bit.bnot(0x0ULL), "~0x0ULL failed")
    
    print("Edge case unary ~ tests passed!")
end

local function test_bnot_jit()
    print("Testing unary ~ with JIT...")
    
    local function loop_test()
        local sum = 0
        for i = 0, 99 do
            sum = sum + (~i & 0xFF)
        end
        return sum
    end
    
    local function loop_test_golden()
        local sum = 0
        for i = 0, 99 do
            sum = sum + bit.band(bit.bnot(i), 0xFF)
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
    print("JIT unary ~ tests passed!")
end

local function test_bnot_patterns()
    print("Testing unary ~ common patterns...")
    
    -- Creating masks
    local mask8 = ~(~0 << 8)
    local g_mask8 = bit.bnot(bit.lshift(bit.bnot(0), 8))
    assert(mask8 == g_mask8, "mask creation failed")
    
    -- Toggling bits
    local flags = 0xFF
    flags = ~flags
    local g_flags = bit.bnot(0xFF)
    assert(flags == g_flags, "bit toggle failed")
    
    print("Pattern unary ~ tests passed!")
end

-- Run all tests
test_bnot_basic()
test_bnot_edge_cases()
test_bnot_jit()
test_bnot_patterns()

print("All unary ~ operator tests passed!")
