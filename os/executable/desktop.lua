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

-------------------------------------------------------plane ponel

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

-------------------------------------------------------menu

osMenu = scene:createLayout(gui:getColor("gray"), 1, scene.sizeY - 20, 30, 20)
osMenu:setParam("disable", true)
osMenu:setParam("hide", true)
osMenu:createWidget({
    type = "button",
    togle = true,

    text = "Power",

    posX = 1,
    posY = osMenu.sizeY,
    sizeX = 8,
    sizeY = 1,

    onTogle = function (_, state)
        powerMenu:setParam("disable", not state)
        powerMenu:setParam("hide", not state)
    end
})

powerMenu = osMenu:createLayout(gui:getColor("lightGray"), 2, osMenu.sizeY - 5, 10, 5)
powerMenu:setParam("disable", true)
powerMenu:setParam("hide", true)
powerMenu:createWidget({
    type = "button",
    notAutoReleased = true,

    text = "Reboot",

    posX = 1,
    posY = powerMenu.sizeY - 1,
    sizeX = powerMenu.sizeX,
    sizeY = 1,

    onReleaseInBox = function ()
        computer.shutdown(true)
    end
})
powerMenu:createWidget({
    type = "button",
    notAutoReleased = true,

    text = "Shutdown",

    posX = 1,
    posY = powerMenu.sizeY,
    sizeX = powerMenu.sizeX,
    sizeY = 1,

    onReleaseInBox = function ()
        computer.shutdown()
    end
})

-------------------------------------------------------

dialogWindows.message(scene, "hello!", "a new os!", gui:getColor("lightGray"))

-------------------------------------------------------

gui:selectScene(scene)
autorun.autorun("/desktopAutorun")
autorun.autorun("/data/desktopAutorun")
gui:run()