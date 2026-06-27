--- Cemi UI TextInput Widget ---

local relative_root = require "root_path"
local Text = require (relative_root.."Widgets.Text") ---@type Text

-- Button Widget is a clickable rectangle
---@class TextInput : Text
    ---@field hintText string
    ---@field hintTextColor {[1]:number,[2]:number,[3]:number,[4]:number?}
    ---@field textColor {[1]:number,[2]:number,[3]:number,[4]:number?}
    ---@field bEditing boolean
    ---@field OnPressed function
    ---@field OnEdited function
    ---@field OnReleased function this fires when the user clicks outside of the textinput
local TextInput = setmetatable({}, Text)

---@class TextInput_Template : Text_Template
    ---@field hintText? string
    ---@field hintTextColor? {[1]:number,[2]:number,[3]:number,[4]:number?}
    ---@field OnPressed? function()
    ---@field OnEdited? function
    ---@field OnStoppedEditing? function this fires when the user clicks outside 



---@param template? TextInput_Template
---@return TextInput
function TextInput:new(template)


    local t = setmetatable(Text:new(template), TextInput)---@cast t TextInput
    self.__index = TextInput
    
    t.hintText = "inputText"
    t.hintTextColor =  {.5,.5,.5}
    t.content = ""
    t.textColor = {1,1,1}

    if template == nil then
        return t
    end

    local attributes = {
        'hintText',
        'OnPressed',
        'field',
        'OnStoppedEditing',
    }
    for _, attr in pairs(attributes) do
        t[attr] = template[attr]
        if attr == 'hintTextColor' then
            t.color = t.hintTextColor
        end
    end

    return t
end

function TextInput:__tostring()
    return string.format("<TextInput: %i>", self.id)
end

function TextInput:Pressed()
    self.bEditing = true
    self:OnPressed()
end

function TextInput:Released()
    self.bEditing = false
    self:OnReleased()
end

--- TextInput Logic & Overrides ---

TextInput.OnPressed = function(self) end
TextInput.OnStoppedEditing = function (self) end
TextInput.OnEdited = function(self) end


function TextInput:draw()
    love.graphics.setColor(self.color)
    local text = self.hintText
    if self.bEditing then text = self.content end

    love.graphics.print(
        text,
        self.global_position.x,
        self.global_position.y
    )
end

return TextInput