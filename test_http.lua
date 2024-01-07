-- Proof of concept using external Lua libraries.
package.path = package.path .. ";./lr/share/lua/5.4/?.lua"
package.cpath = package.cpath .. ";./lr/lib/lua/5.4/?.so"

http_request = require('http.request')
headers, stream = assert(http_request.new_from_uri("http://example.com"):go())
body = assert(stream:get_body_as_string())
if headers:get ":status" ~= "200" then
    error(body)
end
print(body)
