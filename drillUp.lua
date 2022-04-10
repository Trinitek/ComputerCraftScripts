
-- Expected starting position is on floor immediately under the position to dig.

local ignoreBlocks = {
    ["minecraft:blackstone"] = true,
    ["minecraft:netherrack"] = true,
    ["minecraft:nether_bricks"] = true,
    ["minecraft:soul_sand"] = true,
    ["minecraft:soul_soil"] = true,
    ["biomesoplenty:brimstone"] = true,
    ["minecraft:magma_block"] = true
}

local function ensureDigUp()
    while (turtle.digUp()) do
        turtle.suckUp()
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

if ((tonumber(arg[1]) or 0) <= 0 or string.lower(arg[1]) == "help") then
    print("Drills a 1x1 tunnel upwards and returns to the ground, sealing lava along the way.")
    print("Usage:")
    print("  " .. arg[0] .. " help  Shows help")
    print("  " .. arg[0] .. " #     Length of tunnel")
    return
end

local length = tonumber(arg[1])

for position = 0, length - 1, 1 do

    local function sealAround()
        sealLava()
        turtle.turnRight()
        sealLava()
        turtle.turnRight()
        sealLava()
        turtle.turnRight()
        sealLava()
        turtle.turnRight()
    end

    ensureDigUp()
    assertUp()
    sealAround()

end

-- Seal lava at the end

sealLavaAbove()

-- Return to ground
for position = 0, length - 1, 1 do
    assertDown()
end
