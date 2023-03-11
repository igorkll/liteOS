local programs = require("programs")
local colors = require("colors")
local drawer = require("drawer")
local env = require("env")
local fs = require("filesystem")
local webservices = require("webservices")
local gui = require("gui").create(
    {
        renderSettings = {
        }
    }
)

----------------------------------------------scene

standardWindowSizeX, standardWindowSizeY = 48, 10
palette = drawer.palette_computercraft

scene = gui:createScene(
    colors.cyan,
    gui.drawzone.maxSizeX,
    gui.drawzone.maxSizeY,
    palette,
    true
)

----------------------------------------------background

background = scene:createLayout(colors.cyan, 1, 1, scene.sizeX, scene.sizeY, false, true)
background:createLabel(_OSVERSION)
background:createWidget({
    type = "text",

    posX = 1,
    posY = scene.sizeY,
    sizeX = scene.sizeX,
    sizeY = 1,

    bg = colors.green
})

button_os = background:createWidget({
    type = "button",
    togle = true,

    posX = 1,
    posY = scene.sizeY,
    sizeX = 4,
    sizeY = 1,

    text = "OS",

    bg = colors.blue,
    fg = colors.white,
    pressed_bg = colors.blue,
    pressed_fg = colors.white,

    onClick = function()
        if not _MENU then
            _MENU = scene:createLayout(colors.orange, 1, 1, 32, 20)
        end
    end,
    onRelease = function()
        if _MENU then
            _MENU:destroy()
            _MENU = nil
        end
    end
})

----------------------------------------------methods

function getWindowPos(sizeX, sizeY)
    return math.round((scene.sizeX / 2) - (sizeX / 2)), math.round((scene.sizeY / 2) - (sizeY / 2))
end

function createMessage(color, label, text)
    color = color or colors.gray
    label = label or "alert message"
    text = text or ""
    local posX, posY = getWindowPos(standardWindowSizeX, standardWindowSizeY)
    
    local layout = scene:createLayout(
        color,
        posX,
        posY,
        standardWindowSizeX,
        standardWindowSizeY,
        true
    )

    layout:createExitButton()

    layout:createLabel(label)
    layout:createFullscreenText(text, color, colors.white)
end

function createProgrammEnv()
    local posX, posY = getWindowPos(standardWindowSizeX, standardWindowSizeY)

    local localenv = {
        gui = gui,
        scene = scene,

        recommendedPosX = posX,
        recommendedPosY = posY,
        recommendedSizeX = standardWindowSizeX,
        recommendedSizeY = standardWindowSizeY,

        recommendedPalette = palette,

        getWindowPos = getWindowPos,
        createMessage = createMessage,
        runProgramm = runProgramm,
        createProgrammEnv = createProgrammEnv,
    }

    return env.createProgrammEnv(localenv)
end

function runProgramm(name)
    local code, err = programs.load(name, createProgrammEnv())
    if not code then
        createMessage(colors.red, "error", err or "unknown")
    else
        local ok, err = pcall(code)
        if not ok then
            createMessage(colors.red, "error", err or "unknown")
        end
    end
end

----------------------------------------------apps

local function refreshList()
    apps_list = {}
    for _, data in ipairs(programs.list()) do
        if data.name ~= "desktop" then
            table.insert(apps_list, data)
        end
    end
end

apps_buttons = {}
function flushApps()
    for _, app_button in ipairs(apps_buttons) do
        app_button:destroy()
    end
    apps_buttons = {}

    for i, app in ipairs(apps_list) do
        table.insert(apps_buttons, background:createWidget({
            type = "button",

            text = app.name,

            posX = 2,
            posY = 2 + i,
            sizeX = 16,
            sizeY = 1,

            onClick = function ()
                runProgramm(app.name)
            end
        }))
    end
end

function refreshApps()
    refreshList()
    flushApps()
end

refreshApps()

----------------------------------------------main

webservices.run("/desktop.lua", {desktopEnv = _ENV})

gui:selectScene(scene)
gui:run()