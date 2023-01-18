--[[
local drawer = require("drawer")
local colors = require("colors")

----------------------------------------

local drawzone = drawer.create({
    palette = drawer.palette_computercraft,
    usingTheDefaultPalette = true
})

----------------------------------------

local px, py = 1, 1
while true do
    local eventData = {computer.pullSignal(1)}
    if eventData[1] == "drag" then
        px, py = eventData[3], eventData[4]
    end

    drawzone:draw_begin()
    drawzone:clear()
    drawzone:fill(px, py, 16, 16, colors.brown)
    for i = 0, 15 do
        drawzone:set(px + i, py + i, colors.yellow, colors.red, "@")
    end
    drawzone:draw_end()
end
]]

local colors = require("colors")
local drawer = require("drawer")

-------------------------------------------

local gui = require("gui").create()
local scene1 = gui:createScene(colors.purple, 50, 16, drawer.palette_computercraft, true)
local scene2 = gui:createScene(colors.green, 80, 10, drawer.palette_defaultTier2, true)



gui:run()