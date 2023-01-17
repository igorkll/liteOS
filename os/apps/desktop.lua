local drawer = require("drawer")
local colors = require("colors")

----------------------------------------

local drawzone = drawer.create({
    palette = drawer.palette_computercraft,
    usingTheDefaultPalette = true
})

----------------------------------------

drawzone:draw_begin()
drawzone:clear()
drawzone:fill(1, 1, 16, 16, colors.brown)
drawzone:set(4, 2, colors.yellow, colors.red, "Image" .. tostring(colors.brown))
drawzone:draw_end()

os.sleep(1)

while true do
    drawzone:draw_begin()
    --drawzone:clear(0xFFFF00)
    --drawzone:fill(2, ((computer.uptime() * 16) % 20) + 2, 16, 16, 0xFF00FF, 0x00FF00, "@")
    --drawzone:set(1, 1, 0xFFFFFF, 0xFF0000, "A")
    --[[
    for i = 1, 512 do
        drawzone:set(math.random(1, drawzone.sizeX), math.random(1, drawzone.sizeY), math.random(0, 15), math.random(0, 15), string.char(math.random(0, 255)))
    end
    ]]
    --[[
    drawzone:clear(0x000000)
    for i = 1, 16 do
        drawzone:set(i, 1, i - 1, i % 16, "?")
    end
    ]]
    drawzone:copy(1, 1, 16, 16, 50, 10)
    drawzone:draw_end()

    os.sleep(0.5)
end