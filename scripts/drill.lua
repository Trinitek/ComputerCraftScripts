
--

require("libs.position")

local IGNOREBLOCKS_NETHER = {
    ["minecraft:blackstone"] = true,
    ["minecraft:netherrack"] = true,
    ["minecraft:nether_bricks"] = true,
    ["minecraft:soul_sand"] = true,
    ["minecraft:soul_soil"] = true,
    ["biomesoplenty:brimstone"] = true,
    ["minecraft:magma_block"] = true
}

local IGNOREBLOCKS_OVERWORLD = {
    ["minecraft:stone"] = true,
    ["minecraft:cobblestone"] = true,
    ["minecraft:deepslate"] = true,
    ["minecraft:cobbled_deepslate"] = true,
    ["minecraft:andesite"] = true,
    ["minecraft:diorite"] = true,
    ["minecraft:calcite"] = true,
    ["minecraft:granite"] = true,
    ["minecraft:dirt"] = true,
    ["minecraft:tuff"] = true,
    ["create:asurine"] = true,
    ["create:crimsite"] = true,
    ["create:limestone"] = true,
    ["biomesoplenty:mud"] = true,
    ["biomesoplenty:glowing_moss_block"] = true,
    ["biomesoplenty:glowing_moss_carpet"] = true,
    ["biomesoplenty:glowshroom"] = true,
    ["biomesoplenty:glowworm_silk"] = true,
}

local ignoreBlocks = { }

local foundBlocks = { }

local turtlePos = Position:new(Point3D:new(0, 0, 0), "north");

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
    if not turtlePos:down() then
        local blockPresent, details = turtle.inspectDown()
        if (blockPresent) then
            incrementStatistic(details.name)
        end

        turtle.digDown()
        turtle.suckDown()

        local successful = turtlePos:down()
        return successful
    else
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
        if ignoreBlocks[detail.name] == nil then
            turtle.dig()
            turtle.suck()
        end
    else
        incrementStatistic("air")
    end

    turtlePos:turnRight()
end

---
---@param holeDepth integer?
local function goDrill(holeDepth)
    --height = 0

    while (true) do
        if holeDepth and turtlePos.point3d.y <= -holeDepth then break end
        if not goDown() then break end
        goInspect()
        goInspect()
        goInspect()
        goInspect()
    end

    for i = turtlePos.point3d.y + 1, 0, 1 do
        turtlePos:up()
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
    local moveResult, msg = turtlePos:forward()
    if not moveResult then
        error(msg)
    end
end

local function assertUp()
    local moveResult, msg = turtlePos:up()
    if not moveResult then
        error(msg)
    end
end

local function assertDown()
    local moveResult, msg = turtlePos:down()
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

    turtlePos:turnLeft()
    sealLava()
    -- 1 bottom left

    turtlePos:turnRight()
    turtlePos:turnRight()
    sealLava()
    -- 1 bottom right

    ensureDigUp()
    assertUp()
    sealLavaAbove()
    sealLava()
    -- 1 top right

    turtlePos:turnLeft()
    turtlePos:turnLeft()
    sealLava()
    -- 1 top left

    turtlePos:turnRight()
    ensureDigAhead()
    assertForward()
    sealLavaAbove()
    sealLava()
    -- 2 top forward

    turtlePos:turnRight()
    sealLava()
    -- 2 top right

    turtle.digDown()
    turtle.suckDown()
    assertDown()
    sealLava()
    -- 2 bottom right

    turtlePos:turnLeft()
    sealLava()
    -- 2 bottom forward

    turtlePos:turnLeft()
    -- 2 bottom left

    -- Turning corner now
    -- "Forward, left, right" are now relative to the turn, not starting orientation

    ensureDigAhead()
    assertForward()
    sealLava()
    -- 3 bottom forward

    turtlePos:turnRight()
    sealLava()
    -- 3 bottom right

    turtlePos:turnLeft()
    turtlePos:turnLeft()
    sealLava()
    -- 3 bottom left

    ensureDigUp()
    assertUp()
    sealLavaAbove()
    sealLava()
    -- 3 top right

    turtlePos:turnRight()
    sealLava()
    -- 3 top forward

    turtlePos:turnRight()
    sealLava()
    -- 3 top left

    assertDown()
    -- 3 bottom left

    -- Positioned and ready for next drill and tunnel.
end

local ARG_H = arg[1]
local ARG_D = arg[2]
local ARG_HD = arg[3]

if (tonumber(ARG_H) or 0) <= 0 or string.lower(ARG_H) == "help" or not tonumber(ARG_H) then
    print("Drills a 1x1 shaft into the ground, mining ores along the walls.")
    print("Usage:")
    print("  " .. arg[0] .. " help     Shows help")
    print("  " .. arg[0] .. " <h> <d> [hd]")
    print("  h  - Number of holes to drill")
    print("  d  - Dimension; determines which blocks to ignore")
    print("       o = Overworld, n = Nether")
    print("  hd - Hole depth, optional")
    return
end

local holesToDig = tonumber(ARG_H)
local tunnelsToDig = holesToDig - 1
---@type integer?
local holeDepth = math.floor(tonumber(ARG_HD) or -1)

local dimLower = string.lower(ARG_D);
local dimFriendlyName = ""
if (dimLower == "o") then
    ignoreBlocks = IGNOREBLOCKS_OVERWORLD
    dimFriendlyName = "Overworld"
elseif (dimLower == "n") then
    ignoreBlocks = IGNOREBLOCKS_NETHER
    dimFriendlyName = "Nether"
else
    print("Unknown dimension code '" .. ARG_D .. "'")
    return
end

if (holeDepth < 0) then holeDepth = nil end

log("Holes=" .. holesToDig .. ", Tunnels=" .. tunnelsToDig .. ", Depth=" .. (holeDepth or "max"))
log("Dimension=" .. dimFriendlyName)
log("Started")

goDrill(holeDepth)

for i_tunnelsToDig = tunnelsToDig, 1, -1 do
    goTunnel()
    goDrill(holeDepth)
end

log("Statistics:\n" .. textutils.serialize(foundBlocks))
