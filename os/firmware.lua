computer.setArchitecture("Lua 5.3")

-----------------------------------

local gpu = component.proxy(component.list("gpu")() or "")
local screen = component.list("screen")()
if not gpu then error("gpu not found", 0) end
if not screen then error("screen not found") end
gpu.bind(screen)

-----------------------------------

local fs = component.proxy(address)
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

local function boot()
    function computer.getBootAddress()
        return address
    end
    
    local data, err = readFile("/liteOS.lua")
    if not data then error(err, 0) end
    assert(load(data, "=init"))()
end

boot()