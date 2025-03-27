
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
    ---@class Point3D
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
    ---@class Point3DDelta1D
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
