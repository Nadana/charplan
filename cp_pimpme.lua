--[[
    CharPlan - PimpMe

    Pimp item dialog
    based on ideas of ItemForge and ItemPreview

    So special thanks to:
    - Valacar (Hash calculation)
    - ZhurRunes (ItemForge)
    - Alleris (ItemPreview)
]]

--[[
Item data = {
    -- icon,quality
    name
    id
    bind
    bind_flag
    plus
    rarity    -- == color??
    tier
    dura
    max_dura  --  !! Percent of base-dura !!
    stats[6]
    rune_slots
    runes[4]
    unk1      -- unknown itemlink data
}
]]


local CP = _G.CP
local Pimp = {}
CP.Pimp = Pimp

local Nyx = LibStub("Nyx")

local STATSEARCH_FIELD=13


function Pimp.PimpItemLink(itemlink)

    local item_data = Pimp.ExtractLink(itemlink)
    item_data.icon = CP.DB.GetItemIcon(item_data.id)

    Pimp.PimpItem(item_data)
    Pimp.SetHyperLink(itemlink)
end


function Pimp.SetHyperLink(itemlink)

    CPPimpMeToolTip:SetHyperLink( itemlink )
    GameTooltip:Hide()
    GameTooltip1:Hide()
    GameTooltip2:Hide()

    -- scale tooltip
    local lines=1
    for i = 1, 60 do
		textL = getglobal("CPPimpMeToolTipTextLeft" .. i)
		textR = getglobal("CPPimpMeToolTipTextRight" .. i)

        if textL:IsVisible() or textR:IsVisible() then
            lines=i

            -- force right border
            textR:ClearAllAnchors();
		    textR:SetAnchor("TOPRIGHT", "TOPLEFT", textL:GetName(), 372, 0);

            -- minimize DPS
            local t = textL:GetText()
            if string.find(t,TEXT("SYS_WEAPON_DPS")) then
                textL:SetText(string.gsub(t,TEXT("SYS_WEAPON_DPS"),"dps"))
            end
        end
    end

    CPPimpMeToolTip:SetScale(1)
    if lines>35 then
        CPPimpMeToolTip:SetScale(35/lines)
    end
end


function Pimp.PimpItem(item_data)
    Pimp.data = item_data
    Pimp.data_backup = CP.Utils.TableCopy(item_data)

    Pimp.FillFields()
    CPPimpMe:Show()
end


function Pimp.OnItemClicked()
    ChatEdit_AddItemLink( Pimp.GenerateLink(Pimp.data, "CP: ") )
end

function Pimp.FillFields()
    local data = Pimp.data

    CPPimpMeTitle:SetText(data.name)

    SetItemButtonTexture(CPPimpMeItem, data.icon)

    UIDropDownMenu_SetSelectedValue(CPPimpMeAttrPlus, data.plus)
    CPPimpMeAttrPlusText:SetText("+"..tostring(data.plus))

    UIDropDownMenu_SetSelectedValue(CPPimpMeAttrTier, data.tier)
    CPPimpMeAttrTierText:SetText(data.tier)

    CPPimpMeAttrDura:SetText(math.floor(data.dura))
	CPPimpMeAttrMaxDura:SetText(CP.DB.GetItemMaxDura(data.id, data.max_dura))
    if CP.DB.HasFixedMaxDura(data.id) then
        CPPimpMeAttrMaxDura:Disable()
        CPPimpMeAttrMaxDura:SetTextColor(0.6,0.6,0.6)
    else
        CPPimpMeAttrMaxDura:Enable()
        CPPimpMeAttrMaxDura:SetTextColor(1,1,1)
    end

    Pimp.OnStatCtrlSetValue(CPPimpMeAttrStat1, data.stats[1])
    Pimp.OnStatCtrlSetValue(CPPimpMeAttrStat2, data.stats[2])
    Pimp.OnStatCtrlSetValue(CPPimpMeAttrStat3, data.stats[3])
    Pimp.OnStatCtrlSetValue(CPPimpMeAttrStat4, data.stats[4])
    Pimp.OnStatCtrlSetValue(CPPimpMeAttrStat5, data.stats[5])
    Pimp.OnStatCtrlSetValue(CPPimpMeAttrStat6, data.stats[6])

    Pimp.OnStatCtrlSetValue(CPPimpMeAttrRune1, data.runes[1])
    Pimp.OnStatCtrlSetValue(CPPimpMeAttrRune2, data.runes[2])
    Pimp.OnStatCtrlSetValue(CPPimpMeAttrRune3, data.runes[3])
    Pimp.OnStatCtrlSetValue(CPPimpMeAttrRune4, data.runes[4])


    Pimp.UpdateInfo()
