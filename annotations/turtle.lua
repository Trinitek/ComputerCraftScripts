---https://tweaked.cc/module/turtle.html

---@diagnostic disable: lowercase-global

---@class CCBlockInfo
---@field name string The block identifier, i.e. `minecraft:oak_log`.
---@field state table? A key-value bag of block states, i.e. `axis = "x"`.
---@field tags table? A key-value bag of block tags, i.e. `["minecraft:logs"] = true`.

turtle = {
    ---Move the turtle forward one block.
    ---@return boolean successful Whether the turtle could successfully move.
    ---@return string|nil reason The reason the turtle could not move.
    forward = function () end,

    ---Move the turtle backwards one block.
    ---@return boolean successful Whether the turtle could successfully move.
    ---@return string|nil reason The reason the turtle could not move.
    back = function () end,

    ---Move the turtle up one block.
    ---@return boolean successful Whether the turtle could successfully move.
    ---@return string|nil reason The reason the turtle could not move.
    up = function () end,

    ---Move the turtle down one block.
    ---@return boolean successful Whether the turtle could successfully move.
    ---@return string|nil reason The reason the turtle could not move.
    down = function () end,

    ---Rotate the turtle 90 degrees to the left.
    ---@return boolean successful Whether the turtle could successfully turn.
    ---@return string|nil reason The reason the turtle could not turn.
    turnLeft = function () end,

    ---Rotate the turtle 90 degrees to the right.
    ---@return boolean successful Whether the turtle could successfully turn.
    ---@return string|nil reason The reason the turtle could not turn.
    turnRight = function () end,

    ---Attempt to break the block in front of the turtle.
    ---This requires a turtle tool capable of breaking the block. Diamond pickaxes can break any vanilla block.
    ---@param side? "left"|"right" The specific tool to use, if more than one tool is equipped.
    ---@return boolean successful Whether a block was broken.
    ---@return string|nil reason The reason no block was broken.
    dig = function (side) end,

    ---Attempt to break the block above the turtle.
    ---This requires a turtle tool capable of breaking the block. Diamond pickaxes can break any vanilla block.
    ---@param side? "left"|"right" The specific tool to use, if more than one tool is equipped.
    ---@return boolean successful Whether a block was broken.
    ---@return string|nil reason The reason no block was broken.
    digUp = function (side) end,

    ---Attempt to break the block below the turtle.
    ---This requires a turtle tool capable of breaking the block. Diamond pickaxes can break any vanilla block.
    ---@param side? "left"|"right" The specific tool to use, if more than one tool is equipped.
    ---@return boolean successful Whether a block was broken.
    ---@return string|nil reason The reason no block was broken.
    digDown = function (side) end,

    ---Place a block or item into the world in front of the turtle.
    ---
    ---"Placing" an item allows it to interact with blocks and entities in front of the turtle. For instance,
    ---buckets can pick up and place down fluids, and wheat can be used to breed cows. However, you cannot use
    ---`place` to perform arbitrary block interactions, such as clicking buttons or flipping levers.
    ---@param text? string When placing a sign, set its contents to this text.
    ---@return boolean successful Whether the block could be placed.
    ---@return string|nil reason The reason the block was not placed.
    place = function (text) end,

    ---Place a block or item into the world above the turtle.
    ---@param text? string When placing a sign, set its contents to this text.
    ---@return boolean successful Whether the block could be placed.
    ---@return string|nil reason The reason the block was not placed.
    placeUp = function (text) end,

    ---Place a block or item into the world below the turtle.
    ---@param text? string When placing a sign, set its contents to this text.
    ---@return boolean successful Whether the block could be placed.
    ---@return string|nil reason The reason the block was not placed.
    placeDown = function (text) end,

    ---Drop the currently selected stack into the inventory in front of the turtle, or as an item into the world
    ---if there is no inventory.
    ---@param count? integer The number of items to drop. If not given, the entire stack will be dropped.
    ---@return boolean successful
    ---@return string|nil errorReason The reason no items were dropped
    ---Throws if an invalid count is given.
    drop = function (count) end,

    ---Drop the currently selected stack into the inventory above the turtle, or as an item into the world
    ---if there is no inventory.
    ---@param count? integer The number of items to drop. If not given, the entire stack will be dropped.
    ---@return boolean successful
    ---@return string|nil errorReason The reason no items were dropped
    ---Throws if an invalid count is given.
    dropUp = function (count) end,

    ---Drop the currently selected stack into the inventory below the turtle, or as an item into the world
    ---if there is no inventory.
    ---@param count? integer The number of items to drop. If not given, the entire stack will be dropped.
    ---@return boolean successful
    ---@return string|nil errorReason The reason no items were dropped
    ---Throws if an invalid count is given.
    dropDown = function (count) end,

    ---Change the currently selected slot.
    ---@param slot integer The slot to select. Must be between [1..16].
    ---@return boolean successful
    ---Throws if the slot is out of range.
    select = function (slot) end,

    ---Get the number of items in the given slot.
    ---@param slot? integer The slot to check, or the currently selected slot if not provided. Must be between [1..16].
    ---@return integer count
    ---Throws if the slot is out of range.
    getItemCount = function (slot) end,

    ---Get the remaining number of items which may be stored in this stack.
    ---For example a stack of 13 blocks of dirt can hold an additional 51 blocks.
    ---@param slot? integer The slot to check, or the currently selected slot if not provided. Must be between [1..16].
    ---@return integer countRemaining
    ---Throws if the slot is out of range.
    getItemSpace = function (slot) end,

    detect = function () end,
    detectUp = function() end,
    detectDown = function () end,

    compare = function () end,
    compareUp = function () end,
    compareDown = function () end,

    attack = function (side) end,
    attackUp = function (side) end,
    attackDown = function (side) end,

    suck = function (count) end,
    suckUp = function (count) end,
    suckDown = function (count) end,

    ---Get the maximum amount of fuel this turtle currently holds.
    ---@return integer|"unlimited" amount The current amount of fuel this turtle has.
    getFuelLevel = function () end,

    ---Refuel this turtle. While most actions a turtle can perform (such as digging pr placing blocks) are free,
    ---moving consumes fuel from the turtle's internal buffer. If a turtle ahs no fuel, it will not move.
    ---This function refuels the turtle, consuming fuel items (such as coal or lava buckets) from the currently selected
    ---slot and converting them into energy. This finishes once the turtle is fully refuelled or all items have been consumed.
    ---@param count? integer The maximum number of items to consume, or 0 to check if an item is combustable or not.
    ---@return boolean successful True if the turtle was refuelled.
    ---@return string|nil reason The reason why the turtle was not refuelled.
    ---Throws if the refuel count is out of range.
    refuel = function (count) end,

    ---Compare the item in the currently selected slot to the item in another slot.
    ---@param slot integer The slot to compare to. Must be between [1..16].
    ---@return boolean areEqual
    ---Throws if the slot is out of range.
    compareTo = function (slot) end,

    ---Move an item from the selected slot to another one.
    ---@param slot integer The slot to move this item into. Must be between [1..16].
    ---@param count? integer The maximum number of items to move.
    ---@return boolean successful True if at least some items were moved.
    ---Throws if the slot is out of range or the number of items is out of range.
    transferTo = function (slot, count) end,

    ---Get the currently selected slot.
    ---@return integer slot The current slot.
    getSelectedSlot = function () end,

    ---Get the maximum amount of fuel this turtle can hold.
    ---By default, normal turtles have a limit of 20,000 and advanced turtles a limit of 100,000.
    ---@return integer|"unlimited" amount The maximum amount of fuel a turtle can hold.
    getFuelLimit = function () end,

    equipLeft = function () end,
    equipRight = function () end,

    ---Get information about the block in front of the turtle.
    ---@return boolean hasBlock Whether there is a block present.
    ---@return CCBlockInfo|string info Information about the block, or a message explaining that there is no block.
    inspect = function () end,

    ---Get information about the block above the turtle.
    ---@return boolean hasBlock Whether there is a block present.
    ---@return CCBlockInfo|string info Information about the block, or a message explaining that there is no block.
    inspectUp = function () end,

    ---Get information about the block below the turtle.
    ---@return boolean hasBlock Whether there is a block present.
    ---@return CCBlockInfo|string info Information about the block, or a message explaining that there is no block.
    inspectDown = function () end,

    ---Get detailed information about the items in the given slot.
    ---@param slot? integer The slot to get information about. Defaults to the currently selected slot.
    ---@param detailed? boolean Whether to include "detailed" information. When `true` the return value will contain much more information about the item at the cost of taking longer to run.
    ---@return table|nil details Information about the given slot, or nil if it is empty.
    ---Throws if the slot is out of range. Valid slots are [1..16].
    getItemDetail = function (slot, detailed) end,

    craft = function (limit) end
}
