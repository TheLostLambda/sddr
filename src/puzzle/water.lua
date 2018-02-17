local Water = {}

--[[
  A tank is a table that stores the following infomation:
  id: A unique name for this tank
  x & y: The coordinates of the tank (measured from the top-left of the tank).
  w & h: Interior width and height of the tank.
  lid: A boolean value that indicates if this tank has a lid or not.
  openings: A list of tables. Each table stores the side of the tank that the
    opening is on and a number from 0 to 1 that dictates its postition on that
    side of the tank (relative to the side length). Also stores a boolean that
    dictates whether or not the opening is blocked.
  volume: This keeps track of how much water is in this tank.

  A pipe is a table that stores the following information:
  id: A unique name for this pipe
  ends: This is an array of the id's of the objects being connected
]]

-- Constants
tankColor = {100,100,100}

function Water.drawTank(tank)
  r,g,b,a = love.graphics.getColor()
  love.graphics.setColor(tankColor)
  love.graphics.rectangle("fill", tank.x, tank.y, tank.w, tank.h)
  love.graphics.setColor(r,g,b,a)
end

return Water
