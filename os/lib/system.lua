local gui = require("gui")
local drawer = require("drawer")

---------------------------

local system = {}
system.gui = gui.create()
system.palette = drawer.palette_computercraft2
system.usingTheDefaultPalette = false --если включить, то цвета будут представлять собоий индексы палитры, в то время как цвета вне палитры будут недоступны
system.rx = system.gui.drawzone.maxSizeX
system.ry = system.gui.drawzone.maxSizeY

--[[
--палитра не будет устоновлена на мониторах третиго уровня
--это освабодит серый цвет для отрисовки картинок
if system.gui.drawzone.depth ~= 4 then
    system.palette = nil
    system.usingTheDefaultPalette = nil
end
]]



return system