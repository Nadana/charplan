--[[
    CharPlan - Search

    Item search dialog
]]

local CP = _G.CP
local Search = {}
CP.Search = Search

local MAX_LINES=10
local HEADER_COUNT=4
local OVERDURA=110

function Search.OnLoad(this)

    UIPanelBackdropFrame_SetTexture( this, "Interface/Common/PanelCommonFrame", 256, 256 )

    CPSearchTitle:SetText(CP.L.SEARCH_TITLE)

    CPSearchHead1:SetText(CP.L.SEARCH_NAME)
    CPSearchHead2:SetText(CP.L.SEARCH_LEVEL)
    CPSearchHead3:SetText(CP.L.SEARCH_BASE_STATS)
    CPSearchHead4:SetText(CP.L.SEARCH_STATS)
    CPSearchFilterStatLessText:SetText(CP.L.SEARCH_NOSTATLESS)
    CPSearchFilterSetsText:SetText(CP.L.SEARCH_ONLYSET)
    CPSearchFilterNameLabel:SetText(CP.L.SEARCH_NAME)
    CPSearchFilterLevelLabel:SetText(CP.L.SEARCH_LEVEL)

    CPSearchPimpPlus:SetText(CP.L.PIMP_PLUS)
    CPSearchPimpTier:SetText(CP.L.PIMP_TIER)
    CPSearchPowerModifyText:SetText(string.format(CP.L.SEARCH_POWER_MODIFY , OVERDURA))

    CPSearchTakeIt1:SetText(CP.L.SEARCH_USE_SLOT1)
    CPSearchTakeIt2:SetText(CP.L.SEARCH_USE_SLOT2)
end


function Search.ShowSearch(slot_id, item_id)
    if CP.DB.IsSlotType(slot_id) ~= CP.DB.IsSlotType(Search.slot) then
        Search.ClearSettings()
    end
    Search.slot = slot_id
    Search.selection = item_id

    local text = CP.L.SEARCH_FILTER_NIL
    if Search.slot then
        text = TEXT(string.format("SYS_EQWEARPOS_%02i",slot_id))
    end

    UIDropDownMenu_SetText(CPSearchFilterSlot,text)

    Search.FindItems()
    CPSearch:Show()
end

function Search.ClearSettings()
    Search.type_filter={}
    for i=0,24 do Search.type_filter[i]=true end
end

function Search.OnShow(this)
    this:ResetFrameOrder()
    Search.UpdateSlotInfo()
end

function Search.OnHide()
    Search.Items=nil
end

function Search.OnLoadFilterTypeMenu(this)
    Search.ClearSettings()

    UIDropDownMenu_SetWidth(this, 100)
    UIDropDownMenu_Initialize( this, Search.OnTypeFilterShow)
    UIDropDownMenu_SetText(this, CP.L.SEARCH_TYPE)
end

