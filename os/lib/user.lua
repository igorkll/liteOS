local fs = require("filesystem")
local serialization = require("serialization")
local user = {}
user.configPath = "/data/config.tbl"
user.defaultConfig = {timezone = 0}
user.currentConfig = table.clone(user.defaultConfig)

if not fs.exists(user.configPath) then
    fs.writeFile(user.configPath, serialization.serialize(user.currentConfig))
else
    local data = fs.readFile(user.configPath)
    if data then
        data = serialization.unserialize(data)
        if data then
            user.currentConfig = data
        end
    end
end

function user.getUserConfig()
    return user.currentConfig
end

function user.setUserConfig(config)
    user.currentConfig = config
    fs.writeFile(user.configPath, serialization.serialize(user.currentConfig))
end


setmetatable(user, {__index = function (tbl, key)
    return tbl.currentConfig[key]
end, __newindex = function (tbl, key, value)
    tbl.currentConfig[key] = value
end})
return user