end

function Pimp.UpdateInfo()
    Pimp.SetHyperLink( Pimp.GenerateLink(Pimp.data) )
    CP.PimpUpdate()
end

function Pimp.StatName(id)
    if id>0 then
        local sname = string.format("Sys%06i_name",id)
        return string.format("%i - %s",id,TEXT(sname))
    else
        return ""
    end
end


function Pimp.OnShow(this)
    this:ResetFrameOrder()

    CPPimpMeAttrDuraLabel:SetText(CP.L.PIMP_DURA)
end

function Pimp.OnHide(this)
    if Pimp.data_backup then
        CP.Utils.TableCopy(Pimp.data_backup, Pimp.data)
    end

    Pimp.data = nil
    Pimp.data_backup = nil
    CP.PimpFinished()
end

function Pimp.OnOK(this)
    Pimp.data_backup = nil
    CPPimpMe:Hide()
end

function Pimp.OnCancel(this)
    CPPimpMe:Hide()
end

function Pimp.OnCtrlLoad(this)

    local name = string.sub(this:GetName(), string.len("CPPimpMeAttr")+1)

    UIDropDownMenu_SetWidth(this, 60)
    UIDropDownMenu_Initialize(this, Pimp["OnCtrlShow_"..name])
    this.attribute = name

    if name=="Plus" then
        _G[this:GetName().."Label"]:SetText(CP.L.PIMP_PLUS)
    else
        _G[this:GetName().."Label"]:SetText(CP.L.PIMP_TIER)
    end
end

function Pimp.OnCtrlShow_Plus(button)
    local info={}
    for i=0,16 do
        info.text = "+"..i
        info.value = i
        info.notCheckable=1
        info.func = Pimp.OnCtrlClicked_Plus
        UIDropDownMenu_AddButton(info)
    end
end

function Pimp.OnCtrlClicked_Plus(button)
    UIDropDownMenu_SetSelectedValue(CPPimpMeAttrPlus, button.value)
    Pimp.data.plus = button.value
    Pimp.UpdateInfo()
end

function Pimp.OnCtrlShow_Tier(button)
    local info={}
    for i=0,20 do
        info.text = "+"..i
        info.value = i
        info.notCheckable=1
        info.func = Pimp.OnCtrlClicked_Tier
        UIDropDownMenu_AddButton(info)
    end
end

function Pimp.OnCtrlClicked_Tier(button)
    UIDropDownMenu_SetSelectedValue(CPPimpMeAttrTier, button.value)
    Pimp.data.tier = button.value
    Pimp.UpdateInfo()
end

function Pimp.SetStat(nr, id)
    assert(nr<11)
    if nr<7 then
        if Pimp.data.stats[nr] ~= id then
            Pimp.data.stats[nr] = id
            Pimp.OnStatCtrlSetValue(_G["CPPimpMeAttrStat"..nr], id)
        end
    else
        if Pimp.data.runes[nr-6] ~= id then
            Pimp.data.runes[nr-6] = id
            Pimp.OnStatCtrlSetValue(_G["CPPimpMeAttrRune"..(nr-6)], id)

            local used_slots = Pimp.UsedRunes(Pimp.data)
            if used_slots > Pimp.data.rune_slots then
                Pimp.data.rune_slots = used_slots
            end
        end
    end

    Pimp.UpdateInfo()
