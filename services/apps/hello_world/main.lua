local colors = require("colors")

local layout = scene:createLayout(
    colors.pink,
    recommendedPosX,
    recommendedPosY,
    recommendedSizeX,
    recommendedSizeY,
    true
)
layout:createExitButton()
layout:createLabel("hello, world!")