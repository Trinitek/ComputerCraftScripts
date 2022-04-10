---https://tweaked.cc/module/shell.html

---@diagnostic disable: lowercase-global

shell = {
    ---Run a program with the supplied arguments.
    ---
    ---Unlike `shell.run`, each argument is passed to the program verbatim. While `shell.run("echo", "b c")`
    ---runs `echo` with `b` and `c`, `shell.execute("echo", "b c")` runs `echo` with a single argument `b c`.
    ---@param command string The program to execute.
    ---@vararg string Arguments to this program.
    ---@return boolean cleanExit Whether the program exited successfully.
    execute = function (command, ...) end,

    ---Run a program with the supplied arguments.
    ---
    ---All arguments are concatenated together and then parsed as a command line. As a result,
    ---`shell.run("program a b")` is the same as `shell.run("program", "a", "b")`.
    ---@vararg string The program to run and its arguments.
    ---@return boolean cleanExit Whether the program exited successfully.
    run = function (...) end,

    exit = function () end,
    dir = function () end,
    setDir = function (dir) end,
    path = function () end,
    setPath = function (path) end,

    ---Resolve a relative path to an absolute path.
    ---
    ---The `fs` and `io` APIs work using absolute paths, and so we must convert any paths relative to the current directory to absolute ones.
    ---This does nothing when the path starts with `/`.
    ---@param path string The path to resolve.
    ---@return string resolvedPath The resolved absolute path.
    resolve = function (path) end,

    ---Resolve a program, using the program path and list of registered aliases.
    ---@param command string The name of the program.
    ---@return string|nil resolvedPath The absolute path to the program, or nil if it could not be found.
    resolveProgram = function (command) end,

    programs = function (include_hidden) end,
    complete = function (sLine) end,
    completeProgram = function (program) end,
    setCompletionFunction = function (program, complete) end,
    getCompletionInfo = function () end,
    getRunningProgram = function () end,
    setAlias = function (command, program) end,
    clearAlias = function (command) end,
    aliases = function () end,
    openTab = function (...) end,
    switchTab = function (id) end
}
