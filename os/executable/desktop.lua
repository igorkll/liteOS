local programs = require("programs")
local colors = require("colors")
local drawer = require("drawer")
local env = require("env")
local gui = require("gui").create(
    {
        renderSettings = {
        }
    }
)

----------------------------------------------

local scene = gui:createScene(
    colors.cyan,
    gui.drawzone.maxSizeX,
    gui.drawzone.maxSizeY,
    drawer.palette_computercraft,
    true
)

local standardWindowSizeX, standardWindowSizeY = 48, 10

----------------------------------------------background

local background = scene:createLayout(colors.cyan, 1, 1, scene.sizeX, scene.sizeY, false, true)
background:createLabel(_OSVERSION)

----------------------------------------------

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

        getWindowPos = getWindowPos,
        createMessage = createMessage,
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

gui:selectScene(scene)
runProgramm("hello")
runProgramm("seekbar")
gui:run()