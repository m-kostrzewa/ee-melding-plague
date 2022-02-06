require("./69_mymission/comms.lua")
require("./69_mymission/globals.lua")


function ambushInit()  
    kralienStation = SpaceStation():setTemplate("Small Station"):setFaction("Kraylor"):setCallSign("tengchaH"):setPosition(173448, 69329)
    Nebula():setPosition(174956, 70516)

    kralienFiend = CpuShip():setFaction("Kraylor"):setTemplate("Fiend G6"):setCallSign("tlhaQ'"):setPosition(173986, 69774)
        :orderDefendTarget(kralienStation):setWeaponStorage("Homing", 4):setHeading(200.0):setCommsFunction(kralienFiendComms)

    kralienFiend.startX, kralienFiend.startY = kralienFiend:getPosition()
    kralienFiend.escorts = {}
    ambushState = ambushStateLieInWait
    
    local fx, fy = kralienStation:getPosition()
    ElectricExplosionEffect():setPosition(fx, fy):setSize(600):setOnRadar(true)

    local numFighters = 6
    local angleSeparation = 300.0 / (numFighters + 1)
    for i=1, numFighters do
        local dx, dy = vectorFromAngle(30.0 + i * angleSeparation, 1500)
        escortShip = CpuShip():setFaction("Kraylor"):setTemplate("Strikeship"):setCallSign(string.format("nom'%i", i)):setPosition(fx + dx, fy + dy)
        escortShip:setCommsFunction(nil):orderDefendTarget(kralienStation)
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
                kralienFiend.escorts[i]:orderDefendTarget(kralienStation)
            end
        end

        if kralienFiend:isValid() then
            kralienFiend:orderDefendTarget(kralienStation)
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