require("./69_themeldingplague/globals.lua")

dockingState = 0
local dockingStateAllowed = 1
local dockingStateNotAllowed = 2

function borderStationInit() 
    dockingState = dockingStateNotAllowed
    borderStationQuarantine = false

    borderStation = SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setCallSign("Customs"):
        setPosition(-81260, 140904):setCommsFunction(borderStationComms)

    CpuShip():setFaction("Human Navy"):setTemplate("Weapons platform"):setCallSign("BDF88"):setPosition(-80703, 141433):
        orderRoaming():setCommsFunction(randomizedBdfCommsFunc()):setScanned(true)

    local bdf01 = CpuShip():setFaction("Human Navy"):setTemplate("Dreadnought"):setCallSign("BDF01"):setPosition(-80487, 140147):
        orderDefendLocation(-80587, 140025):setCommsFunction(randomizedBdfCommsFunc()):setScanned(true)
    CpuShip():setFaction("Human Navy"):setTemplate("MU52 Hornet"):setCallSign("BDF13"):setPosition(-81986, 142951):
        orderDefendTarget(bdf01):setCommsFunction(randomizedBdfCommsFunc()):setScanned(true)
    CpuShip():setFaction("Human Navy"):setTemplate("MU52 Hornet"):setCallSign("BDF14"):setPosition(-81014, 142838):
        orderDefendTarget(bdf01):setCommsFunction(randomizedBdfCommsFunc()):setScanned(true)
    CpuShip():setFaction("Human Navy"):setTemplate("MU52 Hornet"):setCallSign("BDF15"):setPosition(-81014, 142838):
        orderDefendTarget(bdf01):setCommsFunction(randomizedBdfCommsFunc()):setScanned(true)
    CpuShip():setFaction("Human Navy"):setTemplate("MU52 Hornet"):setCallSign("BDF16"):setPosition(-81014, 142838):
        orderDefendTarget(bdf01):setCommsFunction(randomizedBdfCommsFunc()):setScanned(true)
    CpuShip():setFaction("Human Navy"):setTemplate("MU52 Hornet"):setCallSign("BDF17"):setPosition(-81014, 142838):
        orderDefendTarget(bdf01):setCommsFunction(randomizedBdfCommsFunc()):setScanned(true)
    CpuShip():setFaction("Human Navy"):setTemplate("MU52 Hornet"):setCallSign("BDF18"):setPosition(-81014, 142838):
        orderDefendTarget(bdf01):setCommsFunction(randomizedBdfCommsFunc()):setScanned(true)

    local bdf55 = CpuShip():setFaction("Human Navy"):setTemplate("Phobos M3"):setCallSign("BDF51"):setScanned(true):
        setPosition(-82288, 138520):setHeading(270):setCommsFunction(randomizedBdfCommsFunc()):orderDefendLocation(-80587, 140025)
    bdf55:setImpulseMaxSpeed(bdf55:getImpulseMaxSpeed() * 0.9)
    CpuShip():setFaction("Human Navy"):setTemplate("Phobos M3"):setCallSign("BDF52"):setScanned(true):
        setPosition(-82288, 138520):setHeading(270):setCommsFunction(randomizedBdfCommsFunc()):orderFlyFormation(bdf55, -500, 500)
    CpuShip():setFaction("Human Navy"):setTemplate("Phobos M3"):setCallSign("BDF53"):setScanned(true):
        setPosition(-82288, 138520):setHeading(270):setCommsFunction(randomizedBdfCommsFunc()):orderFlyFormation(bdf55, -500, -500)
end

