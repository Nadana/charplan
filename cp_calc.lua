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


local function ApplyBonus(stats, effect, factor)
    factor = factor or 1
    for i=1,#effect,2 do
        stats[effect[i]] = stats[effect[i]] + effect[i+1]
    end
end

local function AddStats(stats_res, stats)
    for id, val in pairs(stats or {}) do
        stats_res[id]=stats_res[id]+val
    end
end

function Calc.Clear()
    Calc.values={} -- TODO: remove Calc.values
    setmetatable(Calc.values, StatsMeta)
    return Calc.values
end


function Calc.ID2StatName(id)
    for n,v in pairs(Calc.STATS) do
        if id==v then return n end
    end
end

function Calc.Init()
    Calc.GetCardBonus()
end

function Calc.Release()
    Calc.CardsBonus=nil
end

function Calc.GetCardBonus()

    Calc.CardsBonus = Calc.Clear()
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

    local values = Calc.Clear()

    Calc.Bases(values)
    Calc.Cards(values)
    Calc.SetBonus(values)

	local temp_dmg = 0
	local temp_crit = 0
	for _,slot in ipairs( {0,1,2,3,4,5,6,7,8,9,11,12,13,14,21,10,15,16} ) do

        if CP.Items[slot] then
    		temp_dmg = values.PDMG
	    	temp_crit = values.PCRIT

			Calc.Item(values, CP.Items[slot])

            if slot==10 or slot==15 or slot==16 then
                if slot==10 then
                    values.PDMGR = values.PDMG
                    values.PCRITR= values.PCRIT
                end
                if slot==15 then
                    values.PDMGMH = values.PDMG
                    values.PCRITMH= values.PCRIT
                end
                if slot==16 then
                    values.PDMGOH = values.PDMG
                    values.PCRITOH= values.PCRIT
                end

                values.PDMG = temp_dmg
                values.PCRIT = temp_crit
            end
		end
	end

  	Calc.DependingStats(values)

    return Calc.values
end

local function AddDescription(res_tab, text,value, value_prefix)
    if value~=0 then
        table.insert(res_tab.left, text)
        value_prefix = value_prefix or "+"
        table.insert(res_tab.right,value_prefix..value)
    end
end

function Calc.Explain(stat)

    local res = {left={}, right={} }

    local values = Calc.Clear()
    Calc.Bases(values)
    AddDescription(res, CP.L.BY_CLASS, values[stat],"")

    Calc.Cards(values)
    AddDescription(res, CP.L.BY_CARD, Calc.CardsBonus[stat])

    values = Calc.Clear() -- << WRONG
    Calc.SetBonus(values)
    AddDescription(res, CP.L.BY_SET, values[stat])

	for _,slot in ipairs( {0,1,2,3,4,5,6,7,8,9,11,12,13,14,21,10,15,16} ) do
        local item = CP.Items[slot]
		if item then
            values = Calc.Clear()-- << WRONG
    		Calc.Item(values, item)
            AddDescription(res, TEXT("Sys"..item.id.."_name"), values[stat])
		end
	end

    Calc.Explain_DependingStats(res)
    return res.left,res.right
end

function Calc.Bases(values)

	--Base
    values.STR = GetPlayerAbility("STR")
    values.STA = GetPlayerAbility("STA")
    values.DEX = GetPlayerAbility("AGI")
    values.INT = GetPlayerAbility("INT")
    values.WIS = GetPlayerAbility("MND")

	--Melee
	values.PCRITOH = GetPlayerAbility("MELEE_CRITICAL")
	values.PCRITMH = GetPlayerAbility("MELEE_MAIN_CRITICAL")
	values.PCRITOH = GetPlayerAbility("MELEE_OFF_CRITICAL")
	values.PACCMH = GetPlayerAbility("PHYSICAL_MAIN_HIT")

	--Range
	values.PCRITR = GetPlayerAbility("RANGE_CRITICAL")

	--Magic
	values.MCRIT = GetPlayerAbility("MAGIC_CRITICAL")
end

function Calc.Cards(values)
    AddStats(values, Calc.CardsBonus)
end

function Calc.Item(values, item)

    local attA,attB = CP.DB.PrimarAttributes(item.id)
    local effect = CP.DB.GetItemEffect(item.id)
	local dura_factor = Calc.ItemDuraFactor(item)
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
end

function Calc.ItemDuraFactor(item)

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

