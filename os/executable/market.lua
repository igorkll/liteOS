local dialogWindows = require("dialogWindows")
local system = require("system")
local webservices = require("webservices")

if not webservices.run("market.lua") then
    dialogWindows.message(system.gui.scene, "error", "webservices error", system.gui:getColor("red"))
end