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
local function ApplyBonus(stats, effect)
    for i=1,#effect,2 do
        stats[effect[i]] = stats[effect[i]] + effect[i+1]
    end
end

local function LoadStoredData(info)
    TestCP_CalcFull.cur_data = info

    CP.Items={}
    for _,item in pairs(info.item_links) do
        CP.ApplyLinkItem(item,nil,true)
    end

    CP.Unit.Load(info)
end

function TestCP_CalcFull:DoFullCharCheck(info)

    -- data prepase
    LoadStoredData(info)

    CP.Calc.Init()

    -- !Same as in calculate
    local values = CP.Calc.NewStats()
    values = values + info.bases
    values = values + CP.Calc.GetSkillBonus()
    values = values + info.cards
    values = values + CP.Calc.GetArchievementBonus()

    values = CP.Calc.AddItemsBonus(values)
    CP.Calc.DependingStats(values)
    -- !end

    TestCP_Calc:CompareStats(values, info.result,nil,0.9) -- TODO: tolerance (last value) should be 0
end


function TestCP_CalcFull:classSetUp()
    self.old_data = CP.Utils.TableCopy(CP.Items)
    self.old_unit={}
    CP.Unit.Store(self.old_unit)

    CP.DB.Load()
end

function TestCP_CalcFull:classTearDown()

    CP.Unit.Load(self.old_unit)

    CP.Items = self.old_data
    CP.Calc.Init()
    CP.DB.Release()
end


------------------------------------------
-- SnapShot Tests
------------------------------------------
if true then
    local fct,err = loadfile('interface/addons/charplan/test/test_calc_full_data.lua')
    local snapshots = fct()
    for nid,data in pairs(snapshots) do
        local name=string.format("testSnap%s_%s",(data.name or ""),nid)
        TestCP_CalcFull[name]=function()
            TestCP_CalcFull:DoFullCharCheck(data)
        end
    end
end


