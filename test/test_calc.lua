TestCP_Calc={}


function TestCP_Calc:testItemCalc()
    local s = CP.Calc.STATS

    TestCP_Calc.CheckItemPlusGrad(211540, 100,0, 0, {[s.PDMG]=285, [s.MDMG]=150, [s.STR]=17})
    TestCP_Calc.CheckItemPlusGrad(211540, 100,1, 0, {[s.PDMG]=289, [s.MDMG]=150, [s.STR]=17, [s.PATK]=20})
    TestCP_Calc.CheckItemPlusGrad(211540, 100,2, 0, {[s.PDMG]=293, [s.MDMG]=150, [s.STR]=17, [s.PATK]=35})
    TestCP_Calc.CheckItemPlusGrad(211540, 100,0, 1, {[s.PDMG]=313.5,[s.MDMG]=165, [s.STR]=17})
    TestCP_Calc.CheckItemPlusGrad(211540, 100,0, 2, {[s.PDMG]=342, [s.MDMG]=180, [s.STR]=17})
	TestCP_Calc.CheckItemPlusGrad(212615, 100,0, 0, {[s.PDMG]=2288, [s.PATK]=976})	
	TestCP_Calc.CheckItemPlusGrad(212615, 100,1, 0, {[s.PDMG]=2332, [s.PATK]=1016})
	TestCP_Calc.CheckItemPlusGrad(212615, 100,2, 0, {[s.PDMG]=2378, [s.PATK]=1056})		
	TestCP_Calc.CheckItemPlusGrad(212615, 100,0, 1, {[s.PDMG]=2516.8, [s.PATK]=1073.6})
	TestCP_Calc.CheckItemPlusGrad(212615, 100,0, 2, {[s.PDMG]=2745.6, [s.PATK]=1172.2})
	TestCP_Calc.CheckItemPlusGrad(212615, 100,1, 1, {[s.PDMG]=2560.8, [s.PATK]=1113.6})
end



function TestCP_Calc.CheckItemPlusGrad(item_id, dura_percent, plus, tier, stats)
    local item = CP.DB.GenerateItemDataByID(item_id)
    item.dura = item.dura * dura_percent / 100
    item.plus = plus or 0
    item.tier = tier or 0

    local result = {}
    CP.Calc.desc = {}
    CP.Calc.values = result
    CP.Calc.Clear()
    CP.Calc.Item(item)
    CP.Calc.ItemStats(item)
    CP.Calc.ItemRunes(item)

    for stat, value in pairs(stats) do
        assertEquals(result[stat],value, "Item: "..item_id)
    end
end


function TestCP_Calc:classSetUp()
    CP.DB.Load()
end


function TestCP_Calc:classTearDown()
    CP.DB.Release()
end