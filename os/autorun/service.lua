--[[
local background = require("background")
local ip = "176.53.161.98"
local port = 8291

background.addTimer(function ()
    local internet = component.proxy(component.list("internet")() or "")
    if internet then
        local tcp = internet.connect("176.53.161.98", 1236)

        local str = ""

        tcp.finishConnect()
        tcp.write(str)
        tcp.close()
    end
end, 1)
]]--