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
    local I_EFFECT=7 -- optional
    local I_STATS=8 -- optional
    local I_SET=9 -- optional

    -- Bonus
    local B_EFFECT=1 -- optional
    local B_GROUP=2  -- optional

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
    DB.sets = LoadTable("sets")
    DB.archievements = LoadTable("archievements")
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
            DB.sets = nil
            DB.archievements = nil
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

    local effect={}
    local skills = DB.skills[skill_id]
    for _,spell_id in ipairs(skills or {}) do
        local boni = DB.spells[spell_id]
        if boni then
            for _,v in ipairs(boni) do
                table.insert(effect,v)
            end
        end
    end

    return effect
end

function DB.GetArchievementEffect(title_id)
    return DB.archievements[title_id] or {}
end

function DB.GetItemEffect(item_id)
    local item = DB.items[item_id]
    if item then
        return item[I_EFFECT]
    else
        CP.Debug("Item not in DB: "..item_id)
    end
end

function DB.GetItemUsualDropEffects(item_id)
    local item = DB.items[item_id]
    if item then
        if item[I_STATS] then
            local all_effects={}
            for _,stats in ipairs(item[I_STATS]) do
                local ea = DB.GetBonusEffect(stats)
                for _,v in ipairs(ea or {}) do
                    table.insert(all_effects,v)
                end
            end
            return all_effects
        end
    else
        CP.Debug("Item not in DB: "..item_id)
    end
end

function DB.GetBonusEffect(boni_id)
    if DB.bonus[boni_id] then
        return DB.bonus[boni_id][B_EFFECT]
    else
        CP.Debug("Bonus not in DB: "..boni_id)
    end
end

function DB.GetPlusEffect(item_id, plus)
    assert(plus>=0 and plus<21)

    if plus==0 then return {},0 end

    local item = DB.items[item_id]
    if item then
        local eff = DB.refines[item[I_REFINE]+plus-1]
        if eff then
            return eff[1], eff[2]
        else
            CP.Debug(string.format("Plus table not defined: %i+%i item:%i",item[I_REFINE],plus,item_id))
        end
    else
        CP.Debug("Item not in DB: "..item_id)
    end
end

function DB.GetSetEffect(set_id, item_count)

    local eff = {}

    for count,data in pairs(DB.sets[set_id] or {}) do
        if count<=item_count then
            for _,v in ipairs(data) do
                table.insert(eff,v)
            end
        end
    end

    return eff,eff_val
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

function DB.FindItemsOfIcon(icon_path)
    local name = string.gsub(icon_path,"^/?interface/icons/",""):lower()
    local res = {}
    for id,data in pairs(DB.items) do
        if name == DB.images[data[I_ICON]] then
            table.insert(res,id)
        end
    end
    return res
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
    elseif slot==12 then return 11
    elseif slot==14 then return 13
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
                    for i=1,#rdata[B_EFFECT],2 do
                        local n = TEXT("SYS_WEAREQTYPE_"..rdata[B_EFFECT][i])
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

    table.sort(res, function (a,b) return CP.Utils.RomanToNum(a[1])<CP.Utils.RomanToNum(b[1]) end)

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

local function GetFilterFunction(info)
--[[
 info.slot
 info.types
 info.name
 info.level_min
 info.level_max
 info.no_empty_items
]]
    local code = {"return function (id,data)"}

    if info.slot then
        local slots = CP.DB.GetItemTypesForSlot(info.slot)
        if type(slots)=="number" then
            table.insert(code, 'if data[1]~='..slots..' then return false end')
        else
            assert(type(slots)=="table")
            table.insert(code, 'if data[1]~='..table.concat(slots,' and data[1]~=')..' then return false end')
        end
    end

    if info.types then
        table.insert(code, 'if data[2]~='..table.concat(info.types,' and data[2]~=')..' then return false end')
    end

    if info.name and info.name~="" then
        local name = string.lower(info.name)
        table.insert(code, 'if not string.find(TEXT("Sys"..id.."_name"):lower(),"'..name..'") then return false end')
    end

    if info.level_min then
        table.insert(code, 'if data[3]<'..tostring(info.level_min)..' then return false end')
    end

    if info.level_max then
        table.insert(code, 'if data[3]>'..tostring(info.level_max)..' then return false end')
    end

    if info.no_empty_items then
        table.insert(code, 'if not CP.DB.GetItemEffect(id) then return false end')
    end


    table.insert(code,"return true end")

    local code_text = table.concat(code," ")

    local fct,err = loadstring(code_text)
    assert(fct,tostring(err).."\n"..code_text)
    return fct()
end

function DB.FindItems(info)

    local filter_function =  GetFilterFunction(info)

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
