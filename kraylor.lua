require("./69_mymission/globals.lua")


northEastStation = nil
southStation = nil
southEastStation = nil

southFleet = {}
northFleet = {}

fleetStateDormant = 0
fleetStateAwaitingRespawn = 1
fleetStateRallying = 2
fleetStateAttacking = 3
fleetStateRallyStationDestroyed = 4


local function kralienFiendComms_1()
    setCommsMessage(_("Me Roghar raugharR', the humen slayer, whose father is Raghran raugharR', Scourge of the weak, whose father " ..
        "is Gar raugharR, drinker of blood. We talk. Cease fire. Yes?"))
    addCommsReply(
        _("Agreed."),
        function()
            ambushState = ambushStateCeaseFire
            setCommsMessage(_("Okay. I bring friends over."))
            addCommsReply(
                _("Wait what?!.."), 
                function()
                    setCommsMessage(_("<Channel closed>"))
                end
            )
        end
    )
    addCommsReply(
        _("We don't talk with Kraylors."),
        function()
            ambushState = ambushStateAllOutAttack
            setCommsMessage(_("Glory to raugharR' Clan! We crush maggots!"))
        end
    )
end

local function kralienFiendComms_2()
    setCommsMessage(_("Friends coming. I call you back. Await."))
end

local function kralienFiendComms_3()
    setCommsMessage(_("We here to claim a prize. Give us freighter. You no need it anyways."))
    addCommsReply(
        _("The freighter is under Human Navy protection."),
        function()
            setCommsMessage(_("Ha! I only see a puny frigate, with scared little humies on board. Haha!"))
            addCommsReply(
                _("We will call for backup and they will crush you."),
                function()
                    setCommsMessage(_("Hahaha! Puny humans think we will wait so long time."))
                    addCommsReply(
                        _("On second thought, let's talk this through.."),
                        kralienFiendComms_3    
                    )
                    addCommsReply(
                        _("That's it. You're going down!"),
                        function()
                            setCommsMessage(_("Glory to raugharR' Clan! We crush maggots!"))
                            ambushState = ambushStateAllOutAttack
                        end
                    )
                end       
            )
            addCommsReply(
                _("Human Navy is the only legitimate authority in this system."),
                function()
                    setCommsMessage(_("You funny guy. I like! But no time for jokes!"))
                    addCommsReply(
                        _("<back>"),
                        kralienFiendComms_3
                    )
                end       
            )
            addCommsReply(
                _("It's not about the size - it's about technique."),
                function()
                    setCommsMessage(_("Haha! This what my father say! Mother not happy! But serious now!"))
                    addCommsReply(
                        _("<back>"),
                        kralienFiendComms_3
                    )
                end       
            )
            addCommsReply(
                _("Maybe we're not strong, but we're agile."),
                function()
                    setCommsMessage(_("True that. Know what? Give me your Combat Maneuver Drive, we go away."))
                    addCommsReply(
                        _("OK <give Combat Maneuver Drive>"),
                        function()
                            setCommsMessage(_("Good human. Good bye."))
                            comms_source:setCanCombatManeuver(false)
                            comms_source:addReputationPoints(50)
                            ambushState = ambushStateResolved
                        end
                    )
                    addCommsReply(
                        _("I don't think so."),
                        function()
                            setCommsMessage(_("Maybe you rethink offer later."))
                            addCommsReply(
                                _("<back>"),
                                kralienFiendComms_3
                            )
                        end
                    )
                end
            )
        end
    )
    addCommsReply(
        _("Small fleet against a single frigate. raugharR' clan must be weak."),
        function()
            setCommsMessage(_("Argh! raugharR' Clan is the Greatest! My father is Raghran raugharR', Scourrge of the weak, whose father is Gar Raughar, drinker of blood!!!"))
            addCommsReply(
                _("You are correct, we apologize."),
                kralienFiendComms_3
            )
            addCommsReply(
                _("Prove it! We challenge you to a duel."),
                function()
                    setCommsMessage(_("Glory to raugharR' Clan! Escort ships, do not interfere!"))
                    ambushState = ambushStateDuel
                end
            )
        end
    )
    addCommsReply(
        _("Never!"),
        function()
            ambushState = ambushStateAllOutAttack
            setCommsMessage(_("Glory to raugharR' Clan! We crush these maggots!"))
        end
    )
    addCommsReply(
        _("[NOT IMPLEMENTED YET] Sure, take him."),
        kralienFiendComms_3
    )
