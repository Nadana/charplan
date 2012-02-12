--[[
    CharPlan - DB

    Item Database
]]


local DB = {}
local CP = _G.CP
CP.DB = DB


--[[ [ DataBase Format ]]
    -- Items
    local I_SLOT=1
    local I_TYPE=2
    local I_LEVEL=3
    local I_ICON=4
    local I_REFINE=5
    local I_DURA=6
    local I_EFFECT_TYPE=7 -- optional
    local I_EFFECT_VAL=8 -- optional
    local I_STATS=9 -- optional
    local I_SET=10 -- optional

    -- Bonus
    local B_EFFECT_TYPE=1 -- optional
    local B_EFFECT_VAL=2 -- optional
    local B_GROUP=3  -- optional

    -- Spells
    local S_EFFECT_TYPE=1 -- optional
    local S_EFFECT_VAL=2 -- optional
--[[ ] ]]


local function LoadTable(fname)
    local fn, err = loadfile("interface/addons/charplan/item_data/"..fname..".lua")
    assert(fn,err)
    return fn()
end

function DB.Load()

    if DB.LoadCount then
        DB.LoadCount = DB.LoadCount +1
        return
    end
    DB.LoadCount = 1

    DB.images = LoadTable("images")
    DB.items = LoadTable("items")
    DB.bonus = LoadTable("addpower")
    DB.refines = LoadTable("refines")
    DB.cards = LoadTable("cards")
    DB.skills = LoadTable("skills")
    DB.spells = LoadTable("spells")
end

function DB.Release()
    DB.LoadCount = DB.LoadCount-1

    if DB.LoadCount ==0 then
        --collectgarbage("collect")
        --local mem1 = collectgarbage("count")
            DB.LoadCount = nil
            DB.images = nil
            DB.items = nil
            DB.bonus = nil
            DB.refines = nil
            DB.cards = nil
            DB.skills = nil
            DB.spells = nil
        collectgarbage("collect")
        --local mem2 = collectgarbage("count")
        --CP.Debug("DB Released. Freed memory: "..(math.floor(mem1-mem2)/1000).."mb")
    end
end


function DB.GetCardEffect(card_id)
    local boni_id = DB.cards[card_id]
    if boni_id then
        return DB.GetBonusEffect(boni_id)
    end
end

function DB.GetSkillEffect(skill_id)

    local efftype,effvalue={},{}
    local skills = DB.skills[skill_id]
    for _,spell_id in ipairs(skills or {}) do
        local boni = DB.spells[spell_id]
        if boni then
            for i,ef in pairs(boni[S_EFFECT_TYPE]) do
                table.insert(efftype,ef)
                table.insert(effvalue,boni[S_EFFECT_VAL][i])
            end
        end
    end

    return efftype,effvalue
end

function DB.GetItemEffect(item_id)
    local item = DB.items[item_id]
    if item then
        return item[I_EFFECT_TYPE], item[I_EFFECT_VAL]
    else
        CP.Debug("Item not in DB: "..item_id)
    end
end

function DB.GetItemUsualDropEffects(item_id)
    local item = DB.items[item_id]
    if item then
        if item[I_STATS] then
            local all_effects={}
            local all_values={}
            for _,stats in ipairs(item[I_STATS]) do
                local ea,ev = DB.GetBonusEffect(stats)
                for i,effect in ipairs(ea or {}) do
                    table.insert(all_effects,effect)
                    table.insert(all_values,ev[i])
                end
            end
            return all_effects, all_values
        end
    else
        CP.Debug("Item not in DB: "..item_id)
    end
end

function DB.GetBonusEffect(boni_id)
    if DB.bonus[boni_id] then
        return DB.bonus[boni_id][B_EFFECT_TYPE], DB.bonus[boni_id][B_EFFECT_VAL]
    else
        CP.Debug("Bonus not in DB: "..boni_id)
    end
end

function DB.GetPlusEffect(item_id, plus)
    assert(plus>=0 and plus<21)

    if plus==0 then return {},{},0 end

    local item = DB.items[item_id]
    if item then
        local eff = DB.refines[item[I_REFINE]+plus-1]
        if eff then
            return eff[1], eff[2], eff[3]
        else
            CP.Debug(string.format("Plus table not defined: %i+%i item:%i",item[I_REFINE],plus,item_id))
        end
    else
        CP.Debug("Item not in DB: "..item_id)
    end
end

function DB.GetItemIcon(item_id)
    local item = DB.items[item_id]
    if item then
        local icon = DB.images[ item[I_ICON] ]
        if icon then
            return "interface/icons/" .. icon
        else
            CP.Debug("No Icon: "..item[I_ICON].." for Item "..item_id)
        end
    else
        CP.Debug("Item not in DB: "..item_id)
    end
end



function DB.GetItemDura(item_id)
    local item = DB.items[item_id]
    if item then
        return item[I_DURA]
    end
    return 100
end

function DB.IsItemAllowedInSlot(item_id, slot)
    local a,b = DB.GetItemPositions(item_id)

    return slot==a or slot==b
end


function DB.GetItemPositions(item_id)
    local item = DB.items[item_id]
    if not item then return end

    local slot = item[I_SLOT]
    if slot>31 then
        if slot == 32 then return 15 end -- Haupthand
        if slot == 33 then return 16 end -- Nebenhand
        if slot == 34 then return 15,16 end -- Einhand
        if slot == 35 then return 15,16,true end -- Zweihand
        if slot == 37 then return 10 end -- Fernkampf
    else
        if slot==11 or slot==12 then return 11,12 end
        if slot==13 or slot==14 then return 13,14 end
        return slot
    end
