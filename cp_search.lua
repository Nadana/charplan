--[[
    CharPlan - Search

    Item search dialog
]]

local CP = _G.CP
local Search = {}
CP.Search = Search

local MAX_LINES=10


function Search.OnLoad(this)

    UIPanelBackdropFrame_SetTexture( this, "Interface/Common/PanelCommonFrame", 256, 256 )

    -- TODO: localize
    CPSearchHead1:SetText("Name")
    CPSearchHead2:SetText("Level")
    CPSearchFilterStatLessText:SetText("no empty items")
    CPSearchFilterNameLabel:SetText("Name")
    CPSearchFilterLevelLabel:SetText("Level")

    CPSearchFilterStatLess:SetChecked()
end


function Search.ForSlot(slot_id)
    Search.slot = slot_id

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
    UIDropDownMenu_Initialize( this, Search.OnTypeFilterShow, "MENU")
end

function Search.OnTypeFilterShow(this)
    local itype = CP.DB.IsSlotType(Search.slot)

    local filters=
    {   [1]= { -- Armor
            [TEXT("ARMOR_CLOTH")]=0,
            [TEXT("ARMOR_LEATHER")]=1,
            [TEXT("ARMOR_MAIL")]=2,
            [TEXT("ARMOR_PLATE")]=3,
            [TEXT("ARMOR_ROBE")]=4,
            },
        [2]= { -- Cloak
            [TEXT("ARMOR_CLOTH")]=0,
            },
        [3]= { -- Jewelery
            [TEXT("ARMOR_ACCESSORY")]=0,
            },
        [4]= { -- Primary Weapon
            },
        [5]= { -- Secondary Weapon
            },
        [6]= { -- Ranges Weapon
            },
        [7]= { -- Back
            [TEXT("ARMOR_CLOTH")]=0,
            },
    }

    for name,id in pairs(filters[itype]) do
        local info={}
        info.text=name
		UIDropDownMenu_AddButton( info, 1 )
    end

end

local function GetFilterFunction()

    local filter ="return function (id,data) "

    filter = filter..'if data.slot~='..Search.slot..' then return false end '

    local name = CPSearchFilterName:GetText()
    if name~="" then
        name = string.lower(name)
        filter = filter..'if not string.find(TEXT("Sys"..id.."_name"):lower(),"'..name..'") then return false end '
    end

    local lvlmin = tonumber(CPSearchFilterLevelMin:GetText())
    if lvlmin then
        filter = filter..'if data.min_level<'..tostring(lvlmin)..' then return false end '
    end

    local lvlmax = tonumber(CPSearchFilterLevelMax:GetText())
    if lvlmax then
        filter = filter..'if data.min_level>'..tostring(lvlmax)..' then return false end '
    end

    if CPSearchFilterStatLess:IsChecked() then
        filter = filter..'if not CP.DB.GetItemEffect(id) then return false end '
    end


    filter = filter.." return true end"

    local fct,err = loadstring(filter)
    assert(fct,tostring(err).."\n"..filter)
    return fct()
end


function Search.FindItems()

    local filter_fct = GetFilterFunction()

    Search.Items = CP.DB.FindItems(filter_fct)

    CPSearchItemsSB:SetValueStepMode("INT")
    CPSearchItemsSB:SetMinMaxValues(0,math.max(0,(#Search.Items)-MAX_LINES))

    Search.UpdateList()
end

function Search.HeaderClicked(this)
    for i=1,2 do
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
            end
    }

    if column>0 then
        table.sort(Search.Items, sorts[column])
    else
        table.sort(Search.Items, function (a,b) return sorts[-column](b,a) end)
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
            for i,v in ipairs({12,13,14,15}) do
                if boni[v] then
                    txt = txt..(CP.L.STAT_SHORTS[i])..": "..boni[v].."\n"
                    boni[v] = nil
                end
            end
            _G[base_name.."Effect"]:SetText(txt)


            txt=""
            for eff,value in pairs(boni) do
                txt = txt.."+"..value.." "..TEXT("SYS_WEAREQTYPE_"..eff).."\n"
            end
            --if txt=="" then txt = string.format("id: %i",item_id) end

            _G[base_name.."Boni"]:SetText(txt)

        else
            _G[base_name]:Hide()
        end
    end
end

function Search.OnItemEnter(this)
    local top_pos = CPSearchItemsSB:GetValue()
    local item_id = Search.Items[this:GetID()+top_pos]
    if item_id then
        GameTooltip:SetOwner(this, "ANCHOR_BOTTOMLEFT", -10, 0)
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

end

function Search.OnCancel()
    CPSearch:Hide()
end