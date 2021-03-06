require("./69_themeldingplague/globals.lua")

function initializeWormholes()
    northExitWh = WormHole():setPosition(143898, -99701):setTargetPosition(170960, -132962):setCallSign("Independent Space")
    northExitWh:onTeleportation(function(self, teleportee)
        if teleportee.typeName == "PlayerSpaceship" then
            victory("Independent")
        else
            teleportee:destroy()
        end
    end)

    southExitWh = WormHole():setPosition(-85926, 144838):setTargetPosition(-169718, 193575):setCallSign("Human Worlds")
    southExitWh:onTeleportation(function(self, teleportee)
        if teleportee.typeName == "PlayerSpaceship" then
            victory("Independent")
        else
            teleportee:destroy()
        end
    end)
end

function wormholePlayerNearingExitPoint(delta)
    local ships = getActivePlayerShips() 
    for i = 1, #ships do
        ps = ships[i]
        if ps:isValid() then
            local distToNorthExit = distance(ps, northExitWh:getPosition())
            local distToSouthExit = distance(ps, southExitWh:getPosition())
    
            if distToNorthExit > 10000 and distToSouthExit > 10000 and ps.nearExitWormhole == false then
                ps.nearExitWormhole = true
            elseif distToNorthExit < 8000 and ps.nearExitWormhole == true then
                freeport9:sendCommsMessage(
                    ps,
                    _(ps:getCallSign() .. ", you're approaching a wormhole that leads deeper into independent space. " ..
                        "By going through it you will leave the assigned mission area. " ..
                        "FYI: it will be considered desertion. Turn back ASAP.")
                )
                ps.nearExitWormhole = false
            elseif distToSouthExit < 8000 and ps.nearExitWormhole == true then
                freeport9:sendCommsMessage(
                    ps,
                    _(ps:getCallSign() .. ", that wormhole leads back to Human controlled space, which is outside our area of operations. " .. 
                        "Just so we're clear: going through it would mean dereliction of duty.")
                )
                ps.nearExitWormhole = false
            end
        end 
    end
end

function wormholeRotate(delta)
    southExitWh:setRotation(getScenarioTime() * 3)
    northExitWh:setRotation(getScenarioTime() * 10)
end
