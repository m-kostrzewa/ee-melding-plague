require("./69_freeport9_mayhem/globals.lua")

originalInfector = {}

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
    addCommsReply(
        _("[NOT IMPLEMENTED YET] We will arrange a jump carrier from " .. freeport9:getCallSign()),
        hfFreighterComms_m1_2_inner
        -- function()
        --     hfFreighter.awaitJumpCarrier = true
        --     setCommsMessage(_("Confirm! " .. freeport9:getCallSign() .. ". A lot of traffic there these days. Please take us there soon. " ..
        --         "We will await for the jump carrier here, yes. Please arrange it."))
        -- end
    )
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
