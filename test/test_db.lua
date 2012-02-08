
TestCP_DB={}

function TestCP_DB:classSetUp()
    CP.DB.Load()
end

function TestCP_DB:classTearDown()
    CP.DB.Release()
end


local function FindStat(txt)
    for id=510000,515000 do
        if TEXT("Sys"..id.."_name")==txt then return id end
    end
end

local function FindRune(txt)
    for id=520000,525000 do
        if TEXT("Sys"..id.."_name")==txt then return id end
    end
end

function TestCP_DB.testBonusInfos()
    assertEquals(GetLanguage(),"DE")

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
    assertEquals(GetLanguage(),"DE")

    assertEquals(CP.DB.FindBonus("Leben", "X", false), FindStat("Leben X")  )
    assertEquals(CP.DB.FindBonus("Leben", "X", true),  FindRune("Leben X") )
end


function TestCP_DB:testRomans()

    assertEquals(CP.DB.ToRoman(1),"I")
    assertEquals(CP.DB.ToRoman(3),"III")
    assertEquals(CP.DB.ToRoman(4),"IV")
    assertEquals(CP.DB.ToRoman(12),"XII")

    for i=1,105 do
        assertEquals(CP.DB.RomanToNum( CP.DB.ToRoman(i)), i)
    end
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

