local drawer = require("drawer")
local drawzone = drawer.create({
    palette = drawer.defaultPaletteTier2,
    usingTheDefaultPalette = true
})

while true do
    drawzone:draw_begin()
    --drawzone:clear(0xFFFF00)
    --drawzone:fill(2, ((computer.uptime() * 16) % 20) + 2, 16, 16, 0xFF00FF, 0x00FF00, "@")
    --drawzone:set(1, 1, 0xFFFFFF, 0xFF0000, "A")
    for i = 1, 1024 do
        drawzone:set(math.random(1, drawzone.sizeX), math.random(1, drawzone.sizeY), math.random(0, 15), math.random(0, 15), string.char(math.random(0, 255)))
    end
    drawzone:draw_end()

    os.sleep(2)
end