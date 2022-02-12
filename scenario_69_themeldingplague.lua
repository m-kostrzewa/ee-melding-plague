-- Name: The Melding plague
-- Description: A mysterious freighter is discovered near one of the busiest trade routes on the border of Human Worlds.
---
--- Multiple choices and endings. Players are encouraged to help Relay officer decide on dialogue options.
-- Type: Mission
-- Author: Kosai

require("69_themeldingplague/main.lua")

function init()
    local status, err = pcall(myInit)
    if not status then
        print("Error in myInit: ", err)
    end
end

function update(delta)
    local status, err = pcall(myUpdate, delta)
    if not status then
        print("Error in myUpdate: ", err)
    end
end
