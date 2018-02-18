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
tankThickness = 5
waterRate = 500
openingWidth = 20

waterSX = nil
waterSY = nil

local puzzle = nil

function Water.init()
  waterSX = wx / 800
  waterSY = wy / 600
  puzzle = {
    A = {x=570, y=30, w=80, h=60, lid=false, opns={{side="B", pos=0.5, open=true, link="P1"}, {side="L", pos=0.8, open=true, link="P4"}}, v=0},
    P1 = {x=600, y=90, w=openingWidth, h=25, lid=true, opns={{side="T", pos=0.5, open=true, link="A"}, {side="B", pos=0.5, open=false, link="B"}}, v=0},
    B = {x=570, y=115, w=80, h=60, lid=false, opns={{side="T", pos=0.5, open=true, link="P1"}, {side="R", pos=0.2, open=true, link="P2"}}, v=0},
    P2 = {x=650, y=123, w=100, h=openingWidth, lid=true, opns={{side="L", pos=0.5, open=true, link="B"}, {side="B", pos=1.0, open=true, link="P3"}}, v=0},
    P3 = {x=730, y=143, w=openingWidth, h=32, lid=true, opns={{side="T", pos=0.5, open=true, link="P2"}, {side="B", pos=0.5, open=true, link="C"}}, v=0},
    C = {x=710, y=175, w=60, h=60, lid=true, opns={{side="T", pos=0.5, open=true, link="P3"}}, v=0},
    D = {x=400, y=100, w=80, h=60, lid=false, opns={{side="R", pos=0.2, open=true, link="P6"}, {side="L", pos=0.8, open=true, link="P9"}, {side="B", pos=0.5, open=true, link="P7"}}, v=0},
    P4 = {x=535, y=62, w=35, h=openingWidth, lid=true, opns={{side="L", pos=0.5, open=true, link="P5"}, {side="R", pos=0.5, open=true, link="A"}}, v=0},
    P5 = {x=515, y=62, w=openingWidth, h=66, lid=true, opns={{side="R", pos=0.0, open=true, link="P4"}, {side="L", pos=1.0, open=true, link="P6"}}, v=0},
    P6 = {x=480, y=108, w=35, h=openingWidth, lid=true, opns={{side="L", pos=0.5, open=true, link="D"}, {side="R", pos=0.5, open=true, link="P5"}}, v=0},
    F = {x=230, y=100, w=80, h=60, lid=false, opns={{side="R", pos=0.2, open=true, link="P11"}}, v=0},
    P9 = {x=365, y=132, w=35, h=openingWidth, lid=true, opns={{side="L", pos=0.5, open=true, link="P10"}, {side="R", pos=0.5, open=true, link="D"}}, v=0},
    P10 = {x=345, y=108, w=openingWidth, h=44, lid=true, opns={{side="R", pos=1.0, open=true, link="P9"}, {side="L", pos=0.0, open=true, link="P11"}}, v=0},
    P11 = {x=310, y=108, w=35, h=openingWidth, lid=true, opns={{side="L", pos=0.5, open=true, link="F"}, {side="R", pos=0.5, open=true, link="P10"}}, v=0},
    P7 = {x=430, y=160, w=openingWidth, h=65, lid=true, opns={{side="T", pos=0.5, open=true, link="D"}, {side="B", pos=0.5, open=true, link="P8"}}, v=0},
    P8 = {x=430, y=225, w=35, h=openingWidth, lid=true, opns={{side="T", pos=0.0, open=true, link="P7"}}, v=0},
    E = {x=465, y=195, w=60, h=80, lid=false, opns={}, v=0}
  }
end

local function waterLevel(tank)
  return tank.v / tank.w
end

local function isFull(tank)
  return waterLevel(tank) > tank.h and tank.lid
end

