local dialogWindows = require("dialogWindows")
local autorun = require("autorun")
local programs = require("programs")
local system = require("system")
local gui = system.gui

-------------------------------------------------------

scene = gui:createScene(nil, system.rx, system.ry, system.palette, true)
bgLayout = scene:createLayout(gui:getColor("cyan"), 1, 1, system.rx, system.ry, false, true)
bgLayout:createWidget({
    type = "plane",

    bg = gui:getColor("green"),

    posX = 1,
    posY = bgLayout.sizeY,
    sizeX = bgLayout.sizeX,
    sizeY = 1
})

-------------------------------------------------------menu

osMenu = scene:createLayout(gui:getColor("orange"), 1, scene.sizeY - 20, 20, 20)
osMenu:setParam("disable", true)
osMenu:setParam("hide", true)

osButton = bgLayout:createWidget({
    type = "button",
    text = "OS",

    togle = true,
    onTogle = function (_, state)
        osMenu:setParam("disable", not state)
        osMenu:setParam("hide", not state)
    end,

    posX = 1,
    posY = bgLayout.sizeY,
    sizeX = 4,
    sizeY = 1
})

-------------------------------------------------------

gui:selectScene(scene)
autorun.autorun("/desktopAutorun")
autorun.autorun("/data/desktopAutorun")
gui:run()