end

local function kralienFiendComms()
    kralienFiendCommsMissionSpecific()
end


function initializeKraylor()

    southFleet = {
        state = fleetStateDormant
    }
    northFleet = {
        state = fleetStateDormant
    }

    southStation = SpaceStation():setTemplate("Small Station"):setFaction("Kraylor"):setCallSign("Duj ghob"):setPosition(81329, 160168)
    Nebula():setPosition(81335, 160093)
    CpuShip():setFaction("Kraylor"):setTemplate("Strikeship"):setCallSign(string.format("huB'1", i)):setPosition(81335, 160093):orderDefendTarget(southStation)
    CpuShip():setFaction("Kraylor"):setTemplate("Strikeship"):setCallSign(string.format("huB'2", i)):setPosition(81335, 160093):orderDefendTarget(southStation)

    southEastStation = SpaceStation():setTemplate("Medium Station"):setFaction("Kraylor"):setCallSign("Humbaba'Daq"):setPosition(178666, 150612)
    Nebula():setPosition(178492, 150702)


    northEastStation = SpaceStation():setTemplate("Small Station"):setFaction("Kraylor"):setCallSign("tengchaH"):setPosition(173448, 69329)
    Nebula():setPosition(174956, 70516)

    kralienFiend = CpuShip():setFaction("Kraylor"):setTemplate("Fiend G6"):setCallSign("tlhaQ'"):setPosition(173986, 69774)
        :orderDefendTarget(northEastStation):setWeaponStorage("Homing", 4):setHeading(200.0):setCommsFunction(kralienFiendComms)

    kralienFiend.startX, kralienFiend.startY = kralienFiend:getPosition()
    kralienFiend.escorts = {}
    ambushState = ambushStateLieInWait
    
    local fx, fy = northEastStation:getPosition()
    ElectricExplosionEffect():setPosition(fx, fy):setSize(600):setOnRadar(true)

    local numFighters = 6
    local angleSeparation = 300.0 / (numFighters + 1)
    for i=1, numFighters do
        local dx, dy = vectorFromAngle(30.0 + i * angleSeparation, 1500)
        escortShip = CpuShip():setFaction("Kraylor"):setTemplate("Strikeship"):setCallSign(string.format("nom'%i", i)):setPosition(fx + dx, fy + dy)
        escortShip:setCommsFunction(nil):orderDefendTarget(northEastStation)
        escortShip:setRotation(kralienFiend:getRotation())
        escortShip.angleSeparation = angleSeparation
        ElectricExplosionEffect():setPosition(fx + dx, fy + dy):setSize(300):setOnRadar(true)
        table.insert(kralienFiend.escorts, escortShip)
    end
end

