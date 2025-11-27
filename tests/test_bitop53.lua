local bit = require("bit")
local ffi = require("ffi")

-- ============================================================================
-- Basic Arithmetic and Precedence Tests
-- ============================================================================
do
    -- Basic arithmetic and precedence checks
    assert(2 ^ 32 - 1 == 4294967295)
    assert(2ULL ^ 32 - 1 == 4294967295)
    assert(2ULL ^ 32ULL - 1 == 4294967295)
    assert(2 ^ 32ULL - 1 == 4294967295)
    
    assert(math.max(0 ,1) == 1)

    assert("39" ^ 3 == 59319)
    assert(-"39" == -39)
end

-- ============================================================================
-- Operator Precedence Tests (Lua 5.3 standard: & > ~ > |)
-- ============================================================================
do
    -- Verify correct precedence: & binds tighter than ~, ~ binds tighter than |
    -- a & b | c should be (a & b) | c
    assert((0xFF & 0x0F | 0x100) == ((0xFF & 0x0F) | 0x100))
    
    -- a | b & c should be a | (b & c)
    assert((0x100 | 0xFF & 0x0F) == (0x100 | (0xFF & 0x0F)))
    
    -- a ~ b & c should be a ~ (b & c) 
    assert((0xFF ~ 0x0F & 0x03) == (0xFF ~ (0x0F & 0x03)))
    
    -- a | b ~ c should be a | (b ~ c)
    assert((0x100 | 0xFF ~ 0x0F) == (0x100 | (0xFF ~ 0x0F)))
    
    -- Complex precedence chain
    local result = 0xFF & 0x0F | 0x100 ~ 0x55
    local expected = ((0xFF & 0x0F) | 0x100) ~ 0x55
    assert(result == expected, "complex precedence failed")
    
    -- Shift operators have higher precedence than bitwise
    assert((1 << 4 & 0xFF) == ((1 << 4) & 0xFF))
    assert((0x100 >> 4 | 0x0F) == ((0x100 >> 4) | 0x0F))
end

-- AND Operation (&)
do
    local aa = 3
    local bb = 2
    local a = 1 & 1
    local b = aa & bb
    local c = aa & 1
    local d = 1 & aa
    
    assert(a == bit.band(1, 1))
    assert((3 & 2) == bit.band(3, 2))
    assert((aa & bb) == bit.band(aa, bb))
    assert((aa & 1) == bit.band(aa, 1))
    assert((1 & aa) == bit.band(1, aa))

    assert((0xFF & 0xFF00) == bit.band(0xFF, 0xFF00))
    
    -- Testing 36-bit value truncation/masking behavior
    assert((0xFFFFFFFFF & 0xFF00) == bit.band(0xFFFFFFFFF, 0xFF00))
    assert((0xFFFFF00FF & 0xFF00) == bit.band(0xFFFFF00FF, 0xFF00))

    local a = 1ULL + 2
    local a = 1ULL & 2

    assert((1ULL & 2) == bit.band(1ULL, 2))
    assert((2ULL & 1) == bit.band(2ULL, 1))
    assert((1ULL & 1) == bit.band(1ULL, 1))
    assert((2ULL & 2) == bit.band(2ULL, 2))

    assert((2ULL & 3) == bit.band(2ULL, 3))
    
    -- 64-bit high-word masking
    assert((0xFFFFFFFFFFFFFFFFULL & 0xF000000000000000ULL) == bit.band(0xFFFFFFFFFFFFFFFFULL, 0xF000000000000000ULL))
    
    assert((1 & 2ULL) == bit.band(1, 2ULL))
    assert((1 & 3ULL) == bit.band(1, 3ULL))
    
    assert((0xFFFF & 0xFFFF000FULL) == bit.band(0xFFFF, 0xFFFF000FULL))

    -- Metatable __band test
    do
        local my_table = { value = 0 }
        local mt = {}
        mt.__band = function(a, b)
            print("hello from mt.__band")
            return { value = a.value & b.value }
        end
    
        setmetatable(my_table, mt)
    
        local t1 = { value = 5 }
        local t2 = { value = 3 }
        setmetatable(t1, mt)
        setmetatable(t2, mt)
    
        local result = t1 & t2
        assert(result.value == bit.band(5, 3))
    end
