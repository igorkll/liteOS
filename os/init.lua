bootaddress = computer.getBootAddress()
bootfs = component.proxy(bootaddress)

do
    local function raw_require(name)
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
        local code = assert(load(text))
        local lib = assert(code())
        return lib
    end
    raw_require("package")
end

require("utilites")

---------------------------------------------------

