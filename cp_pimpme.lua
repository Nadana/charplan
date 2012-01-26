--[[
    CharPlan - PimpMe

    Pimp item dialog
    based on ideas of ItemForge and ItemPreview

    So special thanks to:
    - Valacar (Hash calculation)
    - ZhurRunes (ItemForge)
    - Alleris (ItemPreview)
]]

--[[
Item data = {
    -- icon,quality
    name
    color
    id
    bind
    bind_flag
    plus
    rarity    -- == color??
    tier
    dura
    max_dura  -- not always valid!
    stats[6]
    rune_slots
    runes[4]
    unk1      -- unknown itemlink data
}
]]


local CP = _G.CP
local Pimp = {}
CP.Pimp = Pimp

local Nyx = LibStub("Nyx")


function Pimp.PimpItemLink(itemlink)

    local item_data = Pimp.ExtractLink(itemlink)
    item_data.icon = CP.DB.GetItemIcon(item_data.id)

    -- TODO: remove (test data)
    Pimp.data = item_data
    local test = Pimp.GenerateLink(item_data)
    if itemlink~=test then
        DEFAULT_CHAT_FRAME:AddMessage("LINK MISSMATCH:",1,0,0)
        DEFAULT_CHAT_FRAME:AddMessage(string.gsub(itemlink,"|",";"),1,0,0)
        DEFAULT_CHAT_FRAME:AddMessage(string.gsub(test,"|",";"),1,0,0)
        assert(false)
    end
    -- end of test

    Pimp.PimpItem(item_data)

    Pimp.SetHyperLink(itemlink)
end


function Pimp.SetHyperLink(itemlink)

    CPPimpMeToolTip:SetHyperLink( itemlink )
    GameTooltip:Hide()
    GameTooltip1:Hide()
    GameTooltip2:Hide()

    -- scale tooltip
    local lines=1
    for i = 1, 60 do
		textL = getglobal("CPPimpMeToolTipTextLeft" .. i);
		textR = getglobal("CPPimpMeToolTipTextRight" .. i);

        if textL:IsVisible() or textR:IsVisible() then
            lines=i
        end
    end

    CPPimpMeToolTip:SetScale(1)
    if lines>28 then
        CPPimpMeToolTip:SetScale(28/lines)
    end
end


function Pimp.PimpItem(item_data)
    Pimp.data = item_data
    Pimp.data_backup = table.copy(item_data)

    Pimp.FillFields()
    CPPimpMe:Show()
end


function Pimp.FillFields()
    local data = Pimp.data

    SetItemButtonTexture(CPPimpMeItem, data.icon)

    UIDropDownMenu_SetSelectedValue(CPPimpMeAttrPlus, data.plus)
    CPPimpMeAttrPlusText:SetText("+"..tostring(data.plus))
    UIDropDownMenu_SetSelectedValue(CPPimpMeAttrTier, data.tier)
    CPPimpMeAttrTierText:SetText(data.tier)

    Pimp.OnStatCtrlSetValue(CPPimpMeAttrStat1, data.stats[1])
    Pimp.OnStatCtrlSetValue(CPPimpMeAttrStat2, data.stats[2])
    Pimp.OnStatCtrlSetValue(CPPimpMeAttrStat3, data.stats[3])
    Pimp.OnStatCtrlSetValue(CPPimpMeAttrStat4, data.stats[4])
    Pimp.OnStatCtrlSetValue(CPPimpMeAttrStat5, data.stats[5])
    Pimp.OnStatCtrlSetValue(CPPimpMeAttrStat6, data.stats[6])

    Pimp.OnStatCtrlSetValue(CPPimpMeAttrRune1, data.runes[1])
    Pimp.OnStatCtrlSetValue(CPPimpMeAttrRune2, data.runes[2])
    Pimp.OnStatCtrlSetValue(CPPimpMeAttrRune3, data.runes[3])
    Pimp.OnStatCtrlSetValue(CPPimpMeAttrRune4, data.runes[4])


    Pimp.UpdateInfo()
