--- Cemi UI Text Widget ---

local relative_root = require "root_path"
local Widget = require (relative_root.."Widgets.Widget")

---TODO Add fit sizing that automatically changes the text's size

--- Text Widget displays text on the screen
---@class Text : Widget
---@field text string
---@field color tablelib
---@field __internalTextLines string[]
local Text = Widget:new( false)
Text.content = "Default Text"
Text.wrap_limit = 500
Text.color = {1, 1, 1, 1}
Text.font = love.graphics.newFont()
Text.__internalTextLines = {"Default Text"}

---@param Text Text
local function updateText(Text)
    local width, textList = Text.font:getWrap(Text.content, Text.wrap_limit)
    rawset( Text, "__internalTextLines", textList)
    Text.size.width.value = width
    Text.size.height.value = #textList * Text.font:getHeight()
end


Text.__newindex = function(self, key, value)

    rawset(self, key, value)

    if key == "content" then
        assert(type(value) == "string", "not a valid string")

        updateText(self)
    elseif key == "wrap_limit" then

        updateText(self)
    elseif key == "font" then

        updateText(self)
    end
end

---@return Text
function Text:new()
    local t = Widget:new(false)
    setmetatable(t, self)
    self.__index = self
    
    return t ---@diagnostic disable-line
end

function Text:draw()
    love.graphics.setColor(self.color)
    love.graphics.setFont(self.font)
    for i, text in ipairs(self.__internalTextLines) do
        love.graphics.print(
            text,
            self.__internal_position.x,
            self.__internal_position.y + Text.font:getHeight()*(i-1)
        )
    end
end

return Text