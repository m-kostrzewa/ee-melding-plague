require("./69_mymission/globals.lua")

local stateBeginNewLeg = 0
local stateDuringTransit = 1
local stateDockedUnpacking = 2
local stateEgressSystem = 3
local stateUnstuck = 8
local stateDuringCombat = 9

local function requestDetailedItineraryComms()
    local tradeRoute = comms_target.tradeRoute
    local tradeRouteStrs = {}
    for i=1, #tradeRoute do
        table.insert(tradeRouteStrs, string.format("%s in %s", tradeRoute[i]:getCallSign(), tradeRoute[i]:getSectorName()))
    end
    setCommsMessage(_(string.format("Detailed itinerary: \n* %s", table.concat(tradeRouteStrs, ",\n* "))))
end

local function duringCombatComms()
    rand = irandom(0, 3)

    if rand == 0 then
        setCommsMessage(_("No time for chit-chat, we're in the middle of combat!"))
    elseif rand == 1 then
        setCommsMessage(_("A little bit busy right now!"))
    elseif rand == 2 then
        setCommsMessage(_("Engaging enemy."))
    elseif rand == 3 then
        setCommsMessage(_("Could use a hand right now..."))
    end
end


local function randomCommerceFreighterShipCommsFunc()
    local rand = irandom(0, 3)
    if rand == 0 then
        return function()
            if comms_target.state == stateDuringCombat then
                duringCombatComms()
            else 
                setCommsMessage(_(
                    "This is " .. comms_target:getCallSign() .. " " .. comms_target:getFaction() .. " freighter. " .. 
                    "We're currently en route to " .. comms_target.tradeRoute[comms_target.currentLeg]:getCallSign() .. 
                    ". Ultimately, we're departing to " .. comms_target.tradeRoute[#comms_target.tradeRoute]:getCallSign() ..
                    ". " .. (#comms_target.tradeRoute - comms_target.currentLeg) .. " waypoints remaining."))
                addCommsReply(
                    _("Request detailed itinerary."),
                    requestDetailedItineraryComms
                )
            end
        end
    elseif rand == 1 then
        return function()
            if comms_target.state == stateDuringCombat then
                duringCombatComms()
            else 
                setCommsMessage(_(
                    comms_target:getFaction() .. " transport " .. comms_target:getCallSign() .. " here. " .. 
                    "Our ultimate destination is " .. comms_target.tradeRoute[#comms_target.tradeRoute]:getCallSign() .. 
                    ". We have " .. (#comms_target.tradeRoute - comms_target.currentLeg) .. " more stops in this system."))
                addCommsReply(
                    _("Request detailed itinerary."),
                    requestDetailedItineraryComms
                )
            end
        end
    elseif rand == 2 then
        return function()
            if comms_target.state == stateDuringCombat then
                duringCombatComms()
            else 
                setCommsMessage(_(
                    "I'm the captain of " .. comms_target:getFaction() .. " convoy " .. comms_target:getCallSign() .. ". " ..
                    "We're just passing by this sector. We're on our way to " .. comms_target.tradeRoute[#comms_target.tradeRoute]:getCallSign() .. "."))
                addCommsReply(
                    _("Request detailed itinerary."),
                    requestDetailedItineraryComms
                )
            end
        end
    elseif rand == 3 then
        return function()
            if comms_target.state == stateDuringCombat then
                duringCombatComms()
            else 
                setCommsMessage(_("This is " .. comms_target:getCallSign() .. ". We're " .. comms_target:getFaction() .. "."))
                addCommsReply(
                    _("Request detailed itinerary."),
                    requestDetailedItineraryComms
                )
            end
        end
    end
end

local function randomCommerceEscortShipCommsFunc()
    rand = irandom(0, 3)
    if rand == 0 then
        return function()
            if comms_target.freighter.state == stateDuringCombat then
                duringCombatComms()
            else 
                setCommsMessage(_("This is " .. comms_target:getCallSign() .. ". I'm escorting " .. comms_target.freighter:getCallSign() .. "."))
            end
        end
    elseif rand == 1 then
        return function()
            if comms_target.freighter.state == stateDuringCombat then
                duringCombatComms()
            else 
                setCommsMessage(_(comms_target:getCallSign() .. " here. If you want anything, talk to my boss on " .. comms_target.freighter:getCallSign() .. "."))
            end
        end
    elseif rand == 2 then
        return function()
            if comms_target.freighter.state == stateDuringCombat then
                duringCombatComms()
            else 
                setCommsMessage(_("Just a lowly escort pilot. " .. comms_target:getCallSign() .. " out."))
            end
        end
    elseif rand == 3 then
        return function()
            if comms_target.freighter.state == stateDuringCombat then
                duringCombatComms()
            else 
                setCommsMessage(_("Hello. You probably want my boss on " .. comms_target.freighter:getCallSign() .. " ."))
            end
        end
    end
end


local function newDestination(alreadyVisited, thisLeg, ultimateDest)
    local possibleDestinations = {}

    if thisLeg == freeport9 then
        for i=1, #habs do
            table.insert(possibleDestinations, {weight = 10, tgt = habs[i]})
        end

        if ultimateDest == northExitWh then
            table.insert(possibleDestinations, {weight = 100, tgt = bobsStation})
        else 
            table.insert(possibleDestinations, {weight = 100, tgt = borderStation})
        end
    elseif thisLeg == bobsStation then
        if ultimateDest == northExitWh then
            table.insert(possibleDestinations, {weight = 100, tgt = northExitWh})
        else 
            table.insert(possibleDestinations, {weight = 100, tgt = freeport9})
        end
    elseif thisLeg == borderStation then
        if ultimateDest == southExitWh then
            table.insert(possibleDestinations, {weight = 100, tgt = southExitWh})
        else 
            table.insert(possibleDestinations, {weight = 100, tgt = freeport9})
        end
    else --- miner hab
        for i=1, #habs do
            if thisLeg.isEast == habs[i].isEast then
                table.insert(possibleDestinations, {weight = 10, tgt = habs[i]})
            end
        end
        table.insert(possibleDestinations, {weight = 60, tgt = freeport9})
    end

    for i=1, #alreadyVisited do
        if alreadyVisited[i] ~= freeport9 then --- freeport9 can be visited multiple times
            for j=1, #possibleDestinations do
                if possibleDestinations[j].tgt == alreadyVisited[i] then
                    table.remove(possibleDestinations, j)
                    break
                end
            end
        end
    end

    local totalWeight = 0
    for i=1, #possibleDestinations do
        totalWeight = totalWeight + possibleDestinations[i].weight
    end

    local roulette = irandom(1, totalWeight)
    local nextDest = nil
    for i=1, #possibleDestinations do
        if possibleDestinations[i].weight >= roulette then
            nextDest = possibleDestinations[i].tgt
            break
        else
            roulette = roulette - possibleDestinations[i].weight
        end
    end
    
    return nextDest
end

local function makeTradeRoute(startFrom, ultimateDest)

    local currentLeg = startFrom
    local alreadyVisited = {currentLeg}
    local tradeRoute = {}
    while true do
        local newDest = newDestination(alreadyVisited, currentLeg, ultimateDest)
        currentLeg = newDest
        table.insert(alreadyVisited, currentLeg)
        table.insert(tradeRoute, currentLeg)
        if newDest == ultimateDest then
            break
        end
    end



    return tradeRoute
end


function initializeCommerce()
    commerceFreighters = {}

    spawnCommerceFleet(-80728, 140307, makeTradeRoute(southExitWh, northExitWh))
    spawnCommerceFleet(1326, 8230, makeTradeRoute(borderStation, northExitWh))
    spawnCommerceFleet(-257, 1722, makeTradeRoute(freeport9, southExitWh))
    spawnCommerceFleet(-57647, 127520, makeTradeRoute(borderStation, northExitWh))
    spawnCommerceFleet(-10930, 38434, makeTradeRoute(borderStation, northExitWh))
    spawnCommerceFleet(-45973, 78147, makeTradeRoute(borderStation, northExitWh))
    spawnCommerceFleet(-47000, 80997, makeTradeRoute(borderStation, southExitWh))
    spawnCommerceFleet(-27702, 49339, makeTradeRoute(borderStation, southExitWh))

    spawnCommerceFleet(42466, -21290, makeTradeRoute(bobsStation, northExitWh))
    spawnCommerceFleet(46996, -31030, makeTradeRoute(bobsStation, northExitWh))
    spawnCommerceFleet(91390, -62287, makeTradeRoute(borderStation, northExitWh))
    spawnCommerceFleet(141447, -89920, makeTradeRoute(northExitWh, southExitWh))
    spawnCommerceFleet(84004, -33904, makeTradeRoute(bobsStation, southExitWh))
    spawnCommerceFleet(500, -1722, makeTradeRoute(freeport9, northExitWh))

    for i=1, 10 do
        local aHab = habs[irandom(1, #habs)]
        local hx, hy = aHab:getPosition()
        local dx, dy = vectorFromAngle(irandom(0, 360), 1000)
        if irandom(1, 100) < 50 then
            spawnCommerceFleet(hx + dx, hy + dy, makeTradeRoute(aHab, northExitWh))
        else
            spawnCommerceFleet(hx + dx, hy + dy, makeTradeRoute(aHab, southExitWh))
        end
    end
end


local function updateCommerceFleet(delta, freighter)
    if not freighter:isValid() then
        for i=1, #freighter.escorts do
            if freighter.escorts[i]:isValid() then 
                freighter.escorts[i]:orderFlyTowards(freighter.tradeRoute[#freighter.tradeRoute]:getPosition())
            end
        end
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
            print("[Commerce] Invalid target typeName " .. dest.typeName )
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
    if getScenarioTime() > freighter.nextPosMeasurementAt then
        if (freighter.state == stateDuringTransit or freighter.state == stateEgressSystem) and
            distance(freighter, freighter.lastPosMeasurementX, freighter.lastPosMeasurementY) < 50.0 then
            print("[Commerce] " .. freighter:getCallSign() .. " unstucking self")
            freighter.state = stateUnstuck
            freighter.nextStateTransitionAt = getScenarioTime() + irandom(5, 10)
            freighter:orderDefendLocation(freighter:getPosition())
        elseif freighter.state == stateUnstuck and getScenarioTime() > freighter.nextStateTransitionAt then
            print("[Commerce] " .. freighter:getCallSign() .. " should've unstucked myself")
            freighter.state = stateBeginNewLeg
        end

        freighter.lastPosMeasurementX, freighter.lastPosMeasurementY = freighter:getPosition()
        freighter.nextPosMeasurementAt = getScenarioTime() + irandom(25, 40)
    end

    if freighter.state == stateDockedUnpacking and getScenarioTime() > freighter.nextStateTransitionAt then
        print("[Commerce] " .. freighter:getCallSign() .. " departing " .. dest:getCallSign())
        freighter.state = stateBeginNewLeg
        freighter.currentLeg = freighter.currentLeg + 1
    end
end


function updateCommerce(delta)
    for i = 1, #commerceFreighters do
        updateCommerceFleet(delta, commerceFreighters[i])
    end
end

function spawnCommerceFleet(spawnLocationX, spawnLocationY, tradeRoute)

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
        "Personnel Jump Freighter 3","Personnel Jump Freighter 4","Personnel Jump Freighter 5",

        --- some quick traffic
        "Adder MK3", "Adder MK4", "Adder MK5", "Adder MK8", "MT52 Hornet", "MU52 Hornet", "Fighter",
        "Adder MK3", "Adder MK4", "Adder MK5", "Adder MK8", "MT52 Hornet", "MU52 Hornet", "Fighter",
        "Adder MK3", "Adder MK4", "Adder MK5", "Adder MK8", "MT52 Hornet", "MU52 Hornet", "Fighter",
    }
    local escortTypes = {
        "Adder MK3", "Adder MK4", "Adder MK5", "Adder MK8", "MT52 Hornet", "MU52 Hornet", "Fighter"
    }
    local escortCallsignFormats =  {
        "%s E %i", "%s-%i", "%s/%i", "%s 0%i"
    }

    local faction = factions[irandom(1, #factions)]
    local freighterType = freighterTypes[irandom(1, #freighterTypes)]
    local freighter = CpuShip():
        setTemplate(freighterType):setFaction(faction):setCommsFunction(randomCommerceFreighterShipCommsFunc()):setPosition(spawnLocationX, spawnLocationY)
    freighter:setScanned(freighter:isFriendly(getPlayerShip(-1)))

    ElectricExplosionEffect():setPosition(spawnLocationX, spawnLocationY):setSize(600):setOnRadar(true)

    freighter.tradeRoute = tradeRoute
    freighter.currentLeg = 1
    freighter.state = stateBeginNewLeg
    freighter.stateBeforeCombat = nil
    freighter.escorts = {}

    --- for unstuck logic
    freighter.nextPosMeasurementAt = getScenarioTime() + 20.0
    freighter.lastPosMeasurementX, freighter.lastPosMeasurementY = freighter:getPosition()

    freighter.ultimateDestStr = "somewhere"
    if #freighter.tradeRoute > 0 then
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
    end
    
    table.insert(commerceFreighters, freighter)

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

    if escortCount == 0 then
        --- warp drive doesn't work with formations at all
        --- chance of warp drive if no escorts present
        if irandom(0,100) < 33 then
            freighter:setWarpDrive(true)
            freighter:setJumpDrive(false)
        end
    end

    local tradeRouteStrs = {}
    for i=1, #tradeRoute do
        table.insert(tradeRouteStrs, tradeRoute[i]:getCallSign())
    end
    print("[Commerce] Spawned fleet " .. freighter:getCallSign() .. " with " .. escortCount .. " escorts, waypoints: ", table.concat(tradeRouteStrs, ", "))
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
                tradeRoute = makeTradeRoute(northExitWh, southExitWh)
            else 
                print("[Commerce] Respawning commerce fleet at south wormwhole")
                spawnAtWh = southExitWh 
                tradeRoute = makeTradeRoute(southExitWh, northExitWh)
            end
            local wx, wy = spawnAtWh:getPosition()
            local dx, dy = vectorFromAngle(random(0,360),random(3500,4000))
            spawnCommerceFleet(wx+dx, wy+dy, tradeRoute, 0)
        end
    end
end
