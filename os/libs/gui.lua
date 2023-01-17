local drawer = require("drawer")
local background = require("background")

----------------------------------------------

local function listen(...)
    local eventData = {...}
    if eventData[2] == obj.drawzone.settings.screen then
        
    end
    if table.contains(component.invoke(obj.drawzone.settings.screen, "getKeyboards"), eventData[2]) then
        
    end 
end

local function tick()
    
end

local function exit(self)
    self.running = false
    self.drawzone:destroy()
    background.removeListen(self.listen)
end

local function run(self, func)
    while self.running do
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

    obj.listen = listen
    obj.tick = tick
    obj.exit = exit
    obj.run = run

    background.addListen(obj.listen)

    return obj
end}