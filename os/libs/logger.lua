local fs = require("filesystem")

--------------------------------------------------

local logger = {}
logger.folder = "/data/logs"
logger.path = fs.concat(logger.folder, "main.log")

function logger.log(str)
    fs.makeDirectory(logger.folder)
    
    local file = fs.open(logger.path, "ab")
    if file then
        file.write(str .. "\n")
        file.close()
    end
    return true
end

return logger