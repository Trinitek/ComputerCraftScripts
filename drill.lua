
--

local ignoreBlocks = {
    ["minecraft:blackstone"] = true,
    ["minecraft:netherrack"] = true,
    ["minecraft:nether_bricks"] = true,
    ["minecraft:soul_sand"] = true,
    ["minecraft:soul_soil"] = true,
    ["biomesoplenty:brimstone"] = true,
    ["minecraft:magma_block"] = true
}

local foundBlocks = { }

local height = 0

---Logs to standard output.
---@param msg any The message to log.
local function log(msg)
    print(msg)
end

local function incrementStatistic(key)
    foundBlocks[key] = (foundBlocks[key] or 0) + 1
end

---Tries to navigate down, breaking blocks in its way.
---@return boolean successful False if there is a non-breakable block preventing movement.
local function goDown()
    if not turtle.down() then
        local blockPresent, details = turtle.inspectDown()
        if (blockPresent) then
            incrementStatistic(details.name)
        end

        turtle.digDown()
        turtle.suckDown()

        if turtle.down() then
            height = height - 1
            return true
        else
            return false
        end
    else
        height = height - 1
        return true
    end
end

---Determines if the given inspection call indicates the presence of lava.
---Example: isLava(turtle.inspect())
---@param blockPresent boolean True if a block is present.
---@param details any The table of details or an error string.
local function isLava(blockPresent, details)
    return blockPresent and details.name == "minecraft:lava"
end

---Selects a valid filler block from the predefined block list in the inventory.
---@return boolean successful False if there is no such block in the inventory.
local function selectFillerBlock()
    local detail = turtle.getItemDetail()
    if detail then
        if ignoreBlocks[detail.name] then
            return true
        end
    end
    
    for i = 1, 16, 1 do
        local detail = turtle.getItemDetail(i)
        if detail then
            if ignoreBlocks[detail.name] then
                turtle.select(i)
                return true
            end
        end
    end

    return false
end

local function stopLava()
    local blockPresent, detail = turtle.inspect()
    if blockPresent then
        if detail.name == "minecraft:lava" then
            if selectFillerBlock() then
                turtle.place()
            end
        end
    end
end

local function goInspect()
    local blockPresent, detail = turtle.inspect()
    if blockPresent then
        incrementStatistic(detail.name)
        --if detail.name == "minecraft:lava" then
        --    if selectFillerBlock() then
        --        turtle.place()
        --    end
        --elseif ignoreBlocks[detail.name] == nil then
        if ignoreBlocks[detail.name] == nil then
            turtle.dig()
            turtle.suck()
        end
    else
        incrementStatistic("air")
    end

    turtle.turnRight()
end

local function goDrill()
    height = 0

    while (goDown()) do
        goInspect()
        goInspect()
        goInspect()
        goInspect()
    end
    
    for i = height + 1, 0, 1 do
        turtle.up()
    end
end

---Digs the block in front of the turtle including falling gravel and sand columns.
local function ensureDigAhead()
    while (turtle.dig()) do
        turtle.suck()
    end
end

---Digs the block above of the turtle including falling gravel and sand columns.
local function ensureDigUp()
    while (turtle.digUp()) do
        turtle.suckUp()
    end
end

---Moves the turtle forward or throws an error.
local function assertForward()
    local moveResult, msg = turtle.forward()
    if not moveResult then
        error(msg)
    end
end

local function assertUp()
    local moveResult, msg = turtle.up()
    if not moveResult then
        error(msg)
    end
end

local function assertDown()
    local moveResult, msg = turtle.down()
    if not moveResult then
        error(msg)
    end
end

---Builds a 1x2 3-long tunnel with a left turn and seals it from lava.
---The turtle's starting position should be just behind the bottom block of the wall.
local function goTunnel()

    local function sealLava()
        if isLava(turtle.inspect()) and selectFillerBlock() then
            local placeResult, msg = turtle.place()
            if not placeResult then
                error(msg)
            end
        end
    end

    local function sealLavaAbove()
        if isLava(turtle.inspectUp()) and selectFillerBlock() then
            local placeResult, msg = turtle.placeUp()
            if not placeResult then
                error(msg)
            end
        end
    end

    -- The following comments denote the turtle's position at that point

    -- 0 bottom forward

    ensureDigAhead()
    assertForward()
    -- 1 bottom forward
    
    turtle.turnLeft()
    sealLava()
    -- 1 bottom left
    
    turtle.turnRight()
    turtle.turnRight()
    sealLava()
    -- 1 bottom right
    
    ensureDigUp()
    assertUp()
    sealLavaAbove()
    sealLava()
    -- 1 top right

    turtle.turnLeft()
    turtle.turnLeft()
    sealLava()
    -- 1 top left

    turtle.turnRight()
    ensureDigAhead()
    assertForward()
    sealLavaAbove()
    sealLava()
    -- 2 top forward

    turtle.turnRight()
    sealLava()
    -- 2 top right

    turtle.digDown()
    turtle.suckDown()
    assertDown()
    sealLava()
    -- 2 bottom right

    turtle.turnLeft()
    sealLava()
    -- 2 bottom forward

    turtle.turnLeft()
    -- 2 bottom left

    -- Turning corner now
    -- "Forward, left, right" are now relative to the turn, not starting orientation

    ensureDigAhead()
    assertForward()
    sealLava()
    -- 3 bottom forward

    turtle.turnRight()
    sealLava()
    -- 3 bottom right

    turtle.turnLeft()
    turtle.turnLeft()
    sealLava()
    -- 3 bottom left

    ensureDigUp()
    assertUp()
    sealLavaAbove()
    sealLava()
    -- 3 top right

    turtle.turnRight()
    sealLava()
    -- 3 top forward

    turtle.turnRight()
    sealLava()
    -- 3 top left

    assertDown()
    -- 3 bottom left

    -- Positioned and ready for next drill and tunnel.
end

if (tonumber(arg[1]) or 0) <= 0 or string.lower(arg[1]) == "help" or not tonumber(arg[1]) then
    print("Drills a 1x1 shaft into the ground, mining ores along the walls.")
    print("Usage:")
    print("  " .. arg[0] .. " help  Shows help")
    print("  " .. arg[0] .. " #     Number of holes to drill")
    return
end

local holesToDig = tonumber(arg[1])
local tunnelsToDig = holesToDig - 1

log("Holes=" .. holesToDig .. ", Tunnels=" .. tunnelsToDig)
log("Started")

goDrill()

for i_tunnelsToDig = tunnelsToDig, 1, -1 do
    goTunnel()
    goDrill()
end

log("Statistics:\n" .. textutils.serialize(foundBlocks))
