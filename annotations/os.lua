---https://tweaked.cc/module/os.html

---@meta

---@diagnostic disable: lowercase-global

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
