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


function TestCP_Calc:CompareStats(actual, expected, msg)

    for stat, value in pairs(expected) do
        local act = actual[stat]
        local round = math.floor(act*10)/10
        assertEquals(round,value, msg)
    end
end

function TestCP_Calc:CompareStatsComplete(actual, expected, msg)

    for stat, value in pairs(expected) do
        local act = actual[stat] or 0
        local round = math.floor(act*10)/10
        assertEquals(round,value, msg)
    end

    for stat, value in pairs(actual) do
        local ex = expected[stat] or 0
        local round = math.floor(value*10)/10
        assertEquals(round, ex, msg)
    end
end
