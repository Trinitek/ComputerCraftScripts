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

---@class CCFileAttributes
---@field size integer
---@field isDir boolean
---@field isReadOnly boolean
---@field created integer Milliseconds since UNIX epoch.
---@field modified integer Milliseconds since UNIX epoch.

fs = {
    ---Returns true if a path is mounted to the parent filesystem.
    ---
    ---The root filesystem (`/`) is considered a mount, along with disk folders and the "rom" folder. Other programs such as network shares
    ---can extend this to make other mount types by correctly assigning their return value for `fs.getDrive`.
    ---@param path string The path to check.
    ---@return boolean isMounted True if the path is mounted, rather than a normal file or folder.
    ---Throws if the path does not exist.
    isDriveRoot = function (path) end,

    ---Provides completion for a file or directory name, suitable for use with `_G.read`.
    ---
    ---When a directory is a possible candidate for completion, two entities are included: one with a trailing slash (`/`)
    ---indicating that entries within this directory exist, and one without, indicating this entry is an immediate completion candidate.
    ---The parameter `include_dirs` can be set to `false` to only include those with a trailing slash.
    ---@param path string The path to complete.
    ---@param location string The location where paths are resolved from.
    ---@param include_files? boolean If `false`, only directories will be included in the returned list.
    ---@param include_dirs? boolean If `false`, "raw" directories will not be included in the returned list.
    ---@return string[] candidates A list of possible completion candidates.
    complete = function (path, location, include_files, include_dirs) end,

    ---Returns a list of files in a directory.
    ---@param path string The path to list.
    ---@return string[] listing A table with a list of files in the directory.
    list = function (path) end,

    ---Combines several parts of a path into one full path, adding separators as needed.
    ---@param path string The first part of the path, i.e. a parent directory.
    ---@vararg string Additional parts of the path to combine.
    ---@return string newPath
    ---Throws when arguments are malformed.
    ---
    ---Example:
    ---```lua
    ---fs.combine("/roms/programs", "../apis", "parallel.lua")
    ----- => "rom/apis/parallel.lua"
    ---```
    combine = function (path, ...) end,

    ---Returns the file name portion of a path.
    ---@param path string The path to get the name from.
    ---@return string filePart The final part of the path.
    ---Example:
    ---```lua
    ---fs.getName("rom/startup.lua")
    ----- => "startup.lua"
    ---```
    getName = function (path) end,

    ---Returns the parent directory portion of a path. This works for both complete file and directory paths.
    ---@param path string The path to get the directory from.
    ---@return string directoryPart The path with the final part removed.
    ---Example:
    ---```lua
    ---fs.getDir("rom/startup.lua")
    ----- => "rom"
    ---fs.getDir("a/b/c/")
    ----- => "a/b"
    ---```
    getDir = function (path) end,

    ---Returns the size of the specified file in bytes.
    ---@param path string The path to the file.
    ---@return integer bytes
    ---Throws if the path doesn't exist.
    getSize = function (path) end,

    ---Returns whether the specified path exists.
    ---@param path string The path to check.
    ---@return boolean exists
    exists = function (path) end,

    ---Returns whether the specified path refers to a directory.
    ---@param path string The path to check.
    ---@return boolean isDir
    isDir = function (path) end,

    ---Returns whether the specified path is read-only.
    ---@param path string The path to check.
    ---@return boolean isReadOnly
    isReadOnly = function (path) end,

    ---Creates a directory and any missing parents.
    ---@param path string The path to create.
    ---Throws if the directory could not be created.
    makeDir = function (path) end,

    ---Moves a file or directory from one path to another. Parent directories are created as needed.
    ---@param path string The current file or directory to move.
    ---@param dest string The destination path.
    ---Throws if the file or directory couldn't be moved.
    move = function (path, dest) end,

    ---Copies a file or directory to a new path. Parent directories are created as needed.
    ---@param path string The current file or directory to copy.
    ---@param dest string The destination path.
    ---Throws if the file or directory couldn't be copied.
    copy = function (path, dest) end,

    ---Deletes a file or directory. If the path points to a directory, all enclosed files and subdirectories are also deleted.
    ---@param path string The path to delete.
    ---Throws if the file or directory couldn't be deleted.
    delete = function (path) end,

    ---Opens a file for reading or writing.
    ---@param path string The path to the file to open.
    ---@param mode CCFileMode The mode to open the file with.
    ---@return CCFileReadHandle | CCFileWriteHandle | CCBinaryReadHandle | CCFileBinaryWriteHandle | nil handle A file handle, or nil if the file could not be opened.
    ---@return string|nil errorMessage A message explaining why the file cannot be opened.
    open = function (path, mode) end,

    ---Returns the name of the mount on which the specified path is located.
    ---@param path string The path of which to get the drive.
    ---@return string driveName The naem of the drive, like `"hdd"` for local files, or `"rom"` for ROM files.
    ---Throws if the path doesn't exist.
    getDrive = function (path) end,

    ---Returns the amount of free space available in bytes on the drive on which the path is located.
    ---@param path string The path to check.
    ---@return integer|"unlimited" freeSpace The amount of free space, or "unlimited".
    ---Throws if the path doesn't exist.
    getFreeSpace = function (path) end,

    ---Searches for files matching a string with wildcards.
    ---
    ---The search string is formatted much like a normal path string, but can include wildcards (`*`) to look for files
    ---matching anything. For example, `rom/*/command*` will return all paths starting with `command` inside any subdirectory
    ---of `/rom`.
    ---@param path string The wildcard-qualified path to search.
    ---@return string[] matchedPaths
    ---Throws if the path doesn't exist.
    find = function (path) end,

    ---Returns the capacity of the drive in bytes.
    ---@param path string The path of the drive to get.
    ---@return integer|nil capacity The drive's capacity, or nil for "read-only" drives like ROM or treasure disks.
    getCapacity = function (path) end,

    ---Get attributes about a specific file or folder.
    ---
    ---The creation and modification times given are the number of milliseconds since the UNIX epoch. Use `os.date`
    ---to convert these into a more usable form as you see fit.
    ---@param path string The path for which to get the attributes.
    ---@return CCFileAttributes attributes
    ---Throws if the path does not exist.
    attributes = function (path) end
}
