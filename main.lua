_G.love = require "love"

local CUI = require "CUI.CUI"
local scene -- your scene should go here

function love.draw()
    CUI.draw(scene)
end

function love.mousemoved( x, y, dx, dy, istouch )
    CUI.check_for_collisions(x,y)
end
function love.mousepressed( x, y, button, istouch, presses )
    CUI.check_for_interaction("pressed")
end
function love.mousereleased( x, y, button, istouch, presses )
    CUI.check_for_interaction("released")
end