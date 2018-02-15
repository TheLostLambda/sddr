function love.load()
  -- Asset Initialization
  pacifico = love.graphics.newFont("assets/fonts/Courgette-Regular.ttf", 80)
  amaranth = love.graphics.newFont("assets/fonts/Amaranth-Regular.ttf", 80)
  love.graphics.setDefaultFilter("nearest") -- Put pixel art below this line.
  duckImageData = love.image.newImageData("assets/sprites/duck.png")
  duck = love.graphics.newImage(duckImageData)

  -- Window setup
  love.window.setMode(800, 600, {resizable=true})
  love.window.setTitle("Sarah's Daring Duck Rescue!")
  love.window.setIcon(duckImageData)

  -- State Initialization
  wx = love.graphics.getWidth()
  wy = love.graphics.getHeight()
  duckAngle = -math.pi / 4
  elapsedTime = 0
  state = 0
end

function love.draw()
  titleScreen()
end

function love.update(dt)
  elapsedTime = elapsedTime + dt
  duckAngle = math.sin(elapsedTime * 1.5) / 2.25
end

function love.resize()
  wx = love.graphics.getWidth()
  wy = love.graphics.getHeight()
end

function titleScreen()
  love.graphics.setBackgroundColor(0, 205, 210)
  local titleText = love.graphics.newText(pacifico, "Sarah's Daring Duck Rescue!")
  love.graphics.draw(titleText, (wx * 0.05), (wy * 0.05), 0, (wx * 0.9) / titleText:getWidth())
  local duckScale = (wx * 0.2) / duck:getWidth()
  love.graphics.draw(duck, (wx / 2), (wy / 2), duckAngle, duckScale, duckScale, duck:getWidth() / 2, duck:getHeight() / 2)
  local startText = love.graphics.newText(amaranth, "Press any button to play!")
  love.graphics.draw(startText, (wx * 0.2), (wy * 0.75), 0, (wx * 0.6) / startText:getWidth())
end
