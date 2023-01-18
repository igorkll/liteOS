local drawer = require("drawer")
local background = require("background")

----------------------------------------------WIDGET



----------------------------------------------SCENE

local function createLayout()
    
end

local function createScene(sizeX, sizeY, palette)
    local scene = {}
    scene.sizeX = sizeX
    scene.sizeY = sizeY
    scene.palette = palette

    scene.createLayout = createLayout
    return scene
end

----------------------------------------------GUI

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

local function selectScene(self, scene)
    self.scene = scene
    
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

    obj.createScene = createScene
    obj.selectScene = selectScene
    
    background.addListen(function(...)
        obj.listen(obj, {...})
    end)
    return obj
end}