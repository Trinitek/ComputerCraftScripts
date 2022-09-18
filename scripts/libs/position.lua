
---@class Vector
---@field x integer Increments going north, decrements going south
---@field y integer Increments going up, decrements going down
---@field z integer Increments going east, decrements going west
Vector = {
}

---@param x integer
---@param y integer
---@param z integer
---@return Vector
function Vector:new(x, y, z)
    ---@type Vector
    local o = { }
    setmetatable(o, self)
    self.__index = self

    o.x = x
    o.y = y
    o.z = z

    return o
end

---@alias Facing "north"|"south"|"east"|"west"

---@class Position
---@field vector Vector
---@field facing Facing
Position = {
}

---@type table<Facing, integer>
local facingLookup = {
    ["north"] = 0,
    ["east"] = 1,
    ["south"] = 2,
    ["west"] = 3
}

---@param vector Vector
---@param facing Facing
---@return Position
function Position:new(vector, facing)
    ---@type Position
    local o = { }
    setmetatable(o, self)
    self.__index = self

    o.vector = vector
    o.facing = facing

    return o;
end

---@param iFacing integer
local function translateIntegerToFacing(iFacing)
    ---@type table<integer, Facing>
    local facingReverseLookup = {
        [0] = "north",
        [1] = "east",
        [2] = "south",
        [3] = "west"
    }

    return facingReverseLookup[iFacing % 4]
end

function Position:turnLeft()
    turtle.turnLeft();
    self.facing = translateIntegerToFacing(facingLookup[self.facing] - 1);
end

function Position:turnRight()
    turtle.turnRight();
    self.facing = translateIntegerToFacing(facingLookup[self.facing] + 1);
end

---Changes the direction the turtle is facing relative to the origin.
---@param facing Facing
function Position:setFacing(facing)
    local turns = facingLookup[self.facing] - facingLookup[facing]
    -- -3   left 1
    -- -2   left 2
    -- -1   right 1
    --  0   nothing
    --  1   left 1
    --  2   right 2
    --  3   right 1

    if turns == -3 then
        self:turnLeft()
    end

    if turns == -2 then
        self:turnLeft()
        self:turnLeft()
    end

    if turns == -1 then
        self:turnRight()
    end

    if turns == 1 then
        self:turnLeft()
    end

    if turns == 2 then
        self:turnRight()
        self:turnRight()
    end

    if turns == 3 then
        self:turnRight()
    end
end

---@return boolean successful
---@return string? failureReason
function Position:forward()
    local successful, failureReason = turtle.forward()
    if successful then
        if self.facing == "north" then self.vector.x = self.vector.x + 1
        elseif self.facing == "south" then self.vector.x = self.vector.x - 1
        elseif self.facing == "east" then self.vector.z = self.vector.z + 1
        elseif self.facing == "west" then self.vector.z = self.vector.z - 1
        end
    end
    return successful, failureReason
end

---@return boolean successful
---@return string? failureReason
function Position:back()
    local successful, failureReason = turtle.back()
    if successful then
        if self.facing == "north" then self.vector.x = self.vector.x - 1
        elseif self.facing == "south" then self.vector.x = self.vector.x + 1
        elseif self.facing == "east" then self.vector.z = self.vector.z - 1
        elseif self.facing == "west" then self.vector.z = self.vector.z + 1
        end
    end
    return successful, failureReason
end

---@return boolean successful
---@return string? failureReason
function Position:up()
    local successful, failureReason = turtle.up()
    if successful then
        self.vector.y = self.vector.y + 1
    end
    return successful, failureReason
end

---@return boolean successful
---@return string? failureReason
function Position:down()
    local successful, failureReason = turtle.up()
    if successful then
        self.vector.y = self.vector.y - 1
    end
    return successful, failureReason
end

return Position
