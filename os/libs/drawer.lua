local drawer = {}

function drawer:create()
    
end

function drawer:init()--инициализация графической системмы
    self.gpu.bind(self.screen)
    local rx, ry = self.gpu.maxResolution()

    if self.gpu.setActiveBuffer then --если версия open computers поддерживает буферы
        self.gpu.setActiveBuffer(0) --лутще их удалить, малоли что там будет
        self.gpu.freeAllBuffers()
    end

    self.gpu.setDepth(1) --сброс палитры
    self.gpu.setDepth(self.gpu.maxDepth())

    self.gpu.setResolution(rx, ry) --ставим максимальное разрешения

    self.gpu.setBackground(0) --цвета по умалчанию
    self.gpu.setForeground(0xFFFFFF)

    self.gpu.fill(1, 1, rx, ry, " ") --очистка экрана
end


return drawer