--- ComputerCraftScripts-Get: An installer and updater.

-- Arguments:
-- -ssu   Suppress self-updater

local updaterProgramName = "ccs-get"
local ccsDirectory = "ccs"
local updaterUrl = "https://raw.githubusercontent.com/Trinitek/ComputerCraftScripts/master/ccs-get.lua"
local githubContentRoot = "https://api.github.com/repos/Trinitek/ComputerCraftScripts/contents"
local githubCommitsRoot = "https://api.github.com/repos/Trinitek/ComputerCraftScripts/commits?per_page=1"
local githubScriptsDirectory = "scripts"
local lockFileName = "css-get.lock"

---@param message any
---@param color number
local function printColor(message, color)
    local originalColor = term.getTextColor();
    term.setTextColor(color);
    print(message);
    term.setTextColor(originalColor);
end

---@class Lockfile
---@field latestCommit string?

---@return string
local function getLockfilePath()
    return lockFileName;
end

---@return Lockfile
local function readLockfile()
    local lockfilePath = getLockfilePath();
    local lockfileReadHandle --[[@as CCBinaryReadHandle]], errorMessage = fs.open(lockfilePath, "rb");
    if not lockfileReadHandle then
        return { };
    end

    local lockfileContents = lockfileReadHandle.readAll();
    lockfileReadHandle.close();
    if not lockfileContents then
        return { };
    end

    local lockfileDeserialized = textutils.unserializeJSON(lockfileContents);
    return lockfileDeserialized or { };
end

---@param lockfile Lockfile
local function writeLockfile(lockfile)
    local lockfilePath = getLockfilePath();
    local lockfileWriteHandle --[[@as CCFileBinaryWriteHandle]], errorMessage = fs.open(lockfilePath, "wb");
    if not lockfileWriteHandle then
        error("Couldn't open lockfile for writing: ".. errorMessage);
    end

    local lockfileSerialized = textutils.serializeJSON(lockfile, false);

    lockfileWriteHandle.write(lockfileSerialized);
    lockfileWriteHandle.close();

    print("Updated lockfile");
end

---@return boolean
local function listContains(list, x)
    for _, v in pairs(list) do
        if v == x then return true end
    end
    return false
end

---@return boolean appliedUpdate
local function checkForSelfUpdate()
    print("ccs-get: An installer and updater")

    local updaterPath = shell.resolveProgram(arg[0]);

    if not updaterPath then
        error("Couldn't find the updater script in the program path.")
    end

    local selfFileRead --[[@as CCFileReadHandle]], selfFileReadErr = fs.open(updaterPath, "r")

    if not selfFileRead then
        error("Could not read updater script: " .. selfFileReadErr)
    end

    local httpGetUpdaterResponse --[[@as CCHttpResponse]], httpGetUpdaterErr = http.get(updaterUrl)

    if not httpGetUpdaterResponse then
        error("Could not fetch updater script: " .. httpGetUpdaterErr)
    end

    local fetchedScriptContents = httpGetUpdaterResponse.readAll() or ""
    local localScriptContents = selfFileRead.readAll()

    httpGetUpdaterResponse.close()
    selfFileRead.close()

    if fetchedScriptContents ~= localScriptContents then

        local selfFileWrite --[[@as CCFileWriteHandle]], selfFileWriteErr = fs.open(updaterPath, "w");

        if not selfFileWrite then
            error("Could not write updater script: " .. selfFileWriteErr);
        end

        selfFileWrite.write(fetchedScriptContents)
        selfFileWrite.flush()
        selfFileWrite.close()

        print("Updated " .. updaterProgramName .. " (" .. string.len(fetchedScriptContents) .. " chars)")

        if not listContains(arg, "-ssu") then
            table.insert(arg, "-ssu")
        end

        shell.run(arg[0] .. " " .. table.concat(arg, " "))

        return true
    else
        printColor("No updates available for " .. updaterProgramName, colors.yellow)
        return false
    end
end

local function updateProgramPath()
    local paths = { }

    -- separator character is a colon `:`
    for p in string.gmatch(shell.path(), "([^:]+)") do
        table.insert(paths, p)
    end

    if not listContains(paths, ccsDirectory) then
        print("Adding " .. ccsDirectory .. " to program path")
        table.insert(paths, ccsDirectory)
        local newPath = table.concat(paths, ":");
        shell.setPath(newPath);
    end
end

local function createStartupFile()
    if not fs.exists("startup.lua") then
        local startupFile --[[@as CCFileWriteHandle]], startupFileError = fs.open("startup.lua", "w")
        
        if not startupFile then
            error("Couldn't open startup file for writing: " .. startupFileError)
        end

        startupFile.writeLine("local ccs = require('ccs-get')")
        startupFile.writeLine("ccs.updateProgramPath()")
        startupFile.close()
        print("Created startup file")
    end
