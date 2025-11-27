-- Test right shift operator (>>) against bit.rshift as golden reference
local bit = require("bit")

local function test_shr_basic()
    print("Testing basic >> operator...")
    
    -- Basic tests
    assert((4 >> 2) == bit.rshift(4, 2), "4 >> 2 failed")
    assert((8 >> 1) == bit.rshift(8, 1), "8 >> 1 failed")
    assert((0x40000000 >> 30) == bit.rshift(0x40000000, 30), "0x40000000 >> 30 failed")
    
    -- Test with variables
    local a, b = 16, 4
    assert((a >> b) == bit.rshift(a, b), "variable >> failed")
    
    -- Test with zero
    assert((0 >> 5) == bit.rshift(0, 5), "0 >> 5 failed")
    assert((5 >> 0) == bit.rshift(5, 0), "5 >> 0 failed")
    
    -- Test common patterns
    assert((0xFF >> 2) == bit.rshift(0xFF, 2), "0xFF >> 2 failed")
    assert((0x3fc >> 2) == bit.rshift(0x3fc, 2), "0x3fc >> 2 failed")
    
    -- Test max positive value
    assert((0x7FFFFFFF >> 1) == bit.rshift(0x7FFFFFFF, 1), "maxint >> 1 failed")
    
    print("Basic >> tests passed!")
end

local function test_shr_edge_cases()
    print("Testing >> edge cases...")
    
    -- Shift by more than 31 should wrap (modulo 32)
    assert((0xFF >> 32) == bit.rshift(0xFF, 32), "0xFF >> 32 failed")
    assert((0xFF >> 33) == bit.rshift(0xFF, 33), "0xFF >> 33 failed")
    
    -- Test with negative shift amounts
    local result1 = 8 >> -1
    local result2 = bit.rshift(8, -1)
    assert(result1 == result2, "8 >> -1 behavior mismatch")
    
    -- Logical shift should zero-fill
    -- Note: In Lua 5.3, >> is logical shift (unsigned)
    -- bit.rshift is also logical (unsigned) shift
    local large_val = 0x80000000
    assert((large_val >> 1) == bit.rshift(large_val, 1), "logical shift of negative failed")
    
    -- FFI cdata tests (ULL, LL)
    assert((8ULL >> 2) == bit.rshift(8ULL, 2), "8ULL >> 2 failed")
    assert((0x40000000ULL >> 30) == bit.rshift(0x40000000ULL, 30), "0x40000000ULL >> 30 failed")
    assert((0x8000000000000000ULL >> 63) == bit.rshift(0x8000000000000000ULL, 63), "64-bit shift failed")
    assert((1ULL >> 1ULL) == bit.rshift(1ULL, 1ULL), "ULL >> ULL failed")
    assert((0x40000000 >> 30ULL) == bit.rshift(0x40000000, 30ULL), "number >> ULL failed")
    
    print("Edge case >> tests passed!")
end

local function test_shr_jit()
    print("Testing >> with JIT...")
    
    local function loop_test()
        local sum = 0
        for i = 1, 100 do
            sum = sum + (i >> 1)
        end
        return sum
    end
    
    local function loop_test_golden()
        local sum = 0
        for i = 1, 100 do
            sum = sum + bit.rshift(i, 1)
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
    print("JIT >> tests passed!")
end

local function test_shr_patterns()
    print("Testing >> common patterns...")
    
    -- Division by powers of 2 (for positive numbers)
    for i = 0, 10 do
        local val = 1024
        assert((val >> i) == bit.rshift(val, i), "division pattern failed at " .. i)
    end
    
    -- Extracting bytes
    local word = 0x12345678
    local byte0 = word & 0xFF
    local byte1 = (word >> 8) & 0xFF
    local byte2 = (word >> 16) & 0xFF
    local byte3 = (word >> 24) & 0xFF
    
    local g_byte0 = bit.band(word, 0xFF)
    local g_byte1 = bit.band(bit.rshift(word, 8), 0xFF)
    local g_byte2 = bit.band(bit.rshift(word, 16), 0xFF)
    local g_byte3 = bit.band(bit.rshift(word, 24), 0xFF)
    
    assert(byte0 == g_byte0, "byte0 extraction failed")
    assert(byte1 == g_byte1, "byte1 extraction failed")
    assert(byte2 == g_byte2, "byte2 extraction failed")
    assert(byte3 == g_byte3, "byte3 extraction failed")
    
    print("Pattern >> tests passed!")
end

-- Run all tests
test_shr_basic()
test_shr_edge_cases()
test_shr_jit()
test_shr_patterns()

print("All >> operator tests passed!")
