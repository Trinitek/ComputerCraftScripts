---https://tweaked.cc/module/textutils.html

---@meta

---@diagnostic disable: lowercase-global

---@class CCTextUtilsSerializeOptions
---@field compact? boolean  If true, do not add indentation or other whitespace.
---@field allow_repetitions? boolean If true, relax the check for recursive tables and allow table instances to appear multiple times, as long as tables do not appear inside themselves.

---@class CCTextUtilsUnserializeJsonOptions
---@field nbt_style boolean If true, this will accept stringified NBT strings as produced by many commands.
---@field parse_null boolean If true, `null` will be parsed as `json_null` rather than `nil`.

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
    ---@return string serialized
    serialize = function (t, opts) end,

    ---Converts a serialized string back into a reassembled Lua object.
    ---@param s string The serialized string to deserialize.
    ---@return any deserialized
    unserialize = function (s) end,

    ---Returns a JSON representation of the given data.
    ---
    ---This function attempts to guess whether a table is a JSON array or object. However, empty tables are assumed to be empty objects;
    ---use `textutils.empty_json_array` to mark an empty array.
    ---
    ---This is largely intended for interacting with various functions from the `commands` and `http` APIs.
    ---@param t any The value to serialize. Like `textutils.serialize`, this should not contain recursive tables or functions.
    ---@param nbtStyle boolean Whether to produce NBT-style JSON (non-quoted keys) instead of standard JSON.
    ---Throws if the object contains a value that cannot be serialized.
    serializeJSON = function (t, nbtStyle) end,

    ---Converts a serialized JSON string back into a reassembled Lua object.
    ---
    ---This may be used with `textutils.serializeJSON` or when communicating with command blocks or web APIs.
    ---@param s string The serialized string to deserialize.
    ---@param options? CCTextUtilsUnserializeJsonOptions
    ---@return any|nil deserialized The deserialized object or nil if it could not be deserialized.
    ---@return string errorMessage A message describing why the JSON string is invalid.
    unserializeJSON = function (s, options) end,

    urlEncode = function (str) end,
    complete = function (searchText, searchTable) end
}
