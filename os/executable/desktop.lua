local dialogWindows = require("dialogWindows")
local autorun = require("autorun")
local system = require("system")
local gui = system.gui

-------------------------------------------------------

local scene = gui:createScene(nil, system.rx, system.ry, system.palette, true)
local bgLayout = scene:createLayout(gui:getColor("cyan"), 1, 1, system.rx, system.ry, false, true)

-------------------------------------------------------

local windows = {}
for i = 0, 15 do
    windows[i] = dialogWindows.message(scene, "label", "text", i)
end

-------------------------------------------------------

gui:selectScene(scene)
autorun.autorun("/desktopAutorun")
autorun.autorun("/data/desktopAutorun")

local olduptime = computer.uptime()
gui:run(function()
    if computer.uptime() - olduptime > 1 then
        local state = math.random(0, 1) == 0
        local index = math.random(0, 15)
        windows[index]:setParam("hide", state)
        windows[index]:setParam("disable", state)
        olduptime = computer.uptime()
    end
end, 0.5)