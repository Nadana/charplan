--[[
    CharPlan - Skills

    the Skill tree
]]
local CP = _G.CP
local Classes= {}
CP.Classes = Classes

local learn = CP.DB.learn

local SKILLS_PER_PAGE=15
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
            local c1 = UIDropDownMenu_GetSelectedValue(CPClassDialogClassMainClassDropDown)
            local c2 = UIDropDownMenu_GetSelectedValue(CPClassDialogClassSubClassDropDown)
            CP.Unit.SetClass(c1,c2)
            Classes.OnClassChanged()
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
    CPClassDialogHideNotAvailableText:SetText("Hide not available")
    CPClassDialogHideNotSkillableText:SetText("Hide not skillable")

    CPClassDialogClassMainLabel:SetText(C_CLASS1)
    CPClassDialogClassSubLabel:SetText(C_CLASS2)

    CPClassDialogClassMainLevelEdit:SetText(CP.Unit.level)
    CPClassDialogClassSubLevelEdit:SetText(CP.Unit.sec_level)

    local pri_name,sec_name = CP.Unit.GetClassName()
    UIDropDownMenu_SetSelectedValue(CPClassDialogClassMainClassDropDown, CP.Unit.class)
    UIDropDownMenu_SetText(CPClassDialogClassMainClassDropDown, pri_name)
    UIDropDownMenu_SetSelectedValue(CPClassDialogClassSubClassDropDown, CP.Unit.sec_class)
    UIDropDownMenu_SetText(CPClassDialogClassSubClassDropDown, sec_name)

    Classes.OnClassChanged()
end

function Classes.OnClassChanged()
    CP.Classes.skills = CP.Unit.GetAllSkills()
    Classes.UpdateTabs()
    Classes.UpdateList()
end

function Classes.OnSkillChanged()
    CP.Classes.skills = CP.Unit.GetAllSkills()

    local hide_not_avail = CPClassDialogHideNotAvailable:IsChecked()
    local hide_not_skill = CPClassDialogHideNotSkillable:IsChecked()

    repeat
        local nothing_removed=true
        for _,line in pairs(CP.Classes.skills) do
            for idx,skill in ipairs(line) do
                if (hide_not_avail and not skill[5]) or
                   (hide_not_skill and skill[9]==0) then
                    table.remove(line,idx)
                    nothing_removed=false
                end
            end
        end
    until nothing_removed

    Classes.UpdateList()
end

function Classes.UpdateList()

    local skillPoints = GetTotalTpExp()
    CPClassDialogSkillPoints:SetText( skillPoints )

    Classes.NextPage(0)
end

function Classes.NextPage(delta)
    Classes.ShowPage((CP.Classes.page or 1)+delta)
end

