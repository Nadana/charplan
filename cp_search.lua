--[[
    CharPlan - Search

    Item search dialog
]]

local CP = _G.CP
local Search = {}
CP.Search = Search

local MAX_LINES=10
local HEADER_COUNT=3


function Search.OnLoad(this)

    UIPanelBackdropFrame_SetTexture( this, "Interface/Common/PanelCommonFrame", 256, 256 )

    -- TODO: localize
    CPSearchHead1:SetText("Name")
    CPSearchHead2:SetText("Level")
    CPSearchHead3:SetText("Base Stats")
    CPSearchFilterStatLessText:SetText("no empty items")
    CPSearchFilterNameLabel:SetText("Name")
    CPSearchFilterLevelLabel:SetText("Level")

    CPSearchFilterStatLess:SetChecked()
end


function Search.ForSlot(slot_id, item_id)
    Search.slot = slot_id
    Search.selection = item_id
    Search.selection_changed = false
    Search.type_filter={}
    for i=0,24 do Search.type_filter[i]=true end

    --CPSearchFilterSlotMenu:Disable()
    Search.FindItems()
    CPSearchTitle:SetText(TEXT(string.format("SYS_EQWEARPOS_%02i",slot_id)))
    CPSearch:Show()
end

function Search.OnShow(this)
    this:ResetFrameOrder()
end

function Search.OnHide()
    Search.Items=nil
end

function Search.OnTypeFilterLoad(this)
    UIDropDownMenu_Initialize( this, Search.OnFilterMenuShow, "MENU")
end

function Search.ShowFilterMenu(this,kind)
    if DropDownList1:IsVisible() then
        CloseDropDownMenus()

        if  CPSearchFilterMenu.Type == kind then
            return
        end
    end


    CPSearchFilterMenu:ClearAllAnchors()
    CPSearchFilterMenu:SetAnchor("TOP", "TOP", this:GetName(), 0, 0)

    CPSearchFilterMenu.Type = kind
    ToggleDropDownMenu(CPSearchFilterMenu)
end

function Search.OnFilterMenuShow(this)
    if CPSearchFilterMenu.Type=="Type" then
        Search.OnTypeFilterShow(this)
    elseif CPSearchFilterMenu.Type=="Slot" then
        Search.OnSlotFilterShow(this)
    elseif CPSearchFilterMenu.Type=="Kind" then
        Search.OnSubTypeFilterShow(this)
    else
        error("illegal kind")
    end
end

function Search.OnTypeFilterShow(this)
    local itype = CP.DB.IsSlotType(Search.slot)

    local filters=
    {   [1]= { -- Armor
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
            [TEXT("SYS_WEAPON_TYPE00")]=8,  --="Waffenlos"
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
            [TEXT("SYS_WEAPON_TYPE00")]=8,  --="Waffenlos"
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
            [TEXT("SYS_WEAPON_TYPE14")]=22, --="Pfeil"
            [TEXT("SYS_WEAPON_TYPE15")]=23, --="Kugeln"
            [TEXT("SYS_WEAPON_TYPE16")]=24, --="Wurfwaffen"
            },
        [7]= { -- Back
            [TEXT("SYS_ARMORTYPE_03")]=3, -- Cloth
            },
    }

    for name,id in pairs(filters[itype]) do
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


function Search.OnSlotFilterShow(this)

    local slots={0,1,2,3,4,5,6,7,8,10,11,13,15,16,21}

    for _,id in ipairs(slots) do
        local info={}
        info.text=TEXT(string.format("SYS_EQWEARPOS_%02i",id))
        info.checked = (Search.slot==id)
        info.value = id
        info.func = Search.OnSlotFilterSelect
		UIDropDownMenu_AddButton( info, 1 )
    end

end

function Search.OnSlotFilterSelect(this)
    Search.slot=this.value
    Search.FindItems()
end

function Search.OnSubTypeFilterShow(this)

    local slots={0,1,2,3,4,5,6,7,8,10,11,13,15,16,21}

    for _,id in ipairs(slots) do
        local info={}
        info.text=TEXT(string.format("SYS_EQWEARPOS_%02i",id))
        info.checked = (Search.slot==id)
        info.value = id
        info.func = Search.OnSlotFilterSelect
		UIDropDownMenu_AddButton( info, 1 )
    end

end

function Search.OnSubTypeFilterSelect(this)
    Search.slot=this.value
    Search.FindItems()
end


