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

local function connectY(y, h, r)
  return y + ((h - openingWidth + tankThickness) * r) - tankThickness
end

function Water.init()
  tankThickness = wx * 0.004
  waterRate = wx * wy * 0.003
  openingWidth = wx * 0.01
  puzzle = {
    A = {x=(wx * 0.725), y=(wy * 0.05), w=(wx * 0.1), h=(wy * 0.1), lid=false, opns={{side="B", pos=0.5, open=true, link="P1"}, {side="L", pos=0.8, open=true, link="P4"}}, v=0},
    P1 = {x=(wx * 0.770), y=(wy * 0.15), w=openingWidth, h=(wy * 0.04), lid=true, opns={{side="T", pos=0.5, open=true, link="A"}, {side="B", pos=0.5, open=true, link="B"}}, v=0},
    B = {x=(wx * 0.725), y=(wy * 0.2), w=(wx * 0.1), h=(wy * 0.1), lid=false, opns={{side="R", pos=0.2, open=true, link="P2"}}, v=0},
    P2 = {x=(wx * 0.825), y=connectY((wy * 0.2),(wy * 0.1),0.2), w=(wx * 0.1125) + tankThickness, h=openingWidth, lid=true, opns={{side="L", pos=1.0, open=true, link="B"}, {side="B", pos=1.0, open=true, link="C"}}, v=0},
    P3 = {x=(wx * 0.9375) - tankThickness, y=connectY((wy * 0.2),(wy * 0.1),0.2) + tankThickness + openingWidth, w=openingWidth, h=(wy * 0.04), lid=true, opns={{side="T", pos=0.5, open=true, link="P2"}, {side="B", pos=0.5, open=true, link="C"}}, v=0},
    C = {x=(wx * 0.900), y=(wy * 0.275), w=(wx * 0.075), h=(wy * 0.075), lid=true, opns={{side="T", pos=0.5, open=true, link="P3"}}, v=0},
    D = {x=(wx * 0.550), y=(wy * 0.175), w=(wx * 0.1), h=(wy * 0.1), lid=false, opns={}, v=0},
    F = {x=(wx * 0.375), y=(wy * 0.175), w=(wx * 0.1), h=(wy * 0.1), lid=false, opns={}, v=0}
  }
end

local function waterLevel(tank)
  return tank.v / tank.w
end

local function isFull(tank)
  if tank.lid then
    return waterLevel(tank) < tank.h - tankThickness
  else
    return waterLevel(tank) < tank.h
  end
end

local function activeOutlets(tank)
  active = {}
  for _,opn in pairs(tank.opns) do
    if opn.side == "B" then
      table.insert(active,opn.link)
    elseif opn.side == "T" and tank.lid and waterLevel(tank) > tank.h - tankThickness then
      table.insert(active,opn.link)
    elseif (opn.side == "R" or opn.side == "L") and waterLevel(tank) > tank.h * (1 - opn.pos) - openingWidth / 2 then
      table.insert(active,opn.link)
    end
  end
  return active
end

function Water.runPuzzle(dt)
  puzzle.A.v = puzzle.A.v + waterRate * dt
  for id,tank in pairs(puzzle) do
    if tank.v / tank.w > tank.h and not tank.lid then
      Water.drawTank(tank)
      state = 8
    end
    for id,link in pairs(activeOutlets(tank)) do
      if puzzle[link].y - waterLevel(puzzle[link]) > tank.y - waterLevel(tank) and tank.v > 0 and isFull(puzzle[link]) then
        tank.v = tank.v - waterRate * dt
        puzzle[link].v = puzzle[link].v + waterRate * dt
      end
    end
  end
end

function Water.drawPuzzle()
  love.graphics.setBackgroundColor(backgroundColor)
  for id,tank in pairs(puzzle) do
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
  for _,opn in pairs(tank.opns) do
    if opn.open then
      love.graphics.setColor(backgroundColor)
      --[[if util.containsValue(activeOutlets(tank),opn.link) and tank.v > 0 then
        love.graphics.setColor(waterColor)
      end--]]
    else
      love.graphics.setColor(tankColor)
    end
    if opn.side == "T" then
      love.graphics.rectangle("fill", tank.x + ((tank.w - openingWidth) * opn.pos) + tankThickness, tank.y, openingWidth - tankThickness, tankThickness)
    elseif opn.side == "B" then
      love.graphics.rectangle("fill", tank.x + ((tank.w - openingWidth) * opn.pos) + tankThickness, tank.y + tank.h, openingWidth - tankThickness, tankThickness)
    elseif opn.side == "L" then
      love.graphics.rectangle("fill", tank.x, tank.y + ((tank.h - openingWidth + tankThickness) * opn.pos), tankThickness, openingWidth - tankThickness)
    elseif opn.side == "R" then
      love.graphics.rectangle("fill", tank.x + tank.w, tank.y + ((tank.h - openingWidth + tankThickness) * opn.pos), tankThickness, openingWidth - tankThickness)
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
