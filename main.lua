require("utils.lua")
require("./69_themeldingplague/comms.lua")
require("./69_themeldingplague/commerce.lua")
require("./69_themeldingplague/terrain.lua")
require("./69_themeldingplague/wormholes.lua")
require("./69_themeldingplague/globals.lua")
require("./69_themeldingplague/kraylor.lua")
require("./69_themeldingplague/ghosts.lua")
require("./69_themeldingplague/border.lua")


local numSectorsPerSide
local currentMission 


local mission1_8a_setup_done = false
local function mission1_8a_ghost_ending(delta)
    if not mission1_8a_setup_done then
        mission1_8a_setup_done = true
        registerRetryCallback(5, function()
            return hfFreighter:sendCommsMessage(
                getPlayerShip(-1),
                _("We thank you. Let's talk.")
            )
        end)
        hfFreighterCommsMissionSpecific = hfFreighterComms_m1_7_end
    end
end

local mission1_8b_setup_done = false
local function mission1_8b_human_ending(delta)
    if not mission1_8b_setup_done then
        mission1_8b_setup_done = true
        registerRetryCallback(5, function()
            return freeport9:sendCommsMessage(
                getPlayerShip(-1),
                _(getPlayerShip(-1):getCallSign() .. ", report to " .. freeport9:getCallSign() .. " for final debriefing.")
            )
        end)
        freeport9CommsMissionSpecific = freeport9Comms_m1_7_end
    end
end


local mission1_7_setup_done = false
local function mission1_7_finalChoice(delta)
    if not mission1_7_setup_done then
        mission1_7_setup_done = true

        registerRetryCallback(5, function()
            return borderStation:sendCommsMessage(
                getPlayerShip(-1),
                _(getPlayerShip(-1):getCallSign() .. ", this is Doctor Jane. We need to talk. Face to face. I'm still at " .. borderStation:getCallSign())
            )
        end)

        borderStationCommsMissionSpecific = borderStationComms_m1_7
    end

    if getPlayerShip(-1):getFaction() == "Ghosts" and not freeport9:isValid() and not borderStation:isValid() then
        currentMission = mission1_8a_ghost_ending
    end

    if getPlayerShip(-1):getFaction() == "Human Navy" then
        local anyNeutralAlive = false
        for i=1, #allStationsRefs do
            local st = allStationsRefs[i]
            if st:isValid() and (st:getFaction() == "Independent" or st:getFaction() == "Ghosts") then
                print("Station alive: ", st:getCallSign())
                anyNeutralAlive = true
                break
            end
        end
        if not anyNeutralAlive then
            currentMission = mission1_8b_human_ending
        end
    end
end

local mission1_6_setup_done = false
local function mission1_6_plagueDoctor(delta)
    if not mission1_6_setup_done then
        mission1_6_setup_done = true

        registerRetryCallback(5, function()
            return freeport9:sendCommsMessage(
                getPlayerShip(-1),
                _(getPlayerShip(-1):getCallSign() .. ", report to " .. freeport9:getCallSign() .. ". The situation is dire.")
            )
        end)

        freeport9CommsMissionSpecific = freeport9Comms_m1_6
        minerHabCommsMissionSpecific = minerHabComms_m1_6
    end

    if foundSourceOfPlague then
        print("foundSourceOfPlague", foundSourceOfPlague)
        currentMission = mission1_7_finalChoice
    end
end


local mission1_5_setup_done = false
local function mission1_5_plagueQuarantineStart(delta)
    if not mission1_5_setup_done then
        mission1_5_setup_done = true

        registerRetryCallback(5, function()
            return freeport9:sendCommsMessage(
                getPlayerShip(-1),
                _(getPlayerShip(-1):getCallSign() .. ", report to " .. freeport9:getCallSign() .. " Command HQ as soon as possible.")
            )
        end)

        freeport9CommsMissionSpecific = freeport9Comms_m1_5
        borderStationCommsMissionSpecific = borderStationComms_m1_5
    end

    if borderStationQuarantine then
        currentMission = mission1_6_plagueDoctor
    end
end


