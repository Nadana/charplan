--[[
    CharPlan

    Utility funcitons
]]

local Utils = {}
local CP = _G.CP
CP.Utils = Utils


function Utils.TableCopy(src,dst)
    local res = dst or {}
    for i in pairs(res) do res[i]=nil end

    for i,v in pairs(src) do
        if type(v)=="table" then
            res[i]=Utils.TableCopy(v)
        else
            res[i]=v
        end
    end
    return res
end


function Utils.ToRoman(num)
    local letters={"M","CM","D","CD","C","XC","L","XL","X", "IX", "V", "IV", "I"}
    local numbers={1000,900,500,400,100,90,50,40,10,9,5,4,1}

    local result=""
    for i,val in ipairs(numbers) do
        while num >= val do
            num = num-val
            result = result .. letters[i]
        end
    end
    return result
end


function Utils.RomanToNum( roman )
    local Num = { ["M"] = 1000, ["D"] = 500, ["C"] = 100, ["L"] = 50, ["X"] = 10, ["V"] = 5, ["I"] = 1 }
    local numeral = 0

    local i = 1
    local strlen = string.len(roman)
    while i < strlen do
        local z1, z2 = Num[ string.sub(roman,i,i) ], Num[ string.sub(roman,i+1,i+1) ]
        if z1 < z2 then
            numeral = numeral + ( z2 - z1 )
            i = i + 2
        else
            numeral = numeral + z1
            i = i + 1
        end
    end

    if i <= strlen then numeral = numeral + Num[ string.sub(roman,i,i) ] end

    return numeral
end


--[[ [ Runes of Magic item link hash calculation code ]]
--//////////////////////////////////////////////////////////////////
-- Runes of Magic item link hash calculation code

-- Author: Valacar (aka Duppy of the Runes of Magic US Osha server)
-- Release Date: September 12th, 2010

-- Credit goes to Neil Richardson for the xor, lshift, and rshift function
-- which I slightly modified. The original code can be found at:
-- http://luamemcached.googlecode.com/svn/trunk/CRC32.lua

-- I could care less what anyone does with the code (i.e. it's public domain),
-- but I'd very much appreciate being given credit (to me Valacar) if you do
-- use the code in any way.


-- Exclusive OR
local function xor(a, b)
    local calc = 0
    for i = 32, 0, -1 do
        local val = 2 ^ i
        local aa = false
        local bb = false
        if a == 0 then
            calc = calc + b
            break
        end
        if b == 0 then
            calc = calc + a
            break
        end
        if a >= val then
            aa = true
            a = a - val
        end
        if b >= val then
            bb = true
            b = b - val
        end
        if not (aa and bb) and (aa or bb) then
             calc = calc + val
        end
    end
     return calc
end

-- binary shift left
local function lshift(num, left)
     local res = num * (2 ^ left)
     return res % (2 ^ 32)
end

-- binary shift right
local function rshift(num, right)
    right = right % 0x20
    local res = num / (2 ^ right)
    return math.floor(res)
end

-- get lower word of a 32-bit number
local function loword(num)
    return rshift(lshift(num, 16), 16)
end

-- get high word of a 32-bit number
local function hiword(num)
    return rshift(num, 16) % 2^16
end

-- multiply two 32-bit numbers, but returns only the low dword of the 64-bit result
local function mymul(num1, num2)
    local x = loword(num2) * num1
    local y = (hiword(num2) * num1) * 2^16
    local a = hiword(x) + hiword(y)
    local b = loword(x)

    return (a * 2^16) + b
end


--//////////////////////////////////////////////////////////////////
-- Calculates hash value of an item based on first 11 hex numbers of an item link
function Utils.CalculateItemLinkHash(num)

    assert(#num == 11, "11 values required!")

    local sum = 0
    for s = 1, 11 do
        sum = sum + num[s]
    end

    local a,b,c,d,e,x,i = sum,0,0,0,0,0,0

    repeat
        d = num[x+1]
        b = d
        b = b * x
        b = b % 2^32
        e = d
        e = rshift(e, i)
        i = i + 0x10
        x = x + 1
        e = e + a
        e = e % 2^32
        b = b + e
        b = b % 2^32
        b = xor(b, d)
        a = b
    until (i >= 0xB0)

    local j = 0

    repeat
        d = num[j+1]
        c = d + 1
        c = mymul(c, a)
        c = c % 2^32
        a = d
        a = mymul(a, c)
        a = a % 2^32
        a = rshift(a, 16)
        a = a + c
        j = j + 1
        a = xor(a, d)
    until (j >= 0x0B)

    hash = loword(a)

    return hash
end
--[[ ] Runes of Magic item link hash calculation code ]]