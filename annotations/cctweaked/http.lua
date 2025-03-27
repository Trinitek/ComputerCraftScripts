---https://tweaked.cc/module/http.html

---@meta

---@diagnostic disable: lowercase-global

---@alias CCHttpMethod
---| '"GET"'
---| '"HEAD"'
---| '"POST"'
---| '"PUT"'
---| '"PATCH"'
---| '"TRACE"'
---| '"DELETE"'

---@class CCHttpRequest
---@field url string
---@field body string
---@field headers table<string, string>
---@field binary boolean
---@field method string|CCHttpMethod
---@field redirect boolean

---@class CCHttpResponseBase
CCHttpResponseBase = {
    ---Returns the response code and response message returned by the server.
    ---@return integer code The response code, i.e. 200
    ---@return string message The message that corresponds to the code, i.e. "OK"
    getResponseCode = function () end,

    ---Get a table containing the response's headers, in a format similar to that required by `http.request`.
    ---If multiple headers are sent with the same name, they will be combined with a comma.
    ---@return table<string, string> headers The response's headers.
    getResponseHeaders = function () end
}

---@class CCHttpResponse : CCHttpResponseBase, CCFileReadHandle

---@class CCBinaryHttpResponse : CCHttpResponseBase, CCBinaryReadHandle

---@class CCWebSocket
CCWebSocket = {
    receive = function (timeout) end,
    send =  function (message, binary) end,
    close = function () end
}

http = {
    ---Asynchronously make an HTTP request to the given URL.
    ---
    ---This returns immediately. A `http_success` event or `http_failure` event will be queued once the request has completed.
    ---@param url string The URL to request.
    ---@param body? string An optional string containing the body of the request. If specified, a POST request will be made instead.
    ---@param headers? table<string, string> Additional headers to send.
    ---@param binary? boolean Whether to make a binary request. If false, UTF-8 is used.
    ---@overload fun(params: CCHttpRequest)
    request = function (url, body, headers, binary) end,

    ---Make an HTTP GET request to the given URL.
    ---@param url string The URL to request.
    ---@param headers? table<string, string> Additional headers to send.
    ---@param binary? boolean Whether to make a binary request. If false, UTF-8 is used.
    ---@overload fun(params: CCHttpRequest)
    ---When using the `CCHttpRequest` overload, `body` is not used.
    ---@return CCHttpResponse|CCBinaryHttpResponse|nil response The resulting response which can be read from, or nil if it failed (404, connection timeout, etc).
    ---@return string failureReason A message detailing why the request failed.
    ---@return CCHttpResponse|CCBinaryHttpResponse|nil failedResponse The failing response, if available.
    get = function (url, headers, binary) end,

    ---Make an HTTP GET request to the given URL.
    ---@param url string The URL to request.
    ---@param headers? table<string, string> Additional headers to send.
    ---@param binary? boolean Whether to make a binary request. If false, UTF-8 is used.
    ---@overload fun(params: CCHttpRequest)
    ---@return CCHttpResponse|CCBinaryHttpResponse|nil response The resulting response which can be read from, or nil if it failed (404, connection timeout, etc).
    ---@return string failureReason A message detailing why the request failed.
    ---@return CCHttpResponse|CCBinaryHttpResponse|nil failedResponse The failing response, if available.
    post = function (url, body, headers, binary) end,

    ---Asynchronously determine whether a URL can be requested.
    ---If this returns `true`, you should listen for `http_check` events which will contain futher information about whether the URL is *allowed* or not.
    ---A URL may be invalid if it is malformed or has been blocked in the Minecraft server configuration.
    ---@param url string The URL to check.
    ---@return boolean isNotInvalid True when the URL is not invalid.
    ---@return string|nil invalidReason A reason why the URL is not valid.
    checkURLAsync = function (url) end,

    ---Determine whether a URL can be requested.
    ---If this returns `true`, you should listen for `http_check` events which will contain futher information about whether the URL is *allowed* or not.
    ---A URL may be invalid if it is malformed or has been blocked in the Minecraft server configuration.
    ---@param url string The URL to check.
    ---@return boolean isNotInvalid True when the URL is not invalid.
    ---@return string|nil invalidReason A reason why the URL is not valid.
    checkURL = function (url) end,

    ---Open a websocket.
    ---@param url string The websocket URL to connect to. This should have a `ws://` or `wss://` protocol.
    ---@param headers? table<string, string> Additional headers to send as part of the initial connection.
    ---@return CCWebSocket|boolean websocket A websocket instance, or `false` if the connection failed.
    ---@return string errorMessage An error message describing why the connection failed.
    websocket = function (url, headers) end,

    ---Asynchronously open a websocket.
    ---
    ---This method returns immediately. A `websocket_success` or `websocket_failure` event will be queued once the request has completed.
    ---@param url string The websocket URL to connect to. This should have a `ws://` or `wss://` protocol.
    ---@param headers? table<string, string> Additional headers to send as part of the initial connection.
    websocketAsync = function (url, headers) end
}
