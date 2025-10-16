-- ============================================
-- WKHUB MAIN LOADER (SMART VERSION)
-- Auto-detects game even if not in database
-- ============================================

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
    [91490659446272] = {
        name = "Mount Mono",
        script = "mono.lua"
    },
    
    -- 99 Nights in the Forest (FIXED)
    [126509999114328] = {
        name = "99 Nights in the Forest",
        script = "forest.lua"
    }
}

-- Base URL untuk semua script
local BASE_URL = "https://raw.githubusercontent.com/wkrisdiyanto/wkhub/main/WKHub/"

-- Game name patterns untuk auto-detection
local GAME_PATTERNS = {
    ["99 [Nn]ights"] = "forest.lua",
    ["[Mm]ount [Ss]umbing"] = "sumbing.lua",
    ["[Mm]ount [Tt]aber"] = "taber.lua",
    ["[Mm]ount [Aa]tin"] = "atin.lua",
    ["[Mm]ount [Mm]ono"] = "mono.lua"
}

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

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
    print("📥 Loading:", url)
    notify("WKHub", "Loading " .. gameName .. "...", 3)
    
    local success, result = pcall(function()
        return game:HttpGet(cacheBuster(url), true)
    end)
    
    if not success then
        return false, "HTTP Error: " .. tostring(result)
    end
    
    local exec, err = pcall(function()
        loadstring(result)()
    end)
    
    return exec, err
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

-- ============================================
-- MAIN EXECUTION
-- ============================================

print("╔════════════════════════════════╗")
print("║   WKHub Universal Loader v2    ║")
print("╚════════════════════════════════╝")

local currentPlace = game.PlaceId
print("📍 Place ID:", currentPlace)

-- Step 1: Check database
local gameInfo = GAMES[currentPlace]

if gameInfo then
    print("✅ Game Found in Database:", gameInfo.name)
    
    local success, err = loadScript(gameInfo.script, gameInfo.name)
    
    if success then
        print("✅ Script loaded successfully!")
        notify("WKHub", gameInfo.name .. " loaded!", 5)
    else
        warn("❌ Failed to load script")
        warn("Error:", err)
        notify("WKHub Error", "Failed to load. Check console (F9)", 8)
    end
else
    -- Step 2: Try auto-detection
    print("🔍 PlaceId not in database, trying auto-detect...")
    
    local scriptFile, gameName = detectGameByName()
    
    if scriptFile then
        print("✅ Auto-detected:", gameName)
        print("📜 Script:", scriptFile)
        
        local success, err = loadScript(scriptFile, gameName)
        
        if success then
            print("✅ Script loaded successfully!")
            notify("WKHub", gameName .. " loaded!", 5)
            print("💡 Tip: Add PlaceId " .. currentPlace .. " to database for faster loading")
        else
            warn("❌ Failed to load script")
            warn("Error:", err)
        end
    else
        -- Step 3: Not supported
        print("❌ Game not supported")
        print("📋 Place ID:", currentPlace)
        print("🎮 Game Name:", gameName)
        
        notify(
            "WKHub", 
            "Game not supported!\nPlace ID: " .. currentPlace,
            10
        )
        
        if setclipboard then
            setclipboard(tostring(currentPlace))
            print("📋 Place ID copied to clipboard!")
        end
        
        print("\n💡 Send this info to developer:")
        print("   Place ID:", currentPlace)
        print("   Game Name:", gameName)
    end
end

print("═══════════════════════════════════")

