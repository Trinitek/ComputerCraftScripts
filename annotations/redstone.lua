---https://tweaked.cc/module/redstone.html

---@meta

---@diagnostic disable: lowercase-global

---@alias CCSide "top"|"bottom"|"left"|"right"|"front"|"back"

redstone = {
    ---Returns a list containing the six sides of the computer: top, bottom, left, right, front, and back.
    ---@return table sides
    getSides = function () end,

    ---Turn  the redstone signal of a specific side on or off.
    ---@param side CCSide The side to set.
    ---@param on boolean True to set the signal strength to 15, false to set it to 0.
    setOutput = function (side, on) end,

    ---Get the current redstone output of a specific side.
    ---@param side CCSide The side to get.
    ---@return boolean isOn Whether the redstone output is on or off.
    getOutput = function (side) end,

    ---Get the current redstone input for a specific side.
    ---@param side CCSide The side to get.
    ---@return boolean isOn Whether the redstone input is on or off.
    getInput = function (side) end,

    ---Set the redstone signal strength for a specific side.
    ---@param side CCSide The side to set.
    ---@param value integer The signal strength between 0 and 15.
    setAnalogOutput = function (side, value) end,

    ---Get the redstone output signal strength for a specific side.
    ---@param side CCSide The side to get.
    ---@return integer value The output signal strength, between 0 and 15.
    getAnalogOutput = function (side) end,

    ---Get the redstone input signal strength for a specific side.
    ---@param side CCSide The side to get.
    ---@return integer value The input signal strength, between 0 and 15.
    getAnalogInput = function (side) end,

    setBundledOutput = function (side, output) end,
    getBundledOutput = function (side) end,
    getBundledInput = function (side) end,
    testBundledInput = function (side, mask) end
}
