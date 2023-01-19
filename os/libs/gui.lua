local drawer = require("drawer")
local advmath = require("advmath")
local colors = require("colors")

----------------------------------------------FUNCS

local function mathColor(self, color)
    return color and (type(color) == "number" and {color, 0xFFFFFF, " "} or color) or {0, 0xFFFFFF, " "}
end

local function fillFakeColor(self, posX, posY, sizeX, sizeY, text, bg, fg) --фековый цвет позваляет смешивать цвета символами unicode, и отрисовывать серый даже на экранах первого уровня
    self.drawzone:fill(posX, posY, sizeX, sizeY, table.unpack(bg))
    local centerX, centerY = math.floor(posX + (sizeX / 2)), math.floor(posY + (sizeY / 2))
    self.drawzone:set(centerX - math.floor(unicode.len(text) / 2), centerY, bg[1], fg[1], text)
end

local function touchInBox(box, eventData, startX, startY)
    if not startX then startX = 1 end
    if not startY then startY = 1 end
    local tx, ty = eventData[3] - (startX - 1), eventData[4] - (startY - 1)
    return tx >= box.posX and ty >= box.posY and tx < (box.posX + box.sizeX) and ty < (box.posY + box.sizeY)
end

local function getColor(self, name)
    if self.drawzone.usingTheDefaultPalette then
        return colors[name]
    else
        return drawer.palette_defaultTier2[colors[name]]
    end
end

----------------------------------------------WIDGET

local createWidget
do
    ----------------------------------------------functions

    local function mathPos(self)
        return self.posX + (self.layout.posX - 1), self.posY + (self.layout.posY - 1)
    end

    local function callback(self, name, ...)
        return (self.settings[name] or function() end)(...)
    end

    ----------------------------------------------callbacks

    local function listen(self, eventData)
        if self.settings.type == "button" then
            local touchinbox = touchInBox(self, eventData, self.layout.posX, self.layout.posY)
            if self.settings.togle then
                if eventData[1] == "touch" and touchinbox then
                    self.state = not self.state

                    self.gui:draw()

                    if self.state then
                        callback(self, "onClick", eventData[6])
                    else
                        callback(self, "onRelease", eventData[6])
                        callback(self, "onReleaseInBox", eventData[6])
                    end
                end
            else
                if self.settings.notAutoReleased then
                    --вы можете разом активировать несколько notAutoReleased кнопок просто свайпнув по ним, и разом отпустить отпустив кнопку мыши
                    if (eventData[1] == "touch" or eventData[1] == "drag") and touchinbox then
                        if not self.state then
                            self.state = true
                            self.gui:draw()
                            callback(self, "onClick", eventData[6])
                        end
                    elseif eventData[1] == "drop" then
                        if self.state then
                           self.state = false
                            self.gui.redrawFlag = true
                            callback(self, "onRelease", eventData[6])
                            if touchinbox then
                                callback(self, "onReleaseInBox", eventData[6])
                            end
                        end
                    end
                else
                    if eventData[1] == "touch" and touchinbox then
                        --спит оставшееся время если функция отработала быстрее 0.5 секунд
                        local function sleep(uptime)
                            os.sleep(0.1 - advmath.constrain(computer.uptime() - uptime, 0, 0.1), function()end)
                        end


                        
                        self.state = true
                        self.gui:draw()
                        local uptime = computer.uptime()
                        callback(self, "onClick", eventData[6])
                        sleep(uptime)

                        self.state = false
                        self.gui:draw()
                        local uptime = computer.uptime()
                        callback(self, "onRelease", eventData[6])
                        callback(self, "onReleaseInBox", eventData[6])
                        sleep(uptime)
                    end
                end
            end
            return touchinbox
        end
    end

    ----------------------------------------------interface

    local function destroy(self)
        table.removeMatches(self.layout.widgets, self)
    end

    local function draw(self)
        local posX, posY = mathPos(self)

        if self.settings.type == "text" or self.settings.type == "button" then
            local bg, fg = self.settings.bg, self.settings.fg
            if not bg then bg = 0 end
            if not fg then fg = self.maxFg end
            if self.state then
                bg = self.settings.pressed_bg
                fg = self.settings.pressed_fg
                if not bg then bg = self.maxFg end
                if not fg then fg = 0 end
            end
            bg = mathColor(self, bg)
            fg = mathColor(self, fg)
            
            fillFakeColor(self,
                posX,
                posY,
                self.sizeX,
                self.sizeY,
                self.settings.text,
                bg,
                fg
            )
        end
    end

    local function setParam(self, name, value)
        self.settings[name] = value
        self[name] = value
    end

    local function getParam(self, name)
        return self[name]
    end

    function createWidget(self, settings)
        local widget = {}
        widget.settings = settings

        widget.state = settings.state or false
        widget.posX = settings.posX
        widget.posY = settings.posY
        widget.sizeX = settings.sizeX
        widget.sizeY = settings.sizeY

        widget.destroy = destroy
        widget.draw = draw
        widget.setParam = setParam
        widget.getParam = getParam

        widget.listen = listen

        widget.layout = self
        self.drawzone:setUsingTheDefaultPalette(self.scene.usingTheDefaultPalette) --для правильной работы mathColor
        widget.drawzone = self.drawzone
        widget.maxFg = self.drawzone.maxFg
        widget.gui = self.scene.gui
        table.insert(self.widgets, widget)
        return widget
    end
