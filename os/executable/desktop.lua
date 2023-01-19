local programs = require("programs")
local colors = require("colors")
local drawer = require("drawer")
local env = require("env")
local gui = require("gui").create()

----------------------------------------------

local scene = gui:createScene(
    colors.cyan,
    gui.drawzone.maxSizeX,
    gui.drawzone.maxSizeY,
    drawer.palette_computercraft,
    true
)

local standardWindowsSizeX, standardWindowsSizeY = 32, 8

----------------------------------------------background

local background = scene:createLayout(colors.cyan, 1, 1, scene.sizeX, scene.sizeY, false, true)
background:createLabel(_OSVERSION)

----------------------------------------------

local function getWindowPos(sizeX, sizeY)
    return math.floor((scene.sizeX / 2) - (sizeX / 2)), math.floor((scene.sizeY / 2) - (sizeY / 2))
end

local function createMessage(color, label, text)
    color = color or colors.gray
    label = label or "alert message"
    text = text or ""
    local posX, posY = getWindowPos(16, 16)
    
    local layout = scene:createLayout(
        color,
        posX,
        posY,
        standardWindowsSizeX,
        standardWindowsSizeY,
        true
    )
    layout:createLabel(label)
    layout:createFullscreenText(text, color, colors.white)
    layout:createExitButton()
end

local function runProgramm(name)
    local code, err = programs.load(name, env.createProgrammEnv({
        gui = gui,
        scene = scene,

        recommendedPosX = 4,
        recommendedPosY = 4,
        recommendedSizeX = standardWindowsSizeX,
        recommendedSizeY = standardWindowsSizeY,

        getWindowPos = getWindowPos,
        createMessage = createMessage,
    }))
    if not code then
        createMessage(colors.red, err or "unknown", "error")
    end

    local ok, err = pcall(code)
    if not ok then
        createMessage(colors.red, err or "unknown", "error")
    end
end

gui:selectScene(scene)
runProgramm("hello")
gui:run()