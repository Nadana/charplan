
local path = 'interface/addons/charplan/test/'

dofile(path..'test_pimp.lua')



TestBases={}


function TestBases:testRomans()

    assertEquals(CP.DB.ToRoman(1),"I")
    assertEquals(CP.DB.ToRoman(3),"III")
    assertEquals(CP.DB.ToRoman(4),"IV")
    assertEquals(CP.DB.ToRoman(12),"XII")

    for i=1,105 do
        assertEquals(CP.DB.RomanToNum( CP.DB.ToRoman(i)), i)
    end

end




LuaUnit:run()
