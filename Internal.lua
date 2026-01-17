local ICUI = {}

ICUI.root = nil ---@type Widget
ICUI.elem_list = {} ---@type Widget[]


--------------------------------
--- get_tree
--------------------------------

--- this function gets all the children of a given node in a depth first search non recursively
---@param root Widget
---@return Widget[]
function ICUI.get_tree(root)

    local remaining = {root}
    local elem_list = {}

    while #remaining ~= 0 do
        -- get all the children into a list in order of a depth first search
        
        elem_list[#elem_list+1] = table.remove(remaining, 1)
        
        for i = #elem_list[#elem_list].children, 1, -1 do
            local child = elem_list[#elem_list].children[i]
            
            --- check if child is already in list
            for _, value in ipairs(elem_list) do -- might make this a hashtable
                assert(
                    child ~= value,
                    string.format(
                        "%s has child: %s which is already referenced",   tostring(elem_list[#elem_list]), tostring(child)
                    )
                ) -- if child is already element on list give error
            end
            table.insert(remaining, 1, child)
        end
    end

    return elem_list
end


--------------------------------
--- refresh_tree
--------------------------------

function ICUI.refresh_tree()
    if ICUI.root == nil then return end
    
    ICUI.elem_list = ICUI.get_tree(ICUI.root)
end


--------------------------------
--- fit_elements
--------------------------------

--- compress all elements in element_list to only fit their contents 
---@param elem_list Widget[]
---@param direction direction_options
function ICUI.fit_elements(elem_list, direction)
    for listIndex = #elem_list, 1, -1 do
        if elem_list[listIndex].size[direction].mode == 'Fit' then 
            elem_list[listIndex]:fit(direction)
        end
    end
end


--------------------------------
--- expand_elements
--------------------------------

--- expand all elements in element_list to fill their containers 
---@param elem_list Widget[]
---@param direction direction_options
function ICUI.expand_elements(elem_list, direction)
    for _, widget in ipairs(elem_list) do
        
        local leftover_size = widget.size[direction].value

        local pad_dir = {'left', 'right'} -- asume the direction is width
        if direction == 'height' then pad_dir = {'top', 'down'} end
        leftover_size = leftover_size - widget.padding[pad_dir[1]] - widget.padding[pad_dir[2]]

        local fill_children = {}
        
        for _, child in ipairs(widget.children) do
            if child.size[direction].mode == 'Fill' then
                fill_children[#fill_children+1] = child
            end
        end
        
        
        ---@cast widget Alignment
        if widget.direction == nil then 

            for _, child in ipairs(fill_children) do
                child.size[direction].value = leftover_size
            end
            
            goto nextWidget 
        end -- only proceed with alignment widgets

        if 
            not 
            (direction =='width' and widget.direction == 'Left to Right' or
            direction =='height' and widget.direction == 'Top to Bottom')
        then
            for _, child in ipairs(fill_children) do
                child.size[direction].value = leftover_size
            end
            goto nextWidget
        end
        
        leftover_size = leftover_size - widget.spacing*(#widget.children-1)
        
        for _, child in ipairs(widget.children) do
            if child.size[direction].mode ~= 'Fill' then
                leftover_size = leftover_size - child.size[direction].value
            end
        end
    
        table.sort(fill_children, function (a, b) return a.size[direction].value > b.size[direction].value end)
    

        --- expand the elements instead of setting them directly
        for _, fill_child in ipairs(fill_children) do
            fill_child.size[direction].value = leftover_size/#fill_children
        end
        
        ::nextWidget::
    end
end


--------------------------------
--- place_elements
--------------------------------

--- set positions of all elements in element_list
---@param elem_list Widget[]
---@param direction direction_options
function ICUI.place_elements(elem_list, direction)
    for _, widget in ipairs(elem_list) do
        widget:place_children(direction)
    end
end


--------------------------------
--- draw_elements
--------------------------------

--- draw all elements in element_list
---@param elem_list tablelib
function ICUI.draw_elements(elem_list)
    for _, element in ipairs(elem_list) do
        if element.draw ~= nil then
            element:draw()
        end
    end
end

return ICUI