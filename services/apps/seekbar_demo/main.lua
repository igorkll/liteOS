local colors = require("colors")

local layout = scene:createLayout(
    colors.purple,
    recommendedPosX,
    recommendedPosY,
    recommendedSizeX,
    recommendedSizeY,
    true
)
layout:createExitButton()
layout:createLabel("seek")

local text = layout:createWidget({
    type = "text",

    posX = 2,
    posY = 3,
    sizeX = 8,
    sizeY = 1,

    text = "-"
})
local progress = layout:createWidget({
    type = "progress",

    posX = 2,
    posY = 4,
    sizeX = recommendedSizeX - 2,
    sizeY = 1
})
layout:createWidget({
    type = "seek",

    posX = 2,
    posY = 6,
    sizeX = recommendedSizeX - 2,
    sizeY = 3,

    onSeek = function(value)
        progress:setParam("value", value)
        text:setParam("text", tostring(value))
    end,
})