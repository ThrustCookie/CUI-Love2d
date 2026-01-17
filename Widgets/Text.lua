--- Cemi UI Text Widget ---

local relative_root = require "root_path"
local Widget = require (relative_root.."Widgets.Widget") ---@type Widget

---@param Text Text
local function updateText(Text)
    local width, textList = Text.font:getWrap(Text.content, Text.wrap_limit)
    rawset( Text, '__internalTextLines', textList)
    Text.size.width.value = width
    Text.size.height.value = #textList * Text.font:getHeight()
end

---TODO Add fit sizing that automatically changes the text's size

--- Text Widget displays text on the screen
---@class Text : Widget
    ---@field content string
    ---@field __internalTextLines string[]
    ---@field wrap_limit number
    ---@field font any
    ---@field color {[1]:number,[2]:number,[3]:number,[4]?:number}
local Text = {}

---@class Text_Template : Widget_Template
    ---@field content string
    ---@field wrap_limit number
    ---@field font any
    ---@field color {[1]:number,[2]:number,[3]:number,[4]?:number}

---@param template Text_Template
---@return Text
function Text:new(template)
    local t = Widget:new(template) ---@cast t Text
    setmetatable(t, self)
    self.__index = self
    
    rawset(t, 'font', love.graphics.newFont())
    rawset(t, 'content', "Default Text")
    rawset(t, 'wrap_limit', 500)

    updateText(t)
    
    t.color = {1, 1, 1, 1}

    if template == nil then
        return t
    end

    for key, value in pairs(template) do
        if value ~= nil then
            t[key] = value
        end
    end
    
    return t
end

---@param template Text_Template
---@return Text
function Text:__call(template)
    return self:new(template)
end

function Text:draw()
    love.graphics.setColor(self.color)
    love.graphics.setFont(self.font)
    for i, text in ipairs(self.__internalTextLines) do
        love.graphics.print(
            text,
            self.global_position.x,
            self.global_position.y + Text.font:getHeight()*(i-1)
        )
    end
end




Text.__newindex = function(self, key, value)

    rawset(self, key, value)

    if key == [[content]] then
        assert(type(value) == 'string', "not a valid string")

        updateText(self)
    elseif key == [[wrap_limit]] then

        updateText(self)
    elseif key == [[font]] then

        updateText(self)
    end
end

return Text