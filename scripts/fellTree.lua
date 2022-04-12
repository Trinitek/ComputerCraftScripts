
-- Expected starting position is 1 block away from bottom left corner of 2x2 spruce.

---@type integer
local height = 0

-- Just in case leaves generated right in front of the turtle
turtle.dig()
turtle.suck()

turtle.forward()
turtle.dig()
turtle.suck()
turtle.forward()

repeat
    turtle.dig()
    turtle.suck()
    turtle.forward()

    turtle.turnRight()

    turtle.dig()
    turtle.suck()
    turtle.forward()

    turtle.turnRight()

    turtle.dig()
    turtle.suck()
    turtle.forward()

    turtle.turnRight()
    
    turtle.forward()
    
    turtle.turnRight()

    local hasBlockAbove = turtle.digUp()

    if hasBlockAbove then
        turtle.suck()
        turtle.up()
        height = height + 1
    end
until not hasBlockAbove

for i = height, 1, -1 do
    turtle.down()
    turtle.back()
    turtle.back()
end

print("Height " .. height)
