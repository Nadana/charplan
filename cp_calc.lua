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
    if not effect then return end

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
    Calc.ReadSkills()
end

function Calc.Release()
    Calc.CardsBonus=nil
    Calc.SkillBonus=nil
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

function Calc.ReadSkills()

    Calc.SkillBonus = Calc.NewStats()

    local skills = Calc.GetListOfSkills()
    for skill_id, level in pairs(skills) do

        local spells = CP.DB.GetSkillSpells(skill_id)
        for _,spell_id in ipairs(spells) do

            local skill_arg, effects = CP.DB.GetSkillSpellEffect(spell_id)
            if skill_arg then
                for i=1,#effects,2 do
                    local ev = effects[i+1]

                    local val = (skill_arg*level+100) * ev / 100
                    val = math.floor(val*10+0.5)/10

                    Calc.SkillBonus[effects[i]] = Calc.SkillBonus[effects[i]] + val
                end
            end
        end
    end
end

function Calc.GetListOfSkills()

    local skills = {}

    for page=2,4 do

        local count = GetNumSkill( page ) or 0
        for index = 1,count do
            local link = GetSkillHyperLink( page, index )
            local id, lvl = link:match(":(%d+) (%d+)")
            skills[tonumber(id)] = tonumber(lvl)
        end
    end

    return skills
end

function Calc.Calculate()

    local values = Calc.GetBases()
    values = values + Calc.GetBasesCalced()
    values = values + Calc.GetSkillBonus()
    values = values + Calc.GetCardBonus()
    values = values + Calc.GetArchievementBonus()
    values = values + Calc.GetAllItemsBonus()

  	Calc.DependingStats(values)

    return values
end

local function AddDescription(stat, text,value, value_prefix)
    if Calc.exp_tab and Calc.exp_stat==stat and value~=0 then
        table.insert(Calc.exp_tab.left, text)
        value_prefix = value_prefix or "+"
        table.insert(Calc.exp_tab.right,value_prefix..value)
    end
end

function Calc.Explain(stat)

    local COLOR_CLASS= "|cff00ff00"
    local COLOR_SKILL= "|cffff5040"
    local COLOR_CARD = "|cffa0a040"
    local COLOR_SET  = "|cffa08040"
    local COLOR_ITEM = "|cffe0e0e0"
    local COLOR_TITLE= "|cffe0e0e0"


    local res  = {left={}, right={} }
    Calc.exp_tab = res
    Calc.exp_stat = stat

    local s = Calc.STATS
    if stat == s.PDMGR or stat == s.PDMGMH or stat == s.PDMGOH then
        res.left, res.right= Calc.Explain(s.PDMG)
        AddDescription(stat,"",0)
    end

    if stat == s.PCRITR or stat == s.PCRITMH or stat == s.PCRITOH then
        res.left, res.right= Calc.Explain(s.PCRIT)
        AddDescription(stat,"",0)
    end

    local values = Calc.GetBases()
    values = values + Calc.GetBasesCalced()
    local total = values
    AddDescription(stat, COLOR_CLASS..CP.L.BY_CLASS, values[stat],"")

    values = Calc.GetSkillBonus()
    total = total + values
    AddDescription(stat, COLOR_SKILL..CP.L.BY_SKILL, values[stat])

    values = Calc.GetCardBonus()
    total = total + values
    AddDescription(stat, COLOR_CARD..CP.L.BY_CARD, values[stat])

    values = Calc.GetSetBonus()
    total = total + values
    AddDescription(stat, COLOR_SET..CP.L.BY_SET, values[stat])

    values = Calc.GetArchievementBonus()
    total = total + values
    AddDescription(stat, COLOR_SET..CP.L.BY_TITLE, values[stat])

	for _,slot in ipairs( {0,1,2,3,4,5,6,7,8,9,11,12,13,14,21,10,15,16} ) do
        local item = CP.Items[slot]
		if item then
            values = Calc.GetItemBonus(item)
            total = total + values
            AddDescription(stat, COLOR_ITEM..TEXT("Sys"..item.id.."_name"), values[stat])
		end
	end

    Calc.DependingStats(total)


    Calc.exp_tab = nil
    Calc.exp_stat = nil

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
	v.PCRITMH = GetPlayerAbility("MAGIC_CRITICAL") -- not correct ability but correct numbers
	v.PCRITDMG = v.PCRITDMG + 30
	v.MCRITDMG = v.MCRITDMG + 30
	--Magic
	v.MCRIT = GetPlayerAbility("MAGIC_CRITICAL")

    return v
end

function Calc.GetBasesCalced()

    local v = Calc.NewStats()

    -- HP
    -- TODO: that's wrong but atleast a lower border
    local lvl = UnitLevel("player")
    v.HP = 64 + 6.5*lvl

    return v
end

function Calc.GetCardBonus()
    return Calc.CardsBonus
end

function Calc.GetSkillBonus()
    return Calc.SkillBonus
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

