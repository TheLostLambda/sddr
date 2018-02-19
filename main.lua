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
  fanfare = love.audio.newSource("assets/sounds/fanfare.wav", "stream")

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
  elseif state == 10 then
    water.success()
  elseif state == 11 then
    duckReveal()
  elseif state == 12 then
    duckUnlock()
  elseif state == 13 then
    outro1()
  elseif state == 14 then
    outro2()
  elseif state == 15 then
    outro3()
  elseif state == 16 then
    outro4()
  elseif state == 17 then
    finale1()
  elseif state == 18 then
    finale2()
  end
end

function love.update(dt)
  if state == 0 or state == 12 then
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
    elapsedTime = 0
  end
  if state == 11 then
    duckAngle = 0
    elapsedTime = elapsedTime + dt
    fadedDuckScale = (((wx * 0.2) / duck:getWidth()) / fanfare:getDuration()) * elapsedTime
    if elapsedTime > fanfare:getDuration() then
      state = 12
      elapsedTime = 0
    end
    love.audio.stop(puzzle_theme)
    love.audio.play(fanfare)
  end
  if state == 12 then
    love.audio.stop(fanfare)
  end
  if state > 11 and state < 18 then
    love.audio.play(main_theme)
  end
  if state == 17 or state == 18 then
    elapsedTime = elapsedTime + dt
    finaleAlpha = elapsedTime * (255 / 2)
    if finaleAlpha > 255 and state ~= 18 then
      state = 18
      elapsedTime = 0
      finaleAlpha = 0
    end
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
  elseif state == 10 and util.choiceClick(x, y, 1) then
    state = 11
  elseif state == 12 then
    state = 13
  elseif state == 13 and util.choiceClick(x, y, 1) then
    state = 14
  elseif state == 14 and util.choiceClick(x, y, 1) then
    state = 15
  elseif state == 14 and util.choiceClick(x, y, 2) then
    state = 16
  elseif state == 15 and util.choiceClick(x, y, 1) then
    state = 16
  elseif state == 16 and util.choiceClick(x, y, 1) then
    elapsedTime = 0
    state = 17
  end
end

function love.keyreleased(key)
  if state == 0 then
    state = 1
  end
  if state == 8 and key == "space" then
    water.start()
  end
  if state == 12 then
    state = 13
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

function duckReveal()
  love.graphics.setBackgroundColor(backgroundColor)
  love.graphics.draw(teal_duck, (wx * 0.5), (wy * 0.45), duckAngle, fadedDuckScale, fadedDuckScale, duck:getWidth() / 2, duck:getHeight() / 2)
end

function duckUnlock()
  love.graphics.setBackgroundColor(backgroundColor)
  love.graphics.setColor(0, 205, 210)
  local rescueText = love.graphics.newText(pacifico_scaled, "Duck Rescued! (How Daring!!!)")
  love.graphics.draw(rescueText, (wx * 0.05), (wy * 0.05), 0, (wx * 0.9) / rescueText:getWidth())
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(teal_duck, (wx * 0.5), (wy * 0.45), duckAngle, fadedDuckScale, fadedDuckScale, teal_duck:getWidth() / 2, duck:getHeight() / 2)
  love.graphics.setColor(0, 205, 210)
  local bigText = love.graphics.newText(amaranth_scaled, "What a fine color!")
  love.graphics.draw(bigText, (wx * 0.2), (wy * 0.70), 0, (wx * 0.6) / bigText:getWidth())
  local smallerText = love.graphics.newText(amaranth_scaled, "The favorite color of the world's cutest girl! (Hey, that's you!)")
  love.graphics.draw(smallerText, (wx * 0.1), (wy * 0.85), 0, (wx * 0.8) / smallerText:getWidth())
end

function outro1()
  love.graphics.setBackgroundColor(0, 205, 210)
  local msg = "That's one duck down, two to go! Maybe if we find the other two legendary rubber ducks, the mystery duck will reveal itself! I suppose we will have to conquer some more puzzles to find out!"
  util.dialog(msg, {"* So what now?"})
end

function outro2()
  local msg = "Hmm... Well, the next duck we'll need to track down is the Beavlet Duck, but I'm not sure if we are ready for something that extreme yet. Perhaps we should rest before continuing."
  util.dialog(msg, {"* SHOW ME THE BEAVLET DUCK!", "* Okay, I can wait."})
end

function outro3()
  local msg = "I'm sorry, I don't know where it is... (Brooks is still developing and testing prototypes for the Beavlet Duck, but the scratching from within the walls is making further progress difficult)."
  util.dialog(msg, {"* Okay, I can wait."})
end

function outro4()
  local msg = "Okay then, that's all for now! Good work " .. name .. ", you're a real rubber duck hero! Oh! Before I let you get back to your date, I have a message from Brooks!"
  util.dialog(msg, {"* Oh?"})
end

function finale1()
  love.graphics.setColor(255, 255, 255)
  outro4()
  love.graphics.setColor(0, 0, 0, finaleAlpha)
  love.graphics.rectangle("fill", 0, 0, wx, wy)
end

function finale2()
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("fill", 0, 0, wx, wy)
  love.graphics.setColor(255, 70, 230, finaleAlpha)
  love.graphics.setFont(amaranth)
  local msg = [[
      Happy belated Valentine's Day Sarah! I love you so very much! You make my day every day and for that I cannot thank you enough! You are absolutely perfect in my eyes.
      You truly are special to me, so I wanted to create something that was special to you! Hopefully this was as fun for you to play as it was for me to make!
      Always remember that, even when it seems like the whole world is conspiring against you, and that you're all alone, you'll always have people that love you and care about you. I can say this with certainty because I am one of those people. There is no challenge that you cannot overcome, Sarah. And I mean that sincerely.
  ]]
  love.graphics.printf(msg, (wx * 0.05), (wy * 0.05), (wx * 0.9), "left", 0)
  love.graphics.printf("~ Love, Brooks", (wx * 0.05), (wy * 0.9), (wx * 0.9), "right", 0)
end
