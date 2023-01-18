local drawer = require("drawer")
local background = require("background")

----------------------------------------------FUNCS

local function mathColor(self, color)
    return color and (type(color) == "number" and {color, self.drawzone.maxFg, " "} or color) or {0, self.drawzone.maxFg, " "}
end

local function fillFakeColor(self, posX, posY, sizeX, sizeY, text, bg, fg) --фековый цвет позваляет смешивать цвета символами unicode, и отрисовывать серый даже на экранах первого уровня
    self.drawzone:fill(posX, posY, sizeX, sizeY, table.unpack(bg))
    local centerX, centerY = math.floor(posX + (sizeX / 2)), math.floor(posY + (sizeY / 2))
    self.drawzone:set(centerX - math.floor(unicode.len(text) / 2), centerY, bg[1], fg[1], text)
end

----------------------------------------------WIDGET

local createWidget
do
    ----------------------------------------------functions

    local function getColors(self)
        return mathColor(self, self.settings.bg), mathColor(self, self.settings.fg)
    end

    local function mathPos(self)
        return self.settings.posX + (self.layout.posX - 1), self.settings.posY + (self.layout.posY - 1)
    end

    local function callback(self, name, ...)
        return (self.settings[name] or function() end)(...)
    end

    ----------------------------------------------callbacks

    local function listen(self, eventData)
        
    end

    ----------------------------------------------interface

    local function destroy(self)
        table.removeMatches(self.layout.widgets, self)
    end

    local function draw(self)
        local posX, posY = mathPos(self)
        

        if self.settings.type == "text" or self.settings.type == "button" then
            local posX, posY = mathPos()

            local bg, fg = self.settings.bg, self.settings.fg
            if self.state then
                bg = self.settings.pressed_bg or self.settings.bg
                fg = self.settings.pressed_fg or self.settings.fg
            end
            if not bg then bg = {0, 0, " "} end
            if not fg then fg = {self.drawzone.maxFg, 0, " "} end

            fillFakeColor(self,
                posX,
                posY,
                self.settings.sizeX,
                self.settings.sizeY,
                self.settings.text,
                bg,
                fg
            )
        end
    end

    function createWidget(self, settings)
        local widget = {}
        widget.settings = settings

        widget.destroy = destroy
        widget.draw = draw

        widget.listen = listen

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

    local function listen(self, eventData)
        for _, widget in ipairs(self.widgets) do
            widget:listen(eventData)
        end
    end

    function createLayout(self, bg, posX, posY, sizeX, sizeY, dragged)
        local layout = {}
        layout.bg = mathColor(self, bg)
        layout.posX = posX or 1
        layout.posY = posY or 1
        layout.sizeX = sizeX or self.gui.drawzone.maxSizeX
        layout.sizeY = sizeY or self.gui.drawzone.maxSizeY
        layout.dragged = dragged
        layout.widgets = {}

        layout.destroy = destroy
        layout.draw = draw
        layout.listen = listen

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

    local function listen(self, eventData)
        for _, layout in ipairs(self.layouts) do
            layout:listen(eventData)
        end
    end

    function createScene(self, bg, sizeX, sizeY, palette, usingTheDefaultPalette)
        local scene = {}

        self.drawzone:setUsingTheDefaultPalette(usingTheDefaultPalette) --для правильной работы mathColor
        
        scene.bg = mathColor(self, bg)
        scene.sizeX = sizeX or self.drawzone.maxSizeX
        scene.sizeY = sizeY or self.drawzone.maxSizeY
        scene.palette = palette
        scene.usingTheDefaultPalette = usingTheDefaultPalette
        scene.layouts = {}

        scene.destroy = destroy
        scene.draw = draw
        scene.listen = listen

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
        if eventData[2] == self.drawzone.settings.screen then
            self.scene:listen(eventData)
        elseif table.contains(self.keyboards, eventData[2]) then
            self.scene:listen(eventData)
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
            tick(self)
            if func then
                func()
            end
            computer.pullSignal(0.5)
        end
    end

    local function draw(self)
        self.drawzone:draw_begin()
        self.scene:draw()
        self.drawzone:draw_end()
    end

    local function selectScene(self, scene)
        self.scene = scene
        self.drawzone:setPalette(scene.palette)
        self.drawzone:setUsingTheDefaultPalette(scene.usingTheDefaultPalette)
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
            obj:listen({...})
        end)
        return obj
    end}
end