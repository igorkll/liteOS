local dialogWindows = require("dialogWindows")
local system = require("system")

local gui = system.gui
local scene = gui.scene

-------------------------

local sizeX, sizeY = dialogWindows.getWindowSize(scene, 25, 9)
local posX, posY = dialogWindows.getWindowPos(scene, sizeX, sizeY)

local layout = scene:createLayout(
    "purple",
    posX,
    posY,
    sizeX,
    sizeY,
    true
)
layout:createExitButton()
layout:createLabel("seek")
text = layout:createWidget({
    type = "text",

    posX = 2,
    posY = 3,
    sizeX = 8,
    sizeY = 1,

    text = "-"
})
progress = layout:createWidget({
    type = "progress",

    posX = 2,
    posY = 4,
    sizeX = sizeX - 2,
    sizeY = 1
})
layout:createWidget({
    type = "seek",

    posX = 2,
    posY = 6,
    sizeX = sizeX - 2,
    sizeY = 3,

    onSeek = function(value)
        progress:setParam("value", value)
        text:setParam("text", tostring(value))
    end,
})