end

-- OR Operation (|)
do
    local a = 1
    local b = 2
    local c = a | b
    assert(c == bit.bor(a, b))
    assert((1 | 3) == bit.bor(1, 3))
    assert((0x0F | 0xF0) == bit.bor(0x0F, 0xF0))
    
    assert((1 | 3ULL) == bit.bor(1, 3ULL))
    assert((1ULL | 3) == bit.bor(1ULL, 3))
    assert((0xFULL | 0xFFFF) == bit.bor(0xFULL, 0xFFFF))
    assert((0xFULL | 0xF0ULL) == bit.bor(0xFULL, 0xF0ULL))

    -- Metatable __bor test
    do
        local my_table = { value = 0 }
        local mt = {}
        mt.__bor = function(a, b)
            print("hello from mt.__bor")
            return { value = a.value | b.value }
        end
    
        setmetatable(my_table, mt)
    
        local t1 = { value = 1 }
        local t2 = { value = 2 }
        setmetatable(t1, mt)
        setmetatable(t2, mt)
    
        local result = t1 | t2
        assert(result.value == bit.bor(1, 2))
    end
end

-- XOR Operation (~)
do
    local a = 5
    local b = 3
    local c = a ~ b
    assert(c == bit.bxor(a, b))
    assert((5 ~ 3) == bit.bxor(5, 3))
    assert((a ~ 3) == bit.bxor(a, 3))
    assert((5 ~ b) == bit.bxor(5, b))
    assert((a ~ b) == bit.bxor(a, b))

    assert((1ULL ~ 4) == bit.bxor(1ULL, 4))
    assert((1 ~ 4ULL) == bit.bxor(1, 4ULL))

    -- Metatable __bxor test
    do
        local my_table = { value = 0 }
        local mt = {}
        mt.__bxor = function(a, b)
            print("hello from mt.__bxor")
            return { value = a.value ~ b.value }
        end
    
        setmetatable(my_table, mt)
    
        local t1 = { value = 5 }
        local t2 = { value = 3 }
        setmetatable(t1, mt)
        setmetatable(t2, mt)
    
        local result = t1 ~ t2
        assert(result.value == bit.bxor(5, 3))
    end
end

-- Left Shift (<<)
do
    assert((1 << 2) == bit.lshift(1, 2))
    assert((1 << 30) == bit.lshift(1, 30))
    assert((1 << 30ULL) == bit.lshift(1, 30ULL))
    assert((1ULL << 30) == bit.lshift(1ULL, 30))
    assert((1ULL << 30ULL) == bit.lshift(1ULL, 30ULL))
    
    -- 64-bit shift verification using bit.lshift
    assert((1ULL << 63) == bit.lshift(1ULL, 63))
    assert((1ULL << 63ULL) == bit.lshift(1ULL, 63ULL))
    assert((1ULL << 64) == bit.lshift(1ULL, 64))
    assert((1ULL << 64ULL) == bit.lshift(1ULL, 64ULL))
    
    assert((0xFFULL << 2) == bit.lshift(0xFFULL, 2))

    -- Metatable __shl test
    do
        local my_table = { value = 0 }
        local mt = {}
        mt.__shl = function(a, b)
            print("hello from mt.__shl")
            return { value = a.value << b.value }
        end
    
        setmetatable(my_table, mt)
    
        local t1 = { value = 1 }
        local t2 = { value = 30 }
        setmetatable(t1, mt)
        setmetatable(t2, mt)
    
        local result = t1 << t2
        assert(result.value == bit.lshift(1, 30))
    end
end

