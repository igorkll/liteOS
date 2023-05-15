local fs = require("filesystem")
local time = require("time")
local user = require("user")
local logger = {}
logger.path = "/data/system_log.log"

function logger.log(...)
    local args = {...}
    for index, value in ipairs(args) do
        args[index] = tostring(value)
    end
    local logstr = table.concat(args, "  ")
    local timestr = table.concat({time.getRealTime(user.timezone)}, ":")
    local endstr = timestr .. ": " .. logstr .. "\n"

    local file = fs.open(logger.path, "ab")
    file.write(endstr)
    file.close()
end

return logger