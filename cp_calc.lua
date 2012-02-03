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

    Calc.CardsBonus={}
    for i = 0,15 do
        local count = LuaFunc_GetCardMaxCount(i)
        for j =0, count do
            local id, own = LuaFunc_GetCardInfo(i , j)
            if (own or 0)>0 then
                local effect, effvalues  = CP.DB.GetCardEffect(id)
                for i, ef in ipairs(effect or {}) do
                    Calc.CardsBonus[ef] = (Calc.CardsBonus[ef] or 0) + effvalues[i]
                end
            end
        end
    end

end


local function AddDesciption(id, left, right)
    Calc.desc[id] = Calc.desc[id] or {left={},right={}}
    table.insert(Calc.desc[id].left, left or "")
    table.insert(Calc.desc[id].right, right or "")
end

local function AddValue(id, value, text)
    if value == 0 then return end
    Calc.values[id] = (Calc.values[id] or 0) + value
    AddDesciption(id, text, string.format("+%i",value))
end

local function AddBonusEffect(effect, effvalues, text, factor)
	for i, ef in ipairs(effect or {}) do
        AddValue(ef, effvalues[i]*factor, text)
    end
end

function Calc.RecalcPoints(values, descriptions)
    local s = Calc.STATS
	
    Calc.values = values
    Calc.desc = descriptions

    Calc.Clear()

    Calc.Bases()
    Calc.Cards()

	for _,slot in ipairs( {0,1,2,3,4,5,6,7,8,9,11,12,13,14,21} ) do 
		if CP.Items[slot] then
			Calc.Item(CP.Items[slot])
			Calc.ItemStats(CP.Items[slot])
			Calc.ItemRunes(CP.Items[slot])
		end
	end
	for _,slot in ipairs( {10,15,16} ) do
		local temp_dmg = 0
		local temp_crit = 0
		if CP.Items[slot] then	
			temp_dmg = Calc.values[s.PDMG]
			temp_crit = Calc.values[s.PCRIT]
			
			Calc.Item(CP.Items[slot])        
			Calc.ItemStats(CP.Items[slot])
			Calc.ItemRunes(CP.Items[slot])
			
			
			
			if slot==10 then
				Calc.values[s.PDMGR] = Calc.values[s.PDMG] 			
				Calc.values[s.PCRITR] = Calc.values[s.PCRIT]
			end
			if slot==15 then
				Calc.values[s.PDMGMH] = Calc.values[s.PDMG]			
				Calc.values[s.PCRITMH] = Calc.values[s.PCRIT] 			
			end
			if slot==16 then
				Calc.values[s.PDMGOH] = Calc.values[s.PDMG] 			
				Calc.values[s.PCRITOH] = Calc.values[s.PCRIT] 			
			end	
			Calc.values[s.PDMG] = temp_dmg
			Calc.values[s.PCRIT] = temp_crit
		end
	end
    CP.Calc.ALL_ATTRIBUTES()
	
	Calc.CharDepended()
    Calc.CharIndepended()
    
end
function Calc.Clear()
    for _,id in pairs(Calc.STATS) do
        Calc.values[id]=0
        Calc.desc[id] = {left={},right={}}
    end
end


function Calc.Bases()
    local s = Calc.STATS
    Calc.values[s.STR] = GetPlayerAbility("STR")
    Calc.values[s.STA] = GetPlayerAbility("STA")
    Calc.values[s.DEX] = GetPlayerAbility("AGI")
    Calc.values[s.INT] = GetPlayerAbility("INT")
    Calc.values[s.WIS] = GetPlayerAbility("MND")

    AddDesciption(s.STR, CP.L.STAT_NAMES.STR, tostring(Calc.values[s.STR]))
    AddDesciption(s.STA, CP.L.STAT_NAMES.STA, tostring(Calc.values[s.STA]))
    AddDesciption(s.DEX, CP.L.STAT_NAMES.DEX, tostring(Calc.values[s.DEX]))
    AddDesciption(s.INT, CP.L.STAT_NAMES.INT, tostring(Calc.values[s.INT]))
    AddDesciption(s.WIS, CP.L.STAT_NAMES.WIS, tostring(Calc.values[s.WIS]))
end

function Calc.Cards()
    for id, val in pairs(Calc.CardsBonus or {}) do
        AddValue(id, val, CP.L.BY_CARD)
    end
end

function Calc.Item(item)
    local s = Calc.STATS

    local name = TEXT("Sys"..item.id.."_name")

    local factor1 = 1+item.tier*0.1
	local factor = 1

    local max_dura = CP.DB.GetItemDura(item.id) * item.max_dura / 100

	if (item.dura > 100) or (item.dura > max_dura) then
		factor1 = factor1*1.2
		factor = 1.2
	elseif item.dura <= max_dura/5 then
		factor1 = factor1*0.2
		factor = 0.2
	elseif item.dura <= max_dura/2 then
		factor1 = factor1*0.8
		factor = 0.8

	end

    local effect, effvalues  = CP.DB.GetItemEffect(item.id)
    for i, ef in ipairs(effect or {}) do
            AddValue(ef, effvalues[i]*factor1, "B "..name)
    end

    if item.plus>0 then
        effect, effvalues  = CP.DB.GetPlusEffect(item.id, item.plus)
        AddBonusEffect(effect, effvalues, "P "..name, factor)
    end