end

function Pimp.UpdateInfo()
    Pimp.SetHyperLink( Pimp.GenerateLink(Pimp.data) )
    CP.PimpUpdate()
end

function Pimp.StatName(id)
    if id>0 then
        local sname = string.format("Sys%06i_name",id)
        return string.format("%i - %s",id,TEXT(sname))
    else
        return ""
    end
end


function Pimp.OnShow(this)
    this:ResetFrameOrder()

    CPPimpMeAttrDuraLabel:SetText(CP.L.PIMP_DURA)
end

function Pimp.OnHide(this)
    Pimp.data = nil
    Pimp.data_backup = nil
    CP.PimpFinished()
end

function Pimp.OnOK(this)
    CPPimpMe:Hide()
end

function Pimp.OnCancel(this)
    if Pimp.data_backup then
        table.copy(Pimp.data, Pimp.data_backup)
    end
    CPPimpMe:Hide()
end




function Pimp.OnCtrlLoad(this)

    local name = string.sub(this:GetName(), string.len("CPPimpMeAttr")+1)

    UIDropDownMenu_SetWidth(this, 60)
    UIDropDownMenu_Initialize(this, Pimp["OnCtrlShow_"..name])
    this.attribute = name

    if name=="Plus" then
        _G[this:GetName().."Label"]:SetText(CP.L.PIMP_PLUS)
    else
        _G[this:GetName().."Label"]:SetText(CP.L.PIMP_TIER)
    end
end

function Pimp.OnCtrlShow_Plus(button)
    local info={}
    for i=0,16 do
        info.text = "+"..i
        info.value = i
        info.notCheckable=1
        info.func = Pimp.OnCtrlClicked_Plus
        UIDropDownMenu_AddButton(info)
    end
end

function Pimp.OnCtrlClicked_Plus(button)
    UIDropDownMenu_SetSelectedValue(CPPimpMeAttrPlus, button.value)
    Pimp.data.plus = button.value
    Pimp.UpdateInfo()
end

function Pimp.OnCtrlShow_Tier(button)
    local info={}
    for i=0,10 do
        info.text = i
        info.value = i
        info.notCheckable=1
        info.func = Pimp.OnCtrlClicked_Tier
        UIDropDownMenu_AddButton(info)
    end
end

function Pimp.OnCtrlClicked_Tier(button)
    UIDropDownMenu_SetSelectedValue(CPPimpMeAttrTier, button.value)
    Pimp.data.tier = button.value
    Pimp.UpdateInfo()
end


function Pimp.OnStatCtrlLoad(this)
    local id = this:GetID()
    if id<7 then
        _G[this:GetName().."Label"]:SetText( string.format(CP.L.PIMP_STAT,id))
    else
        _G[this:GetName().."Label"]:SetText( string.format(CP.L.PIMP_RUNE,id-6))
    end

    UIDropDownMenu_SetWidth(_G[this:GetName().."Tier"], 30)
end

function Pimp.OnStatCtrlSetValue(button, id)
    local namebtn = _G[button:GetName().."Name"]
    local tierbtn = _G[button:GetName().."Tier"]
    if id>0 then
        namebtn:SetText(TEXT(string.format("Sys%06i_name",id)))
    else
        namebtn:SetText("")
    end

end

function Pimp.OnStatSelSearch(this)
    CPStatSearch:ClearAllAnchors()
    CPStatSearch:SetAnchor("TOPLEFT", "TOPLEFT", this, 16, 16 )
    CPStatSearch:Show()
end

