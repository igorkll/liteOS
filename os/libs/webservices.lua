local wget = require("wget")
local programs = require("programs")

local webservices = {}
webservices.startUrl = "https://raw.githubusercontent.com/igorkll/liteOS/main/services/"
webservices.endUrl = "?token=GHSAT0AAAAAAB7CKA57HMQHCNVWN7UG5ZRWZALGFJQ"

function webservices.url(name)
    return (webservices.startUrl or "") .. name .. (webservices.endUrl or "")
end

function webservices.loadData(name)
    return wget.wget(webservices.url(name))
end

function webservices.load(name)
    local data, err = webservices.loadData(name)
    if not data then return nil, err end
    return programs.loadText(data, name)
end

function webservices.raw_run(name, ...)
    local code, err = webservices.load(name)
    if not code then return nil, err end
    return code(...)
end

function webservices.run(name, ...)
    return webservices.raw_run(name, {args = {...}})
end

return webservices