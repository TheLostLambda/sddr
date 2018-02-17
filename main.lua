local util = require("src.util")
local water = require("src.puzzle.water")

function love.load()
  -- Asset Initialization
  pacifico_scaled = love.graphics.newFont("assets/fonts/Courgette-Regular.ttf", 80)
  amaranth_scaled = love.graphics.newFont("assets/fonts/Amaranth-Regular.ttf", 80)
  amaranth = love.graphics.newFont("assets/fonts/Amaranth-Regular.ttf", 30)
  love.graphics.setDefaultFilter("nearest") -- Put pixel art below this line.
  duckImageData = love.image.newImageData("assets/sprites/duck.png")
  duck = love.graphics.newImage(duckImageData)
  maxwell = love.graphics.newImage("assets/sprites/manatee.png")
  quack = love.audio.newSource("assets/sounds/quack.wav", "static")

  -- Window setup
  love.window.setMode(800, 600, {resizable=true, minwidth=800, minheight=600})
  love.window.setTitle("Sarah's Daring Duck Rescue!")
  love.window.setIcon(duckImageData)

  -- State Initialization
  wx = love.graphics.getWidth()
  wy = love.graphics.getHeight()
  duckAngle = -math.pi / 4
  elapsedTime = 0
  state = 0
  name = "Dennis"
end

function love.draw()
  if state == 0 then
    titleScreen()
  elseif state == 1 then
    intro1()
  elseif state == 2 then
    intro2()
  elseif state == 3 then
    intro3()
  elseif state == 4 then
    intro4()
  elseif state == 5 then
    intro5()
  elseif state == 6 then
    intro6()
  elseif state == 7 then
    waterPuzzle()
  end
end

function love.update(dt)
  if state == 0 then
    elapsedTime = elapsedTime + dt
    duckAngle = math.sin(elapsedTime * 1.5) / 2.25
  end
end

function love.mousepressed(x, y, button, isTouch)
  love.audio.play(quack)
end

function love.mousereleased(x, y, button, isTouch)
  if state == 0 then
    state = 1
  elseif state == 1 and util.choiceClick(x, y, 1) then
    state = 2
    name = "Sarah"
  elseif state == 1 and util.choiceClick(x, y, 2) then
    state = 3
  elseif state == 2 and util.choiceClick(x, y, 1) then
    state = 3
  elseif state == 3 and util.choiceClick(x, y, 1) then
    state = 4
  elseif state == 4 and util.choiceClick(x, y, 1) then
    state = 5
  elseif state == 4 and util.choiceClick(x, y, 2) then
    state = 6
  elseif state == 5 and util.choiceClick(x, y, 1) then
    state = 6
  elseif state == 6 and util.choiceClick(x, y, 1) then
    state = 7
  end
end

function love.keyreleased(key)
  if state == 0 then
    state = 1
  end
end

function love.resize()
  wx = love.graphics.getWidth()
  wy = love.graphics.getHeight()
end

function intro1()
  local msg = "Hiya Dennis! I'm Maxwell the manatee! I heard that you were rubber duck collector of exquisite taste. Oh do I have a treat for you!"
  util.dialog(msg, {"* I'm not Dennis...", "* And what may that be?"})
end

function intro2()
  local msg = "Oh no! I'm so sorry! I must have misheard your name! Sarah you said? Okay, I'll call you Sarah from now on!"
  util.dialog(msg, {"* So, about those ducks..."})
end

function intro3()
  local msg = "Exciting news indeed! The locals have recently reported seeing three different, legendary rubber ducks! There have also been rumors of a fourth, mystery duck of extraordinary rarity..."
  util.dialog(msg, {"* Where can I find these ducks?!"})
end

function intro4()
  local msg = "The first legendary duck, the Teal Duck, is locked away in the water temple. Unfortunately the duck is guarded by ancient duck magic so you'll have to solve a puzzle to free it!"
  util.dialog(msg, {"* Ancient duck magic?", "* Let's go free a duck!"})
end

function intro5()
  local msg = "Um.... Yes. It's magic cast by... Uh... Ancient ducks. Duh... (Brooks is still finalizing his \"Harry Duck\" / \"Rubber Potter\" fan-fiction. It's like Harry Potter, but with rubber ducks)"
  util.dialog(msg, {"* Neat."})
end

function intro6()
  local msg = "To free the Teal duck, fill its tub all the way up with water! You are allowed to place three stopppers. These stoppers can block a pipe and redirect the flow of water to free the duck!"
  util.dialog(msg, {"* Let's do this."})
end

function waterPuzzle()
  tank = {x=(wx * 0.7), y=(wy * 0.1), w=(wx * 0.15), h=(wy * 0.25)}
  water.drawTank(tank)
end

function titleScreen()
  love.graphics.setBackgroundColor(0, 205, 210)
  local titleText = love.graphics.newText(pacifico_scaled, "Sarah's Daring Duck Rescue!")
  love.graphics.draw(titleText, (wx * 0.05), (wy * 0.05), 0, (wx * 0.9) / titleText:getWidth())
  local duckScale = (wx * 0.2) / duck:getWidth()
  love.graphics.draw(duck, (wx * 0.5), (wy * 0.5), duckAngle, duckScale, duckScale, duck:getWidth() / 2, duck:getHeight() / 2)
  local startText = love.graphics.newText(amaranth_scaled, "Press any button to play!")
  love.graphics.draw(startText, (wx * 0.2), (wy * 0.75), 0, (wx * 0.6) / startText:getWidth())
end
