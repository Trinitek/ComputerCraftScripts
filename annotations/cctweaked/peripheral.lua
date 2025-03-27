---https://tweaked.cc/module/peripheral.html

---@meta

---@diagnostic disable: lowercase-global

---@class CCPeripheral A wrapped peripheral that contains callable functions.
peripheral = {
    ---Provides a list of all peripherals available.
    ---If a device is located directly next to the system, then its name will be listed as the side it is attached to.
    ---If a device is attached via a Wired Modem, then it will be reported according to its name on the wired network.
    ---@return table names A list of the names of all attached peripherals.
    getNames = function () end,

    ---Determines if a peripheral is present with the given name.
    ---@param name string The side or network name to check, i.e. "top" or "monitor_0".
    ---@return boolean isPresent True if a peripheral with the given name is present.
    isPresent = function (name) end,

    ---Get the types of a named or wrapped peripheral.
    ---@param peripheral string|CCPeripheral The name of the peripheral to find, or a wrapped peripheral instance.
    ---@return table|nil types A list of strings of the peripheral's types, or nil if it is not present.
    getType = function (peripheral) end,

    ---Check if a peripheral is of a particular type.
    ---@param peripheral string|CCPeripheral The name of the peripheral or a wrapped peripheral instance.
    ---@param peripheralType string The type to check.
    ---@return boolean|nil isType True if a peripheral has a particular type, or nil if it is not present.
    hasType = function (peripheral, peripheralType) end,

    ---Get all available methods for the peripheral with the given name.
    ---@param name string The name of the peripheral to find.
    ---@return table|nil methodList A list of method names as strings provided by this peripheral, or nil if it is not present.
    getMethods = function (name) end,

    ---Get the name of a wrapped peripheral.
    ---@param peripheral CCPeripheral The peripheral of which to get the name.
    ---@return string name The name of the given peripheral.
    getName = function (peripheral) end,

    ---Call a method on the peripheral with the given name.
    ---@param name string The name of the peripheral on which to invoke the method.
    ---@param method string The name of the method to invoke.
    ---@vararg any Additional method arguments
    call = function (name, method, ...) end,

    ---Get a table containing all functions available on a peripheral. These can then be called instead of using peripheral.call().
    ---@param name string The name of the peripheral to wrap.
    ---@return CCPeripheral|nil peripheral A table containing the peripheral's methods, or nil if no peripheral was found.
    wrap = function (name) end,

    ---Find all peripherals of a specific type, and return the wrapped peripherals.
    ---@param peripheralType string The type of peripheral to look for.
    ---@param filter? fun(name: string, peripheral: CCPeripheral): boolean An optional filter predicate. For a given peripheral's name and a wrapped peripheral instance, return true if the peripheral should be included in the result.
    ---@return table peripherals A list of zero or more wrapped peripherals matching the given filters.
    find = function (peripheralType, filter) end
}
