local wget = require("wget")
local programs = require("programs")

local webservices = {}
local startUrl = "https://raw.githubusercontent.com/igorkll/liteOS/main/services/"
local endUrl = "?token=GHSAT0AAAAAAB7CKA57HMQHCNVWN7UG5ZRWZALGFJQ"

function webservices.url(name)
    return (startUrl or "") .. name .. (endUrl or "")
end

function webservices.loadData(name)
    return wget.wget(webservices.url(name))
end

function webservices.load(name)
    local data, err = webservices.loadData(name)
    if not data then return nil, err end
    return programs.loadText(data, name)
end

function webservices.run(name, ...)
    local code, err = webservices.load(name)
    if not code then return nil, err end
    return code(...)
end

return webservices