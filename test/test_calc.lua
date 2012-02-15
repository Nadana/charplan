TestCP_Calc={}

function TestCP_Calc:testStats()

    local a= CP.Calc.NewStats()
    a.STR= 10
    assertEquals(a.STR, 10)
    a[2]=a[2]+10
    assertEquals(a.STR, 20)

    a.DEX=a.DEX+30
    assertEquals(a.STR, 20)
    assertEquals(a.DEX, 30)

    local b= CP.Calc.NewStats()
    b.STR=5
    b.INT=5

    local c = a+b
    assertEquals(c.STR, 25)
    assertEquals(c.DEX, 30)
    assertEquals(c.INT, 5)
end

