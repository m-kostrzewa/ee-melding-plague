require("./69_freeport9_mayhem/globals.lua")


function initializeGhosts()
    hfFreighter.infected = true
    minerHab.infected = true
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

        if station["hasDecontaminationUnit"] == nil then
            station.hasDecontaminationUnit = false
        end

        if station:isValid() and not station.hasDecontaminationUnit then
            local oir = station:getObjectsInRange(4000)
            for j=1, #oir do
                local object = oir[j]
                if object:isValid() and object.typeName == "CpuShip" then
                    --- there alternative ways of initializing these fields but are more messy (since we'd need to add ghosts logic
                    --- to unrelated parts of the codebase)
                    if object["infected"] == nil then
                        object.infected = false
                    end
                    if station["infected"] == nil then
                        station.infected = false
                    end

                    if object:isDocked(station) then
                        if station.infected and not object.infected then
                            print("[Ghosts] station " .. station:getCallSign() .. " infected freighter " .. object:getCallSign())
                            object.infected = true
                        elseif object.infected and not station.infected then
                            print("[Ghosts] freighter " .. object:getCallSign() .. " infected station " .. station:getCallSign())
                            station.infected = true
                            if station == freeport9 then
                                freeport9.plagueAlertLevel = freeport9.plagueAlertLevel + 1
                            end
                        end
                    end
                end

                if object:isValid() and object.typeName == "PlayerShip" then
                    if object:isDocked(station) then
                        print("[Ghosts] station " .. station:getCallSign() .. " infected PLAYER SHIP " .. object:getCallSign())
                    end
                end
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
