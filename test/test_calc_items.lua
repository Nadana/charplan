TestCP_CalcItems={}

function TestCP_CalcItems:testSetBonus()
    local s = CP.Calc.STATS

    CP.Items={
            [1]={id=226503}, -- Set - Handschützer von Yawaka
            [4]={id=226505}, -- Set - Beinschützer von Yawaka
            [6]={id=226504}, -- Set - Gurt von Yawaka
            [13]={id=226506}, -- Set - Ohrring von Yawaka
            [14]={id=227956}, -- Earring (dummy - other set)
            [15]={id=212254}, -- Weapon (dummy)
        }
    local result = CP.Calc.GetSetBonus(result)
    self:CompareStatsComplete(result, {[s.DEX]=95,[s.PATK]=1200,[s.PCRIT]=150,[s.STR]=100,[s.PDMG]=45})


    CP.Items={
            [1]={id=226503}, -- Set - Handschützer von Yawaka
            [4]={id=226505}, -- Set - Beinschützer von Yawaka
        }
    local result = CP.Calc.GetSetBonus(result)
    self:CompareStatsComplete(result, {[s.DEX]=95})
end

function TestCP_CalcItems:testItemCalc_ID_226499() --Handschützer von Lekani
    local s = CP.Calc.STATS

    -- http://de.runesdatabase.com/item/226499
    local item = CP.DB.GenerateItemDataByID(226499)
    self:CheckItem(item, {[s.PDEF]=1107, [s.MDEF]=1365})
 	self:CheckItemPlusGrad(226499, 100,10, 10, {[s.PDEF]=2601, [s.MDEF]=3207})
end


function TestCP_CalcItems:testItemCalc_ID_212485()
    local s = CP.Calc.STATS

    -- http://de.runesdatabase.com/item/212485
    local item = CP.DB.GenerateItemDataByID(212485)
    self:CheckItem(item, {[s.PDMG]=1159})
    self:CheckPlus(item, s.PDMG, {1182,1205,1228,1251,1274,1309,1344,1379,1413,1448,1483,1541,1599,1657,1715,1831})
    self:CheckTier(item, s.PDMG, {1274.9,1390.8,1506.7,1622.6,1738.5})
    item.tier=1
        self:CheckPlus(item, s.PDMG, {1297.9,1320.9,1343.9,1366.9,1389.9,1424.9})
    item.plus=1
        self:CheckTier(item, s.PDMG, {1297.9,1413.8,1529.7,1645.6,1761.5,1877.4})

    self:CheckItemPlusGrad(212485, 100,10,10,{[s.PDMG]=2607})
end


function TestCP_CalcItems:testItemCalc_ID_212615()
    local s = CP.Calc.STATS

    -- http://de.runesdatabase.com/item/212615
	self:CheckItemPlusGrad(212615, 100,0, 0, {[s.PDMG]=2288, [s.PATK]=976})
	self:CheckItemPlusGrad(212615, 100,1, 0, {[s.PDMG]=2332, [s.PATK]=1016})
	self:CheckItemPlusGrad(212615, 100,2, 0, {[s.PDMG]=2378, [s.PATK]=1056})
 	self:CheckItemPlusGrad(212615, 100,0, 1, {[s.PDMG]=2516.8, [s.PATK]=1073.6})
 	self:CheckItemPlusGrad(212615, 100,0, 2, {[s.PDMG]=2745.6, [s.PATK]=1171.2})
 	self:CheckItemPlusGrad(212615, 100,1, 1, {[s.PDMG]=2560.8, [s.PATK]=1113.6})
end


function TestCP_CalcItems:testItemCalc_without_BasePLUS()
    local s = CP.Calc.STATS

    -- http://de.runesdatabase.com/item/211540
    self:CheckItemPlusGrad(211540, 100,0, 0, {[s.PDMG]=285, [s.MDMG]=150, [s.STR]=17})
    self:CheckItemPlusGrad(211540, 100,1, 0, {[s.PDMG]=289, [s.MDMG]=150, [s.STR]=17, [s.PATK]=20})
    self:CheckItemPlusGrad(211540, 100,2, 0, {[s.PDMG]=293, [s.MDMG]=150, [s.STR]=17, [s.PATK]=35})
    self:CheckItemPlusGrad(211540, 100,0, 1, {[s.PDMG]=313.5,[s.MDMG]=165, [s.STR]=17})
    self:CheckItemPlusGrad(211540, 100,0, 2, {[s.PDMG]=342, [s.MDMG]=180, [s.STR]=17})
    self:CheckItemPlusGrad(211540, 100,10,10,{[s.PDMG]=611,[s.MDMG]=300,[s.STR]=17, [s.PATK]=170})

    -- http://de.runesdatabase.com/item/223026
    self:CheckItemPlusGrad(223026, 100,0, 0, {[s.PDEF]=568, [s.MDEF]=811})
    self:CheckItemPlusGrad(223026, 100,10, 0,{[s.PDEF]=768, [s.MDEF]=1011, [s.INT]=92})
    self:CheckItemPlusGrad(223026, 100,0, 10,{[s.PDEF]=1136, [s.MDEF]=1622})
end

function TestCP_CalcItems:CheckPlus(item, stat, values)
    local temp = item.plus
    for plus,pdmg in pairs(values) do
        item.plus = plus
        self:CheckItem(item, {[stat]=pdmg} )
    end
    item.plus = temp
end

function TestCP_CalcItems:CheckTier(item, stat, values)
    local temp = item.tier
    for tier,pdmg in pairs(values) do
        item.tier = tier
        self:CheckItem(item, {[stat]=pdmg} )
    end
    item.tier = temp
end


function TestCP_CalcItems:CheckItemPlusGrad(item_id, dura_percent, plus, tier, stats)
    local item = CP.DB.GenerateItemDataByID(item_id)
    item.dura = item.dura * dura_percent / 100
    item.plus = plus or 0
    item.tier = tier or 0

    self:CheckItem(item, stats)
end


function TestCP_CalcItems:CheckItem(item, stats)
    local result = CP.Calc.GetItemBonus(item)
    self:CompareStats(result, stats, "Item: "..item.id)
end

function TestCP_CalcItems:CompareStatsComplete(actual, expected, msg)

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

function TestCP_CalcItems:CompareStats(actual, expected, msg)

    for stat, value in pairs(expected) do
        local act = actual[stat]
        local round = math.floor(act*10)/10
        assertEquals(round,value, msg)
    end
end

function TestCP_CalcItems:classSetUp()
    self.old_data = CP.Utils.TableCopy(CP.Items)
    CP.DB.Load()
end


function TestCP_CalcItems:classTearDown()
    CP.DB.Release()
    CP.Items = self.old_data
end