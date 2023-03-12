local colors = require("colors")
local drawer = require("drawer")
local system = require("system")

local gui = system.gui
local scene = gui.scene
local old_scene = gui.scene

--------------------------------------------------------------------------------------scene1

scene1 = gui:createScene(colors.black, 80, 25, drawer.palette_computercraft, true)

local function createSceneselector()
    local layout = scene1:createLayout(colors.lime, 3, 3, 32, 8, true)
    local text = layout:createWidget({
        type = "text",

        posX = 1,
        posY = 1,
        sizeX = 31,
        sizeY = 1,
        text = "current scene 1",
    })
    local button = layout:createWidget({
        type = "button",

        posX = 2,
        posY = 4,
        sizeX = 16,
        sizeY = 1,
        text = "to scene 2",

        onClick = function()
            gui:selectScene(scene2)
        end
    })

    layout:createExitButton()
end

local function createControl()
    local layout = scene1:createLayout(colors.red, 6, 6, 32, 8, true)
    local label = layout:createWidget({
        type = "text",

        posX = 1,
        posY = 1,
        sizeX = 31,
        sizeY = 1,
        text = "control",
    })
    local button = layout:createWidget({
        type = "button",

        posX = 2,
        posY = 3,
        sizeX = 16,
        sizeY = 1,
        text = "reboot",

        notAutoReleased = true,

        onReleaseInBox = function()
            computer.shutdown(true)
        end
    })
    local button = layout:createWidget({
        type = "button",

        posX = 2,
        posY = 4,
        sizeX = 16,
        sizeY = 1,
        text = "shutdown",

        notAutoReleased = true,

        onReleaseInBox = function()
            computer.shutdown()
        end
    })
    local button2 = layout:createWidget({
        type = "button",

        posX = 2,
        posY = 5,
        sizeX = 16,
        sizeY = 1,
        text = "exit",

        notAutoReleased = true,

        onReleaseInBox = function()
            scene1:destroy()
            scene2:destroy()
            gui:selectScene(old_scene)
        end
    })

    layout:createExitButton()
end

local function createNicknamegetter()
    local layout = scene1:createLayout(colors.yellow, 9, 9, 32, 8, true)
    local label = layout:createWidget({
        type = "text",

        posX = 1,
        posY = 1,
        sizeX = 31,
        sizeY = 1,
        text = "nickname recipient",
    })
    local nickname = layout:createWidget({
        type = "text",

        posX = 2,
        posY = 4,
        sizeX = 24,
        sizeY = 1,
        text = "-",
    })
    local button = layout:createWidget({
        type = "button",

        posX = 2,
        posY = 3,
        sizeX = 24,
        sizeY = 1,
        text = "get your nickname",


        onClick = function(name)
            nickname:setParam("text", name or "-")
        end
    })

    layout:createExitButton()
end




scene1_window3 = scene1:createLayout(colors.cyan, 1, 1, scene1.sizeX, scene1.sizeY, false, true)
scene1_window3_text = scene1_window3:createWidget({
    type = "text",

    posX = 2,
    posY = 2,
    sizeX = 16,
    sizeY = 1,
    text = "gui demo",
})
scene1_window3_button = scene1_window3:createWidget({
    type = "button",

    posX = 2,
    posY = 4,
    sizeX = 24,
    sizeY = 1,
    text = "not auto released",

    notAutoReleased = true,

    onClick = function()
        computer.beep(500)
    end,
    onRelease = function()
        computer.beep(200)
    end
})
scene1_window3_button2 = scene1_window3:createWidget({
    type = "button",

    posX = 2,
    posY = 5,
    sizeX = 24,
    sizeY = 1,
    text = "auto released",

    onClick = function()
        computer.beep(2000)
    end,
    onRelease = function()
        computer.beep(1500)
    end
})
scene1_window3_button2 = scene1_window3:createWidget({
    type = "button",

    posX = 2,
    posY = 6,
    sizeX = 24,
    sizeY = 1,
    text = "togle button",

    togle = true,

    onClick = function()
        computer.beep(100)
    end,
    onRelease = function()
        computer.beep(50)
    end
})

for i = 1, 8 do
    scene1_window3:createWidget({
        type = "button",
    
        posX = scene1_window3.sizeX - 13,
        posY = 1 + i,
        sizeX = 12,
        sizeY = 1,
        text = tostring(i) .. ". swipe on us",
    
        notAutoReleased = true
    })
end

scene1_window3:createWidget({
    type = "button",

    posX = 2,
    posY = 8,
    sizeX = 32,
    sizeY = 1,
    text = "open nickname getter",

    onClick = function()
        createNicknamegetter()
    end
})
scene1_window3:createWidget({
    type = "button",

    posX = 2,
    posY = 9,
    sizeX = 32,
    sizeY = 1,
    text = "open control panel",

    onClick = function()
        createControl()
    end
})
scene1_window3:createWidget({
    type = "button",

    posX = 2,
    posY = 10,
    sizeX = 32,
    sizeY = 1,
    text = "open scene selector",

    onClick = function()
        createSceneselector()
    end
})

---------------------------------------------------------------------------------------scene2

scene2 = gui:createScene(colors.green, 80, 10, drawer.palette_defaultTier2, true)
scene2_window1 = scene2:createLayout(colors.red, 3, 3, 18, 8, true)
scene2_window1_text = scene2_window1:createWidget({
    type = "text",

    posX = 3,
    posY = 2,
    sizeX = 14,
    sizeY = 1,
    text = "scene 2",
})
scene2_window1_button = scene2_window1:createWidget({
    type = "button",

    posX = 3,
    posY = 4,
    sizeX = 14,
    sizeY = 1,
    text = "to scene 1",

    onClick = function()
        gui:selectScene(scene1)
    end
})
scene2_window1_button = scene2_window1:createWidget({
    type = "button",

    posX = 3,
    posY = 6,
    sizeX = 14,
    sizeY = 1,
    text = "exit",

    onClick = function()
        scene1:destroy()
        scene2:destroy()
        gui:selectScene(old_scene)
    end
})

gui:selectScene(scene1)