TestCP_Calc={}

function TestCP_Calc:testStats()
    local s = CP.Calc.STATS

    local a = CP.Calc.Clear()
    a.STR= 10
    assertEquals(a.STR, 10)
    a[2]=a[2]+10
    assertEquals(a.STR, 20)

    a.DEX=a.DEX+30
    assertEquals(a.STR, 20)
    assertEquals(a.DEX, 30)
end

