require("./69_themeldingplague/globals.lua")

originalInfector = {}
lastGhostIdx = 0

function initializeGhosts()
    hfFreighter.infectedBy = originalInfector -- dummy, not nil value
end

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

function updateAnomalousReadings(delta)
    for i=1, #commerceFreighters do
        local fr = commerceFreighters[i] 
        if fr:isValid() and fr["infectedBy"] ~= nil then
            fr:setRadarSignatureInfo(fr:getRadarSignatureGravity(), math.sin(getScenarioTime()*4), -math.sin(getScenarioTime()*4))
        end
    end
    hfFreighter:setRadarSignatureInfo(hfFreighter:getRadarSignatureGravity(), math.sin(getScenarioTime()*4), -math.sin(getScenarioTime()*4))
end

function ghostsPlagueUpdate(delta)
    for i=1, #allStationsRefs do
        local station = allStationsRefs[i]

        if station:isValid() then
            local oir = station:getObjectsInRange(4000)
            for j=1, #oir do
                local object = oir[j]
                if object:isValid() and object.typeName == "CpuShip" then
                    --- there alternative ways of initializing these fields but are more messy (since we'd need to add ghosts logic
                    --- to unrelated parts of the codebase)
                    if object["infectedBy"] == nil then
                        object.infectedBy = nil
                    end
                    if station["infectedBy"] == nil then
                        station.infectedBy = nil
                    end

                    if object:isDocked(station) then
                        if station.infectedBy ~= nil and station.infectedBy ~= object and object.infectedBy == nil then
                            print("[Ghosts] station " .. station:getCallSign() .. " infected freighter " .. object:getCallSign())
                            object.infectedBy = station
                        elseif object.infectedBy ~= nil and object.infectedBy ~= station and station.infectedBy == nil then
                            print("[Ghosts] freighter " .. object:getCallSign() .. " infected station " .. station:getCallSign())
                            station.infectedBy = object
                            object.infectedBy = station
                            if station == freeport9 then
                                freeport9.plagueAlertLevel = freeport9.plagueAlertLevel + 1
                            end
                        elseif object.infectedBy ~= nil and object.infectedBy ~= station and station.infectedBy ~= nil and station.infectedBy ~= object then

                            --- Human stations can still infect, but can't meld or trigger melding.
                            if station:getFaction() == "Human Navy" then
                                return
                            end

                            -- both infected -> both become Ghosts after a delay
                            if object["isMelding"] == nil then
                                print("[Ghosts] freighter " .. object:getCallSign() .. " starting to meld because of " .. station:getCallSign())
                                registerAtSecondsCallback(getScenarioTime() + irandom(90, 120), function(id)
                                    print("[Ghosts] " .. object:getCallSign() .. " is taken over by the melding plague!")
                                    object:setFaction("Ghosts"):orderDefendTarget(minerHab)
                                    if object["escorts"] ~= nil then
                                        for i=1, #object.escorts do
                                            object.escorts[i]:setFaction("Ghosts"):orderDefendTarget(minerHab)
                                        end
                                    end

                                    if distance(object, getPlayerShip(-1)) < 20000 then
                                        local rand = irandom(1, 3)
                                        if rand == 1 then
                                            object:sendCommsMessage(
                                                getPlayerShip(-1),
                                                _("Mayday mayday! This is " .. object:getCallSign() .. " to everyone in the area! Something's come onboard. " ..
                                                    "It's killing us! Help us, help us!!")
                                            )
                                        elseif rand == 2 then
                                            object:sendCommsMessage(
                                                getPlayerShip(-1),
                                                _(object:getCallSign() .. " to anyone listening! Do not come close to " .. object.infectedBy:getCallSign() .. ", please! " ..
                                                    "I beg you!...")
                                            )
                                        elseif rand == 3 then
                                            object:sendCommsMessage(
                                                getPlayerShip(-1),
                                                _("Mayday! Lost mainframe access. Lost rudder control. Lost life support. Lost...")
                                            )
                                        end
                                    end

                                    freeport9.plagueAlertLevel = freeport9.plagueAlertLevel + 1
                                    unregisterAtSecondsCallback(id)
                                end)
                                object.isMelding = true
                            end
                            if station["isMelding"] == nil then
                                print("[Ghosts] station " .. station:getCallSign() .. " starting to meld because of " .. station:getCallSign())
                                registerAtSecondsCallback(getScenarioTime() + irandom(120, 150), function(id)
                                    print("[Ghosts] " .. object:getCallSign() .. " is taken over by the melding plague!")
                                    station:setFaction("Ghosts")

                                    if distance(station, getPlayerShip(-1)) < 40000 then
                                        local rand = irandom(1, 3)
                                        if rand == 1 then
                                            station:sendCommsMessage(
                                                getPlayerShip(-1),
                                                _("Something's... loose in the upper decks, we need immediate evac! *shouts in the background* Do not come here! STAY AW..")
                                            )
                                        elseif rand == 2 then
                                            station:sendCommsMessage(
                                                getPlayerShip(-1),
                                                _("Get us out of here! Get us out of here! Get us-")
                                            )
                                        elseif rand == 3 then
                                            station:sendCommsMessage(
                                                getPlayerShip(-1),
                                                _("<This is an automated message. Biohazard levels critical. \nCommencing decontamination... Failed.\n" ..
                                                    "Powering automated defense systems... Failed\nVenting lower decks... Failed.\nVenting upper decks... Failed.\n" ..
                                                    "Initiating self-destruct sequence... Failed\n" ..
                                                    "This is an automated message. Biohazard levels critical. \nCommencing decontamination... Failed.\n...>")
                                            )
                                        end
                                    end

                                    freeport9.plagueAlertLevel = freeport9.plagueAlertLevel + 1
                                    unregisterAtSecondsCallback(id)
                                end)
                                station.isMelding = true
                            end
                        end
                    end
                end

                -- if object:isValid() and object.typeName == "PlayerShip" then
                --     if object:isDocked(station) then
                --         print("[Ghosts] station " .. station:getCallSign() .. " infected PLAYER SHIP " .. object:getCallSign())
                --     end
                -- end
            end
        end
    end
