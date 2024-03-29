local _checkArg, str_string, str_nil, str_initlua, str_kernel, str_liteOS, str_seturlboot, str_lifeurlboot, str_sbp, str_sbf, str_empty, str_lifeboot, str_openOSonline, str_updateUrl, str_defaultSettings, str_settings, str_biosname, str_exit, str_nointernetcard, proxy, list, invoke, TRUE =
       checkArg, "string", "nil", "init.lua", "boot/kernel/", "Install LiteOS", "Set Url Boot", "Life Url Boot", "Select Boot Priority", "Select Boot Fs", "", "Classic Boot", "", "", "{u='',e=true,k=true,j=true,f=false}", "Settings", "liteOS installer", "exit", "no internet-card, urlboot is not available", component.proxy, component.list, component.invoke, true

local _computer, _pcall, resX, resY, --не забуть запитую
screen, selected1, empty, event, code, str, char, err,
tryUrlBoot, saveWithSplash, reverseColor, setBackground, setForeground, hpath, haddr, old_laddr, old_lpath,
tryBoot, gIsPal, col, isPal, tmp1, setPaletteColor, internet, gpu, boot_gpu, refresh
= computer, pcall, 50, 16

function refresh()
    internet = proxy(list"int"() or str_empty)
    gpu = proxy(list"gp"() or str_empty)
    screen = list"scr"()
    if gpu and screen then
        setBackground, setForeground, setPaletteColor =
        gpu.setBackground, gpu.setForeground, gpu.setPaletteColor
        
        gpu.bind(screen)
        gpu.setDepth(1) --reset pallete
        gpu.setDepth(math.min(gpu.maxDepth(), 4))

        if gpu.getDepth() > 3 then
            --4 depth
            setPaletteColor(0, 0)
            setPaletteColor(1, 0xffffff)
            setPaletteColor(2, 0x888888)
            gIsPal = 1
        end
    
        gpu.setResolution(resX, resY)
    
        invoke(screen, "turnOn")
    end
end

function reverseColor()
    --setBackground(setForeground(gpu.getBackground())) --unsupported pallete
    col, isPal = gpu.getBackground()
    gpu.setBackground(gpu.getForeground())
    gpu.setForeground(col, isPal)
end

local clear, drawStr, pullSignal, beforeBoot, setColor, bm_fast, bm_bios, shutdown = function()
    gpu.fill(1, 1, resX, resY, " ")
end, function(str, posY, invert)
    if invert then reverseColor() end
    gpu.set(math.floor(resX / 2 - #str / 2) + 1, posY, str)
    if invert then reverseColor() end
end, function(wait)
    event, empty, char, code = _computer.pullSignal(wait)
end, function ()
    gpu.setDepth(1) --reset pallete
    gpu.setDepth(gpu.maxDepth())

    setBackground(0)
    setForeground(-1)
end, function(num)
    if gIsPal then
        if num == 0 then
            setBackground(1, TRUE)
            setForeground(0, TRUE)
        elseif num == 1 then
            setBackground(1, TRUE)
            setForeground(2, TRUE)
        end
    else
        setBackground(-1)
        setForeground(0)
    end
end, "__fast", "__bios", _computer.shutdown

refresh()

---------------- boot standart "LGC 2023-A"

----default methods
function _computer.getBootAddress()
    return haddr
end
function _computer.setBootAddress(address)
end

---------------- ----------------

local menu, splash, input, boot, urlboot, selectdisk = function(title, strs, current)
    setColor(0)
    clear()
    drawStr(title, 2, not gIsPal)
    ::LOOP::
        setColor(1)
        for i, str in ipairs(strs) do
            drawStr((" "):rep(46), i + 3, i == current)
            drawStr(str, i + 3, i == current)
        end

        pullSignal()
        if event == "key_down" then
            if code == 28 then
                return current
            end
            if code == 208 and current < #strs then
                current = current + 1
            end
            if code == 200 and current > 1 then
                current = current - 1
            end
        end
    goto LOOP
end, function (title, wait)
    if not gpu then return end

    setColor(0)
    clear()
    drawStr(title, 2)
    while wait do
        setColor(1)
        drawStr("press enter to continue", 4)

        pullSignal()
        if event == "key_down" and code == 28 then
            break
        end
    end
end, function(title, lstr)
    str = lstr or str_empty
    ::LOOP::
        clear()
        setColor(0)
        drawStr(title, 2)
        setColor(1)
        drawStr(str .. "_", 4)

        pullSignal()
        if event == "key_down" then
            if code == 28 then
                return str
            elseif code == 14 then
                str = str:sub(1, -2)
            elseif char > 31 and char < 127 then
                str = str .. string.char(char)
            end
        elseif event == "clipboard" then
            str = str .. char
        end
    goto LOOP
end, function (addr, path)
    ---------------- load boot file
    empty, str, char, err, haddr, hpath = proxy(addr), str_empty, str_empty, F, addr, path
    event, err = empty.open(path, "rb")
    if event then
        repeat
            str = str .. char
            char = empty.read(event, math.huge)
        until not char
        empty.close(event)
        code, err = load(str, "=" .. path)
    end
    if err then
        return err
    end

    ----------------run

    beforeBoot()
    err = debug.traceback
    assert(xpcall(code, err))
    shutdown()
end, function (url)
    empty, str, err = internet.request(url), str_empty, "Unvalid Address"
    while empty do
        char, err = empty.read(math.huge)
        if char then
            str = str .. char
        else
            break
        end
    end

    if err then return err end
    code, err = load(str, "=" .. url)
    if err then return err end

    ----------------run

    beforeBoot()
    err = debug.traceback
    assert(xpcall(code, err))
    shutdown(1)
end

--------------------- main funcs

function tryBoot(laddr, lpath) --is local
    local str2 = " (" .. laddr:sub(1, 4) .. ", " .. lpath .. ") "
    splash("booting" .. str2)
    

    str = boot(laddr, lpath)
    if str then
        splash("boot-error" .. str2 .. str, 1)
    end
end

function tryUrlBoot(url) --is local
    if not internet then splash(str_nointernetcard, 1) return end
    splash("please wait")

    str = urlboot(url)
    if str then
        splash("error-urlboot: " .. str, 1)
    end
end

function selectdisk(label, writable)
    hpath, haddr = {}, {}
    for address in list"file" do
        if not writable or not invoke(address, "isReadOnly") then
            table.insert(hpath, address:sub(1, 5) .. ":" .. (invoke(address, "getLabel") or "unknown"))
            table.insert(haddr, address)
        end
    end
    table.insert(hpath, "cancel")

    return menu(label, hpath, 1)
end

--------------------- main

selected1 = 1
while 1 do
    selected1 = menu(str_biosname, {str_lifeboot, str_liteOS, "Shutdown"}, selected1)

    if selected1 == 1 then
        err = selectdisk(str_lifeboot)
        if haddr[err] then
            tryBoot(haddr[err], str_initlua)
        end
    elseif selected1 == 2 then
        err = selectdisk(str_liteOS, 1)
        if haddr[err] then
            idisk = proxy(haddr[err])
            tryUrlBoot("https://raw.githubusercontent.com/igorkll/liteOS/main/ninstall_compress.lua")
        end
    elseif selected1 == 3 then
        shutdown()
    end
end