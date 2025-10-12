-- ============================================
-- WKHUB MAIN LOADER (HYBRID VERSION)
-- Simple + Remote Manifest Support
-- ============================================

-- Local game database (fallback jika remote gagal)
local GAMES = {
    -- Mount Sumbing
    [14963184269] = {
        name = "Mount Sumbing",
        script = "https://raw.githubusercontent.com/wkrisdiyanto/wkhub/main/WKHub/sumbing.lua"
    },
    
    -- Mount Taber
    [12399530955] = {
        name = "Mount Taber",
        script = "https://raw.githubusercontent.com/wkrisdiyanto/wkhub/main/WKHub/taber.lua"
    },
    
    -- Mount Atin - ⚠️ GANTI PlaceId yang benar!
    [1232242940] = { -- Example ID, sesuaikan!
        name = "Mount Atin",
        script = "https://raw.githubusercontent.com/wkrisdiyanto/wkhub/main/WKHub/atin.lua"
    },
    
    -- Mount Mono - ⚠️ GANTI PlaceId yang benar!
    [914906594] = { -- Example ID, sesuaikan!
        name = "Mount Mono",
        script = "https://raw.githubusercontent.com/wkrisdiyanto/wkhub/main/WKHub/mono.lua"
    },
    
    -- 99 Nights in the Forest (in-game) - ✅ CONFIRMED
    [126509999114328] = {
        name = "99 Nights in the Forest",
        script = "https://raw.githubusercontent.com/wkrisdiyanto/wkhub/main/WKHub/forest.lua"
    }
}

-- Remote manifest URL (optional - untuk update tanpa edit script)
local MANIFEST_URL = "https://raw.githubusercontent.com/wkrisdiyanto/wkhub/main/WKHub/manifest.json"

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

local function fetchRemoteManifest()
    local ok, result = pcall(function()
        local raw = game:HttpGet(cacheBuster(MANIFEST_URL), true)
        return game:GetService("HttpService"):JSONDecode(raw)
    end)
    
    if ok and type(result) == "table" then
        return result
    end
    return nil
end

local function mergeRemoteGames(manifest)
    if not manifest then return end
    
    -- Support format: { "12345": { name = "...", script = "..." } }
    local games = manifest.games or manifest.places or manifest
    
    for placeId, data in pairs(games) do
        local id = tonumber(placeId)
        if id and type(data) == "table" then
            GAMES[id] = {
                name = data.name or data.Name or ("Game " .. id),
                script = data.script or data.url or data.ScriptURL
            }
        end
    end
end

local function loadScript(url, gameName)
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

-- ============================================
-- MAIN EXECUTION
-- ============================================

print("╔════════════════════════════════╗")
print("║     WKHub Universal Loader     ║")
print("╚════════════════════════════════╝")

local currentPlace = game.PlaceId
print("📍 Current Place ID:", currentPlace)

-- Step 1: Try to fetch remote manifest
print("🌐 Fetching remote manifest...")
local manifest = fetchRemoteManifest()

if manifest then
    print("✅ Remote manifest loaded")
    mergeRemoteGames(manifest)
else
    print("⚠️  Using local database")
end

-- Step 2: Check if game is supported
local gameInfo = GAMES[currentPlace]

if gameInfo then
    print("✅ Game Detected:", gameInfo.name)
    print("📜 Script URL:", gameInfo.script)
    
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
    print("❌ Game not supported")
    print("📋 Place ID:", currentPlace)
    
    notify(
        "WKHub", 
        "Game not supported!\nPlace ID: " .. currentPlace,
        10
    )
    
    -- Auto-copy PlaceId untuk memudahkan report
    if setclipboard then
        setclipboard(tostring(currentPlace))
        print("📋 Place ID copied to clipboard!")
    end
    
    print("\n💡 Tip: Send this Place ID to developer")
end

print("═══════════════════════════════════")