local function activeOutlets(tank)
  active = {}
  for _,opn in pairs(tank.opns) do
    if opn.open and tank.v > 0 then
      if opn.side == "B" then
        table.insert(active,opn.link)
      elseif opn.side == "T" and tank.lid and waterLevel(tank) >= tank.h - tankThickness then
        table.insert(active,opn.link)
      elseif (opn.side == "R" or opn.side == "L") and waterLevel(tank) > (tank.h - openingWidth) * (1 - opn.pos) then
        table.insert(active,opn.link)
      end
    end
  end
  return active
end

local function flow(tank, link, depth, dt)
  if depth > 20 then
    return nil
  end
  if link.y + link.h - waterLevel(link) > tank.y + tank.h - waterLevel(tank) and tank.v > 0 and not isFull(link) then
    tank.v = tank.v - waterRate * dt
    link.v = link.v + waterRate * dt
  elseif link.y + link.h - waterLevel(link) > tank.y + tank.h - waterLevel(tank) and tank.v > 0 then
    for id,link2 in pairs(activeOutlets(link)) do
      flow(tank, puzzle[link2], depth + 1, dt)
    end
  end
end

function Water.runPuzzle(dt)
  puzzle.A.v = puzzle.A.v + waterRate * dt
  for id,tank in pairs(puzzle) do
    if tank.v / tank.w > tank.h and not tank.lid then
      Water.drawTank(tank)
      state = 8
    end
    for id,link in pairs(activeOutlets(tank)) do
      flow(tank, puzzle[link], 0, dt)
    end
  end
end

function Water.drawPuzzle()
  love.graphics.setBackgroundColor(backgroundColor)
  for id,tank in pairs(puzzle) do
      Water.drawTank(tank)
  end
end

local function openingStencil(tank)
  for _,opn in pairs(tank.opns) do
    if opn.open then
      love.graphics.setColor(255, 255, 255, 0)
    else
      love.graphics.setColor(255, 0, 0)
    end
    if opn.side == "T" then
      love.graphics.rectangle("fill", tank.x + ((tank.w - openingWidth) * opn.pos) + tankThickness, tank.y, openingWidth - tankThickness, tankThickness)
    elseif opn.side == "B" then
      love.graphics.rectangle("fill", tank.x + ((tank.w - openingWidth) * opn.pos) + tankThickness, tank.y + tank.h, openingWidth - tankThickness, tankThickness)
    elseif opn.side == "L" then
      love.graphics.rectangle("fill", tank.x, tank.y + ((tank.h - openingWidth) * opn.pos) + tankThickness, tankThickness, openingWidth - tankThickness)
    elseif opn.side == "R" then
      love.graphics.rectangle("fill", tank.x + tank.w, tank.y + ((tank.h - openingWidth) * opn.pos) + tankThickness, tankThickness, openingWidth - tankThickness)
    end
  end
end

function Water.drawTank(tank)
  love.graphics.push()
  love.graphics.scale(waterSX, waterSY)
  love.graphics.setColor(waterColor)
  if waterLevel(tank) < tank.h then
    love.graphics.rectangle("fill", tank.x, tank.y + tank.h, tank.w + tankThickness, -waterLevel(tank))
  else
    love.graphics.rectangle("fill", tank.x, tank.y + tank.h, tank.w + tankThickness, -tank.h)
  end
  local function wrapStencil()
    openingStencil(tank)
  end
  love.graphics.stencil(wrapStencil, "replace", 1)
  love.graphics.setStencilTest("equal", 0)
  love.graphics.setColor(tankColor)
  love.graphics.rectangle("fill", tank.x, tank.y, tankThickness, tank.h)
  love.graphics.rectangle("fill", tank.x, tank.y + tank.h, tank.w + tankThickness, tankThickness)
  love.graphics.rectangle("fill", tank.x + tank.w, tank.y, tankThickness, tank.h)
  if tank.lid then
    love.graphics.rectangle("fill", tank.x, tank.y, tank.w + tankThickness, tankThickness)
  end
  love.graphics.setStencilTest("gequal", 0)
  openingStencil(tank)
  love.graphics.pop()
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
