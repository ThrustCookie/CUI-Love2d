--- Cemi UI Main Drawing Logic ---

local ICUI = require "CUI.Internal"

local CUI = {}
CUI.Widget = require "CUI.Widgets.Widget"
CUI.Alignment = require "CUI.Widgets.Alignment"
CUI.Box = require "CUI.Widgets.Box"
CUI.Button = require "CUI.Widgets.Button"
CUI.Text = require "CUI.Widgets.Text"


--- TODO ---
--- image
--- center start and end align
--- min and max sizing
--- Fill sizing that doesnt size all elements equally
--- collision for button based on object (can leave for later)
--- 
--- 
--- i am hating actually implementing anything with this library, its too verbose
--- do the add_child() and make it take any ammount of parameters to aleviate this
--- 
--- in this function process and apply the metatables to each item
--- 
--- q? how to define class type to then set the metatable for?
--- 
--- have field for it like
--- 
--- constructer function?
--- 
--- param of the type it belongs to
--- CUI.Text({param here})
--- CUI.Widget({})
--- CUI.Button({})
--- 
--- {
--- "type" = {objet here}
--- "type" = {}
--- }
--- 
--- CUI:Set_size
--- or process it internally in the add_child() function
--- 
--- use lua multiple variable definitions instead of objects


--------------------------------
--- draw
--------------------------------

---@param scene Widget
function CUI.draw(scene)
    local r,g,b,a = love.graphics.getColor()
    
    if ICUI.root ~= scene then -- if scene changed
        ICUI.root = scene

        ICUI.refresh_tree()
    end
    --- first caluclate sizes ---
    
    -- fit pass
    ICUI.fit_elements(ICUI.elem_list, 'width')
    ICUI.fit_elements(ICUI.elem_list, 'height')

    -- fill pass
    ICUI.expand_elements(ICUI.elem_list, 'width')
    ICUI.expand_elements(ICUI.elem_list, 'height')

    --- Set positions based on sizes ---
    ICUI.place_elements(ICUI.elem_list, 'width')
    ICUI.place_elements(ICUI.elem_list, 'height')

    --- Draw elements ---
    ICUI.draw_elements(ICUI.elem_list)

    love.graphics.setColor(r,g,b,a)
    return
end

--------------------------------
--- check_for_collisions
--------------------------------

---@param x number
---@param y number
function CUI.check_for_collisions(x,y)
    if ICUI.elem_list == nil then return end

    for _, button in ipairs(ICUI.elem_list) do
        ---@cast button Button
        if button.Hovered == nil then goto continue end
        
        if button:Hovered(x,y) then
            button.bHovered = true
            button:OnHovered()

            if button.bPressed == false then
                button.color = button.hovered_color
            end

        elseif button.bHovered == true then
            button.bHovered = false
            button:OnUnhovered()

            if button.bPressed == false then
                button.color = button.basic_color
            end
        end

        ::continue::
    end
end


--------------------------------
--- check_for_interaction
--------------------------------

--- check for interactions with the UI
---@param type 'pressed' | 'released'
function CUI.check_for_interaction(type)

    if ICUI.elem_list == nil then return end

    if type == 'pressed' then

        for i = #ICUI.elem_list, 1, -1 do
            local button = ICUI.elem_list[i] 
            
            ---@cast button Button
            if button.bHovered == nil then goto continue end
            
            if button.bHovered == false then goto continue end

            button.bPressed = true
            button:OnPressed()

            button.color = button.pressed_color

            ::continue::
        end

    else --- asume its released
        for _, button in ipairs(ICUI.elem_list) do
            ---@cast button Button
            if button.bPressed == nil then goto continue end

            if button.bPressed == false then goto continue end

            button.bPressed = false
            button:OnReleased()
            
            
            if button.bHovered == true then
                button.color = button.hovered_color
            else 
                button.color = button.basic_color
            end

            ::continue::
        end
    end
end

return CUI