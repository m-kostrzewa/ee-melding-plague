require("utils.lua")
require("./69_mymission/comms.lua")
require("./69_mymission/commerce.lua")
require("./69_mymission/terrain.lua")
require("./69_mymission/wormholes.lua")
require("./69_mymission/globals.lua")
require("./69_mymission/ambush.lua")


local numSectorsPerSide
local currentMission 

function hfFreighterSosBlinking(delta)
    if not hfFreighter.sosBlinkingEnabled then
        return
    end
    blips = {1, 0, 1, 0, 1, 0, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0}
    currBlip = math.floor(getScenarioTime() * 4) % #blips

    if blips[currBlip] == 1 then
        hfFreighter:setCallSign("HF2137")
    else       
        hfFreighter:setCallSign("")
    end
end


local mission1_3a_setup_done = false
local function mission1_3a_goto_miners(delta)

    if not mission1_3a_setup_done then
        mission1_3a_setup_done = true

        hfFreighter:orderDock(minerHab)

        freeport9CommsMissionSpecific = freeport9Comms_m1_3_a --- todo
        minerHabCommsMissionSpecific = minerHabComms_m1_3_a
        hfFreighterCommsMissionSpecific = hfFreighterComms_m1_3_a
    end
end

local mission1_3b_setup_done = false
local function mission1_3b_jump_carrier(delta)

    if not mission1_3b_setup_done then
        mission1_3b_setup_done = true

        --- todo
    end
end



local mission1_2_setup_done = false
local function mission1_2_lookForSignal(delta)

    if not mission1_2_setup_done then
        mission1_2_setup_done = true
        freeport9CommsMissionSpecific = freeport9Comms_m1_2
        minerHabCommsMissionSpecific = minerHabComms_m1_2
        hfFreighterCommsMissionSpecific = hfFreighterComms_m1_2
    end

    if hfFreighter.gotoMiners then
        currentMission = mission1_3a_goto_miners

    elseif hfFreighter.awaitJumpCarrier then
        freeport9CommsMissionSpecific = freeport9Comms_m1_3_b
        currentMission = mission1_3b_jump_carrier
    end
end


local function mission1_1_prologue(delta)

    freeport9CommsMissionSpecific = freeport9Comms_m1_1

    if getScenarioTime() >= 30 and stroke2.talked and stroke4.talked then
        stroke1:sendCommsMessage(
            getPlayerShip(-1),
            _("Stroke 3, report to Freeport 9 command.")
        )
        currentMission = mission1_2_lookForSignal
    end

end


