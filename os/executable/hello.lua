local colors = require("colors")

local layout = scene:createLayout(
    colors.pink,
    recommendedPosX,
    recommendedPosY,
    recommendedSizeX,
    recommendedSizeY,
    true
)
layout:createWidget({
    
})
layout:createExitButton()
layout:createLabel("hello, world!")

return layout