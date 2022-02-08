player = nil

freeport9 = nil

stroke1 = nil
stroke3 = nil
stroke4 = nil

minerHab = nil

hfFreighter = nil
sosSquawkEnabled = nil



freeport9CommsMissionSpecific = nil
minerHabCommsMissionSpecific = nil
hfFreighterCommsMissionSpecific = nil

northExitWh = nil
southExitWh = nil
outsideExitArea = true

bobsStation = nil
borderStation = nil

--- terrain
habs = {}

--- commerce
commerceFreighters = {}
tradeRouteSouthToNorth = {}
tradeRouteNorthToSouth = {}

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
ambushStateBackToNormal = 6
ambushStateDone = 7


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