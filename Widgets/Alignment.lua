--- Cemi UI Alignment Widget ---

local relative_root = require "root_path"
local Widget = require (relative_root.."Widgets.Widget") ---@type Widget

-- the Alignment Widget arranges its children
-- in a specified direction with optional spacing
---@class Alignment : Widget
    -- Direction in which children are laid out
    ---@field direction 'Top to Bottom' | 'Left to Right' 
    -- spacing between children
    ---@field spacing number
local Alignment = setmetatable({}, Widget)

---@class Alignment_Template : Widget_Template
    ---@field direction? 'Top to Bottom' | 'Left to Right'
    ---@field spacing? integer

---@param template? Alignment_Template
---@return Alignment
function Alignment:new(template)
    local t = Widget:new(template) ---@cast t Alignment
    setmetatable(t, Alignment)
    self.__index = Alignment

    --- default values
    t.direction = 'Top to Bottom'
    t.spacing = 0

    if template == nil then
        return t
    end

    if template.direction then
        t.direction = template.direction
    end

    if template.spacing then
        t.spacing = template.spacing
    end

    return t
end

--- Overrides ---

function Alignment:__tostring()
    return string.format("<Alignment: %i>", self.id)
end

---@param direction direction_options
function Alignment:place_children(direction)
    local offset = 0
    local axis
    if direction == 'width' then
        axis = 'x'
        offset = offset + self.padding.left
    else -- if direction is height
        axis = 'y'
        offset = offset + self.padding.top
    end

    offset = offset + self.global_position[axis]

    local alignmentMatchesDir =
        self.direction == 'Top to Bottom' and direction == 'height'
        or self.direction == 'Left to Right' and direction == 'width'

    if alignmentMatchesDir == false then
        for _, child in ipairs(self.children) do
            child.global_position[axis] = 
                child.relative_position[axis]
                + offset
        end
    else
        
        for _, child in ipairs(self.children) do
            child.global_position[axis] = offset
            
            offset = 
                offset
                + child.size[direction].value
                + self.spacing
        end
    end
end

---@param template Alignment_Template
---@return Alignment
function Alignment:__call(template)
    return self:new(template)
end

---@param direction direction_options
function Alignment:fit(direction)
    --- calculations for adequate padding and axis to make my life easier
    local pad_dir
    if direction == 'width' then
        pad_dir = {'right', 'left'}
    else -- if direction is height
        pad_dir = {'top', 'down'}
    end
    
    ---@type number
    local calc_size = self.padding[pad_dir[1]] + self.padding[pad_dir[2]]
    
    local bIsLayoutDir = 
        self.direction == 'Left to Right' and direction == 'width'
        or self.direction == 'Top to Bottom' and direction == 'height'
    if bIsLayoutDir then
        --- add children sizes and padding ---
        for _, child in pairs(self.children) do ---@param child Widget
            calc_size = calc_size + child.size[direction].value
        end
        calc_size = calc_size + self.spacing * (#self.children - 1)
    else
        local maxChildSize = 0
        for _, child in next, self.children do ---@param child Widget
            maxChildSize = math.max(maxChildSize, child.size[direction].value)
        end
        calc_size = calc_size + maxChildSize
    end
    
    self.size[direction].value = calc_size
end

return Alignment