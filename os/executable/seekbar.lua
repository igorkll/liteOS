local colors = require("colors")

local layout = scene:createLayout(
    colors.blue,
    recommendedPosX,
    recommendedPosY,
    recommendedSizeX,
    recommendedSizeY,
    true
)
layout:createExitButton()
layout:createLabel("seek")

local progress = layout:createWidget({
    type = "progress",

    posX = 2,
    posY = 3,
    sizeX = recommendedSizeX - 2,
    sizeY = 1
})
layout:createWidget({
    type = "seek",

    posX = 2,
    posY = 5,
    sizeX = recommendedSizeX - 2,
    sizeY = 3,

    onSeek = function(value)
        progress:setParam("value", value)
    end
})

return layout