
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



