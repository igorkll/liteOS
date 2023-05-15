local fs = require("filesystem")

local autorun = {}
autorun.log = {}

function autorun._autorun(folder)
    local fs = require("filesystem")
    local programs = require("programs")

    if fs.exists(folder) and fs.isDirectory(folder) then
        for _, path in ipairs(fs.list(folder) or {}) do
            local fullpath = fs.concat(folder, path)
            if fs.exists(fullpath) then
                local ok, err = programs.run(fullpath)
                if not ok then
                    table.insert(autorun.log, {err = err, file = fullpath})
                end
            end
        end
    end
end

function autorun.autorun(name)
    autorun._autorun(fs.concat("/", name))
    autorun._autorun(fs.concat("/data", name))
end

return autorun