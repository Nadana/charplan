--[[
    CharPlan - DB - Spell
]]

local CP = _G.CP
local DB = CP.DB

--[[ [ DataBase Format ]]
    -- Spells
    local S_EFFECT=1
    local S_ICON=2
    local S_SPELL_EFFECTS=3
    local S_MAX_SKILL=4
    local S_TP_RATE=5

    -- Spell-Effect
    local SE_SKILL_VARG=1
    local SE_BUFFS=2
    local SE_TIME=3
    local SE_TIME_VARG=4
    local SE_ATK_DMG=5
    local SE_ATK_VARG=6
    local SE_ATK_DMG_FIX=7
    local SE_DOT_DMG=8
    local SE_DOT_VARG=9
--[[ ] ]]



function DB.GetSpellEffectList(skill_id)
    local sp = DB.skills[skill_id] and DB.skills[skill_id][S_SPELL_EFFECTS]

    if type(sp)=="number" then
        return {sp}
    elseif type(sp)~="table" then
        CP.Debug("!no skill: "..skill_id)
        return {}
    end

    return sp
end

function DB.GetSpellEffect(spell_id)
    local boni = DB.spell_effects[spell_id]
    if boni then
        return boni[SE_SKILL_VARG],boni[SE_BUFFS] or {}
    end
end

--  2=passive
function DB.GetSpellType(spell_id)
    return DB.skills[spell_id] and DB.skills[spell_id][S_EFFECT]
end

function DB.IsSpellPassive(spell_id)
    return DB.GetSpellType(spell_id)==2
end

function DB.GetSpellIcon(spell_id)
    local icon_id = DB.skills[spell_id] and DB.skills[spell_id][S_ICON]
    if icon_id then
        return DB.GetIcon(icon_id)
    else
        CP.Debug("No Icon for spell "..spell_id)
    end
end

function DB.GetSpellBuffValue(spell_id,index1,index2,level)
    local spell = DB.GetSpellEffectList(spell_id)[index1+1]
    if not spell then
        CP.Debug("no sub effect: "..spell_id.."/"..index1)
        return 0
    end

    return DB.GetSpellEffectBuffValue(spell,index2,level)
end

function DB.GetSpellEffectBuffValue(spell_effect_id,index,level)
    local skill_arg, effects = CP.DB.GetSpellEffect(spell_effect_id)
    if skill_arg then
        local ev = effects[index*2+2]
        if ev then
            local val = (skill_arg*level+100) * ev / 100
            val = math.floor(val*10+0.5)/10

            return val
        end
    end
end

function DB.GetSpellDmgValue(spell_id,index,level)
    local spell = DB.GetSpellEffectList(spell_id)[index+1]
    if not spell then
        CP.Debug("no sub effect: "..spell_id.."/"..index)
        return 0
    end

    local eff = DB.spell_effects[spell]
    if eff then
        local val = ( (eff[SE_ATK_VARG] or 0)*level+100) * (eff[SE_ATK_DMG] or 0) / 100
        val = math.floor(val*10+0.5)/10

        return val, eff[SE_ATK_DMG_FIX] or 0
    end
end

function DB.GetSpellFixDmgValue(spell_eff_id)
    local eff = DB.spell_effects[spell_eff_id]
    if eff then
        return eff[SE_ATK_DMG_FIX] or 0
    end
end

function DB.GetSpellTimeValue(spell_id,index,level)
    local spell_effect_id = DB.GetSpellEffectList(spell_id)[index+1]
    if not spell_effect_id then
        CP.Debug("no sub effect: "..spell_id.."/"..index)
        return 0
    end

    return DB.GetSpellEffectTimeValue(spell_effect_id,level)
end

function DB.GetSpellEffectTimeValue(spell_effect_id,level)
    local eff = DB.spell_effects[spell_effect_id]
    if eff then
        if eff[SE_TIME_VARG] then
            local val = (eff[SE_TIME_VARG]*level+100) * eff[SE_TIME] / 100
            val = math.floor(val*10+0.5)/10
            return val
        else
            return eff[SE_TIME]
        end
    end
end

function DB.GetSpellDotValue(spell_id,index,level)
    local spell_effect_id = DB.GetSpellEffectList(spell_id)[index+1]
    if not spell_effect_id then
        CP.Debug("no sub effect: "..spell_id.."/"..index)
        return 0
    end

    return DB.GetSpellEffectDotValue(spell_effect_id,level)
end

function DB.GetSpellEffectDotValue(spell_effect_id,level)
    local eff = DB.spell_effects[spell_effect_id]
    if eff then
        if eff[SE_DOT_VARG] then
            local val = ( eff[SE_DOT_VARG]*level+100) * eff[SE_DOT_DMG] / 100
            val = math.floor(val*10+0.5)/10
            return val
        else
            return eff[SE_DOT_DMG]
        end
    end
end

function DB.GetSpellDesc(spell_id,level, var_color_code)

    local function colored(text)
        if var_color_code and text then
            return var_color_code .. text .. "|r"
        else
            return text
        end
    end

    local function SpellBuff(token)

        local i1,val,ispell = string.match(token,"(%d*)%-?([^%-]*)%-?(%d*)")
        i1 = tonumber(i1) or 0

        ispell = tonumber(ispell)
        if not ispell then
            ispell = DB.GetSpellEffectList(spell_id)[i1+1]
        end

        if val=="Time" then
            return colored(DB.GetSpellEffectTimeValue(ispell,level))
        elseif val=="Dot" then
            return colored(DB.GetSpellEffectDotValue(ispell,level))
        else
            val = tonumber(val)
            if val then
                if val>20 then
                    return colored(math.abs(DB.GetSpellEffectBuffValue(val,i1,level) or 0))
                else
                    return colored(DB.GetSpellEffectBuffValue(ispell,val,level))
                end
            end
        end

        return "Buff"..token
    end

    local function SpellDmg(token)

        local i1 = tonumber(token)
        i1 = i1 or 0

        return colored(math.abs(DB.GetSpellDmgValue(spell_id,i1,level)))
    end

    local function SpellFixDmg(token)

        local i1 = tonumber(token)
        if i1 then
            return math.abs(DB.GetSpellFixDmgValue(i1) or 0)
        end
        return "FixDMG-"..token
    end

    local desc = TEXT("Sys"..spell_id.."_shortnote")

    desc = string.gsub(desc,"%(Buff(.-)%)", function (x) return SpellBuff(x) end )
    desc = string.gsub(desc,"%(DMG(.-)%)", function (x) return SpellDmg(x) end )
    desc = string.gsub(desc,"%(FixDMG%-(.-)%)", function (x) return SpellFixDmg(x) end )
    desc = string.gsub(desc,"%(Max%-BuffTime.-%)", function (x) return "___" end )

    desc = string.gsub(desc,"%[.-|(.-)%]", function (x) return x end )
    desc = string.gsub(desc,"%[(.-)%]", function (x)
        if tonumber(x) then
            return TEXT("Sys"..x.."_name")
        end
        return TEXT(x)
        end )
    desc = string.gsub(desc,"<CM>", "|cff770dd0")
    desc = string.gsub(desc,"</CM>", "|r")

    return desc
end

function DB.GetSkillList(token_id,line)
    local learn = CP.DB.learn[token_id]
    if not learn then return {} end

    assert(line==1 or line==2)
    return learn[line]
end
