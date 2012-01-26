--[[
    CharPlan

Notes:
- gibt es items die auf rassen/geschlecht begrenzt sind, oder z.B. ein minimum an STR brauchen?
   (gibt es in der DB..die frage ist ob ich die besser rausschmeisse)
]]



--[[
Item data:
    icon
From LINK:
    item_id
    name
    bind
    plus
    tier
    max_dura
    stats[6]
    rune_slots
    runes[4]

]]


local CP = {}
_G.CP = CP

CP_Storage={}


CP.version       = "@project-version@"
--@do-not-package@
CP.version       = "v1.0 (alpha)"
--@end-do-not-package@


------------------------------
SLASH_charplan1="/cp"
SLASH_charplan2="/charplan"
SlashCmdList["charplan"] = function(_,msg)
    if msg~="" then
        local base = "interface/addons/charplan/"
        if string.find(msg,"^t") then
            dofile(base.."test/test.lua")
        elseif string.find(msg,"^r") then
            dofile(base.."charplan.lua")
            dofile(base.."cp_calc.lua")
            dofile(base.."cp_db.lua")
            dofile(base.."cp_pimpme.lua")
            dofile(base.."cp_search.lua")
            dofile(base.."sp_storage.lua")
        end

        return
    end

    ToggleUIFrame(CPFrame)
end




local Nyx = LibStub("Nyx")

Nyx.LoadLocalesAuto("interface/addons/charplan/locales/")

function CP.Debug(txt)
    --@debug@
    DEFAULT_CHAT_FRAME:AddMessage("CP: "..txt,1,0.5,0.5)
    --@end-debug@
end

function CP.OnLoad(this)
    UIPanelBackdropFrame_SetTexture( this, "Interface/Common/PanelCommonFrame", 256 , 256 )

    this:RegisterEvent("VARIABLES_LOADED")
 end


function CP.OnEvent(this,event)
    if CP[event] then
        CP[event]()
    end
end


function CP.OnShow(this)

    CPFrameClassFrameLeftText:SetText(UnitClass("player"))
	CPFrameClassFrameRightText:SetText(UnitLevel("player"))

    CP.UpdateTitle()
    CP.DB.Load()
    CP.Calc.Init()
    CP.UpdateEquipment()
end

function CP.UpdateTitle()
    local stored = CP.Storage.GetLoadedName()
    local name = CP.L.TITLE.." "..CP.version.." - " .. (stored or CP.L.TITLE_EMPTY)

    CPFrameTitle:SetText(name)
end

function CP.OnHide()
    CP.DB.Release()
    CP.Calc.Release()

    CP.Stats=nil
    CP.Stats_Desc=nil
end



function CP.VARIABLES_LOADED()
    CP.Items = {}

    CP.ori_Hyperlink_Assign = Hyperlink_Assign
    Hyperlink_Assign = CP.Hooked_Hyperlink_Assign

    CP.Storage.Init()

    --@do-not-package@
    SlashCmdList["charplan"](nil,"test")
    --@end-do-not-package@
end


function CP.ApplyBagItem(inv_slot, bag_slot, hidden)

    local icon = GetGoodsItemInfo( bag_slot )
    local link = GetBagItemLink( bag_slot )

    assert(icon~="" and link)

    local item_data = CP.Pimp.ExtractLink(link)
    item_data.icon = icon

    CP.ApplyItem(item_data, inv_slot, hidden)
end


function CP.ApplyLinkItem(link)
    local item_data = CP.Pimp.ExtractLink(link)
    item_data.icon = CP.DB.GetItemIcon(item_data.id)

    local inv_slot = CP.FindSlotForItem(item_data.id)
    CP.ApplyItem(item_data, inv_slot)
end


function CP.ApplyItem(item_data, inv_slot, hidden)
    assert(CP.EquipButtons[inv_slot])

    if not CP.DB.IsItemAllowedInSlot(item_data.id, inv_slot) then
        CP.Debug(string.format("item not allowed in that slot: %i - %s slot:%i",item_data.id,item_data.name,inv_slot))
    --  return
    end

    if CP.DB.IsWeapon2Hand(item_data.id) then
        CP.Items[16]=nil
        if inv_slot==16 then inv_slot=15 end
    end

    CP.Items[inv_slot] = item_data

    if not hidden then
        CP.UpdateEquipment()
    end
end


function CP.FindSlotForItem(item_id)
    local s1,s2, force1 = CP.DB.GetItemPositions(item_id)

    if not force1 and CP.Items[s1] and s2 and not CP.Items[s2] then
        return s2
    end

    return s1
end