function Search.OnTypeFilterShow(this)
    local slot_type = CP.DB.IsSlotType(Search.slot)

    local filters={
        [1]= { -- Armor
            [TEXT("SYS_ARMORTYPE_00")]=0, -- Plate
            [TEXT("SYS_ARMORTYPE_01")]=1, -- Mail
            [TEXT("SYS_ARMORTYPE_02")]=2, -- Leather
            [TEXT("SYS_ARMORTYPE_03")]=3, -- Cloth
            },
        [2]= { -- Cloak
            [TEXT("SYS_ARMORTYPE_03")]=3, -- Cloth
            },
        [3]= { -- Jewelery
            [TEXT("SYS_ARMORTYPE_07")]=7, -- Jewelery
            },
        [4]= { -- Primary Weapon
            [TEXT("SYS_WEAPON_TYPE01")]=9,  --="Schwert"
            [TEXT("SYS_WEAPON_TYPE02")]=10, --="Dolch"
            [TEXT("SYS_WEAPON_TYPE03")]=11, --="Stab"
            [TEXT("SYS_WEAPON_TYPE04")]=12, --="Axt"
            [TEXT("SYS_WEAPON_TYPE05")]=13, --="Einhandhammer"
            [TEXT("SYS_WEAPON_TYPE06")]=14, --="Zweihandschwert"
            [TEXT("SYS_WEAPON_TYPE07")]=15, --="Zweihandstab"
            [TEXT("SYS_WEAPON_TYPE08")]=16, --="Zweihandaxt"
            [TEXT("SYS_WEAPON_TYPE09")]=17, --="Beidhändiger Hammer"
            [TEXT("SYS_WEAPON_TYPE10")]=18, --="Stangenwaffe"
            },
        [5]= { -- Secondary Weapon
            [TEXT("SYS_ARMORTYPE_05")]=5,   -- Shield
            [TEXT("SYS_ARMORTYPE_06")]=6,   -- Talisman
            [TEXT("SYS_WEAPON_TYPE01")]=9,  --="Schwert"
            [TEXT("SYS_WEAPON_TYPE02")]=10, --="Dolch"
            [TEXT("SYS_WEAPON_TYPE03")]=11, --="Stab"
            [TEXT("SYS_WEAPON_TYPE04")]=12, --="Axt"
            [TEXT("SYS_WEAPON_TYPE05")]=13, --="Einhandhammer"
            [TEXT("SYS_WEAPON_TYPE10")]=18, --="Stangenwaffe"
            },
        [6]= { -- Ranges Weapon
            [TEXT("SYS_WEAPON_TYPE11")]=19, --="Bogen"
            [TEXT("SYS_WEAPON_TYPE12")]=20, --="Armbrust"
            [TEXT("SYS_WEAPON_TYPE13")]=21, --="Feuerwaffe"
            --[TEXT("SYS_WEAPON_TYPE14")]=22, --="Pfeil"
            --[TEXT("SYS_WEAPON_TYPE15")]=23, --="Kugeln"
            --[TEXT("SYS_WEAPON_TYPE16")]=24, --="Wurfwaffen"
            },
        [7]= { -- Back
            [TEXT("SYS_ARMORTYPE_03")]=3, -- Cloth
            },
    }

    local vals = filters[slot_type] or {}
    if not Search.slot then
        vals = {}
        for _,data in pairs(filters) do
            for name,id in pairs(data) do
                vals[name] = id
            end
        end
    end

    for name,id in pairs(vals) do
        local info={}
        info.text=name
        info.checked = Search.type_filter[id]
        info.value = id
        info.func = Search.OnTypeFilterSelect
        info.keepShownOnClick = 1
		UIDropDownMenu_AddButton( info, 1 )
    end
end

function Search.OnTypeFilterSelect(this)
    Search.type_filter[this.value] = not Search.type_filter[this.value]
    Search.FindItems()
end


function Search.OnLoadFilterSlotMenu(this)
    UIDropDownMenu_SetWidth(this, 100)
    UIDropDownMenu_Initialize( this, Search.OnSlotFilterShow)
    UIDropDownMenu_Refresh(this)
end


function Search.OnSlotFilterShow(this)
    local slots={0,1,2,3,4,5,6,7,8,10,11,13,15,16,21}

    local info={
        text=CP.L.SEARCH_FILTER_NIL,
        checked = (Search.slot==nil),
        value = nil,
        func = Search.OnSlotFilterSelect,
    }
    UIDropDownMenu_AddButton( info, 1 )

    for _,id in ipairs(slots) do
      info.text=TEXT(string.format("SYS_EQWEARPOS_%02i",id))
      info.checked = (Search.slot==id)
      info.value = id
      UIDropDownMenu_AddButton( info, 1 )
    end
end

function Search.OnSlotFilterSelect(this)
    UIDropDownMenu_SetSelectedID(CPSearchFilterSlot, this:GetID())
    Search.slot=this.value
    Search.FindItems()
end

function Search.OnLoadFilterPlusMenu(this)
    UIDropDownMenu_SetWidth(this, 40)
    UIDropDownMenu_Initialize(this, Search.OnLoadFilterPlusShow)
    UIDropDownMenu_SetSelectedValue(this, 0)