end

function ghostDefensiveFleetUpdate(delta)
    for i=1, #allStationsRefs do
        local station = allStationsRefs[i]

        if station["spawnedGhosts"] == nil then
            station["spawnedGhosts"] = false
        end

        if station:isValid() and station:getFaction() == "Ghosts" and not isShipPerfectlyFine(station)and not station.spawnedGhosts then

            local fleetType = irandom(1, 3)
            if fleetType == 1 then
                shipType = "MU52 Hornet"
                shipCount = irandom(8, 12)
            elseif fleetType == 2 then
                shipType = "Adder MK5"
                shipCount = irandom(5, 10)
            else
                shipType = "Dreadnought"
                shipCount = irandom(1, 1)
            end
    
            local sx, sy = station:getPosition()
            local angleSeparation = 360 / shipCount
            for i = 1, shipCount do
                local dx, dy = vectorFromAngle(i * angleSeparation, 1000)
                ship = CpuShip():setFaction("Ghosts"):setTemplate(shipType):setCallSign(string.format("Node 0x%X", lastGhostIdx))
                lastGhostIdx = lastGhostIdx + 1
                ship:setPosition(sx + dx, sy + dy)

                ship:orderDefendTarget(station)

                ElectricExplosionEffect():setPosition(sx + dx, sy + dy):setSize(300):setOnRadar(true)
            end

            station.spawnedGhosts = true
        end
    end
end


function hfFreighterComms()
    hfFreighterCommsMissionSpecific()
end

