--[[
    CharPlan - DB

    Item Database
]]


local DB = {}
local CP = _G.CP
CP.DB = DB


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
    DB.armor = LoadTable("armor")
    DB.weapons = LoadTable("weapons")
    DB.bonus = LoadTable("addpower")
    DB.runebonus = LoadTable("runes")
    DB.refines = LoadTable("refines")
    DB.cards = LoadTable("cards")
end

function DB.Release()
    DB.LoadCount = DB.LoadCount-1

    if DB.LoadCount ==0 then
        collectgarbage("collect")
        local mem1 = collectgarbage("count")
            DB.LoadCount = nil
            DB.images = nil
            DB.armor = nil
            DB.weapons = nil
            DB.bonus = nil
            DB.runebonus = nil
            DB.refines = nil
            DB.cards = nil
        collectgarbage("collect")
        local mem2 = collectgarbage("count")
        CP.Debug("DB Released. Freed memory: "..(math.floor(mem1-mem2)/1000).."mb")
    end
end

local function FindItem(item_id)
    if DB.weapons[item_id] then
        return DB.weapons[item_id],15
    end
    for slot,data in pairs(DB.armor) do
        if data[item_id] then
            return data[item_id],slot
        end
    end
end


function DB.GetCardEffect(card_id)
    local boni_id = DB.cards[card_id]
    if boni_id then
        return DB.GetBonusEffect(boni_id)
    end
end

function DB.GetItemEffect(item_id)
    local item = FindItem(item_id)
    if item then
        return item.efftype, item.effvalue
    else
        CP.Debug("Item not in DB: "..item_id)
    end
end

function DB.GetBonusEffect(boni_id)
    if DB.bonus[boni_id] then
        return DB.bonus[boni_id].efftype, DB.bonus[boni_id].effvalue
    else
        CP.Debug("Bonus not in DB: "..boni_id)
    end
end

function DB.GetRunesEffect(rune_id)
    if DB.runebonus[rune_id] then
        return DB.runebonus[rune_id].efftype, DB.runebonus[rune_id].effvalue
    else
        CP.Debug("Rune not in DB: "..rune_id)
    end
end

function DB.GetPlusEffect(item_id, plus)
    assert(plus>0 and plus<21)

    local item = FindItem(item_id)
    if item then
        local eff = DB.refines[item.refine+plus-1]
        if eff then
            return eff.efftype, eff.effvalue
        else
            CP.Debug(string.format("Plus table not defined: %i+%i item:%i",item.refine,plus,item_id))
        end
    else
        CP.Debug("Item not in DB: "..item_id)
    end
end

function DB.GetItemIcon(item_id)
    local item = FindItem(item_id)
    if item then
        return DB.images[ item.icon ]
    else
        CP.Debug("Item not in DB: "..item_id)
    end
end


function DB.IsItemAllowedInSlot(item_id, slot)
    local a,b = DB.GetItemPositions(item_id)

    return slot==a or slot==b
end


function DB.GetItemPositions(item_id)
    local item,slot = FindItem(item_id)

    if slot == 15 then
        if item.weaponpos == 0 then return 15 end -- Haupthand
        if item.weaponpos == 1 then return 16 end -- Nebenhand
        if item.weaponpos == 2 then return 15,16 end -- Einhand
        if item.weaponpos == 3 then return 15,16,true end -- Zweihand
        if item.weaponpos == 5 then return 10 end -- Fernkampf
    else
        if slot==11 or slot==12 then return 11,12 end
        if slot==13 or slot==14 then return 13,14 end
        return slot
    end
end


function DB.IsWeapon2Hand(item_id)
    local item = DB.weapons[item_id]
    if item then
        return item.weaponpos == 3
    end
end






--------
-- item search
function DB.GetItemForSlot(pos)

    local res={}
    if pos==15 or pos==16  or pos==10 then
        for id,_ in pairs(DB.weapons) do
            table.insert(res,id) -- TODO: need better filter
        end
    else
        for id,_ in pairs(DB.armor[pos]) do
            table.insert(res,id)
        end
    end

    return res
end