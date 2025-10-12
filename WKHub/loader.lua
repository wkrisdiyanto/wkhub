-- ============================================
-- WKHUB MAIN LOADER
-- ============================================
-- File ini akan auto-detect game dan load script yang sesuai

local GAME_DATABASE = {
    -- Mount Sumbing
    ["14963184269"] = {
        Name = "Mount Sumbing",
        ScriptURL = "https://raw.githubusercontent.com/wkrisdiyanto/wkhub/main/WKHub/sumbing.lua"
    },
    
    -- Mount Atin
    ["123224294054165"] = {
        Name = "Mount Atin",
        ScriptURL = "https://raw.githubusercontent.com/wkrisdiyanto/wkhub/main/WKHub/atin.lua"
    },
    
    -- Mount Mono
    ["91490659446272"] = {
        Name = "Mount Mono",
        ScriptURL = "https://raw.githubusercontent.com/wkrisdiyanto/wkhub/main/WKHub/mono.lua"
    },
    
    -- Mount Taber
    ["12399530955"] = {
        Name = "Mount Taber",
        ScriptURL = "https://raw.githubusercontent.com/wkrisdiyanto/wkhub/main/WKHub/taber.lua"
    },
    
    -- 99 Nights in the Forest
    ["79546208627805"] = {
        Name = "99 Nights in the Forest",
        ScriptURL = "https://raw.githubusercontent.com/wkrisdiyanto/wkhub/main/WKHub/forest.lua"
    },
    -- 99 Nights in the Forest (alternate place)
    ["1266509999114328"] = {
        Name = "99 Nights in the Forest",
        ScriptURL = "https://raw.githubusercontent.com/wkrisdiyanto/wkhub/main/WKHub/forest.lua"
    },
    
    -- Tambahkan game lain di sini
    -- ["PLACE_ID"] = {
    --     Name = "Game Name",
    --     ScriptURL = "URL_SCRIPT"
    -- },
}

-- ============================================
-- DETECTION & LOADING
-- ============================================

local currentPlaceId = tostring(game.PlaceId)
local gameInfo = GAME_DATABASE[currentPlaceId]

-- Utility: append cache-buster to avoid CDN caching old raw content
local function withCacheBuster(url)
    local hasQuery = string.find(url, "?", 1, true) ~= nil
    local sep = hasQuery and "&" or "?"
    return url .. sep .. "cb=" .. tostring(os.time())
end

-- Optional: Remote manifest so you don't have to edit this file for new games
local REMOTE_MANIFEST_URL = "https://raw.githubusercontent.com/wkrisdiyanto/wkhub/main/WKHub/manifest.json"

local function mergeRemoteDatabase()
    local ok, data = pcall(function()
        local body = game:HttpGet(withCacheBuster(REMOTE_MANIFEST_URL))
        return game:GetService("HttpService"):JSONDecode(body)
    end)
    if ok and typeof(data) == "table" then
        for placeId, entry in pairs(data) do
            local key = tostring(placeId)
            if typeof(entry) == "table" then
                local name = entry.Name or ("Game " .. key)
                local url = entry.ScriptURL or entry.Url or entry.url
                if typeof(url) == "string" and #url > 0 then
                    GAME_DATABASE[key] = { Name = name, ScriptURL = url }
                end
            elseif typeof(entry) == "string" then
                GAME_DATABASE[key] = { Name = ("Game " .. key), ScriptURL = entry }
            end
        end
    end
end

-- Try to pull latest mappings (safe to fail silently and fall back to local)
mergeRemoteDatabase()

print("=== WKHub Loader ===")
print("Current Place ID:", currentPlaceId)

if gameInfo then
    print("Game Detected:", gameInfo.Name)
    print("Loading script from:", gameInfo.ScriptURL)
    
    -- Show loading notification
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "WKHub";
        Text = "Loading " .. gameInfo.Name .. " script...";
        Duration = 5;
    })
    
    -- Load game-specific script
    local success, errorMsg = pcall(function()
        local url = withCacheBuster(gameInfo.ScriptURL)
        loadstring(game:HttpGet(url))()
    end)
    
    if success then
        print("✅ Script loaded successfully!")
    else
        warn("❌ Failed to load script:", errorMsg)
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "WKHub Error";
            Text = "Failed to load script. Check console (F9)";
            Duration = 8;
        })
    end
else
    print("⚠️ Game not supported")
    print("Place ID:", currentPlaceId)
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "WKHub";
        Text = "This game is not supported yet!\nPlace ID: " .. currentPlaceId;
        Duration = 10;
    })
    
    -- Tawarkan untuk copy Place ID
    if setclipboard then
        setclipboard(currentPlaceId)
        print("Place ID copied to clipboard!")
    end
end


print("===================")
