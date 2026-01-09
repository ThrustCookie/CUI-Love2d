--- Cemi UI Alignment Widget ---

local relative_root = require "root_path"
local Widget = require (relative_root.."Widgets.Widget")
local id = 1

--- definitions ---

-- the Alignment Widget arranges its children
-- in a specified direction with optional spacing
---@class Alignment : Widget
    ---@field spacing number
    ---@field direction "Top to Bottom" | "Left to Right" 
local Alignment = Widget:new(false)
Alignment.direction = "Top to Bottom" -- Direction in which children are laid out
Alignment.spacing = 0 -- spacing between children


---@return Alignment
function Alignment:new()
    local t = Widget:new(false)
    setmetatable(t, self)
    self.__index = self
    
    t.id = id ---@diagnostic disable-line private
    id = id + 1
    
    return t ---@diagnostic disable-line return-type-mismatch
end

--- Overrides ---

function Alignment:__tostring()
    ---@diagnostic disable-next-line
    return string.format("< Alignment: %i>", self.id)
end

---@param direction direction_options
function Alignment:place_children(direction)
    local offset = 0
    local axis
    if direction == "width" then 
        axis = "x"
        offset = offset + self.padding.left
    else -- if direction is height
        axis = "y"
        offset = offset + self.padding.top
    end
    
    
    offset = offset + self.__internal_position[axis]

    local alignmentMatchesDir = 
        self.direction == "Top to Bottom" and direction == "height"
        or self.direction == "Left to Right" and direction == "width"
    
    if alignmentMatchesDir == false then
        for _, child in ipairs(self.children) do
            child.__internal_position[axis] = 
                child.position[axis]
                + offset
        end   
    else
        
        for _, child in ipairs(self.children) do
            child.__internal_position[axis] = offset
            
            offset = 
                offset
                + child.size[direction].value
                + self.spacing
        end
    end
end

---@param direction direction_options
function Alignment:fit(direction)
    --- calculations for adequate padding and axis to make my life easier
    local pad_dir
    if direction == "width" then
        pad_dir = {"right", "left"}
    else -- if direction is height
        pad_dir = {"top", "down"}
    end
    
    ---@type number
    local calc_size = self.padding[pad_dir[1]] + self.padding[pad_dir[2]]
    
    local bIsLayoutDir = 
        self.direction == "Left to Right" and direction == "width"
        or self.direction == "Top to Bottom" and direction == "height"
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