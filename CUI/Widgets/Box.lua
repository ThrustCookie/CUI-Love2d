--- Cemi UI Box Widget ---

local Widget = require "Cemi_UI.Widgets.Widget"
local id = 1

--- definitions ---

--- Box Widget is a colored rectangle
---@class Box : Widget
    ---@field fill_mode "fill" | "line"
    ---@field color tablelib
    ---@field rounding {x:number, y:number}
local Box = Widget:new("Box", false)
Box.fill_mode = "fill"
Box.color = {1, 1, 1, 1}
Box.rounding = {x = 0, y = 0}


function Box:draw()
    love.graphics.setColor(self.color)
    love.graphics.rectangle(
        self.fill_mode,
        self.__internal_position.x,
        self.__internal_position.y,
        self.size.width.value, 
        self.size.height.value,
        self.rounding.x,
        self.rounding.y
    )
end

--- overrides ---

---@param name string | nil
---@return Box
function Box:new(name)
    local t = Widget:new("Box", false)
    setmetatable(t, self)
    self.__index = self

    t.name = name or t.name
    t.id = id ---@diagnostic disable-line
    id = id + 1

    return t ---@diagnostic disable-line
end

function Box:__tostring()
    ---@diagnostic disable-next-line
    return "<".. self.name ..": ".. self.id ..">" 
end



return Box