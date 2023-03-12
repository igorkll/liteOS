local system = require("system")
local gui = system.instance

----------------------------------------------

local dialogWindows = {}

function dialogWindows.message(label, text, color, textColor)
    color = color or gui:getColor("gray")
    textColor = textColor or gui:getColor("white")
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
    layout:createFullscreenText(text, color, textColor)

    local returnTbl = {}
    function layout.onDestroy()
        returnTbl.destroyed = true
    end
    return returnTbl
end

return dialogWindows