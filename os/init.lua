----------------generate firmware

local fs = component.proxy(computer.getBootAddress())
local function readFile(path)
    local file, err = fs.open(path, "rb")
    if not file then return nil, err end
    local buffer = ""
    repeat
        local data = fs.read(file, math.huge)
        buffer = buffer .. (data or "")
    until not data
    fs.close(file)
    return buffer
end

----------------eeprom

local eeprom = component.proxy(component.list("eeprom")())

eeprom.set("local address = \"" .. fs.address .. "\"\n" .. readFile("/firmware.lua"))
eeprom.setData("")
eeprom.setLabel("liteOS firmware")
eeprom.makeReadonly(eeprom.getChecksum())

----------------reboot

computer.setArchitecture("Lua 5.3")
computer.shutdown(true)