--[[
    CharPlan - Search

    Item search dialog
]]

local CP = _G.CP
local Search = {}
CP.Search = Search

local MAX_LINES=10

function Search.ForSlot(slot_id)
    Search.slot = slot_id

    Search.FindItems()
    CPSearch:Show()
end

function Search.OnShow()
    Search.UpdateList()
end

function Search.OnHide()
    Search.Items=nil
end

function Search.FindItems()
    Search.Items = CP.DB.GetItemForSlot(Search.slot)
end

function Search.UpdateList()
    for i=1,MAX_LINES do
        local item_id = Search.Items[i]
        local base_name = "CPSearchItem"..i

        if item_id then
            _G[base_name]:Show()

            _G[base_name.."Name"]:SetText(TEXT("Sys"..item_id.."_name"))
            SetItemButtonTexture(_G[base_name.."Item"], CP.DB.GetItemIcon(item_id) )
        else
            _G[base_name]:Hide()
        end
    end
end