end

function Pimp.OnDura_Changed(this)
    local text = this:GetText()
    if not text or text=="" then return end

    Pimp.data.dura=tonumber(text) or (Pimp.data.max_dura)
    Pimp.UpdateInfo()
end

function Pimp.OnMaxDura_Changed(this)
    local edit_max_dura = tonumber( this:GetText() )
    if not edit_max_dura then return end
	Pimp.data.max_dura =  CP.DB.CalcMaxDura(Pimp.data.id, edit_max_dura)
    Pimp.UpdateInfo()
end

-----------------------------------
function Pimp.GetStatLable(id)
    if id<7 then
        return string.format(CP.L.PIMP_STAT,id)
    else
        return string.format(CP.L.PIMP_RUNE,id-6)
    end
end

function Pimp.OnStatCtrlLoad(this)
    local id = this:GetID()
    this.isRune= (id>6)
    _G[this:GetName().."Label"]:SetText(Pimp.GetStatLable(id))

    UIDropDownMenu_SetWidth(_G[this:GetName().."Tier"], 40)
    UIDropDownMenu_Initialize(_G[this:GetName().."Tier"], Pimp.OnStatCtrlTierShow)
end

function Pimp.OnStatCtrlSetValue(button, id)
    local namebtn = _G[button:GetName().."Name"]
    local tierbtn = _G[button:GetName().."Tier"]

    if id>0 then
        local name,level, grp = CP.DB.GetBonusInfo(id)
        assert( grp and (CP.DB.IsRuneGroup(grp) == button.isRune))

        namebtn.level = level
        tierbtn.levels = CP.DB.GetBonusGroupLevels(grp)

        namebtn:SetText(name)
        UIDropDownMenu_SetText(tierbtn, level)
        if #tierbtn.levels<2 then
            UIDropDownMenuButton_Disable(tierbtn)
        else
            UIDropDownMenuButton_Enable(tierbtn)
        end
    else
        namebtn:SetText("")
        UIDropDownMenu_SetText(tierbtn, "")
        UIDropDownMenuButton_Disable(tierbtn)
    end
end


function Pimp.StatName_Finished(this)
    this:HighlightText(0,0)
    local text = this:GetText()
    if not text or text=="" then
        Pimp.SetStat(this:GetParent():GetID(),0)
        return
    end

    local is_rune = (this:GetParent():GetID()>6)
    local bestmatch = CP.DB.FindBonus(text,this.level, is_rune)

    Pimp.SetStat(this:GetParent():GetID(), bestmatch or 0)
end


function Pimp.StatName_Tab(this)
    local id = this:GetParent():GetID()
    if IsShiftKeyDown() then
        id = id-1
        if id<1 then id=10 end
    else
        id = id+1
        if id>10 then id=1 end
    end

    if id<7 then
        _G["CPPimpMeAttrStat"..id.."Name"]:SetFocus()
    else
        _G["CPPimpMeAttrRune"..(id-6).."Name"]:SetFocus()
    end
end


function Pimp.OnStatCtrlTierShow(this)

    local slot = this:GetParent():GetID()
    local info={ notCheckable = 1 }

    for i,data in pairs(this.levels or {}) do
		info.text = data[1]
        info.value = data[2]
        info.func = function(this)
            Pimp.SetStat(slot, this.value)
            end
		UIDropDownMenu_AddButton( info, 1 )
    end
end

function Pimp.OnStatSelSearch(this)
    Pimp.DoStatSearch(this:GetID(), this)
end


function Pimp.DoStatSearch(slot_id, parent)
    CPStatSearch.slot = slot_id
    if parent then
        CPStatSearch:ClearAllAnchors()
        CPStatSearch:SetAnchor("TOPRIGHT", "TOPRIGHT", parent, 10, 18 )
    end
    CPStatSearch:Show()
