local json = require("json")
local background = require("background")
local ip = "176.53.161.98"
local port = 8291

local service = {}

function service.request(request)
    local internet = component.proxy(component.list("internet")() or "")
    if internet then
        local tcp = internet.connect(ip, port)

        tcp.write(request)
        local response = ""
        local update = computer.update()
        while computer.update() - update < 1 do
            response = response .. tcp.read(1024)
        end
        tcp.finishConnect()
        tcp.close()

        return response
    end
end

background.addTimer(function ()
    service.request(json.encode({type = "ping"}))
end, 1)

return service