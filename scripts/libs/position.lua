
require("libs.point3d");
local xassert = require("libs.xassert");

---@alias Facing "north"|"south"|"east"|"west"

---@type table<Facing, integer>
local FACING_LOOKUP = {
    ["north"] = 0,
    ["east"] = 1,
    ["south"] = 2,
    ["west"] = 3
}

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

---@class MovingEntity
---@field position Position
---@field p_fnForward fun(): boolean, string
---@field p_fnBack fun(): boolean, string
---@field p_fnUp fun(): boolean, string
---@field p_fnDown fun(): boolean, string
---@field p_fnTurnLeft fun(): boolean, string
---@field p_fnTurnRight fun(): boolean, string
MovingEntity = { }

---@param position Position
---@param fnForward fun(): boolean, string
---@param fnBack fun(): boolean, string
---@param fnUp fun(): boolean, string
---@param fnDown fun(): boolean, string
---@param fnTurnLeft fun(): boolean, string
---@param fnTurnRight fun(): boolean, string
function MovingEntity:new(position, fnForward, fnBack, fnUp, fnDown, fnTurnLeft, fnTurnRight)
    ---@type MovingEntity
    local o = {
        position = xassert.paramType(position, "position", type(Position)),
        p_fnForward = xassert.paramType(fnForward, "fnForward", xassert.Types.Function),
        p_fnBack = xassert.paramType(fnBack, "fnBack", xassert.Types.Function),
        p_fnUp = xassert.paramType(fnUp, "fnUp", xassert.Types.Function),
        p_fnDown = xassert.paramType(fnDown, "fnDown", xassert.Types.Function),
        p_fnTurnLeft = xassert.paramType(fnTurnLeft, "fnTurnLeft", xassert.Types.Function),
        p_fnTurnRight = xassert.paramType(fnTurnRight, "fnTurnRight", xassert.Types.Function)
    };
    setmetatable(o, self);
    self.__index = self;
    return o;
end

---Constructs a new MovingEntity instance from the current turtle.
---@param position Position? The origin position. Defaults to `(0,0,0),"north"` if nil.
function MovingEntity:newFromTurtle(position)
    return MovingEntity:new(
        position or Position:new(),
        turtle.forward,
        turtle.back,
        turtle.up,
        turtle.down,
        turtle.turnLeft,
        turtle.turnRight);
end

---@return boolean successful
---@return string? failureReason
function MovingEntity:forward()
    local successful, failureReason = self.p_fnForward();
    if successful then
        self.position:forward();
    end
    return successful, failureReason;
end

---@return boolean successful
---@return string? failureReason
function MovingEntity:back()
    local successful, failureReason = self.p_fnBack();
    if successful then
        self.position:back();
    end
    return successful, failureReason;
end

---@return boolean successful
---@return string? failureReason
function MovingEntity:up()
    local successful, failureReason = self.p_fnUp();
    if successful then
        self.position:up();
    end
    return successful, failureReason;
end

---@return boolean successful
---@return string? failureReason
function MovingEntity:down()
    local successful, failureReason = self.p_fnDown();
    if successful then
        self.position:down();
    end
    return successful, failureReason;
end

---@return boolean successful
---@return string? failureReason
function MovingEntity:turnLeft()
    local successful, failureReason = self.p_fnTurnLeft();
    if successful then
        self.position:turnLeft();
    end
    return successful, failureReason;
end

---@return boolean successful
---@return string? failureReason
function MovingEntity:turnRight()
    local successful, failureReason = self.p_fnTurnRight();
    if successful then
        self.position:turnRight();
    end
    return successful, failureReason;
end

