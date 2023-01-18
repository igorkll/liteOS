local drawer = require("drawer")
local background = require("background")

----------------------------------------------

local function createScene(rx, ry, palette)
    
end

----------------------------------------------

local function listen(self, eventData)
    if eventData[2] == obj.drawzone.settings.screen then
        
    end
    if table.contains(self.keyboards, eventData[2]) then
        
    end 
end

local function tick()
    
end

local function exit(self)
    if self.running then
        self.running = false
        self.drawzone:destroy()
        background.removeListen(self.listen)
    end
end

local function run(self, func)
    while self.running do
        tick()
        if func then
            func()
        end
    end
end

return {create = function(settings)
    local obj = {}
    obj.running = true
    obj.settings = settings or {}
    obj.drawzone = drawer.create(settings.renderSettings)
    obj.keyboards = component.invoke(obj.drawzone.settings.screen, "getKeyboards")

    obj.listen = listen
    obj.tick = tick
    obj.exit = exit
    obj.run = run

    background.addListen(function(...)
        obj.listen(obj, {...})
    end)
    return obj
end}