end

---@class GithubContent
---@field name string
---@field path string
---@field sha string
---@field size integer
---@field url string URL to a content endpoint for this file. Useful for recursing directories.
---@field download_url string URL to the file's raw content.
---@field type '"file"'|'"dir"'|'"symlink"'|'"submodule"'

---@class GithubCommit
---@field sha string

local github = {
    ---Gets file and directory content from a GitHub `contents` endpoint.
    ---See https://docs.github.com/en/rest/reference/repos#get-repository-content.
    ---A valid URL will look like `https://api.github.com/repos/{owner}/{repo}/contents/{path}`.
    ---@param url? string Content endpoint to fetch
    ---@return GithubContent[] contentListing
    getContentListing = function (url)
        local headers = {
            ["Accept"] = "application/vnd.github.v3+json"
        }

        url = url or githubContentRoot

        local response --[[@as CCHttpResponse]], failureReason = http.get(url, headers)

        if not response then
            error(failureReason);
        end

        local jsonResponse = response.readAll();

        if not jsonResponse then
            error("Unexpected null JSON response from API call.")
        end

        local deserialized, deserializeErrorMessage = textutils.unserializeJSON(jsonResponse)

        if not deserialized then
            error(deserializeErrorMessage)
        end

        return deserialized
    end,

    ---Gets the latest commit from a GitHub `contents` endpoint.
    ---See https://docs.github.com/en/rest/commits/commits#list-commits
    ---A valid URL will look like `https://api.github.com/repos/{owner}/{repo}/commits`
    ---@param url? string Commit endpoint to fetch
    ---@return GithubCommit|nil
    getLatestCommit = function (url)
        local headers = {
            ["Accept"] = "application/vnd.github.v3+json"
        }

        url = url or githubCommitsRoot;

        local response --[[@as CCHttpResponse]], failureReason = http.get(url, headers);

        if not response then
            error(failureReason);
        end

        local jsonResponse = response.readAll();

        if not jsonResponse then
            error("Unexpected null JSON response from API call.");
        end

        local deserialized --[[@as table<GithubCommit>]], deserializedErrorMessage = textutils.unserializeJSON(jsonResponse);

        if not deserialized then
            error(deserializedErrorMessage);
        end

        return deserialized[1];
    end
}

---@class ContentListing
---@field localPath string
---@field githubContent GithubContent

---@param url string
---@return ContentListing[]
local function enumerateContentListings(url)
    ---@type ContentListing[]
    local contents = { }

    ---@param rUrl string
    local function recursiveGet(rUrl)

        for _, v in pairs(github.getContentListing(rUrl)) do
            if v.type == "dir" then
                recursiveGet(v.url)
            elseif v.type == "file" then
                -- Remove remote root directory (and following slash) and replace it with local root
                local remotePath = string.sub(v.path, string.len(githubScriptsDirectory) + 2, -1)
                local localDestPath = fs.combine(ccsDirectory, remotePath)
                table.insert(contents, { localPath = localDestPath, githubContent = v })
            end
        end
    end

    recursiveGet(githubContentRoot .. "/" .. githubScriptsDirectory)

    return contents
end

---@return GithubContent|nil
local function findRemoteScriptsDirectory()
    local rootListing = github.getContentListing();

    for _, v in pairs(rootListing) do
        if v.name == githubScriptsDirectory then
            return v
        end
    end

    return nil
end

-- If loaded with `require`, expose some functions but do not execute main section.
if package.loaded["ccs-get"] then
    return {
        listContains = listContains,
        github = github,
        enumerateContentListings = enumerateContentListings,
        updateProgramPath = updateProgramPath,
        readLockfile = readLockfile,
        writeLockfile = writeLockfile
    }
end

-- Entry point

if not listContains(arg, "-ssu") then
    if checkForSelfUpdate() then
        return
    end
end

print("Using remote root '" .. githubContentRoot .. "'")

local remoteScriptsContent = findRemoteScriptsDirectory()

if not remoteScriptsContent then
    error("Could not find '" .. githubScriptsDirectory .. "' on remote")
else
    print("Found content directory '" .. githubScriptsDirectory .. "' on remote")
end

for _, v in pairs(enumerateContentListings(remoteScriptsContent.url)) do
    print("Fetching " .. v.githubContent.path)

    local destFile --[[@as CCFileBinaryWriteHandle]], destFileError = fs.open(v.localPath, "wb")

    if not destFile then
        error("Could not open file " .. v.localPath .. ": " .. destFileError)
    end

    local remoteRequest, failReason = http.get(v.githubContent.download_url, nil, true)

    if not remoteRequest then
        error(failReason)
    end

    destFile.write(remoteRequest.readAll())

    destFile.close()
    remoteRequest.close()
end

updateProgramPath()

createStartupFile()

print("Done")
