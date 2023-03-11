local webservices = require("webservices")
local fs = require("filesystem")

--------------------------------------------------

local apps = {
    ["gui demo"] = {
        ["/data/executable/gui_demo/main.lua"] = "/apps/gui_demo/main.lua"
    },
    ["hello world"] = {
        ["/data/executable/hello_world/main.lua"] = "/apps/hello_world/main.lua"
    },
    ["ram monitor"] = {
        ["/data/executable/ram_monitor/main.lua"] = "/apps/ram_monitor/main.lua"
    },
    ["seekbar - demo"] = {
        ["/data/executable/seekbar_demo/main.lua"] = "/apps/seekbar_demo/main.lua"
    }
}

--------------------------------------------------

local function download(file, to)
    local data, err = webservices.loadData(file)
    if not data then return nil, err end
    fs.makeDirectory(fs.path(to))
    fs.writeFile(to, data)
end

local function install(name)
    local app = apps[name]
    for local_path, net_file in pairs(app) do
        download(net_file, local_path)
    end
end

--------------------------------------------------

for name in pairs(apps) do
    install(name)
end

--------------------------------------------------

return true