-----------------------------------------------------------------------------
-- Nyx
--  by McBen
--  A collection of random function I usually need
--  feedback to: viertelvor12@gmx.net
--
--
--  License: MIT/X
-----------------------------------------------------------------------------

local Nyx = LibStub:NewLibrary("Nyx", 7)
if not Nyx then return end

------------------------------
function Nyx.LoadLocalesAuto(directory)  -- Example: Nyx.LoadLocalesAuto("Interface/Addons/dailynotes/Locales/")
    Nyx.LoadLocales(directory, string.sub(GetLanguage(),1,2))
end

function Nyx.LoadLocales(directory, locales)
    local func, err = loadfile(directory..locales..".lua")
    if err then
        Nyx.LoadFile(directory.."en.lua")
        return
    end
    func()
end

function Nyx.LoadFile(filename)
    local func, err = loadfile(filename)
    if err then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000Error loading: "..filename.." -> "..tostring(err))
        return
    end
    func()
end

------------------------------
function Nyx.GetBagItemCounts()
    local items={}
    for i = 51, 240 do
        local bagitemid, bagitemcount = Nyx.GetBagItem(i)
        if bagitemid then
            items[bagitemid] = (items[bagitemid] or 0) + bagitemcount
        end
    end
    return items
end

function Nyx.GetBagItem(index)
    local icon, _, itemCount, _ = GetGoodsItemInfo( index )
    if ( icon~="" ) then
        return Nyx.GetItemID(GetBagItemLink( index )), itemCount
    end
end



function Nyx.GetItemID( itemLk )

  if not itemLk then return end

  local ret = "";
  local _type, _data, _name = ParseHyperlink(itemLk)

  if ( _data and _data ~= "" ) then
    _,_,ret = string.find(_data, "(%x+)")
    ret =  tonumber(ret, 16)
  end

  return ret
end


function Nyx.CreateItemLink( item_id, quality )
  assert(type(item_id)=="number")

  local r,g,b = GetItemQualityColor(quality or 1)
  return string.format('|Hitem:%6x|h|cff%2x%2x%2x[dummy]|r|h',item_id,r*255,g*255,b*255)
end

function Nyx.FindBagIndex(m_name,m_icon)
    local inventoryIndex, icon, name
    local _,bagcount=GetBagCount()
    for i=1,bagcount do
        inventoryIndex, icon, name= GetBagItemInfo ( i )
        if name==m_name and icon==m_icon then
            return inventoryIndex
        end
    end
end

------------------------------
function Nyx.GetCurrentRealm()
  local realm = string.match((GetCurrentRealm() or ""),"(%w*)$")
  return realm or ""
end

function Nyx.GetUniqueCharname()
  local realm = Nyx.GetCurrentRealm()
  local player= UnitName("player") or ""
  return string.format("%s:%s",realm,player)
end

function Nyx.GetNPCInfo(npc_id)-- return: Name,map,pos_x,pos_y

    if NpcTrack_SearchNpcByDBID( npc_id ) <1 then
        return
    end

    local _, name, map, posx, posy = NpcTrack_GetNpc(1)
    return name,map,posx,posy

end

function Nyx.GetPlayerLevel() -- (secondary not depending on current main-class)

    mainClass, secondClass = UnitClass( "player" )

    local mlvl=0
    local slvl=0

    local numClasses = GetNumClasses()
    for i = 1, numClasses do
        local class, token, level, currExp, maxExp = GetPlayerClassInfo(i)
        if mainClass and   mainClass==class then mlvl = level end
        if secondClass and secondClass==class then slvl = level end
    end

    return mlvl,slvl
end

------------------------------
function Nyx.IsOnFriendlist(name)
    for i=1, GetFriendCount("Friend") do
	    if name == GetFriendInfo("Friend", i) then
            return true
        end
    end
end

function Nyx.IsInMyGuild(name)
    local numGuildNodes = GetNumGuildMembers()

	for i = 1,numGuildNodes do
	    if name == GetGuildRosterInfo(i) then
            return true
        end
    end
end

------------------------------
function Nyx.GetQuestBookText(Quest_ID)

    local desc = TEXT("Sys"..Quest_ID.."_szquest_desc")

    local catcher=20 -- prevent infinitive loop
    while catcher>0 do
        catcher=catcher-1
        local ls,le = desc:find("%[.-%]")
        if not ls then break end

        local newtext= string.match(desc:sub(ls+1,le-1), "^([^|]+)")

        if newtext:find("^<[sS]>") then
            newtext = "|cffb0b0b0"..TEXT("Sys"..string.sub(newtext,4).."_name_plural").."|r"
        elseif tonumber(newtext) then
            newtext = "|cffb0b0b0"..TEXT("Sys"..newtext.."_name").."|r"
        else
            newtext = "|cffb0b0b0"..TEXT(newtext).."|r"
        end

        desc = desc:sub(1,ls-1)..newtext..desc:sub(le+1)
    end

    desc = desc:gsub("</?C[PS]>","")

    assert(catcher>0,"Quest Text error for QID="..tostring(Quest_ID))

    return desc
end


------------------------------
function Nyx.TableSize(tab)
    local s = 0
    for _,_ in pairs(tab) do s=s+1 end
    return s
end

function Nyx.VersionToNumber(text) --ex.: "v1"=10000  "1.2.3.4" = 10203.04
  local version=0
  local n=10000
  (text or "0"):gsub("%d+", function(c) if n>0 then version=version+(tonumber(c))*n; n=n/100 end end)
  return version
end

-- src: http://lua-users.org/wiki/SplitJoin
function Nyx.Split(str, delim, maxNb)
    -- Eliminate bad cases...
    if string.find(str, delim) == nil then
        return { str }
    end
    if maxNb == nil or maxNb < 1 then
        maxNb = 0    -- No limit
    end
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in string.gfind(str, pat) do
        nb = nb + 1
        result[nb] = part
        lastPos = pos
        if nb == maxNb then break end
    end
    -- Handle the last field
    if nb ~= maxNb then
        result[nb + 1] = string.sub(str, lastPos)
    end
    return result
end