-- Right Shift (>>)
do
    assert(4 >> 2 == bit.rshift(4, 2))
    assert(0x40000000 >> 30 == bit.rshift(0x40000000, 30))
    assert(0x40000000 >> 30ULL == bit.rshift(0x40000000, 30ULL))
    assert(0x40000000ULL >> 30 == bit.rshift(0x40000000ULL, 30))
    assert(0x40000000ULL >> 30ULL == bit.rshift(0x40000000ULL, 30ULL))
    
    -- 64-bit logical right shift
    assert((0x8000000000000000ULL >> 63) == bit.rshift(0x8000000000000000ULL, 63))
    assert((0x8000000000000000ULL >> 63ULL) == bit.rshift(0x8000000000000000ULL, 63ULL))
    
    assert((1ULL >> 1) == bit.rshift(1ULL, 1))
    assert((1ULL >> 1ULL) == bit.rshift(1ULL, 1ULL))
    assert((0x3fc >> 2) == bit.rshift(0x3fc, 2))

    -- Metatable __shr test
    do
        local my_table = { value = 0 }
        local mt = {}
        mt.__shr = function(a, b)
            print("hello from mt.__shr")
            return { value = a.value >> b.value }
        end

        setmetatable(my_table, mt)

        local t1 = { value = 0x40000000 }
        local t2 = { value = 30 }
        setmetatable(t1, mt)
        setmetatable(t2, mt)

        local result = t1 >> t2
        assert(result.value == bit.rshift(0x40000000, 30))
    end
end

-- Bitwise NOT (~)
do
    local a = 0x01
    local b = 1
    local c = 1ULL
    assert(~a == bit.bnot(a))
    assert(~b == bit.bnot(b))
    assert(~1 == bit.bnot(1))
    
    assert(~1ULL == bit.bnot(1ULL))
    assert(~c == bit.bnot(c))

    local d = 0x02
    local e = 2
    assert(~d == bit.bnot(d))
    assert(~e == bit.bnot(e))

    local f = 0x0F
    local g = 15
    assert(~f == bit.bnot(f))
    assert(~g == bit.bnot(g))

    local h = 0xFF
    local i = 255
    assert(~h == bit.bnot(h))
    assert(~i == bit.bnot(i))

    local zero = 0
    assert(~zero == bit.bnot(zero))

    local maxUnsignedLongLong = 0xFFFFFFFFFFFFFFFFULL
    assert(~maxUnsignedLongLong == bit.bnot(maxUnsignedLongLong))

    -- Metatable __bnot test
    do
        local my_table = { value = 0 }
        local mt = {}
        mt.__bnot = function(a)
            print("hello from mt.__bnot")
            return { value = ~a.value }
        end

        setmetatable(my_table, mt)

        local ret = ~my_table
        assert(ret.value == bit.bnot(0))
    end
end