function CP.UpdateEquipment()
   for id, button in pairs(CP.EquipButtons) do
       local item = CP.Items[id]
       if item and item.icon then
           SetItemButtonTexture(button, item.icon)
       else
           SetItemButtonTexture(button, button.backgroundTextureName)
       end
    end

    CP.UpdatePoints()
end

function CP.UpdatePoints()

    CP.Stats = {}
    CP.Stats_Desc = {}

    CP.Calc.RecalcPoints(CP.Stats, CP.Stats_Desc)

    local att=CP.Calc.STATS

    for id,frame in pairs(CP.AttributeFields) do
        ctrl = _G[frame:GetName().."Value"]
        assert(att[id], "stat:"..id.." not defined "..frame:GetName())
        ctrl:SetText(math.floor(CP.Stats[att[id]]))
    end
end




function CP.PimpStart(slot)
    local data = CP.Items[CPEquipButtonMenu.Slot]
    assert(data)
    CP.Pimp.PimpItem( data )
end

function CP.PimpFinished()
    CP.UpdatePoints()
end

function CP.PimpUpdate()

    local new_vals = {}
    local temp_desc = {}

    CP.Calc.RecalcPoints(new_vals, temp_desc)


    local att=CP.Calc.STATS

    for id,frame in pairs(CP.AttributeFields) do
        ctrl = _G[frame:GetName().."Value"]

        local old, new = CP.Stats[att[id]] , new_vals[att[id]]
        if old > new then
            ctrl:SetText("|cffff2020"..math.floor(new))
        elseif old < new then
            ctrl:SetText("|cff20ff20"..math.floor(new))
        else
            ctrl:SetText(math.floor(new))
        end
    end
end
-----------------------------------
-- Menu
function CP.OnMenuLoad(this)
    UIDropDownMenu_Initialize( this, CP.OnMenuShow, "MENU")
end

function CP.OnMenuShow(this)
	local info
    local save_list = CP.Storage.GetSavedList()
    local loaded_name = CP.Storage.GetLoadedName()

	if( UIDROPDOWNMENU_MENU_LEVEL == 1 ) then

		info = {notCheckable = 1}
		info.text = CP.L.MENU_IMPORT
        info.func = function() CP.Storage.LoadCurrentEquipment() end
		UIDropDownMenu_AddButton( info, 1 )

        if #save_list>0 then
            info = {notCheckable = 1, hasArrow = 1}
            info.text = CP.L.MENU_LOAD
            info.value="load"
            UIDropDownMenu_AddButton( info, 1 )
        end

        info = {notCheckable = 1}
        info.text = CP.L.MENU_SAVE
        info.func = function() CP.Storage.SaveItems(loaded_name) end
        UIDropDownMenu_AddButton( info, 1 )

        if loaded_name then
            info = {notCheckable = 1}
            info.text = CP.L.MENU_SAVEAS
            info.func = function() CP.Storage.SaveItems() end
            UIDropDownMenu_AddButton( info, 1 )
        end

        if #save_list>0 then
            info = {notCheckable = 1, hasArrow = 1}
            info.text = CP.L.MENU_DEL
            info.value="del"
            UIDropDownMenu_AddButton( info, 1 )
        end

    elseif( UIDROPDOWNMENU_MENU_LEVEL == 2 ) then

        for _,name in ipairs(save_list) do
            info = {notCheckable = 1}
            info.text = name

            if UIDROPDOWNMENU_MENU_VALUE=="load" then
                info.func = function() CP.Storage.LoadItems(name) CloseDropDownMenus() end
            elseif UIDROPDOWNMENU_MENU_VALUE=="del" then
                info.func = function() CP.Storage.DeleteItems(name) CloseDropDownMenus() end
            end

            UIDropDownMenu_AddButton( info, 2 )
        end
    end
end


function CP.Hooked_Hyperlink_Assign(link, key)
	CP.ori_Hyperlink_Assign(link, key)
	if (key ~= "RBUTTON" ) then return 	end

	local _type, _data, _name = ParseHyperlink(link)
	if(_type=="item") then
  		local info = {}
		info.text = CP.L.CONTEXT_MENU
        info.notCheckable = 1
		info.func = function()
            CP.DB.Load()
			CP.ApplyLinkItem(link)
            CP.DB.Release()
		end
		UIDropDownMenu_AddButton(info, 1)


		UIDropDownMenu_Refresh(ChatFrameDropDown)
	end
end

