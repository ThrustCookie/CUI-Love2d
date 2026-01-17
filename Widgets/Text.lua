--- Cemi UI Text Widget ---

local relative_root = require "root_path"
local Widget = require (relative_root.."Widgets.Widget") ---@type Widget

---@param self Text
local function updateText(self)
    local width, textList = self.font:getWrap(self.content, self.wrap_limit)
    rawset( self, [[__internalTextLines]], textList)
    self:set_size({width = width, height = #textList * self.font:getHeight()})
end

---TODO Add fit sizing that automatically changes the text's size

--- Text Widget displays text on the screen
---@class Text : Widget
    ---@field content string
    ---@field __internalTextLines string[]
    ---@field wrap_limit number
    ---@field font any
    ---@field color {[1]:number,[2]:number,[3]:number,[4]?:number}
local Text = setmetatable({}, Widget)
Text.content = "Default Text"
Text.wrap_limit = 500
Text.font = love.graphics.newFont(12)



function Text:draw()
    love.graphics.setColor(self.color)
    love.graphics.setFont(self.font)
    for i, text in ipairs(self.__internalTextLines) do
        love.graphics.print(
            text,
            self.global_position.x,
            self.global_position.y + self.font:getHeight()*(i-1)
        )
    end
end

Text.__newindex = function(self, key, value)

    rawset(self, key, value)

    if 
        key == [[content]] or
        key == [[wrap_limit]] or
        key == [[font]]
    then
        updateText(self)
    end
end


---@class Text_Template : Widget_Template
    ---@field content? string
    ---@field wrap_limit? number
    ---@field font? any
    ---@field color? {[1]:number,[2]:number,[3]:number,[4]?:number}

---@param template? Text_Template
---@return Text
function Text:new(template)
    
    local t = setmetatable(Widget:new(template), Text) ---@cast t Text
    self.__index = self
    
    t.color = {1, 1, 1}
    t.size.height.mode = 'Fixed'
    t.size.width.mode = 'Fixed'
    
    if template == nil then
        updateText(t)
        return t
    end
    
    for key, value in pairs(template) do
        if value ~= nil then
            t[key] = value
        end
    end
    
    updateText(t)
    return t
end

---@param template Text_Template
---@return Text
function Text:__call(template)
    return self:new(template)
end

function Text:__tostring()
    return string.format("<Text: %i>", self.id)
end

return Text