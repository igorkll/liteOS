local fs = require("filesystem")

--------------------------------------------------

local logger = {}
logger.folder = "/logs"
logger.path = fs.concat(logger.folder, "main.log")

function logger.write(str)
    fs.makeDirectory(logger.folder)
    local file = fs.open(logger.path, "ab")
    if file then
        file.write(str .. "\n")
        file.close()
    end
    return true
end

function logger.log(name, text)
    local str = (name or "unknown") .. ": " .. (text or "unknown")
    logger.write(str)
end

function logger.error(errorname, errortext)
    local str = "error in " .. (errorname or "unknown") .. ": " .. (errortext or "unknown")
    logger.write(str)
end

logger.log("logger init")

return logger