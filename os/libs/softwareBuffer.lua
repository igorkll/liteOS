return {create = function(gpu_address, usePaletteIndex)
    local invoke, insert, concat, len, sub = component.invoke, table.insert, table.concat, unicode.len, unicode.sub

    local currentFrameBackgrounds, currentFrameForegrounds, currentFrameSymbols, newFrameBackgrounds, newFrameForegrounds, newFrameSymbols
    local bufferWidth, bufferHeight, drawLimitX1, drawLimitY1, drawLimitX2, drawLimitY2


    --------------------------------------------------------------------------------

    local function flush(width, height)
        if not width or not height then
            width, height = invoke(gpu_address, "getResolution")
        end

        currentFrameBackgrounds, currentFrameForegrounds, currentFrameSymbols, newFrameBackgrounds, newFrameForegrounds, newFrameSymbols = {}, {}, {}, {}, {}, {}
        bufferWidth = width
        bufferHeight = height
        
        drawLimitX1, drawLimitY1, drawLimitX2, drawLimitY2 = 1, 1, bufferWidth, bufferHeight

        for y = 1, bufferHeight do
            for x = 1, bufferWidth do
                insert(currentFrameBackgrounds, 0)
                insert(currentFrameForegrounds, usePaletteIndex and 15 or 0xFFFFFF)
                insert(currentFrameSymbols, " ")

                insert(newFrameBackgrounds, 0)
                insert(newFrameForegrounds, usePaletteIndex and 15 or 0xFFFFFF)
                insert(newFrameSymbols, " ")
            end
        end
    end
    flush(invoke(gpu_address, "getResolution"))

    local function setResolution(width, height)
        invoke(gpu_address, "setResolution", width, height)
        flush(width, height)
    end
    
    local function getResolution()
        return bufferWidth, bufferHeight
    end

    --------------------------------------------------------------------------------

    local function get(x, y)
        if x >= 1 and y >= 1 and x <= bufferWidth and y <= bufferHeight then
            local index = bufferWidth * (y - 1) + x
            return newFrameBackgrounds[index], newFrameForegrounds[index], newFrameSymbols[index]
        else
            return 0, 0, " "
        end
    end

    local function set(x, y, background, foreground, text)
        for i = 1, len(text) do
            if x >= drawLimitX1 and y >= drawLimitY1 and x <= drawLimitX2 and y <= drawLimitY2 then
                local index = bufferWidth * (y - 1) + x
                newFrameBackgrounds[index], newFrameForegrounds[index], newFrameSymbols[index] = background, foreground, sub(text, i, i)
            end
        end
    end

    --------------------------------------------------------------------------------

    --doNotRedraw делать пиклеси "уже отрисоваными" и скопировый участок не будет перерисовываться, используйте gpu.copy с данным флагом
    local function copy(x, y, width, height, startX, startY, doNotRedraw)
        local copyArray, index = { width, height }
    
        for j = y, y + height - 1 do
            for i = x, x + width - 1 do
                if i >= 1 and j >= 1 and i <= bufferWidth and j <= bufferHeight then
                    index = bufferWidth * (j - 1) + i
                    tableInsert(copyArray, newFrameBackgrounds[index])
                    tableInsert(copyArray, newFrameForegrounds[index])
                    tableInsert(copyArray, newFrameSymbols[index])
                else
                    tableInsert(copyArray, 0x0)
                    tableInsert(copyArray, 0x0)
                    tableInsert(copyArray, " ")
                end
            end
        end
    
        local function paste(startX, startY, picture)
            local imageWidth = picture[1]
            local screenIndex, pictureIndex, screenIndexStepOnReachOfImageWidth = bufferWidth * (startY - 1) + startX, 3, bufferWidth - imageWidth
        
            for y = startY, startY + picture[2] - 1 do
                if y >= drawLimitY1 and y <= drawLimitY2 then
                    for x = startX, startX + imageWidth - 1 do
                        if x >= drawLimitX1 and x <= drawLimitX2 then
                            newFrameBackgrounds[screenIndex] = picture[pictureIndex]
                            newFrameForegrounds[screenIndex] = picture[pictureIndex + 1]
                            newFrameSymbols[screenIndex] = picture[pictureIndex + 2]
                            if doNotRedraw then
                                currentFrameBackgrounds[screenIndex] = newFrameBackgrounds[screenIndex]
                                currentFrameForegrounds[screenIndex] = newFrameForegrounds[screenIndex]
                                currentFrameSymbols[screenIndex] = newFrameSymbols[screenIndex]
                            end
                        end
        
                        screenIndex, pictureIndex = screenIndex + 1, pictureIndex + 3
                    end
        
                    screenIndex = screenIndex + screenIndexStepOnReachOfImageWidth
                else
                    screenIndex, pictureIndex = screenIndex + bufferWidth, pictureIndex + imageWidth * 3
                end
            end
        end

        paste(startX, startY, copyArray)
    end

    --------------------------------------------------------------------------------

    local function update(force)
        local index, indexStepOnEveryLine, changes = bufferWidth * (drawLimitY1 - 1) + drawLimitX1, (bufferWidth - drawLimitX2 + drawLimitX1 - 1), {}
        local x, equalChars, equalCharsIndex, charX, charIndex, currentForeground
        local currentFrameBackground, currentFrameForeground, currentFrameSymbol, changesCurrentFrameBackground, changesCurrentFrameBackgroundCurrentFrameForeground
        local changesCurrentFrameBackgroundCurrentFrameForegroundIndex

        for y = drawLimitY1, drawLimitY2 do
            x = drawLimitX1

            while x <= drawLimitX2 do
                if
                    currentFrameBackgrounds[index] ~= newFrameBackgrounds[index] or
                    currentFrameForegrounds[index] ~= newFrameForegrounds[index] or
                    currentFrameSymbols[index] ~= newFrameSymbols[index] or
                    force
                then
                    currentFrameBackground, currentFrameForeground, currentFrameSymbol = newFrameBackgrounds[index], newFrameForegrounds[index], newFrameSymbols[index]
                    currentFrameBackgrounds[index] = currentFrameBackground
                    currentFrameForegrounds[index] = currentFrameForeground
                    currentFrameSymbols[index] = currentFrameSymbol

                    equalChars, equalCharsIndex, charX, charIndex = {currentFrameSymbol}, 2, x + 1, index + 1
                    
                    while charX <= drawLimitX2 do
                        if	
                            currentFrameBackground == newFrameBackgrounds[charIndex] and
                            (
                                newFrameSymbols[charIndex] == " " or
                                currentFrameForeground == newFrameForegrounds[charIndex]
                            )
                        then
                            currentFrameBackgrounds[charIndex] = newFrameBackgrounds[charIndex]
                            currentFrameForegrounds[charIndex] = newFrameForegrounds[charIndex]
                            currentFrameSymbols[charIndex] = newFrameSymbols[charIndex]

                            equalChars[equalCharsIndex], equalCharsIndex = currentFrameSymbols[charIndex], equalCharsIndex + 1
                        else
                            break
                        end

                        charX, charIndex = charX + 1, charIndex + 1
                    end

                    changesCurrentFrameBackground = changes[currentFrameBackground] or {}
                    changes[currentFrameBackground] = changesCurrentFrameBackground
                    changesCurrentFrameBackgroundCurrentFrameForeground = changesCurrentFrameBackground[currentFrameForeground] or {index = 1}
                    changesCurrentFrameBackground[currentFrameForeground] = changesCurrentFrameBackgroundCurrentFrameForeground

                    changesCurrentFrameBackgroundCurrentFrameForegroundIndex = changesCurrentFrameBackgroundCurrentFrameForeground.index
                    changesCurrentFrameBackgroundCurrentFrameForeground[changesCurrentFrameBackgroundCurrentFrameForegroundIndex], changesCurrentFrameBackgroundCurrentFrameForegroundIndex = x, changesCurrentFrameBackgroundCurrentFrameForegroundIndex + 1
                    changesCurrentFrameBackgroundCurrentFrameForeground[changesCurrentFrameBackgroundCurrentFrameForegroundIndex], changesCurrentFrameBackgroundCurrentFrameForegroundIndex = y, changesCurrentFrameBackgroundCurrentFrameForegroundIndex + 1
                    changesCurrentFrameBackgroundCurrentFrameForeground[changesCurrentFrameBackgroundCurrentFrameForegroundIndex], changesCurrentFrameBackgroundCurrentFrameForegroundIndex = concat(equalChars), changesCurrentFrameBackgroundCurrentFrameForegroundIndex + 1
                    
                    x, index, changesCurrentFrameBackgroundCurrentFrameForeground.index = x + equalCharsIndex - 2, index + equalCharsIndex - 2, changesCurrentFrameBackgroundCurrentFrameForegroundIndex
                end

                x, index = x + 1, index + 1
            end

            index = index + indexStepOnEveryLine
        end
        
        for background, foregrounds in pairs(changes) do
            invoke(gpu_address, "setBackground", background, usePaletteIndex)

            for foreground, pixels in pairs(foregrounds) do
                if currentForeground ~= foreground then
                    invoke(gpu_address, "setForeground", foreground, usePaletteIndex)
                    currentForeground = foreground
                end

                for i = 1, #pixels, 3 do
                    invoke(gpu_address, "set", pixels[i], pixels[i + 1], pixels[i + 2])
                end
            end
        end

        changes = nil
    end

    --------------------------------------------------------------------------------

    return {
        copy = copy,

        setResolution = setResolution,
        getResolution = getResolution,

        get = get,
        set = set,
        update = update,
    }
end}