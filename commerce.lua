require("./69_mymission/globals.lua")

function randomCommerceFreighterShipCommsFunc()
    rand = irandom(0, 3)
    if rand == 0 then
        return function()
            setCommsMessage(_("This is " .. comms_target:getCallSign() .. " " .. comms_target:getFaction() .. " freighter. We're en route to " .. comms_target.ultimateDestStr .. 
                ". " .. (#comms_target.tradeRoute - comms_target.currentLeg) .. " waypoints remaining."))
        end
    elseif rand == 1 then
        return function()
            setCommsMessage(_(comms_target:getFaction() .. " transport " .. comms_target:getCallSign() .. " here. Our ultimate destination is " 
                .. comms_target.ultimateDestStr .. ". We have " .. (#comms_target.tradeRoute - comms_target.currentLeg) .. " more stops in this system."))
        end
    elseif rand == 2 then
        return function()
            setCommsMessage(_("I'm the captain of " .. comms_target:getFaction() .. " convoy " .. comms_target:getCallSign() .. ". " ..
                "We're just passing by this sector. We're on our way to " .. comms_target.ultimateDestStr .. "."))
        end
    elseif rand == 3 then
        return function()
            setCommsMessage(_("This is " .. comms_target:getCallSign() .. " heavy. We're " .. comms_target:getFaction() .. ". Want anything, speak to my boss."))
        end
    end
end

function randomCommerceEscortShipCommsFunc()
    rand = irandom(0, 3)
    if rand == 0 then
        return function()
            setCommsMessage(_("This is " .. comms_target:getCallSign() .. ". I'm escorting " .. comms_target.freighter:getCallSign() .. "."))
        end
    elseif rand == 1 then
        return function()
            setCommsMessage(_(comms_target:getCallSign() .. " here. If you want anything, talk to my boss on " .. comms_target.freighter:getCallSign() .. "."))
        end
    elseif rand == 2 then
        return function()
            setCommsMessage(_("Just a lowly escort pilot. " .. comms_target:getCallSign() .. " out."))
        end
    elseif rand == 3 then
        return function()
            setCommsMessage(_("Hello. You probably want my boss on " .. comms_target.freighter:getCallSign() .. " ."))
        end
    end
end

function initializeCommerce()
    commerceFreighters = {}

    tradeRouteSouthToNorth = {}
    tradeRouteSouthToNorth[0] = borderStation
    tradeRouteSouthToNorth[1] = freeport9
    tradeRouteSouthToNorth[2] = bobsStation
    tradeRouteSouthToNorth[3] = northExitWh

    tradeRouteNorthToSouth = {}
    tradeRouteNorthToSouth[0] = bobsStation
    tradeRouteNorthToSouth[1] = freeport9
    tradeRouteNorthToSouth[2] = borderStation
    tradeRouteNorthToSouth[3] = southExitWh

    spawnCommerceFleet(-80728, 140307, tradeRouteSouthToNorth, 0)
    spawnCommerceFleet(1326, 8230, tradeRouteSouthToNorth, 1)
    spawnCommerceFleet(-40743, 76231, tradeRouteNorthToSouth, 2)
    spawnCommerceFleet(-47000, 80997, tradeRouteNorthToSouth, 2)
    spawnCommerceFleet(-27702, 49339, tradeRouteNorthToSouth, 2)
    spawnCommerceFleet(-57647, 127520, tradeRouteSouthToNorth, 1)
    spawnCommerceFleet(-10930, 38434, tradeRouteSouthToNorth, 1)
    spawnCommerceFleet(-45973, 78147, tradeRouteSouthToNorth, 1)

    spawnCommerceFleet(42466, -21290, tradeRouteNorthToSouth, 1)
    spawnCommerceFleet(46996, -31030, tradeRouteNorthToSouth, 1)
    spawnCommerceFleet(91390, -62287, tradeRouteSouthToNorth, 2)
    spawnCommerceFleet(141447, -89920, tradeRouteNorthToSouth, 0)
    spawnCommerceFleet(84004, -33904, tradeRouteNorthToSouth, 1)
end

function updateCommerce(delta)
    for i = 1, #commerceFreighters do
        commerceFreighters[i].updateFunc()
    end
end

function spawnCommerceFleet(spawnLocationX, spawnLocationY, tradeRoute, startingLeg)

    local factions = {
        "Independent",
        "Independent",
        "Independent",
        "Independent",
        "Human Navy",
        "CUF",
        "USN",
        "Arlenians",
        "Arlenians",
        "Arlenians"
    }
    local freighterTypes = {
        "Fuel Freighter 1","Fuel Freighter 2","Fuel Freighter 3","Fuel Freighter 4",
        "Fuel Freighter 5","Fuel Jump Freighter 3","Fuel Jump Freighter 4","Fuel Jump Freighter 5",
        "Equipment Freighter 1","Equipment Freighter 2","Equipment Freighter 3","Equipment Freighter 4",
        "Equipment Freighter 5","Equipment Jump Freighter 3","Equipment Jump Freighter 4","Equipment Jump Freighter 5",
        "Goods Freighter 1","Goods Freighter 2","Goods Freighter 3","Goods Freighter 4","Goods Freighter 5",
        "Goods Jump Freighter 3","Goods Jump Freighter 4","Goods Jump Freighter 5",
        "Personnel Freighter 1","Personnel Freighter 2","Personnel Freighter 3","Personnel Freighter 4","Personnel Freighter 5",
        "Personnel Jump Freighter 3","Personnel Jump Freighter 4","Personnel Jump Freighter 5"
    }
    local escortTypes = {
        "Adder MK3", "Adder MK4", "Adder MK5", "Adder MK8", "MT52 Hornet", "MU52 Hornet", "Fighter"
    }
    local escortCallsignFormats =  {
        "%s E %i", "%s-%i", "%s/%i", "%s 0%i"
    }

    local stateBeginNewLeg = 0
    local stateDuringTransit = 1
    local stateDockedUnpacking = 2
    local stateEgressSystem = 3
    local stateUnstuck = 8
    local stateDuringCombat = 9

    local faction = factions[irandom(1, #factions)]
    local freighterType = freighterTypes[irandom(1, #freighterTypes)]
    local freighter = CpuShip():
        setTemplate(freighterType):setFaction(faction):setCommsFunction(randomCommerceFreighterShipCommsFunc()):setPosition(spawnLocationX, spawnLocationY)
    freighter:setScanned(freighter:isFriendly(getPlayerShip(-1)))

    ElectricExplosionEffect():setPosition(spawnLocationX, spawnLocationY):setSize(600):setOnRadar(true)

    freighter.tradeRoute = tradeRoute
    freighter.currentLeg = startingLeg
    freighter.state = stateBeginNewLeg
    freighter.stateBeforeCombat = nil
    freighter.escorts = {}

    --- for unstuck logic
    freighter.nextPosMeasurementAt = 0 
    freighter.lastPosMeasurementX, freighter.lastPosMeasurementY = freighter:getPosition()

    freighter.ultimateDestStr = "somewhere"
    local ultimateDest = freighter.tradeRoute[#freighter.tradeRoute]
    if ultimateDest.typeName == "WormHole" then
        if ultimateDest == southExitWh then
            freighter.ultimateDestStr = "Human space"
        elseif ultimateDest == northExitWh then
            freighter.ultimateDestStr = "Independent space"
        end
    elseif ultimateDest.typeName == "SpaceStation" then
        freighter.ultimateDestStr = ultimateDest:getCallSign()
    end
    
    table.insert(commerceFreighters, freighter)

    freighter.updateFunc = function()
        if not freighter:isValid() then
            return
        end

        local sensorHystheresis = 500.0
        if freighter.state ~= stateDuringCombat and freighter:areEnemiesInRange(freighter:getShortRangeRadarRange() - sensorHystheresis) then
            print("[Commerce] " .. freighter:getCallSign() .. " defending")

            freighter.stateBeforeCombat = freighter.state
            freighter.state = stateDuringCombat

            for i=1, #freighter.escorts do
                if freighter.escorts[i]:isValid() then 
                    freighter.escorts[i]:orderDefendTarget(freighter)
                end
            end
        end

        if freighter.state == stateDuringCombat then
            if not freighter:areEnemiesInRange(freighter:getShortRangeRadarRange()) then
                freighter.state = stateBeginNewLeg
                print("[Commerce] " .. freighter:getCallSign() .. " standing down")
            else
                --- still fighting!
                --- early return so we don't execute the rest of AI "stack"
                return
            end
        end

        local dest = freighter.tradeRoute[freighter.currentLeg]

        if freighter.state == stateBeginNewLeg then
            if dest.typeName == "SpaceStation" then
                print("[Commerce] " .. freighter:getCallSign() .. " beginning new leg to " .. dest:getCallSign())
                freighter:orderDock(dest)
                freighter.state = stateDuringTransit

                local angleSeparation = 300.0 / (#freighter.escorts + 1)
                for i=1, #freighter.escorts do
                    local dx, dy = vectorFromAngle(30.0 + i * angleSeparation, 700)
                    if freighter.escorts[i]:isValid() then 
                        freighter.escorts[i]:orderFlyFormation(freighter, dx, dy)
                    end
                end
            elseif dest.typeName == "WormHole" then
                print("[Commerce] " .. freighter:getCallSign() .. " eggressing system ")
                local whx, why = dest:getPosition()
                freighter:orderFlyTowards(dest:getPosition())
                freighter.state = stateEgressSystem
                for i=1, #freighter.escorts do
                    if freighter.escorts[i]:isValid() then 
                        freighter.escorts[i]:orderFlyTowards(dest:getPosition())
                    end
                end
            else
                print("[Commerce]  Invalid target typeName " .. dest.typeName )
            end
        end

        if freighter.state == stateDuringTransit and freighter:isDocked(dest)  then
            local stayTime = irandom(30, 60)
            print("[Commerce] " .. freighter:getCallSign() .. " docked for " .. stayTime .. " seconds at " .. dest:getCallSign())

            freighter.state = stateDockedUnpacking
            freighter.nextStateTransitionAt = getScenarioTime() + stayTime

            for i=1, #freighter.escorts do
                if freighter.escorts[i]:isValid() then
                    freighter.escorts[i]:orderDefendTarget(freighter)    
                end
            end
        end

        --- unstuck logic
        if getScenarioTime() > freighter.nextPosMeasurementAt and getScenarioTime() > 15.0 then
            if freighter.state == stateDuringTransit and distance(freighter, freighter.lastPosMeasurementX, freighter.lastPosMeasurementY) < 100.0 then
                print("[Commerce] " .. freighter:getCallSign() .. " unstucking self")
                freighter.state = stateUnstuck
                freighter.nextStateTransitionAt = getScenarioTime() + irandom(5, 10)
                freighter:orderDefendLocation(freighter:getPosition())
            elseif freighter.state == stateUnstuck and getScenarioTime() > freighter.nextStateTransitionAt then
                print("[Commerce] " .. freighter:getCallSign() .. " should've unstucked myself")
                freighter.state = stateBeginNewLeg
            end

            freighter.lastPosMeasurementX, freighter.lastPosMeasurementY = freighter:getPosition()
            freighter.nextPosMeasurementAt = getScenarioTime() + irandom(10, 20)
        end

        if freighter.state == stateDockedUnpacking and getScenarioTime() > freighter.nextStateTransitionAt then
            print("[Commerce] " .. freighter:getCallSign() .. " departing " .. dest:getCallSign())
            freighter.state = stateBeginNewLeg
            freighter.currentLeg = freighter.currentLeg + 1
        end

    end

    local fx, fy = freighter:getPosition()

    local escortType = escortTypes[irandom(1, #escortTypes)]
    local escortCount = 0

    local dx, dy = vectorFromAngle(random(0,360),random(100,500))


    local escortCallsignFormat = escortCallsignFormats[irandom(1, #escortCallsignFormats)]
    while irandom(1, 100) < 45 do
        local escortShip = CpuShip():setTemplate(escortType):setCommsFunction(randomCommerceEscortShipCommsFunc())
        escortShip:setJumpDrive(freighter:hasJumpDrive())
        escortShip:setFaction(freighter:getFaction())


        escortShip:setCallSign(string.format(escortCallsignFormat, freighter:getCallSign(), escortCount))

        escortCount = escortCount + 1

        escortShip.freighter = freighter

        table.insert(escortShip.freighter.escorts, escortShip)
    end

    local angleSeparation = 300.0 / (#freighter.escorts + 1)
    for i=1, #freighter.escorts do
        local dx, dy = vectorFromAngle(30.0 + i * angleSeparation, 700)
        freighter.escorts[i]:setPosition(fx + dx, fy + dy)
        ElectricExplosionEffect():setPosition(fx + dx, fy + dy):setSize(300):setOnRadar(true)

        freighter.escorts[i]:setRotation(freighter:getRotation())
        freighter.escorts[i]:setScanned(freighter:isFriendly(getPlayerShip(-1)))
    end

    print("[Commerce] Spawned fleet " .. freighter:getCallSign() .. " with " .. escortCount .. " escorts")
end

function maybeRespawnCommerceFleet(wormhole, teleportee)
    for i=1, #commerceFreighters do
        if commerceFreighters[i] == teleportee then
            --- yep, it was a freighter that just jumped.
            --- therefore, respawn a new fleet from the other wormhole
            local spawnAtWh = nil
            local tradeRoute = nil
            if wormhole == southExitWh then
                print("[Commerce] Respawning commerce fleet at north wormwhole")
                spawnAtWh = northExitWh
                tradeRoute = tradeRouteNorthToSouth
            else 
                print("[Commerce] Respawning commerce fleet at south wormwhole")
                spawnAtWh = southExitWh 
                tradeRoute = tradeRouteSouthToNorth
            end
            local wx, wy = spawnAtWh:getPosition()
            local dx, dy = vectorFromAngle(random(0,360),random(3500,4000))
            spawnCommerceFleet(wx+dx, wy+dy, tradeRoute, 0)
        end
    end
end
