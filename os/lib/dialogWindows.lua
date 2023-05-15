local system = require("system")
local gui = system.gui

----------------------------------------------

local dialogWindows = {}
dialogWindows.windowSizeX = 25
dialogWindows.windowSizeY = 6

function dialogWindows.getWindowPos(scene, sizeX, sizeY)
    sizeX = sizeX or dialogWindows.windowSizeX
    sizeY = sizeY or dialogWindows.windowSizeY
    return math.round((scene.sizeX / 2) - (sizeX / 2)), math.round((scene.sizeY / 2) - (sizeY / 2))
end

function dialogWindows.getWindowSize(scene, minX, minY)
    return math.max(dialogWindows.windowSizeX, minX or -1), math.max(dialogWindows.windowSizeY, minY or -1)
end

function dialogWindows.message(scene, label, text, color, textColor)
    color = color or gui:getColor("gray")
    textColor = textColor or gui:getColor("white")
    label = label or "alert message"
    text = text or ""

    local posX, posY = dialogWindows.getWindowPos(scene, dialogWindows.windowSizeX, dialogWindows.windowSizeY)
    local layout = scene:createLayout(
        color,
        posX,
        posY,
        dialogWindows.windowSizeX,
        dialogWindows.windowSizeY,
        true
    )
    layout:createExitButton()
    layout:createLabel(label)
    layout:createFullscreenText(text, color, textColor)

    local returnTbl = {}
    function layout.onDestroy()
        returnTbl.destroyed = true
    end
    return layout, returnTbl
end

return dialogWindows