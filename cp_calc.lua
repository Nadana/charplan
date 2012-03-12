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

        local effect = CP.DB.GetSkillEffect(skill_id)
        for i=1,#effect,2 do
            local ev = effect[i+1]
            -- TODO: calc real value with ability_skilllvarg
            -- local val = (varg*level+100) * ev / 100
            
            -- NOTE: a approximation - real value can differ by 0.1 (related to rounding borders)
            local val = ev*(1+level/10)- math.floor(ev*level/10+0.49)/10

            Calc.SkillBonus[effect[i]] = Calc.SkillBonus[effect[i]] + val
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
        		--[[
            local _, _, _, _, PLV, _, _, _ = GetSkillDetail( page,  index )
            local link = GetSkillHyperLink( page, index )
            local _type, _data, _name = ParseHyperlink(link)
            local _,_,skill_id = string.find(_data, "(%d+)")
            skills[tonumber(skill_id)] = PLV
            --]]
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

local function AddDescription(res_tab, text,value, value_prefix)
    if value~=0 then
        table.insert(res_tab.left, text)
        value_prefix = value_prefix or "+"
        table.insert(res_tab.right,value_prefix..value)
    end
end

function Calc.Explain(stat)

    local COLOR_CLASS= "|cff00ff00"
    local COLOR_SKILL= "|cffff5040"
    local COLOR_CARD = "|cffa0a040"
    local COLOR_SET  = "|cffa08040"
    local COLOR_ITEM = "|cffe0e0e0"
    local COLOR_TITLE= "|cffe0e0e0"

    local res = {left={}, right={} }

    local s = Calc.STATS
    if stat == s.PDMGR or stat == s.PDMGMH or stat == s.PDMGOH then
        res.left, res.right= Calc.Explain(s.PDMG)
        AddDescription(res, "",0)
    end

    if stat == s.PCRITR or stat == s.PCRITMH or stat == s.PCRITOH then
        res.left, res.right= Calc.Explain(s.PCRIT)
        AddDescription(res, "",0)
    end

    local values = Calc.GetBases()
    values = values + Calc.GetBasesCalced()
    local total = values
    AddDescription(res, COLOR_CLASS..CP.L.BY_CLASS, values[stat],"")

    values = Calc.GetSkillBonus()
    total = total + values
    AddDescription(res, COLOR_SKILL..CP.L.BY_SKILL, values[stat])

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

    Calc.Explain_DependingStats(res, total, stat)

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
    Calc.StatRelations(values)
    Calc.CharDepended(values)
    Calc.CharIndepended(values)
	Calc.WeaponDepended(values)
end

function Calc.Explain_DependingStats(res, cur_values,stat)
    local values = Calc.Clear() + cur_values
    -- TODO: split explanations
    CP.Calc.DependingStats(values)
    AddDescription(res, CP.L.BY_CALC, values[stat]-cur_values[stat])
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

    local s = Calc.STATS
    local perc={
        [161]=s.STR,   -- "% Stärke"
        [162]=s.STA,   -- "% Ausdauer"
        [163]=s.INT,   -- "% Intelligenz"
        [164]=s.WIS,   -- "% Weisheit"
        [165]=s.DEX,   -- "% Geschicklichkeit"
        [166]={s.STR, s.STA, s.INT, s.WIS, s.DEX}, -- "% Alle Hauptattribute"
        [167]=s.HP,    -- "% LP-Maximums"
        [168]=s.MP,    -- "% MP-Maximums"
        [170]=s.MDEF,  -- "% Magische Verteidigung"
        [171]=s.MATK,  -- "% Magische Angriffskraft"
        [192]=s.MDMG,  -- "% magische Schadensrate"
        [199]=s.MACC,  -- "% Magische Präzision"
        [149]=s.MHEAL, -- "% Heilung"
        [135]=s.PDEF,  -- "% Verteidigung"
        [37]=s.PDMGOH, -- "% Nebenhand-Schadensrate"
        [36]=s.PACCOH, -- "% Nebenhand-Präzision"
        [52]=s.PDMGR,  -- "% Fernkampfwaffen-Schadensrate"
        [134]=s.PATK, -- "% physische Angriffe"
        [173]={s.PDMGMH, s.PDMGOH, s.PDMGR}, -- "% Schaden"
        [56] ={s.PDMGMH, s.PDMGOH}, -- "% Nahkampfwaffen-Schadensrate"
    }

    for p_stat,inc_stat in pairs(perc) do
        if values[p_stat]~=0 then
            local percent = 1 + values[p_stat]/100

            if type(inc_stat)=="table" then
                for _,i_stat in ipairs(inc_stat) do
                    values[i_stat] = math.floor(values[i_stat]*percent)
                end
            else
                values[inc_stat] = math.floor(values[inc_stat]*percent)
            end
        end
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
	values.PDMGOH= values.PDMGOH*0.7
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
   
   

function Calc.WeaponDepended(values)	
	local weapon={	
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
	for _,slot in ipairs( {10,15,16} ) do
        local item = CP.Items[slot]
		if item then
			local weapon_type = CP.DB.GetWeaponType(item.id) 		
			if slot== 10 then				
				values.PDMGR = values.PDMGR * (1+ values[weapon[weapon_type]]/100)
			elseif slot == 15 then			
				if weapon_type~=2 and weapon_type~=6 then					
						values.PDMGMH = values.PDMGMH * (1+ values[weapon[weapon_type]]/100)				
				else						
						values.MDMG = values.MDMG * (1+ values[weapon[weapon_type]]/100)
				end
				
			else
				if weapon_type~=2 then
					values.PDMGOH = values.PDMGOH * (1+ values[weapon[weapon_type]]/100)
				else
					values.MDMG = values.MDMG * (1+ values[weapon[weapon_type]]/100)
				end
			end	
            
		end
	end
	
end
function Calc.CharDepended(values)
    local cname = UnitClassToken("player")
    local d = CLASS_VARS[cname]

    values.PDEF = values.PDEF + values.STA* d.PDEF
    values.MDEF = values.MDEF + math.floor(values.WIS* d.MDEF)

    values.PATK = values.PATK + values.INT* d.PATKint
    values.PATK = values.PATK + values.DEX* d.PATKdex
    values.PATK = values.PATK + values.STR* d.PATKstr
end


