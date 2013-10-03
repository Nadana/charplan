
TestCP_Utils={}

function TestCP_Utils:testRomans()

    assertEquals(Charplan.Utils.ToRoman(1),"I")
    assertEquals(Charplan.Utils.ToRoman(3),"III")
    assertEquals(Charplan.Utils.ToRoman(4),"IV")
    assertEquals(Charplan.Utils.ToRoman(12),"XII")

    for i=1,105 do
        assertEquals(Charplan.Utils.RomanToNum( Charplan.Utils.ToRoman(i)), i)
    end
end

function TestCP_Utils:testTableCopy()
    local a = {"a","b","c","d","e"}
    local b = {"f","g","h","i"}
    c = Charplan.Utils.TableCopy(a)
    assertArrayEquals(c,a)
    Charplan.Utils.TableCopy(b,c)
    assertArrayEquals(c,b)
end

