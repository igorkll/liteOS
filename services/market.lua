local webservices = require("webservices")
local fs = require("filesystem")

--------------------------------------------------

local apps = {
    ["demo pack"] = {
        ["/data/bin/demo gui/main.lua"] = "/apps/demopack/demo_gui.lua",
        --["/data/bin/demo gui/uninstall.lua"] = "/default_uninstall.lua",

        ["/data/bin/demo seekbar/main.lua"] = "/apps/demopack/demo_seekbar.lua",
        --["/data/bin/demo seekbar/uninstall.lua"] = "/default_uninstall.lua",
    },
    ["hello world"] = {
        ["/data/bin/hello world/main.lua"] = "/apps/hello_world/main.lua",
        --["/data/bin/hello world/uninstall.lua"] = "/default_uninstall.lua",
    },
    ["ram monitor"] = {
        ["/data/bin/ram monitor/main.lua"] = "/apps/ram_monitor/main.lua",
        --["/data/bin/ram monitor/uninstall.lua"] = "/default_uninstall.lua",
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

--------------------------------------------------

return true