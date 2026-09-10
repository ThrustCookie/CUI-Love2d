
---@class Alignment : Widget
local alignmnet = {}

function alignmnet:fill(direction)
    local leftover_size = self.size[direction].value

    local pad_dir -- asume the direction is width
    if direction == 'height' then
        pad_dir = {'top', 'down'}
    else -- if direction == 'width'
        pad_dir = {'left', 'right'}
    end

    --remove margin from total size
    leftover_size = leftover_size - self.margin[pad_dir[1]] - self.margin[pad_dir[2]]
    
    local fill_children = {}
    
    for _, child in ipairs(self.children) do
        if child.size[direction].mode == 'Fill' then
            fill_children[#fill_children+1] = child
        end
    end

    if
        not
        (direction =='width' and self.direction == 'Left to Right' or
        direction =='height' and self.direction == 'Top to Bottom')
    then
        for _, child in ipairs(fill_children) do
            child.size[direction].value = leftover_size
        end
        return
    end
    
    leftover_size = leftover_size - self.spacing*(#self.children-1)
    
    for _, child in ipairs(self.children) do
        if child.size[direction].mode ~= 'Fill' then
            leftover_size = leftover_size - child.size[direction].value
        end
    end

    table.sort(fill_children, function (a, b) return a.size[direction].value > b.size[direction].value end)


    --- expand the elements instead of setting them directly
    for _, fill_child in ipairs(fill_children) do
        fill_child.size[direction].value = leftover_size/#fill_children
    end
end

return alignmnet