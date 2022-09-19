
---@alias Facing "north"|"south"|"east"|"west"

---@class Point3D
---@field x integer Increments going north, decrements going south
---@field y integer Increments going up, decrements going down
---@field z integer Increments going east, decrements going west
Point3D = { }

---@param x integer
---@param y integer
---@param z integer
---@return Point3D
function Point3D:new(x, y, z)
    ---@type Point3D
    local o = { }
    setmetatable(o, self)
    self.__index = self

    o.x = x
    o.y = y
    o.z = z

    return o
end

---Gets a value copy of the current instance.
---@return Point3D
function Point3D:copy()
    return Point3D:new(self.x, self.y, self.z);
end

---Gets the one-dimensional difference between the current position and the
---given previous position. If the two differ on more than one axis, the result is nil.
---@param previous Point3D
---@return Point3DDelta1D?
function Point3D:getDelta1D(previous)
    local dx = self.x - previous.x;
    local dy = self.y - previous.y;
    local dz = self.z - previous.z;

    if (dx ~= 0 and dy ~= 0) or (dx ~= 0 and dz ~= 0) or (dy ~= 0 and dz ~= 0) then
        return nil;
    end

    if (dx ~= 0) then return Point3DDelta1D:new("x", dx);
    elseif (dy ~= 0) then return Point3DDelta1D:new("y", dy);
    elseif (dz ~= 0) then return Point3DDelta1D:new("z", dz);
    else return Point3DDelta1D:new("x", 0); end
end

---@alias Axis "x"|"y"|"z"

---@class Point3DDelta1D
---@field axis Axis
---@field amount integer
Point3DDelta1D = { }

---@param axis Axis
---@param amount integer
function Point3DDelta1D:new(axis, amount)
    ---@type Point3DDelta1D
    local o = {
        axis = axis,
        amount = amount
    }
    setmetatable(o, self);
    self.__index = self;

    return o;
end

---Returns the facing of the direction of the delta, or nil if the difference
---is in the Y axis.
---@return Facing?
function Point3DDelta1D:getFacing()
    if (self.axis == "x") then
        if (self.amount >= 0) then return "north"
        else return "south" end
    elseif (self.axis == "z") then
        if (self.amount >= 0) then return "east"
        else return "west"
        end
    else
        return nil
    end
end

---Returns the magnitude of the movement in the direction of the facing as returned
---by getFacing().
---@return integer
function Point3DDelta1D:getMagnitudeForFacing()
    if (self.axis == "x") or (self.axis == "z") then return math.abs(self.amount)
    else return self.amount
    end
end

---@return Point3DDelta1D
function Point3DDelta1D:getReverse()
    return Point3DDelta1D:new(self.axis, self.amount * -1);
end

---@class Position
---@field point3d Point3D
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

---@param point3d? Point3D The origin point. Defaults to (0,0,0) if nil.
---@param facing? Facing The direction the turtle is facing. Defaults to "north" if nil.
---@return Position
function Position:new(point3d, facing)
    ---@type Position
    local o = { };
    setmetatable(o, self);
    self.__index = self;

    o.point3d = point3d or Point3D:new(0,0,0);
    o.facing = facing or "north";

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

    return facingReverseLookup[iFacing % 4];
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
        if self.facing == "north" then self.point3d.x = self.point3d.x + 1
        elseif self.facing == "south" then self.point3d.x = self.point3d.x - 1
        elseif self.facing == "east" then self.point3d.z = self.point3d.z + 1
        elseif self.facing == "west" then self.point3d.z = self.point3d.z - 1
        end
    end
    return successful, failureReason
end

---@return boolean successful
---@return string? failureReason
function Position:back()
    local successful, failureReason = turtle.back()
    if successful then
        if self.facing == "north" then self.point3d.x = self.point3d.x - 1
        elseif self.facing == "south" then self.point3d.x = self.point3d.x + 1
        elseif self.facing == "east" then self.point3d.z = self.point3d.z - 1
        elseif self.facing == "west" then self.point3d.z = self.point3d.z + 1
        end
    end
    return successful, failureReason
end

---@return boolean successful
---@return string? failureReason
function Position:up()
    local successful, failureReason = turtle.up()
    if successful then
        self.point3d.y = self.point3d.y + 1
    end
    return successful, failureReason
end

---@return boolean successful
---@return string? failureReason
function Position:down()
    local successful, failureReason = turtle.down()
    if successful then
        self.point3d.y = self.point3d.y - 1
    end
    return successful, failureReason
end

---@class PositionHistoryRecord
---@field point3d Point3D
PositionHistoryRecord = { }

---@param point3d Point3D
function PositionHistoryRecord:new(point3d)
    ---@type PositionHistoryRecord
    local o = { };
    setmetatable(o, self);
    self.__index = self;

    o.point3d = point3d:copy();

    return o;
end

---@class PositionHistory
---@field currentPos Position
---@field stack table<PositionHistoryRecord>
---@field top integer
---@field index integer
PositionHistory = { }

---@param position Position
function PositionHistory:new(position)
    ---@type PositionHistory
    local o = { }
    setmetatable(o, self)
    self.__index = self

    o.currentPos = position;
    o.stack = { };
    o.stack[1] = PositionHistoryRecord:new(position.point3d);
    o.top = 1;
    o.index = 1;

    return o;
end

---Pushes the current position to the stack at the current index.
---If there are existing positions above the current index, they are destroyed.
---If the current and previous positions are different on more than one axis,
---an exception is thrown.
function PositionHistory:push()
    if not self.currentPos.point3d:getDelta1D(self.stack[self.index].point3d) then
        error("Cannot push current position: differs from previous in more than one axis.");
    end

    self.index = self.index + 1;
    self.stack[self.index] = PositionHistoryRecord:new(self.currentPos.point3d);
    self.top = self.index;
end

---Navigates the turtle position backwards or forwards through the history.
---@param toIndex integer
function PositionHistory:navigate(toIndex)
    if (toIndex < 1) or (toIndex > self.top) then
        error("Cannot navigate to index less than 1 or greater than the top index.");
    end

    local deltaFromCurrent = self.currentPos.point3d:getDelta1D(self.stack[self.index].point3d);

    if not deltaFromCurrent then
        error("Current position and position at current index differ on more than one axis.");
    end

    ---@param delta Point3DDelta1D
    local function go(delta)
        local facing = delta:getFacing();
        if facing then
            self.currentPos:setFacing(facing);
        end

        if (delta.axis == "x") or (delta.axis == "z") then
            for i=1, delta:getMagnitudeForFacing(), 1 do
                self.currentPos:forward()
            end
        elseif (delta.axis == "y") then
            local y = delta:getMagnitudeForFacing();
            if (y >= 0) then
                for i=1, y, 1 do
                    self.currentPos:up();
                end
            else
                for i=1, math.abs(y), 1 do
                    self.currentPos:down();
                end
            end
        end
    end

    go(deltaFromCurrent:getReverse());

    ---@type integer
    local step;
    if (self.index < toIndex) then step = 1
    elseif (self.index > toIndex) then step = -1
    else return end

    for i=self.index, toIndex, step do
        ---@type PositionHistoryRecord
        local current = self.stack[self.index];
        ---@type PositionHistoryRecord
        local next = self.stack[self.index + step];

        if not next then break end

        local delta = current.point3d:getDelta1D(next.point3d);

        if not delta then
            error("Unexpected null delta between " .. self.index .. " and " .. self.index + step);
        end

        go(delta:getReverse());

        self.index = self.index + step;
    end
end
