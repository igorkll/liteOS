local internet = {}

function internet.card()
    return component.proxy(component.list("internet")() or "")
end

return internet