-----------------------------------
-- Item Link
function Pimp.GenerateLink(item_data)

    local free_slots = item_data.rune_slots
            - ( item_data.runes[1]~=0 and 1 or 0)
            - ( item_data.runes[2]~=0 and 1 or 0)
            - ( item_data.runes[3]~=0 and 1 or 0)
            - ( item_data.runes[4]~=0 and 1 or 0)


    local temphex= string.format("%x%02x%02x%02x",
        item_data.unk1,
        item_data.plus + 32*free_slots,
        (item_data.tier+10) + 32*item_data.rarity,
        item_data.max_dura)

    local function s(a,b)
        if a>0 then a=a-0x70000 end
        if b>0 then b=b-0x70000 end
        return a + (2^16)*b
    end

    local data=
    {
        item_data.id,
        item_data.bind,
        tonumber(temphex,16),
        s(item_data.stats[1],item_data.stats[2]),
        s(item_data.stats[3],item_data.stats[4]),
        s(item_data.stats[5],item_data.stats[6]),
        item_data.runes[1],
        item_data.runes[2],
        item_data.runes[3],
        item_data.runes[4],
        item_data.dura
    }

    data[12] = Pimp.CalculateItemLinkHash(data)

    local link = string.format("|Hitem:%x %x %x %x %x %x %x %x %x %x %x %x|h|c%s[%s]|r|h",
        data[1], data[2], data[3], data[4],data[5], data[6], data[7], data[8],data[9], data[10], data[11], data[12],
        item_data.color,
        item_data.name
        )

    return link
end



-- TEMP HELPER
local function testflag(set, flag)
  return set % (2*flag) >= flag
end

local function setflag(set, flag)
  if set % (2*flag) >= flag then
    return set
  end
  return set + flag
end

local function clearflag(set, flag)
  if set % (2*flag) >= flag then
    return set - flag
  end
  return set
end


-- END TEMP HELPER


function Pimp.ExtractLink(itemlink)

    local data_str, color, name = string.match(itemlink, "|Hitem:([%x ]+)|h|c(%x%x%x%x%x%x%x%x)%[(.-)%]|r|h")
    assert(name and data_str, "not a valid Item link")

    local data = Nyx.Split(data_str, " ", 14)

    local item_data = {}
    item_data.name = name
    item_data.color = color

    item_data.id =  tonumber(data[1], 16)
    item_data.bind = tonumber( string.sub(data[2],-2,-1) , 16)
    item_data.bind_flag = tonumber( string.sub(data[2],-4,-3) , 16) or 0

    item_data.unk1 = tonumber( string.sub(data[3],-8,-7) , 16) or 0
    item_data.max_dura = tonumber( string.sub(data[3],-2,-1), 16)
    item_data.dura = tonumber( data[11], 16)

    local runesPlus = tonumber( string.sub(data[3],-6,-5) , 16) or 0
    local tier_rar = tonumber( string.sub(data[3],-4,-3), 16) or 0
    local free_slots = math.floor(runesPlus / 32)

    item_data.plus = runesPlus % 32
    item_data.rarity = math.floor(tier_rar / 32)
    item_data.tier = (tier_rar % 32 )-10


    local function s(txt)
        local n = tonumber(txt,16) or 0
        if n>0 then n = n + 0x70000 end
        return n
    end

    item_data.stats={
            s( string.sub(data[4],-4,-1)), s( string.sub(data[4],-8,-5)),
            s( string.sub(data[5],-4,-1)), s( string.sub(data[5],-8,-5)),
            s( string.sub(data[6],-4,-1)), s( string.sub(data[6],-8,-5)) }

    item_data.runes={
            tonumber( data[ 7], 16) or 0,
            tonumber( data[ 8], 16) or 0,
            tonumber( data[ 9], 16) or 0,
            tonumber( data[10], 16) or 0 }

    item_data.rune_slots = free_slots
            + ( item_data.runes[1]~=0 and 1 or 0)
            + ( item_data.runes[2]~=0 and 1 or 0)
            + ( item_data.runes[3]~=0 and 1 or 0)
            + ( item_data.runes[4]~=0 and 1 or 0)

    return item_data
end



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
function Pimp.CalculateItemLinkHash(num)

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