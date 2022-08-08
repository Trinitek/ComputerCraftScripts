--- ComputerCraftScripts-Get: An installer and updater.

-- Arguments:
-- -ssu   Suppress self-updater

local updaterProgramName = "ccs-get"
local ccsDirectory = "ccs"
local updaterUrl = "https://raw.githubusercontent.com/Trinitek/ComputerCraftScripts/master/ccs-get.lua"
local githubContentRoot = "https://api.github.com/repos/Trinitek/ComputerCraftScripts/contents"
local githubScriptsDirectory = "scripts"

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

    ---@type CCFileReadHandle
    local selfFileRead
    ---@type string
    local selfFileReadErr

    selfFileRead, selfFileReadErr = fs.open(updaterPath, "r")

    if not selfFileRead then
        error("Could not read updater script: " .. selfFileReadErr)
    end

    ---@type CCHttpResponse
    local httpGetUpdaterResponse
    ---@type string
    local httpGetUpdaterErr

    httpGetUpdaterResponse, httpGetUpdaterErr = http.get(updaterUrl)

    if not httpGetUpdaterResponse then
        error("Could not fetch updater script: " .. httpGetUpdaterErr)
    end

    local fetchedScriptContents = httpGetUpdaterResponse.readAll()
    local localScriptContents = selfFileRead.readAll()

    httpGetUpdaterResponse.close()
    selfFileRead.close()

    if fetchedScriptContents ~= localScriptContents then

        ---@type CCFileWriteHandle
        local selfFileWrite
        ---@type string
        local selfFileWriteErr

        selfFileWrite, selfFileWriteErr = fs.open(updaterPath, "w");

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
        print("No updates available for " .. updaterProgramName)
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
        local startupFile = fs.open("startup.lua", "w")
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

        ---@type CCHttpResponse
        local response
        ---@type string
        local failureReason

        response, failureReason = http.get(url, headers)

        if not response then
            error(failureReason);
        end

        return textutils.unserializeJSON(response.readAll())
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
        updateProgramPath = updateProgramPath
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

    local destFile = fs.open(v.localPath, "wb")
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
