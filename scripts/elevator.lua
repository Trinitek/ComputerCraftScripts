--

local function log(msg)
    print(os.date("%X" .." " .. msg))
end

log("Started")

---@class RedstoneIntegrator : CCPeripheral
---@field setOutput fun(CCSide, boolean)
local ri_mech = peripheral.wrap("left")

local function driveConnect()
    ri_mech.setOutput("top", true)
    log("[Drv] Connect")
end

local function driveDisconnect()
    ri_mech.setOutput("top", false)
    log("[Drv] Disconnect")
end

local function driveUp()
    ri_mech.setOutput("left", false)
    log("[Drv] Up")
end

local function driveDown()
    ri_mech.setOutput("left", true)
    log("[Drv] Down")
end

---@class Floor
---@field sideBtnUp CCSide?
---@field sideBtnDown CCSide?
---@field sidePresence CCSide?
Floor = { }

---Constructs a new Floor instance.
---@param periph any            any redstone device that supports `getInput(side: string)`
---@param sideBtnUp CCSide?
---@param sideBtnDown CCSide
---@param sidePresence CCSide
---@return Floor
function Floor:new(periph, sideBtnUp, sideBtnDown, sidePresence)
    ---@class Floor
    local o = { }
    setmetatable(o, self)
    self.__index = self

    if periph == nil then
        error("periph cannot be nil", 2)
    end

    o.peripheral = periph
    o.sideBtnUp = sideBtnUp
    o.sideBtnDown = sideBtnDown
    o.sidePresence = sidePresence

    return o
end

function Floor:callingUp()
    if self.sideBtnUp == nil then return false end
    return self.peripheral.getInput(self.sideBtnUp)
end

function Floor:callingDown()
    if self.sideBtnDown == nil then return false end
    return self.peripheral.getInput(self.sideBtnDown)
end

function Floor:isPresent()
    if self.sidePresence == nil then return false end
    return self.peripheral.getInput(self.sidePresence)
end

local floors = {}

-- Initialize floors

local RI_B_UP = "top"
local RI_B_DOWN = "back"
local RI_PRESENT = "front"

floors[0] = Floor:new(redstone, nil, "back", "front")
floors[-1] = Floor:new(peripheral.wrap("redstoneIntegrator_0"), RI_B_UP, RI_B_DOWN, RI_PRESENT)
floors[-2] = Floor:new(peripheral.wrap("redstoneIntegrator_1"), RI_B_UP, RI_B_DOWN, RI_PRESENT)

local floorCount = 0
for _ in pairs(floors) do floorCount = floorCount + 1 end
log("Configured " .. floorCount .. " floors")

-- Main loop

driveDisconnect()

local D_UP = "up"
local D_DOWN = "down"

local lastKnownFloor = nil
local currentFloor = nil
local callingFloor = nil
local destinationFloor = nil
---@type "up" | "down" | nil
local direction = nil
local isMoving = false

local i_iter = 0;
local i_iter_limit = 100; -- number of loops to do before yielding to operating system

while (true)
do

    local i_callUpdated = false     -- updated per iteration
    local i_floorUpdated = false    -- updated per iteration

    -- Update state variables
    ---@type table<number, Floor>
    for k,v in pairs(floors) do

        if v:callingUp() then
            direction = D_UP
            callingFloor = k
            i_callUpdated = true
            log("UP called on floor " .. k)
        elseif v:callingDown() then
            direction = D_DOWN
            callingFloor = k
            i_callUpdated = true
            log("DOWN called on floor " .. k)
        end

        if v:isPresent() then
            currentFloor = k
            lastKnownFloor = currentFloor
            i_floorUpdated = true
        end

    end

    if i_floorUpdated == false then
        currentFloor = nil
    end

    local function setUp()
        driveUp()
        direction = D_UP
    end

    local function setDown()
        driveDown()
        direction = D_DOWN
    end

    local function go()
        driveConnect()
        isMoving = true
    end

    local function stop()
        driveDisconnect()
        isMoving = false
        callingFloor = nil
        direction = nil
        destinationFloor = nil
    end

    -- If position is unknown on startup, go to next highest floor
    if lastKnownFloor == nil and isMoving == false then
        log("Returning to next highest floor")
        setUp()
        go()
    else
        if i_callUpdated == true then
            if lastKnownFloor ~= nil then -- are we initialized?
                if lastKnownFloor > callingFloor then
                    destinationFloor = callingFloor
                    log(lastKnownFloor .. " --> " .. destinationFloor)
                    setDown()
                elseif lastKnownFloor < callingFloor then
                    destinationFloor = callingFloor
                    log(lastKnownFloor .. " --> " .. destinationFloor)
                    setUp()
                else
                    log("Called from current floor")
                    if direction == D_UP then
                        destinationFloor = lastKnownFloor + 1
                        log(lastKnownFloor .. " --> " .. destinationFloor)
                        setUp()
                    else
                        destinationFloor = lastKnownFloor - 1
                        log(lastKnownFloor .. " --> " .. destinationFloor)
                        setDown()
                    end
                end
                go()
            end
        elseif isMoving == true and currentFloor ~= nil then
            if destinationFloor == nil then
                log("Reached starting floor " .. currentFloor)
                stop()
            elseif currentFloor == destinationFloor then
                log("Reached destination " .. currentFloor)
                stop()
            end
        end
    end

    i_iter = i_iter + 1
    if (i_iter >= i_iter_limit) then
        i_iter = 0
        os.sleep(0.05)
    end

end
