
-- Expected starting position is on the floor immediately behind the beginning of the tunnel.

local ignoreBlocks = {
    ["minecraft:blackstone"] = true,
    ["minecraft:netherrack"] = true,
    ["minecraft:nether_bricks"] = true,
    ["minecraft:soul_sand"] = true,
    ["minecraft:soul_soil"] = true,
    ["biomesoplenty:brimstone"] = true,
    ["minecraft:magma_block"] = true,
    ["biomesoplenty:flesh"] = true,
    ["biomesoplenty:porous_flesh"] = true
}

---Total of all lava seal blocks placed, both temporary and permanent along the walls.
---@type integer
local lavaSealsPlaced = 0

---Digs the block in front of the turtle including falling gravel and sand columns.
local function ensureDigAhead()
    while (turtle.dig()) do
        turtle.suck()
    end
end

local function ensureDigDown()
    while (turtle.digDown()) do
        turtle.suckDown()
    end
end

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

local function selectFillerBlockOrWait()
    while (not selectFillerBlock()) do
        print("Ran out of filler blocks. Waiting for inventory...")
        os.pullEvent("turtle_inventory");
        print("Detected inventory change. Resuming.")
    end
    return true
end

local function compressInventory()
    for dest = 1, 15, 1 do
        for source = dest + 1, 16, 1 do
            if turtle.getItemCount(source) > 0 then
                turtle.select(source)
                turtle.transferTo(dest)
            end
        end
    end
end

local function incrementSealBlockCount()
    lavaSealsPlaced = lavaSealsPlaced + 1
    if lavaSealsPlaced % 64 == 0 then
        print("Compressing inventory")
        compressInventory()
    end
end

local function sealLava()
    if isLava(turtle.inspect()) and selectFillerBlockOrWait() then
        local placeResult, msg = turtle.place()
        if not placeResult then
            error(msg)
        end
        incrementSealBlockCount()
    end
end

local function sealLavaAbove()
    if isLava(turtle.inspectUp()) and selectFillerBlockOrWait() then
        local placeResult, msg = turtle.placeUp()
        if not placeResult then
            error(msg)
        end
        incrementSealBlockCount()
    end
end

if ((tonumber(arg[1]) or 0) <= 0 or string.lower(arg[1]) == "help") then
    print("Tunnels a 1x2 tunnel straight ahead, sealing lava along the way.")
    print("Usage:")
    print("  " .. arg[0] .. " help  Shows help")
    print("  " .. arg[0] .. " #     Length of tunnel")
    return
end

local length = tonumber(arg[1])

for position = 0, length - 1, 1 do

    ensureDigUp() -- break lava backflow stop if present, see below
    assertUp()
    ensureDigAhead()
    assertForward()
    sealLavaAbove()
    sealLava() -- prevent lava backflow when going down
    turtle.turnLeft()
    sealLava()
    turtle.turnRight()
    turtle.turnRight()
    sealLava()
    ensureDigDown()
    assertDown()
    sealLava()
    turtle.turnLeft()
    turtle.turnLeft()
    sealLava()
    turtle.turnRight()

    if position % 5 == 0 then
        print("Traveled " .. position)
    end
end

-- Seal lava at the end
sealLava()
assertUp()
sealLava()
assertDown()
