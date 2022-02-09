require("./69_freeport9_mayhem/globals.lua")


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



function freeport9Comms()
    freeport9CommsMissionSpecific()
end

function freeport9Comms_m1_1()
    setCommsMessage(_("Good day. " .. comms_target:getCallSign() .. " here. What can I do for you?"))
    addCommsReply(
        _("Patch me through to Human Navy HQ."),
        function()
            setCommsMessage(_("CIC, Navy HQ, " .. comms_target:getCallSign() .. " here. Come in, " .. comms_source:getCallSign() .. "."))
            addCommsReply(
                _(comms_source:getCallSign() .. " to HQ, what are our orders, sir?"),
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
    )
end

function freeport9Comms_m1_2()
    setCommsMessage(_("Good day. " .. comms_target:getCallSign() .. " here. What can I do for you?"))
    addCommsReply(
        _("Patch me through to Human Navy HQ."),
        function()
            setCommsMessage(_("CIC, Navy HQ, " .. comms_target:getCallSign() .. " here. Come in, " .. comms_source:getCallSign() .. "."))
            addCommsReply(
                _(comms_source:getCallSign() .. " reporting in. Orders, sir?"),
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
    )
end

function freeport9Comms_m1_3_a()
    setCommsMessage(_("Good day. " .. comms_target:getCallSign() .. " here. What can I do for you?"))
    addCommsReply(
        _("Patch me through to Human Navy HQ."),
        function()
            setCommsMessage(_("CIC, Navy HQ, " .. comms_target:getCallSign() .. " here. Come in, " .. comms_source:getCallSign() .. "."))
            addCommsReply(
                _("<give sitrep report>. What are our orders, sir?"),
                function()
                    setCommsMessage(_("Escort " .. hfFreighter:getCallSign() .. " to ." .. minerHab:getCallSign() .. " in " .. 
                        minerHab:getSectorName() .. ". Make sure it's safe and sound."))
                end
            )
        end
    )
end

function freeport9Comms_m1_4()
    setCommsMessage(_("Good day. " .. comms_target:getCallSign() .. " here. What can I do for you?"))
    addCommsReply(
        _("Patch me through to Human Navy HQ."),
        function()
            setCommsMessage(_("CIC, Navy HQ, " .. comms_target:getCallSign() .. " here. Come in, " .. comms_source:getCallSign() .. "."))
            addCommsReply(
                _("<give sitrep report>. What should we do, commander?"),
                function()
                    setCommsMessage(_("Your report is very concerning. It seems to confirm our intelligence reports about increased Kraylor activity in this system. " ..
                        "You are to conduct combat patrol along main trade routes between " .. southExitWh:getCallSign() .. " and " .. northExitWh():getCallSign() .. " wormholes. " .. 
                        "Destroy any encountered hostile Kraylor forces. Piracy won't be tolerated. We will reach out to you once we have more intel. "))
                end
            )
        end
    )
end

function freeport9Comms_m1_5()
    setCommsMessage(_(comms_target:getCallSign() .. " here. Be informed that both departure and arrival times are being delayed. What can I do for you?"))
    addCommsReply(
        _("Patch me through to Human Navy HQ."),
        function()
            setCommsMessage(_("CIC, Navy HQ, " .. comms_target:getCallSign() .. " here. Come in, " .. comms_source:getCallSign() .. "."))
            addCommsReply(
                _("Sir, what's going on?"),
                function()
                    setCommsMessage(_("We have a biohazard situation on lower decks. Some sort of alien disease. Thirteen of our men are incapacitated in medbay. " ..
                        "The Chief Medical Officer says that it's nothing she's ever seen before. We've ordered some additional lab equipment but it's stuck at " ..
                        borderStation:getCallSign() .. ". There's no time to bring all of it here. She's already been transfered onto your ship. Get her to " ..
                        borderStation:getCallSign() .. " ASAP. This is of utmost priority. We can't risk an outbreak at such an important trade route. Do not dock " ..
                        "at any other station, especially the ones without decontamination units."))
                end
            )
        end
    )
end

function minerHabComms_m1_3_a()
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

function minerHabComms_m1_2()
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

