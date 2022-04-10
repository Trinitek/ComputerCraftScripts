---https://tweaked.cc/module/fs.html

---@diagnostic disable: lowercase-global

---@class CCFileHandle_Closable
CCFileHandle_Closable = {
    ---Closes the file, freeing any resources it uses.
    ---
    ---Throws if the file has already been closed.
    close = function () end
}

---@class CCFileHandle_Flushable
CCFileHandle_Flushable = {
    ---Save the current file without closing it.
    ---
    ---Throws if the file has been closed.
    flush = function () end
}

---@alias CCFileHandleSeekWhence
---| '"set"' # `offset` is relative to the beginning of the file.
---| '"cur"' # Relative to the current position.
---| '"end"' # Relative to the end of the file.

---@class CCFileHandle_Seekable
CCFileHandle_Seekable = {
    ---Seek to a new position within the file, changing where bytes are written to. The new position is an offset relative to some start position.
    ---@param whence CCFileHandleSeekWhence The reference point for `offset`. Default is "cur".
    ---@param offset integer The offset to seek to.
    ---@return integer|nil newPosition The new position, or nil if the seek failed.
    ---@return string errorMessage A message describing why the seek failed.
    ---Throws if the file has been closed.
    seek = function (whence, offset) end
}

---@class CCFileReadHandle : CCFileHandle_Closable
CCFileReadHandle = {
    ---Read a number of characters from the file.
    ---@param count? integer The number of characters to read. Default is 1.
    ---@return string|nil contents The read characters, or nil if the end of the file has been reached.
    --- - Throws when `count` < 0
    --- - Throws if the file has been closed.
    read = function (count) end,

    ---Read a line from the file.
    ---@param withTrailing? boolean Whether to include the newline characters with the returned string. Default is `false`.
    ---@return string|nil contents read line or nil if the end of the file has been reached.
    ---Throws if the file has been closed.
    readLine = function (withTrailing) end,

    ---Read the remainder of the file.
    ---@return string|nil contents The remaining contents of the file, or nil if the end of the file has been reached.
    ---Throws if the file has been closed.
    readAll = function () end
}

---@class CCBinaryReadHandle : CCFileHandle_Closable
CCBinaryReadHandle = {
    read = function (count) end,
    readLine = function (withTrailing) end,
    readAll = function (count) end
}

---@class CCFileWriteHandle : CCFileHandle_Closable, CCFileHandle_Flushable
CCFileWriteHandle = {
    ---Write a string of characters to the file.
    ---@param value string The value to write to the file.
    ---Throws if the file has been closed.
    write = function (value) end,

    ---Write a string of characters to the file, followed by a newline character.
    ---@param value string The value to write to the file.
    ---Throws if the file has been closed.
    writeLine = function (value) end,
}

---@class CCFileBinaryWriteHandle : CCFileHandle_Closable, CCFileHandle_Flushable, CCFileHandle_Seekable
CCFileBinaryWriteHandle = {
    write = function (...) end
}

---@alias CCFileMode
---| '"r"' # Read
---| '"w"' # Write
---| '"a"' # Append
---| '"rb"' # Read binary
---| '"wb"' # Write binary
---| '"ab"' # Append binary

fs = {
    isDriveRoot = function (path) end,
    complete = function (path, location, include_files, include_dirs) end,
    list = function (path) end,
    combine = function (path, ...) end,
    getName = function (path) end,
    getDir = function (path) end,
    getSize = function (path) end,
    exists = function (path) end,
    isDir = function (path) end,
    isReadOnly = function (path) end,
    makeDir = function (path) end,
    move = function (path, dest) end,
    copy = function (path, dest) end,
    delete = function (path) end,

    ---Opens a file for reading or writing.
    ---@param path string The path to the file to open.
    ---@param mode CCFileMode The mode to open the file with.
    ---@return CCFileReadHandle | CCFileWriteHandle | CCBinaryReadHandle | CCFileBinaryWriteHandle | nil handle A file handle, or nil if the file could not be opened.
    ---@return string|nil errorMessage A message explaining why the file cannot be opened.
    open = function (path, mode) end,

    getDrive = function (path) end,
    getFreeSpace = function (path) end,
    find = function (path) end,
    getCapacity = function (path) end,
    attributes = function (path) end
}