local function GetFilterFunction()

    local code = {"return function (id,data)"}

    local slots = CP.DB.GetItemTypesForSlot(Search.slot)
    if type(slots)=="number" then
        table.insert(code, 'if data[1]~='..slots..' then return false end')
    else
        assert(type(slots)=="table")
        table.insert(code, 'if data[1]~='..table.concat(slots,' and data[1]~=')..' then return false end')
    end

    table.insert(code, 'if not CP.Search.type_filter[data[2]] then return false end')

    local name = CPSearchFilterName:GetText()
    if name~="" then
        name = string.lower(name)
        table.insert(code, 'if not string.find(TEXT("Sys"..id.."_name"):lower(),"'..name..'") then return false end')
    end

    local lvlmin = tonumber(CPSearchFilterLevelMin:GetText())
    if lvlmin then
        table.insert(code, 'if data[3]<'..tostring(lvlmin)..' then return false end')
    end

    local lvlmax = tonumber(CPSearchFilterLevelMax:GetText())
    if lvlmax then
        table.insert(code, 'if data[3]>'..tostring(lvlmax)..' then return false end')
    end

    if CPSearchFilterStatLess:IsChecked() then
        table.insert(code, 'if not CP.DB.GetItemEffect(id) then return false end')
    end


    table.insert(code,"return true end")

    local code_text = table.concat(code," ")

    local fct,err = loadstring(code_text)
    assert(fct,tostring(err).."\n"..code_text)
    return fct()
end


function Search.FindItems()

    local filter_fct = GetFilterFunction()

    Search.Items = CP.DB.FindItems(filter_fct)

    CPSearchItemsSB:SetValueStepMode("INT")
    CPSearchItemsSB:SetMinMaxValues(0,math.max(0,(#Search.Items)-MAX_LINES))

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
                local slots={[12]=1,[13]=1,[14]=1,[15]=1}
                local boni1=0
                local efftype, effvalue = CP.DB.GetItemEffect(id1)
                for i,eff in pairs(efftype or {}) do
                    if slots[eff] then
                        boni1 = boni1 + effvalue[i]
                    end
                end

                local boni2=0
                local efftype, effvalue = CP.DB.GetItemEffect(id2)
                for i,eff in pairs(efftype or {}) do
                    if slots[eff] then
                        boni2 = boni2 + effvalue[i]
                    end
                end

                return boni1>boni2
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
            CPSearchItemsSB:SetValue(i)
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
            _G[base_name]:Show()

            SetItemButtonTexture(_G[base_name.."Item"], CP.DB.GetItemIcon(item_id) )

            local r,g,b = GetItemQualityColor(GetQualityByGUID( item_id ))
            local col=string.format("|cff%02x%02x%02x",r*255,g*255,b*255)
            _G[base_name.."Name"]:SetText(col..TEXT("Sys"..item_id.."_name"))

            local level, setname = CP.DB.GetItemInfo(item_id)
            _G[base_name.."Set"]:SetText(setname or "")
            _G[base_name.."Level"]:SetText(level or "")


            local boni={}
            local efftype, effvalue = CP.DB.GetItemEffect(item_id)
            for i,eff in pairs(efftype or {}) do
                boni[eff] = (boni[eff] or 0) + effvalue[i]
            end

            local efftype, effvalue = CP.DB.GetItemUsualDropEffects(item_id)
            for i,eff in pairs(efftype or {}) do
                boni[eff] = (boni[eff] or 0) + effvalue[i]
            end

            local txt = ""
            local attA,attB = CP.DB.PrimarAttributes(item_id)
            if attA and boni[attA] then
                local n = Calc.ID2StatName(attA)
                txt = txt..(CP.L.STAT_SHORTS[n])..": "..boni[attA].."\n"
                boni[attA] = nil
            end
            if attB and boni[attB] then
                local n = Calc.ID2StatName(attB)
                txt = txt..(CP.L.STAT_SHORTS[n])..": "..boni[attB].."\n"
                boni[attB] = nil
            end
            _G[base_name.."Effect"]:SetText(txt)


            txt=""
            for eff,value in pairs(boni) do
                txt = txt.."+"..value.." "..TEXT("SYS_WEAREQTYPE_"..eff).."\n"
            end

            _G[base_name.."Boni"]:SetText(txt)

            if item_id == Search.selection then
                _G[base_name.."Highlight"]:Show()
            else
                _G[base_name.."Highlight"]:Hide()
            end

        else
            _G[base_name]:Hide()
        end
    end
end


function Search.OnItemClick(this)
    local top_pos = CPSearchItemsSB:GetValue()
    local new_item = Search.Items[this:GetID()+top_pos]
    if new_item ~= Search.selection then
        Search.selection = new_item
        Search.selection_changed = true
    end

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
        GameTooltip:SetHyperLink(CP.Pimp.GenerateLinkByID(item_id))
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

function Search.OnTakeIt()
    if Search.selection and Search.selection_changed then
        local item_data = CP.DB.GenerateItemDataByID(Search.selection)
        CP.ApplyItem(item_data, Search.slot, false)

        CPSearch:Hide()
    end
end


function Search.OnCancel()
    CPSearch:Hide()
end