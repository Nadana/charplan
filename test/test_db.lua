
TestCP_DB={}

function TestCP_DB:classSetUp()
    Charplan.DB.Load()
end

function TestCP_DB:classTearDown()
    Charplan.DB.Release()
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

    local name, lvl, grp = Charplan.DB.GetBonusInfo( FindStat("Leben X") )
    assertEquals(name,"Leben")
    assertEquals(lvl,"X")
    assertFalse(Charplan.DB.IsRuneGroup(grp))

    name, lvl, grp = Charplan.DB.GetBonusInfo( FindRune("Leben X") )
    assertEquals(name,"Leben")
    assertEquals(lvl,"X")
    assertTrue(Charplan.DB.IsRuneGroup(grp))

end


function TestCP_DB.testBonusTextParser()
    if GetLanguage()~="DE" then return end

    assertEquals(Charplan.DB.FindBonus("Leben", "X", false), FindStat("Leben X")  )
    assertEquals(Charplan.DB.FindBonus("Leben", "X", true),  FindRune("Leben X") )
end


function TestCP_DB.testGetItemEffect()
    local effect = Charplan.DB.GetItemEffect(212485)
    assertArrayEquals(effect, {25,1159,6,80,12,483})
end



