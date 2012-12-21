--[[
    CharPlan - Skills

    the Skill tree
]]
local CP = _G.CP
local Classes= {}
CP.Classes = Classes

local learn = CP.DB.learn

-- helper
local function SetVisible(this,vis)
    if vis then
        this:Show()
    else
        this:Hide()
    end
end
-----

function CP.UpdateClassBotton()
    CPFrameClassBtnLeftText:SetText(CP.Unit.GetClassName())
    CPFrameClassBtnRightText:SetText(CP.Unit.level)
end

function CP.ChangeClass()
    ToggleUIFrame(CPClassDialog)
end

function Classes.OnClassDropDownShow(this)
    local info={}
    for i=1,GetClassCount() do
        local txt, token = GetClassInfoByID( GetClassID(i) )
        info.text = txt
        info.value = token
        info.notCheckable=1
        info.func = function (button)
            UIDropDownMenu_SetSelectedValue(this, button.value)
            Classes.ResetList()
        end
        UIDropDownMenu_AddButton(info)
    end
end

function CP.OnClassDialogClick()
    local lvl = tonumber(CPClassDialogLevelEdit:GetText())
    if lvl<1 then lvl=1 end
    if lvl>MAX_LEVEL then lvl=MAX_LEVEL end

    CP.Unit.level = lvl
    CP.Unit.class = UIDropDownMenu_GetSelectedValue(CPClassDialogClassDropDown)

    HideUIPanel(CPClassDialog)
    CP.UpdateClassBotton()
    CP.UpdatePoints()
end

function Classes.OnShow(this)

    CPClassDialogClassLabel:SetText(CLASS)
    CPClassDialogLevelLabel:SetText(CP.L.SEARCH_LEVEL)

    CPClassDialogClassMainLabel:SetText(C_CLASS1)
    CPClassDialogClassSubLabel:SetText(C_CLASS2)

    CPClassDialogClassMainLevelEdit:SetText(CP.Unit.level)
    CPClassDialogClassSubLevelEdit:SetText(CP.Unit.sec_level)

    local pri_name,sec_name = CP.Unit.GetClassName()
    UIDropDownMenu_SetSelectedValue(CPClassDialogClassMainClassDropDown, CP.Unit.class)
    UIDropDownMenu_SetText(CPClassDialogClassMainClassDropDown, pri_name)
    UIDropDownMenu_SetSelectedValue(CPClassDialogClassSubClassDropDown, CP.Unit.sec_class)
    UIDropDownMenu_SetText(CPClassDialogClassSubClassDropDown, sec_name)

	Classes.ResetList()
end

function Classes.ResetList()

	Classes.ResetTab()

    local skillPoints = GetTotalTpExp()
    CPClassDialogSkillPoints:SetText( skillPoints )

    Classes.ShowPage(1)
end

