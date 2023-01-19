local colors = require("colors")

local layout = scene:createLayout(colors.pink, recommendedPosX, recommendedPosY, 4, 16, 16, true)
layout:createExitButton()

layout:createWidget({
    type = "text",
    posX = 1,
    posY = 1,
    sizeX = layout.sizeX - 1,
    sizeY = 1,

    text = "hello, world!"
})