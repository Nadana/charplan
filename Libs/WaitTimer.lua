--[[
    WaitTimer
        A simple and easy timer class

    by McBen
        Web: http://rom.curseforge.com/addons/waittimer/
        Rep: git://git.curseforge.net/rom/waittimer/mainline.git


    Init:
        local WaitTimer = LibStub("WaitTimer")

    Example:
        -- simple delayed call
        WaitTimer.Wait(5, function () DEFAULT_CHAT_FRAME:AddMessage("huhu") end)

        -- repeatable call
        id = WaitTimer.Wait(10, function ()
                            DEFAULT_CHAT_FRAME:AddMessage("spam")
                            return 10
                        end)
        ...
        WaitTimer.Stop(id)

        -- with user data
        funtion pout(txt) DEFAULT_CHAT_FRAME:AddMessage(txt) end
        WaitTimer.Wait(1, pout, nil, "3")
        WaitTimer.Wait(2, pout, nil, "2")
        WaitTimer.Wait(3, pout, nil, "1")


    Usage:
        timer_id = WaitTimer.Wait(seconds, function, id, data)
        ================================================

        - seconds=  how long to wait
        - function= will be called when time is elapsed
            if the function returns a value, this value is used as new wait_time.
        - id= (optional) a fixed timer id
            If another timer with the same ID exists it will be replaced.
            You may use any kind of value.
        - data= (optional) will be passed to the function call

        - timer_id= id which can be used in the other functions
            It's equal "id" when it was provided


        WaitTimer.Stop(id)
        ===================
        - stops the timer without calling the function


        waittime = WaitTimer.Remaining(id)
        ==================================
        - @return remaining seconds
                  or nil


        WaitTimer.SetTime(id, delay)
        ==================================
        - reset the wait time
        - if <delay> is ommited the function will be triggert on next update


    Setup:
        simply copy theses files to your addon or any subdirectory of it
            LibStub.lua
            WaitTimer.lua
            WaitTimer.toc

--]]
WaitTimerUpdateFrame = nil


local Timer = LibStub:NewLibrary("WaitTimer", 3)
if not Timer then return end




Timer.events={}
Timer.last_id=1000

local function FindID(id)
    for i,data in ipairs(Timer.events) do
        if data[2]==id then return i,data end
    end
end

local function StartUpdate()
    if not WaitTimerUpdateFrame then
        local frame = CreateUIComponent("Frame", "WaitTimerUpdateFrame", "UIParent")
        frame:SetScripts("OnUpdate",[=[ WaitTimerOnUpdate(this,elapsedTime)]=])
    end

    WaitTimerUpdateFrame:Show()
end

local function StopUpdate()
    if TimerUpdateFrame then
        TimerUpdateFrame:Hide()
    end
end

function WaitTimerOnUpdate(this,elapsedTime)

    for i,data in ipairs(Timer.events) do

        data[1] = data[1]-elapsedTime

        if data[1]<=0 then
            local good, next_delay = pcall(data[3],data[4])

            if good and type(next_delay)=="number" then
                data[1] = next_delay
            else
                table.remove(Timer.events,i)
                if #Timer.events==0 then
                    this:Hide()
                end
            end

            if not good then
                error("error in update call (id='"..tostring(data[2]).."'): "..next_delay)
            end
        end
    end
end

function Timer.Wait(seconds, fct, id, data)
    local _,cur_data = FindID(id)
    if cur_data then
        cur_data[1]=seconds
        return
    end

    if not id then
        repeat
            id = Timer.last_id
            Timer.last_id = Timer.last_id+1
        until FindID(id)==nil
    end

    table.insert(Timer.events, {seconds, id, fct, data} )

    StartUpdate()

    return id
end

function Timer.Remaining(id)
    local _,cur_data = FindID(id)
    if cur_data then
        return cur_data[1]
    end
end

function Timer.SetTime(id,delay)
    local _,cur_data = FindID(id)
    if cur_data then
        cur_data[1] = (delay or 0)
    end
end

function Timer.Stop(id)
    local idx = FindID(id)
    if idx then
        table.remove(Timer.events,idx)

        if #Timer.events==0 then
            StopUpdate()
        end
    end
end
