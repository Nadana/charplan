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
    local B_GROUP=2 -- optional
--[[ ] ]]


local function LoadTable(fname)
    local fn, err = loadfile("interface/addons/charplan/item_data/"..fname..".lua")
    assert(fn,err)
    return fn()
end

local function LoadEffects()
	local eff = {}
	for i=0,300 do
		local n = "SYS_WEAREQTYPE_" .. i
		local t = TEXT(n)
		eff[i] = t
	end
	return eff
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

    DB.effects = LoadEffects()
end

function DB.Release()
    DB.LoadCount = DB.LoadCount-1

    if DB.LoadCount ==0 then
        -- collectgarbage("collect")
        -- local mem1 = collectgarbage("count")
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
            DB.effects = nil
        collectgarbage("collect")
        -- local mem2 = collectgarbage("count")
        -- CP.Debug("DB Released. Freed memory: "..(math.floor(mem1-mem2)/1000).."mb")
    end
end

function DB.IsLoaded()
    return DB.LoadCount
end

function DB.GetCardEffect(card_id)
    local boni_id = DB.cards[card_id]
    if boni_id then
        return DB.GetBonusEffect(boni_id)
    end
end

function DB.GetSkillSpells(skill_id)
    return DB.skills[skill_id] or {}
end

function DB.GetSkillSpellEffect(spell_id)
    local boni = DB.spells[spell_id]
    if boni then
        return boni[1],boni[2]
    end
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
        if count<item_count then
            for _,v in ipairs(data) do
                table.insert(eff,v)
            end
        end
    end

    return eff,eff_val
end

function DB.GetItemName(item_id)
    return TEXT("Sys"..item_id.."_name")
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
		-- 1. replace '\' to '/'
		-- 2. lower
		-- 3. remove 'interface/icons' prefix
		-- 4. remove file extension
    local name = icon_path:gsub('\\','/'):lower():gsub("^/?interface/icons/",""):gsub("%.(%w+)$", "")
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
        return math.abs(item[I_DURA])
    end
    return 100
end

function DB.GetItemMaxDura(item_id, item_max_dura)
    local item = DB.items[item_id]
    if item then
        if item[I_DURA]<0 then
            return -item[I_DURA]
        else
            return math.floor(item[I_DURA]*item_max_dura/100)
        end
    end
end

function DB.HasFixedMaxDura(item_id)
    local item = DB.items[item_id]
    if item then
        return (item[I_DURA]<0)
    end
end

function DB.CalcMaxDura(item_id, dura)
    local item = DB.items[item_id]
    if item and item[I_DURA]>0 then
        return math.floor(dura*100/item[I_DURA]+0.5)
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

function DB.IsWeapon(id)
  if id and id >= 200000 then
    -- its item_id
    local s1,s2 = DB.GetItemPositions(id)
    return DB.IsWeapon(s1) or DB.IsWeapon(s2)
  end
  -- its slot_id
  return id == 10 or id == 15 or id == 16
end

function DB.IsWeapon2Hand(item_id)
    local item = DB.items[item_id]
    if item then
        return (item[I_SLOT] == 35)
    end
end

function DB.GetWeaponType(item_id)
	local item = DB.items[item_id]
	return item[I_TYPE]-9
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

function DB.ItemSkinPosition(item_id)
    local item_pos = DB.GetItemPositions(item_id)
    if not item_pos then return end

    local mslots={0,1,2,3,4,5,6,7,10,15,16,21}
    for _,i in ipairs(mslots) do
        if  i==item_pos then
            return i
        end
    end
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

