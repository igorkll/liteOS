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
local gui = require("gui").create()

-------------------------------------------

scene1 = gui:createScene(colors.black, 50, 16, drawer.palette_computercraft, true)
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
scene1_window2 = scene1:createLayout(colors.red, 3, 3, 32, 8, true)
scene1_window2_text = scene1_window2:createWidget({
    type = "text",

    posX = 1,
    posY = 1,
    sizeX = 32,
    sizeY = 1,
    text = "new window",
})
scene1_window2_button = scene1_window2:createWidget({
    type = "button",

    posX = 2,
    posY = 4,
    sizeX = 16,
    sizeY = 1,
    text = "beep",

    togle = true,

    bg = {colors.red, colors.yellow, "▒"},
    fg = {colors.blue, colors.lightblue, "▒"},

    pressed_bg = {colors.green, colors.lime, "▒"},
    pressed_fg = {colors.lightblue, colors.blue, "▒"},

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