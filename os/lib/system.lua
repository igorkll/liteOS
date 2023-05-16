local gui = require("gui")
local drawer = require("drawer")
local parser = require("parser")
local internet = require("internet")
local json = require("json")
local logger = require("logger")

---------------------------

local system = {}
system.gui = gui.create()
system.palette = drawer.palette_computercraft2
system.usingTheDefaultPalette = true --если включить, то цвета будут представлять собоий индексы палитры, в то время как цвета вне палитры будут недоступны
system.rx = system.gui.drawzone.maxSizeX
system.ry = system.gui.drawzone.maxSizeY

--[[
--палитра не будет устоновлена на мониторах третиго уровня
--это освабодит серый цвет для отрисовки картинок
if system.gui.drawzone.depth ~= 4 then
    system.palette = nil
    system.usingTheDefaultPalette = nil
end
]]

function system.getSelfInfo()
    local info

    for runLevel = 0, math.huge do
        info = debug.getinfo(runLevel)

        if info then
            if info.what == "main" then
                return parser.split(string, info.source, "=")
            end
        else
            error("Failed to get debug info for runlevel " .. runLevel)
        end
    end
end

function system.getSelfPath()
    return system.getSelfInfo()[2]
end

function system.getSelfType()
    return system.getSelfInfo()[1]
end

function system.createScene(bg, sizeX, sizeY, palette)
    return system.gui:createScene(
        bg,
        sizeX or system.rx,
        sizeY or system.ry,
        palette or system.palette,
        system.usingTheDefaultPalette
    )
end

function system.update()
    local files = assert(internet.repoList("https://api.github.com/repos/igorkll/liteOS", ""))
    for index, value in ipairs(files) do
        logger.log("repo file", value)
    end
end
system.update()

return system