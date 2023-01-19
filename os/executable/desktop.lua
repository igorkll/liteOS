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
    drawer.palette_defaultTier2,
    true
)

----------------------------------------------

local function getWindowPos(sizeX, sizeY)
    local scene
end

local function createMessage()
    scene:createLayout()
end

local function runProgramm(name)
    local code, err = programs.load(name, env.createProgrammEnv({
        gui = gui,
        scene = scene,
        recommendedPosX = 4,
        recommendedPosY = 4
    }))
    
end