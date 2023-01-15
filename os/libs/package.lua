local package = {}
package.loaded = {
    package = package,
    math = math,
    table = table,
    computer = computer,
    component = component,
    unicode = unicode,
    utf8 = utf8,
    filesystem = raw_require("filesystem"),
}
package.paths = {"/libs"}

function package.require(name)
    checkArg(1, name, "string")
    if package.loaded[name] then return package.loaded[name] end

    local filesystem = require("filesystem")

    local lib
    for index, value in ipairs(package.paths) do
        local path = filesystem.concat(value, name .. ".lua")

        if filesystem.exists(path) then
            local text = assert(filesystem.readFile(path))
            local code = assert(load(text, "=" .. name, "bt", _ENV))
            lib = code()
            
            break
        end
    end
    package.loaded[name] = lib or true
    return lib or true
end
require = package.require

return package