-- Test bitwise AND operator (&) against bit.band as golden reference
local bit = require("bit")

local function test_band_basic()
    print("Testing basic & operator...")
    
    -- Basic tests
    assert((1 & 1) == bit.band(1, 1), "1 & 1 failed")
    assert((3 & 2) == bit.band(3, 2), "3 & 2 failed")
    assert((0xFF & 0xFF00) == bit.band(0xFF, 0xFF00), "0xFF & 0xFF00 failed")
    assert((0xFF & 0x0F) == bit.band(0xFF, 0x0F), "0xFF & 0x0F failed")
    
    -- Test with variables
    local a, b = 5, 3
    assert((a & b) == bit.band(a, b), "variable & failed")
    
    -- Test with zero
    assert((0 & 0) == bit.band(0, 0), "0 & 0 failed")
    assert((0 & 1) == bit.band(0, 1), "0 & 1 failed")
    assert((1 & 0) == bit.band(1, 0), "1 & 0 failed")
    
    -- Test with -1 (all bits set)
    assert((0xFF & -1) == bit.band(0xFF, -1), "0xFF & -1 failed")
    assert((-1 & 0xFF) == bit.band(-1, 0xFF), "-1 & 0xFF failed")
    
    -- Test with larger values
    assert((0x12345678 & 0x87654321) == bit.band(0x12345678, 0x87654321), "large values failed")
    
    -- Test all bits set
    assert((-1 & -1) == bit.band(-1, -1), "-1 & -1 failed")
    
    print("Basic & tests passed!")
end

local function test_band_64bit()
    print("Testing 64-bit & operator...")
    
    -- ULL suffix tests
    assert((1ULL & 1ULL) == 1ULL, "1ULL & 1ULL failed")
    assert((0xFFFFFFFFULL & 0xFFFFFFFF00000000ULL) == 0, "64-bit mask failed")
    assert((0x123456789ABCDEF0ULL & 0xFFFFFFFF) == 0x9ABCDEF0ULL, "64-bit truncation failed")
    
    -- Mixed 32/64 bit
    assert((1ULL & 1) == 1, "1ULL & 1 failed")
    assert((1 & 1ULL) == 1, "1 & 1ULL failed")
    
    print("64-bit & tests passed!")
end

local function test_band_edge_cases()
    print("Testing & edge cases...")
    
    -- Test with maxint
    local maxint = 0x7FFFFFFF
    assert((maxint & maxint) == bit.band(maxint, maxint), "maxint & maxint failed")
    assert((maxint & 0) == bit.band(maxint, 0), "maxint & 0 failed")
    
    -- Test with negative numbers
    assert(((-1) & (-2)) == bit.band(-1, -2), "-1 & -2 failed")
    assert(((-5) & 3) == bit.band(-5, 3), "-5 & 3 failed")
    
    -- Test chained operations
    assert((7 & 6 & 4) == bit.band(bit.band(7, 6), 4), "chained & failed")
    
    print("Edge case & tests passed!")
end

local function test_band_jit()
    print("Testing & with JIT...")
    
    local function loop_test()
        local sum = 0
        for i = 1, 1000 do
            sum = sum + (i & 0xFF)
        end
        return sum
    end
    
    local function loop_test_golden()
        local sum = 0
        for i = 1, 1000 do
            sum = sum + bit.band(i, 0xFF)
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
    print("JIT & tests passed!")
end

-- Run all tests
test_band_basic()
test_band_64bit()
test_band_edge_cases()
test_band_jit()

print("All & operator tests passed!")
