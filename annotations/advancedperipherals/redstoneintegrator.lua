---https://advancedperipherals.netlify.app/peripherals/redstone_integrator/

---@meta

---@diagnostic disable: lowercase-global

---@class APRedstoneIntegrator : CCPeripheral
APRedstoneIntegrator = {
    ---Returns true if there is any redstone signal detected at the given side.
    ---@param side CCSide
    ---@return boolean
    getInput = function(side) end,

    ---Returns true if this integrator is sending a signal to the given side.
    ---@param side CCSide
    ---@return boolean
    getOutput = function(side) end,

    ---Returns the redstone level on the given side.
    ---@param side CCSide
    ---@return integer
    getAnalogInput = function(side) end,

    ---Returns the redstone level this integrator is sending to the given side.
    ---@param side CCSide
    ---@return integer
    getAnalogOutput = function(side) end,

    ---Sets the redstone output level on the given side to either 0 or 15.
    ---@param side CCSide
    ---@param powered boolean
    setOutput = function(side, powered) end,

    ---Sets the redstone output level on the given side to the given power level.
    ---@param side CCSide
    ---@param power integer
    setAnalogOutput = function(side, power) end
}
