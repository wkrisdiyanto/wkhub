-- Manual configuration (SDK embedded via obfuscation)
JunkieProtected.API_KEY = "42512885-d927-4395-b168-538f8130308b"
JunkieProtected.PROVIDER = "WKHub"
JunkieProtected.SERVICE_ID = "wkhub"

-- Step 1: Check if keyless mode is enabled
local keylessCheck = JunkieProtected.IsKeylessMode()

if keylessCheck and keylessCheck.keyless_mode then
    print("🎉 Keyless mode enabled - Starting script...")
    -- Your main script here (original loader code will go here)
else
    -- Keyless mode disabled - need a key
    print("🔑 Key required!")
    
    -- Get the key link
    local keyLink = JunkieProtected.GetKeyLink()
    print("Get your key: " .. keyLink)
    
    -- Get key from user (Note: In Roblox, implement a simple GUI or use executor input like ask() if available; hardcoded for demo)
    local userKey = "DEMO_KEY_HERE"  -- Replace with actual input method, e.g., local userKey = game:GetService("HttpService"):GenerateGUID(false) or user prompt
    
    -- Validate the key
    local result = JunkieProtected.ValidateKey({ Key = userKey })
    
    if result == "valid" then
        print("✅ Key is valid! Starting script...")
        
        -- Step 2: Check HWID ban (optional; Roblox HWID is limited, use UserId as proxy)
        local hwid = game.Players.LocalPlayer.UserId  -- Proxy for HWID; implement real HWID if SDK supports
        local isBanned = JunkieProtected.IsHwidBanned(tostring(hwid))
        
        if isBanned then
            print("🚫 Hardware/User is banned!")
            game.Players.LocalPlayer:Kick("Hardware banned from this service")
            return
        end
        
        -- Step 3: Use global variables after verification
        if _G.JD_ExpiresAt then
            local currentTime = os.time()
            local expiresAt = _G.JD_ExpiresAt
            
            if currentTime < expiresAt then
                local timeLeft = expiresAt - currentTime
                local daysLeft = math.floor(timeLeft / 86400)
                print("⏰ Key expires in " .. daysLeft .. " days")
            else
                print("❌ Key has expired!")
                game.Players.LocalPlayer:Kick("Key expired")
                return
            end
        end
        
        -- Step 4: Check premium status
        if _G.JD_IsPremium then
            print("🌟 Premium user detected!")
            -- Enable premium features (e.g., unlock all games in loader)
        else
            print("📝 Standard user")
            -- Optional: Limit features, e.g., only basic games
        end
        
        -- Step 5: Get Discord ID if available
        if _G.JD_DiscordId then
            print("👤 User Discord ID: " .. _G.JD_DiscordId)
            -- Use for user-specific features
        end
        
        -- Your main script here (insert original loader code)
else
        print("❌ Invalid key!")
        game.Players.LocalPlayer:Kick("Invalid key. Get one from: " .. keyLink)
    end
end

-- Insert original loader code here (GAMES table and below)
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
    
    -- 99 Nights in the Forest (FIXED)
    [126509999114328] = {
        name = "99 Nights in the Forest",
        script = "forest.lua"
    },
    
    -- Violence District
    [93978595733734] = {
        name = "Violence District",
        script = "vd.lua"
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
    ["[Mm]ount [Mm]ono"] = "mono.lua",
    ["[Vv]iolence [Dd]istrict"] = "vd.lua"
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

