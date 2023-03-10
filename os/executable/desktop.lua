local programs = require("programs")
local colors = require("colors")
local drawer = require("drawer")
local env = require("env")
local fs = require("filesystem")
local gui = require("gui").create(
    {
        renderSettings = {
        }
    }
)

----------------------------------------------scene

local standardWindowSizeX, standardWindowSizeY = 48, 10
local palette = drawer.palette_computercraft

local scene = gui:createScene(
    colors.cyan,
    gui.drawzone.maxSizeX,
    gui.drawzone.maxSizeY,
    palette,
    true
)

----------------------------------------------background

local background = scene:createLayout(colors.cyan, 1, 1, scene.sizeX, scene.sizeY, false, true)
background:createLabel(_OSVERSION)

----------------------------------------------methods

local function getWindowPos(sizeX, sizeY)
    return math.round((scene.sizeX / 2) - (sizeX / 2)), math.round((scene.sizeY / 2) - (sizeY / 2))
end

local function createMessage(color, label, text)
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

local function runProgramm(name)
    local posX, posY = getWindowPos(standardWindowSizeX, standardWindowSizeY)

    local uptime = computer.uptime()

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
    }
    local code, err = programs.load(name, env.createProgrammEnv(localenv))
    if not code then
        createMessage(colors.red, "error", err or "unknown")
    else
        local ok, err = pcall(code)
        if not ok then
            createMessage(colors.red, "error", err or "unknown")
        end
    end

    --если вдруг это полноэкранная программа создающия свой инстанс gui которая сбила настройки
    if computer.uptime() - uptime > 0.5 or localenv.breaksSettings then
        gui:selectScene(scene, true)
    end
end

----------------------------------------------main

local apps_list
local function refreshList()
    apps_list = {}
    for _, data in ipairs(programs.list()) do
        if data.name ~= "desktop" then
            table.insert(apps_list, data)
        end
    end
end

local apps_buttons = {}
local function flushApps()
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

refreshList()
flushApps()


gui:selectScene(scene)
gui:run()