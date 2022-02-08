require("./69_mymission/globals.lua")


function stroke1Comms()
    setCommsMessage(_("Eyes open, " .. comms_source:getCallSign() .. ". I don't want to end up dead because you were daydreaming. " .. comms_target:getCallSign() .. " out."))
    addCommsReply(_("Aye, sir."))
    comms_target.talked = true
end

function stroke2Comms()
    setCommsMessage(_(comms_target:getCallSign() .. "... can you speak up?"))
    if comms_target.talked then
        addCommsReply(
            _("Status?"),
            function()
                setCommsMessage(_("It's just perfect. " .. comms_target:getCallSign() .. " out"))
            end
        )
    else
        addCommsReply(
            _("Status?"),
            function()
                setCommsMessage(_("Man, I'm tired of this backwater station. Patrolling this place makes me wish I never applied to the Navy. " ..
                    "No action and nothing but grumpy gas miners around."))
                addCommsReply(
                    _("Yeah, same."),
                    function()
                        setCommsMessage(_("Fancy some 'debriefing fluid' once our shift is done?"))
                        addCommsReply(
                            _("I'm glad you asked. I'm longing for a nice, cold 'Sidewinder Fang'."),
                            function()
                                setCommsMessage(_("Hmpf. You know they only got 'Liberty Ale' here, friend. Anyways, I think the boss is monitoring this frequency, " .. 
                                    "better get back on track. " .. comms_target:getCallSign() .. " out."))
                                    comms_target.likesPlayer = true
                            end
                        )
                        addCommsReply(
                            _("No thanks."),
                            function()
                                setCommsMessage(_("Suit yourself. Let's focus on the work then. " .. comms_target:getCallSign() .. " out."))
                            end
                        )
                    end
                )
                addCommsReply(
                    _(comms_target:getCallSign() .. ", please keep it professional."),
                    function()
                        setCommsMessage(_("Roger. All systems green. " .. comms_target:getCallSign() .. " out."))
                    end
                )
            end
        )
        comms_target.talked = true
    end
end

function stroke4Comms()
    setCommsMessage(_(comms_target:getCallSign() .. " here."))
    if comms_target.talked then
        addCommsReply(
            _("Status?"),
            function()
                setCommsMessage(_("Nothing to report. " .. comms_target:getCallSign() .. " out."))
            end
        )
    else 
        addCommsReply(
            _("Status?"),
            function()
                setCommsMessage(_("All systems green... except none of us has any probes left, as you know. The promised equipment didn't arrive. " ..
                    "It's like the Command forgot about us here."))
                addCommsReply(
                    _("Captured outposts are never high on priority list."),
                    function()
                        setCommsMessage(_("Why does the Navy need this base anyways?"))
                        addCommsReply(
                            _(freeport9:getCallSign() .. " is located on an important trade route."),
                            function()
                                setCommsMessage(_("Thanks for the reminder, mate. Defending rich merchants. My life has a purpose now. "
                                    .. comms_target:getCallSign() .. " out."))
                                comms_target.likesPlayer = true
                            end
                        )
                        addCommsReply(
                            _("Because the local gas mining is important to the war effort."),
                            function()
                                setCommsMessage(_("Thanks for the reminder, mate. Defending grumpy gas miners. My life has a purpose now. "
                                    .. comms_target:getCallSign() .. " out."))
                                comms_target.likesPlayer = true
                            end
                        )
                        addCommsReply(
                            _("No time to explain."),
                            function()
                                setCommsMessage(_("Affirm, we will discuss it later. " .. comms_target:getCallSign() .. " out."))
                            end
                        )
                    end
                )
                addCommsReply(
                    _("Stop complaining."),
                    function()
                        setCommsMessage(_("What else am I supposed to do? It's not like anything interesting happened in weeks..." ..
                            "Eh, let's just get back to the business. " .. comms_target:getCallSign() .. " out."))
                    end
                )
            end
        )
        comms_target.talked = true
    end
end

function minerHabComms()
    minerHabCommsMissionSpecific()
end

function randomizedHabCommsFunc()
    local rand = irandom(0, 3)
    if rand == 0 then
        return function()
            setCommsMessage(_("<Channel open, but no resopnse>"))
        end
    elseif rand == 1 then
        return function()
            setCommsMessage(_("Go away."))
        end
    elseif rand == 2 then
        return function()
            setCommsMessage(_("Yes?"))
            addCommsReply(
                _("Hello?"),
                function()
                    setCommsMessage(_("Who is this?"))
                    addCommsReply(
                        _("The Navy."),
                        function()
                            setCommsMessage(_("<Channel closed by the remote client>"))
                        end
                    )
                    addCommsReply(
                        _("Umm... it's me."),
                        function()
                            setCommsMessage(_("No, I'm not interested in my ship's extended warranty. Good bye."))
                        end
                    )
                end
            )
        end
    elseif rand == 3 then
        return function()
            setCommsMessage(_("We don't want Navy types like you in this system."))
        end
    end
end


function hfFreighterComms()
    hfFreighterCommsMissionSpecific()
end

hfFreighterComms_m1_2_inner = function()
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
        _("We will arrange a jump carrier from " .. freeport9:getCallSign()),
        function()
            hfFreighter.awaitJumpCarrier = true
            setCommsMessage(_("Confirm! " .. freeport9:getCallSign() .. ". A lot of traffic there these days. Please take us there soon. " ..
                "We will await for the jump carrier here, yes. Please arrange it."))
        end
    )
