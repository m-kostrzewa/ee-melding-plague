require("utils.lua")
require("./69_mymission/comms.lua")


local currentMission

-- local freeport9

-- local stroke1
-- local stroke3
-- local stroke4

-- local minerHab

local commerceFreighters = nil

function create(object_type, amount, dist_min, dist_max, x0, y0)
    for n = 1, amount do
        local r = random(0, 360)
        local distance = random(dist_min, dist_max)
        x = x0 + math.cos(r / 180 * math.pi) * distance
        y = y0 + math.sin(r / 180 * math.pi) * distance
        object_type():setPosition(x, y)
    end
end



function hfFreighterSquawk(delta)
    blips = {1, 0, 1, 0, 1, 0, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0}
    currBlip = math.floor(getScenarioTime() * 4) % #blips

    if blips[currBlip] == 1 then
        hfFreighter:setCallSign("HF2137")
    else
        hfFreighter:setCallSign("")
    end
end

local mission1_2_setup_done = false
local function mission1_2_body(delta)

    if not mission1_2_setup_done then
        mission1_2_setup_done = true
    end

    freeport9CommsMissionSpecific = freeport9Comms_m1_2

    minerHabCommsMissionSpecific = minerHabComms_m1_2

    hfFreighterSquawk(delta)
end


local function mission1_1_pre(delta)

    freeport9CommsMissionSpecific = freeport9Comms_m1_1

    if getScenarioTime() >= 30 and stroke2.talked and stroke4.talked then
        stroke1:sendCommsMessage(
            getPlayerShip(-1),
            _("Stroke 3, report to Freeport 9 command.")
        )
        currentMission = mission1_2_body
    end

end


