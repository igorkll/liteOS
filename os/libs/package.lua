local filesystem = require("filesystem")

-------------------------------------

local package = {}
package.loaded = {
    package = package,
    math = math,
    table = table,
    computer = computer,
    component = component,
    unicode = unicode,
    utf8 = utf8
}
package.paths = {"/libs"}

function package.require(name)
    checkArg(1, name, "string")

    if package.loaded[name] then return package.loaded[name] end
    local text = assert(filesystem.readFile(bootaddress, "/libs/" .. name .. ".lua"))
    local code = assert(load(text))
    local lib = assert(code())
    package.loaded[name] = lib
    return lib
end
require = package.require

return package