end

function Search.OnLoadFilterPlusShow(button)
    local info={}
    for i=0,16 do
        info.text = "+"..i
        info.value = i
        info.notCheckable=1
        info.func = Search.OnLoadFilterPlusClicked
        UIDropDownMenu_AddButton(info)
    end
end

function Search.OnLoadFilterPlusClicked(button)
    UIDropDownMenu_SetSelectedValue(CPSearchFilterPlus, button.value)
    Search.UpdateList()
end

function Search.OnLoadFilterTierMenu(this)
    UIDropDownMenu_SetWidth(this, 40)
    UIDropDownMenu_Initialize(this, Search.OnLoadFilterTierShow)
    UIDropDownMenu_SetSelectedValue(this, 0)
end

function Search.OnLoadFilterTierShow(button)
    local info={}
    for i=0,20 do
        info.text = "+"..i
        info.value = i
        info.notCheckable=1
        info.func = Search.OnLoadFilterTierClicked
        UIDropDownMenu_AddButton(info)
    end
end

function Search.OnLoadFilterTierClicked(button)
    UIDropDownMenu_SetSelectedValue(CPSearchFilterTier, button.value)
    Search.UpdateList()
end

local function GetFilterInfo()

    local info={}

    info.slot = Search.slot
    info.name = CPSearchFilterName:GetText()
    info.level_min = tonumber(CPSearchFilterLevelMin:GetText())
    info.level_max = tonumber(CPSearchFilterLevelMax:GetText())
    info.no_empty_items = CPSearchFilterStatLess:IsChecked()
    info.itemset_only = CPSearchFilterSets:IsChecked()

    info.types = {}
    for id,v in pairs(CP.Search.type_filter) do
        if v then
            table.insert(info.types,id)
        end
    end

    return info
end


