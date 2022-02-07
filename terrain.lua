require("utils.lua")


function evalParabola(a, b, c, x0, y0, x)
    return a*(x-x0)*(x-x0) + b*(x-x0) + c+y0
end


function createInRing(object_type, amount, dist_min, dist_max, x0, y0)
    for n = 1, amount do
        local r = random(0, 360)
        local distance = random(dist_min, dist_max)
        x = x0 + math.cos(r / 180 * math.pi) * distance
        y = y0 + math.sin(r / 180 * math.pi) * distance
        object_type():setPosition(x, y)
    end
end



function initializeNebulas(amount, x0, y0, numSectorsPerSide)
    placeRandomObjects(Nebula, 30, 0.5, 0, 0, numSectorsPerSide, numSectorsPerSide)

    --- parabola 1  (values obtained experimentally)
    a1 = 0.0000005
    b1 = 0
    c1 = 0

    --- parabola 2 (values obtained experimentally)
    a2 = 0.000005
    b2 = 1.5
    c2 = 10000

    local allObjs = getAllObjects()
    for i=1, #allObjs do
        if allObjs[i]:isValid() and allObjs[i].typeName == "Nebula" then

            local x, y = allObjs[i]:getPosition()

            local eval1 = evalParabola(a1, b1, c1, x0, y0, x)
            local eval2 = evalParabola(a2, b2, c2, x0, y0, x)

            if not(y > eval1 and y < eval2 or y > eval2 and y < eval1) then
                --- give the nebula field some shape:
                --- remove not in boundaries of 2 parabolas
                allObjs[i]:destroy()
            end
        end
    end
end

function clearNebulasInRadius(x, y, r)
    local objs = getObjectsInRadius(x, y, r)
    for i=1, #objs do
        if objs[i].typeName == "Nebula" then
            objs[i]:destroy()
        end
    end
end

function combNebulas()
    local allObjs = getAllObjects()
    for i=1, #allObjs do
        if allObjs[i]:isValid() and allObjs[i].typeName == "Nebula" then

            --- remove nebulas which are right on top of each other for performance
            local inRange = allObjs[i]:getObjectsInRange(4000.0)
            for j=1, #inRange do
                if inRange[j] ~= allObjs[i] and inRange[j].typeName == "Nebula" then
                    inRange[j]:destroy()
                end
            end
        end
    end
end

function initializeMinerHabs()
    local habsToCreate = {
        {name = "Hab 218", x = 135338, y = 64184}, 
        {name = "Hab 221", x = 136087, y = 66575}, 
        {name = "Hab 219", x = 137619, y = 63725}, 
        {name = "Hab 154", x = 66430, y = 52186}, 
        {name = "Hab 155", x = 65571, y = 51498}, 
        {name = "Hab 705", x = 108774, y = 31594}, 
        {name = "Hab 801", x = 86763, y = 88371}, 
        {name = "Hab 51", x = 25155, y = 15336}, 
        {name = "Hab 50", x = 26832, y = 16153}, 
        {name = "Hab 52", x = 24513, y = 17242}, 
        {name = "Hab 301", x = 68931, y = 120334}, 
    }

    for i=1, #habsToCreate do
        local entry = habsToCreate[i] 
        print("[Terrain] Spawning ", entry.name)

        local aHab = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign(entry.name):setPosition(entry.x, entry.y):setRotation(random(0, 360)):setCommsFunction(randomizedHabCommsFunc())
        table.insert(habs, aHab)
    end
end
