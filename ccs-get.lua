--- ComputerCraftScripts-Get: An installer and updater.

-- Arguments:
-- -u   Suppress self-updater

local updaterProgramName = "ccs-get"
local ccsDirectory = "ccs"
local updaterUrl = "https://raw.githubusercontent.com/Trinitek/ComputerCraftScripts/master/ccs-get.lua"

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

        if not listContains(arg, "-u") then
            table.insert(arg, "-u")
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

---@class GithubContent
---@field name string
---@field path string
---@field sha string
---@field size integer
---@field url string
---@field download_url string
---@field type '"file"'|'"dir"'

local github = {
    ---@param url? string Content endpoint to fetch
    ---@return GithubContent[] contentListing
    getContentListing = function (url)
        local headers = {
            ["Accept"] = "application/vnd.github.v3+json"
        }

        url = url or "https://api.github.com/repos/Trinitek/ComputerCraftScripts/contents"

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

-- Entry point

if not listContains(arg, "-u") then
    if checkForSelfUpdate() then
        return
    end
end

local rootListing = github.getContentListing();

for _, v in pairs(rootListing) do
    if v.name == "scripts" then
        print(v.url)
        break
    end
end

print("TODO: Do package updates here...")

updateProgramPath()

print("Done")
