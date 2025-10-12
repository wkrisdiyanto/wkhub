-- ============================================
-- WKHUB MAIN LOADER
-- ============================================
-- File ini akan auto-detect game dan load script yang sesuai

local GAME_DATABASE = {
    -- Mount Sumbing
    ["14963184269"] = {
        Name = "Mount Sumbing",
        ScriptURL = "https://raw.githubusercontent.com/wkrisdiyanto/wkhub/refs/heads/main/WKHub/sumbing.lua?token=GHSAT0AAAAAADMZV54PC7LIHTPQH6POQ23C2HLAWAQ"
    },
    
    -- Mount Atin
    ["123224294054165"] = {
        Name = "Mount Atin",
        ScriptURL = "https://raw.githubusercontent.com/wkrisdiyanto/wkhub/refs/heads/main/WKHub/atin.lua?token=GHSAT0AAAAAADMZV54PTL7HUZBC6SXVDNUM2HLAU3A"
    },
    
    -- Mount Mono
    ["91490659446272"] = {
        Name = "Mount Mono",
        ScriptURL = "https://raw.githubusercontent.com/wkrisdiyanto/wkhub/refs/heads/main/WKHub/mono.lua?token=GHSAT0AAAAAADMZV54PLH6TRKF5GR3CQCDS2HLAVNQ"
    },
    
    -- Mount Taber
    ["12399530955"] = {
        Name = "Mount Taber",
        ScriptURL = "https://raw.githubusercontent.com/wkrisdiyanto/wkhub/refs/heads/main/WKHub/taber.lua?token=GHSAT0AAAAAADMZV54PZZWQJILZG2A4NUMU2HLAWSA"
    },
    
    -- 99 Nights in the Forest
    ["79546208627805"] = {
        Name = "99 Nights in the Forest",
        ScriptURL = "https://raw.githubusercontent.com/wkrisdiyanto/wkhub/refs/heads/main/WKHub/forest.lua?token=GHSAT0AAAAAADMZV54PVK3J6MTXG2JNVVFK2HLAW2Q"
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
        loadstring(game:HttpGet(gameInfo.ScriptURL))()
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
