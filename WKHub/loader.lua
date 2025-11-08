-- ============================================
-- WKHUB MAIN LOADER (VENUS LIB VERSION)
-- Auto-detects game even if not in database
-- ============================================

-- Game Database
local GAMES = {
    -- Mount Sumbing
    [14963184269] = {
        name = "Mount Sumbing",
        script = "sumbing.lua"
    },
    
    -- Mount Taber
    [12399530955] = {
        name = "Mount Taber",
        script = "taber.lua"
    },
    
    -- Mount Atin
    [1232242940] = {
        name = "Mount Atin",
        script = "atin.lua"
    },
    
    -- Mount Mono
    [914906594] = {
        name = "Mount Mono",
        script = "mono.lua"
    },
    
    -- 99 Nights in the Forest
    [126509999114328] = {
        name = "99 Nights in the Forest",
        script = "forest.lua"
    },
    
    -- Violence District
    [93978595733734] = {
        name = "Violence District",
        script = "vd.lua"
    },
    
    -- Crocs Quest
    [95937769845016] = {
        name = "Crocs Quest",
        script = "crocs.lua"
    },
    
    -- Fish It!
    [121864768012064] = {
        name = "Fish It!",
        script = "fishit.lua"
    },
    
    -- Plants Vs Brainrots
    [127742093697776] = {
        name = "Plants Vs Brainrots",
        script = "pvb.lua"
    }
}

-- Base URL for all scripts
local BASE_URL = "https://raw.githubusercontent.com/wkrisdiyanto/wkhub/main/WKHub/"

-- Game name patterns for auto-detection
local GAME_PATTERNS = {
    ["99 [Nn]ights"] = "forest.lua",
    ["[Mm]ount [Ss]umbing"] = "sumbing.lua",
    ["[Mm]ount [Tt]aber"] = "taber.lua",
    ["[Mm]ount [Aa]tin"] = "atin.lua",
    ["[Mm]ount [Mm]ono"] = "mono.lua",
    ["[Vv]iolence [Dd]istrict"] = "vd.lua",
    ["[Cc]rocs [Qq]uest"] = "crocs.lua",
    ["[Cc]roctober"] = "crocs.lua",
    ["[Ff]ish [Ii]t"] = "fishit.lua",
    ["[Uu][Pp][Dd] [Ff]ish"] = "fishit.lua",
    ["[Pp]lants [Vv]s [Bb]rainrots"] = "pvb.lua",
    ["[Pp][Vv][Bb]"] = "pvb.lua"
}

-- Helper Functions
local function notify(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 5
        })
    end)
end

local function cacheBuster(url)
    return url .. (url:find("?") and "&" or "?") .. "t=" .. os.time()
end

local function loadScript(scriptName, gameName)
    local url = BASE_URL .. scriptName
    notify("WKHub", "Loading " .. gameName .. "...", 3)
    
    print("[WKHub] Attempting to load:", url)
    
    -- Use general executor methods (not HttpService)
    local result = nil
    local success = false
    
    -- Method 1: game:HttpGet (Most common executor method)
    success, result = pcall(function()
        return game:HttpGet(cacheBuster(url))
    end)
    
    -- Method 2: http_request (General executor)
    if not success and http_request then
        print("[WKHub] Trying http_request...")
        success, result = pcall(function()
            local response = http_request({
                Url = cacheBuster(url),
                Method = "GET"
            })
            return response.Body
        end)
    end
    
    -- Method 3: syn.request (Synapse)
    if not success and syn and syn.request then
        print("[WKHub] Trying syn.request...")
        success, result = pcall(function()
            local response = syn.request({
                Url = cacheBuster(url),
                Method = "GET"
            })
            return response.Body
        end)
    end
    
    if not success then
        warn("[WKHub] HTTP Error:", result)
        return false, "HTTP Error: " .. tostring(result)
    end
    
    print("[WKHub] Script downloaded, executing...")
    
    local scriptFunc, loadErr = loadstring(result)
    if not scriptFunc then
        warn("[WKHub] Loadstring Error:", loadErr)
        return false, "Loadstring Error: " .. tostring(loadErr)
    end
    
    local exec, err = pcall(scriptFunc)
    
    if not exec then
        warn("[WKHub] Execution Error:", err)
        return false, "Execution Error: " .. tostring(err)
    end
    
    return true, nil
end

local function detectGameByName()
    local gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    
    for pattern, scriptFile in pairs(GAME_PATTERNS) do
        if gameName:match(pattern) then
            return scriptFile, gameName
        end
    end
    
    return nil, gameName
end

-- Main Execution
local currentPlace = game.PlaceId

-- Step 1: Check database
local gameInfo = GAMES[currentPlace]

if gameInfo then
    local success, err = loadScript(gameInfo.script, gameInfo.name)
    
    if success then
        notify("WKHub", gameInfo.name .. " loaded!", 5)
        print("[WKHub] Successfully loaded:", gameInfo.name)
    else
        notify("WKHub Error", "Failed to load. Check console (F9)", 8)
        warn("[WKHub] Load failed:", err)
    end
else
    -- Step 2: Try auto-detection
    local scriptFile, gameName = detectGameByName()
    
    if scriptFile then
        print("[WKHub] Game detected:", gameName)
        local success, err = loadScript(scriptFile, gameName)
        
        if success then
            notify("WKHub", gameName .. " loaded!", 5)
            print("[WKHub] Successfully loaded:", gameName)
        else
            notify("WKHub Error", "Failed to load. Check console (F9)", 8)
            warn("[WKHub] Load failed:", err)
        end
    else
        -- Step 3: Not supported
        notify(
            "WKHub", 
            "Game not supported!\nPlace ID: " .. currentPlace,
            10
        )
        
        if setclipboard then
            setclipboard(tostring(currentPlace))
        end
    end
end