end


function Calc.ItemStats(item)
    local s = Calc.STATS

    local name = TEXT("Sys"..item.id.."_name")
	local factor = 1
	if (item.dura > 100) or (item.dura > item.max_dura) then
		factor = 1.2
	elseif item.dura <= item.max_dura/5 then
		factor = 0.2
	elseif item.dura <= item.max_dura/2 then
		factor = 0.8

	end
    for i=1,6 do
        if item.stats[i]>0 then
            local effect, effvalues  = CP.DB.GetBonusEffect(item.stats[i])
            AddBonusEffect(effect, effvalues, "S "..name, factor)
        end
    end
end

function Calc.ItemRunes(item)
   local s = Calc.STATS

    local name = TEXT("Sys"..item.id.."_name")
	local factor = 1
	if (item.dura > 100) or (item.dura > item.max_dura) then
		factor = 1.2
	elseif item.dura <= item.max_dura/5 then
		factor = 0.2
	elseif item.dura <= item.max_dura/2 then
		factor = 0.8

	end
    for i=1,4 do
        if item.runes[i]>0 then
            local effect, effvalues  = CP.DB.GetBonusEffect(item.runes[i])
            AddBonusEffect(effect, effvalues, "R "..name, factor)
        end
    end
end

function Calc.ALL_ATTRIBUTES()
    local s = Calc.STATS
    local all = Calc.values[s.ALL_ATTRIBUTES]

    if all then
        AddValue(s.STR, all, TEXT("SYS_WEAREQTYPE_7"))
        AddValue(s.STA, all, TEXT("SYS_WEAREQTYPE_7"))
        AddValue(s.DEX, all, TEXT("SYS_WEAREQTYPE_7"))
        AddValue(s.INT, all, TEXT("SYS_WEAREQTYPE_7"))
        AddValue(s.WIS, all, TEXT("SYS_WEAREQTYPE_7"))
    end
end


function Calc.CharSkills()
    -- TODO: Krieger -> Brutale Kraft
end

function Calc.CharIndepended()
    local s = Calc.STATS

    AddValue(s.MATK, Calc.values[s.INT]* 2   ,CP.L.STAT_NAMES.INT)
    AddValue(s.EVADE,Calc.values[s.DEX]* 0.78,CP.L.STAT_NAMES.DEX)
    AddValue(s.MRES, Calc.values[s.WIS]* 0.6 ,CP.L.STAT_NAMES.WIS)
    AddValue(s.MACC, Calc.values[s.WIS]* 0.9 ,CP.L.STAT_NAMES.WIS)
    AddValue(s.PACC, Calc.values[s.DEX]* 0.9 ,CP.L.STAT_NAMES.DEX)
    AddValue(s.MHEAL,Calc.values[s.MDMG]*0.5 ,CP.L.STAT_NAMES.MDMG)

	AddValue(s.PACCR,Calc.values[s.PACC]*1 ,CP.L.STAT_NAMES.PACCR)
	AddValue(s.PACCOH,Calc.values[s.PACC]*0.5 ,CP.L.STAT_NAMES.PACCOH)
	AddValue(s.PDMGOH,Calc.values[s.PDMGOH]*0.7,CP.L.STAT_NAMES.PDMGOH)
	AddValue(s.PATKR,Calc.values[s.PATK]* 1 ,CP.L.STAT_NAMES.PATKR)
	
    AddValue(s.HP,   Calc.values[s.STA]* 5   ,CP.L.STAT_NAMES.STA)
    AddValue(s.HP,   Calc.values[s.STR]* 0.2 ,CP.L.STAT_NAMES.STR)

    AddValue(s.MANA, Calc.values[s.WIS]* 5   ,CP.L.STAT_NAMES.WIS)
    AddValue(s.MANA, Calc.values[s.INT]* 1   ,CP.L.STAT_NAMES.INT)
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

function Calc.CharDepended()
    local cname = UnitClass("player")
    local d = CLASS_VARS[cname]
    local s = Calc.STATS

    AddValue(s.PDEF, Calc.values[s.STA]* d.PDEF   ,CP.L.STAT_NAMES.STA)
    AddValue(s.MDEF, Calc.values[s.WIS]* d.MDEF   ,CP.L.STAT_NAMES.WIS)

    AddValue(s.PATK, Calc.values[s.INT]* d.PATKint,CP.L.STAT_NAMES.INT)
    AddValue(s.PATK, Calc.values[s.DEX]* d.PATKdex,CP.L.STAT_NAMES.DEX)
    AddValue(s.PATK, Calc.values[s.STR]* d.PATKstr,CP.L.STAT_NAMES.STR)

end




function Calc.CharacterSkills()

    for page=1,4 do

        local count = GetNumSkill( page )
        for index = 1,count do

            local _SkillName, _SkillLV, _IconPath, _Mode, _PLV, _PPoint, _PTotalPoint, _bLearned = GetSkillDetail( page,  index )

            local link = GetSkillHyperLink( page, index )
            local _type, _data, _name = ParseHyperlink(link)
            local _,_,skill_id = string.find(_data, "(%x+)")
            skill_id =  tonumber(skill_id, 16)

            CP.Debug(string.format("%i %i %s",skill_id, _SkillLV, _SkillName))
        end
    end

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
