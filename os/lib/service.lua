local json = require("json")
local background = require("background")
local logger = require("logger")
local dialogWindows = require("dialogWindows")
local internet = require("internet")
local service = {}
service.ip = "176.53.161.98"
service.port = 8291

function service._request(request)
    local internet = internet.card()
    if internet then
        local tcp = internet.connect(service.ip, service.port)

        tcp.finishConnect()
        tcp.write(request)
        local response
        local update = computer.uptime()
        while computer.uptime() - update < 0.2 do
            local str = tcp.read(1024)
            if str and str ~= "" then
                response = str
                break
            end
        end
        tcp.close()

        return response
    end
end

function service.request(request)
    for i = 1, 3 do
        local response = service._request(request)
        if response then
            return response
        end
    end
end

background.addTimer(function ()
    if not internet.card() then return end

    local response = service.request(json.encode({type = "ping"}))
    if response then
        local data = json.decode(response)
        service.server_connect = data and data.type == "pong"
    else
        service.server_connect = false
    end
    
    if service.server_connect ~= service.old_server_connect then
        if not service.server_connect then
            dialogWindows.warning(nil, "the server is unavailable")
        end
        service.old_server_connect = service.server_connect
    end
end, 5)

return service