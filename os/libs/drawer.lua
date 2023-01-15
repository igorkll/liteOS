--[[
    для коректной отрисовке необходимо сначала вызвать draw_begin
    отрисовать все что необходимо а зачем вызвать draw_end
    между draw_begin и draw_end не должно быть прирываний(тех что могут переключить процесс)
    так же в блоке отрисовке нужно вызывать только draw utiles методы методы settings следует вызывать до него
]]

local drawer = {}

function drawer.create(settings) --создает графическую системму, состоящию из видеокарты и монитора
    local gpu = component.proxy(component.list("gpu")() or "")
    local screen = settings.screen or component.list("screen")()

    if gpu and screen then
        local obj = setmetatable({
            gpu = gpu,
            screen = screen
        }, {_index = drawer})

        gpu.bind(screen)
        local rx, ry = gpu.maxResolution()

        gpu.setDepth(1) --сброс палитры
        gpu.setDepth(gpu.maxDepth())

        gpu.setResolution(rx, ry) --ставим максимальное разрешения

        gpu.setBackground(0) --цвета по умалчанию
        gpu.setForeground(0xFFFFFF)

        gpu.fill(1, 1, rx, ry, " ") --очистка экрана

        obj.depth = gpu.getDepth()
        obj.sizeX = rx
        obj.sizeY = ry

        ------------------------------------

        if obj.depth > 1 then
            obj.palette = {}
            for i = 0, 15 do
                obj.palette[i] = gpu.getPaletteColor(i)
            end
        end

        if gpu.setActiveBuffer then
            obj.bufferSupport = true
        end

        return obj
    end
end

------------------------------------------------------------------------settings

function drawer:_begin()
    if self.gpu.getScreen() ~= self.screen then
        self.gpu.bind(self.screen, false)
    end
    if self.bufferSupport then
        self.gpu.setActiveBuffer(0)
    end
end

function drawer:setResolution(rx, ry)
    if self.sizeX == rx and self.sizeY == ry then
        return false
    end

    self:_begin()
    self.gpu.setResolution(rx, ry)
    if self.bufferSupport and self.hardwareBuffer then
        local newbuffer = self.gpu.allocateBuffer(rx, ry)
        self.gpu.bitblt(newbuffer, nil, nil, nil, nil, self.hardwareBuffer)
        self.gpu.freeBuffer(self.hardwareBuffer)
        self.hardwareBuffer = newbuffer
    end

    self.sizeX = rx
    self.sizeY = ry
    return true
end

------------------------------------------------------------------------service

function drawer:draw_begin()
    local function applyPalette()
        if self.palette then
            for i = 0, 15 do
                if self.palette[i] ~= self.gpu.getPaletteColor(i) then
                    self.gpu.setPaletteColor(i)
                end
            end
        end
    end

    self:_begin()
    applyPalette()
    if self.bufferSupport then
        if self.hardwareBuffer then
            self.gpu.setActiveBuffer(self.hardwareBuffer)
            applyPalette()
        else
            self.gpu.setActiveBuffer(0)
        end
    end
end

function drawer:draw_end()
    if self.bufferSupport and self.hardwareBuffer then
        self.gpu.bitblt()
    end
end

------------------------------------------------------------------------draw utiles

function drawer:set()
    
end

function drawer:fill()
    
end


return drawer