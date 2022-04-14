
-- Fuels a collection of Botania Endoflame flowers.

---Fuels and their burn times in seconds
---@type table<string, integer>
local fuelItems = {
    ["quark:charcoal_block"] = 800,
    ["minecraft:coal_block"] = 800,
    ["minecraft:charcoal"] = 64,
    ["minecraft:coal"] = 64
}

---@param msg string
local function log(msg)
    print(os.date("%X") .. " " .. msg)
end

---Selects a valid item from the predefined fuel list in the inventory.
---@return string|nil item Item name that was selected, or nil
local function selectFuelItem()
    local detail = turtle.getItemDetail()
    if detail then
        if fuelItems[detail.name] then
            return true
        end
    end

    for i = 1, 16, 1 do
        local detail = turtle.getItemDetail(i)
        if detail then
            if fuelItems[detail.name] then
                turtle.select(i)
                return true
            end
        end
    end

    return false
end

local function compressInventory()
    for dest = 1, 15, 1 do
        for source = 2, 16, 1 do
            turtle.select(source)
            turtle.transferTo(dest)
        end
    end
end

-- Support loading as a module
if package.loaded["dropEndoflameFuel"] then
    return {
        fuelItems = fuelItems,
        selectFuelItem = selectFuelItem,
        compressInventory = compressInventory
    }
end

local dropCount = tonumber(arg[1])

if not tonumber(arg[1]) then
    print("Fuels a collection of Botania Endoflame flowers.")
    print("Usage:")
    print("  dropEndoflameFuel <count>")
    return
end

while true do

    log("Compressing inventory")
    compressInventory()

    local item = selectFuelItem()

    if turtle.getItemCount() < dropCount then
        log("Ran out of fuel items")
        return
    end

    turtle.dropDown(dropCount)
    log("Dropped " .. dropCount .. " of " .. item)

    local sleepTime = fuelItems[item]

    log("Sleeping for " .. sleepTime .. " seconds")
    os.sleep(sleepTime)

end
