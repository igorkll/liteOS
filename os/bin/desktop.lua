local webservices = require("webservices")
local autorun = require("autorun")
local programs = require("programs")
local system = require("system")
local gui = system.gui

-------------------------------------------------------

scene = system.createScene()
system.scene = scene

bgLayout = scene:createLayout(gui:getColor("cyan"), 1, 1, system.rx, system.ry, false, true)
bgLayout:createWidget({
    type = "plane",

    bg = gui:getColor("green"),

    posX = 1,
    posY = bgLayout.sizeY,
    sizeX = bgLayout.sizeX,
    sizeY = 1
})

osButton = bgLayout:createWidget({
    type = "button",
    text = "OS",

    togle = true,
    onTogle = function (_, state)
        osMenu:toUpper()
        osMenu:setParam("disable", not state)
        osMenu:setParam("hide", not state)
    end,

    bg = gui:getColor("blue"),
    fg = gui:getColor("lightBlue"),

    posX = 1,
    posY = bgLayout.sizeY,
    sizeX = 4,
    sizeY = 1
})

cloneButton = bgLayout:createWidget({
    type = "button",
    text = "clone the OS",

    onClick = function ()
        
    end,

    bg = gui:getColor("white"),
    fg = gui:getColor("black"),

    posX = bgLayout.sizeX - 20,
    posY = bgLayout.sizeY - 2,
    sizeX = 16,
    sizeY = 1
})

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

-------------------------------------------------------apps menu

local function refreshList()
    apps_list = {}
    for _, data in ipairs(programs.list()) do
        if data.name ~= "desktop" then
            table.insert(apps_list, data)
        end
    end
end

apps_buttons = {}
function flushApps()
    for _, app_button in ipairs(apps_buttons) do
        app_button:destroy()
    end
    apps_buttons = {}

    for i, app in ipairs(apps_list) do
        table.insert(apps_buttons, bgLayout:createWidget({
            type = "button",

            text = app.name,

            posX = 2,
            posY = 1 + i,
            sizeX = 16,
            sizeY = 1,

            onClick = function ()
                programs.guiout_execute(app.name)
            end
        }))
    end
end

function refreshApps()
    refreshList()
    flushApps()
end

refreshApps()

-------------------------------------------------------

gui:selectScene(scene)
webservices.run("/desktop.lua")
autorun.autorun("desktopAutorun")
gui:run()