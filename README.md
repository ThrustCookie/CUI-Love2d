######
## CUI-Love2d
######

CUI or Cemí UI is a Love2D UI layout library.
The ui elements use a parent children tree structure with some set rules to align themselves.
The main algorithm is based on video by Nic barker: [How Clay's UI Layout Algorithm Works](https://youtu.be/by9lQvpvMIc?si=x-HM9oVEFAFbntmM).

# How to use
You can clone this library directly into any project.

## Making A Widget

Creating a widget is simple.

Add a require to the main **CUI.lua** file; you can call it whatever you like. Usually I leave it as CUI.
```lua
local CUI = require [[CUI.lua]]
```

Then you can create any of the internal widgets inside the CUI file.
```lua
local scene = CUI.widget()
```

### Parameters

Parameters can be set when creating a widget by passing a template argument to the function.
```lua
local scene CUI.widget {
    size = 'fill',
    position = 20,
}
```
You can also set the variables after creating the widget.
```lua
local scene CUI.widget()
scene.size      = 'fill'
scene.position  = 20
```

The parameters are protected with interal __index and __newindex functions which allow setting shorthands directly.
This:
```lua
local scene CUI.widget {
    size = 'fill',
    position = 20,
}
```
is the same as this:
```lua
local scene CUI.widget {
    size = {width='fill', height='fill'},
    position = {x=20, y=20},
}
```

Most of the parameters can also be set as references or functions which are called when indexing them.

__Function__
```lua
local scene CUI.widget {
    size = function(self)
        return 10
    end,
}
```

__Reference__
```lua
local reference = {value=10}

local scene CUI.widget {
    size = {table=reference, key='value'},
}
```

## Rendering
This is incharge of the rendering. *scene* can be any **widget** made with this library.
```lua
function love.draw()
    scene:draw()
end
```

## Interaction
The following are used for interaction within the widgets, they get input from the mouse.
```lua

function love.mousemoved( x, y, dx, dy, istouch )
    scene:mousemoved(x,y)
end

function love.mousepressed( x, y, button, istouch, presses )
    scene:mouse('pressed')
end

function love.mousereleased( x, y, button, istouch, presses )
    scene:mouse('released')
end
```

## Implemented Wigets

### [Widget](Widgets/Widget.lua)
This is a basic empty widget, it can be used as spacing other widgets.

### [Alignment](Widgets/Alignment.lua)
This is used to align widgets horizontally or vertically, this can be set with it's direction variable.

### [Box](Widgets/Box.lua)
This is a colored box.

### [Text](Widgets/Text.lua)
This can display text.

### [Image](Widgets/Image.lua)
This can display an image.


## Future Development
- Min and Max sizing options which allows for Unequal spacing for the Fill option
- factoring in the scale for the widget size calculations.
