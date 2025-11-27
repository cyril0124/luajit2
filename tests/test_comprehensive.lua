-- Comprehensive bitwise operator tests combining all operations
local bit = require("bit")

local function test_combined_operations()
    print("Testing combined bitwise operations...")
    
    -- Test operator precedence and combination
    local a = 0xFF
    local b = 0x0F
    local c = 0xF0
    
    -- Complex expression
    local result = (a & b) | (a & c)
    local golden = bit.bor(bit.band(a, b), bit.band(a, c))
    assert(result == golden, "combined & | failed")
    
    -- Shift and mask
    result = (a << 4) & 0xFF0
    golden = bit.band(bit.lshift(a, 4), 0xFF0)
    assert(result == golden, "shift and mask failed")
    
    -- XOR swap pattern (doesn't actually swap due to same variable, but tests ops)
    local x = 42
    local y = 17
    local t = x ~ y
    assert(t == bit.bxor(x, y), "XOR in swap pattern failed")
    
    -- NOT and AND for masking
    result = a & (~b)
    golden = bit.band(a, bit.bnot(b))
    assert(result == golden, "NOT and AND failed")
    
    print("Combined operations tests passed!")
end

local function test_real_world_patterns()
    print("Testing real-world bit manipulation patterns...")
    
    -- Color extraction (RGBA)
    local color = 0x12345678
    local r = (color >> 24) & 0xFF
    local g = (color >> 16) & 0xFF
    local b = (color >> 8) & 0xFF
    local a = color & 0xFF
    
    local g_r = bit.band(bit.rshift(color, 24), 0xFF)
    local g_g = bit.band(bit.rshift(color, 16), 0xFF)
    local g_b = bit.band(bit.rshift(color, 8), 0xFF)
    local g_a = bit.band(color, 0xFF)
    
    assert(r == g_r and g == g_g and b == g_b and a == g_a, "color extraction failed")
    
    -- Color packing
    local packed = (r << 24) | (g << 16) | (b << 8) | a
    local g_packed = bit.bor(bit.bor(bit.bor(
        bit.lshift(r, 24),
        bit.lshift(g, 16)),
        bit.lshift(b, 8)),
        a)
    assert(packed == g_packed, "color packing failed")
    
    -- Checking if a bit is set
    local flags = 0x15  -- 0b10101
    local is_bit0_set = (flags & (1 << 0)) ~= 0
    local is_bit1_set = (flags & (1 << 1)) ~= 0
    local is_bit2_set = (flags & (1 << 2)) ~= 0
    
    assert(is_bit0_set == true, "bit 0 check failed")
    assert(is_bit1_set == false, "bit 1 check failed")
    assert(is_bit2_set == true, "bit 2 check failed")
    
    -- Setting and clearing bits
    local val = 0
    val = val | (1 << 5)  -- Set bit 5
    assert((val & (1 << 5)) ~= 0, "set bit failed")
    
    val = val & ~(1 << 5)  -- Clear bit 5
    assert((val & (1 << 5)) == 0, "clear bit failed")
    
    -- Toggle bit
    val = 0xFF
    val = val ~ (1 << 3)  -- Toggle bit 3
    local g_val = bit.bxor(0xFF, bit.lshift(1, 3))
    assert(val == g_val, "toggle bit failed")
    
    print("Real-world pattern tests passed!")
end

local function test_stress_jit()
    print("Testing JIT compilation stress test...")
    
    local function complex_loop()
        local result = 0
        for i = 1, 1000 do
            local a = i & 0xFF
            local b = (i >> 4) & 0x0F
            local c = ~i & 0xFF
            local d = a | b
            local e = d ~ c
            result = result + (e << 2) + (e >> 1)
        end
        return result
    end
    
    local function complex_loop_golden()
        local result = 0
        for i = 1, 1000 do
            local a = bit.band(i, 0xFF)
            local b = bit.band(bit.rshift(i, 4), 0x0F)
            local c = bit.band(bit.bnot(i), 0xFF)
            local d = bit.bor(a, b)
            local e = bit.bxor(d, c)
            result = result + bit.lshift(e, 2) + bit.rshift(e, 1)
        end
        return result
    end
    
    -- Run with JIT on
    jit.on()
    local result_jit = complex_loop()
    local golden_jit = complex_loop_golden()
    assert(result_jit == golden_jit, "JIT stress test failed: " .. result_jit .. " vs " .. golden_jit)
    
    -- Run with JIT off
    jit.off()
    local result_no_jit = complex_loop()
    local golden_no_jit = complex_loop_golden()
    assert(result_no_jit == golden_no_jit, "No-JIT stress test failed")
    
    -- Both should produce the same result
    assert(result_jit == result_no_jit, "JIT vs no-JIT mismatch in stress test")
    
    jit.on()
    print("JIT stress tests passed!")
end

local function test_edge_case_combinations()
    print("Testing edge case combinations...")
    
    -- Zero with all operators
    assert((0 & 0xFF) == bit.band(0, 0xFF), "0 & x failed")
    assert((0 | 0xFF) == bit.bor(0, 0xFF), "0 | x failed")
    assert((0 ~ 0xFF) == bit.bxor(0, 0xFF), "0 ~ x failed")
    assert((0 << 5) == bit.lshift(0, 5), "0 << x failed")
    assert((0 >> 5) == bit.rshift(0, 5), "0 >> x failed")
    
    -- All bits set with all operators
    local all_bits = -1
    assert((all_bits & 0xFF) == bit.band(all_bits, 0xFF), "-1 & x failed")
    assert((all_bits | 0x00) == bit.bor(all_bits, 0x00), "-1 | x failed")
    assert((all_bits ~ all_bits) == bit.bxor(all_bits, all_bits), "-1 ~ -1 failed")
    
    -- Chained operations
    local chain = 0xFF & 0x0F | 0xF0 ~ 0x55
    local g_chain = bit.bxor(bit.bor(bit.band(0xFF, 0x0F), 0xF0), 0x55)
    assert(chain == g_chain, "chained operations failed")
    
    print("Edge case combination tests passed!")
end

-- Run all tests
test_combined_operations()
test_real_world_patterns()
test_stress_jit()
test_edge_case_combinations()

print("All comprehensive tests passed!")
