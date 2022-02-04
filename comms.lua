require("./69_mymission/globals.lua")



function freeport9Comms()
    setCommsMessage(_("Freeport 9 here."))
    freeport9CommsMissionSpecific()
end

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
    setCommsMessage(_("What?"))
    addCommsReply(
        _("Nothing."),
        function()
            setCommsMessage(_("Aight"))
        end
    )
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

minerHabComms_m1_2 = function()
    addCommsReply(
        _("Anything unusual happening lately?"),
        function()
            setCommsMessage(_("Still didn't get used to Navy presence around here, does that count as unusual?"))
            addCommsReply(
                _("Anything else?"),
                function()
                    setCommsMessage(_("What, your science guy's asleep? We detected faint lifeform readings from the gas cloud nearby, about 20000 bearing 090, " ..
                        "but it's not one of us."))
                    addCommsReply(
                        _("Any idea what could be there?"),
                        function()
                            setCommsMessage(_("Probably some exotic species, you know, with five legs and three heads... "..
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

function randomCommerceFreighterShipCommsFunc()
    rand = irandom(0, 3)
    if rand == 0 then
        return function()
            setCommsMessage(_("This is " .. comms_target:getCallSign() .. " " .. comms_target:getFaction() .. " freighter. We're en route to " .. comms_target.ultimateDestStr .. 
                ". " .. (#comms_target.tradeRoute - comms_target.currentLeg) .. " waypoints remaining."))
        end
    elseif rand == 1 then
        return function()
            setCommsMessage(_(comms_target:getFaction() .. " transport " .. comms_target:getCallSign() .. " here. Our ultimate destination is " 
                .. comms_target.ultimateDestStr .. ". We have " .. (#comms_target.tradeRoute - comms_target.currentLeg) .. " more stops in this system."))
        end
    elseif rand == 2 then
        return function()
            setCommsMessage(_("I'm the captain of " .. comms_target:getFaction() .. " convoy " .. comms_target:getCallSign() .. ". " ..
                "We're just passing by this sector. We're on our way to " .. comms_target.ultimateDestStr .. "."))
        end
    elseif rand == 3 then
        return function()
            setCommsMessage(_("This is " .. comms_target:getCallSign() .. " heavy. We're " .. comms_target:getFaction() .. ". Want anything, speak to my boss."))
        end
    end
end

function randomCommerceEscortShipCommsFunc()
    rand = irandom(0, 3)
    if rand == 0 then
        return function()
            setCommsMessage(_("This is " .. comms_target:getCallSign() .. ". I'm escorting " .. comms_target.freighter:getCallSign() .. "."))
        end
    elseif rand == 1 then
        return function()
            setCommsMessage(_(comms_target:getCallSign() .. " here. If you want anything, talk to my boss on " .. comms_target.freighter:getCallSign() .. "."))
        end
    elseif rand == 2 then
        return function()
            setCommsMessage(_("Just a lowly escort pilot. " .. comms_target:getCallSign() .. " out."))
        end
    elseif rand == 3 then
        return function()
            setCommsMessage(_("Hello. You probably want my boss on " .. comms_target.freighter:getCallSign() .. " ."))
        end
    end
end