end

hfFreighterComms_m1_2 = function()
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

hfFreighterComms_m1_3_a_1 = function()
    setCommsMessage(_("We hear that the Kraylor are incoming. We will wait until you resolve the event. Yes. This is interesting."))
end

hfFreighterComms_m1_3_a = function()
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


function freeport9Comms()
    setCommsMessage(_("CIC, Navy HQ, " .. comms_target:getCallSign() .. " here. Come in, " .. comms_source:getCallSign() .. "."))
    freeport9CommsMissionSpecific()
end

freeport9Comms_m1_1 = function()
    addCommsReply(
        _("What are my orders, sir?"),
        function()
            setCommsMessage(_("Continue combat patrol around " .. freeport9:getCallSign() .. 
                ". Check in with the other ships in your formation. We might have new orders for you very soon."))
            addCommsReply(
                _("Aye, sir"),
                function()
                    setCommsMessage(_("Dismissed."))
                end
            )
        end
    )
end

function freeport9Comms_m1_2()
    addCommsReply(
        _("What are my orders, sir?"),
        function()
            setCommsMessage(_("We received reports on unusual sensor readings not too far from " .. minerHab:getCallSign() .. " in sector " .. minerHab:getSectorName() .. 
                ". Break off from formation and check it out, solo."))
            addCommsReply(
                _("Aye, sir"),
                function()
                    setCommsMessage(_("Dismissed."))
                end
            )
        end
    )
end

function freeport9Comms_m1_3_a()
    addCommsReply(
        _("<give report> What are my orders, sir?"),
        function()
            setCommsMessage(_("Escort " .. hfFreighter:getCallSign() .. " to ." .. minerHab:getCallSign() .. " in " .. 
                minerHab:getSectorName() .. ". Make sure it's safe and sound."))
        end
    )
end


minerHabComms_m1_3_a = function()
    addCommsReply(
        _("We've found a damaged freighter."),
        function()
            setCommsMessage(_("Good. And?"))
            addCommsReply(
                _("They will dock with you for emergency repairs."),
                function()
                    setCommsMessage(_("We will gladly help a fellow civilian."))
                end
            )
        end
    )
end

minerHabComms_m1_2 = function()
    setCommsMessage(_("What?"))
    addCommsReply(
        _("Anything unusual happening lately?"),
        function()
            setCommsMessage(_("Still didn't get used to Navy presence around here, does that count as unusual?"))
            addCommsReply(
                _("Anything else?"),
                function()
                    setCommsMessage(_("We detected some strange sensor readings from " .. hfFreighter:getSectorName() ..
                        ", like from a damaged ship, but it's not one of ours."))
                    addCommsReply(
                        _("Any idea what could be there?"),
                        function()
                            setCommsMessage(_("Probably some exotic species, you know, with six legs and three heads... "..
                                "I don't know, that's why we called you! Now, if you excuse me..."))
                        end
                    )
                    addCommsReply(
                        _("Thanks."),
                        function()
                            setCommsMessage(_("Hmpf."))
                        end
                    )
                end
            )
            addCommsReply(
                _("Do you have a problem with the Navy?"),
                function()
                    setCommsMessage(_("Yea, I do. You lazy bastards, with your damn beaurocracy and taxes. T'was hard making ends meet before you showed up. " ..
                        "Many of my colleagues were forced to leave or... change profession. "))
                    addCommsReply(
                        _("The Navy provides protection from aliens and pirates. You should be thankful."),
                        function()
                            setCommsMessage(_("Tsk."))
                            addCommsReply("<Back>", minerHabComms)
                        end
                    )
                    addCommsReply(
                        _("Understandable. Navy presence in this system is dubious at best."),
                        function()
                            setCommsMessage(_("Well, you and me, we agree on one thing at least."))
                            addCommsReply("<Back>", minerHabComms)
                        end
                    )
                end
            )
        end
    )
end


function randomizedBdfCommsFunc()
    local rand = irandom(0, 3)
    if rand == 0 then
        return function()
            setCommsMessage(_("This is " .. comms_target:getCallSign() .. " of the Border Defense Fleet, all systems green."))
        end
    elseif rand == 1 then
        return function()
            setCommsMessage(_(comms_target:getCallSign() .. " here. Want anything, ask my commander stationed at " .. borderStation:getCallSign() .. "."))
        end
    elseif rand == 2 then
        return function()
            setCommsMessage(_("They see me rollin'. They hatin'. Patrollin'... huh? I mean... " .. comms_target:getCallSign() .. " out."))
        end
    elseif rand == 3 then
        return function()
            setCommsMessage(_("We're stationed at " .. borderStation:getCallSign() .. ". Ask there. " .. comms_target:getCallSign() .. " over and out."))
        end
    end
end

kralienFiendComms_1 = function()
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

kralienFiendComms_2 = function()
    setCommsMessage(_("Friends coming. I call you back. Await."))
end

kralienFiendComms_3 = function()
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
            setCommsMessage(_("Glory to raugharR' Clan! We crush maggots!"))
        end
    )
end

function kralienFiendComms()
    kralienFiendCommsMissionSpecific()
end