function myInit()
    -- currentMission = mission1_1_pre
    currentMission = mission1_2_body

    player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Phobos T3"):setCallSign("Stroke 3"):setWarpDrive(true):setCanCombatManeuver(true)

    freeport9 = SpaceStation():setTemplate("Huge Station"):setFaction("Human Navy"):setCallSign("Freeport 9"):setPosition(2000, 2000):setCommsFunction(freeport9Comms)
    local fp9_x, fp9_y = freeport9:getPosition()


    -- table.insert(friendlyList, setCirclePos(CpuShip():setTemplate(friendlyShip[friendlyShipIndex]):setRotation(a):setFaction("Human Navy"):orderRoaming():setScanned(true), 0, 0, a + random(-5, 5), d + random(-100, 100)))



    --- TODO: less probes??..
    stroke1 = CpuShip():setFaction("Human Navy"):setTemplate("Phobos T3"):setCallSign("Stroke 1"):setScanned(true):setPosition(500, 500):setCommsFunction(stroke1Comms):orderDefendTarget(freeport9):setWarpDrive(true)
    stroke1.talked = false
    --- TODO: should be a way to make this guy like us.
    stroke1.likesPlayer = false

    stroke2 = CpuShip():setFaction("Human Navy"):setTemplate("Phobos T3"):setCallSign("Stroke 2"):setScanned(true):setPosition(500, 700):setCommsFunction(stroke2Comms):orderFlyFormation(stroke1, 200, 200):setWarpDrive(true)
    stroke2.talked = false
    stroke2.likesPlayer = false

    stroke4 = CpuShip():setFaction("Human Navy"):setTemplate("Phobos T3"):setCallSign("Stroke 4"):setScanned(true):setPosition(500, 300):setCommsFunction(stroke4Comms):orderFlyFormation(stroke1, -200, 200):setWarpDrive(true)
    stroke4.talked = false
    stroke4.likesPlayer = false

    local sectorSize = 10000

    -- for n = 1, 20 do
    --     Nebula():setPosition(random(-4*sectorSize, 4*sectorSize), random(-2*sectorSize, 2*sectorSize))
    -- end
    create(Nebula, 40, 15000, 40000, fp9_x, fp9_y)

    -- local zone = Zone():setPoints(0, 0, 500, 100, 600, 700, 300, 400)



    minerHab = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("Hab 220"):setPosition(138263, 64230):setRotation(random(0, 360)):setCommsFunction(minerHabComms)
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("Hab 218"):setPosition(135338, 64184):setRotation(random(0, 360)):setCommsFunction(minerHabNope1Comms)
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("Hab 221"):setPosition(136087, 66575):setRotation(random(0, 360)):setCommsFunction(minerHabNope2Comms)
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("Hab 219"):setPosition(137619, 63725):setRotation(random(0, 360)):setCommsFunction(minerHabNope3Comms)

    local minerHab_x, minerHab_y = minerHab:getPosition()

    --- add ElectricExplosionEffect to some nebulas
    create(Nebula, 40, 15000, 40000, minerHab_x, minerHab_y)

    --- todo: chat for these ships
    CpuShip():setFaction("Independent"):setTemplate("Transport3x5"):setCallSign("SS5"):setPosition(136479, 64503)
    CpuShip():setFaction("Independent"):setTemplate("Transport1x5"):setCallSign("NC9"):setPosition(135424, 64701)
    CpuShip():setFaction("Independent"):setTemplate("Tug"):setCallSign("UTI6"):setPosition(136243, 66132)


    hfFreighter = CpuShip():setFaction("Independent"):setTemplate("Transport5x1"):setCallSign("HF2137"):setPosition(180616, 61131):orderIdle():setImpulseMaxSpeed(0)
    Nebula():setPosition(174809, 60968)

    --- todo: station comms
    bobsStation = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("Bob's"):setPosition(144785, -93706)
    northExitWh = WormHole():setPosition(143898, -99701)
    northExitWh:setTargetPosition(170960, -132962)
    northExitWh:onTeleportation(function(self, teleportee)
        if teleportee.typeName == "PlayerSpaceship" then
            victory("Independent")
        else
            teleportee:destroy()
        end
    end)

    --- todo: station comms
    --- todo: needs some heavy escort
    --- todo: part of this escort can be called for a mission but will lead to different outcome (smugglers pass by border control maybe?)
    borderStation = SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):setCallSign("Border station K83"):setPosition(-81260, 140904)
    southExitWh = WormHole():setPosition(-85926, 144838)
    southExitWh:setTargetPosition(-169718, 193575)
    southExitWh:onTeleportation(function(self, teleportee)
        if teleportee.typeName == "PlayerSpaceship" then
            victory("Independent")
        else
            teleportee:destroy()
        end
    end)

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
    spawnCommerceFleet(-57647, 127520, tradeRouteSouthToNorth, 1)
    spawnCommerceFleet(-10930, 38434, tradeRouteSouthToNorth, 1)
    spawnCommerceFleet(-45973, 78147, tradeRouteSouthToNorth, 1)

    spawnCommerceFleet(42466, -21290, tradeRouteNorthToSouth, 1)
    spawnCommerceFleet(46996, -31030, tradeRouteNorthToSouth, 1)
    spawnCommerceFleet(91390, -62287, tradeRouteSouthToNorth, 2)
    spawnCommerceFleet(141447, -89920, tradeRouteNorthToSouth, 0)
    spawnCommerceFleet(84004, -33904, tradeRouteNorthToSouth, 1)
end

function playerNearingExitPoint(delta)
    local ships = getActivePlayerShips() 
    for i = 1, #ships do
        ps = ships[i]
        if ps:isValid() then
            local distToNorthExit = distance(ps, northExitWh:getPosition())
            local distToSouthExit = distance(ps, southExitWh:getPosition())
    
            if distToNorthExit > 10000 and distToSouthExit > 10000 then
                ps.outsideExitArea = true
            elseif distToNorthExit < 8000 and ps.outsideExitArea == true then
                freeport9:sendCommsMessage(
                    ps,
                    _(ps:getCallSign() .. ", you're approaching a wormhole that leads deeper into independent space. By going through it you will leave the assigned mission area. " ..
                        "It will be considered desertion. Turn back ASAP.")
                )
                ps.outsideExitArea = false
            elseif distToSouthExit < 8000 and ps.outsideExitArea == true then
                freeport9:sendCommsMessage(
                    ps,
                    _(ps:getCallSign() .. ", that wormhole leads back to Human controlled space, which is outside our area of operations. Going through it would mean dereliction of duty.")
                )
                ps.outsideExitArea = false
            end
        end 
    end
end

function rotateWormholes(delta)
    southExitWh:setRotation(getScenarioTime() * 3)
    northExitWh:setRotation(getScenarioTime() * 10)
