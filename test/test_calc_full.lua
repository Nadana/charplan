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

local function LoadStoredData(info)
    TestCP_CalcFull.cur_data = info

    Charplan.Items={}
    for _,item in pairs(info.item_links) do
        Charplan.ApplyLinkItem(item,nil,true)
    end

    Charplan.Unit.Load(info)
end

function TestCP_CalcFull:DoFullCharCheck(info)

    -- data prepase
    LoadStoredData(info)

    Charplan.Calc.Init()

    -- !Same as in calculate
    local values = Charplan.Calc.NewStats()
    values = values + info.bases
    values = values + Charplan.Calc.GetSkillBonus()
    values = values + info.cards
    values = values + Charplan.Calc.GetArchievementBonus()

    values = Charplan.Calc.AddItemsBonus(values)
    Charplan.Calc.DependingStats(values)
    -- !end

    TestCP_Calc:CompareStats(values, info.result,nil,0.9) -- TODO: tolerance (last value) should be 0
end


function TestCP_CalcFull:classSetUp()
    self.old_data = Charplan.Utils.TableCopy(Charplan.Items)
    self.old_unit={}
    Charplan.Unit.Store(self.old_unit)

    Charplan.DB.Load()
end

function TestCP_CalcFull:classTearDown()

    Charplan.Unit.Load(self.old_unit)

    Charplan.Items = self.old_data
    Charplan.Calc.Init()
    Charplan.DB.Release()
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


