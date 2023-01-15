local drawer = require("drawer")
local drawzone = drawer:create()

while true do
    drawzone:draw_begin()
    drawzone:clear(0xFFFF00)
    drawzone:fill(2, 2, 16, 16, 0xFF00FF, 0x00FF00, "@")
    drawzone:set(1, 1, 0xFFFFFF, 0xFF0000, "A")
    drawzone:draw_end()

    os.sleep(1)
end 