function Calc.SetBonus(values)
    local sets={}

    for _,item in pairs(CP.Items) do
        local _,set_id = CP.DB.GetItemInfo(item.id)
        if set_id then
            sets[set_id]=(sets[set_id] or 0)+1
        end
    end

    for set_id,item_count in pairs(sets) do
        local eff = CP.DB.GetSetEffect(set_id, item_count)
        ApplyBonus(values, eff)
    end
end

function Calc.DependingStats(values)
    Calc.ALL_ATTRIBUTES(values)
    Calc.CharDepended(values)
    Calc.CharIndepended(values)
end

function Calc.Explain_DependingStats(res)
    local values = Calc.Clear()
    CP.Calc.ALL_ATTRIBUTES(values)
    AddDescription(res, TEXT("SYS_WEAREQTYPE_7"), values[stat])
end

function Calc.ALL_ATTRIBUTES(values)
    local all = values.ALL_ATTRIBUTES

    if all then
        values.STR = values.STR+all
        values.STA = values.STA+all
        values.DEX = values.DEX+all
        values.INT = values.INT+all
        values.WIS = values.WIS+all
    end
end

function Calc.CharIndepended(values)
    values.MATK = values.MATK + values.INT* 2
    values.EVADE= values.EVADE+ values.DEX* 0.78
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
	[C_AUGUR]  ={   PDEF=1.5, MDEF=3.2,
                    PATKint=0.5, PATKdex=0  ,PATKstr=0.8},
	[C_MAGE]   ={   PDEF=1.5, MDEF=3  ,
                    PATKint=0.5,PATKdex=0  ,PATKstr=0.8},
	[C_DRUID]  ={   PDEF=1.5, MDEF=3  ,
                    PATKint=0.5,PATKdex=0  ,PATKstr=0.8},
	[C_RANGER] ={   PDEF=1.8, MDEF=2.6,
                    PATKint=0  ,PATKdex=1  ,PATKstr=1  },
	[C_KNIGHT] ={   PDEF=3  , MDEF=2.4,
                    PATKint=0.5,PATKdex=0  ,PATKstr=1.5},
	[C_WARDEN] ={   PDEF=2  , MDEF=2.4,
                    PATKint=0.5,PATKdex=0  ,PATKstr=1.5},
	[C_THIEF]  ={   PDEF=1.8, MDEF=2.3,
                    PATKint=0  ,PATKdex=1.3,PATKstr=1.2},
    [C_WARRIOR]={   PDEF=2.3, MDEF=2.2,
                    PATKint=0  ,PATKdex=0  ,PATKstr=2  },
}

function Calc.CharDepended(values)
    local cname = UnitClass("player")
    local d = CLASS_VARS[cname]

    values.PDEF = values.PDEF + values.STA* d.PDEF
    values.MDEF = values.MDEF + values.WIS* d.MDEF

    values.PATK = values.PATK + values.INT* d.PATKint
    values.PATK = values.PATK + values.DEX* d.PATKdex
    values.PATK = values.PATK + values.STR* d.PATKstr
end


function Calc.CharacterSkills()

-- /run CP.Calc.CharacterSkills()

    CP.DB.Load()

    --for page=1,4 do
    for page=2,4 do

        local count = GetNumSkill( page )
        for index = 1,count do

            local _SkillName, _SkillLV, _IconPath, _Mode, _PLV, _PPoint, _PTotalPoint, _bLearned = GetSkillDetail( page,  index )

            local link = GetSkillHyperLink( page, index )
            local _type, _data, _name = ParseHyperlink(link)
            local _,_,skill_id = string.find(_data, "(%d+)")

            local effect = CP.DB.GetSkillEffect(tonumber(skill_id))
            if #effect>0 then
                local txt ={}
                for i=1,#effect,2  do
                    table.insert(txt,string.format("%i %s",effect[i+1],TEXT("SYS_WEAREQTYPE_"..effect[i])))
                end

                CP.Debug( string.format("%i %s(%i): %s",skill_id, _SkillName,_SkillLV,table.concat(txt,",")))
        end
    end
    end

    CP.DB.Release()

end

