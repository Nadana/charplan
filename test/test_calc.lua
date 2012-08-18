TestCP_Calc={}


function TestCP_Calc:testSkillBonus()
    local s = CP.Calc.STATS

    TestCP_Calc:CheckSkill({[s.INT]=78}, {[490222]=0}, {[s.INT]=78+11}) -- Weisheit+0
    TestCP_Calc:CheckSkill({[s.INT]=78}, {[490222]=7}, {[s.INT]=78+18.9}) -- Weisheit+7
end

function TestCP_Calc:CheckSkill(base_val, skills, result)

    TestCP_Calc.cur_list_of_skills = skills
    CP.Calc.ReadSkills()

    local values = CP.Calc.NewStats()
    values = values + base_val
    values = values + CP.Calc.GetSkillBonus()
    CP.Calc.DependingStats(values)


    TestCP_Calc:CompareStats(values, result)
end

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

function TestCP_Calc.HOOKED_GetListOfSkills()
    return TestCP_Calc.cur_list_of_skills
end

function TestCP_Calc:CompareStats(actual, expected, msg, tolerance)
    tolerance = tolerance or 0.01
    for stat, value in pairs(expected) do
        if math.abs(1-value/actual[stat])*100>tolerance then
            assertEquals(actual[stat],value, stat.."/"..TEXT("SYS_WEAREQTYPE_"..stat)..": is "..actual[stat].." should "..value)
        end
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


function TestCP_Calc:classSetUp()

    self.old_unit={}
    CP.Unit.Store(self.old_unit)

    CP.Unit.class = "WARDEN"
    CP.Unit.sec_class = nil


    self.old_GetListOfSkills = CP.Calc.GetListOfSkills
    CP.Calc.GetListOfSkills = TestCP_Calc.HOOKED_GetListOfSkills

    CP.DB.Load()
end

function TestCP_Calc:classTearDown()

    CP.Unit.Load(self.old_unit)

    CP.Calc.GetListOfSkills = self.old_GetListOfSkills

    CP.Calc.Init()
    CP.DB.Release()
end