local drawer = {}

function drawer.create() --создает графическую системму, состоящию из видеокарты и монитора
    local gpu = component.proxy(component.list("gpu")() or "")
    local screen = component.list("screen")()

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

        return obj
    end
end

------------------------------------------------------------------------

function drawer:begin_draw()
    if self.hardwareBuffer then
        self.gpu.setActiveBuffer(self.hardwareBuffer)
    end
end

function drawer:end_draw()
    if self.hardwareBuffer then
        self.gpu.bitblt()
    end
end

------------------------------------------------------------------------

function drawer:set()
    
end

function drawer:fill()
    
end




return drawer