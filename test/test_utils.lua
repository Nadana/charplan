
TestCP_Utils={}

function TestCP_Utils:testRomans()

    assertEquals(CP.Utils.ToRoman(1),"I")
    assertEquals(CP.Utils.ToRoman(3),"III")
    assertEquals(CP.Utils.ToRoman(4),"IV")
    assertEquals(CP.Utils.ToRoman(12),"XII")

    for i=1,105 do
        assertEquals(CP.Utils.RomanToNum( CP.Utils.ToRoman(i)), i)
    end
end

function TestCP_Utils:testTableCopy()
    local a = {"a","b","c","d","e"}
    local b = {"f","g","h","i"}
    c = CP.Utils.TableCopy(a)
    assertArrayEquals(c,a)
    CP.Utils.TableCopy(b,c)
    assertArrayEquals(c,b)
end
