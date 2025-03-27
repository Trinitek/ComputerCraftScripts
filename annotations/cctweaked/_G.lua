---https://tweaked.cc/module/_G.html

---@meta

---@diagnostic disable: lowercase-global

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
