local colors = require("colors")
local background = require("background")

-------------------------

local function update()
    local total_ram = computer.()

    total_ram:setParam("text", "total ram: " .. tostring(math.floor( + 0.5)))
end

-------------------------

layout = scene:createLayout(
    colors.lime,
    recommendedPosX,
    recommendedPosY,
    recommendedSizeX,
    recommendedSizeY,
    true
)
layout:createExitButton()
layout:createLabel("ram monitor")

for index, value in ipairs({"total_ram", "free_ram", "used_ram"}) do
    _ENV[value] = layout:createWidget({
        type = "text",
    
        posX = 2,
        posY = 4 + index,
        sizeX = recommendedSizeX - 2,
        sizeY = 1
    })
end

used_ram = layout:createWidget({
    type = "progress",

    posX = 2,
    posY = 3,
    sizeX = recommendedSizeX - 2,
    sizeY = 1
})

-------------------------update

layout.onDestroy = function ()
    background.removeTimer(update)
end
background.addTimer(update, 0.5)
update()

return layout