function ambushUpdate(delta)
    for i=1, #kralienFiend.escorts do
        if isShipPerfectlyFine(kralienFiend.escorts[i]) == false then
            ambushState = ambushStateAllOutAttack
        end
    end

    if not ambushState == ambushStateDuel and isShipPerfectlyFine(kralienFiend) == false then
        ambushState = ambushStateAllOutAttack
    end

    if ambushState == ambushStateLieInWait then
        if distance(hfFreighter, kralienFiend) > 7000 then
            kralienFiend:setWarpDrive(true)
        else 
            kralienFiend:setWarpDrive(false)
        end
        if distance(hfFreighter.initialX, hfFreighter.initialY, hfFreighter) > 2000 then
            local sent = kralienFiend:sendCommsMessage(
                getPlayerShip(-1),
                _("Human frigate!.. This captain Roghar Raughar, Kraylor vessel thlaQ'. Do not fire, we talk. I come to freighter.")
            )
            if sent then
                ambushState = ambushStateAskCeaseFire
                kralienFiendCommsMissionSpecific = kralienFiendComms_1
                hfFreighterCommsMissionSpecific = hfFreighterComms_m1_3_a_1
            end
        end
    end

    if ambushState == ambushStateAskCeaseFire then
        local dist = distance(kralienFiend, hfFreighter)
        if dist > 1100 then
            kralienFiend:orderFlyTowardsBlind(hfFreighter:getPosition())
        else 
            hfFreighter:orderIdle()
            kralienFiend:orderFlyFormation(hfFreighter, -1000, -1000)
        end
    end

    if ambushState == ambushStateCeaseFire or ambushState == ambushStateNegotiating then
        kralienFiend:setWarpDrive(true)
        hfFreighter:orderIdle()

        if ambushState ~= ambushStateNegotiating then
            kralienFiendCommsMissionSpecific = kralienFiendComms_2
        end

        for i=1, #kralienFiend.escorts do
            if kralienFiend.escorts[i]:isValid() then
                local distPlayerFreighter = distance(hfFreighter, getPlayerShip(-1))
                local tgt = nil
                if distPlayerFreighter < 5000 then
                    if math.fmod(i, 2) == 0 then
                        tgt = hfFreighter
                    else
                        tgt = getPlayerShip(-1)
                    end
                else 
                    tgt = hfFreighter
                end

                local tx, ty = tgt:getPosition()
                local dx, dy = vectorFromAngle(tgt:getRotation() + i * kralienFiend.escorts[i].angleSeparation, 1500)
                local dist = distance(kralienFiend.escorts[i], tx, ty)

                if dist > 2000  then
                    kralienFiend.escorts[i]:orderFlyTowardsBlind(tx + dx, ty + dy)
                else
                    local dx, dy = vectorFromAngle(i * kralienFiend.escorts[i].angleSeparation, 1500)
                    kralienFiend.escorts[i]:orderFlyFormation(tgt, dx, dy)

                    if ambushState ~= ambushStateNegotiating then
                        local sent = kralienFiend:sendCommsMessage(
                            getPlayerShip(-1),
                            _("Here Roghar raugharR' from thlaQ'. Friends are here. Talk now.")
                        )
                        if sent then
                            ambushState = ambushStateNegotiating
                            kralienFiendCommsMissionSpecific = kralienFiendComms_3
                        end
                    end
                end
            end
        end
    end

    if ambushState == ambushStateAllOutAttack then
        kralienFiendCommsMissionSpecific = nil
        kralienFiend:orderAttack(getPlayerShip(-1))

        local anyEscortAlive = false
        for i=1, #kralienFiend.escorts do
            if kralienFiend.escorts[i]:isValid() then
                kralienFiend.escorts[i]:orderDefendTarget(kralienFiend)
                anyEscortAlive = true
            else 
            end
        end

        if not kralienFiend:isValid() and not anyEscortAlive then
            ambushState = ambushStateResolved
        end
    end

    if ambushState == ambushStateDuel then
        kralienFiendCommsMissionSpecific = nil
        kralienFiend:orderAttack(getPlayerShip(-1))
        if kralienFiend:isValid() then
            for i=1, #kralienFiend.escorts do
                if kralienFiend.escorts[i]:isValid() then
                    local dx, dy = vectorFromAngle(i * kralienFiend.escorts[i].angleSeparation, 1500)
                    kralienFiend.escorts[i]:orderFlyFormation(hfFreighter, dx, dy)
                end
            end
        else 
            ambushState = ambushStateResolved
        end
    end

    if ambushState == ambushStateResolved then
        getPlayerShip(-1):addReputationPoints(100)

        for i=1, #kralienFiend.escorts do
            if kralienFiend.escorts[i]:isValid() then
                kralienFiend.escorts[i]:orderDefendTarget(northEastStation)
            end
        end

        if kralienFiend:isValid() then
            kralienFiend:orderDefendTarget(northEastStation)
            kralienFiend:setCommsFunction(nil)
        else
            local anyHailed = false
            for i=1, #kralienFiend.escorts do
                if kralienFiend.escorts[i]:isValid() then
                    if anyHailed == false then
                        kralienFiend.escorts[i]:sendCommsMessage(
                            getPlayerShip(-1),
                            _(kralienFiend.escorts[i]:getCallSign() .. " to Kraylor in area. Boss is dead. I take command now. " ..
                                "I order go back and drink wine! Damn these humies! Oops they hear this. Stupid radio.")
                        )
                        getPlayerShip(-1):addReputationPoints(50)
                    end
                end
            end
        end

        kralienFiendCommsMissionSpecific = nil
        ambushState = ambushStateBackToNormal
        hfFreighter.hailAfter = getScenarioTime() + 15
    end

    if ambushState == ambushStateBackToNormal then
        if hfFreighter.gotoMiners and getScenarioTime() > hfFreighter.hailAfter then
            hfFreighter.hailAfter = getScenarioTime() + 5
            hfFreighter:orderDock(minerHab)
            local sent = hfFreighter:sendCommsMessage(
                getPlayerShip(-1),
                _("That was interesting. Anyhow... we can take it from here. You should go back now. Yes?")
            )
            if sent then
                hfFreighterCommsMissionSpecific = hfFreighterComms_m1_3_a
                ambushState = ambushStateDone
            end    
        end
    end