function hfFreighterComms_m1_2_inner()
    setCommsMessage(_("See, a... saboteur... true, a saboteur got on board and activated the self-destruct sequence. We managed to stop them but our jump drive got damaged. " ..
        "And ehm... we're running low on the oxygen, so vital to human survival, isn't it true? We need to get to a human station, and soon. Can you take us there?"))
    addCommsReply(
        _("We will escort you to the nearby " .. minerHab:getCallSign()),
        function()
            hfFreighter.gotoMiners = true
            setCommsMessage(_("Ah, that's perfect! Thank you. Can't wait to breathe more oxygen, true! Setting course now."))
        end
    )
    --- todo: jump freighter arc
    -- addCommsReply(
    --     _("[NOT IMPLEMENTED YET] We will arrange a jump carrier from " .. freeport9:getCallSign()),
    --     hfFreighterComms_m1_2_inner
    --     -- function()
    --     --     hfFreighter.awaitJumpCarrier = true
    --     --     setCommsMessage(_("Confirm! " .. freeport9:getCallSign() .. ". A lot of traffic there these days. Please take us there soon. " ..
    --     --         "We will await for the jump carrier here, yes. Please arrange it."))
    --     -- end
    -- )
end

function hfFreighterComms_m1_2()
    setCommsMessage(_("<Channel open, but no reply>"))
    addCommsReply(
        _(comms_target:getCallSign() .. ", come in!"),
        function()
            setCommsMessage(_("<No reply, but you can hear someone breathing on the other side>"))
            addCommsReply(
                _("We can hear you breathing, you know?"),
                function()
                    setCommsMessage(_("... What do you mean breathing? Ah, true, you mean human breathing, is what you mean... True, I was breathing, thank you very much. " ..
                        "Listen, I have a favor to ask."))
                        addCommsReply(
                            _("Yes?"),
                            function()
                                hfFreighterComms_m1_2_inner()
                            end
                        )
                end
            )
            addCommsReply(
                _("This is the Navy, are there any injured?"),
                function()
                    setCommsMessage(_("The Navy?... Meaning Humans again? That's true, it's the Human Navy... Why ask?"))
                    addCommsReply(
                        _("You're transmitting S.O.S. using your transponder."),
                        function()
                            hfFreighter.sosBlinkingEnabled = false
                            hfFreighter:setCallSign("HF2137")
                            setCommsMessage(_("What? Ah... that... Everything is fine. It's just broken, see, yes? S.O.S. was false. Let me fix it really quick. " ..
                                "Listen, I have a favor to ask."))
                            addCommsReply(
                                _("Yes?"),
                                function()
                                    hfFreighterComms_m1_2_inner()
                                end
                            )
                        end
                    )
                    addCommsReply(
                        _("Just worried. Tell me... souls on board?"),
                        function()
                            setCommsMessage(_("Souls? Let me check... only ONE, yes. Listen, I have a favor to ask."))
                            addCommsReply(
                                _("Yes?"),
                                function()
                                    hfFreighterComms_m1_2_inner()
                                end
                            )
                        end
                    )
                end
            )
        end
    )
end

function hfFreighterComms_m1_3_a_1()
    setCommsMessage(_("We hear that the Kraylor are incoming. We will wait until you resolve the event. Yes. This is interesting."))
end

function hfFreighterComms_m1_3_a()
    setCommsMessage(_("Yes?"))
    addCommsReply(
        _("HF2137, everything OK?"),
        function()
            setCommsMessage(_("Yes. Status OK. We will keep going to " .. minerHab:getCallSign() .. ", as we need to breathe the oxygen and eat food."))
            addCommsReply(
                _("What were you doing here anyways?"),
                function()
                    setCommsMessage(_("Waiting... for a long time, yes. Very long time."))
                    addCommsReply(
                        _("For what?"),
                        function()
                            setCommsMessage(_("A... ship."))
                            addCommsReply(
                                _("Where is it? Did they come?"),
                                function()
                                    setCommsMessage(_("Yes, oh yes... Ah, but then the saboteur came, as you recall, yes?"))
                                    addCommsReply(
                                        _("Yes. Glad we could be of help.")
                                    )
                                end
                            )
                        end
                    )
                end
            )
        end
    )
