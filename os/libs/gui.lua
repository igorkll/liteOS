local drawer = require("drawer")
local background = require("background")

----------------------------------------------FUNCS


----------------------------------------------WIDGET

local createWidget
do
    local function mathPos(self)
        return self.settings.posX + (self.layout.posX - 1), self.settings.posY + (self.layout.posY - 1)
    end


    local function destroy(self)
        table.removeMatches(self.layout.widgets, self)
    end

    local function draw(self)
        local sizeX, sizeY = mathPos(self)

    end

    function createWidget(self, settings)
        local widget = {}
        widget.settings = settings

        widget.destroy = destroy
        widget.draw = draw

        widget.layout = self
        widget.drawzone = self.drawzone
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

    local function draw(self)
        self.drawzone:fill(self.posX, self.posY, self.sizeX, self.sizeY, table.unpack(self.bg))
        for _, widget in ipairs(self.widgets) do
            widget:draw()
        end
    end

    function createLayout(self, bg, posX, posY, sizeX, sizeY, dragged)
        local layout = {}
        layout.bg = bg and (type(bg) == "number" and {bg, self.gui.drawzone.maxFg, " "} or bg) or {0, self.gui.drawzone.maxFg, " "}
        layout.posX = posX or 1
        layout.posY = posY or 1
        layout.sizeX = sizeX or self.gui.drawzone.maxSizeX
        layout.sizeY = sizeY or self.gui.drawzone.maxSizeY
        layout.dragged = dragged
        layout.widgets = {}

        layout.destroy = destroy
        layout.draw = draw

        layout.createWidget = createWidget

        layout.scene = self
        layout.drawzone = self.drawzone
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

    local function draw(self)
        self.drawzone:clear(table.unpack(self.bg))
        for _, layout in ipairs(self.layouts) do
            layout:draw()
        end
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
        scene.draw = draw

        scene.createLayout = createLayout

        scene.gui = self
        scene.drawzone = self.drawzone
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
        self.scene:draw()
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