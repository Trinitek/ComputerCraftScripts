--- EmmyLua annotations for ComputerCraft (CCTweaked).
--- For use with the Lua extension for VSCode at https://github.com/sumneko/lua-language-server.

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

    drop = function (count) end,
    dropUp = function (count) end,
    dropDown = function (count) end,

    select = function (slot) end,
    getItemCount = function (slot) end,
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

    compareTo = function (slot) end,
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

---@class CCPeripheral A wrapped peripheral that contains callable functions.

peripheral = {
    ---Provides a list of all peripherals available.
    ---If a device is located directly next to the system, then its name will be listed as the side it is attached to.
    ---If a device is attached via a Wired Modem, then it will be reported according to its name on the wired network.
    ---@return table names A list of the names of all attached peripherals.
    getNames = function () end,

    ---Determines if a preipheral is present with the given name.
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

---@class CCDateTime
---@field year integer Calendar year
---@field month integer Calendar month
---@field day integer Calendar day
---@field hour integer Hours (24 hour clock)
---@field min integer Minutes
---@field sec integer Seconds
---@field isdst boolean True if Daylight Savings Time is in effect.
---@field wday integer The nth week of the month.
---@field yday integer The nth day of the year.

---@alias CCEventFilter
---| '"alarm"'
---| '"char"'
---| '"computer_command"'
---| '"disk"'
---| '"disk_eject"'
---| '"http_check"'
---| '"http_failure"'
---| '"http_success"'
---| '"key"'
---| '"key_up"'
---| '"modem_message"'
---| '"monitor_resize"'
---| '"monitor_touch"'
---| '"mouse_click"'
---| '"mouse_drag"'
---| '"mouse_scroll"'
---| '"mouse_up"'
---| '"paste"'
---| '"peripheral"'
---| '"peripheral_detach"'
---| '"rednet_message"'
---| '"redstone"'
---| '"speaker_audio_empty"'
---| '"task_complete"'
---| '"term_resize"'
---| '"terminate"'
---| '"timer"'
---| '"turtle_inventory"'
---| '"websocket_closed"'
---| '"websocket_failure"'
---| '"websocket_message"'
---| '"websocket_success"'

os = {
    ---Pause execution of the current thread and waits for any events matching the given filter.
    ---
    ---This function yields the current process and waits for it to be resumed with a vararg list where the first element
    ---matches `filter`. If no filter is supplied, this will match all events.
    ---
    ---Unlike `os.pullEventRaw`, it will stop the application up a "terminate" event, printing the error "Terminated".
    ---@param filter? CCEventFilter|string Event to filter for.
    ---@return CCEventFilter|string event The name of the event that fired.
    ---@return any extraParams Optional additional parameters of the event.
    pullEvent = function (filter) end,

    ---Pause execution of the current thread and waits for events, including the `terminate` event.
    ---
    ---This behaves almost the same as `os.pullEvent`, except it allows you to handle the `terminate` event yourself;
    ---the program will not stop execution when `Ctrl+T` is pressed.
    ---@param filter? CCEventFilter|string Event to filter for.
    ---@return CCEventFilter|string event The name of the event that fired.
    ---@return any extraParams Optional additional parameters of the event.
    pullEventRaw = function (filter) end,

    ---Pauses execution for the specified number of seconds.
    ---@param time number The number of seconds to sleep for, rounded up to the nearest multiple of 0.05.
    sleep = function (time) end,

    ---Get the current CraftOS version, i.e. "CraftOS 1.8".
    ---@return string version
    version = function () end,

    run = function (env, path, ...) end,
    
    queueEvent = function (name, ...) end,
    
    startTimer = function (timer) end,
    cancelTimer = function (token) end,
    
    setAlarm = function (time) end,
    cancelAlarm = function (token) end,
    
    shutdown = function () end,
    reboot = function () end,
    
    getComputerId = function () end,
    computerId = function () end,

    getComputerLabel = function () end,
    computerLabel = function () end,
    setComputerLabel = function (label) end,

    ---Returns the number of seconds that a computer has been running.
    ---@return number upTime
    clock = function () end,

    ---Returns the current time depending on the given locale. This will always be some number between 0.0 and 24.0.
    ---
    --- - If called with `ingame`, the current world time is returned. This is the default.
    --- - If called with `utc`, the current hour of the day in UTC time is returned.
    --- - If called with `local`, the current hour of the day in the server's timezone is returned.
    ---
    ---This function can also be called with a table returned from `date` which will convert the date fields into a UNIX
    ---timestamp, which is the number of seconds since 1 January 1970.
    ---@param args? "ingame"|"utc"|"local"|CCDateTime The locale of the time, or a `CCDateTime` instance returned by `os.date("*t")`, or `ingame` if nil.
    ---@return number time The hour of the selected locale between 0.0 and 24.0, or a UNIX timestamp.
    time = function (args) end,

    ---Returns the day depending on the locale specified.
    ---
    --- - If called with `ingame`, the number of days since the world was created is returned. This is the default.
    --- - If called with `utc`, the number of days since 1 January 1970 in the UTC timezone is returned.
    --- - If called with `local`, the number of days since 1 January 1970 in the server's local timezone is returned.
    ---@param args? "ingame"|"utc"|"local" The locale for which to get the day, or `ingame` if nil.
    ---@return number day
    day = function (args) end,

    ---Returns the number of milliseconds since an epoch depending on the locale.
    ---
    --- - If called with `ingame`, the number of milliseconds since the world was created is returned. This is the default.
    --- - If called with `utc`, the number of milliseconds since 1 January 1970 in the UTC timezone is returned.
    --- - If called with `local`, the number of milliseconds since 1 January 1970 in the server's local timezone is returned.
    ---@param args? "ingame"|"utc"|"local" The locale for which to get the milliseconds, or `ingame` if nil.
    ---@return number milliseconds
    epoch = function (args) end,

    ---Returns a date string or `CCDateTime` instance using a specified format string and optional time to format.
    ---
    ---The format string takes the same formats as the C language `strftime` function. In extension, it can be prefixed
    ---with an exclamation mark `!` to use UTC time instead of the server's local timezone.
    ---
    ---If the format is exactly `*t`, optionally prefixed with `!`, a `CCDateTime` instance will be returned instead.
    ---This table has fields for the year, month, day, hour, minute, second, day of week, day of year, and whether
    ---Daylight Savings Time is in effect. This table can be converted to a UNIX timestamp with this function.
    ---@param format? string The format of the string to return, or `%c` if nil, which looks like "Sat Dec 24 16:58:00 2011".
    ---@param time? number The time to convert to a string, or the current time if nil.
    date = function (format, time) end
}

---@class CCTextUtilsSerializeOptions
---@field compact? boolean  If true, do not add indentation or other whitespace.
---@field allow_repetitions? boolean If true, relax the check for recursive tables and allow table instances to appear multiple times, as long as tables do not appear inside themselves.

textutils = {
    slowWrite = function (text, rate) end,
    slowPrint = function (text, rate) end,
    formatTime = function (time, twentyFourHour) end,
    pagedPrint = function (text, freeLines) end,
    tabulate = function (...) end,
    pagedTabulate = function (...) end,

    ---A table representing an empty JSON array, in order to distinguish it from an empty JSON object.
    ---**Do not modify this table.**
    empty_json_array = { },

    ---A table representing the JSON null value.
    ---**Do not modify this table.**
    json_null = { },

    ---Convert a Lua object into a textual representation, suitable for saving in a file or pretty-printing.
    ---@param t table The object to serialize.
    ---@param opts? CCTextUtilsSerializeOptions Serialization options.
    serialize = function (t, opts) end,

    unserialize = function (s) end,
    serializeJSON = function (t, nbtStyle) end,
    unserializeJSON = function (s, options) end,
    urlEncode = function (str) end,
    complete = function (searchText, searchTable) end
}

---@class _G Functions in the global environment, defined in `bios.lua`. This does not include standard Lua functions.
---@field _HOST string The ComputerCraft and Minecraft version of the current computer environment, i.e. "ComputerCraft 1.93.0 (Minecraft 1.15.2)".
---@field _CC_DEFAULT_SETTINGS string The default computer settings as defined in the ComputerCraft configuration by the server owner. This is a comma-separated list. Empty by default.
_G = {
    sleep = function (time) end;
    write = function (text) end;
    print = function (...) end;
    printError = function (...) end;
    read = function (replaceChar, history, completeFn, default) end;
}