local mission1_4_setup_done = false
local function mission1_4_kraylorSkirmishes(delta)
    if not mission1_4_setup_done then
        mission1_4_setup_done = true

        activateKraylorAttacks()

        registerRetryCallback(5, function()
            return freeport9:sendCommsMessage(
                getPlayerShip(-1),
                _(getPlayerShip(-1):getCallSign() .. ", report to " .. freeport9:getCallSign() .. " Command HQ, we've got another assignment for you.")
            )
        end)

        freeport9CommsMissionSpecific = freeport9Comms_m1_4
        minerHabCommsMissionSpecific = nil
        hfFreighterCommsMissionSpecific = nil
    end

    if freeport9.plagueAlertLevel >= 5 then
        currentMission = mission1_5_plagueQuarantineStart
    end
end

local mission1_3a_setup_done = false
local function mission1_3a_goto_miners(delta)
    if not mission1_3a_setup_done then
        mission1_3a_setup_done = true

        hfFreighter:orderDock(minerHab)

        freeport9CommsMissionSpecific = freeport9Comms_m1_3_a
        minerHabCommsMissionSpecific = minerHabComms_m1_3_a
        hfFreighterCommsMissionSpecific = hfFreighterComms_m1_3_a
    end

    if ambushState == ambushStateDone then
        currentMission = mission1_4_kraylorSkirmishes

    end
end

-- local mission1_3b_setup_done = false
-- local function mission1_3b_jump_carrier(delta)
--     if not mission1_3b_setup_done then
--         mission1_3b_setup_done = true
--     end
-- end


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

local mission1_1_setup_done = false
local function mission1_1_prologue(delta)
    if not mission1_1_setup_done then
        mission1_1_setup_done = true

        freeport9CommsMissionSpecific = freeport9Comms_m1_1
        stroke1CommsMissionSpecific = stroke1Comms_m1_1
        stroke2CommsMissionSpecific = stroke2Comms_m1_1
        stroke4CommsMissionSpecific = stroke4Comms_m1_1
    end

    if stroke1.talked and stroke2.talked and stroke4.talked then
        registerRetryCallback(5, function()
            return freeport9:sendCommsMessage(
                getPlayerShip(-1),
                _(getPlayerShip(-1):getCallSign() .. ", report to " .. freeport9:getCallSign() .. " Command HQ.")
            )
        end)
        currentMission = mission1_2_lookForSignal
    end

end

