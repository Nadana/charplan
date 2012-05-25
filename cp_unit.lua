local CP = _G.CP
local Unit= {}
CP.Unit = Unit

--[[ data fields:
    title_id
    title_count
    name
    level
    sec_level
    class
    sec_level
]]

local function _GetTitleCount()
    local count = GetTitleCount()-1
    local tc = 0
	for i = 0, count do
		local _,_,getted = GetTitleInfoByIndex(i)
        if getted then tc=tc+1 end
    end
    return tc
end


function Unit.ReadCurrent()
    Unit.title_id = GetCurrentTitle()
    Unit.title_count = _GetTitleCount()
    Unit.name = UnitName("player")
    Unit.level, Unit.sec_level=UnitLevel("player")
    Unit.class, Unit.sec_class=UnitClassToken("player")
end

function Unit.Store(data_tab)
    data_tab.name = Unit.name
    data_tab.title_id = Unit.title
    data_tab.title_count = Unit.title_count
    data_tab.level = Unit.level
    data_tab.sec_level = Unit.sec_level
    data_tab.class = Unit.class
    data_tab.sec_class = Unit.sec_class
end

function Unit.Load(data_tab)
    Unit.name = data_tab.name
    Unit.title_id = data_tab.title
    Unit.title_count = data_tab.title_count or 0
    Unit.level = data_tab.level
    Unit.sec_level = data_tab.sec_level
    Unit.class = data_tab.class
    Unit.sec_class = data_tab.sec_class
end

function Unit.GetCurrentTitle()
    local count = GetTitleCount()
	for i = 1 , count do
        local name,id = GetTitleInfoByIndex( i - 1 )
        if id == Unit.title_id then
            return id,name
        end
    end

    if Unit.title_id~=0 then
        CP.Debug("title not found: id="..tostring(Unit.title_id))
    end

    return 0,C_TITLE_NIL
end

function Unit.Init(this)
    CP.RegisterEvent("PLAYER_TITLE_ID_CHANGED", Unit.Updated)
    CP.RegisterEvent("SKILL_UPDATE", Unit.Updated)
    CP.RegisterEvent("CARDBOOKFRAME_UPDATE", Unit.Updated)
    CP.RegisterEvent("PLAYER_LEVEL_UP", Unit.Updated)
end

function Unit.Updated()
    if CPFrame:IsVisible() then
        Unit.ReadCurrent()
        CP.Calc.ReadCards()
        CP.Calc.ReadSkills()
        CP.PlayerTitle()
        CP.UpdatePoints()
    end
end
