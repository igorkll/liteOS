local buffer = require("buffer")
local json = require("json")
local fs = require("filesystem")
local internet = {}

-------------------------------------------------------------------------------

function internet.card()
    return component.proxy(component.list("internet")() or "")
end

function internet.wget(url)
  local internet, err = internet.card()
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

function internet.repoList(repoUrl, path)
    local tbl = {}
    local function recurse(repoUrl, path)
        path = table.concat(fs.segments(path), "/")
        
        local files = json.decode(internet.wget(repoUrl .. "/contents/" .. path))
        for i = 1, #files do
            local file = files[i]
            if file.type == "file" then
                table.insert(tbl, file.path)
            elseif file.type == "dir" then
                recurse(repoUrl, file.path)
            end
        end
    end
    recurse(repoUrl, path)

    for index, value in ipairs(tbl) do
        local str = value:sub(#path, #value)
        if str:sub(1, 1) ~= "/" then
            str = "/" .. str
        end
        tbl[index] = str
    end
    
    return tbl
end

function internet.request(url, data, headers, method)
  checkArg(1, url, "string")
  checkArg(2, data, "string", "table", "nil")
  checkArg(3, headers, "table", "nil")
  checkArg(4, method, "string", "nil")

  local inet = internet.card()

  local post
  if type(data) == "string" then
    post = data
  elseif type(data) == "table" then
    for k, v in pairs(data) do
      post = post and (post .. "&") or ""
      post = post .. tostring(k) .. "=" .. tostring(v)
    end
  end

  local request, reason = inet.request(url, post, headers, method)
  if not request then
    error(reason, 2)
  end

  return setmetatable(
  {
    ["()"] = "function():string -- Tries to read data from the socket stream and return the read byte array.",
    close = setmetatable({},
    {
      __call = request.close,
      __tostring = function() return "function() -- closes the connection" end
    })
  },
  {
    __call = function()
      while true do
        local data, reason = request.read()
        if not data then
          request.close()
          if reason then
            error(reason, 2)
          else
            return nil -- eof
          end
        elseif #data > 0 then
          return data
        end
        -- else: no data, block
        os.sleep(0)
      end
    end,
    __index = request,
  })
end

-------------------------------------------------------------------------------

local socketStream = {}

function socketStream:close()
  if self.socket then
    self.socket.close()
    self.socket = nil
  end
end

function socketStream:seek()
  return nil, "bad file descriptor"
end

function socketStream:read(n)
  if not self.socket then
    return nil, "connection is closed"
  end
  return self.socket.read(n)
end

function socketStream:write(value)
  if not self.socket then
    return nil, "connection is closed"
  end
  while #value > 0 do
    local written, reason = self.socket.write(value)
    if not written then
      return nil, reason
    end
    value = string.sub(value, written + 1)
  end
  return true
end

function internet.socket(address, port)
  checkArg(1, address, "string")
  checkArg(2, port, "number", "nil")
  if port then
    address = address .. ":" .. port
  end

  local inet = internet.card()
  local socket, reason = inet.connect(address)
  if not socket then
    return nil, reason
  end

  local stream = {inet = inet, socket = socket}
  local metatable = {__index = socketStream,
                     __metatable = "socketstream"}
  return setmetatable(stream, metatable)
end

function internet.open(address, port)
  local stream, reason = internet.socket(address, port)
  if not stream then
    return nil, reason
  end
  return buffer.new("rwb", stream)
end

-------------------------------------------------------------------------------

return internet