function DB.GetBonusFilteredList(is_rune, existingStats, statName, name1, name2, minValue)
	is_runs = is_rune and true or false
	minValue = minValue and tonumber(minValue)

	-- convert existing stats to lookup table
	local exists = {}
	if existingStats then
		for i,v in pairs(existingStats) do
			if v then
				exists[v] = true
			end
		end
	end

	-- filter out stat and bonus names
	local result, done = {},{}
	for id,rdata in pairs(DB.bonus) do
		local group = rdata[B_GROUP]
		if group and not done[group] and not exists[id] then
			if DB.IsRuneGroup(group) == is_rune then
				local name = GetBonusName(id)
				local found, found1, found2 = (not statName) or name:lower():find(statName)		-- filter by stat name
				local eff = {}
				local bonus = rdata[B_EFFECT]
				for i=1,#bonus,2 do
					local effect = DB.effects[ bonus[i] ]
					local value = bonus[i+1]
					if not effect then break end
					table.insert(eff, effect)
					if name1 and i == 1 then								-- filter by effect1
						found1 = effect:lower():find(name1)
					end
					if name2 and i == 3 then								-- filter by effect2
						found2 = effect:lower():find(name2)
					end
				end
				if found and (not name1 or found1) and (not name2 or found2) then
					table.insert(result,{id,name,eff})
				end
			end
			done[group] = true
		end
	end

	-- filter out min values and existing stats
	local first_of_group = function(id)
		local group = DB.bonus[id][B_GROUP]
		for i = id-1,(520000-1),-1 do
			local stat = DB.bonus[i]
			if not stat or stat[B_GROUP] ~= group then
				return i + 1
			end
		end
		return id
	end

	local is_include_stat = function(id)
		if exists[id] then
			return false
		elseif not minValue then
			return true
		else
			local bonus = DB.bonus[id][B_EFFECT]
			for i=2,#bonus,2 do
				local v = bonus[i]
				if v >= minValue then
					return true
				end
			end
			return false
		end
	end

	done = {}
	for i,stat in pairs(result) do
		local id = stat[1]
		local group = DB.bonus[id][B_GROUP]
		local include = false
		if not is_rune then
			-- item stats always are single
			include = is_include_stat(id)
		else
			-- its a random-choosed rune from list, and we must enumerate all similar of same group
			local rid = first_of_group(id)
			while DB.bonus[rid] do
				if DB.bonus[rid][B_GROUP] ~= group then
					break
				elseif exists[rid] then
					-- force exclude
					include = false
					break
				end
				include = is_include_stat(rid)
				rid = rid + 1
			end
		end
		if include then
			table.insert(done, stat)
		end
	end

	table.sort(done, function (a,b) return a[2]<b[2] end)
	return done
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
    return id>=10000
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
 info.rarity
 info.level_min
 info.level_max
 info.no_empty_items
 info.itemset_only
]]
    local code = {"return function (id,data)"}

    if info.slot then
        local slots = CP.DB.GetItemTypesForSlot(info.slot)
        if type(slots)=="number" then
            table.insert(code, string.format('if data[%i]~=%i then return false end',I_SLOT,slots))
        else
            assert(type(slots)=="table")
            table.insert(code, 'if data[1]~='..table.concat(slots,' and data[1]~=')..' then return false end')
        end
    end

    if info.itemset_only then
        table.insert(code, 'if not data['..I_SET..'] then return false end')
    end

    if info.types then
        table.insert(code, 'if data[2]~='..table.concat(info.types,' and data[2]~=')..' then return false end')
    end

    if info.level_min then
        table.insert(code, string.format('if data[%i]<%i then return false end',I_LEVEL,info.level_min))
    end

    if info.level_max then
        table.insert(code, string.format('if data[%i]>%i then return false end',I_LEVEL,info.level_max))
    end

    if info.no_empty_items then
        table.insert(code, 'local eff=CP.DB.GetItemEffect(id) if not eff or #eff==0 then return false end')
    end

    if info.rarity then
        table.insert(code, 'if GetQualityByGUID(id)~='..info.rarity..' then return false end')
    end

    if info.name and info.name~="" then
        local name = string.lower(info.name)
        local suit_test = string.format('if not data[%i] or not string.find(TEXT("Sys"..data[%i].."_name"):lower(),"%s") then return false end',I_SET,I_SET,name)
        table.insert(code, 'if not string.find(TEXT("Sys"..id.."_name"):lower(),"'..name..'") then '..suit_test..' end')
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
        max_runes = 0,
        runes = {0,0,0,0},
        unk1 = 0, -- INVALID/UNKNOWN
    }

    local item = DB.items[item_id]
    if item then
        for i,stat in ipairs(item[I_STATS] or {}) do
            data.stats[i]=stat
        end

        data.dura = math.abs(item[I_DURA])
    end

    return data
end

function DB.GetSuitItems(suit_id)
    assert(suit_id)
    local set = {}
    for item_id, v in pairs(DB.items) do
        if suit_id == v[I_SET] then
            table.insert(set, item_id)
    end
  end

    return set
end

function DB.IsSuitItem(item_id)
  local lvl, suit = DB.GetItemInfo(item_id)
  return suit
end