function Classes.ShowPage(pagenr)

	local	_FrameName		= "CPClassDialogSkills"
	local	_PageBar		= _G[ _FrameName .. "PageBar"]
	local	_LeftPage		= _G[ _PageBar:GetName() .. "LeftPage"]
	local	_RightPage		= _G[ _PageBar:GetName() .. "RightPage"]
	local	_Page			= _G[ _PageBar:GetName() .. "Page"]


    local skill_list = Classes.GetCurSkillList()

    local nof_pages = math.ceil( #skill_list / SKILLS_PER_PAGE )

    if pagenr<1 then pagenr =1 end
    if pagenr>nof_pages then pagenr=nof_pages end
    Classes.page = pagenr


    SetVisible(_PageBar, nof_pages > 1)
    SetVisible(_LeftPage, pagenr > 1)
    SetVisible(_RightPage, pagenr < nof_pages)

	_Page:SetText( pagenr.." / "..nof_pages )


    local top = (pagenr-1) * SKILLS_PER_PAGE
    for i = 1,SKILLS_PER_PAGE do
        local _ButtonName = _FrameName .. "SkillButton_"..i
        local _Button = _G[_ButtonName]
        local _NextValueBar	= _G[ _ButtonName .. "PointStatusBar"]

        local sk = skill_list[top+i]

        if sk then
            local lvl = sk[1]
            local id = sk[2]
            local name = sk[3]
            local icon = sk[4]
            local learned = sk[5]
            local condition = sk[6]
            local skill = sk[7] or 0
            local mode = sk[8] -- ==2: passive
            local maxskill = sk[9]

            local costs = CP.DB.GetTPCosts(skill, false)

            Classes.SetSkillButton( _Button, icon, name, id, skill, costs,  mode, maxskill>0, 0, 0, learned )
--~             if _bLearned then
--~                 Classes.SetSkillButton( _Button, _IconPath, _SkillName, _SkillLV, _PLV, _PPoint, _Mode, _EnableToLV, 0, 0, _bLearned )
--~             else
--~                 Classes.SetSkillButton( _Button, _IconPath, _SkillName, _SkillLV, nil, nil, nil, nil, 0, 0, _bLearned )
--~             end
		else
			Classes.SetSkillButton( _Button, nil, nil, nil, nil, nil, nil, nil, 0, 0, nil )
		end
	end
end

function Classes.UpdateTabs()

    local basename="CPClassDialogSkillsTab"

	local VocName, VocSubName  = CP.Unit.GetClassName()
	local ClassToken, SubClassToken = CP.Unit.class, CP.Unit.sec_class

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

	for i=index,5 do
 		_G[ basename .. i ]:Hide()
	end

	PanelTemplates_SetNumTabs( CPClassDialogSkills, index )

	PanelTemplates_SetTab( CPClassDialogSkills, 1)
end

function Classes.OnTabClicked(this, id)
    PanelTemplates_SetTab(CPClassDialogSkills,id)
    Classes.ShowPage(1)
end

function Classes.OnLevelChanged(this)
    CP.Unit.level = CP.Unit.ClampLevel(CPClassDialogClassMainLevelEdit:GetText())
    CP.Unit.sec_level = CP.Unit.ClampLevel(CPClassDialogClassSubLevelEdit:GetText())

    CPClassDialogClassMainLevelEdit:SetText(CP.Unit.level)
    CPClassDialogClassSubLevelEdit:SetText(CP.Unit.sec_level)

    if CP.Unit.sec_level > CP.Unit.level then
        CPClassDialogClassSubLevelEdit:SetTextColor(1,0.7,0.7)
    else
        CPClassDialogClassSubLevelEdit:SetTextColor(1,1,1)
    end

    Classes.OnSkillChanged()
end

function Classes.GetCurSkillList()
    local idx = PanelTemplates_GetSelectedTab(CPClassDialogSkills)
    local skill_type = _G[ "CPClassDialogSkillsTab" .. idx ].type
    return CP.Classes.skills[skill_type]
end


function Classes.OnEnterButton(this, id)

	local iIndex	= (CP.Classes.page-1)*SKILLS_PER_PAGE + id

	if this.EnableToLV == 1 then
		getglobal( this:GetName() .. "SelectHighlight" ):Show()
	end

	GameTooltip:ClearAllAnchors()
	GameTooltip:SetOwner(this, "ANCHOR_RIGHT", 10, 0)
	--GameTooltip:SetSkillItem( gSkillFrame.type, iIndex )
	GameTooltip:Show()
end

function Classes.SetSkillButton( _Button, _IconPath, _SkillName, _Lv, _Plv, _Point, _Mode, _EnableToLV, _duration, _remaining, _bLearned )

	local _ButtonName	= _Button:GetName()
	local _SkillInfoName	= _ButtonName .. "_SkillInfo";
	local _ItemButton	= getglobal( _ButtonName .. "ItemButton" )
	local _Name		= getglobal( _SkillInfoName .. "_Name"	)
	local _LV		= getglobal( _SkillInfoName .. "_LV"	)
	local _PowerLV		= getglobal( _ButtonName .. "PowerLV"	)
	local _StatusBar	= getglobal( _ButtonName .. "PointStatusBar" )
	local _NextValue	= getglobal( _ButtonName .. "PointStatusBar" .. "NextValue" )
	local _NextValueTitle	= getglobal( _ButtonName .. "PointStatusBar" .. "Next" )
	local _PowerIcon	= getglobal( _ButtonName .. "Icon" );

	if( _SkillName ) then
		_NextValueTitle:Show()
		_Button:Enable()
	else
		_NextValueTitle:Hide()
		_Button:Disable()
	end

	if( _EnableToLV == 0 and _Plv == 0 and _Point == 0 )then
		_EnableToLV = nil
		_Plv = nil
		_Point = nil
	end


	SetItemButtonTexture( _ItemButton, _IconPath );

	getglobal( _ButtonName .. "PointStatusBar" .. "StatusText" ):Hide();

    _NextValue:SetText( _Point )

	if( _Lv and _Lv > 0 ) then
		local strRank = TEXT( "SYS_MAGIC_LEVEL" )
		_LV:SetText( strRank .. _Lv );
		_LV:SetColor( 0.9, 0.9, 0.4 );
	else
		_LV:SetText( "" );
	end

	if( _Plv ) then
		_PowerLV:SetText( _Plv );
		_NextValueTitle:Show();
		_PowerIcon:Show();
	else
		_NextValueTitle:Hide();
		_PowerLV:SetText( "" );
		_PowerIcon:Hide();
	end

	if( _EnableToLV ) then
		_StatusBar:Show();
		if( _EnableToLV == 0 ) then
			_StatusBar:SetValue( 1 );
			_NextValue:SetText( "" );
			getglobal( _ButtonName .. "PointStatusBar" .. "Next" ):Hide();
			getglobal( _ButtonName .. "PointStatusBar" .. "StatusText" ):Show();
		else
			_StatusBar:SetValue( _Plv / UnitLevel( "player" ) );
			getglobal( _ButtonName .. "PointStatusBar" .. "Next" ):Show();
			getglobal( _ButtonName .. "PointStatusBar" .. "StatusText" ):Hide();

		end
		_StatusBar:Show();
	else
		_StatusBar:Hide();
	end

	if( _Mode == 0 or _Mode == 1 )then
		_Name:SetText( _SkillName );
		_Name:SetColor( 1, 1, 1 );
		_ItemButton:Enable();
	elseif( _Mode == 2 ) then
		_Name:SetColor( 0.1, 0.68, 0.21 );
		_Name:SetText( _SkillName );
		_ItemButton:Disable();
	elseif( _Mode == 100 ) then
		_Name:SetText( _SkillName );
		_Name:SetColor( 1, 1, 1 );
		_ItemButton:Enable();
	else
		_Name:SetText( _SkillName );
		_Name:SetColor( 1, 1, 1 );
		_ItemButton:Disable();
	end

	_Button.Mode       = _Mode;
	_Button.EnableToLV = _EnableToLV;
	_Button.bLearned = _bLearned;
	_ItemButton.bLearned = _bLearned;
	_Button:Show()

	if( not _bLearned )then
		_ItemButton:Disable();
		_Name:SetColor( 0.5, 0.5, 0.5 );
		_LV:SetColor( 0.5, 0.5, 0.5 );
	end

end


