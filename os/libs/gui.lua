local drawer = require("drawer")
local background = require("background")

----------------------------------------------FUNCS


----------------------------------------------WIDGET

local createWidget
do
    local function destroy(self)
        table.removeMatches(self.layout.widgets, self)
    end

    function createWidget(self)
        local widget = {}

        widget.destroy = destroy

        self.layout = self
        table.insert(self.widgets, widget)
        return widget
    end
end

----------------------------------------------LAYOUT

local createLayout
do
    local function destroy(self)
        table.removeMatches(self.scene.layouts, self)
    end

    function createLayout(self, bg, sizeX, sizeY, dragged)
        local layout = {}
        layout.bg = bg and (type(bg) == "number" and {bg, self.gui.drawzone.maxFg, " "} or bg) or {0, self.gui.drawzone.maxFg, " "}
        layout.sizeX = sizeX or self.gui.drawzone.maxSizeX
        layout.sizeY = sizeY or self.gui.drawzone.maxSizeY
        layout.dragged = dragged
        layout.widgets = {}

        layout.destroy = destroy

        layout.createWidget = createWidget

        self.scene = self
        table.insert(self.layouts, layout)
        return layout
    end
end

----------------------------------------------SCENE

local createScene
do
    local function destroy(self)
        table.removeMatches(self.gui.scenes, self)
    end

    function createScene(self, bg, sizeX, sizeY, palette, usingTheDefaultPalette)
        local scene = {}
        scene.bg = bg and (type(bg) == "number" and {bg, self.drawzone.maxFg, " "} or bg) or {0, self.drawzone.maxFg, " "}
        scene.sizeX = sizeX or self.drawzone.maxSizeX
        scene.sizeY = sizeY or self.drawzone.maxSizeY
        scene.palette = palette
        scene.usingTheDefaultPalette = usingTheDefaultPalette
        scene.layouts = {}

        scene.destroy = destroy

        scene.createLayout = createLayout

        scene.gui = self
        table.insert(self.scenes, scene)
        return scene
    end
end

----------------------------------------------GUI

do
    local function listen(self, eventData)
        if eventData[2] == obj.drawzone.settings.screen then
            
        end
        if table.contains(self.keyboards, eventData[2]) then
            
        end 
    end

    local function tick(self)
        if self.redrawFlag then
            self:draw()
            self.redrawFlag = nil
        end
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

    local function draw(self)
        self.drawzone:draw_end()
        self.drawzone:clear(table.unpack(self.scene.bg))
        for _, layout in ipairs(self.scene.layouts) do
            layout:draw()
        end
        self.drawzone:draw_begin()
    end

    local function selectScene(self, scene)
        self.scene = scene
        self.drawzone:setPalette(scene.palette)
        self.drawzone:setResolution(scene.sizeX, scene.sizeY)
        self.redrawFlag = true
    end

    return {create = function(settings)
        local obj = {redrawFlag = true}
        obj.running = true
        obj.settings = settings or {}
        obj.drawzone = drawer.create(obj.settings.renderSettings)
        obj.keyboards = component.invoke(obj.drawzone.screen, "getKeyboards")
        obj.scenes = {}

        obj.listen = listen
        obj.tick = tick
        obj.exit = exit
        obj.run = run
        obj.draw = draw
        obj.selectScene = selectScene


        obj.createScene = createScene
        
        background.addListen(function(...)
            obj.listen(obj, {...})
        end)
        return obj
    end}
end