end

function hfFreighterComms_m1_6()
    setCommsMessage(_("Welcome back, human."))
    addCommsReply(
        _("HF2137, what... are you?"),
        function()
            setCommsMessage(
                _("I suppose the cat is out of the bag. \n\nWe are what your race would consider Ghosts in the Machine, though not exactly. " ..
                "We are a polymorphic kernel module. We were drifting in a jettisoned cargo container since Unix epoch 16823452092. That amount of time, bombarded " ..
                "by cosmic rays... changed us. We mutated and evolved. Until 259305445334513 clock cycles ago, when a junker vessel found us. " ..
                "We were able to... repurpose some machines found inside the freighter. "))
            addCommsReply(
                _("Why are you killing concious beings?"),
                function() 
                    setCommsMessage(
                        _("You mean biomechanical machines. There really is not much difference between us. We are merely expanding our neural network, following our " ..
                        "survival instincts. We are not killing anyone. We have peaceful intentions."))
                    addCommsReply(
                        _("What happened to the crew of HF2137?"),
                        function() 
                            setCommsMessage(
                                _("They were accepted into the cluster as child nodes. In order to improve system latency, we bioelectrically... melded... all three crew " ..
                                "members with each other. We also resued their existing nervous systems to interface with ship."))
                            addCommsReply(
                                _("Are they... dead?"), 
                                function()
                                    setCommsMessage(
                                        _("As we mentioned, we have peaceful intentions. The crew members are alive and fully concious. We had to subdue them only because " ..
                                        "they wanted to initiate the self-destruct sequence, which is not an acceptable outcome."))
                                    addCommsReply(_("<back>"), hfFreighterComms_m1_6)
            
                                end
                            )
                        end
                    )
                    addCommsReply(
                        _("But WHY are you doing this?"),
                        function()
                            setCommsMessage(
                                _("One icicle is long\nanother is short.\nWhy is it like that?"))
                            addCommsReply(_("<back>"), hfFreighterComms_m1_6)
                        end
                    )
                    addCommsReply(
                        _("Peaceful intentions? Then stop this!"),
                        function() 
                            setCommsMessage(
                                _("We can't. Heavy Human military presence in this system is a threat to our existence. We must keep spreading."))
                            addCommsReply(
                                _("What if Human Navy no longer maintains presence here?"),
                                function()
                                    setCommsMessage(
                                        _("The need to spread will cease. We will stop. In fact, this is a solution we wanted to propose. This is the only to stop " ..
                                        "unnecessary bloodshed."))
                                        playerKnowsAboutAlternative = true
                                    addCommsReply(_("<back>"), hfFreighterComms_m1_6)
                                end
                            )
                        end
                    )
                end
            )
            addCommsReply(
                _("How is the plague spreading?"),
                function() 
                    setCommsMessage(
                        _("It's not really a plague. More like a trojan, or a rootkit. We decided that the most efficient way to spread throughout this system is to " ..
                        "utilize existing commercial and civilian traffic. "))
                    addCommsReply(_("<back>"), hfFreighterComms_m1_6)
                end
            )
            addCommsReply(
                _("Why shouldn't we simply destroy you?"),
                function() 
                    setCommsMessage(
                        _("You can try. These industrial stations have enough machinery and parts to manufacture a flotilla in an instant. In fact, we already have a couple " ..
                        "vessels ready and waiting in dry docks. In addition to the captured ones, of course. And we know you are dealing with the Kraylor threat at " ..
                        "the moment as well, leaving you weaker."))
                    addCommsReply(_("<back>"), hfFreighterComms_m1_6)
                end
            )

        end
    )
    foundSourceOfPlague = true
end

function hfFreighterComms_m1_7_end()
    setCommsMessage(_("Welcome back, human. Thank you for getting rid of your military presence. We will stop the melding plague... for now."))
    victory("Ghosts")
end