---@param facing Facing
function MovingEntity:turnToFacing(facing)
    local turns = FACING_LOOKUP[self.position.facing] - FACING_LOOKUP[facing]
    -- -3   left 1
    -- -2   left 2
    -- -1   right 1
    --  0   nothing
    --  1   left 1
    --  2   right 2
    --  3   right 1

    ---@param action fun(self: MovingEntity): boolean, string
    local function assertTurn(action)
        local successful, failureReason = action(self);
        if not successful then
            error("Unexpected exception when turning to facing: " .. failureReason);
        end
    end

    if turns == -3 then
        assertTurn(self.turnLeft);
    end

    if turns == -2 then
        assertTurn(self.turnLeft);
        assertTurn(self.turnLeft);
    end

    if turns == -1 then
        assertTurn(self.turnRight);
    end

    if turns == 1 then
        assertTurn(self.turnLeft);
    end

    if turns == 2 then
        assertTurn(self.turnRight);
        assertTurn(self.turnRight);
    end

    if turns == 3 then
        assertTurn(self.turnRight);
    end
end

---@class Position
---@field point3d Point3D
---@field facing Facing
Position = {
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

function Position:turnLeft()
    self.facing = translateIntegerToFacing(FACING_LOOKUP[self.facing] - 1);
end

function Position:turnRight()
    self.facing = translateIntegerToFacing(FACING_LOOKUP[self.facing] + 1);
end

function Position:forward()
    if self.facing == "north" then self.point3d.x = self.point3d.x + 1
    elseif self.facing == "south" then self.point3d.x = self.point3d.x - 1
    elseif self.facing == "east" then self.point3d.z = self.point3d.z + 1
    elseif self.facing == "west" then self.point3d.z = self.point3d.z - 1
    end
end

function Position:back()
    if self.facing == "north" then self.point3d.x = self.point3d.x - 1
    elseif self.facing == "south" then self.point3d.x = self.point3d.x + 1
    elseif self.facing == "east" then self.point3d.z = self.point3d.z - 1
    elseif self.facing == "west" then self.point3d.z = self.point3d.z + 1
    end
end

function Position:up()
    self.point3d.y = self.point3d.y + 1
end

function Position:down()
    self.point3d.y = self.point3d.y - 1;
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
---@field entity MovingEntity
---@field stack table<PositionHistoryRecord>
---@field top integer
---@field index integer
PositionHistory = { }

---@param entity MovingEntity
function PositionHistory:new(entity)
    ---@type PositionHistory
    local o = { }
    setmetatable(o, self)
    self.__index = self

    o.currentPos = entity;
    o.stack = { };
    o.stack[1] = PositionHistoryRecord:new(entity.position.point3d);
    o.top = 1;
    o.index = 1;

    return o;
end

---@return Position
function PositionHistory:getCurrentPosition()
    return self.entity.position;
end

---Pushes the given position (or the current position if nil) to the stack at the current index.
---If there are existing positions above the current index, they are destroyed.
---If the current and previous positions are different on more than one axis,
---an exception is thrown.
---@param position Position? The position to push or nil to use the current entity position.
function PositionHistory:push(position)
    local currentPosition = position or self:getCurrentPosition();

    if not currentPosition.point3d:getDelta1D(self.stack[self.index].point3d) then
        error("Cannot push position: differs from previous in more than one axis.");
    end

    self.index = self.index + 1;
    self.stack[self.index] = PositionHistoryRecord:new(currentPosition.point3d);
    self.top = self.index;
end

---Navigates the turtle position backwards or forwards through the history.
---@param toIndex integer
function PositionHistory:navigate(toIndex)
    if (toIndex < 1) or (toIndex > self.top) then
        error("Cannot navigate to index less than 1 or greater than the top index.");
    end

    local deltaFromCurrent = self:getCurrentPosition().point3d:getDelta1D(self.stack[self.index].point3d);

    if not deltaFromCurrent then
        error("Current position and position at current index differ on more than one axis.");
    end

    ---@param delta Point3DDelta1D
    local function go(delta)
        local facing = delta:getFacing();
        if facing then
            self.entity:turnToFacing(facing);
        end

        if (delta.axis == "x") or (delta.axis == "z") then
            for i=1, delta:getMagnitudeForFacing(), 1 do
                self.entity:forward()
            end
        elseif (delta.axis == "y") then
            local y = delta:getMagnitudeForFacing();
            if (y >= 0) then
                for i=1, y, 1 do
                    self.entity:up();
                end
            else
                for i=1, math.abs(y), 1 do
                    self.entity:down();
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

    while self.index ~= toIndex do
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
