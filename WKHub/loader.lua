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
    -- 99 Nights in the Forest (in-game place)
    ["126650999114328"] = {
        Name = "99 Nights in the Forest",
        ScriptURL = "https://raw.githubusercontent.com/wkrisdiyanto/wkhub/main/WKHub/forest.lua"
    },
    
    -- Tambahkan game lain di sini
    -- ["PLACE_ID"] = {
    --     Name = "Game Name",
    --     ScriptURL = "URL_SCRIPT"
    -- },
}

-- Optional: universe-level mapping (works across lobby/ingame places of the same experience)
local UNIVERSE_DATABASE = {
    -- ["UNIVERSE_ID"] = { Name = "Game Name", ScriptURL = "https://.../script.lua" }
    ["79546208627805"] = {
        Name = "99 Nights in the Forest",
        ScriptURL = "https://raw.githubusercontent.com/wkrisdiyanto/wkhub/main/WKHub/forest.lua"
    },
    ["732693493454"] = {
        Name = "99 Nights in the Forest",
        ScriptURL = "https://raw.githubusercontent.com/wkrisdiyanto/wkhub/main/WKHub/forest.lua"
    }
}

-- ============================================
-- DETECTION & LOADING
-- ============================================

local currentPlaceId = tostring(game.PlaceId)
local currentGameId = tostring(game.GameId)

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
        -- Allow either flat placeId->entry mapping, or nested { places = {...}, universes = {...} }
        local places = data.places or data
        if typeof(places) == "table" then
            for placeId, entry in pairs(places) do
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
        local universes = data.universes
        if typeof(universes) == "table" then
            for universeId, entry in pairs(universes) do
                local key = tostring(universeId)
                if typeof(entry) == "table" then
                    local name = entry.Name or ("Game " .. key)
                    local url = entry.ScriptURL or entry.Url or entry.url
                    if typeof(url) == "string" and #url > 0 then
                        UNIVERSE_DATABASE[key] = { Name = name, ScriptURL = url }
                    end
                elseif typeof(entry) == "string" then
                    UNIVERSE_DATABASE[key] = { Name = ("Game " .. key), ScriptURL = entry }
                end
            end
        end
    end
end

-- Try to pull latest mappings (safe to fail silently and fall back to local)
mergeRemoteDatabase()

-- Helper: fetch UniverseId for a given PlaceId
local function fetchUniverseId(placeId)
    local HttpService = game:GetService("HttpService")
    local url = "https://games.roblox.com/v1/places/multiget-place-details?placeIds=" .. tostring(placeId)
    local body = game:HttpGet(withCacheBuster(url))
    local arr = HttpService:JSONDecode(body)
    if typeof(arr) == "table" and #arr > 0 then
        local uni = arr[1] and arr[1].universeId
        if uni ~= nil then return tostring(uni) end
    end
    return nil
end

-- Cache for seed place -> universe id
local SEED_UNIVERSE_CACHE = {}

print("=== WKHub Loader ===")
print("Current Place ID:", currentPlaceId)
print("Current Game ID:", currentGameId)

-- Resolve after remote merge to allow dynamic updates
local gameInfo = GAME_DATABASE[currentPlaceId] or UNIVERSE_DATABASE[currentGameId]

-- Fallback: match by UniverseId of known seed places (handles lobby vs ingame automatically)
if not gameInfo then
    local okCur, currentUniverseId = pcall(fetchUniverseId, currentPlaceId)
    if okCur and currentUniverseId then
        -- Direct universe mapping from manifest
        if UNIVERSE_DATABASE[currentUniverseId] then
            gameInfo = UNIVERSE_DATABASE[currentUniverseId]
        else
            for seedPlaceId, entry in pairs(GAME_DATABASE) do
                if seedPlaceId ~= currentPlaceId then
                    local cached = SEED_UNIVERSE_CACHE[seedPlaceId]
                    if not cached then
                        local okSeed, seedUni = pcall(fetchUniverseId, seedPlaceId)
                        if okSeed then
                            SEED_UNIVERSE_CACHE[seedPlaceId] = seedUni
                            cached = seedUni
                        end
                    end
                    if cached and cached == currentUniverseId then
                        gameInfo = entry
                        break
                    end
                end
            end
        end
    end
end

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
