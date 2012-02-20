--[[
    CharPlan - Cals

    Calculations
]]
local CP = _G.CP
local Calc= {}
CP.Calc = Calc


Calc.STATS={
    -- Base
    STR=2, -- Strength
    STA=3, -- Stamina
    INT=4, -- Inteligenz
    WIS=5, -- Wisdom
    DEX=6, -- Dexterity
    ALL_ATTRIBUTES = 7,

    -- Base2
    HP = 8,
    MANA = 9,

    -- pdef
	PDEF = 13,
    PARRY = 22,
	EVADE = 17,

	-- melee/range
	PDMG = 25,
	PDMGR = 400,
	PDMGMH = 401,
	PDMGOH = 402,


	PATK = 12,
	PATKR = 407,
	PCRIT = 18,
	PCRITR = 403,
	PCRITMH = 404,
	PCRITOH = 405,
	PACC = 16,
	PACCMH = 409,
	PACCR = 408,
	PACCOH = 406,

	--mdef
	MDEF = 14,
	MRES = 196,

    -- magic
	MDMG = 191,
    MATK = 15,
    MCRIT = 20,
    MHEAL = 150,
    MACC = 195,

	PCRITDMG = 19,
	MCRITDMG = 21,
}


local StatsMeta={
    __add = function (tab1,tab2)
        local res = CP.Utils.TableCopy(tab1)
        setmetatable(res , getmetatable(tab1))
        for i,v in pairs(tab2) do
            res[i]=res[i]+v
        end
        return res
    end,
    __index = function(s, key)
        if type(key)=="string" then
            key = Calc.STATS[key]
            if not key then error("unknown field",2) end
        end
        return (rawget(s, key) or 0)
    end,
    __newindex = function(s,key,val)
        if type(key)=="string" then
            key = Calc.STATS[key]
            if not key then error("unknown field",2) end
        end
        rawset(s,key,val)
    end,
}

function Calc.NewStats()
    local res = {}
    setmetatable(res , StatsMeta)
    return res
end

local function ApplyBonus(stats, effect, factor)
    factor = factor or 1
    for i=1,#effect,2 do
        stats[effect[i]] = stats[effect[i]] + effect[i+1] * factor
    end
end

local function AddStats(stats_res, stats)
    for id, val in pairs(stats or {}) do
        stats_res[id]=stats_res[id]+val
    end
end

function Calc.Clear()
    Calc.values=Calc.NewStats()
    return Calc.values
end


function Calc.ID2StatName(id)
    for n,v in pairs(Calc.STATS) do
        if id==v then return n end
    end
end

function Calc.Init()
    Calc.ReadCards()
end

function Calc.Release()
    Calc.CardsBonus=nil
end

function Calc.ReadCards()

    Calc.CardsBonus = Calc.NewStats()
    for i = 0,15 do
        local count = LuaFunc_GetCardMaxCount(i)
        for j =0, count do
            local id, own = LuaFunc_GetCardInfo(i , j)
            if (own or 0)>0 then
                local effect  = CP.DB.GetCardEffect(id)
                ApplyBonus(Calc.CardsBonus, effect)
            end
        end
    end
end

function Calc.Calculate()

    local values = Calc.GetBases()
    values = values + Calc.GetCardBonus()
    values = values + Calc.GetSetBonus()
    values = values + Calc.GetArchievementBonus()

    local items = {}
	for _,slot in ipairs( {0,1,2,3,4,5,6,7,8,9,11,12,13,14,21,10,15,16} ) do
        items[slot] = Calc.GetItemBonus(CP.Items[slot])
    	values = values + items[slot]
    end

    values.PDMGR = values.PDMG   -items[15].PDMG -items[16].PDMG
    values.PCRITR= values.PCRIT  -items[15].PCRIT-items[16].PCRIT
    values.PDMGMH = values.PDMG  -items[10].PDMG -items[16].PDMG
    values.PCRITMH= values.PCRIT -items[10].PCRIT-items[16].PCRIT
    values.PDMGOH = values.PDMG  -items[10].PDMG -items[15].PDMG
    values.PCRITOH= values.PCRIT -items[10].PCRIT-items[15].PCRIT

  	Calc.DependingStats(values)

    return values
end

local function AddDescription(res_tab, text,value, value_prefix)
    if value~=0 then
        table.insert(res_tab.left, text)
        value_prefix = value_prefix or "+"
        table.insert(res_tab.right,value_prefix..value)
    end
end

