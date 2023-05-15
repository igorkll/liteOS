local json = require("json")
local background = require("background")
local logger = require("logger")
local service = {}
service.ip = "176.53.161.98"
service.port = 8291

function service.request(request)
    local internet = component.proxy(component.list("internet")() or "")
    if internet then
        local tcp = internet.connect(service.ip, service.port)

        tcp.finishConnect()
        tcp.write(request)
        local response = ""
        local update = computer.uptime()
        while computer.uptime() - update < 1 do
            response = response .. (tcp.read(1024) or "")
        end
        if response == "" then response = "{}" end
        tcp.close()

        return response
    end
end

background.addTimer(function ()
    local data = json.decode(service.request(json.encode({type = "ping"})))
    if data then
        if data.type == "pong" then
            computer.beep(2000)
        else
            computer.beep(1000)
        end
    else
        computer.beep(50)
    end
end, 1)

return service