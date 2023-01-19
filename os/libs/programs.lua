local fs = require("filesystem")
local env = require("env")

----------------------------------------

local programs = {}
programs.paths = {"/executable", "/data/executable"}

function programs.find(name)
    for _, path in ipairs(programs.paths) do
        local fullpath = fs.concat(path, name)
        if fs.exists(fullpath .. ".lua") then
            return fullpath .. ".lua"
        end

        local fullfilepath = fs.concat(path, name, "main.lua")
        if fs.exists(fullpath) and fs.isDirectory(fullpath) and
        fs.exists(fullfilepath) and not fs.isDirectory(fullfilepath) then
            return fullfilepath
        end
    end
end

function programs.load(name, envtbl)
    local path = programs.find(name)
    local text, err = fs.readFile(path)
    if not text then return nil, err end
    local code, err = load(text, "=" .. name, "bt", envtbl or env.createProgrammEnv())
    if not code then return nil, err end
    return code
end

function programs.run(name, ...)
    local code, err = programs.load(name)
    if not code then return nil, err or "unknown" end
    return pcall(code, ...)
end

function programs.execute(name, ...)
    local code, err = programs.load(name)
    if not code then return nil, err or "unknown" end
    return assert(xpcall(code, debug.traceback, ...))
end

return programs