function Calc.Explain(stat)

    local COLOR_CLASS= "|cff00ff00"
    local COLOR_CARD = "|cffa0a040"
    local COLOR_SET  = "|cffa08040"
    local COLOR_ITEM = "|cffe0e0e0"
    local COLOR_TITLE= "|cffe0e0e0"

    local res = {left={}, right={} }

    local values = Calc.GetBases()
    local total = values
    AddDescription(res, COLOR_CLASS..CP.L.BY_CLASS, values[stat],"")

    values = Calc.GetCardBonus()
    total = total + values
    AddDescription(res, COLOR_CARD..CP.L.BY_CARD, values[stat])

    values = Calc.GetSetBonus()
    total = total + values
    AddDescription(res, COLOR_SET..CP.L.BY_SET, values[stat])

    values = Calc.GetArchievementBonus()
    total = total + values
    AddDescription(res, COLOR_SET..CP.L.BY_TITLE, values[stat])

	for _,slot in ipairs( {0,1,2,3,4,5,6,7,8,9,11,12,13,14,21,10,15,16} ) do
        local item = CP.Items[slot]
		if item then
            values = Calc.GetItemBonus(item)
            total = total + values
            AddDescription(res, COLOR_ITEM..TEXT("Sys"..item.id.."_name"), values[stat])
		end
	end

    Calc.Explain_DependingStats(res)
    return res.left,res.right
end

function Calc.GetBases()

    local v = Calc.NewStats()

	--Base
    v.STR = GetPlayerAbility("STR")
    v.STA = GetPlayerAbility("STA")
    v.DEX = GetPlayerAbility("AGI")
    v.INT = GetPlayerAbility("INT")
    v.WIS = GetPlayerAbility("MND")

	--Melee
	v.PCRITOH = GetPlayerAbility("MELEE_CRITICAL")
	v.PCRITMH = GetPlayerAbility("MELEE_MAIN_CRITICAL")
	v.PCRITOH = GetPlayerAbility("MELEE_OFF_CRITICAL")
	v.PACCMH = GetPlayerAbility("PHYSICAL_MAIN_HIT")

	--Range
	v.PCRITR = GetPlayerAbility("RANGE_CRITICAL")

	--Magic
	v.MCRIT = GetPlayerAbility("MAGIC_CRITICAL")

    return v
end

function Calc.GetCardBonus()
    return Calc.CardsBonus
end

function Calc.GetArchievementBonus()

    local values = Calc.NewStats()

    local titel_id = GetCurrentTitle()
    if titel_id>0 then
        local effect = CP.DB.GetArchievementEffect(titel_id)
        ApplyBonus(values, effect)
    end

    return values
end

function Calc.GetItemBonus(item)

    local values = Calc.NewStats()
    if not item then return values end

    local attA,attB = CP.DB.PrimarAttributes(item.id)
    local effect = CP.DB.GetItemEffect(item.id)
	local dura_factor = Calc.GetItemDuraFactor(item)
    local plus_effect, plus_base = CP.DB.GetPlusEffect(item.id, item.plus)

    local factor = (1+item.tier*0.1)*dura_factor

    for i=1,#effect,2 do
        local ef = effect[i]
        local val = effect[i+1]
        if ef==attA or ef==attB then
            local v = math.floor(val*(1+plus_base/100))
            local dif = (v-val)*(item.tier*0.1)
            values[ef] = values[ef] + (v*factor-dif)
        else
            values[ef] = values[ef] + val*factor
        end
    end

    ApplyBonus(values, plus_effect, dura_factor)

    for i=1,6 do
        if item.stats[i]>0 then
            local effect  = CP.DB.GetBonusEffect(item.stats[i])
            ApplyBonus(values, effect, dura_factor)
        end
    end

    for i=1,4 do
        if item.runes[i]>0 then
            local effect = CP.DB.GetBonusEffect(item.runes[i])
            ApplyBonus(values, effect, dura_factor)
        end
    end

    return values
end

function Calc.GetItemDuraFactor(item)

    local max_dura = CP.DB.GetItemDura(item.id) * item.max_dura / 100

	if (item.dura > 100) or (item.dura > max_dura) then
		return 1.2
	elseif item.dura <= max_dura/5 then
		return 0.2
	elseif item.dura <= max_dura/2 then
		return 0.8
	end

    return 1
end

function Calc.GetSetBonus()
    local sets={}
    local counted={}

    for _,item in pairs(CP.Items) do
        local _,set_id = CP.DB.GetItemInfo(item.id)
        if set_id and not counted[item.id] then
            sets[set_id]=(sets[set_id] or 0)+1
            counted[item.id]=1
        end
    end

    local v = Calc.NewStats()
    for set_id,item_count in pairs(sets) do
        local eff = CP.DB.GetSetEffect(set_id, item_count)
        ApplyBonus(v, eff)
    end

    return v
end

function Calc.DependingStats(values)
    Calc.StatRelations(values)
    Calc.CharDepended(values, UnitClassToken("player"))
    Calc.CharIndepended(values)
end

function Calc.Explain_DependingStats(res)
    local values = Calc.Clear()
    CP.Calc.StatRelations(values)
    AddDescription(res, TEXT("SYS_WEAREQTYPE_7"), values[stat])
end

