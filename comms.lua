require("./69_mymission/globals.lua")


function stroke1Comms()
    setCommsMessage(_("Eyes open, Stroke 3. I don't want to end up dead because you were daydreaming. Stroke 1 out."))
    addCommsReply(_("Aye, sir."))
    comms_target.talked = true
end

function stroke2Comms()
    setCommsMessage(_("Stroke 2... can you speak up?"))
    if comms_target.talked then
        addCommsReply(
            _("Status?"),
            function()
                setCommsMessage(_("It's just perfect. Stroke 2 out"))
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
                                    "better get back on track. Stroke 2 out."))
                                    comms_target.likesPlayer = true
                            end
                        )
                        addCommsReply(
                            _("No thanks."),
                            function()
                                setCommsMessage(_("Suit yourself. Let's focus on the work then. Stroke 2 out."))
                            end
                        )
                    end
                )
                addCommsReply(
                    _("Stroke 2, please keep it proffessional."),
                    function()
                        setCommsMessage(_("Affirm. All systems green. Stroke 2 out."))
                    end
                )
            end
        )
        comms_target.talked = true
    end
end

function stroke4Comms()
    setCommsMessage(_("Stroke 4 here."))
    if comms_target.talked then
        addCommsReply(
            _("Status?"),
            function()
                setCommsMessage(_("Nothing to report. Stroke 4 out"))
            end
        )
    else 
        addCommsReply(
            _("Status?"),
            function()
                setCommsMessage(_("All systems green... except none of us has any probes left, as you know. The promised equipment didn't arrive. " ..
                    "It's like the Command forgot about us here."))
                addCommsReply(
                    _("Badlands outposts are never high on priority list."),
                    function()
                        setCommsMessage(_("Why does the Navy need this base anyways?"))
                        addCommsReply(
                            _("Freeport 9 is located on an important trade route."),
                            function()
                                setCommsMessage(_("Thanks for the reminder, mate. Defending rich merchants. My life has a purpose now. Stroke 4 out."))
                                comms_target.likesPlayer = true
                            end
                        )
                        addCommsReply(
                            _("Because the local gas mining is important to the war effort."),
                            function()
                                setCommsMessage(_("Thanks for the reminder, mate. Defending grumpy gas miners. My life has a purpose now. Stroke 4 out."))
                                comms_target.likesPlayer = true
                            end
                        )
                        addCommsReply(
                            _("No time."),
                            function()
                                setCommsMessage(_("Affirm, we will discuss it later. Stroke 2 out."))
                            end
                        )
                    end
                )
                addCommsReply(
                    _("Stop complaining."),
                    function()
                        setCommsMessage(_("What else am I supposed to do? It's not like anything interesting happened in weeks..." ..
                            "Eh, let's just get back to the business. Stroke 4 out."))
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

function minerHabNope1Comms() 
    setCommsMessage(_("<Channel open, but no resopnse>"))
end
function minerHabNope2Comms() 
    setCommsMessage(_("Go away."))
end
function minerHabNope3Comms() 
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


function hfFreighterComms()
    setCommsMessage(_("<Channel open, but no reply>"))
    hfFreighterCommsMissionSpecific()
end

hfFreighterComms_m1_2_inner = function()
    setCommsMessage(_("See, a... saboteur... yes, a saboteur got on board and activated the self-destruct sequence. We managed to stop them but our jump drive got damaged. " ..
        "And ehm... we're running low on the oxygen, so vital to human survival, yes. We need to get to a human station, and soon. Can you take us there?"))
    addCommsReply(
        _("We will escort you to nearby miner's habitations."),
        function()
            hfFreighter.gotoMiners = true
            setCommsMessage(_("Ah, that's perfect! Thank you. Can't wait to breathe more oxygen, yes! Setting course now."))
        end
    )
    addCommsReply(
        _("We will arrange a jump carrier from Freeport 9."),
        function()
            hfFreighter.awaitJumpCarrier = true
            setCommsMessage(_("Yes! Freeport 9. A lot of traffic there these days. Please take us there soon. We will await for the jump carrier here, yes. Please arrange it."))
        end
    )
end

hfFreighterComms_m1_2 = function()
    addCommsReply(
        _("HF2137, report in!"),
        function()
            setCommsMessage(_("<No reply, but you can hear someone breathing on the other side>"))
            addCommsReply(
                _("We can hear you breathing, you know?"),
                function()
                    setCommsMessage(_("... What do you mean breathing? Ah, yes, you mean human breathing, is what you mean... Yes, I was breathing, thank you very much. " ..
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
                    setCommsMessage(_("The Navy?... Meaning more Humans? That's right, it's the Human Navy... Why ask?"))
                    addCommsReply(
                        _("You're transmitting S.O.S. using your transponder."),
                        function()
                            hfFreighter.sosBlinkingEnabled = false
                            hfFreighter:setCallSign("HF2137")
                            setCommsMessage(_("What? Ah... that... Everything is fine. It's just broken, see, yes? Let me fix it really quick. " ..
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
                            setCommsMessage(_("Souls? Let me check... only me, yes. Listen, I have a favor to ask."))
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

function freeport9Comms()
    setCommsMessage(_("Freeport 9 here."))
    freeport9CommsMissionSpecific()
end

freeport9Comms_m1_1 = function()
    addCommsReply(
        _("What are my orders, sir?"),
        function()
            setCommsMessage(_("Continue combat patrol around Freeport 9. Check with other ships in formation. We might have new orders for you very soon."))
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
            setCommsMessage(_("We received reports on unusual sensor readings not too far from gas miners habitation modules in sector " .. minerHab:getSectorName() .. 
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
                    setCommsMessage(_("We detected faint lifeform readings from " .. hfFreighter:getSectorName() ..
                        ", but it's not one of ours."))
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
                        _("Understandable. Navy presence in this sector is dubious at best."),
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