-- Integer Division (//)
-- The bit library does not provide integer division, using math.floor as golden.
do
    assert(1 // 2 == math.floor(1/2))
    assert(1ULL // 2 == math.floor(1/2))
    assert(1 // 2ULL == math.floor(1/2))
    assert(1ULL // 2ULL == math.floor(1/2))
    assert(1ULL // 1ULL == math.floor(1/1))
    assert(1ULL // 1 == math.floor(1/1))
    assert(1 // 1ULL == math.floor(1/1))
    assert(1 // 1 == math.floor(1/1))
    assert(5 // 2 == math.floor(5/2))
    assert(5ULL // 2 == math.floor(5/2))

    local a = 5
    local b = 2
    assert(a // b == math.floor(5/2))
    assert(a // 2ULL == math.floor(5/2))
    assert(5ULL // b == math.floor(5/2))
    assert(5ULL // 2ULL == math.floor(5/2))
    
    -- Metatable __idiv test
    do
        local my_table = { value = 0 }
        local mt = {}
        mt.__idiv = function(a, b)
            print("hello from mt.__idiv")
            return { value = a.value // b.value }
        end

        local t1 = { value = 5 }
        local t2 = { value = 2 }
        setmetatable(t1, mt)
        setmetatable(t2, mt)
        local result = t1 // t2
        assert(result.value == math.floor(5/2))
    end
end


-- Benchmark / JIT loop testing
-- jit.off()
-- local dump = require "jit.dump"
-- dump.on(nil, "./dump.jit.out")

local test = function (times)
    for i = 1, times do
        local mod = i % 3
        local a = 1 << mod
        local b = 0xFF >> mod
        local c = 1ULL >> mod
        local d = c << 1ULL
        local e = a << b
    end
end

local s = os.clock()
test(10000 * 1000 * 100)
local e = os.clock()
print(e - s)

jit.off()
test(10)
jit.on()


-- JIT Loop Optimization Test Case 1
-- local dump = require "jit.dump"
-- dump.on(nil, "./dump.jit.out")
do
    local test = function ()
        local mask32 = 0x8
        local mask64 = 0x8ULL
        local v32 = 0x01
        local v64 = 0x01ULL
        for i = 1, 5 do
            if (mask32 & 0x01) ~= 0 then
                assert(false)
            end
            
            if (mask32 & 0x01ULL) ~= 0 then
                assert(false)
            end

            if (mask32 & (0 + 0x01ULL)) ~= 0 then
                assert(false)
            end

            if (mask64 & 0x01) ~= 0 then
                assert(false)
            end

            if (mask64 & 0x01ULL) ~= 0 then
                assert(false)
            end

            if (mask32 + 0x01ULL) == 0 then
                assert(false)
            end

            if (0x01ULL & mask32) ~= 0 then
                assert(false)
            end

            if (mask32 & 0x80) ~= 0 then
                assert(false)
            end

            if (mask32 & v32) ~= 0 then
                assert(false)
            end

            if (mask32 & v64) ~= 0 then
                assert(false)
            end

            if (mask64 & v32) ~= 0 then
                assert(false)
            end

            if (mask64 & v64) ~= 0 then
                assert(false)
            end
        end
    end

    jit.off()
    test()

    jit.on()
    jit.opt.start("hotloop=1")
    test()
end

-- JIT Loop Optimization Test Case 2
do
    jit.on()
    jit.opt.start("hotloop=1")

    local mask32 = 0x8
    local mask64 = 0x8ULL
    local v32 = 0x01
    local v64 = 0x01ULL
    for i = 1, 5 do
        if (mask32 & v32) ~= 0 then
            assert(false)
        end

        if (mask64 & v32) ~= 0 then
            assert(false)
        end
    end
end

-- JIT Loop Optimization Test Case 3: Negation and Bitwise NOT
do
    jit.opt.start("hotloop=1")
    -- local dump = require "jit.dump"
    -- dump.on(nil, "./dump.jit.out")

    local vv = 1LL
    local v = 0x0000000100000000ULL
    for i = 1, 5 do
        assert(-vv == -1)
        assert(-10 == -10)
        assert(~v == bit.bnot(v))
        assert(~(0x0000000100000000ULL) == bit.bnot(0x0000000100000000ULL))
    end
end

-- JIT Loop Optimization Test Case 4: Addition and Exponentiation
do
    jit.opt.start("hotloop=1")
    -- local dump = require "jit.dump"
    -- dump.on(nil, "./dump.jit.out")

    local x = 0ll
    local result = {16, 32, 48, 64, 80}
    for i=1,5 do 
        local xp = x
        local v = (-2LL) ^ 4
        x = xp + v
        assert(result[i] == x)
    end
end

-- ============================================================================
-- Signed vs Unsigned Integer Tests (LL vs ULL)
-- ============================================================================
do
    -- LL (signed) vs ULL (unsigned) behavior
    local signed = -1LL
    local unsigned = 0xFFFFFFFFFFFFFFFFULL
    
    -- Both should have the same bit pattern
    assert((signed & unsigned) == unsigned, "signed/unsigned AND failed")
    
    -- Right shift behavior
    -- ULL is logical shift (zero-fill)
    assert((0x8000000000000000ULL >> 1) == 0x4000000000000000ULL, "ULL logical shift failed")
    
    -- Mixing LL and ULL
    assert((1LL | 2ULL) == bit.bor(1LL, 2ULL), "LL | ULL failed")
    assert((1ULL | 2LL) == bit.bor(1ULL, 2LL), "ULL | LL failed")
    assert((0xFFLL & 0x0FULL) == bit.band(0xFFLL, 0x0FULL), "LL & LL failed")
end

-- ============================================================================
-- 64-bit Boundary Tests
-- ============================================================================
do
    local max64 = 0xFFFFFFFFFFFFFFFFULL
    local min64_signed = 0x8000000000000000LL
    local max64_signed = 0x7FFFFFFFFFFFFFFFLL
    
    -- Boundary operations
    assert((max64 & 1) == 1ULL, "max64 & 1 failed")
    assert((max64 | 0) == max64, "max64 | 0 failed")
    assert((max64 ~ max64) == 0ULL, "max64 ~ max64 failed")
    assert(~0ULL == max64, "~0ULL failed")
    
    -- Shift at boundaries
    assert((1ULL << 63) == 0x8000000000000000ULL, "1ULL << 63 failed")
    assert((0x8000000000000000ULL >> 63) == 1ULL, ">> 63 failed")
    
    -- 32-bit boundary crossing
    assert((0xFFFFFFFFULL << 1) == 0x1FFFFFFFEULL, "32-bit boundary shift failed")
    assert((0x100000000ULL >> 1) == 0x80000000ULL, "32-bit boundary rshift failed")
end

-- ============================================================================
-- Expression Complexity Tests
-- ============================================================================
do
    -- Deeply nested expressions
    local a, b, c, d = 0xFF, 0x0F, 0xF0, 0xAA
    
    local nested = ((a & b) | (c ~ d)) & ((a | b) ~ (c & d))
    local expected = bit.band(
        bit.bor(bit.band(a, b), bit.bxor(c, d)),
        bit.bxor(bit.bor(a, b), bit.band(c, d))
    )
    assert(nested == expected, "deeply nested expression failed")
    
    -- Chained shifts
    assert(((1 << 4) << 4) == (1 << 8), "chained left shift failed")
    assert(((256 >> 4) >> 4) == 1, "chained right shift failed")
    
    -- Mixed operations
    local x = 0x12345678
    local rotl_sim = ((x << 8) | (x >> 24)) & 0xFFFFFFFF
    assert(rotl_sim == bit.rol(x, 8), "simulated rotate left failed")
end

-- ============================================================================
-- Variable Type Combinations
-- ============================================================================
do
    -- number, cdata, and their combinations
    local num = 255
    local ull = 255ULL
    local ll = 255LL
    
    -- All combinations should work
    assert((num & num) == (ull & ull), "num & num != ull & ull")
    assert((num | ull) == (ull | num), "commutativity failed for |")
    assert((num ~ ll) == (ll ~ num), "commutativity failed for ~")
    
    -- Type promotion rules
    local r1 = num & ull  -- should promote to cdata
    local r2 = ull & num  -- should also be cdata
    assert(type(r1) == "cdata", "type promotion failed")
    assert(r1 == r2, "type promotion asymmetric")
end

-- ============================================================================
-- Bit Pattern Tests
-- ============================================================================
do
    -- Power of 2 detection
    local function is_power_of_2(n)
        return n > 0 and (n & (n - 1)) == 0
    end
    
    assert(is_power_of_2(1), "1 is power of 2")
    assert(is_power_of_2(2), "2 is power of 2")
    assert(is_power_of_2(4), "4 is power of 2")
    assert(is_power_of_2(1024), "1024 is power of 2")
    assert(not is_power_of_2(0), "0 is not power of 2")
    assert(not is_power_of_2(3), "3 is not power of 2")
    assert(not is_power_of_2(6), "6 is not power of 2")
    
    -- Lowest set bit
    local function lowest_set_bit(n)
        return n & (-n)
    end
    
    assert(lowest_set_bit(12) == 4, "lowest bit of 12 is 4")
    assert(lowest_set_bit(8) == 8, "lowest bit of 8 is 8")
    assert(lowest_set_bit(7) == 1, "lowest bit of 7 is 1")
    
    -- Clear lowest set bit
    local function clear_lowest_bit(n)
        return n & (n - 1)
    end
    
    assert(clear_lowest_bit(12) == 8, "clear lowest of 12")
    assert(clear_lowest_bit(8) == 0, "clear lowest of 8")
    assert(clear_lowest_bit(15) == 14, "clear lowest of 15")
end

-- ============================================================================
-- JIT Trace with Mixed Types
-- ============================================================================
do
    jit.on()
    jit.opt.start("hotloop=1")
    
    local function mixed_type_loop(n)
        local sum = 0ULL
        local mask = 0xFFULL
        for i = 1, n do
            local num_val = i
            local ull_val = i * 1ULL
            sum = sum + (num_val & mask) + (ull_val & mask)
        end
        return sum
    end
    
    -- First run in interpreter
    jit.off()
    local result1 = mixed_type_loop(10)
    
    -- Then run with JIT
    jit.on()
    local result2 = mixed_type_loop(100)
    
    -- Verify JIT result matches expected
    local expected = 0ULL
    for i = 1, 100 do
        expected = expected + (i & 0xFF) + (i & 0xFF)
    end
    assert(result2 == expected, "JIT mixed type loop failed")
end

-- ============================================================================
-- Edge Cases for Each Operator
-- ============================================================================
do
    -- Zero operand
    assert((0 & 0xFF) == 0, "0 & any = 0")
    assert((0 | 0xFF) == 0xFF, "0 | any = any")
    assert((0 ~ 0xFF) == 0xFF, "0 ~ any = any")
    assert((~0) == -1, "~0 = -1")
    assert((0 << 10) == 0, "0 << n = 0")
    assert((0 >> 10) == 0, "0 >> n = 0")
    
    -- Identity operations
    assert((0xFF & 0xFF) == 0xFF, "a & a = a")
    assert((0xFF | 0xFF) == 0xFF, "a | a = a")
    assert((0xFF ~ 0xFF) == 0, "a ~ a = 0")
    assert((0xFF << 0) == 0xFF, "a << 0 = a")
    assert((0xFF >> 0) == 0xFF, "a >> 0 = a")
    
    -- All ones (32-bit context) - note: bitwise ops convert to signed 32-bit
    local all_ones = -1  -- Use -1 which is all bits set in two's complement
    assert((all_ones & 0) == 0, "-1 & 0 = 0")
    assert((all_ones | 0) == -1, "-1 | 0 = -1")
    assert((all_ones ~ all_ones) == 0, "-1 ~ -1 = 0")
    assert((all_ones ~ 0) == -1, "-1 ~ 0 = -1")
end

-- ============================================================================
-- Arithmetic Right Shift (via bit.arshift comparison)
-- ============================================================================
do
    -- Note: >> is logical right shift in Lua 5.3
    -- bit.arshift is arithmetic right shift
    
    -- For positive numbers, both should be the same
    assert((8 >> 1) == bit.arshift(8, 1), "positive arshift")
    assert((256 >> 4) == bit.arshift(256, 4), "positive arshift 2")
    
    -- For negative 32-bit patterns, they differ
    local neg = 0x80000000  -- highest bit set (negative in signed 32-bit)
    local logical_shift = neg >> 1
    local arith_shift = bit.arshift(neg, 1)
    -- Logical: 0x40000000, Arithmetic: 0xC0000000
    assert(logical_shift ~= arith_shift, "logical != arithmetic for negative")
end

-- ============================================================================
-- Bit Rotation Simulation
-- ============================================================================
do
    local function rotl32(x, n)
        n = n % 32
        return ((x << n) | (x >> (32 - n))) & 0xFFFFFFFF
    end
    
    local function rotr32(x, n)
        n = n % 32
        return ((x >> n) | (x << (32 - n))) & 0xFFFFFFFF
    end
    
    local val = 0x12345678
    
    -- Compare with bit library
    assert(rotl32(val, 4) == bit.rol(val, 4), "rotl32 failed")
    assert(rotr32(val, 4) == bit.ror(val, 4), "rotr32 failed")
    
    -- Full rotation should return original
    assert(rotl32(val, 32) == val, "rotl32 by 32 failed")
    assert(rotr32(val, 32) == val, "rotr32 by 32 failed")
end

-- ============================================================================
-- Stress Test: Rapid Operation Sequence
-- ============================================================================
do
    jit.on()
    jit.opt.start("hotloop=1")
    
    local x = 0x12345678
    for i = 1, 100 do
        x = (x & 0xFFFFFF00) | (i & 0xFF)
        x = x ~ (i << 8)
        x = (x << 1) | (x >> 31)
        x = x & 0xFFFFFFFF
    end
    
    -- Just verify it completes without error
    assert(type(x) == "number", "stress test type check")
end

print("Finish")