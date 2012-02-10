TestCP_Calc={}


function TestCP_Calc:testItemCalc_ID_212485()
    local s = CP.Calc.STATS

    -- http://de.runesdatabase.com/item/212485
    local item = CP.DB.GenerateItemDataByID(212485)
    TestCP_Calc.CheckItem(item, {[s.PDMG]=1159})
    TestCP_Calc.CheckPlus(item, s.PDMG, {1182,1205,1228,1251,1274,1309,1344,1379,1413,1448,1483,1541,1599,1657,1715,1831})
    TestCP_Calc.CheckTier(item, s.PDMG, {1274.9,1390.8,1506.7,1622.6,1738.5})
--~     item.tier=1
--~     TestCP_Calc.CheckPlus(item, s.PDMG, {
--~         [1]=1297.9, -- 1300.2
--~         [2]=1320.9, -- 1325.5
--~         [3]=1343.9, -- 1350.8
--~         [4]=1366.9, -- 1376.1
--~         [5]=1389.9, -- 1401.4
--~         [6]=1424.9  -- 1439.9
--~         })
--~     item.plus=1
--~     TestCP_Calc.CheckTier(item, s.PDMG, {
--~         [1]=1297.9, -- 1300.2
--~         [2]=1413.8, -- 1418.3
--~         [3]=1529.7, -- 1536.6
--~         [4]=1645.6, -- 1654.8
--~         [5]=1761.5, -- 1773
--~         [6]=1877.4  -- 1891,2
--~         })
    --TestCP_Calc.CheckPlus(item, s.PDMG, {1297.9, 1320.9, 1343.9, 1366.9, 1389.9, 1424.9})
    --TestCP_Calc.CheckItemPlusGrad(212485, 100,10,10,{[s.PDMG]=2607})
end


function TestCP_Calc:testItemCalc_with_BasePLUS()
    local s = CP.Calc.STATS

    -- http://de.runesdatabase.com/item/212615
	TestCP_Calc.CheckItemPlusGrad(212615, 100,0, 0, {[s.PDMG]=2288, [s.PATK]=976})
	TestCP_Calc.CheckItemPlusGrad(212615, 100,1, 0, {[s.PDMG]=2332, [s.PATK]=1016})
	TestCP_Calc.CheckItemPlusGrad(212615, 100,2, 0, {[s.PDMG]=2378, [s.PATK]=1056})
--~ 	TestCP_Calc.CheckItemPlusGrad(212615, 100,0, 1, {[s.PDMG]=2516.8, [s.PATK]=1073.6})
--~ 	TestCP_Calc.CheckItemPlusGrad(212615, 100,0, 2, {[s.PDMG]=2745.6, [s.PATK]=1171.2})
--~ 	TestCP_Calc.CheckItemPlusGrad(212615, 100,1, 1, {[s.PDMG]=2560.8, [s.PATK]=1113.6})
end


function TestCP_Calc:testItemCalc_without_BasePLUS()
    local s = CP.Calc.STATS

    -- http://de.runesdatabase.com/item/211540
    TestCP_Calc.CheckItemPlusGrad(211540, 100,0, 0, {[s.PDMG]=285, [s.MDMG]=150, [s.STR]=17})
    TestCP_Calc.CheckItemPlusGrad(211540, 100,1, 0, {[s.PDMG]=289, [s.MDMG]=150, [s.STR]=17, [s.PATK]=20})
    TestCP_Calc.CheckItemPlusGrad(211540, 100,2, 0, {[s.PDMG]=293, [s.MDMG]=150, [s.STR]=17, [s.PATK]=35})
    TestCP_Calc.CheckItemPlusGrad(211540, 100,0, 1, {[s.PDMG]=313.5,[s.MDMG]=165, [s.STR]=17})
    TestCP_Calc.CheckItemPlusGrad(211540, 100,0, 2, {[s.PDMG]=342, [s.MDMG]=180, [s.STR]=17})
    TestCP_Calc.CheckItemPlusGrad(211540, 100,10,10,{[s.PDMG]=611,[s.MDMG]=300,[s.STR]=17, [s.PATK]=170})

    -- http://de.runesdatabase.com/item/223026
    TestCP_Calc.CheckItemPlusGrad(223026, 100,0, 0, {[s.PDEF]=568, [s.MDEF]=811})
    TestCP_Calc.CheckItemPlusGrad(223026, 100,10, 0,{[s.PDEF]=768, [s.MDEF]=1011, [s.INT]=92})
    TestCP_Calc.CheckItemPlusGrad(223026, 100,0, 10,{[s.PDEF]=1136, [s.MDEF]=1622})
end


function TestCP_Calc.CheckPlus(item, stat, values)
    local temp = item.plus
    for plus,pdmg in pairs(values) do
        item.plus = plus
        TestCP_Calc.CheckItem(item, {[stat]=pdmg} )
    end
    item.plus = temp
end

function TestCP_Calc.CheckTier(item, stat, values)
    local temp = item.tier
    for tier,pdmg in pairs(values) do
        item.tier = tier
        TestCP_Calc.CheckItem(item, {[stat]=pdmg} )
    end
    item.tier = temp
end


function TestCP_Calc.CheckItemPlusGrad(item_id, dura_percent, plus, tier, stats)
    local item = CP.DB.GenerateItemDataByID(item_id)
    item.dura = item.dura * dura_percent / 100
    item.plus = plus or 0
    item.tier = tier or 0

    TestCP_Calc.CheckItem(item, stats)
end


function TestCP_Calc.CheckItem(item, stats)

    local result = {}
    CP.Calc.desc = {}
    CP.Calc.values = result
    CP.Calc.Clear()
    CP.Calc.Item(item)
    CP.Calc.ItemStats(item)
    CP.Calc.ItemRunes(item)

    for stat, value in pairs(stats) do
        local round = math.floor(result[stat]*10)/10
        assertEquals(round,value, "Item: "..item.id)
    end
end

function TestCP_Calc:classSetUp()
    CP.DB.Load()
end


function TestCP_Calc:classTearDown()
    CP.DB.Release()
end