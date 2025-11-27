--[=[
Test metatable support for Lua 5.3 bitwise operators
Tests __band, __bor, __bxor, __bnot, __shl, __shr metamethods
]=]

local bit = require("bit")

print("Testing bitwise operator metatables...")

-- Test __band (bitwise AND)
local function test_band_mt()
    print("Testing __band metamethod...")
    
    local obj1 = setmetatable({value = 15}, {
        __band = function(a, b)
            if type(b) == "number" then
                return a.value & b
            elseif type(a) == "number" then
                return a & b.value
            else
                return a.value & b.value
            end
        end
    })
    
    local result = obj1 & 7
    assert(result == (15 & 7), "__band with number failed")
    
    print("__band metamethod tests passed!")
end

-- Test __bor (bitwise OR)
local function test_bor_mt()
    print("Testing __bor metamethod...")
    
    local obj1 = setmetatable({value = 8}, {
        __bor = function(a, b)
            if type(b) == "number" then
                return a.value | b
            elseif type(a) == "number" then
                return a | b.value
            else
                return a.value | b.value
            end
        end
    })
    
    local result = obj1 | 7
    assert(result == (8 | 7), "__bor with number failed")
    
    print("__bor metamethod tests passed!")
end

-- Test __bxor (bitwise XOR)
local function test_bxor_mt()
    print("Testing __bxor metamethod...")
    
    local obj1 = setmetatable({value = 15}, {
        __bxor = function(a, b)
            if type(b) == "number" then
                return a.value ~ b
            elseif type(a) == "number" then
                return a ~ b.value
            else
                return a.value ~ b.value
            end
        end
    })
    
    local result = obj1 ~ 8
    assert(result == (15 ~ 8), "__bxor with number failed")
    
    print("__bxor metamethod tests passed!")
end

-- Test __bnot (bitwise NOT)
local function test_bnot_mt()
    print("Testing __bnot metamethod...")
    
    local obj1 = setmetatable({value = 5}, {
        __bnot = function(a)
            return ~a.value
        end
    })
    
    local result = ~obj1
    assert(result == ~5, "__bnot failed")
    
    print("__bnot metamethod tests passed!")
end

-- Test __shl (left shift)
local function test_shl_mt()
    print("Testing __shl metamethod...")
    
    local obj1 = setmetatable({value = 3}, {
        __shl = function(a, b)
            if type(b) == "number" then
                return a.value << b
            elseif type(a) == "number" then
                return a << b.value
            else
                return a.value << b.value
            end
        end
    })
    
    local result = obj1 << 2
    assert(result == (3 << 2), "__shl with number failed")
    
    print("__shl metamethod tests passed!")
end

-- Test __shr (right shift - logical)
local function test_shr_mt()
    print("Testing __shr metamethod...")
    
    local obj1 = setmetatable({value = 16}, {
        __shr = function(a, b)
            if type(b) == "number" then
                return a.value >> b
            elseif type(a) == "number" then
                return a >> b.value
            else
                return a.value >> b.value
            end
        end
    })
    
    local result = obj1 >> 2
    assert(result == (16 >> 2), "__shr with number failed")
    
    print("__shr metamethod tests passed!")
end

-- Test mixed metatables
local function test_mixed_mt()
    print("Testing mixed metatable operations...")
    
    local BitNum = {}
    BitNum.__index = BitNum
    
    function BitNum.new(value)
        return setmetatable({value = value}, BitNum)
    end
    
    function BitNum:__band(other)
        if getmetatable(other) == BitNum then
            return BitNum.new(self.value & other.value)
        else
            return BitNum.new(self.value & other)
        end
    end
    
    function BitNum:__bor(other)
        if getmetatable(other) == BitNum then
            return BitNum.new(self.value | other.value)
        else
            return BitNum.new(self.value | other)
        end
    end
    
    function BitNum:__bxor(other)
        if getmetatable(other) == BitNum then
            return BitNum.new(self.value ~ other.value)
        else
            return BitNum.new(self.value ~ other)
        end
    end
    
    function BitNum:__bnot()
        return BitNum.new(~self.value)
    end
    
    function BitNum:__shl(other)
        if getmetatable(other) == BitNum then
            return BitNum.new(self.value << other.value)
        else
            return BitNum.new(self.value << other)
        end
    end
    
    function BitNum:__shr(other)
        if getmetatable(other) == BitNum then
            return BitNum.new(self.value >> other.value)
        else
            return BitNum.new(self.value >> other)
        end
    end
    
    local a = BitNum.new(12)
    local b = BitNum.new(10)
    
    local result_and = a & b
    assert(result_and.value == (12 & 10), "BitNum AND failed")
    
    local result_or = a | b
    assert(result_or.value == (12 | 10), "BitNum OR failed")
    
    local result_xor = a ~ b
    assert(result_xor.value == (12 ~ 10), "BitNum XOR failed")
    
    local result_not = ~a
    assert(result_not.value == ~12, "BitNum NOT failed")
    
    local result_shl = a << 2
    assert(result_shl.value == (12 << 2), "BitNum SHL failed")
    
    local result_shr = a >> 2
    assert(result_shr.value == (12 >> 2), "BitNum SHR failed")
    
    print("Mixed metatable tests passed!")
end

-- Run all tests
test_band_mt()
test_bor_mt()
test_bxor_mt()
test_bnot_mt()
test_shl_mt()
test_shr_mt()
test_mixed_mt()

print("\nAll metatable tests passed!")
