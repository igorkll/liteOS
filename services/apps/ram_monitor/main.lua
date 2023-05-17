local dialogWindows = require("dialogWindows")
local background = require("background")
local system = require("system")

local gui = system.gui
local scene = gui.scene

-------------------------

local function update()
    local total = math.floor((computer.totalMemory() / 1024) + 0.5)
    local free = math.floor((computer.freeMemory() / 1024) + 0.5)
    local used = math.floor(((computer.totalMemory() - computer.freeMemory()) / 1024) + 0.5)

    total_ram:setParam("text", "total ram: " .. tostring(math.floor(total + 0.5)) .. "KB")
    free_ram:setParam("text", "free ram: " .. tostring(math.floor(free + 0.5)) .. "KB")
    used_ram:setParam("text", "used ram: " .. tostring(math.floor(used + 0.5)) .. "KB")

    progress_used_ram:setParam("value", used / total)

    gui:draw()
end

-------------------------

local sizeX, sizeY = dialogWindows.getWindowSize(scene, 25, 8)
local posX, posY = dialogWindows.getWindowPos(scene, sizeX, sizeY)

layout = scene:createLayout(
    "lime",
    posX,
    posY,
    sizeX,
    sizeY,
    true
)
layout:createExitButton()
layout:createLabel("ram monitor")

for index, value in ipairs({"total_ram", "free_ram", "used_ram"}) do
    _ENV[value] = layout:createWidget({
        type = "text",
    
        posX = 2,
        posY = 4 + index,
        sizeX = sizeX - 2,
        sizeY = 1
    })
end

progress_used_ram = layout:createWidget({
    type = "progress",

    posX = 2,
    posY = 3,
    sizeX = sizeX - 2,
    sizeY = 1,

    fg = "yellow"
})

-------------------------update

layout:addTimer(update, 0.2)
update()