end

----------------------------------------------LAYOUT

local createLayout
do
    local function destroy(self)
        table.removeMatches(self.scene.layouts, self)
        self.scene.gui.redrawFlag = true
    end

    local function draw(self)
        self.drawzone:fill(self.posX, self.posY, self.sizeX, self.sizeY, table.unpack(self.bg))
        for _, widget in ipairs(self.widgets) do
            widget:draw()
        end
    end

    local function listen(self, eventData)
        local tx, ty = self.tx, self.ty
        if eventData[1] == "touch" or eventData[1] == "drag" then
            tx, ty = eventData[3], eventData[4]
        end

        local moveLock
        if not self.selected then
            for _, widget in ipairs(self.widgets) do
                if widget:listen(eventData) then
                    moveLock = true
                end
            end
        end

        if eventData[1] == "touch" then
            if not self.selected and not moveLock then
                self.selected = touchInBox(self, eventData)
            end
        elseif eventData[1] == "drop" then
            self.selected = false
        end

        if not moveLock and self.selected and eventData[1] == "drag" and tx and self.tx and self.dragged then
            local moveX, moveY = tx - self.tx, ty - self.ty
            if moveX ~= 0 or moveY ~= 0 then
                self.posX = self.posX + moveX
                self.posY = self.posY + moveY
                self.scene.gui.redrawFlag = true
            end
        end

        self.tx = tx
        self.ty = ty
    end

    --------------------------------------------------------------auto creators

    local function createExitButton(self, posX, posY)
        return self:createWidget{
            type = "button",
        
            posX = posX or self.sizeX,
            posY = posY or 1,
            sizeX = 1,
            sizeY = 1,
            text = "X",
        
            bg = getColor(self, "red"),
            fg = getColor(self, "white"),
            pressed_bg = getColor(self, "brown"),
            pressed_fg = getColor(self, "black"),
        
            notAutoReleased = true,

            onReleaseInBox = function()
                self:destroy()
            end
        }
    end
    
    --notSelectable стоит использовать только для background layout`а, иначе вы можете сломать всю сцену
    function createLayout(self, bg, posX, posY, sizeX, sizeY, dragged, doNotMoveToTheUpperLevel)
        local layout = {}

        self.drawzone:setUsingTheDefaultPalette(self.usingTheDefaultPalette) --для правильной работы mathColor

        layout.bg = mathColor(self, bg)
        layout.posX = posX or 1
        layout.posY = posY or 1
        layout.sizeX = sizeX or self.gui.drawzone.maxSizeX
        layout.sizeY = sizeY or self.gui.drawzone.maxSizeY
        layout.dragged = dragged
        layout.doNotMoveToTheUpperLevel = doNotMoveToTheUpperLevel
        layout.widgets = {}

        layout.destroy = destroy
        layout.draw = draw
        layout.listen = listen

        layout.createWidget = createWidget

        layout.createExitButton = createExitButton

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
        local upLayout = self.layouts[#self.layouts]
        if eventData[1] == "touch" or eventData[1] == "drag" or eventData[1] == "scroll" then
            if self.lastLayout then
                if not self.lastLayout.selected then
                    self.lastLayout = nil
                else
                    self.lastLayout:listen(eventData)
                    return
                end
            end

            for i = #self.layouts, 1, -1 do
                local layout = self.layouts[i]
                if touchInBox(layout, eventData) then
                    if not layout.doNotMoveToTheUpperLevel then
                        --table.remove(self.layouts, #self.layouts)

                        table.remove(self.layouts, i)
                        table.insert(self.layouts, layout)

                        
                        --table.insert(self.layouts, 1, upLayout)

                        self.gui.redrawFlag = true
                    end
                    layout:listen(eventData)
                    self.lastLayout = layout
                    break
                end
            end
        else
            for _, layout in ipairs(self.layouts) do
                layout:listen(eventData)
            end
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
        if eventData[2] == self.drawzone.screen then
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
        end
    end

    local function run(self, func, time)
        tick(self)
        while self.running do
            local eventData = {computer.pullSignal(time)}
            self:listen(eventData)

            tick(self)
            if func then
                func()
            end
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
        self.drawzone.flushed = true
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
        return obj
    end}
end