function Calc.GetAllItemsBonus()

    local values = Calc.NewStats()
    values = values + Calc.GetSetBonus()

    local items = {}
	for slot,item in pairs(CP.Items) do
        items[slot] = Calc.GetItemBonus(item)
    	values = values + items[slot]
    end

    items[10] = items[10] or Calc.NewStats()
    items[15] = items[15] or Calc.NewStats()
    items[16] = items[16] or Calc.NewStats()

    values.PDMG = values.PDMG  -items[10].PDMG -items[15].PDMG -items[16].PDMG
    values.PCRIT= values.PCRIT -items[10].PCRIT-items[15].PCRIT-items[16].PCRIT

    values.PDMGR  = values.PDMG  +items[10].PDMG
    values.PDMGMH = values.PDMG  +items[15].PDMG
    values.PDMGOH = values.PDMG  +items[16].PDMG
    values.PCRITR = values.PCRIT +items[10].PCRIT
    values.PCRITMH= values.PCRIT +items[15].PCRIT
    values.PCRITOH= values.PCRIT +items[16].PCRIT

    return values
end


local function IsStandardAttribut(stat)
    local s = CP.Calc.STATS
    return  stat==s.PDMG or stat==s.MDMG or
            stat==s.PDEF or stat==s.MDEF;
end

function Calc.GetItemBonus(item)

    local values = Calc.NewStats()
    if not item then return values end

    local effect = CP.DB.GetItemEffect(item.id)
    local dura_factor = Calc.GetItemDuraFactor(item)
    local plus_effect, plus_base = CP.DB.GetPlusEffect(item.id, item.plus)

    local factor = (1+item.tier*0.1)*dura_factor

    for i=1,#effect,2 do
        local ef = effect[i]
        local val = effect[i+1]
        if IsStandardAttribut(ef) then
            -- NB: based on float/rounding errors we may have a +/- 0.1
            local v = math.floor(val*(1+plus_base/100))
            local dif = math.floor( (v-val)*(item.tier*0.1*dura_factor) *10)/10
            v = v*factor-dif
            values[ef] = values[ef] + v
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

    local max_dura = CP.DB.GetItemMaxDura(item.id, item.max_dura)

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
    Calc.StatRelationsAttributes(values)
    Calc.CharDepended(values)
    Calc.CharIndepended(values)
	Calc.StatRelations(values)
	Calc.WeaponDepended(values)
end

local STATS_PERC_VALUES_ATTRIBUTES={
    [161]={Calc.STATS.STR},   -- "% Stärke"
    [162]={Calc.STATS.STA},   -- "% Ausdauer"
    [163]={Calc.STATS.INT},   -- "% Intelligenz"
    [164]={Calc.STATS.WIS},   -- "% Weisheit"
    [165]={Calc.STATS.DEX},   -- "% Geschicklichkeit"
    [166]={Calc.STATS.STR, Calc.STATS.STA, Calc.STATS.INT, Calc.STATS.WIS, Calc.STATS.DEX}, -- "% Alle Hauptattribute"
}
local STATS_PERC_VALUES={
   [167]={Calc.STATS.HP},    -- "% LP-Maximums"
    [168]={Calc.STATS.MP},    -- "% MP-Maximums"
    [170]={Calc.STATS.MDEF},  -- "% Magische Verteidigung"
    [171]={Calc.STATS.MATK},  -- "% Magische Angriffskraft"
    [192]={Calc.STATS.MDMG},  -- "% magische Schadensrate"
    [199]={Calc.STATS.MACC},  -- "% Magische Präzision"
    [149]={Calc.STATS.MHEAL}, -- "% Heilung"
    [135]={Calc.STATS.PDEF},  -- "% Verteidigung"
    [37] ={Calc.STATS.PDMGOH}, -- "% Nebenhand-Schadensrate"
    [36] ={Calc.STATS.PACCOH}, -- "% Nebenhand-Präzision"
    [52] ={Calc.STATS.PDMGR},  -- "% Fernkampfwaffen-Schadensrate"
    [134]={Calc.STATS.PATK, Calc.STATS.PATKR}, -- "% physische Angriffe"
    [173]={Calc.STATS.PDMGMH, Calc.STATS.PDMGOH, Calc.STATS.PDMGR}, -- "% Schaden"
    [56] ={Calc.STATS.PDMGMH, Calc.STATS.PDMGOH}, -- "% Nahkampfwaffen-Schadensrate"
}

function Calc.StatRelationsAttributes(values, res_tab, res_stat)

    local s = Calc.STATS
    local all = values.ALL_ATTRIBUTES
    if all then
        values.STR = values.STR+all
        values.STA = values.STA+all
        values.DEX = values.DEX+all
        values.INT = values.INT+all
        values.WIS = values.WIS+all

        AddDescription(s.STR, TEXT("SYS_WEAREQTYPE_7"),all)
        AddDescription(s.STA, TEXT("SYS_WEAREQTYPE_7"),all)
        AddDescription(s.DEX, TEXT("SYS_WEAREQTYPE_7"),all)
        AddDescription(s.INT, TEXT("SYS_WEAREQTYPE_7"),all)
        AddDescription(s.WIS, TEXT("SYS_WEAREQTYPE_7"),all)
    end
	local perc_list = STATS_PERC_VALUES_ATTRIBUTES
	Calc.Perc_Values(values, perc_list)   
