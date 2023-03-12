local autorun = {}
autorun._AUTORUNS_LOG = {}

function autorun.autorun(folder)
    local fs = require("filesystem")
    local programs = require("programs")

    if fs.exists(folder) and fs.isDirectory(folder) then
        for _, path in ipairs(fs.list(folder)) do
            local fullpath = fs.concat(folder, path)
            if fs.exists(fullpath) then
                local ok, err = programs.run(fullpath)
                if not ok then
                    table.insert(autorun._AUTORUNS_LOG, {err = err, file = fullpath})
                end
            end
        end
    end
end

return autorun