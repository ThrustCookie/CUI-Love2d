# CUI-Love2d
CUI or Cemi UI is a Love2D UI layout library.
This library is based on video by Nic barker: [How Clay's UI Layout Algorithm Works](https://youtu.be/by9lQvpvMIc?si=x-HM9oVEFAFbntmM).

## How to use
You can copy or git clone this library directly into any project.
To implement it you'll need the following functions in your main.lua:

CUI.draw(scene) is incharge of the rendering. *scene* can be any **widget** made with this library.
```lua
function love.draw()
    CUI.draw(scene)
end
```

The following are used for the button widget, they get input from the mouse.
```lua
function love.mousemoved( x, y, dx, dy, istouch )
    CUI.check_for_collisions(x,y)
end
function love.mousepressed( x, y, button, istouch, presses )
    CUI.check_for_interaction("pressed")
end
function love.mousereleased( x, y, button, istouch, presses )
    CUI.check_for_interaction("released")
end
```

## Implemented Wigets

### [Alignment](CUI/Widgets/Alignment.lua)
This is used to align widgets horizontally or vertically, this can be set with it's direction variable.

### [Box](CUI/Widgets/Box.lua)
This is a colored box.

### [Button](CUI/Widgets/Button.lua)
This reacts to your mouse. It can be binded to execute functions with its On[Action] functions.

### [Text](CUI/Widgets/Text.lua)
This can display text

### [Basic Widget](CUI/Widgets/Widget.lua)
This is a basic empty widget, it can be used to align or space other widgets.

## Future Development
- Image Widget
- Unequal spacing for the Fill option
- Min and Max sizing options
- ease of use for adding children