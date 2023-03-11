local webservices = require("webservices")
local fs = require("filesystem")

local function download(file, to)
    local data, err = webservices.loadData(file)
    if not data then return nil, err end
    fs.makeDirectory(fs.path(to))
    fs.writeFile(to, data)
end