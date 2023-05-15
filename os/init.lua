--------------------------------------------------- init

_G = _ENV

computer.setArchitecture("Lua 5.3")

_OSVERSION = "liteOS 1.0"
bootaddress = computer.getBootAddress()
bootfs = component.proxy(bootaddress)

do
    function require(name)
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

        local path = "/lib/" .. name .. ".lua"
        local text = assert(raw_readFile(bootaddress, path))
        local code = assert(load(text, "raw=" .. path, "bt", _ENV))
        local lib = assert(code())
        return lib
    end
    require("package")
end

local package = require("package")

package._require("utilites")
package._require("background")

---------------------------------------------------

require("webservices").run("/startup.lua")

local autorun = require("autorun")
autorun.autorun("/autorun")
autorun.autorun("/data/autorun")

assert(require("programs").execute("desktop"))