end

function DB.GetItemTypesForSlot(slot)

    if slot==15 then     return {32,34,35}
    elseif slot==16 then return {16,33,34}
    elseif slot==10 then return 37
    end

    return slot
end

function DB.IsWeapon2Hand(item_id)
    local item = DB.items[item_id]
    if item then
        return (item[I_SLOT] == 35)
    end
end

function DB.IsSlotType(slot_id)
    local slots={
    [0]=1, -- Head
    [1]=1, -- Hands
    [2]=1, -- Feets
    [3]=1, -- Body
    [4]=1, -- Legs
    [5]=2, -- Cloak
    [6]=1, -- Wraist
    [7]=1, -- Shoulders
    [8]=3, -- Necklace
    [10]=6, -- Ranges Weapon
    [11]=3, -- Ring
    [12]=3, -- Ring
    [13]=3, -- Earring
    [14]=3, -- Earring
    [15]=4, -- Primary Weapon
    [16]=5, -- Secondary Weapon
    [21]=7, -- Back
    }

    return  slots[slot_id]
end



--------
-- stat search
local function GetBonusName(id)
    local name = TEXT("Sys"..id.."_name")
    local gname, lvl = string.match(name,"^(.-)%s+(%w+)$")
    if not gname then
        return name, ""
    end
    return gname, lvl
end

function DB.GetBonusGroupList(runes, filter)

    runes = runes and true or false

    if filter then
        filter = filter:lower()
    end

    local done={}
    local res={}
    for id,rdata in pairs(DB.bonus) do

        local group = rdata[B_GROUP]

        if group then
            if not done[group] then

                if DB.IsRuneGroup(group)==runes then
                    local name = GetBonusName(id)

                    local filter_found = (not filter) or string.find(name:lower(),filter)

                    eff = {}
                    for i, ef in ipairs(rdata[B_EFFECT_TYPE] or {}) do
                        local n = TEXT("SYS_WEAREQTYPE_"..ef)
                        if n then
                            table.insert(eff,n)
                            if not filter_found then
                                filter_found = string.find(n:lower(),filter)
                            end
                        end
                    end

                    if filter_found then
                        table.insert(res,{id,name,eff})
                    end
                end

                done[group]=1
            end
        end
    end

    table.sort(res, function (a,b) return a[2]<b[2] end)

    return res
end



function DB.GetBonusGroupLevels(grp)
    local res={}
    for id,rdata in pairs(DB.bonus) do

        if rdata[B_GROUP]==grp then
            local name, lvl = GetBonusName(id)
            table.insert(res,{lvl,id})
        end
    end

    table.sort(res, function (a,b) return DB.RomanToNum(a[1])<DB.RomanToNum(b[1]) end)

    return res
end

function DB.GetBonusInfo(id)
    local name, lvl = GetBonusName(id)
    local grp = DB.bonus[id] and DB.bonus[id][B_GROUP]
    return name, lvl, grp
end

function DB.FindBonus(text, cur_level, is_rune)

    text = text:lower()

    local good_match = nil
    local good_match_name = nil
    for id,rdata in pairs(DB.bonus) do

        if rdata[B_GROUP] and DB.IsRuneGroup(rdata[B_GROUP])==is_rune then

            local fulltext = TEXT("Sys"..id.."_name"):lower()
            local _, lvl = GetBonusName(id)

            if text==fulltext then
                return id
            elseif string.find(fulltext, "^"..text) then
                if lvl == cur_level then
                    return id
                else
                    good_match = id
                end
            end
        end
    end

    return good_match
end

function DB.IsRuneGroup(id)
    return id>10000
end

function DB.ToRoman(num)
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

function DB.RomanToNum( roman )
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

--------
-- item search
function DB.PrimarAttributes(item_id)
    local item = DB.items[item_id]
    if not item then return end

    local s = CP.Calc.STATS
    if item[I_SLOT]>31 then
        return s.PDMG, s.MDMG
    else
        return s.PDEF, s.MDEF
    end
end

function DB.FindItems(filter_function)

    local res={}
    for id,data in pairs(DB.items) do
        if filter_function(id,data) then
            table.insert(res,id)
        end
    end

    return res
end

function DB.GetItemInfo(item_id)

    local item = DB.items[item_id]
    if not item then return end

    return  item[I_LEVEL],item[I_SET]
end



function DB.GenerateItemDataByID(item_id)

    local data = {
        name = TEXT("Sys"..item_id.."_name"),
        icon = DB.GetItemIcon(item_id),
        id = item_id,
        bind = 0,   -- INVALID
        bind_flag = 0, -- INVALID
        plus = 0,
        rarity = 0,
        tier = 0,
        dura = 100,
        max_dura = 100,
        stats = {0,0,0,0,0,0},
        rune_slots = 0,
        runes = {0,0,0,0},
        unk1 = 0, -- INVALID/UNKNOWN
    }

    local item = DB.items[item_id]
    if item then
        for i,stat in ipairs(item[I_STATS] or {}) do
            data.stats[i]=stat
        end

        data.dura = item[I_DURA]
    end

    return data
end