end

function spawnCommerceFleet(spawnLocationX, spawnLocationY, tradeRoute, startingLeg)

    local factions = {
        "Independent",
        "Independent",
        "Independent",
        "Human Navy",
        "CUF",
        "TSN"
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
        "MT52 Hornet", "MU52 Hornet", "Fighter"
    }
    -- tradeRoutes = {
    --     {bobsStation, freeport9, borderStation},
    --     {borderStation, freeport9, bobsStation}
    -- }

    local stateBeginNewLeg = 0
    local stateDuringTransit = 1
    local stateDockedUnpacking = 2
    local stateEgressSystem = 3

    local faction = factions[irandom(1, #factions)]
    local freighterType = freighterTypes[irandom(1, #freighterTypes)]
    local freighter = CpuShip():setTemplate(freighterType):setFaction(faction):setCommsFunction(randomCommerceFreighterShipCommsFunc())

    freighter.tradeRoute = tradeRoute
    freighter.currentLeg = startingLeg
    freighter.state = stateBeginNewLeg
    freighter.escorts = {}

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

    local freighterSpawnDX, freighterSpawnDY = vectorFromAngle(random(0, 360), random(3000, 4000))

    freighter:setPosition(spawnLocationX + freighterSpawnDX, spawnLocationY + freighterSpawnDY)

    table.insert(commerceFreighters, freighter)

    freighter.updateFunc = function()
        local dest = freighter.tradeRoute[freighter.currentLeg]

        if freighter.state == stateBeginNewLeg then
            if dest.typeName == "SpaceStation" then
                print("[Commerce] " .. freighter:getCallSign() .. " begin new leg to " .. dest:getCallSign())
                freighter:orderDock(dest)
                freighter.state = stateDuringTransit

            elseif dest.typeName == "WormHole" then
                print("[Commerce] " .. freighter:getCallSign() .. " eggressing system ")
                local whx, why = dest:getPosition()
                freighter:orderFlyTowards(dest:getPosition())
                freighter.state = stateEgressSystem
                for i=1, #freighter.escorts do
                    freighter.escorts[i]:orderFlyTowards(dest:getPosition())
                end
            else
                print("[Commerce]  Invalid target typeName " .. dest.typeName )
            end
        end

        if freighter.state == stateDuringTransit and freighter:isDocked(dest)  then
            local stayTime = irandom(30, 60)
            print("[Commerce] " .. freighter:getCallSign() .. " docked for " .. stayTime .. " seconds at " .. dest:getCallSign())

            freighter.state = stateDockedUnpacking
            freighter.dockLeaveAt = getScenarioTime() + stayTime
        end

        if freighter.state == stateDockedUnpacking and getScenarioTime() > freighter.dockLeaveAt then
            print("[Commerce] " .. freighter:getCallSign() .. " departing " .. dest:getCallSign())
            freighter.state = stateBeginNewLeg
            freighter.currentLeg = freighter.currentLeg + 1
        end

    end

    local fx, fy = freighter:getPosition()

    local escortType = escortTypes[irandom(1, #escortTypes)]
    local escortCount = 0

    local dx, dy = vectorFromAngle(random(0,360),random(1000,3000))

    while irandom(1, 100) < 70 do
        escortShip = CpuShip():setTemplate(escortType):setCommsFunction(randomCommerceEscortShipCommsFunc())
        escortShip:setJumpDrive(freighter:hasJumpDrive())
        escortShip:setFaction(freighter:getFaction())
        escortShip:setCallSign(string.format("%s E %i",freighter:getCallSign(), escortCount))
        escortShip:setPosition(fx + dx, fy + dy)
        --- TODO: fly in formation better? does it keep formation during jump?
        escortShip:orderDefendTarget(freighter)
        escortCount = escortCount + 1

        escortShip.freighter = freighter

        table.insert(escortShip.freighter.escorts, escortShip)
    end
end

function myUpdate(delta)
    if currentMission == nil then
        print("currentMission is nil.")
    else
        currentMission(delta)
    end

    playerNearingExitPoint(delta)
    rotateWormholes(delta)

    for i = 1, #commerceFreighters do
        commerceFreighters[i].updateFunc()
    end
end