function Classes.ShowPage(pagenr)

	local	_FrameName		= "CPClassDialogSkills"
	local	_PageBar		= _G[ _FrameName .. "PageBar"]
	local	_LeftPage		= _G[ _PageBar:GetName() .. "LeftPage"]
	local	_RightPage		= _G[ _PageBar:GetName() .. "RightPage"]
	local	_Page			= _G[ _PageBar:GetName() .. "Page"]


    local skill_list = Classes.GetCurSkillList()

    local nof_pages = math.ceil( #skill_list / DF_MAXPAGESKILL_SKILLBOOK )

    if pagenr<1 then pagenr =1 end
    if pagenr>nof_pages then pagenr=nof_pages end
    Classes.page = pagenr


    SetVisible(_PageBar, nof_pages > 1)
    SetVisible(_LeftPage, pagenr > 1)
    SetVisible(_RightPage, pagenr < nof_pages)

	_Page:SetText( pagenr.." / "..nof_pages )


    local top = (pagenr-1) * DF_MAXPAGESKILL_SKILLBOOK
    for i = 1,DF_MAXPAGESKILL_SKILLBOOK do
        local _ButtonName = _FrameName .. "SkillButton_"..i
        local _Button = _G[_ButtonName]
        local _NextValueBar	= _G[ _ButtonName .. "PointStatusBar"]

        local sk = skill_list[top+i]

        if sk then
            local lvl = sk[1]
            local id = sk[2]
            local name = TEXT("Sys"..id.."_name")

            SkillBook_SetSkillButton( _Button, "", name, nil, 99, 200, 400, nil, true, 0, 0, 1 )
--~             if _bLearned then
--~                 SkillBook_SetSkillButton( _Button, _IconPath, _SkillName, _SkillLV, _PLV, _PPoint, _PTotalPoint, _Mode, _EnableToLV, 0, 0, _bLearned )
--~             else
--~                 SkillBook_SetSkillButton( _Button, _IconPath, _SkillName, _SkillLV, nil, nil, nil, nil, nil, 0, 0, _bLearned )
--~             end
		else
			SkillBook_SetSkillButton( _Button, nil, nil, nil, nil, nil, nil, nil, nil, 0, 0, nil )
		end
	end
end

function Classes.ResetTab()

    local basename="CPClassDialogSkillsTab"

	local VocID, VocName = GetVocInfo()
	local VocSubID, VocSubName = GetVocSubInfo()
	local ClassToken, SubClassToken = UnitClassToken( "player" )

    local index=1
    local function AddTab(this, typ, value, name)
        local frame = _G[ basename .. index]
        frame.type = typ
		frame:SetID(index)
        frame:Show()
        PanelTemplates_DeselectTab(frame)
        PanelTemplates_IconTabInit( frame, value, text)
        index = index+1
    end

    AddTab(this, DF_SkillType_MainJob, string.format( DF_SkillBook_Tab_Format , ClassToken ) , VocName )

	if( VocSubID ~= -1 )then
        AddTab(this, DF_SkillType_SubJob, string.format( DF_SkillBook_Tab_Format , SubClassToken ) , VocSubName )
    end

    AddTab(this, DF_SkillType_SP, string.format( DF_SkillBook_Tab_Format , ClassToken ) .. "_sole" , string.format( CLASS_ONLY , VocName ) )

--~ 	if( GetNumSkill( DF_SkillType_Pet ) > 0 )then
--~         AddTab(this, DF_SkillType_Pet, string.format( DF_SkillBook_Tab_Format , "pet" ), TEXT("SKILLBOOK_TAB_PET") )
--~ 	end


	for i=index,5 do
 		_G[ basename .. i ]:Hide()
	end

	PanelTemplates_SetNumTabs( CPClassDialogSkills, index )

	PanelTemplates_SetTab( CPClassDialogSkills, 1)
end



function Classes.GetCurSkillList()
    local skill_type = Classes.GetSelectedTab()

    local c1 = UIDropDownMenu_GetSelectedValue(CPClassDialogClassMainClassDropDown)
    local c2 = UIDropDownMenu_GetSelectedValue(CPClassDialogClassSubClassDropDown)

    if skill_type == DF_SkillType_MainJob then
        return Classes.GetSkillList(c1,1)
    elseif skill_type == DF_SkillType_SubJob then
        return Classes.GetSkillList(c2,1)
    elseif skill_type == DF_SkillType_SP then
        return Classes.GetSkillList(c1,2)
    else
        assert(false)
    end

end

function Classes.GetSelectedTab()
    local idx = PanelTemplates_GetSelectedTab(CPClassDialogSkills)
    return _G[ "CPClassDialogSkillsTab" .. idx ].type
end

function Classes.GetSkillList(token,line)
    local cid = CP.Unit.GetClassIDByToken(token)
    local learn = CP.DB.learn[590000+cid]
    if not learn then return {} end

    assert(line==1 or line==2)
    return learn[line]
end


function Classes.OnTabClicked(this, id)

--~ 	if( gSkillFrame.type ~= this.type ) then

--~ 		SkillTab_SetActiveState( gSkillFrame.tab, false );
--~ 		SkillTab_SetActiveState( this, true );

--~ 		gSkillFrame.tab = this;
--~ 		gSkillFrame.type = this.type;

--~ 		Lua_Reset_SkillBook( gSkillFrame.frame );
--~ 	end

end

