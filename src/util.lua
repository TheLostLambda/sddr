local Util = {}

function Util.dialog(msg, choices)
  local maxwellScale = (wx * 0.35) / maxwell:getWidth()
  love.graphics.draw(maxwell, (wx * 0.8), (wy * 0.5), 0, maxwellScale, maxwellScale, maxwell:getWidth() / 2, maxwell:getHeight() / 2)
  love.graphics.rectangle("fill", (wx * 0.05), (wy * 0.05), (wx * 0.55), (wy * 0.4), 10)
  love.graphics.setColor(0, 0, 0)
  love.graphics.setFont(amaranth)
  love.graphics.printf(msg, (wx * 0.06), (wy * 0.06), (wx * 0.53), "left", 0)
  love.graphics.setColor(255, 255, 255)
  for i = 1, #choices do
    love.graphics.printf(choices[i], (wx * 0.06), (wy * (0.4 + 0.1 * i)), (wx * 0.53), "left", 0)
  end
end

function Util.pointWithin(px, py, rx, ry, rw, rh)
  return px >= rx and px <= (rx + rw) and py >= ry and py <= (ry + rh)
end

function Util.choiceClick(x, y, c)
  return Util.pointWithin(x, y, (wx * 0.06), (wy * (0.4 + 0.1 * c)), (wx * 0.53), amaranth:getHeight())
end

return Util
