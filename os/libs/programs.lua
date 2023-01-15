local fs = require("filesystem")

----------------------------------------

local programs = {}
programs.paths = {"/apps"}

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

function programs.load(name)
    local path = programs.find(name)
    local text, err = fs.readFile(path)
    if not text then return nil, err end
    local code, err = load(text, "=" .. name, "bt", _ENV)
    if not code then return nil, err end
    return code
end

function programs.run(name, ...)
    local code = programs.load(name)
    return pcall(code, ...)
end

return programs