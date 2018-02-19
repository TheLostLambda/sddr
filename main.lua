local util = require("src.util")
local water = require("src.puzzle.water")

function love.load()
  -- Asset Initialization
  pacifico_scaled = love.graphics.newFont("assets/fonts/Courgette-Regular.ttf", 80)
  amaranth_scaled = love.graphics.newFont("assets/fonts/Amaranth-Regular.ttf", 100)
  amaranth = love.graphics.newFont("assets/fonts/Amaranth-Regular.ttf", 30)
  love.graphics.setDefaultFilter("nearest") -- Put pixel art below this line.
  duckImageData = love.image.newImageData("assets/sprites/duck.png")
  duck = love.graphics.newImage(duckImageData)
  maxwell = love.graphics.newImage("assets/sprites/manatee.png")
  teal_duck = love.graphics.newImage("assets/sprites/teal_duck.png")
  quack = love.audio.newSource("assets/sounds/quack.wav", "static")
  quack:setVolume(0.5)
  waterSound = love.audio.newSource("assets/sounds/water.wav", "stream")
  waterSound:setVolume(0.5)
  main_theme = love.audio.newSource("assets/sounds/main_theme.wav", "stream")
  puzzle_theme = love.audio.newSource("assets/sounds/puzzle_theme.wav", "stream")

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

  -- Module Initialization
  water.init()
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
    intro7()
  elseif state == 8 then
    water.drawPuzzle()
  elseif state == 9 then
    water.fail()
  end
end

function love.update(dt)
  if state == 0 then
    elapsedTime = elapsedTime + dt
    duckAngle = math.sin(elapsedTime * 1.5) / 2.25
  end
  if state < 8 then
    love.audio.play(main_theme)
  end
  if state == 8 then
    love.audio.stop(main_theme)
    love.audio.play(puzzle_theme)
    water.runPuzzle(dt)
  end
  if state == 9 or state == 10 then
    love.audio.stop(waterSound)
    love.audio.stop(puzzle_theme)
  end
end

function love.mousepressed(x, y, button, isTouch)
  if state ~= 8 then
    love.audio.play(quack)
  end
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
  elseif state == 6 and util.choiceClick(x, y, 2) then
    state = 8
  elseif state == 7 and util.choiceClick(x, y, 1) then
    state = 8
  elseif state == 9 and util.choiceClick(x, y, 1) then
    water.init()
    state = 8
  elseif state == 8 and not water.isOn() then
    water.processClick(x,y)
  end
end

function love.keyreleased(key)
  if state == 0 then
    state = 1
  end
  if state == 8 and key == "space" then
    water.start()
  end
end

function love.resize()
  wx = love.graphics.getWidth()
  wy = love.graphics.getHeight()
  waterSX = wx / 800
  waterSY = wy / 600
end

function intro1()
  local msg = "Hiya Dennis! I'm Maxwell the manatee! I heard that you were a rubber duck collector of exquisite taste. Oh do I have a treat for you!"
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
  local msg = "To free the Teal duck, fill its tub all the way up with water! You are allowed to place a maximum of four stopppers. These stoppers can block a pipe and redirect the flow of water to free the duck!"
  util.dialog(msg, {"* How do I play?", "* Onwards!"})
end

function intro7()
  local msg = "To place a stopper, click on the empty space at the boundary of a tank and a pipe. To remove a stopper, click it a second time. Once you are ready to test your solution, press the spacebar."
  util.dialog(msg, {"* Onwards!"})
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
