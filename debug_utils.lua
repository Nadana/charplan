
function CP.SlashCMD(msg)
    if string.find(msg,"^t") then
        CP.SlashCMD_Test()
    elseif string.find(msg,"^r") then
        CP.SlashCMD_Reload()
    elseif string.find(msg,"^s") then
        CP.SlashCMD_SnapShot()
    else
CP.Output([[Charplan Debug Tool
Usage: /cp <command>
command:
 t / test  -> run test
 r / reload-> reload CharPlan files (not complet)
 s / snapshot -> take snapshot of current char for test run]])
    end
end

function CP.InitialTest()
    dofile("interface/addons/charplan/test/luaunit.lua")
    dofile("interface/addons/charplan/test/test.lua")
end

function CP.SlashCMD_Test()
    dofile("interface/addons/charplan/test/luaunit.lua")
    UnitResult.verbosity=1
    dofile("interface/addons/charplan/test/test.lua")
end


function CP.SlashCMD_Reload()
    local temp_storage = CP_Storage
    local temp_ebuttons = CP.EquipButtons

    CPFrame:Hide()
    local base = "interface/addons/charplan/"
    --dofile(base.."charplan.lua")
    dofile(base.."cp_calc.lua")
    dofile(base.."cp_db.lua")
    --dofile(base.."cp_pimpme.lua")
    dofile(base.."cp_search.lua")
    dofile(base.."cp_storage.lua")
    dofile(base.."cp_utils.lua")
    dofile(base.."debug_utils.lua")

    CP_Storage = temp_storage
    CP.EquipButtons = temp_ebuttons
    DEFAULT_CHAT_FRAME:AddMessage("CP: RELOADED",1,0.5,0.5)
end

local function GetCurrentStats()
    local s = CP.Calc.STATS

    local function GetOri(txt)
        local b,e = GetPlayerAbility(txt)
        return b+e
    end

    local mana = UnitMaxMana("player")
    if mana==100 then mana = UnitMaxSkill("player") end

    return
    {
        --Base
        [s.STR] = GetOri("STR"),
        [s.STA] = GetOri("STA"),
        [s.DEX] = GetOri("AGI"),
        [s.INT] = GetOri("INT"),
        [s.WIS] = GetOri("MND"),
        [s.HP] = UnitMaxHealth("player"),
        [s.MANA] = mana,

	    --Melee
        [s.PATK] =  GetOri("MELEE_ATTACK"),
        [s.PDEF] = GetOri("PHYSICAL_DEFENCE"),
	    [s.PCRITOH] = GetOri("MELEE_CRITICAL"),
	    [s.PCRITMH] = GetOri("MELEE_MAIN_CRITICAL"),
	    [s.PCRITOH] = GetOri("MELEE_OFF_CRITICAL"),
	    [s.PACCMH] = GetOri("PHYSICAL_MAIN_HIT"),
        [s.PARRY]= GetOri("PHYSICAL_PARRY"),
        [s.EVADE] = GetOri("PHYSICAL_DODGE"),

	    --Range
	    [s.PCRITR] = GetOri("RANGE_CRITICAL"),

	    --Magic
        [s.MATK] =  GetOri("MAGIC_ATTACK"),
	    [s.MCRIT] = GetOri("MAGIC_CRITICAL"),
        [s.MDEF] = GetOri("MAGIC_DEFENCE"),

--[[
GetOri("MELEE_MAIN_DAMAGE")
GetOri("RANGE_ATTACK")
GetOri("RANGE_DAMAGE")
GetOri("PHYSICAL_HIT_RATE")
GetOri("MAGIC_DAMAGE")
GetOri("MAGIC_HEAL")
GetOri("MAGIC_HIT")
GetOri("PHYSICAL_RESIST_CRITICAL")
GetOri("MAGIC_DODGE")
GetOri("MAGIC_RESIST_CRITICAL")
]]
    }
end


local function GetCurrentCPItems()
    local item_links ={}
    for _,item in pairs(CP.Items) do
        local lnk = CP.Pimp.GenerateLink(item)
        table.insert(item_links, lnk)
    end
    if #item_links<1 then
        CP.Output("WARN: no equipment!")
    end

    return item_links
end

function CP.SlashCMD_SnapShot()
    SaveVariables("CP_FullCharInfo")

    local buff = UnitBuff("player",1)
    if buff then
        CP.Output("|cffff0000!!You have to remove all buffs before doing a snapshot !!")
    end

    CP.Calc.ReadCards()

    CP_FullCharInfo = {}
    CP_FullCharInfo.level, CP_FullCharInfo.sec_level=UnitLevel("player")
    CP_FullCharInfo.class, CP_FullCharInfo.sec_class=UnitClassToken("player")
    CP_FullCharInfo.bases=CP.Calc.GetBases()
    CP_FullCharInfo.cards=CP.Calc.GetCardBonus()
    CP_FullCharInfo.title=GetCurrentTitle()
    CP_FullCharInfo.item_links=GetCurrentCPItems()
    CP_FullCharInfo.skills=CP.Calc.GetListOfSkills()

    CP_FullCharInfo.result =GetCurrentStats()


    CP.Output("-> Equipment from Charplan is used.")
    CP.Output("-> 'CP_FullCharInfo' will be written to savevarialbes.lua. Copy and use it in test_calc_full.lua!")
end

function CP.DumpCharacterSkills()

-- /run CP.DumpCharacterSkills()

    CP.DB.Load()

    --for page=1,4 do
    for page=2,4 do

        local count = GetNumSkill( page ) or 0
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

                CP.Debug( string.format("%i %s(%i): %s",skill_id, _SkillName,_PLV,table.concat(txt,",")))
            --else
            --    CP.Debug( string.format("%i %s(%i)",skill_id, _SkillName,_PLV))
            end
        end
    end

    CP.DB.Release()

end

function CP.DumpCharacterTitles()

-- /run CP.DumpCharacterTitles()
    -- only titles with bonus

    CP.DB.Load()

    local count = GetTitleCount()
    for i = 1 , count do
		local name, titleID, geted, icon,classify1, classify2,note,brief,rare = GetTitleInfoByIndex( i - 1 )
        if geted then
            local v = CP.DB.GetArchievementEffect(titel_id)
            if #v>0 then
                CP.Debug(name)
            end
        end
    end

    CP.DB.Release()

end

