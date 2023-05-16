local dialogWindows = require("dialogWindows")
local system = require("system")
local gui = system.gui
local scene = system.scene


local sizeX, sizeY = dialogWindows.getWindowSize(scene, 40, 10)
local posX, posY = dialogWindows.getWindowPos(scene, sizeX, sizeY)

local layout = scene:createLayout(
    gui:getColor("black"),
    posX,
    posY,
    sizeX,
    sizeY,
    true
)

layout:createExitButton()
layout:createLabel("settings")

layout:createWidget({
    type = "button",
    text = "set background color",

    posX = 2,
    posY = 3,
    sizeX = 16,
    sizeY = 1
})