-- Cemi UI alignment widget --


---@class Alignment : Widget
-- Direction in which children are laid out
---@field direction 'top to bottom' | 'left to right'
-- spacing between children
---@field spacing number
local alignment = require [[Widgets.Widget]]:extend()


---@class Alignment_Template : Widget_Template
---@field direction? 'top to bottom' | 'left to right'
---@field spacing? integer

---@param t? Alignment_Template
---@return Alignment
function alignment.new(t)
    t = t or {}
    t.name = t.name or "Alignment"

    local new_alignment = alignment:child_new(t)

    new_alignment.direction = t.direction   or 'top to bottom'
    new_alignment.spacing   = t.spacing     or 0

    return new_alignment
end


---@param direction direction_options
function alignment:__place_children(direction)

    local offset = 0
    local axis
    if direction == 'width' then
        axis = 'x'
        offset = offset + self.margin.left
    else -- if direction is height
        axis = 'y'
        offset = offset + self.margin.top
    end

    offset = offset + self.__global_position[axis]

    local alignmentMatchesDir =
        self.direction == 'top to bottom' and direction == 'height' or
        self.direction == 'left to right' and direction == 'width'

    for _, child in ipairs(self.children) do
        child.__global_position[axis] = offset + child.position[axis]
        
        if alignmentMatchesDir then ---@TODO check margin calc
            offset = offset + child.size[direction].value + self.spacing
        end
    end
end

---@param direction direction_options
function alignment:__fit(direction)

    --calculations for adequate padding and axis to make my life easier
    local pad_dir
    if direction == 'width' then
        pad_dir = {'right', 'left'}
    else -- if direction is height
        pad_dir = {'top', 'down'}
    end

    ---@type number
    local calc_size = self.margin[pad_dir[1]] + self.margin[pad_dir[2]]

    local bIsLayoutDir =
        self.direction == 'left to right' and direction == 'width' or
        self.direction == 'top to bottom' and direction == 'height'

    if bIsLayoutDir then
        --- add children sizes and margin ---
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

function alignment:__fill_children(direction)
    local leftover_size = self.size[direction].value

    local pad_dir -- asume the direction is width
    if direction == 'height' then
        pad_dir = {'top', 'down'}
    else -- if direction == 'width'
        pad_dir = {'left', 'right'}
    end

    local margin = {self.margin[pad_dir[1]], self.margin[pad_dir[2]]}

    leftover_size = leftover_size - (margin[1]+margin[2])

    local fill_children = {}

    for _, child in ipairs(self.children) do
        if child.size[direction].mode == 'fill' then
            fill_children[#fill_children+1] = child
        end
    end

    local is_alignment_direction =
        direction =='width' and self.direction == 'left to right' or
        direction=='height' and self.direction == 'top to bottom'

    if not is_alignment_direction then
        for _, child in ipairs(fill_children) do
            child.size[direction].value = leftover_size
        end
        return
    end

    leftover_size = leftover_size - self.spacing*(#self.children-1)

    --remove non sizing obj from space
    for _, child in ipairs(self.children) do
        if child.size[direction].mode ~= 'fill' then
            leftover_size = leftover_size - child.size[direction].value
        end
    end

    table.sort(
        fill_children,
        function (a, b)
            return a.size[direction].value > b.size[direction].value
        end
    )

    ---@TODO expand the elements instead of setting them directly
    for _, fill_child in ipairs(fill_children) do
        fill_child.size[direction].value = leftover_size/#fill_children
    end
end

return alignment