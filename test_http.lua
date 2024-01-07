-- Proof of concept using external Lua libraries.
package.path = package.path .. ";/usr/share/lua/5.3/?.lua;/usr/share/lua/5.2/?.lua"
package.cpath = package.cpath .. ";/usr/lib/x86_64-linux-gnu/lua/5.3/?.so"

http_request = require('http.request')
headers, stream = assert(http_request.new_from_uri("http://example.com"):go())
body = assert(stream:get_body_as_string())
if headers:get ":status" ~= "200" then
    error(body)
end
print(body)
