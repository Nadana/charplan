
TestCP_DB={}

function TestCP_DB:classSetUp()
    CP.DB.Load()
end

function TestCP_DB:classTearDown()
    CP.DB.Release()
end


local function FindStat(txt)
    for id=510000,519999 do
        if TEXT("Sys"..id.."_name")==txt then return id end
    end
end

local function FindRune(txt)
    for id=520000,529999 do
        if TEXT("Sys"..id.."_name")==txt then return id end
    end
end

function TestCP_DB.testBonusInfos()
    if GetLanguage()~="DE" then return end

    local name, lvl, grp = CP.DB.GetBonusInfo( FindStat("Leben X") )
    assertEquals(name,"Leben")
    assertEquals(lvl,"X")
    assertFalse(CP.DB.IsRuneGroup(grp))

    name, lvl, grp = CP.DB.GetBonusInfo( FindRune("Leben X") )
    assertEquals(name,"Leben")
    assertEquals(lvl,"X")
    assertTrue(CP.DB.IsRuneGroup(grp))

end


function TestCP_DB.testBonusTextParser()
    if GetLanguage()~="DE" then return end

    assertEquals(CP.DB.FindBonus("Leben", "X", false), FindStat("Leben X")  )
    assertEquals(CP.DB.FindBonus("Leben", "X", true),  FindRune("Leben X") )
end


function TestCP_DB.testGetItemEffect()
    local effect = CP.DB.GetItemEffect(212485)
    assertArrayEquals(effect, {25,1159,6,80,12,483})
end

local CLASS_VAR=  {	-- outdated, use DB.classes
  ["WARRIOR"]={14,13,5,6,12,60,20,5,4.5,1.9,2.1,4.25,2,2,0.02,0.02,0.02,0.02,0.02,0.02,0.02,2,0,0,2.3},
  ["RANGER"]={11,10,10,9,13,60,20,3.85,3.65,3.6,3.4,4.5,2,2,0.02,0.02,0.02,0.02,0.02,0.02,0.02,1,0,1,1.8},
  ["THIEF"]={12,11,7,7,14,60,20,4.15,3.9,2.6,2.4,5,2,2,0.02,0.02,0.02,0.02,0.02,0.02,0.02,1.2,0,1.3,1.8},
  ["MAGE"]={5,9,14,12,10,60,20,1.9,3.4,5,4.25,3.5,2,2,0.02,0.02,0.02,0.02,0.02,0.02,0.02,0.8,0.5,0,1.5},
  ["AUGUR"]={7,10,13,14,10,60,20,2.5,3.6,4.5,5,3.5,2,2,0.02,0.02,0.02,0.02,0.02,0.02,0.02,0.8,0.5,0,1.5},
  ["KNIGHT"]={13,14,11,11,11,60,20,4.5,5,3.75,4.1,3.9,2,2,0.02,0.02,0.02,0.02,0.02,0.02,0.02,1.5,0.5,0,3},
  ["WARDEN"]={14,12,10,10,10,60,20,5,4.2,3.8,4,3.5,2,2,0.02,0.02,0.02,0.02,0.02,0.02,0.02,1.5,0.5,0,2},
  ["DRUID"]={7,11,13,13,10,60,20,2.5,3.7,4.5,4.9,3.65,2,2,0.02,0.02,0.02,0.02,0.02,0.02,0.02,0.8,0.5,0,1.5},
}

function TestCP_DB.testWarriorInfo()
    local effect = CP.DB.GetClassInfo('WARRIOR')
		table.remove(effect) -- rm mdef
    assertArrayEquals(effect, CLASS_VAR['WARRIOR'])
end

function TestCP_DB.testScoutInfo()
    local effect = CP.DB.GetClassInfo('RANGER')
		table.remove(effect)
    assertArrayEquals(effect, CLASS_VAR['RANGER'])
end

--[[
-- TODO: tests for
function DB.GetCardEffect(card_id)
function DB.GetSkillEffect(skill_id)
function DB.GetItemEffect(item_id)
function DB.GetItemUsualDropEffects(item_id)
function DB.GetBonusEffect(boni_id)
function DB.GetPlusEffect(item_id, plus)
function DB.GetItemIcon(item_id)
function DB.GetItemDura(item_id)
function DB.IsItemAllowedInSlot(item_id, slot)
function DB.GetItemPositions(item_id)
function DB.GetItemTypesForSlot(slot)
function DB.IsWeapon2Hand(item_id)
function DB.IsSlotType(slot_id)
function DB.GetBonusGroupList(runes, filter)
function DB.GetBonusGroupLevels(grp)
function DB.FindItems(filter_function)
function DB.GetItemInfo(item_id)
function DB.GenerateItemDataByID(item_id)
]]

