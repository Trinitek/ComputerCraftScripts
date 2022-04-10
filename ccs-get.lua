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
end

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
    
        shell.execute(arg[0], table.concat(arg, " "))
    else
        print("No updates available for " .. updaterProgramName .. ".")
    end
end

if not listContains(arg, "-u") then
    checkForSelfUpdate()
    return
end

print("TODO: Do package updates here...")
