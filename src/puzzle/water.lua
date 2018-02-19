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
lightWaterColor = {70, 80, 115}
backgroundColor = {75, 75, 75}
offColor = {160,30,0}
tankThickness = 5
waterRate = 2500
openingWidth = 20
maxStoppers = 4

waterSX = nil
waterSY = nil

local puzzle = nil
local waterOn = nil
local usedStoppers = nil

function Water.start()
  if not waterOn then
    waterOn = true
  end
end

function Water.isOn()
  return waterOn
end

function Water.init()
  waterOn = false
  usedStoppers = 0
  waterSX = wx / 800
  waterSY = wy / 600
  puzzle = {
    IN = {x=600, y=-5, w=openingWidth, h=25, lid=true, opns={{side="B", pos=0.5, open=true, link="A"}}, v=0},
    A = {x=570, y=30, w=80, h=60, lid=false, opns={{side="B", pos=0.5, open=true, link="P1"}, {side="L", pos=0.8, open=true, link="P4"}}, v=0},
    P1 = {x=600, y=90, w=openingWidth, h=48, lid=true, opns={{side="T", pos=0.5, open=true, link="A"}, {side="B", pos=0.5, open=true, link="B"}}, v=0},
    B = {x=570, y=115, w=80, h=60, lid=false, opns={{side="T", pos=0.5, open=true, link="P1"}, {side="R", pos=0.2, open=true, link="P2"}}, v=0},
    P2 = {x=650, y=123, w=100, h=openingWidth, lid=true, opns={{side="L", pos=0.5, open=true, link="B"}, {side="B", pos=1.0, open=true, link="P3"}}, v=0},
    P3 = {x=730, y=143, w=openingWidth, h=32, lid=true, opns={{side="T", pos=0.5, open=true, link="P2"}, {side="B", pos=0.5, open=true, link="C"}}, v=0},
    C = {x=710, y=175, w=60, h=60, lid=true, opns={{side="T", pos=0.5, open=true, link="P3"}}, v=0},
    D = {x=400, y=100, w=80, h=60, lid=false, opns={{side="R", pos=0.2, open=true, link="P6"}, {side="L", pos=0.8, open=true, link="P9"}, {side="B", pos=0.5, open=true, link="P7"}}, v=0},
    P4 = {x=535, y=62, w=35, h=openingWidth, lid=true, opns={{side="L", pos=0.5, open=true, link="P5"}, {side="R", pos=0.5, open=true, link="A"}}, v=0},
    P5 = {x=515, y=62, w=openingWidth, h=66, lid=true, opns={{side="R", pos=0.0, open=true, link="P4"}, {side="L", pos=1.0, open=true, link="P6"}}, v=0},
    P6 = {x=480, y=108, w=35, h=openingWidth, lid=true, opns={{side="L", pos=0.5, open=true, link="D"}, {side="R", pos=0.5, open=true, link="P5"}}, v=0},
    F = {x=230, y=100, w=80, h=60, lid=false, opns={{side="R", pos=0.2, open=true, link="P11"}, {side="B", pos=0.5, open=true, link="P12"}}, v=0},
    P9 = {x=365, y=132, w=35, h=openingWidth, lid=true, opns={{side="L", pos=0.5, open=true, link="P10"}, {side="R", pos=0.5, open=true, link="D"}}, v=0},
    P10 = {x=345, y=108, w=openingWidth, h=44, lid=true, opns={{side="R", pos=1.0, open=true, link="P9"}, {side="L", pos=0.0, open=true, link="P11"}}, v=0},
    P11 = {x=310, y=108, w=35, h=openingWidth, lid=true, opns={{side="L", pos=0.5, open=true, link="F"}, {side="R", pos=0.5, open=true, link="P10"}}, v=0},
    P7 = {x=430, y=160, w=openingWidth, h=65, lid=true, opns={{side="T", pos=0.5, open=true, link="D"}, {side="B", pos=0.5, open=true, link="P8"}}, v=0},
    P8 = {x=430, y=225, w=35, h=openingWidth, lid=true, opns={{side="T", pos=0.0, open=true, link="P7"}}, v=0},
    E = {x=465, y=195, w=60, h=80, lid=false, opns={{side="B", pos=0.5, open=true, link="P16"}}, v=0},
    P17 = {x=525, y=203, w=125, h=openingWidth, lid=true, opns={{side="B", pos=1.0, open=true, link="P18"}}, v=0},
    P18 = {x=630, y=223, w=openingWidth, h=150, lid=true, opns={{side="T", pos=0.5, open=true, link="P17"}, {side="B", pos=0.5, open=true, link="P18"}}, v=0},
    G = {x=230, y=215, w=80, h=80, lid=true, opns={{side="R", pos=0.5, open=true, link="P13"}, {side="T", pos=0.5, open=true, link="P12"}, {side="B", pos=0.5, open=true, link="P19"}}, v=0},
    P12 = {x=260, y=160, w=openingWidth, h=55, lid=true, opns={{side="T", pos=0.5, open=true, link="F"}, {side="B", pos=0.5, open=true, link="G"}}, v=0},
    P13 = {x=310, y=245, w=90, h=openingWidth, lid=true, opns={{side="L", pos=0.5, open=true, link="G"}, {side="B", pos=1.0, open=true, link="P14"}}, v=0},
    P14 = {x=380, y=265, w=openingWidth, h=75, lid=true, opns={{side="T", pos=0.5, open=true, link="P13"}, {side="R", pos=1.0, open=true, link="P15"}}, v=0},
    P15 = {x=400, y=320, w=105, h=openingWidth, lid=true, opns={{side="L", pos=0.5, open=true, link="P14"}, {side="T", pos=1.0, open=true, link="P16"}}, v=0},
    P16 = {x=485, y=275, w=openingWidth, h=45, lid=true, opns={{side="T", pos=0.5, open=true, link="E"}, {side="B", pos=1.0, open=true, link="P15"}}, v=0},
    P19 = {x=260, y=295, w=openingWidth, h=50, lid=true, opns={{side="T", pos=0.5, open=true, link="G"}, {side="L", pos=1.0, open=true, link="P20"}}, v=0},
    P20 = {x=175, y=325, w=85, h=openingWidth, lid=true, opns={{side="L", pos=0.5, open=true, link="P21"}, {side="R", pos=0.5, open=true, link="P19"}}, v=0},
    P21 = {x=155, y=160, w=openingWidth, h=185, lid=true, opns={{side="L", pos=0.0, open=true, link="P22"}, {side="R", pos=1.0, open=true, link="P20"}}, v=0},
    P22 = {x=114, y=160, w=41, h=openingWidth, lid=true, opns={{side="L", pos=0.5, open=true, link="H"}, {side="R", pos=0.5, open=true, link="P21"}}, v=0},
    H = {x=30, y=144, w=84, h=100, lid=false, opns={{side="R", pos=0.2, open=true, link="P22"}, {side="B", pos=0.5, open=true, link="P23"}}, v=0},
    P23 = {x=62, y=244, w=openingWidth, h=235, lid=true, opns={{side="T", pos=0.0, open=true, link="H"}, {side="R", pos=1.0, open=true, link="P24"}}, v=0},
    P24 = {x=82, y=459, w=73, h=openingWidth, lid=true, opns={{side="L", pos=0.5, open=true, link="P23"}, {side="R", pos=0.5, open=true, link="P25"}}, v=0},
    P25 = {x=155, y=394, w=openingWidth, h=182.5, lid=true, opns={{side="L", pos=0.4, open=true, link="P24"}, {side="R", pos=1.0, open=true, link="P27"}, {side="R", pos=0.0, open=true, link="P26"}}, v=0},
    P26 = {x=175, y=394, w=25, h=openingWidth, lid=true, opns={{side="L", pos=0.5, open=true, link="P25"}}, v=0},
    P27 = {x=175, y=556.5, w=75, h=openingWidth, lid=true, opns={{side="L", pos=0.5, open=true, link="P25"}, {side="T", pos=1.0, open=true, link="P28"}}, v=0},
    I = {x=200, y=386, w=80, h=60, lid=false, opns={{side="R", pos=1.0, open=true, link="P33"}, {side="B", pos=0.5, open=true, link="P32"}}, v=0},
    P32 = {x=230, y=446, w=openingWidth, h=35.25, lid=true, opns={{side="T", pos=0.5, open=true, link="I"}, {side="B", pos=0.5, open=true, link="J"}}, v=0},
    J = {x=220, y=481.25, w=40, h=40, lid=true, opns={{side="T", pos=0.5, open=true, link="P32"}, {side="R", pos=0.5, open=true, link="P29"}, {side="B", pos=0.5, open=true, link="P28"}}, v=0},
    P28 = {x=230, y=521.25, w=openingWidth, h=35.25, lid=true, opns={{side="T", pos=0.5, open=true, link="J"}, {side="B", pos=0.5, open=true, link="P27"}}, v=0},
    P29 = {x=260, y=491.25, w=85, h=openingWidth, lid=true, opns={{side="L", pos=0.5, open=true, link="J"}, {side="R", pos=0.5, open=true, link="K"}}, v=0},
    P33 = {x=280, y=426, w=225, h=openingWidth, lid=true, opns={{side="L", pos=0.5, open=true, link="I"}, {side="R", pos=0.5, open=true, link="L"}}, v=0},
    L = {x=505, y=414, w=186.75, h=80, lid=false, opns={{side="T", pos=0.75, open=true, link="P18"}, {side="L", pos=0.2, open=true, link="P33"}, {side="B", pos=0.2, open=true, link="P31"}}, v=0},
    K = {x=345, y=471.25, w=122.5, h=100, lid=false, opns={{side="L", pos=0.25, open=true, link="P29"}, {side="R", pos=0.8, open=true, link="P30"}}, v=0},
    P30 = {x=467.5, y=535.25, w=70.75, h=openingWidth, lid=true, opns={{side="L", pos=0.5, open=true, link="K"}, {side="R", pos=0.5, open=true, link="P31"}}, v=0},
    P31 = {x=538.25, y=494, w=openingWidth, h=61.25, lid=true, opns={{side="T", pos=0.5, open=true, link="L"}, {side="L", pos=1.0, open=true, link="P30"}}, v=0},
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
  if depth > 6 then
    return nil
  end
  if link.y + link.h - waterLevel(link) > tank.y + tank.h - waterLevel(tank) and tank.v > 0 and not isFull(link) then
    tank.v = tank.v - waterRate * dt
    if(tank.v <= 0) then
      tank.v = 1
    end
    if(link.v <= 0) then
      link.v = 1
    end
    link.v = link.v + waterRate * dt
  elseif link.y + link.h - waterLevel(link) > tank.y + tank.h - waterLevel(tank) and tank.v > 0 then
    for id,link2 in pairs(activeOutlets(link)) do
      flow(tank, puzzle[link2], depth + 1, dt)
    end
  end
end

function Water.runPuzzle(dt)
  if waterOn then
    puzzle.IN.v = puzzle.IN.v + waterRate * dt
    if love.audio.getSourceCount() < 1 then
      love.audio.play(waterSound)
    end
  end
  for id,tank in pairs(puzzle) do
    if tank.v / tank.w > tank.h and not tank.lid then
      if id == "L" then
        state = 10
      else
        state = 9
      end
    end
    for id,link in pairs(activeOutlets(tank)) do
      flow(tank, puzzle[link], 0, dt)
    end
  end
end

local function openingStencil(tank)
  for _,opn in pairs(tank.opns) do
    if opn.open then
      love.graphics.setColor(255, 255, 255, 0)
    else
      love.graphics.setColor(offColor)
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

local function drawTank1(tank)
  love.graphics.push()
  love.graphics.scale(waterSX, waterSY)
  love.graphics.setColor(lightWaterColor)
  if tank.v > 0 then
    love.graphics.rectangle("fill", tank.x, tank.y, tank.w + tankThickness, tank.h + tankThickness)
  end
  love.graphics.pop()
end

local function drawTank2(tank)
  love.graphics.push()
  love.graphics.scale(waterSX, waterSY)
  love.graphics.setColor(waterColor)
  if waterLevel(tank) < tank.h and tank.v > 50 then
    love.graphics.rectangle("fill", tank.x, tank.y + tank.h, tank.w + tankThickness, -waterLevel(tank))
  elseif tank.v > 50 then
    love.graphics.rectangle("fill", tank.x, tank.y + tank.h, tank.w + tankThickness, -tank.h)
  end
  love.graphics.pop()
end

local function drawTank3(tank)
  love.graphics.push()
  love.graphics.scale(waterSX, waterSY)
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

function Water.drawPuzzle()
  love.graphics.setBackgroundColor(backgroundColor)
  local startText = nil
  love.graphics.setColor(0, 205, 210)
  if waterOn then
    startText = love.graphics.newText(amaranth_scaled, "Running puzzle...")
  else
    startText = love.graphics.newText(amaranth_scaled, "Press the spacebar to run!")
  end
  love.graphics.draw(startText, (wx * 0.025), (wy * 0.025), 0, (wy * 0.08) / startText:getHeight())
  for id,tank in pairs(puzzle) do
      drawTank1(tank)
  end
  for id,tank in pairs(puzzle) do
      drawTank2(tank)
  end
  for id,tank in pairs(puzzle) do
      drawTank3(tank)
  end
  love.graphics.push()
  love.graphics.scale(waterSX, waterSY)
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(teal_duck, 602.25, 494 - teal_duck:getHeight() * 2 - waterLevel(puzzle.L), 0, -2, 2)
  love.graphics.pop()
end

local function inOpening(x,y,tank,opn)
  if opn.side == "T" then
    return util.pointWithin(x, y, tank.x + ((tank.w - openingWidth) * opn.pos) + tankThickness, tank.y, openingWidth - tankThickness, tankThickness)
  elseif opn.side == "B" then
    return util.pointWithin(x, y, tank.x + ((tank.w - openingWidth) * opn.pos) + tankThickness, tank.y + tank.h, openingWidth - tankThickness, tankThickness)
  elseif opn.side == "L" then
    return util.pointWithin(x, y, tank.x, tank.y + ((tank.h - openingWidth) * opn.pos) + tankThickness, tankThickness, openingWidth - tankThickness)
  elseif opn.side == "R" then
    return util.pointWithin(x, y, tank.x + tank.w, tank.y + ((tank.h - openingWidth) * opn.pos) + tankThickness, tankThickness, openingWidth - tankThickness)
  end
end

function Water.processClick(x,y)
  x = x / waterSX
  y = y / waterSY
  local addedStopper = false
  local removedStopper = false
  for id,tank in pairs(puzzle) do
    for _,opn in ipairs(tank.opns) do
      if inOpening(x,y,tank,opn) then
        if opn.open and usedStoppers < maxStoppers then
          opn.open = false
          addedStopper = true
        elseif not opn.open then
          opn.open = true
          removedStopper = true
        end
      end
    end
  end
  if addedStopper then
    usedStoppers = usedStoppers + 1
  end
  if removedStopper then
    usedStoppers = usedStoppers - 1
  end
end

function Water.fail()
  Water.drawPuzzle()
  love.graphics.setColor(0, 0, 0, 128)
  love.graphics.rectangle("fill", 0, 0, wx, wy)
  love.graphics.setColor(255, 255, 255)
  local msg = "Oh no! You were close, but the water didn't fill the Teal Duck's tub first! You've got this " .. name .. "! Give it another go?"
  util.dialog(msg, {"* Try again."})
end

return Water