function borderStationUpdate(delta) 
    if not borderStation:isValid() then
        return
    end

    --- player ship docking
    local ps = getPlayerShip(-1)
    if dockingState == dockingStateNotAllowed then
        if ps:isDocked(borderStation) then
            if not ps.paidDockingFees or not ps.hasOnShorePermit then
                ps:commandUndock()
                
                registerRetryCallback(5, function()
                    return borderStation:sendCommsMessage(
                        getPlayerShip(-1),
                        _(getPlayerShip(-1):getCallSign() .. ", docking request denied. Reason: lack of on-shore permit and/or docking fees unpaid. " ..
                            "Contact the station for more information.")
                    )
                end)
            else 
                dockingState = dockingStateAllowed
            end
        end

    end
    if dockingState == dockingStateAllowed and not ps:isDocked(borderStation) then
        --- undocked
        dockingState = dockingStateNotAllowed
        ps.paidDockingFees = false
        ps.hasOnShorePermit = false
    end

    if borderStationQuarantine then
        --- turn around infected traffic
        local oir = borderStation:getObjectsInRange(4000)
        for j=1, #oir do
            local object = oir[j]
            if object:isValid() and object.typeName == "CpuShip" and object:isDocked(borderStation) then
                --- be racist: let all human traffic through
                local faction = object:getFaction()
                if faction ~= "Human Navy" and faction ~= "CUF" and faction ~= "USN" then
                    if object["infected"] == true and not object:getFaction() then
                        if object.tradeRoute[#comms_target.tradeRoute] == southExitWh then
                            object.tradeRoute = {
                                freeport9,
                                bobsStation,
                                northExitWh
                            }
                        end
                        object.turnedAround = true
                        print("[Border] Turned around " .. object:getCallSign() .. " of faction " .. object:getFaction())
                    end
                end
            end
        end
    end
end

function borderStationCommsPermits(isHuman)
    local dockingFee = 10
    local onShorePermit = 15
    if not isHuman then
        dockingFee = 30
        onShortPermit = 50
    end
        
    addCommsReply(
        _("<3>"),
        function()
            setCommsMessage(_("Docking fees allow to dock for a duration of 1 (one) Terran hour."))
            addCommsReply(
                _("<Purchase for " .. dockingFee .. " REP>"),
                function() 
                    if not comms_source:takeReputationPoints(dockingFee) then
                        setCommsMessage(_("Insufficient funds. As a reminder, being poor is considered illegal in Human worlds."))
                        addCommsReply(_("<Back>"), borderStationCommsArrivals)
                    else 
                        setCommsMessage(_("<Docking fees paid>"))
                        comms_source.paidDockingFees = true
                    end
                end
            )
            addCommsReply(_("<Back>"), borderStationCommsArrivals)
        end
    )
    addCommsReply(
        _("<4>"),
        function()
            setCommsMessage(_("The on-shore permit is valid for the duration of a single visit."))
            addCommsReply(
                _("<Purchase for " .. onShorePermit .. " REP>"),
                function() 
                    if not comms_source:takeReputationPoints(onShorePermit) then
                        setCommsMessage(_("Insufficient funds. As a reminder, being poor is considered illegal in Human worlds."))
                        addCommsReply(_("<Back>"), borderStationCommsArrivals)
                    else 
                        setCommsMessage(_("<On-shore permit acquired>"))
                        comms_source.hasOnShorePermit = true
                    end
                end
            )
            addCommsReply(_("<Back>"), borderStationCommsArrivals)
        end
    )
end

function borderStationCommsArrivals()
    setCommsMessage(_("Human Worlds welcome you. Humans, press 1. Non-human, press 9."))
    addCommsReply(
        _("<1>"),
        function()
            setCommsMessage(_("We are happy to have you back. Fast-track, press 1. Ship registration, press 2. " ..
                "Docking fees, press 3. On-shore permits, press 4. Political asylum, press 5."))
            addCommsReply(
                _("<1>"),
                function()
                    setCommsMessage(_("Fast-track is enabled by default for all Human owned vessels. No need to do anything, your case will be handled ahead of non-humans."))
                    addCommsReply(_("<Back>"), borderStationCommsArrivals)
                end
            )
            addCommsReply(
                _("<2>"),
                function()
                    setCommsMessage(_("To register a ship all you have to do is submit a request to Administration Office via electronic mail. It will be handled free " ..
                        "of charge. "))
                    addCommsReply(_("<Back>"), borderStationCommsArrivals)
                end
            )
            borderStationCommsPermits(true)
            addCommsReply(
                _("<5>"),
                function()
                    setCommsMessage(_("Humans have many enemies. We must stick together. We offer political asylum from all other races, " ..
                        "like Kraylor, Exhuari, Arlenians, Klitans and Ghosts. Please contact any Security officer upon boarding the station."))
                    addCommsReply(_("<Back>"), borderStationCommsArrivals)
                end
            )
        end
    )
    addCommsReply(
        _("<9>"),
        function()
            setCommsMessage(_("Have your papers ready. Security officers have the right to search your crew and your vessel without warrant. \n" ..
                "Be informed that a special contribution for transporting goods by non-human crews applies. For more information, press 9.\n" ..
                "Visa applications, press 1. Ship registration, press 2. Docking fees, press 3. On-shore permits, press 4. Political asylum, press 5."))
            addCommsReply(
                _("<1>"),
                function()
                    setCommsMessage(_("Visa applications are currently on hold. Applicants in queue: 3801283."))
                    addCommsReply(_("<Back>"), borderStationCommsArrivals)
                end
            )
            addCommsReply(
                _("<2>"),
                function()
                    setCommsMessage(_("An additional fee of 20% of current market rate for the ship is required to obtain ship registration documents. " ..
                        "Please contact the Administration Office while on board the station. Normal docking fees and an on-shore permit apply."))
                        addCommsReply(_("<Back>"), borderStationCommsArrivals)
                end
            )
            borderStationCommsPermits(false)
            addCommsReply(
                _("<5>"),
                function()
                    setCommsMessage(_("Political asylum is currently only available for Humans."))
                    addCommsReply(_("<Back>"), borderStationCommsArrivals)
                end
            )
        end
    )
end

function borderStationCommsDepartures()
    setCommsMessage(_("Humans, press 1. Non-human, press 9."))
    addCommsReply(
        _("<1>"),
        function()
            setCommsMessage(_("We are sad to see you go. Be back soon!"))
        end
    )
    addCommsReply(
        _("<9>"),
        function()
            setCommsMessage(_("Please have appropriate papers ready upon returning. Keep in mind that we have a right to freeze your accounts and " ..
                "seize your property held in Human Space under any suspicion of anti-Human behaviour, including, but not limited to: piracy, terrorism, " ..
                "diminishing profits, defamation and slander, accessing banned works or art depicting anti-Human sentiment, and more."))
        end
    )
end

function borderStationCommsTalkToHuman()
    local musicRand = irandom(1,3)
    if musicRand == 1 then
        setCommsMessage(_("<Channel open>"))
    else
        setCommsMessage(_("<Cheery ukulele music plays>"))
    end

    local respRand = irandom(1, 3)
    if respRand == 1 then
        addCommsReply(
            _("Hello?"),
            borderStationCommsTalkToHuman
        )
    elseif respRand == 2 then
        addCommsReply(
            _("Can anyone hear me?"),
            borderStationCommsTalkToHuman
        )
    elseif respRand == 3 then
        addCommsReply(
            _("This is " .. comms_source:getCallSign() .. " to " .. comms_target:getCallSign() .. ", can you hear me?"),
            borderStationCommsTalkToHuman
        )
    end
end

function borderStationComms()
    setCommsMessage(_("This is " .. comms_target:getCallSign() .. ". Arrivals to Human systems, press 1. Departures to Indpendend space, press 2. " .. 
        " Speak to a human, press 3."))
    addCommsReply(
        _("<1>"),
        borderStationCommsArrivals
    )
    addCommsReply(
        _("<2>"),
        borderStationCommsDepartures
    )
    addCommsReply(
        _("<3>"),
        borderStationCommsTalkToHuman
    )
    borderStationCommsMissionSpecific()
end 

function borderStationComms_m1_5()
    if comms_source:isDocked(comms_target) then
        addCommsReply(
            _("<Talk to the Chief Medical Officer>"),
            function()
                setCommsMessage(_("Doctor Jane here."))
                addCommsReply(
                    _("We've arrived <let the CMO onto the station>."),
                    function()
                        borderStationQuarantine = true
                        setCommsMessage(_("Thank you, I'll get to work immediately. A quarantine zone will be setup in the docking bay. " ..
                            "Also, we have orders from HQ to deny access to the wormhole to all non-Human ships. We still don't know the " ..
                            "nature of the disease. I recommend you refrain from docking to non-Human controlled stations, as only those have decontamination units " ..
                            "to stop the spread, at least for now. That makes it this station and " .. freeport9:getCallSign() .. "."))
                    end
                )
            end
        )
    end
end

function borderStationComms_m1_7()
    if comms_source:isDocked(comms_target) then
        addCommsReply(
            _("<Talk to the Chief Medical Officer>"),
            function()
                setCommsMessage(_("There's no time to waste. I've analized your conversation with the Ghost. It confirms my findings. The infection... it works on the " ..
                    "biomolecular level, transforming the patient and melding it with surrounding electronics. The patient is kept alive at all times, but, as you " ..
                    "can probably imagine, the experience is agonising. I call it... the melding plague."))
                addCommsReply(
                    _("Is there a cure?"),
                    function()
                        setCommsMessage(_("Unfortunately not... I can't even begin to imagine what would happen if the plague reached Human Worlds. The melding plague " ..
                            "must be stopped at all costs. The line must be drawn here. This far, no further."))
                        registerRetryCallback(5, function()
                            return freeport9:sendCommsMessage(
                                getPlayerShip(-1),
                                _(getPlayerShip(-1):getCallSign() .. ", report to " .. freeport9:getCallSign() .. "."))
                            end
                        )
                        freeport9CommsMissionSpecific = freeport9Comms_m1_7
                    end
                )
            end
        )
    end
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
