return {create = function(gpu_address)
    local invoke, insert, concat, len, sub = component.invoke, table.insert, table.concat, unicode.len, unicode.sub

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
                insert(currentFrameBackgrounds, 0x010101)
                insert(currentFrameForegrounds, 0xFEFEFE)
                insert(currentFrameSymbols, " ")

                insert(newFrameBackgrounds, 0x010101)
                insert(newFrameForegrounds, 0xFEFEFE)
                insert(newFrameSymbols, " ")
            end
        end
    end

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
            return 0x000000, 0x000000, " "
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
            invoke(gpu_address, "setBackground", background)

            for foreground, pixels in pairs(foregrounds) do
                if currentForeground ~= foreground then
                    invoke(gpu_address, "setForeground", foreground)
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
        setResolution = setResolution,
        getResolution = getResolution,

        get = get,
        set = set,
        update = update,
    }
end}