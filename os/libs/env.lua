local env = {}
env.fakeGlobals = {} --позваляет имплементировать фейковые глобалы, добавьте сюда таблицу а нее добавьте свои феквовые глобалы

function env.createProgrammEnv(localEnv) --создает env для программы, где _G это будут глобалы а _ENV будет личная таблица окружения
    localEnv = localEnv or {}
    localEnv._G = _ENV
    setmetatable(localEnv, {__index = _ENV})
    return localEnv
end

setmetatable(_ENV, {__index = function(tbl, key)
    for key, value in pairs(env.fakeGlobals) do
        if value[key] then
            return value[key]
        end
    end
end})

return env