end
function Calc.StatRelations(values)
	local perc_list = STATS_PERC_VALUES
	Calc.Perc_Values(values, perc_list)
end
function Calc.Perc_Values(values, perc_list)	
	for p_stat,inc_stat in pairs(perc_list) do
        if values[p_stat]~=0 then
            local percent = values[p_stat]/100

            for _,i_stat in ipairs(inc_stat) do
                local inc = math.floor(values[i_stat]*percent)
                values[i_stat] = values[i_stat] + inc

                AddDescription(i_stat, TEXT("SYS_WEAREQTYPE_"..p_stat),inc)
            end
        end
    end
end

local function AddValue(values, stat,val, by_stat)
    values[stat] = values[stat] + val
    AddDescription(stat, TEXT("SYS_WEAREQTYPE_"..by_stat), math.floor(val))
end

function Calc.CharIndepended(values)
    local s = Calc.STATS

    AddValue(values, s.EVADE, math.floor(values.DEX* 0.78), s.DEX)

    AddValue(values, s.MATK,  values.INT* 2, s.INT)
    AddValue(values, s.MRES,  values.WIS* 0.6, s.WIS)
    AddValue(values, s.MACC,  values.WIS* 0.9, s.WIS)
    AddValue(values, s.PACC,  values.DEX* 0.9, s.DEX)
    AddValue(values, s.MHEAL, values.MDMG*0.5, s.MDMG)
    AddValue(values, s.PACCR, values.PACC*1  , s.PACC)
    AddValue(values, s.PACCOH,values.PACC*0.5, s.PACC)
    AddValue(values, s.PATKR, values.PATK*1 , s.PATK)

    AddValue(values, s.HP, values.STA*5  , s.STA)
    AddValue(values, s.HP, values.STR*0.2, s.STR)

    AddValue(values, s.MANA, values.WIS*5, s.WIS)
    AddValue(values, s.MANA, values.INT*1, s.INT)

    AddValue(values, s.PDMGOH, values.PDMGOH*(-0.3), s.PDMG)
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

function Calc.CharDepended(values)
    local s = Calc.STATS
    local cname = UnitClassToken("player")
    local d = CLASS_VARS[cname]

    AddValue(values, s.MDEF,  math.floor(values.WIS* d.MDEF), s.WIS)
    AddValue(values, s.PDEF,  values.STA* d.PDEF, s.STA)
    AddValue(values, s.PATK,  values.INT* d.PATKint, s.INT)
    AddValue(values, s.PATK,  values.DEX* d.PATKdex, s.DEX)
    AddValue(values, s.PATK,  values.STR* d.PATKstr, s.STR)
end

local WEAPON_STATS={
    [0]=58 , -- "% Schwert-Schadensrate",
    [1]=59 , -- "% Dolch-Schadensrate",
    [2]=60 , -- "% Stab-Schadensrate",
    [3]=61 , -- "% Axt-Schadensrate",
    [4]=62 , -- "% Einhandhammer-Schadensrate",
    [5]=63 , -- "% Zweihandschwert-Schadensrate",
    [6]=64 , -- "% Zweihandstab-Schadensrate",
    [7]=65 , -- "% Zweihandaxt-Schadensrate",
    [8]=66 , -- "% 'Beidhändiger Hammer'-Schadensrate",
	[10]=53 , -- "% Bogen-Schadensrate",
    [11]=54 , -- "% Armbrust-Schadensrate",
    --[]55 , -- "% Feuerwaffen-Schadensrate",
    --[]67 , -- "% Feuerwaffen-Schadensrate",
}

function Calc.WeaponDepended(values)
    local s = Calc.STATS

	if CP.Items[10] then
        local weapon_type = CP.DB.GetWeaponType(CP.Items[10].id)
        local wstat = WEAPON_STATS[weapon_type]
        if wstat then
            AddValue(values, s.PDMGR, values.PDMGR*values[wstat]/100, wstat)
        end
	end

	if CP.Items[15] then
        local weapon_type = CP.DB.GetWeaponType(CP.Items[15].id)
        local wstat = WEAPON_STATS[weapon_type]
        if wstat then
            if weapon_type==2 or weapon_type==6 then
                AddValue(values, s.MDMG, values.MDMG*values[wstat]/100, wstat)
            else
                AddValue(values, s.PDMGMH, values.PDMGMH*values[wstat]/100, wstat)
            end
        end
	end

	if CP.Items[16] then
        local weapon_type = CP.DB.GetWeaponType(CP.Items[16].id)
        local wstat = WEAPON_STATS[weapon_type]
        if wstat then
            if weapon_type==2 then
                AddValue(values, s.MDMG, values.MDMG*values[wstat]/100, wstat)
            else
                AddValue(values, s.PDMGOH, values.PDMGOH*values[wstat]/100, wstat)
            end
        end
    end
end


