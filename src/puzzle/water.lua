local Water = {}

local util = require("src.util")

--[[
  A tank is a table that stores the following infomation:
  id: A unique name for this tank
  x & y: The coordinates of the tank (measured from the top-left of the tank).
  w & h: Interior width and height of the tank.
  lid: A boolean value that indicates if this tank has a lid or not.
  openings: A list of tables. Each table stores the side of the tank that the
    opening is on and a number from 0 to 1 that dictates its postition on that
    side of the tank (relative to the side length). Also stores a boolean that
    dictates whether or not the opening is blocked and the id of the tank it
    leads to.
  volume: This keeps track of how much water is in this tank.
]]

-- Constants
tankColor = {200,200,200}
waterColor = {30, 50, 180}
backgroundColor = {75, 75, 75}
waterRate = nil
tankThickness = nil
openingWidth = nil

local puzzle = nil

function Water.init()
  tankThickness = wx * 0.003
  waterRate = wx * wy * 0.001
  openingWidth = wx * 0.01
  puzzle = {
    {id="A", x=(wx * 0.725), y=(wy * 0.05), w=(wx * 0.1), h=(wy * 0.1), lid=false, opns={{side="B", pos=0.5, open=true}}, v=0},
    {id="1", x=(wx * 0.771), y=(wy * 0.15), w=openingWidth, h=(wy * 0.05), lid=true, opns={{side="T", pos=0.5, open=true}, {side="B", pos=0.5, open=true}}, v=0},
    {id="B", x=(wx * 0.725), y=(wy * 0.2), w=(wx * 0.1), h=(wy * 0.1), lid=false, opns={}, v=0},
    {id="C", x=(wx * 0.9), y=(wy * 0.275), w=(wx * 0.075), h=(wy * 0.075), lid=true, opns={}, v=0},
    {id="D", x=(wx * 0.550), y=(wy * 0.175), w=(wx * 0.1), h=(wy * 0.1), lid=false, opns={}, v=0},
    {id="F", x=(wx * 0.375), y=(wy * 0.175), w=(wx * 0.1), h=(wy * 0.1), lid=false, opns={}, v=0}
  }
end

function Water.runPuzzle(dt)
  puzzle[1].v = puzzle[1].v + waterRate * dt
  for id,tank in pairs(puzzle) do
    if tank.v / tank.w > tank.h then
      Water.drawTank(tank)
      state = 8
    end
  end
end

function Water.drawPuzzle()
  love.graphics.setBackgroundColor(backgroundColor)
  for _,tank in ipairs(puzzle) do
      Water.drawTank(tank)
  end
end

function Water.drawTank(tank)
  love.graphics.setColor(tankColor)
  love.graphics.rectangle("fill", tank.x, tank.y, tankThickness, tank.h)
  love.graphics.rectangle("fill", tank.x, tank.y + tank.h, tank.w + tankThickness, tankThickness)
  love.graphics.rectangle("fill", tank.x + tank.w, tank.y, tankThickness, tank.h)
  if tank.lid then
    love.graphics.rectangle("fill", tank.x, tank.y, tank.w + tankThickness, tankThickness)
  end
  love.graphics.setColor(waterColor)
  love.graphics.rectangle("fill", tank.x + tankThickness, tank.y + tank.h - tank.v / tank.w, tank.w - tankThickness, tank.v / tank.w)
  love.graphics.setColor(backgroundColor)
  for _,opn in ipairs(tank.opns) do
    if opn.side == "T" then
      love.graphics.rectangle("fill", tank.x + (tank.w * opn.pos) - openingWidth / 2 + tankThickness, tank.y, openingWidth - tankThickness, tankThickness)
    elseif opn.side == "B" then
      love.graphics.rectangle("fill", tank.x + (tank.w * opn.pos) - openingWidth / 2 + tankThickness, tank.y + tank.h, openingWidth - tankThickness, tankThickness)
    end
  end
end

function Water.fail()
  Water.drawPuzzle()
  love.graphics.setColor(0, 0, 0, 128)
  love.graphics.rectangle("fill", 0, 0, wx, wy)
  love.graphics.setColor(255, 255, 255)
  local msg = "Oh no! You were close, but the water didn't fill the Teal Duck's tub first! You've got this! Give it another go?"
  util.dialog(msg, {"* Try again."})
end

return Water
