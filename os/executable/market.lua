local webservices = require("webservices")
local colors = require("colors")

if not webservices.run("market.lua") then
    createMessage(colors.red, "error", "webservices error")
end