function Search.FindItems()

    local filter_info = GetFilterInfo()

    Search.Items = CP.DB.FindItems(filter_info)

    CPSearchItemsSB:SetValueStepMode("INT")
    CPSearchItemsSB:SetMinMaxValues(0,math.max(0,(#Search.Items)-MAX_LINES))

    if Search.cur_sort then
        Search.DoSort(Search.cur_sort)
    end
    Search.ScrollToSelection()
end

function Search.HeaderClicked(this)
    assert(this:GetID()<=HEADER_COUNT)
    for i=1,HEADER_COUNT do
        _G["CPSearchHead"..i.."SortIcon"]:Hide()
    end

    local id = this:GetID()
    if Search.cur_sort == id or Search.cur_sort == -id then
        Search.cur_sort = -Search.cur_sort
    else
        Search.cur_sort = id
    end

    if Search.cur_sort>0 then
        _G[this:GetName() .. "SortIcon"]:SetFile("Interface/chatframe/chatframe-scrollbar-buttondown")
        _G[this:GetName() .. "SortIcon"]:Show()
    else
        _G[this:GetName() .. "SortIcon"]:SetFile("Interface/chatframe/chatframe-scrollbar-buttonup")
        _G[this:GetName() .. "SortIcon"]:Show()
    end

    Search.DoSort(Search.cur_sort)
end


function Search.DoSort(column)

    local cache={}

    local function GetPriBonus(item_id)
        local cached = cache[item_id]
        if cached then return cached end

        local att1,att2 = CP.DB.PrimarAttributes(item_id)

        local item = CP.DB.GenerateItemDataByID(item_id)
        item.plus= UIDropDownMenu_GetSelectedValue(CPSearchFilterPlus) or 0
        item.tier= UIDropDownMenu_GetSelectedValue(CPSearchFilterTier) or 0
		if CPSearchPowerModify:IsChecked() then
			item.dura = OVERDURA
			item.max_dura = CP.DB.CalcMaxDura(item.id, OVERDURA)
		end

        local effect = CP.Calc.GetItemBonus(item)
        local boni=effect[att1] + (att2 and effect[att2])
        cache[item_id] = boni
        return boni
    end

    local function GetNonPriBonus(item_id)
        local cached = cache[item_id]
        if cached then return cached end

        local att1,att2 = CP.DB.PrimarAttributes(item_id)

        local item = CP.DB.GenerateItemDataByID(item_id)
        item.plus= UIDropDownMenu_GetSelectedValue(CPSearchFilterPlus) or 0
        item.tier= UIDropDownMenu_GetSelectedValue(CPSearchFilterTier) or 0
		if CPSearchPowerModify:IsChecked() then
			item.dura = OVERDURA
			item.max_dura = CP.DB.CalcMaxDura(item.id, OVERDURA)
		end
        local boni=0
        local effect = CP.Calc.GetItemBonus(item)
        for id,val in pairs(effect) do
            if id~=att1 and id~=att2 then
                boni = boni + val
            end
        end

        cache[item_id] = boni
        return boni
    end

    local sorts=
    {
        [1] = function (id1,id2)
                return TEXT("Sys"..id1.."_name")<TEXT("Sys"..id2.."_name")
            end,

        [2] = function (id1,id2)
                local l1 = CP.DB.GetItemInfo(id1)
                local l2 = CP.DB.GetItemInfo(id2)
                return l1>l2
            end,

        [3] = function (id1,id2)
                return GetPriBonus(id1) > GetPriBonus(id2)
            end,

        [4] = function (id1,id2)
               return GetNonPriBonus(id1) > GetNonPriBonus(id2)
            end,
    }

    if column>0 then
        table.sort(Search.Items, sorts[column])
    else
        table.sort(Search.Items, function (a,b) return sorts[-column](b,a) end)
    end


    Search.ScrollToSelection()
end


function Search.ScrollToSelection()

    if Search.selection then
        line = 1
        for i,id in ipairs(Search.Items) do
            if id == Search.selection then
                line = i
                break
            end
        end

        local top_pos = CPSearchItemsSB:GetValue()
        if top_pos>line then
            CPSearchItemsSB:SetValue(line-1)
        elseif top_pos+MAX_LINES<line then
            CPSearchItemsSB:SetValue(math.max(line-MAX_LINES))
        end
    end

    Search.UpdateList()
end

function Search.UpdateList()

    local top_pos = CPSearchItemsSB:GetValue()

    for i=1,MAX_LINES do
        local base_name = "CPSearchItem"..i

        local item_id = Search.Items[i+top_pos]

        if item_id then
            local item_data = Search.GetPimpedItemData(item_id)
            Search.UpdateItem(base_name,item_data)

            if item_id == Search.selection then
                _G[base_name.."Highlight"]:Show()
            else
                _G[base_name.."Highlight"]:Hide()
            end
            _G[base_name]:Show()
        else
            _G[base_name]:Hide()
        end
    end
end

function Search.UpdateItem(base_name, item)

    SetItemButtonTexture(_G[base_name.."Item"], item.icon )

    local r,g,b = GetItemQualityColor(GetQualityByGUID( item.id ))
    local col=string.format("|cff%02x%02x%02x",r*255,g*255,b*255)
    _G[base_name.."Name"]:SetText(col..TEXT("Sys"..item.id.."_name"))

    local level, set = CP.DB.GetItemInfo(item.id)
    local setname = set and TEXT("Sys"..set.."_name") or ""
    _G[base_name.."Set"]:SetText(setname)
    _G[base_name.."Level"]:SetText(level or "")


    local boni=CP.Calc.GetItemBonus(item)

    local txt = ""
    local attA,attB = CP.DB.PrimarAttributes(item.id)
    if attA and boni[attA]~=0 then
        local n = CP.Calc.ID2StatName(attA)
        txt = txt..(CP.L.STAT_SHORTS[n])..": "..boni[attA].."\n"
        boni[attA] = nil
    end
    if attB and boni[attB]~=0 then
        local n = CP.Calc.ID2StatName(attB)
        txt = txt..(CP.L.STAT_SHORTS[n])..": "..boni[attB].."\n"
        boni[attB] = nil
    end
    _G[base_name.."Effect"]:SetText(txt)

    local txt=""
    local txt2=""
    local i=0
    for eff,value in pairs(boni) do
        if i<3 then
            txt = txt.."+"..value.." "..TEXT("SYS_WEAREQTYPE_"..eff).."\n"
        else
            txt2 = txt2.."+"..value.." "..TEXT("SYS_WEAREQTYPE_"..eff).."\n"
        end
        i=i+1
    end

    _G[base_name.."Boni"]:SetText(txt)
    _G[base_name.."Boni2"]:SetText(txt2)
end


function Search.UpdateSlotInfo()
    local s1,s2
    if Search.selection then
        s1,s2 = CP.DB.GetItemPositions(Search.selection)
    else
        s1 = Search.slot
        if s1==11 or s1==12 then s1,s2=11,12 end
        if s1==13 or s1==14 then s1,s2=13,14 end
    end

    if s1 then
        CPSearchTakeIt1:Show()
        CPSearchTakeIt1Item:Show()
        SetItemButtonTexture(CPSearchTakeIt1Item, CP.GetSlotTexture(s1))
    else
        CPSearchTakeIt1:Hide()
        CPSearchTakeIt1Item:Hide()
    end

    CPSearchTakeIt1:SetText(CP.L.SEARCH_USE_SLOT1)
    if s2 then
        CPSearchTakeIt2:Show()
        CPSearchTakeIt2Item:Show()
        SetItemButtonTexture(CPSearchTakeIt2Item, CP.GetSlotTexture(s2))
    else
        CPSearchTakeIt2:Hide()
        CPSearchTakeIt2Item:Hide()
        if Search.slot == 16 then   -- "Slot 2" for right hand
          CPSearchTakeIt1:SetText(CP.L.SEARCH_USE_SLOT2)
        end
    end
end

function Search.SelectItem(item_id)
    if item_id ~= Search.selection then
        Search.selection = item_id
        Search.ScrollToSelection()
        Search.UpdateSlotInfo()
    end
end

function Search.OnItemClick(this, key)

  local top_pos = CPSearchItemsSB:GetValue()
  local new_item = Search.Items[this:GetID()+top_pos]
  if key == "RBUTTON" then
    GameTooltip:Hide()
    CPSearchItemMenu.item_id = new_item
    ToggleDropDownMenu(CPSearchItemMenu, 1,this,"cursor", 1 ,1 )
    return
  elseif key == "LBUTTON" and (IsShiftKeyDown() or IsCtrlKeyDown()) then
    local item_data = Search.GetPimpedItemData(new_item)
    if IsCtrlKeyDown() then
        local link = CP.Pimp.GenerateLink(item_data, "CP: ")
        ItemPreviewFrame_SetItemLink(ItemPreviewFrame, link)
    else
        CP.PostItemLink(item_data)
    end
		return
  end
  Search.SelectItem(new_item)
  Search.UpdateList()
end

function Search.OnItemDblClick(this)
    Search.OnItemClick(this)
    Search.OnTakeIt()
end

function Search.OnItemEnter(this)
    local top_pos = CPSearchItemsSB:GetValue()
    local item_id = Search.Items[this:GetID()+top_pos]
    if item_id then
        GameTooltip:SetOwner(this, "ANCHOR_TOPLEFT", 0, 2)

        local item = CP.DB.GenerateItemDataByID(item_id)
        item.plus= UIDropDownMenu_GetSelectedValue(CPSearchFilterPlus) or 0
        item.tier= UIDropDownMenu_GetSelectedValue(CPSearchFilterTier) or 0
		if CPSearchPowerModify:IsChecked() then
		    item.dura = OVERDURA
		    item.max_dura = CP.DB.CalcMaxDura(item_id, OVERDURA)
		end
        GameTooltip:SetHyperLink(CP.Pimp.GenerateLink(item))
        GameTooltip:Show()
        GameTooltip1:Hide()
        GameTooltip2:Hide()
    end
end

function Search.OnItemLeave(this)
    GameTooltip1:Hide()
    GameTooltip2:Hide()
    GameTooltip:Hide()
end

function Search.ShowContextMenu(this)
    local info={notCheckable = 1}

    info.text = CP.L.SEARCH_CONTEXT_TAKE
    info.func = function()
                    Search.ApplyItem(this.item_id)
                end
    UIDropDownMenu_AddButton(info)

    if CP.DB.IsSuitItem(this.item_id) then
      info.text = CP.L.SEARCH_CONTEXT_SUIT
      info.func = function() Search.ApplySuitOfItem(this.item_id) end
      UIDropDownMenu_AddButton(info)
    end

    local skin = CP.DB.ItemSkinPosition(this.item_id)
    if skin then
        info.text = CP.L.SEARCH_CONTEXT_SKIN
        info.func = function()
                    CP.UseSkin(this.item_id,skin)
                end
        UIDropDownMenu_AddButton(info)
    end


    info.text = CP.L.SEARCH_CONTEXT_WEB
    info.func = function()
                    local linkData = string.format(CP.L.SEARCH_WEBSITE,this.item_id)
					--StaticPopupDialogs["OPEN_WEBROWER"].link = linkData
					--StaticPopup_Show("OPEN_WEBROWER")
    				GC_OpenWebRadio(linkData)
                end
    UIDropDownMenu_AddButton(info)

    local res = Search.FindInDungeonLoots(this.item_id)
    for _,data in pairs(res) do
        info.text   = data
        info.func   = function ()
                assert(DungeonLoot_Frame)
                DungeonLoot.var.instance =
                DungeonLoot_Frame:Show()
            end
        UIDropDownMenu_AddButton(info)
    end
end

function Search.FindInDungeonLoots(item_id)
    local res = {}

    if DungeonLoot and DungeonLoot.tables then
        for _,zone in pairs(DungeonLoot.tables) do
            for _,boss in pairs(zone.Boss or {}) do
                for _,loot in pairs(boss.Loots or {}) do
                    if loot==item_id then
                        table.insert(res, string.format(CP.L.SEARCH_DROPPED,
                                GetZoneLocalName(zone.Zone) or "unknown",
                                TEXT("Sys"..boss.Name.."_name")
                            ))
                    end
                end
            end
        end
    end

    return res
end

function Search.ApplySuitOfItem(item_id)
    local lvl, suit_id = CP.DB.GetItemInfo(item_id)
    if not suit_id then return end
    Search.ApplySuit(suit_id)
end

function Search.ApplySuit(suit_id)
    local set_items = CP.DB.GetSuitItems(suit_id)
    if not set_items then return end

    for _,item_id in ipairs(set_items) do
        Search.ApplyItem(item_id)
    end

    CPSearch:Hide()
end

function Search.OnTakeIt(slot1or2,dont_close)

    if not Search.selection then return end
    Search.ApplyItem(Search.selection, slot1or2)

    if not dont_close then CPSearch:Hide() end
end

function Search.ApplyItem(item_id, slot1or2)

    local slot
    if slot1or2 then
        local s1,s2 = CP.DB.GetItemPositions(item_id)
        slot = slot1or2==2 and s2 or s1
    else
        slot = CP.FindSlotForItem(item_id)
    end

    local item_data = Search.GetPimpedItemData(item_id)
    CP.ApplyItem(item_data, slot, false)
end

function Search.GetPimpedItemData(item_id)

    local item_data = CP.DB.GenerateItemDataByID(item_id)
    item_data.plus = UIDropDownMenu_GetSelectedValue(CPSearchFilterPlus) or 0
    item_data.tier = UIDropDownMenu_GetSelectedValue(CPSearchFilterTier) or 0

    if CPSearchPowerModify:IsChecked() then
        item_data.dura = OVERDURA
        item_data.max_dura = CP.DB.CalcMaxDura(item_data.id, OVERDURA)
    end

    return item_data
end

function Search.OnCancel()
    CPSearch:Hide()
end