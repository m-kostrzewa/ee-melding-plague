player = nil

freeport9 = nil

stroke1 = nil
stroke3 = nil
stroke4 = nil

minerHab = nil


freeport9CommsMissionSpecific = nil
minerHabCommsMissionSpecific = nil

northExitWh = nil
southExitWh = nil
outsideExitArea = true

bobsStation = nil
borderStation = nil

allStationsRefs = {}

--- border
borderStationCommsMissionSpecific = nil
borderStationQuarantine = nil

--- terrain
habs = {}

--- commerce
commerceFreighters = {}
tradeRouteSouthToNorth = {}
tradeRouteNorthToSouth = {}

--- ghosts
hfFreighterCommsMissionSpecific = nil
hfFreighter = nil
sosSquawkEnabled = nil


--- ambush
kralienFiend = nil
kralienFiendCommsMissionSpecific = {}
ambushState = 0
ambushStateLieInWait = 0
ambushStateAskCeaseFire = 1
ambushStateCeaseFire = 2
ambushStateAllOutAttack = 3
ambushStateDuel = 4
ambushStateResolved = 5
ambushStateDone = 7


--- callbacks
lastCallbackId = 0
callbacks = {}

function isShipPerfectlyFine(ship) 
    if not ship:isValid() then
        return false
    end

    if ship:getHull() < ship:getHullMax() then
        return false
    end
    for i=1, ship:getShieldCount() do
        if ship:getShieldLevel(i) < ship:getShieldMax(i) then
            return false
        end
    end
    return true
end

function registerAtSecondsCallback(atSeconds, func)
    lastCallbackId = lastCallbackId + 1

    local cb = {atSeconds = atSeconds, func = func}
    callbacks[lastCallbackId] = cb

    print("[Callback] Registering id=" .. lastCallbackId .. " atSeconds=" .. atSeconds)
    return lastCallbackId
end

function unregisterAtSecondsCallback(id)
    print("[Callback] Unregistering " .. id)
    callbacks[id] = nil
end

function registerRetryCallback(interval, func)
    local actualFunc = function(id)
        local ret = func(id)
        if not ret then
            local retryAt = interval
            registerRetryCallback(interval, func)
        end
        unregisterAtSecondsCallback(id)
    end
    registerAtSecondsCallback(getScenarioTime() + interval, actualFunc)
end

function updateCallbacks(delta)
    local currentSeconds = getScenarioTime()
    for id=1, lastCallbackId do
        if callbacks[id] ~= nil and currentSeconds >= callbacks[id].atSeconds then
            callbacks[id].func(id)
        end
    end
end