local dialogWindows = require("dialogWindows")
local system = require("system")
local colors = require("colors")

local gui = system.gui
local scene = gui.scene

-------------------------

--local sizeX, sizeY = dialogWindows.getWindowSize(scene, 25, 17)
local sizeX, sizeY = 25, 16
local posX, posY = dialogWindows.getWindowPos(scene, sizeX, sizeY)

local layout = scene:createLayout(
    gui:getColor("purple"),
    posX,
    posY,
    sizeX,
    sizeY,
    true
)
layout:createExitButton()
layout:createLabel("palette")

for i = 1, 15 do
    text = layout:createWidget({
        type = "text",

        posX = 1,
        posY = 1 + i,
        sizeX = layout.sizeX,
        sizeY = 1,

        bg = gui:getColor(colors[i])
    })
end