-----------------------------------------------------------
--[[
function UpdatePoints()

    info = SumOfAllItems()

	-- magie: Schaden, Kritisch, Heilbonus, Präzision



    -- Physische Verteidigung:
	pdef:SetText( CalcPdef(info) )				-- Physische Verteidigung
	par:SetText ( CalcPar(info) )				-- Parieren
	phyau:SetText( CalcPhyau(info) )			-- Physische Ausweichrate (Ausweichen)

	-- Magische Verteidigung:
	mdef:SetText( CalcMdef(info) )				-- Magische Verteidigung
	mwid:SetText( CalcMWid(info) )				-- Magischer Widerstand
	-- Magie:
	mdmg:SetText( CalcMdmg(info) )				-- Magischer Schaden
    matk:SetText( CalcMatk(info) )				-- Magischer Angriff
    mcrit:SetText( CalcMCrit(info))				-- Magische Kritische Trefferrate
    healb:SetText( CalcHealb(info))				-- Heilbonus
	mprae:SetText( CalcMPrae(info))				-- Magische Präzision

	-- Nahkampf:
	pdmghh:SetText( CalcPdmgHh(info))			-- Physischer Schaden Haupthand
	pdmgnh:SetText( CalcPdmgNh(info))			-- Physischer Schaden Nebenhand
	patk:SetText( CalcPatk(info) )				-- Physischer Angriff
	pcrithh:SetText( CalcPCritHh(info))			-- Physischer Kritische Trefferrate Haupthand
	pcritNh:SetText( CalcPCritNh(info))			-- Physischer Kritische Trefferrate Nebenhand
	ppraehh:SetText( CalcPPraeHh(info))			-- Physische Präzision Haupthand
	ppraeNh:SetText( CalcPPraeNh(info))			-- Physische Präzision Nebenhand
			-- Veränderung ??

	-- Fernkampf:
	pdmgfk:SetText( CalcPdmgFk(info))			-- Physischer Fernkampf-Schaden
	-- Fernkampf-Angriff = Nahkampf-Angriff
	pcritfk:SetText( CalcPCritFk(info))			-- Physische Kritische Trefferrate, Fernkampf
	-- Fernkampf-Präzision = Nahkampf-Präzision,Haupthand

	-- Anderes:
	manap:SetText( CalcManap(info))				-- Manapunkte
	--manareg:SetText( CalcManareg(info))			-- Manaregeneration
	lifep:SetText( CalcLifep(info))				-- Lebenspunkte
	--lifereg:SetText( CalcLifereg(info)) 		-- Lebensregeneration

end




function CalcPdmgHh(info)
        return (info.PDMGWHH + info.PDMG) --SKILLS?
end
function CalcPdmgNh(info)
        return ((info.PDMGWNH*0.7) + info.PDMG) --SKILLS?
end
function CalcPCritHh(info)
        return ((info.CRITE) + (info.CRITWHH))   --CRITE=Krit. von Items (Equip) ohne Runen von Waffen, CRITWHH=Krit. aus Haupthandwaffe inkl Rune
end
function CalcPCritNh(info)
        return ((info.CRITE) + (info.CRITWNH))
end

function CalcPPraeNh(info)
        return ((CalcPPraeHh(info)*0.5))  --Fehler bei Schurke
end

function CalcPdmgFk(info)
        return (info.PDMGFK + info.PDMG)
end
function CalcPCritFk(info)
        return ((info.CRITE) + (info.CRITWFK))    -- CRITWFK= Krit. von der Fernkamfwaffe, inklusive Rune
end


        Erläuterungen Variablen:
		Die Werte setzen sich aus den Char.Grundwerten und den Equip-Werten(inklusive Runen) zusammen (ggf. auch durch Perma-Skills)

		  CRITE = Krit. Trefferrate Equip
		CRITWFK = Krit. Trefferrate Fernkampfwaffe (Nonstat und Rune)
		CRITWHH = Krit. Trefferrate Haupthandwaffe (Nonstat und Rune)
		CRITWNH = Krit. Trefferrate Nebenhandwaffe (Nonstat und Rune)
		  MCRIT = mag. Kritische Trefferrate
		   MWID = mag. Widerstand
		   LIFE = Lebenspunkte
		   MANA = Manapunkte
		   PATK = Physischer Angriff
		   MATK = Magischer Angriff

		   MDMG = Magischer Schaden (Setzt sich aus Equip, mag. Schaden Runen und Haupt-und Nebenhand-Waffe zusammen)
		   PDMG = Physischer Schaden (Setzt sich aus Equip und Runen zusammen)
		   PDEF = Physische Verteidigung
		   MDEF = Magische Verteidigung
		    PAR = Parieren
		  PHYAU = Physische ausweichrate
		  PPRAE = phy. Präzision
		  MPRAE = mag. Präzision
		 PDMGHH = Physischer Schaden Haupthandwaffe
		 PDMGNH = Physischer Schaden Nebenhandwaffe
		 PDMGFK = Physischer Schaden Fernkampfwaffe


		]]--
