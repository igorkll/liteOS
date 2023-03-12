local gui = require("gui")
local drawer = require("drawer")

---------------------------

local system = {}
system.gui = gui.create()
system.palette = drawer.palette_computercraft
system.rx = system.gui.drawzone.maxSizeX
system.ry = system.gui.drawzone.maxSizeY

return system