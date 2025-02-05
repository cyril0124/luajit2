do
    assert(2 ^ 32 - 1 == 4294967295)
    assert(2ULL ^ 32 - 1 == 4294967295)
    assert(2ULL ^ 32ULL - 1 == 4294967295)
    assert(2 ^ 32ULL - 1 == 4294967295)
    assert(math.max(0 ,1) == 1)

    assert("39" ^ 3 == 59319)
    assert(-"39" == -39)
end

do
    local aa = 3
    local bb = 2
    local a = 1 & 1
    local b = aa & bb
    local c = aa & 1
    local d = 1 & aa
    assert(a == 1)
    assert(3 & 2 == 2)
    assert(aa & bb == 2)
    assert(aa & 1 == 1)
    assert(1 & aa == 1)

    assert(0xFF & 0xFF00 == 0)
    assert(0xFFFFFFFFF & 0xFF00 == 0xFF00)
    assert(0xFFFFF00FF & 0xFF00 == 0x00)

    local a = 1ULL + 2
    local a = 1ULL & 2

    assert(1ULL & 2 == 0)
    assert(2ULL & 1 == 0)
    assert(1ULL & 1 == 1)
    assert(2ULL & 2 == 2)

    assert(2ULL & 3 == 2ULL)
    assert(0xFFFFFFFFFFFFFFFFULL & 0xF000000000000000ULL == 0xF000000000000000ULL)
    assert(1 & 2ULL == 0)
    assert(1 & 3ULL == 1)
    assert(0xFFFF & 0xFFFF000FULL == 0xF)

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
        assert(result.value == 1)
    end
end

do
    local a = 1
    local b = 2
    local c = a | b
    assert(c == 3)
    assert(1 | 3 == 3)
    assert(0x0F | 0xF0 == 0xFF)
    assert(1 | 3ULL == 3)

    assert(1ULL | 3 == 3)
    assert(0xFULL | 0xFFFF == 0xFFFF)
    assert(0xFULL | 0xF0ULL == 0xFFULL)

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
        assert(result.value == 3)
    end
end

do
    local a = 5
    local b = 3
    local c = a ~ b
    assert(c == 6)
    assert(5 ~ 3 == 6)
    assert(a ~ 3 == 6)
    assert(5 ~ b == 6)
    assert(a ~ b == 6)

    assert(1ULL ~ 4 == 5)
    assert(1 ~ 4ULL == 5)

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
        assert(result.value == 6)
    end
end

do
    assert(1 << 2 == 4)
    assert((1 << 30) == 0x40000000)
    assert((1 << 30ULL) == 0x40000000)
    assert((1ULL << 30) == 0x40000000)
    assert((1ULL << 30ULL) == 0x40000000)
    assert((1ULL << 63) == 0x8000000000000000ULL)
    assert((1ULL << 63ULL) == 0x8000000000000000ULL)
    assert((1ULL << 64) == 1ULL)
    assert((1ULL << 64ULL) == 1ULL)
    assert((0xFFULL << 2) == 0x3fc)

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
        assert(result.value == 0x40000000)
    end
end

do
    assert(4 >> 2 == 1)
    assert(0x40000000 >> 30 == 1)
    assert(0x40000000 >> 30ULL == 1)
    assert(0x40000000ULL >> 30 == 1)
    assert(0x40000000ULL >> 30ULL == 1)
    assert(0x8000000000000000ULL >> 63 == 1)
    assert(0x8000000000000000ULL >> 63ULL == 1)
    assert(1ULL >> 1 == 0)
    assert(1ULL >> 1ULL == 0)
    assert(0x3fc >> 2 == 0xFF)

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
        assert(result.value == 1)
    end
end

do
    local a = 0x01
    local b = 1
    local c = 1ULL
    assert(~a == -2)
    assert(~b == -2)
    assert(~1 == -2)
    assert(~1ULL == 0xFFFFFFFFFFFFFFFEULL)
    assert(~c == 0xFFFFFFFFFFFFFFFEULL)

    local d = 0x02
    local e = 2
    assert(~d == -3)
    assert(~e == -3)

    local f = 0x0F
    local g = 15
    assert(~f == -16)
    assert(~g == -16)

    local h = 0xFF
    local i = 255
    assert(~h == -256)
    assert(~i == -256)

    local zero = 0
    assert(~zero == -1)

    local maxUnsignedLongLong = 0xFFFFFFFFFFFFFFFFULL
    assert(~maxUnsignedLongLong == 0ULL)

    do
        local my_table = { value = 0 }
        local mt = {}
        mt.__bnot = function(a)
            print("hello from mt.__bnot")
            return { value = ~a.value }
        end

        setmetatable(my_table, mt)

        local ret = ~my_table
        assert(ret.value == -1)
    end
end


do
    assert(1 // 2 == 0)
    assert(1ULL // 2 == 0)
    assert(1 // 2ULL == 0)
    assert(1ULL // 2ULL == 0)
    assert(1ULL // 1ULL == 1)
    assert(1ULL // 1 == 1)
    assert(1 // 1ULL == 1)
    assert(1 // 1 == 1)
    assert(5 // 2 == 2)
    assert(5ULL // 2 == 2)

    local a = 5
    local b = 2
    assert(a // b == 2)
    assert(a // 2ULL == 2)
    assert(5ULL // b == 2)
    assert(5ULL // 2ULL == 2)
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
        assert(result.value == 2)
    end
end


-- jit.off()
-- local dump = require "jit.dump"
-- dump.on(nil, "./dump.jit.out")

local test = function (times)
    for i = 1, times do
        local a = 1 << i % 3
        local b = 0xFF >> i % 3
        local c = 1ULL >> i % 3
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

do
    jit.opt.start("hotloop=1")
    -- local dump = require "jit.dump"
    -- dump.on(nil, "./dump.jit.out")

    local vv = 1LL
    local v = 0x0000000100000000ULL
    for i = 1, 5 do
        assert(-vv == -1)
        assert(-10 == -10)
        assert(~v == 0xfffffffeffffffffULL)
        assert(~(0x0000000100000000ULL) == 0xfffffffeffffffffULL)
    end
end

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

print("Finish")
