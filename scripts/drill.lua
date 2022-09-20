
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

local entity = MovingEntity:newFromTurtle();
local positionHistory = PositionHistory:new(entity);

---Logs to standard output.
---@param msg any The message to log.
local function log(msg)
    print(msg)
end

local function depositItems()
    for i=1, 16, 1 do
        turtle.select(i);
        turtle.drop();
    end
end

local function incrementStatistic(key)
    foundBlocks[key] = (foundBlocks[key] or 0) + 1
end

---Tries to navigate down, breaking blocks in its way.
---@return boolean successful False if there is a non-breakable block preventing movement.
local function goDown()
    if not entity:down() then
        local blockPresent, details = turtle.inspectDown()
        if (blockPresent) then
            incrementStatistic(details.name)
        end

        turtle.digDown()
        turtle.suckDown()

        local successful = entity:down()
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

    entity:turnRight()
end

---
---@param holeDepth integer?
local function goDrill(holeDepth)
    --height = 0

    while (true) do
        if holeDepth and entity.position.point3d.y <= -holeDepth then break end
        if not goDown() then break end
        goInspect()
        goInspect()
        goInspect()
        goInspect()
    end

    for i = entity.position.point3d.y + 1, 0, 1 do
        entity:up()
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
    local moveResult, msg = entity:forward()
    if not moveResult then
        error(msg)
    end
end

local function assertUp()
    local moveResult, msg = entity:up()
    if not moveResult then
        error(msg)
    end
end

local function assertDown()
    local moveResult, msg = entity:down()
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

    -- Dig plan:
    --
    -- ######
    -- ##32##
    -- ###1##
    -- ###0##
    --
    -- The following comments denote the turtle's position at that point

    -- 0 bottom forward

    ensureDigAhead()
    assertForward()
    -- 1 bottom forward

    entity:turnLeft()
    sealLava()
    -- 1 bottom left

    entity:turnRight()
    entity:turnRight()
    sealLava()
    -- 1 bottom right

    ensureDigUp()
    assertUp()
    sealLavaAbove()
    sealLava()
    -- 1 top right

    entity:turnLeft()
    entity:turnLeft()
    sealLava()
    -- 1 top left

    entity:turnRight()
    ensureDigAhead()
    assertForward()
    sealLavaAbove()
    sealLava()
    -- 2 top forward

    entity:turnRight()
    sealLava()
    -- 2 top right

    turtle.digDown()
    turtle.suckDown()
    assertDown()
    sealLava()
    -- 2 bottom right

    entity:turnLeft()
    sealLava()
    -- 2 bottom forward

    entity:turnLeft()
    -- 2 bottom left

    positionHistory:push(); -- push history at corner

    -- Turning corner now
    -- "Forward, left, right" are now relative to the turn, not starting orientation

    ensureDigAhead()
    assertForward()
    sealLava()
    -- 3 bottom forward

    entity:turnRight()
    sealLava()
    -- 3 bottom right

    entity:turnLeft()
    entity:turnLeft()
    sealLava()
    -- 3 bottom left

    ensureDigUp()
    assertUp()
    sealLavaAbove()
    sealLava()
    -- 3 top right

    entity:turnRight()
    sealLava()
    -- 3 top forward

    entity:turnRight()
    sealLava()
    -- 3 top left

    assertDown()
    -- 3 bottom left

    -- Positioned and ready for next drill and tunnel.

    positionHistory:push(); -- push history at next drill position
end

local ARG_H = arg[1]
local ARG_D = arg[2]
local ARG_C = arg[3]
local ARG_HD = arg[4]

if (tonumber(ARG_H) or 0) <= 0 or string.lower(ARG_H) == "help" or not tonumber(ARG_H) then
    print("Drills a 1x1 shaft into the ground, mining ores along the walls.")
    print("Usage:")
    print("  " .. arg[0] .. " help     Shows help")
    print("  " .. arg[0] .. " <h> <d> <c> [hd]")
    print("  h  - Number of holes to drill")
    print("  d  - Dimension (ignore blocks)")
    print("       o = Overworld, n = Nether")
    print("  c  - Deposit into chest at origin?")
    print("       cy = Yes, cn = No")
    print("  hd - Hole depth, optional")
    return
end

local holesToDig = tonumber(ARG_H);
local tunnelsToDig = holesToDig - 1;
---@type integer?
local holeDepth = math.floor(tonumber(ARG_HD) or -1);

local dimLower = string.lower(ARG_D);
local dimFriendlyName = "";
if (dimLower == "o") then
    ignoreBlocks = IGNOREBLOCKS_OVERWORLD;
    dimFriendlyName = "Overworld";
elseif (dimLower == "n") then
    ignoreBlocks = IGNOREBLOCKS_NETHER;
    dimFriendlyName = "Nether";
else
    print("Unknown dimension code '" .. ARG_D .. "'");
    return;
end

---@type boolean
local depositChest;
local depositChestsLower = string.lower(ARG_C);
if (depositChestsLower == "cy") then
    depositChest = true;
elseif (depositChestsLower == "cn") then
    depositChest = false;
else
    print("Unexpected argument for <c>: '" .. ARG_C .. "'");
    return;
end

if (holeDepth < 0) then holeDepth = nil end

log("Holes=" .. holesToDig .. ", Tunnels=" .. tunnelsToDig .. ", Depth=" .. (holeDepth or "max"));
log("Dim=" .. dimFriendlyName .. ", Chest=" .. tostring(depositChest));
log("Started");

-- positionHistory:push(); -- not needed because we're already at origin

goDrill(holeDepth)

if (tunnelsToDig < 1) and (depositChest) then
    entity:turnToFacing("south");
    depositItems();
    entity:turnToFacing("north");
end

for i_tunnelsToDig = tunnelsToDig, 1, -1 do
    goTunnel();

    if (depositChest) then
        -- After tunneling, return to chest to deposit items
        positionHistory:navigate(1);
        entity:turnToFacing("south"); -- not needed but just to be 100% sure
        depositItems();
        positionHistory:navigate(positionHistory.top);
        entity:turnToFacing("north");
    end

    goDrill(holeDepth);
end

log("Statistics:\n" .. textutils.serialize(foundBlocks));
