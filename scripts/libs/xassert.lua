
---@enum Types
local Types = {
    ["Nil"] = "nil",
    ["Boolean"] = "boolean",
    ["Number"] = "number",
    ["String"] = "string",
    ["Function"] = "function",
    ["Table"] = "table"
}

---@param name string?
local function throwParamNull(name)
    if not name then
        error("Parameter cannot be null");
    else
        error("Parameter cannot be null: '" .. name .. "'");
    end
end

---@param object any
---@param name string?
local function notNull(object, name)
    if not object then
        throwParamNull(name)
    end
end

---@generic T: any
---@param object T
---@param name string
---@param assertion boolean
---@param message string?
---@return T
local function param(object, name, assertion, message)
    if not assertion then
        if message == nil then
            error("Param assert failed: '" .. name .. "'");
        else
            error("Param assert failed: '" .. name .. "': " .. message);
        end
    end
    return object;
end

---@generic T: any
---@param object T
---@param name string
---@param expectedType string
---@param message string?
---@return T
local function paramType(object, name, expectedType, message)
    local objectType = type(object);
    if objectType ~= expectedType then
        if message == nil then
            error("Param type mismatch: '" .. name .. "' was " .. objectType .. " but expected " .. expectedType)
        else
            error("Param type mismatch: '" .. name .. "' was " .. objectType .. " but expected " .. expectedType .. ": " .. message)
        end
    end
    return object;
end

return {
    Types = Types,
    notNull = notNull,
    param = param,
    paramType = paramType
}
