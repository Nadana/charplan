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
        local icon = DB.images[ item.icon ]
        if icon then
            return "interface/icons/" .. icon
        else
            CP.Debug("Not Icon: "..item.icon.." for Item: "..item_id)
        end
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
-- stat search
function DB.GetBonusGroupList(runes, filter)

    runes = runes and true or false

    local done={}
    local res={}
    for id,rdata in pairs(DB.bonus) do
        if rdata.grp then
            if not done[rdata.grp] then

                if DB.IsRuneGroup(rdata.grp)==runes then
                    local name = TEXT("Sys"..id.."_name")
                    name = string.match(name,"^(.-)%s*%w*$") or name

                    local filter_found = true
                    if filter then
                        filter_found = string.find(name,filter)
                    end

                    eff = {}
                    for i, ef in ipairs(rdata.efftype or {}) do
                        local n = TEXT("SYS_WEAREQTYPE_"..ef)
                        if n then
                            table.insert(eff,n)
                            if not filter_found and filter then
                                filter_found = string.find(name,n)
                            end
                        end
                    end

                    if filter_found then
                        table.insert(res,{id,name,eff})
                    end
                end

                done[rdata.grp]=1
            end
        end
    end

    table.sort(res, function (a,b) return a[2]<b[2] end)

    return res
end



function DB.GetBonusGroupLevels(grp)
    local res={}
    for id,rdata in pairs(DB.bonus) do

        if rdata.grp==grp then
            local name = TEXT("Sys"..id.."_name")
            local gname, lvl = string.match(name,"^(.-)%s*(%w*)$")
            if not gname then
                gname = name
                lvl = ""
            end

            table.insert(res,{lvl or "",id})
        end
    end

    table.sort(res, function (a,b) return DB.RomanToNum(a[1])<DB.RomanToNum(b[1]) end)

    return res
end

function DB.GetBonusInfo(id)

    local name = TEXT("Sys"..id.."_name")
    local gname, lvl = string.match(name,"^(.-)%s*(%w*)$")
    if not gname then
        gname = name
        lvl = ""
    end

    return gname, lvl, (DB.bonus[id] and DB.bonus[id].grp)
end

function DB.FindBonus(text, is_rune)

    local iname, ilvl = string.match(text,"^(.-)%s*(%w*)$")
    if not iname then
        iname = name
        ilvl = ""
    end

    local good_match = nil
    for id,rdata in pairs(DB.bonus) do
        if rdata.grp and DB.IsRuneGroup(rdata.grp)==is_rune then

            local name = TEXT("Sys"..id.."_name")
            local gname, lvl = string.match(name,"^(.-)%s*(%w*)$")
            if not gname then
                gname = name
                lvl = ""
            end

            if iname==name then
                if ilvl==lvl then
                    return iname,ilvl,id
                else
                    good_match = id
                end
            elseif string.find(gname, "^"..iname) then
                return gname,nil,id
            end
        end
    end

    return iname,ilvl,good_match
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




