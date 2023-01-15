bootaddress = computer.getBootAddress()
bootfs = component.proxy(bootaddress)

do
    function raw_require(name)
        local function raw_readFile(fs, path)
            checkArg(1, fs, "table", "string")
            checkArg(2, path, "string")
        
            if type(fs) == "string" then fs = component.proxy(fs) end
            if not fs.exists(path) then return nil, "file not found" end
            if fs.isDirectory(path) then return nil, "is directory" end
            local file, err = fs.open(path, "rb")
            if not file then return nil, err or "unknown" end
        
            local buffer = ""
            repeat
                local data = fs.read(file, math.huge)
                buffer = buffer .. (data or "")
            until not data
            fs.close(file)
            return buffer
        end

        local text = assert(raw_readFile(bootaddress, "/libs/" .. name .. ".lua"))
        local code = assert(load(text, "=" .. name, "bt", _ENV))
        local lib = assert(code())
        return lib
    end
    raw_require("package")
    raw_require = nil
end

require("utilites")

---------------------------------------------------

local function autorun(folder)
    local fs = require("filesystem")
    local programs = require("programs")
    local logger = require("logger")

    logger.log("autorun", "start from: " .. folder)

    if fs.exists(folder) and fs.isDirectory(folder) then
        for _, path in ipairs(fs.list(folder)) do
            local fullpath = fs.concat(folder, path)
            if fs.exists(fullpath) then
                logger.log("autorun", "running: " .. fullpath)
                local ok, err = programs.run(fullpath)
                if not ok then
                    logger.error("autorun", err)
                else
                    logger.log("autorun", "ok: " .. fullpath)
                end
            end
        end
    end
end

autorun("/autorun")
autorun("/data/autorun")

require("programs").execute("desktop")