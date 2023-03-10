local component = require("component")
local wget = {}

function wget.wget(url)
    local internet, err = component.proxy(component.list("internet")() or "")
    if not internet then
        return nil, err
    end

    local handle, data, result, reason = internet.request(url), ""
    if handle then
        while true do
            result, reason = handle.read(math.huge) 
            if result then
                data = data .. result
            else
                handle.close()
                
                if reason then
                    return nil, reason
                else
                    return data
                end
            end
        end
    else
        return nil, "unvalid address"
    end
end

return wget