end

local function kraylorFleetUpdate(delta, fleet)

    if fleet.state == fleetStateDormant then
        return
    end

    if fleet.state == fleetStateRallyStationDestroyed then
        return
    end

    if not fleet.rallyStation:isValid() then
        print("[Kraylor] Rally station of fleet " .. fleet.callsign .. " was destroyed, won't respawn anymore.")
        fleet.state = fleetStateRallyStationDestroyed
    end

    if fleet.state == fleetStateAwaitingRespawn and getScenarioTime() > fleet.respawnAt then
        print("[Kraylor] Respawning fleet " .. fleet.callsign)

        --- spawn a new fleet
        local shipType = ""
        local shipCount = 0

        local fleetType = irandom(1, 3)
        if fleetType == 1 then
            shipType = "Strikeship"
            shipCount = irandom(3, 5)
        elseif fleetType == 2 then
            shipType = "Stalker Q5"
            shipCount = irandom(2, 3)
        else
            shipType = "Fiend G4"
            shipCount = irandom(1, 2)
        end

        for i = 1, shipCount do
            local sx, sy = southEastStation:getPosition()
            ship = CpuShip():setFaction("Kraylor"):setTemplate(shipType):setCallSign(string.format("%s'%d", fleet.callsign, fleet.lastShipIdx + i))
            ship:setPosition(sx - 500 - i * 100, sy - 500 - i * 100):setHeading(300)

            ship:orderDefendTarget(fleet.rallyStation)
            table.insert(fleet.ships, ship)
        end
        fleet.lastShipIdx = fleet.lastShipIdx + shipCount

        
        fleet.state = fleetStateRallying
        print("[Kraylor] Rallying fleet " .. fleet.callsign .. " to " .. fleet.rallyStation:getCallSign())
    end

    if fleet.state == fleetStateRallying then
        local rallied = true
        for i=1, #fleet.ships do
            if distance(fleet.ships[i], fleet.rallyStation) > 4000 then
                rallied = false
            end
        end

        if rallied then
            print("[Kraylor] Ordering " .. fleet.callsign .. " to attack")

            fleet.state = fleetStateAttacking
            for i=1, #fleet.ships do
                if fleet.ships[i]:isValid() then
                    fleet.ships[i]:orderDefendLocation(fleet.attackX, fleet.attackY)
                end
            end
        end
    end

    if fleet.state == fleetStateAttacking or fleet.state == fleetStateRallying then
        local anyAlive = false
        for i = 1, #fleet.ships do
            if fleet.ships[i]:isValid() then
                anyAlive = true
            end
        end
    
        if not anyAlive then
            fleet.ships = {}
            fleet.state = fleetStateAwaitingRespawn
            fleet.respawnAt = getScenarioTime() + irandom(60, 180)
            print("[Kraylor] Fleet " .. fleet.callsign .. " destroyed, will respawn at: ", fleet.respawnAt)
        end
    end

end

function activateKraylorAttacks()
    print("[Kraylor] Initializing fleets")
    southFleet = {
        respawnAt = getScenarioTime() + 0,
        state = fleetStateAwaitingRespawn,
        callsign = "watlh",
        rallyStation = southStation,
        lastShipIdx = 0,
        attackX = -48191,
        attackY = 83781,
        ships = {}
    }
    northFleet = {
        respawnAt = getScenarioTime() + 180,
        state = fleetStateAwaitingRespawn,
        callsign = "\'oy\'",
        rallyStation = northEastStation,
        lastShipIdx = 0,
        attackX = 94698,
        attackY = -63108,
        ships = {}
    }

end

function kraylorSkirmishesUpdate(delta)
    kraylorFleetUpdate(delta, southFleet)
    kraylorFleetUpdate(delta, northFleet)
end