function Calc.StatRelations(values)

    local all = values.ALL_ATTRIBUTES
    if all then
        values.STR = values.STR+all
        values.STA = values.STA+all
        values.DEX = values.DEX+all
        values.INT = values.INT+all
        values.WIS = values.WIS+all
    end

    local p = values[166] / 100 --% all
    if p~=0 then
        values.STR = values.STR*(1+p)
        values.STA = values.STA*(1+p)
        values.DEX = values.DEX*(1+p)
        values.INT = values.INT*(1+p)
        values.WIS = values.WIS*(1+p)
    end
	
	local p = values[56] / 100 -- pdmg (melee)
	if p~=0 then
		values.PDMGMH = values.PDMGMH*(1+p)
		values.PDMGOH = values.PDMGOH*(1+p)
	end	
	
	local p = values[173] / 100 -- pdmg
	if p~=0 then
		values.PDMGMH = values.PDMGMH*(1+p)
		values.PDMGOH = values.PDMGOH*(1+p)
		values.PDMGR  = values.PDMGR *(1+p)
	end	
	
	local p = values[134] / 100 -- pdmg
	if p~=0 then
		values.PATK  = values.PATK*(1+p)
		values.PATKR = values.PATKR*(1+p)
	end	
	
	local p = values[134] / 100 -- pdmg
	if p~=0 then
		values.PACC   = values.PACC  *(1+p)
		values.PACCOH = values.PACCOH*(1+p)
		values.PACCR  = values.PACCR *(1+p)
	end	
	
    local s = Calc.STATS
    local perc={
        [161]=s.STR,    [162]=s.STA,    [163]=s.INT,   [164]=s.WIS,   [165]=s.DEX,
        [167]=s.HP,     [168]=s.MP,     [170]=s.MDEF,  [171]=s.MATK,  [192]=s.MDMG,
		[197]=s.PACC,   [199]=s.MACC,   [149]=s.MHEAL, [135]=s.PDEF,   [37]=s.PDMGOH,
  		 [36]=s.PACCOH,  [52]=s.PDMGR,
		
		
    }

    for s,v in pairs(perc) do
        local p = values[s]/100
        if p~=0 then  values[v] = values[v]*(1+p) end
    end

end

function Calc.CharIndepended(values)
    values.MATK = values.MATK + values.INT* 2
    values.EVADE= values.EVADE+ math.floor(values.DEX* 0.78)
    values.MRES = values.MRES + values.WIS* 0.6
    values.MACC = values.MACC + values.WIS* 0.9
    values.PACC = values.PACC + values.DEX* 0.9
    values.MHEAL= values.MHEAL+ values.MDMG*0.5

	values.PACCR = values.PACCR+ values.PACC*1
	values.PACCOH= values.PACCOH+values.PACC*0.5
	values.PDMGOH= values.PDMGOH+values.PDMGOH*0.7
	values.PATKR = values.PATKR+ values.PATK* 1

    values.HP= values.HP + values.STA* 5
    values.HP= values.HP + values.STR* 0.2

    values.MANA= values.MANA + values.WIS* 5
    values.MANA= values.MANA + values.INT* 1
end


local CLASS_VARS={
	["AUGUR"]  ={   PDEF=1.5, MDEF=3.2,
                    PATKint=0.5, PATKdex=0  ,PATKstr=0.8},
	["MAGE"]   ={   PDEF=1.5, MDEF=3  ,
                    PATKint=0.5,PATKdex=0  ,PATKstr=0.8},
	["DRUID"]  ={   PDEF=1.5, MDEF=3  ,
                    PATKint=0.5,PATKdex=0  ,PATKstr=0.8},
	["RANGER"] ={   PDEF=1.8, MDEF=2.6,
                    PATKint=0  ,PATKdex=1  ,PATKstr=1  },
	["KNIGHT"] ={   PDEF=3  , MDEF=2.4,
                    PATKint=0.5,PATKdex=0  ,PATKstr=1.5},
	["WARDEN"] ={   PDEF=2  , MDEF=2.4,
                    PATKint=0.5,PATKdex=0  ,PATKstr=1.5},
	["THIEF"]  ={   PDEF=1.8, MDEF=2.3,
                    PATKint=0  ,PATKdex=1.3,PATKstr=1.2},
    ["WARRIOR"]={   PDEF=2.3, MDEF=2.2,
                    PATKint=0  ,PATKdex=0  ,PATKstr=2  },
}

function Calc.CharDepended(values, cname)
    local d = CLASS_VARS[cname]

    values.PDEF = values.PDEF + values.STA* d.PDEF
    values.MDEF = values.MDEF + math.floor(values.WIS* d.MDEF)

    values.PATK = values.PATK + values.INT* d.PATKint
    values.PATK = values.PATK + values.DEX* d.PATKdex
    values.PATK = values.PATK + values.STR* d.PATKstr
end


