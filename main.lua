require("utils.lua")
require("./69_mymission/comms.lua")
require("./69_mymission/commerce.lua")


local currentMission

-- local freeport9

-- local stroke1
-- local stroke3
-- local stroke4

-- local minerHab

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



    --- blockade due to some anomaly
    --- but navy ships want them to let you through because you are also navy (rep +- miners)

    --- todo: station comms
    --- todo: needs some heavy escort
    --- todo: part of this escort can be called for a mission but will lead to different outcome (smugglers pass by border control maybe?)
    borderStation = SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):setCallSign("Border station K83"):setPosition(-81260, 140904)


    initializeCommerce()
end



function myUpdate(delta)
    if currentMission == nil then
        print("currentMission is nil.")
    else
        currentMission(delta)
    end

    wormholePlayerNearingExitPoint(delta)
    wormholeRotate(delta)

    updateCommerce(delta)
end