function myInit()
    -- currentMission = mission1_1_prologue
    currentMission = mission1_2_lookForSignal

    initializeWormholes()



    player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Phobos M3P"):setCallSign("Stroke 3"):setWarpDrive(true)
    player:setPosition(156412, 96481)

    player.nearExitWormhole = false
    player.nearMapBoundary = false
    
    freeport9 = SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setCallSign("Freeport 9"):setPosition(2000, 2000):setHeading(270):setCommsFunction(freeport9Comms)
    local freeport9X, freeport9Y = freeport9:getPosition()

    --- TODO: less probes??..
    stroke1 = CpuShip():setFaction("Human Navy"):setTemplate("Phobos M3"):setCallSign("Stroke 1"):setScanned(true):setPosition(-1000, 0):setHeading(270):setCommsFunction(stroke1Comms):orderDefendTarget(freeport9):setWarpDrive(true)
    stroke1:setImpulseMaxSpeed(stroke1:getImpulseMaxSpeed() * 0.9) --- so that escorts can catch up
    stroke1.talked = false
    --- TODO: should be a way to make this guy like us.
    stroke1.likesPlayer = false

    stroke2 = CpuShip():setFaction("Human Navy"):setTemplate("Phobos M3"):setCallSign("Stroke 2"):setScanned(true):setPosition(-500, -500):setHeading(270):setCommsFunction(stroke2Comms):orderFlyFormation(stroke1, -500, 500):setWarpDrive(true)
    stroke2.talked = false
    stroke2.likesPlayer = false

    stroke4 = CpuShip():setFaction("Human Navy"):setTemplate("Phobos M3"):setCallSign("Stroke 4"):setScanned(true):setPosition(-500, 500):setHeading(270):setCommsFunction(stroke4Comms):orderFlyFormation(stroke1, -500, -500):setWarpDrive(true)
    stroke4.talked = false
    stroke4.likesPlayer = false

    minerHab = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("Hab 220"):setPosition(138263, 64230):setRotation(random(0, 360)):setCommsFunction(minerHabComms)
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("Hab 218"):setPosition(135338, 64184):setRotation(random(0, 360)):setCommsFunction(minerHabNope1Comms)
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("Hab 221"):setPosition(136087, 66575):setRotation(random(0, 360)):setCommsFunction(minerHabNope2Comms)
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("Hab 219"):setPosition(137619, 63725):setRotation(random(0, 360)):setCommsFunction(minerHabNope3Comms)

    local minerHabX, minerHabY = minerHab:getPosition()

    --- todo: chat for these ships
    CpuShip():setFaction("Independent"):setTemplate("Transport3x5"):setCallSign("SS5"):setPosition(136479, 64503)
    CpuShip():setFaction("Independent"):setTemplate("Transport1x5"):setCallSign("NC9"):setPosition(135424, 64701)
    CpuShip():setFaction("Independent"):setTemplate("Tug"):setCallSign("UTI6"):setPosition(136243, 66132)

    --- todo: station comms
    bobsStation = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("Bob's"):setPosition(144785, -93706)

    --- blockade due to some anomaly
    --- but navy ships want them to let you through because you are also navy (rep +- miners)

    --- todo: station comms
    --- todo: part of this escort can be called for a mission but will lead to different outcome (smugglers pass by border control maybe?)
    borderStation = SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):setCallSign("Border station K83"):setPosition(-81260, 140904)

    CpuShip():setFaction("Human Navy"):setTemplate("Weapons platform"):setCallSign("BDF88"):setPosition(-80703, 141433):orderRoaming():setCommsFunction(randomizedBdfCommsFunc()):setScanned(true)

    local bdf01 = CpuShip():setFaction("Human Navy"):setTemplate("Dreadnought"):setCallSign("BDF01"):setPosition(-80487, 140147):orderDefendLocation(-80587, 140025):setCommsFunction(randomizedBdfCommsFunc()):setScanned(true)
    CpuShip():setFaction("Human Navy"):setTemplate("MU52 Hornet"):setCallSign("BDF13"):setPosition(-81986, 142951):orderDefendTarget(bdf01):setCommsFunction(randomizedBdfCommsFunc()):setScanned(true)
    CpuShip():setFaction("Human Navy"):setTemplate("MU52 Hornet"):setCallSign("BDF14"):setPosition(-81014, 142838):orderDefendTarget(bdf01):setCommsFunction(randomizedBdfCommsFunc()):setScanned(true)

    --- todo: anomalous description and changing science readings.
    hfFreighter = CpuShip():setFaction("Independent"):setTemplate("Garbage Freighter 3"):setCallSign("HF2137"):setPosition(157226, 97278):orderIdle():setCommsFunction(hfFreighterComms)
    hfFreighter.sosBlinkingEnabled = true
    hfFreighter.spottedFriends = false
    hfFreighter.initialX, hfFreighter.initialY = hfFreighter:getPosition()

    --- jump cruiser picks up hfFreighter
    -- jumpC = CpuShip():setFaction("Independent"):setTemplate("Jump Carrier"):setCallSign("JC"):setPosition(146708, 142000)
    -- hfFreighter:orderDock(jumpC)


    --- todo: add ElectricExplosionEffect to some nebulas
    --- todo: add asteroids and visualasteroids whatever they are

    numSectorsPerSide = 20
    initializeNebulas(60, 0, 0, numSectorsPerSide)


    clearNebulasInRadius(minerHabX, minerHabY, 10000)
    clearNebulasInRadius(freeport9X, freeport9Y, 10000)
    clearNebulasInRadius(hfFreighter.initialX, hfFreighter.initialY, 10000)

    createInRing(Nebula, 5, 8000, 10000, minerHabX, minerHabY)
    createInRing(Nebula, 10, 8000, 10000, hfFreighter.initialX, hfFreighter.initialY)

    combNebulas()

    initializeCommerce()

    ambushInit()
end


function playerNearingMapBoundary(delta)
    local ships = getActivePlayerShips() 
    for i = 1, #ships do
        local ps = ships[i]
        if ps:isValid() then
            local distToFp9 = distance(ps, freeport9)
                
            if distToFp9 < ((numSectorsPerSide - 2) / 2) * 20000 and ps.nearMapBoundary == true then 
                ps.nearMapBoundary = false
            elseif distToFp9 > ((numSectorsPerSide - 1) / 2) * 20000 and ps.nearMapBoundary == false then 
                freeport9:sendCommsMessage(
                    ps,
                    _(ps:getCallSign() .. ", you're approaching the boundaries of our operational area. Turn back or face consequences of desertion.")
                )
                ps.nearMapBoundary = true
            elseif distToFp9 > (numSectorsPerSide / 2) * 20000 then 
                victory("Independent")
            end
        end
    end
end

function myUpdate(delta)
    if currentMission == nil then
        print("currentMission is nil.")
    else
        currentMission(delta)
    end


    wormholePlayerNearingExitPoint(delta)
    wormholeRotate(delta)

    playerNearingMapBoundary(delta)

    --- todo : add nebula animation ("waviness")
    --- todo: add nebula animation ("storms")

    updateCommerce(delta)

    hfFreighterSosBlinking(delta)

    ambushUpdate(delta)
end
