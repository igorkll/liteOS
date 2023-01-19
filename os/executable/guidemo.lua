--[[
local drawer = require("drawer")
local colors = require("colors")

----------------------------------------

local drawzone = drawer.create()
drawzone:setPalette(drawer.palette_computercraft)
drawzone:setUsingTheDefaultPalette(true)

----------------------------------------

local px, py = 1, 1
while true do
    local eventData = {computer.pullSignal(1)}
    if eventData[1] == "drag" then
        px, py = eventData[3], eventData[4]
    end

    drawzone:draw_begin()
    drawzone:clear()
    drawzone:fill(px, py, 16, 16, colors.brown)
    for i = 0, 15 do
        drawzone:set(px + i, py + i, colors.yellow, colors.red, "@")
    end
    drawzone:draw_end()
end
]]

local colors = require("colors")
local drawer = require("drawer")
local gui = require("gui").create({renderSettings = {
    softwareBufferPriority = false,
}})


-------------------------------------------

scene1 = gui:createScene(colors.black, 80, 25, drawer.palette_computercraft, true)
scene1_window3 = scene1:createLayout(colors.cyan, 1, 1, scene1.sizeX, scene1.sizeY, false, true)
scene1_window3_text = scene1_window3:createWidget({
    type = "text",

    posX = 2,
    posY = 2,
    sizeX = 16,
    sizeY = 1,
    text = "gui demo",
})
scene1_window3_button = scene1_window3:createWidget({
    type = "button",

    posX = 2,
    posY = 4,
    sizeX = 24,
    sizeY = 1,
    text = "not auto released",

    notAutoReleased = true,

    onClick = function()
        computer.beep(500)
    end,
    onRelease = function()
        computer.beep(200)
    end
})
scene1_window3_button2 = scene1_window3:createWidget({
    type = "button",

    posX = 2,
    posY = 5,
    sizeX = 24,
    sizeY = 1,
    text = "auto released",

    onClick = function()
        computer.beep(2000)
    end,
    onRelease = function()
        computer.beep(1500)
    end
})
scene1_window3_button2 = scene1_window3:createWidget({
    type = "button",

    posX = 2,
    posY = 6,
    sizeX = 24,
    sizeY = 1,
    text = "togle button",

    togle = true,

    onClick = function()
        computer.beep(100)
    end,
    onRelease = function()
        computer.beep(50)
    end
})

for i = 1, 8 do
    scene1_window3:createWidget({
        type = "button",
    
        posX = scene1_window3.sizeX - 13,
        posY = 1 + i,
        sizeX = 12,
        sizeY = 1,
        text = tostring(i) .. ". swipe on us",
    
        notAutoReleased = true
    })
end

---------------------------------------------------------------------------------------

scene1_window1 = scene1:createLayout(colors.lime, 3, 3, 32, 8, true)
scene1_window1_text = scene1_window1:createWidget({
    type = "text",

    posX = 1,
    posY = 1,
    sizeX = 32,
    sizeY = 1,
    text = "current scene 1",
})
scene1_window1_button = scene1_window1:createWidget({
    type = "button",

    posX = 2,
    posY = 4,
    sizeX = 16,
    sizeY = 1,
    text = "to scene 2",

    onClick = function()
        gui:selectScene(scene2)
    end
})

---------------------------------------------------------------------------------------

scene1_window2 = scene1:createLayout(colors.red, 6, 6, 32, 8, true)
scene1_window2_text = scene1_window2:createWidget({
    type = "text",

    posX = 1,
    posY = 1,
    sizeX = 32,
    sizeY = 1,
    text = "control",
})
scene1_window2_button = scene1_window2:createWidget({
    type = "button",

    posX = 2,
    posY = 4,
    sizeX = 16,
    sizeY = 1,
    text = "beep",

    togle = true,

    onClick = function()
        computer.beep()
    end,
    onRelease = function()
        computer.beep(800)
    end
})
scene1_window2_button2 = scene1_window2:createWidget({
    type = "button",

    posX = 2,
    posY = 5,
    sizeX = 16,
    sizeY = 1,
    text = "exit",

    onClick = function()
        gui:exit()
    end
})

---------------------------------------------------------------------------------------

scene1_nicknamegetter = scene1:createLayout(colors.yellow, 9, 9, 32, 8, true)
scene1_nicknamegetter_text = scene1_nicknamegetter:createWidget({
    type = "text",

    posX = 1,
    posY = 1,
    sizeX = 31,
    sizeY = 1,
    text = "nickname recipient",
})
scene1_nicknamegetter_closebutton = scene1_nicknamegetter:createWidget({
    type = "button",

    posX = 32,
    posY = 1,
    sizeX = 1,
    sizeY = 1,
    text = "X",

    bg = colors.red,
    fg = colors.white,
    pressed_bg = colors.brown,
    pressed_fg = colors.black,

    onClick = function()
        scene1_nicknamegetter:destroy()
    end
})

scene1_nicknamegetter_button = scene1_nicknamegetter:createWidget({
    type = "button",

    posX = 2,
    posY = 3,
    sizeX = 24,
    sizeY = 1,
    text = "get your nickname",


    onClick = function(name)
        scene1_nicknamegetter_nickname:setParam("text", name or "-")
    end
})
scene1_nicknamegetter_nickname = scene1_nicknamegetter:createWidget({
    type = "text",

    posX = 2,
    posY = 4,
    sizeX = 24,
    sizeY = 1,
    text = "-",
})

---------------------------------------------------------------------------------------

scene2 = gui:createScene(colors.green, 80, 10, drawer.palette_defaultTier2, true)
scene2_window1 = scene2:createLayout(colors.red, 3, 3, 18, 8, true)
scene2_window1_text = scene2_window1:createWidget({
    type = "text",

    posX = 3,
    posY = 2,
    sizeX = 14,
    sizeY = 1,
    text = "scene 2",
})
scene2_window1_button = scene2_window1:createWidget({
    type = "button",

    posX = 3,
    posY = 4,
    sizeX = 14,
    sizeY = 1,
    text = "to scene 1",

    onClick = function()
        gui:selectScene(scene1)
    end
})

gui:selectScene(scene1)
gui:run()