end


function Pimp.StatSearch_OnShow(this)
    Pimp.Selection = nil

    CPStatSearchTitle:SetText(Pimp.GetStatLable(this.slot))

    CPStatSearchSearchBox:SetText("")
    CPStatSearchSearchBoxBack:SetText(CP.L.PIMP_FILTER)
    CP.Pimp.StatSearch_UpdateList()
end


function Pimp.StatSearch_UpdateList()
    local text = CPStatSearchSearchBox:GetText()
    if text=="" then  text=nil end

    local isrune = (CPStatSearch.slot>6)
    Pimp.Stats = CP.DB.GetBonusGroupList(isrune, text)

    CPStatSearchItemSB:SetValueStepMode("INT")
    CPStatSearchItemSB:SetMinMaxValues(0,math.max(0,(#Pimp.Stats)-STATSEARCH_FIELD))

    Pimp.StatSearch_ListUpdate()
end

function Pimp.StatSearch_FilterFocus(this, got_focus)
    _G[this:GetName().."Back"]:Hide()
    if not got_focus and this:GetText()=="" then
        _G[this:GetName().."Back"]:Show()
    end
end

function Pimp.StatSearch_ListUpdate()

     for i=1,STATSEARCH_FIELD do
        local d = Pimp.Stats[i + CPStatSearchItemSB:GetValue()]
        local line = "CPStatSearchItem"..i
        if d then

            _G[line.."Name"]:SetText(d[2])
            _G[line.."Value"]:SetText(table.concat(d[3],", "))
            _G[line]:Show()
            _G[line]:SetID(d[1])
            if Pimp.Selection == d[1] then
                _G[line.."Highlight"]:Show()
            else
                _G[line.."Highlight"]:Hide()
            end
        else
            _G[line]:Hide()
        end
    end
end

function Pimp.StatSearch_OnHide(this)

    if Pimp.Selection then
        Pimp.SetStat(CPStatSearch.slot, Pimp.Selection)
        Pimp.Selection = nil
    end

    Pimp.Stats = nil
end

function Pimp.StatSearch_ItemClicked(this,key)
    Pimp.Selection = this:GetID()
    Pimp.StatSearch_ListUpdate()
end


function Pimp.StatSearch_Close()
    CPStatSearch:Hide()
end

function Pimp.StatSearch_Cancel()
    Pimp.Selection = nil
    CPStatSearch:Hide()
end

function Pimp.StatSearch_ItemOnEnter(this)
    GameTooltip:SetOwner(this, "ANCHOR_TOPRIGHT", -10, 0)

    local name,lvl,grp = CP.DB.GetBonusInfo(this:GetID())
    GameTooltip:SetText(name)


    local ids = {{lvl,this:GetID()}}
    if grp then
        ids = CP.DB.GetBonusGroupLevels(grp)
    end

    for _,d in ipairs(ids) do

        local effect = CP.DB.GetBonusEffect(d[2])
        if #effect>0 then
            GameTooltip:AddLine(d[1],1,0.82,0)
            local left={}
            local right={}
            for i=1,#effect,2 do
                table.insert(left, TEXT("SYS_WEAREQTYPE_"..effect[i]))
                table.insert(right,effect[i+1])
            end
            GameTooltip:AddDoubleLine(" "..table.concat(left,"/"), table.concat(right,"/"))
        end
    end

    GameTooltip:Show()
end

function Pimp.StatSearch_ItemOnLeave()
    GameTooltip:Hide()
end



-----------------------------------
-- Item Link
function Pimp.UsedRunes(item_data)
    return   ( item_data.runes[1]~=0 and 1 or 0)
           + ( item_data.runes[2]~=0 and 1 or 0)
           + ( item_data.runes[3]~=0 and 1 or 0)
           + ( item_data.runes[4]~=0 and 1 or 0)

end

function Pimp.GenerateLink(item_data, prefix)

    local free_slots = item_data.rune_slots - Pimp.UsedRunes(item_data)
    assert(free_slots>=0 and item_data.rune_slots<5)

    local temphex= string.format("%x%02x%02x%02x",
        item_data.unk1,
        item_data.plus + 32*free_slots,
        (item_data.tier+10) + 32*item_data.rarity,
        item_data.max_dura)

    local function s(a,b)
        if a>0 then a=a-0x70000 end
        if b>0 then b=b-0x70000 end
        return a + (2^16)*b
    end

    local data=
    {
        item_data.id,
        item_data.bind,
        tonumber(temphex,16),
        s(item_data.stats[1],item_data.stats[2]),
        s(item_data.stats[3],item_data.stats[4]),
        s(item_data.stats[5],item_data.stats[6]),
        item_data.runes[1],
        item_data.runes[2],
        item_data.runes[3],
        item_data.runes[4],
        item_data.dura*100
    }

    data[12] = CP.Utils.CalculateItemLinkHash(data)

    local r,g,b = GetItemQualityColor(GetQualityByGUID( item_data.id ))

    local link = string.format("|Hitem:%x %x %x %x %x %x %x %x %x %x %x %x|h|cff%02x%02x%02x[%s%s]|r|h",
        data[1], data[2], data[3], data[4],data[5], data[6], data[7], data[8],data[9], data[10], data[11], data[12],
        r*256,g*256,b*256, -- Note: another RoM enigma
        prefix or "",
        item_data.name
        )

    return link
end

function Pimp.GenerateLinkByID(item_id, prefix)
    local item_data = CP.DB.GenerateItemDataByID(item_id)

    return Pimp.GenerateLink(item_data, prefix)
end

function Pimp.ExtractLink(itemlink)
    local data_str, name = string.match(itemlink, "|Hitem:([%x ]+)|h|c%x%x%x%x%x%x%x%x%[(.-)%]|r|h")
    assert(name and data_str, "not a valid Item link")

    local data = Nyx.Split(data_str, " ", 14)
    while #data<14 do table.insert(data,"0") end

    local item_data = {}
    item_data.name = name

    item_data.id =  tonumber(data[1], 16)
    item_data.bind = tonumber( string.sub(data[2],-2,-1) , 16)
    item_data.bind_flag = tonumber( string.sub(data[2],-4,-3) , 16) or 0

    item_data.unk1 = tonumber( string.sub(data[3],-8,-7) , 16) or 0
    item_data.max_dura = tonumber( string.sub(data[3],-2,-1), 16) or 100
    item_data.dura = tonumber( data[11], 16) / 100

    local runesPlus = tonumber( string.sub(data[3],-6,-5) , 16) or 0
    local tier_rar = tonumber( string.sub(data[3],-4,-3), 16) or 0
    local free_slots = math.floor(runesPlus / 32)

    item_data.plus = runesPlus % 32
    item_data.rarity = math.floor(tier_rar / 32)
    item_data.tier = (tier_rar % 32 )-10


    local function s(txt)
        local n = tonumber(txt,16) or 0
        if n>0 then n = n + 0x70000 end
        return n
    end

    item_data.stats={
            s( string.sub(data[4],-4,-1)), s( string.sub(data[4],-8,-5)),
            s( string.sub(data[5],-4,-1)), s( string.sub(data[5],-8,-5)),
            s( string.sub(data[6],-4,-1)), s( string.sub(data[6],-8,-5)) }

    item_data.runes={
            tonumber( data[ 7], 16) or 0,
            tonumber( data[ 8], 16) or 0,
            tonumber( data[ 9], 16) or 0,
            tonumber( data[10], 16) or 0 }

    item_data.rune_slots = free_slots + Pimp.UsedRunes(item_data)

    if item_data.max_dura==0 then item_data.max_dura=100 end
    if item_data.tier<0 then item_data.tier=0 end
    if item_data.dura==0 then item_data.dura=CP.DB.GetItemDura(item_data.id) end

    return item_data
end



