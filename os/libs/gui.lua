local drawer = require("drawer")
local background = require("background")

----------------------------------------------WIDGET



----------------------------------------------SCENE

local function createLayout()
    
end

local function createScene(self, bg, sizeX, sizeY, palette)
    local scene = {}
    scene.bg = bg and (type(bg) == "number" and {bg, self.drawzone.maxFg, " "} or bg) or {0, self.drawzone.maxFg, " "}
    scene.sizeX = sizeX
    scene.sizeY = sizeY
    scene.palette = palette
    scene.layouts = {}

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

local function redraw(self)
    self.drawzone:draw_end()

    self.drawzone:clear(table.unpack(self.scene.bg))

    self.drawzone:draw_begin()
end

local function selectScene(self, scene)
    self.scene = scene
    self.drawzone:setPalette(scene.palette)
    self.drawzone:setResolution(scene.sizeX, scene.sizeY)
end

return {create = function(settings)
    local obj = {}
    obj.running = true
    obj.settings = settings or {}
    obj.drawzone = drawer.create(settings.renderSettings)
    obj.keyboards = component.invoke(obj.drawzone.settings.screen, "getKeyboards")
    obj.scenes = {}

    obj.listen = listen
    obj.tick = tick
    obj.exit = exit
    obj.run = run
    obj.redraw = redraw
    obj.selectScene = selectScene


    obj.createScene = createScene
    
    background.addListen(function(...)
        obj.listen(obj, {...})
    end)
    return obj
end}