function myInit()
    print([[

_____ _           ___  ___     _     _ _                     _                        
|_   _| |          |  \/  |    | |   | (_)                   | |                       
  | | | |__   ___  | .  . | ___| | __| |_ _ __   __ _   _ __ | | __ _  __ _ _   _  ___ 
  | | | '_ \ / _ \ | |\/| |/ _ | |/ _` | | '_ \ / _` | | '_ \| |/ _` |/ _` | | | |/ _ \
  | | | | | |  __/ | |  | |  __| | (_| | | | | | (_| | | |_) | | (_| | (_| | |_| |  __/
  \_/ |_| |_|\___| \_|  |_/\___|_|\__,_|_|_| |_|\__, | | .__/|_|\__,_|\__, |\__,_|\___|
                                                 __/ | | |             __/ |  by Kosai 
                                                |___/  |_|            |___/            
        
  ]])

    currentMission = mission1_1_prologue

    player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Phobos M3P"):setCallSign("Stroke 3"):setWarpDrive(true)
    player:setPosition(0, 0):setHeading(270)
    player:setReputationPoints(100) --- TO PLAYTEST?

    player.nearExitWormhole = false
    player.nearMapBoundary = false

    player.paidDockingFees = false
    player.hasOnShorePermit = false
    

    freeport9 = SpaceStation():setTemplate("Large Station"):setFaction("Human Navy"):setCallSign("Freeport 9"):setPosition(2000, 2000):
        setHeading(270):setCommsFunction(freeport9Comms)
    local freeport9X, freeport9Y = freeport9:getPosition()
    freeport9.plagueAlertLevel = 0
    freeport9["Homing"] = 12
    freeport9["Nuke"] = 1
    freeport9["Mine"] = 3
    freeport9["EMP"] = 2
    freeport9["HVLI"] = 29
    freeport9["Probe"] = 15


    stroke1 = CpuShip():setFaction("Human Navy"):setTemplate("Phobos M3"):setCallSign("Stroke 1"):setScanned(true):setPosition(-1000, 0):
        setHeading(270):setCommsFunction(stroke1Comms):orderDefendTarget(freeport9):setWarpDrive(true)
    stroke1:setImpulseMaxSpeed(stroke1:getImpulseMaxSpeed() * 0.9) --- so that escorts can catch up
    stroke1.talked = false
    stroke1.likesPlayer = false

    stroke2 = CpuShip():setFaction("Human Navy"):setTemplate("Phobos M3"):setCallSign("Stroke 2"):setScanned(true):setPosition(-500, -500):
        setHeading(270):setCommsFunction(stroke2Comms):orderFlyFormation(stroke1, -500, 500):setWarpDrive(true)
    stroke2.talked = false
    stroke2.likesPlayer = false

    stroke4 = CpuShip():setFaction("Human Navy"):setTemplate("Phobos M3"):setCallSign("Stroke 4"):setScanned(true):setPosition(-500, 500):
        setHeading(270):setCommsFunction(stroke4Comms):orderFlyFormation(stroke1, -500, -500):setWarpDrive(true)
    stroke4.talked = false
    stroke4.likesPlayer = false


    --- todo: anomalous description
    --- todo comms of infected stations and ships

    --- jump cruiser picks up hfFreighter
    -- jumpC = CpuShip():setFaction("Independent"):setTemplate("Jump Carrier"):setCallSign("JC"):setPosition(146708, 142000)
    -- hfFreighter:orderDock(jumpC)

    --- todo(visual): add ElectricExplosionEffect to some nebulas
    --- todo(visual): add asteroids and visualasteroids whatever they are

    initializeWormholes()
    initializeMinerHabs()
    initializeCommerce()
    initializeKraylor()
    initializeGhosts()

    borderStationInit()

    local minerHabX, minerHabY = minerHab:getPosition()

    numSectorsPerSide = 20
    initializeNebulas(60, 0, 0, numSectorsPerSide)

    clearNebulasInRadius(minerHabX, minerHabY, 10000)
    clearNebulasInRadius(freeport9X, freeport9Y, 10000)
    clearNebulasInRadius(hfFreighter.initialX, hfFreighter.initialY, 10000)

    createInRing(Nebula, 5, 8000, 10000, minerHabX, minerHabY)
    createInRing(Nebula, 10, 8000, 10000, hfFreighter.initialX, hfFreighter.initialY)

    combNebulas()

    rememberAllStations()

    createAsteroids()
end


function playerNearingMapBoundary(delta)
    local ships = getActivePlayerShips() 
    for i = 1, #ships do
        local ps = ships[i]
        if ps:isValid() then
            local distToFp9 = distance(ps, 0, 0)
                
            if distToFp9 < ((numSectorsPerSide - 2) / 2) * 20000 and ps.nearMapBoundary == true then 
                ps.nearMapBoundary = false
            elseif distToFp9 > ((numSectorsPerSide - 1) / 2) * 20000 and ps.nearMapBoundary == false then 
                freeport9:sendCommsMessage(
                    ps,
                    _(ps:getCallSign() .. ", you're approaching the boundaries of our operational area (" .. (numSectorsPerSide / 2) * 20000 ..
                        " units away from " .. freeport9:getCallSign() .. ") As a reminder: leaving the operational area is considered desertion.")
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

    --- todo(visual) : add nebula animation ("waviness")
    --- todo(visual) : add nebula animation ("storms")

    updateCommerce(delta)

    hfFreighterSosBlinking(delta)

    ambushUpdate(delta)

    rotateStations(delta)

    --- todo: add rep for killing those guys
    kraylorSkirmishesUpdate(delta)

    ghostsPlagueUpdate(delta)

    borderStationUpdate(delta)

    updateCallbacks(delta)

    updateAnomalousReadings(delta)

    ghostDefensiveFleetUpdate(delta)
end
