-- coding: utf-8
TestCP_CalcFull={}

--[[
 How to:
  -> Ingame: import equipment into cp  & run command "/cp s"
  -> logout
  -> open savevariables.lua and copy the "CP_FullCharInfo" block
  -> create a new function (named "TestCP_CalcFull:testXXXX")
  -> paste the CP_FullCharInfo variable into it
  -> at the end of the function add the test call: "TestCP_CalcFull:DoFullCharCheck(CP_FullCharInfo)"
]]


function TestCP_CalcFull:testThoros()

    local CP_FullCharInfo = {
        ["class"]= "WARDEN",
        ["cards"] = {
            [2] = 6, [3] = 7, [4] = 8, [6] = 14, [13] = 18,[15] = 4,
        },
        ["item_links"] = {
            [1] = "|Hitem:36da4 0 77010a64 c9b5 0 0 0 0 0 0 1f40 2ded|h|cff00ff00[Bablis' geschmiedete Handschuhe]|r|h",
            [2] = "|Hitem:36dae 0 77010a64 c9b5 0 0 0 0 0 0 1f40 cbcf|h|cff00ff00[Abgefahrene Stiefel]|r|h",
            [3] = "|Hitem:36d65 0 77010a64 c9b5 0 0 0 0 0 0 1f40 ca47|h|cff00ff00[Flammenbrustpanzer der Bodos]|r|h",
            [4] = "|Hitem:36d98 0 77010a64 c9b5 0 0 0 0 0 0 1f40 d961|h|cff00ff00[Beinpanzer der Schuld]|r|h",
            [5] = "|Hitem:36c06 0 77010a64 c9a0c9b5 0 0 0 0 0 0 1f40 13d3|h|cff0072bc[Schlangenabwehr-Umhang des Mutes]|r|h",
            [6] = "|Hitem:36d5e 0 77010a64 c9b5 0 0 0 0 0 0 1f40 4fd1|h|cff00ff00[Grüner Dornkettengürtel]|r|h",
            [7] = "|Hitem:36d55 0 77010a64 c9b5 0 0 0 0 0 0 1f40 d818|h|cff00ff00[Kampfschulterschützer]|r|h",
            [8] = "|Hitem:36141 0 77010a64 c960c9c4 0 0 0 0 0 0 1f40 88a0|h|cff0072bc[Kette aus Carfcamois Beute]|r|h",
            [9] = "|Hitem:33c0f 0 77000a64 c9b4c875 0 0 0 0 0 0 1f40 94d4|h|cff0072bc[Norzens Windläufer-Langbogen]|r|h",
            [10] = "|Hitem:363ce 1 77010a55 c99ac9af 0 0 0 0 0 0 2134 9fd8|h|cff0072bc[Ring des heldenhaften Aufruhrs]|r|h",
            [11] = "|Hitem:36bf9 0 77010a64 c89d 0 0 0 0 0 0 1f40 737f|h|cff00ff00[Mysteriöser Ring]|r|h",
            [12] = "|Hitem:36fee 0 77010a64 c9b5 0 0 0 0 0 0 1f40 4f9a|h|cff00ff00[Heldengedenken-Ohrring]|r|h",
            [13] = "|Hitem:363d2 1 77010a54 c99cc871 0 0 0 0 0 0 20d0 9438|h|cff0072bc[Ohrring des heldenhaften Zorns]|r|h",
            [14] = "|Hitem:33c0e 0 77010a64 c9a0c9b5 0 0 0 0 0 0 1f36 87b1|h|cff0072bc[Schwert der Wut des Feuergeistes]|r|h",
            [15] = "|Hitem:369b3 0 77000a64 c9a0c9b5 0 0 0 0 0 0 1f40 86|h|cff0072bc[Heldenhelm des Schwertkämpfers]|r|h",
        },
        ["title"] = 0,
        ["bases"] = {
            [2] = 543,[3] = 460,[4] = 417,[5] = 434,[6] = 399, [20] = 10,
            [403] = 0, [404] = 10, [405] = 10, [409] = 359,
        },
        ["result"] = {
            [2] = 956,
            [3] = 596,
            [4] = 430,
            [5] = 439,
            [6] = 482,
            --[8] = 4443, -- HP 3761.2
            --[9] = 2892, -- MP 2625
            --[12] = 1757, -- PATK 1758
            --[13] = 2899, -- PDEF 2898
            [14] = 2612, -- MDEF
            --[15] = 880, -- MATK 879
            [17] = 375, -- EVADE
            [20] = 20,
            [22] = 0,
            --[404] = 20, -- PCRITMH 10
            --[405] = 20, -- PCRITOH 10
            --[409] = 433, -- PACCMH 359
            [403] = 10,
        },
    }

    TestCP_CalcFull:DoFullCharCheck(CP_FullCharInfo)
end

local function ApplyBonus(stats, effect)
    for i=1,#effect,2 do
        stats[effect[i]] = stats[effect[i]] + effect[i+1]
    end
end

function  TestCP_CalcFull:DoFullCharCheck(info)

    local values = CP.Calc.NewStats()
    values = values + info.bases
    values = values + info.cards

    local effect = CP.DB.GetArchievementEffect(info.titel)
    ApplyBonus(values, effect)

    CP.Items={}
    for _,item in pairs(info.item_links) do
        CP.ApplyLinkItem(item,nil,true)
    end

    values = values + CP.Calc.GetSetBonus()

    local items = {}
	for _,slot in ipairs( {0,1,2,3,4,5,6,7,8,9,11,12,13,14,21,10,15,16} ) do
        items[slot] = CP.Calc.GetItemBonus(CP.Items[slot])
    	values = values + items[slot]
    end

    values.PDMGR = values.PDMG   -items[15].PDMG -items[16].PDMG
    values.PCRITR= values.PCRIT  -items[15].PCRIT-items[16].PCRIT
    values.PDMGMH = values.PDMG  -items[10].PDMG -items[16].PDMG
    values.PCRITMH= values.PCRIT -items[10].PCRIT-items[16].PCRIT
    values.PDMGOH = values.PDMG  -items[10].PDMG -items[15].PDMG
    values.PCRITOH= values.PCRIT -items[10].PCRIT-items[15].PCRIT

  	CP.Calc.StatRelations(values)
    CP.Calc.CharDepended(values, info.class)
    CP.Calc.CharIndepended(values)

    TestCP_CalcItems:CompareStats(values, info.result)
end


function TestCP_CalcFull:CompareStats(actual, expected, msg)

    for stat, value in pairs(expected) do
        local act = actual[stat]
        local round = math.floor(act*10)/10
        assertEquals(round,value, msg)
    end
end

function TestCP_CalcFull:classSetUp()
    self.old_data = CP.Utils.TableCopy(CP.Items)
    CP.DB.Load()
end


function TestCP_CalcFull:classTearDown()
    CP.DB.Release()
    CP.Items = self.old_data
end