-----------------------------------
-- EquipItem Buttons
function CP.EquipItem_OnLoad(this)
    CP.EquipButtons = CP.EquipButtons or {}

    this:RegisterForClicks("LeftButton", "RightButton")

    local slotName = string.sub(this:GetName(), string.len("CPEquipmentFrameEquip")+1)
	local slotId
    slotId, this.backgroundTextureName = GetInventorySlotInfo(slotName)
    assert(slotId,slotName..":"..tostring(slotId))
    this:SetID(slotId)
    CP.EquipButtons[slotId]=this

end


function CP.EquipItem_OnEnter(this)
    local item = CP.Items[this:GetID()]

    if item then
        GameTooltip:SetOwner(this, "ANCHOR_TOPRIGHT", -10, 0)
        GameTooltip:SetHyperLink(CP.Pimp.GenerateLink(item))
    end
end


function CP.EquipItem_OnLeave(this)
    GameTooltip1:Hide()
    GameTooltip2:Hide()
    GameTooltip:Hide()
end


function CP.EquipItem_OnReceiveDrag( this )

    if CursorItemType()~="bag" then
        -- TODO: add more drop senders
        DEFAULT_CHAT_FRAME:AddMessage("only Bag is supported right now")
        return
    end

    ItemClipboard_Clear()

    local pos=GetCursorItemInfo()
    assert(pos)

    CP.ApplyBagItem(this:GetID(), pos)
end


function CP.EquipItem_OnClick(this, key)
    if( key == "RBUTTON") then
        GameTooltip:Hide()
        CPEquipButtonMenu.Slot = this:GetID()
        ToggleDropDownMenu(CPEquipButtonMenu, 1,nil,"cursor", 1 ,1 );
    else
        local item_data = CP.Items[this:GetID()]
        if item_data then
            CP.Pimp.PimpItem(item_data)
        else
            CP.Search.ForSlot(this:GetID())
        end
     end
end

function CP.EquipItem_ShowMenu( this )

    local info = {}
    info.notCheckable = 1

    if( UIDROPDOWNMENU_MENU_LEVEL == 1 ) then
        --@debug@
        info.text   = string.format(CP.L.CONTEXT_PIMPME,"TEST - Ardmonds Helm")
        info.func   = function()
                CP.Pimp.PimpItemLink("|Hitem:377a0 3 358e0c74 d41fd41a d56bd56d d48fd56c 0 0 0 0 2d50 82a0|h|cffc805f8[Ardmonds Helm]|r|h")
            end
        UIDropDownMenu_AddButton(info)
        --@end-debug@


        local data = CP.Items[CPEquipButtonMenu.Slot]
        if data then
            info.text = string.format(CP.L.CONTEXT_PIMPME,data.name)
            info.func = function() CP.PimpStart(CPEquipButtonMenu.Slot) end
            UIDropDownMenu_AddButton(info)
        end

        info.text = CP.L.CONTEXT_SEARCH
        info.func = function() CP.Search.ForSlot(CPEquipButtonMenu.Slot) end
        UIDropDownMenu_AddButton(info)

        info.text = CP.L.CONTEXT_CLEAR
        info.func = function()
                CP.Items[CPEquipButtonMenu.Slot]=nil
                CP.UpdateEquipment()
            end
        UIDropDownMenu_AddButton(info)
    end

end

-----------------------------------
-- Attribute fields
function CP.Attribute_OnLoad( this )
    CP.AttributeFields=CP.AttributeFields or {}

    local name = string.sub(this:GetName(), string.len("CPAttributeFrameValue")+1)
    CP.AttributeFields[name]= this
    this:SetID(CP.Calc.STATS[name])

    _G[this:GetName().."Label"]:SetText(CP.L.STAT_NAMES[name])
end


function CP.Attribute_OnEnter(this)
    GameTooltip:SetOwner(this, "ANCHOR_TOPRIGHT", -10, 0)

    local stat_id = this:GetID()
    local stat = CP.Calc.ID2StatName(stat_id)

    local txt = string.format("%s%s%s (%i)", NORMAL_FONT_COLOR_CODE,
                CP.L.STAT_NAMES[stat], FONT_COLOR_CODE_CLOSE, CP.Stats[stat_id] or 0)

	GameTooltip:SetText(txt)
    for i=1,#(CP.Stats_Desc[stat_id].left) do
  		GameTooltip:AddDoubleLine(CP.Stats_Desc[stat_id].left[i], CP.Stats_Desc[stat_id].right[i])
    end

	GameTooltip:Show()
end


function CP.AttributeTitle_OnLoad( this )

    local name = string.sub(this:GetName(), string.len("CPAttributeTitle")+1)
    _G[this:GetName().."Label"]:SetText(CP.L.STAT_NAMES[name])
end





