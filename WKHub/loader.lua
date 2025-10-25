-- ============================================
-- WKHUB MAIN LOADER (SIMPLE DYNAMIC VERSION)
-- Relies on games.json from GitHub
-- ============================================

local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")

-- Base URL for scripts
local BASE_URL = "https://raw.githubusercontent.com/wkrisdiyanto/wkhub/main/WKHub/"

-- GitHub JSON URL for game database
local GAMES_JSON_URL = "https://raw.githubusercontent.com/wkrisdiyanto/wkhub/main/WKHub/games.json"

-- Game name patterns for auto-detection
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

local function cacheBuster(url)
    return url .. (url:find("?") and "&" or "?") .. "t=" .. os.time()
end

local function fetchGamesFromGitHub()
    local success, result = pcall(function()
        local jsonUrl = cacheBuster(GAMES_JSON_URL)
        local jsonData = game:HttpGet(jsonUrl, true)
        return HttpService:JSONDecode(jsonData)
    end)
    
    if success and result then
        local gamesTable = {}
        for _, gameInfo in pairs(result) do
            if gameInfo.placeId and gameInfo.name and gameInfo.script then
                gamesTable[tonumber(gameInfo.placeId)] = {
                    name = gameInfo.name,
                    script = gameInfo.script
                }
            end
        end
        return true, gamesTable
    else
        return false, nil
    end
end

local function loadScript(scriptName, gameName)
    local url = BASE_URL .. scriptName
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
    local gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
    
    for pattern, scriptFile in pairs(GAME_PATTERNS) do
        if gameName:match(pattern) then
            return scriptFile, gameName
        end
    end
    
    return nil, gameName
end

local function notify(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 5
        })
    end)
end

-- Anti-AFK Function
local function enableAntiAFK()
    local player = Players.LocalPlayer
    local antiAFKConnection = player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
    print("Anti-AFK Enabled")
    notify("WKHub", "Anti-AFK Protection Active", 3)
    return antiAFKConnection
end

-- ============================================
-- MAIN EXECUTION
-- ============================================

print("WKHub Simple Dynamic Loader v4")

local currentPlace = game.PlaceId
print("Place ID:", currentPlace)

-- Enable Anti-AFK immediately
local antiAFKConn = enableAntiAFK()

-- Fetch games from JSON
local fetchSuccess, GAMES = fetchGamesFromGitHub()

if not fetchSuccess then
    notify("WKHub Error", "Failed to load game database from GitHub. Check games.json.", 8)
    print("❌ JSON fetch failed")
    return -- Exit early
end

print("✅ Loaded games from JSON")

-- Check database
local gameInfo = GAMES[currentPlace]

if gameInfo then
    print("Game Found:", gameInfo.name)
    
    local success, err = loadScript(gameInfo.script, gameInfo.name)
    
    if success then
        print("Script loaded!")
        notify("WKHub", gameInfo.name .. " loaded!", 5)
        
        -- Mobile Dock Button for toggling menu (general)
        if _G.WKHubWindow then
            local DockGui = Instance.new("ScreenGui")
            DockGui.Name = "WKHubDock"
            DockGui.ResetOnSpawn = false
            DockGui.Parent = game:GetService("CoreGui")

            local DockFrame = Instance.new("Frame")
            DockFrame.Size = UDim2.new(0, 60, 0, 60)
            DockFrame.Position = UDim2.new(1, -70, 1, -70)
            DockFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            DockFrame.BorderSizePixel = 0
            DockFrame.Parent = DockGui

            local DockCorner = Instance.new("UICorner")
            DockCorner.CornerRadius = UDim.new(0, 30)
            DockCorner.Parent = DockFrame

            local DockButton = Instance.new("TextButton")
            DockButton.Size = UDim2.new(1, 0, 1, 0)
            DockButton.BackgroundTransparency = 1
            DockButton.Text = "☰"
            DockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            DockButton.TextScaled = true
            DockButton.Font = Enum.Font.GothamBold
            DockButton.Parent = DockFrame

            local isMinimized = _G.WKHubWindow.Minimized or false
            DockButton.Activated:Connect(function()
                isMinimized = not isMinimized
                _G.WKHubWindow.Minimized = isMinimized
                if isMinimized then
                    DockButton.Text = "▶"
                else
                    DockButton.Text = "☰"
                end
            end)
            
            notify("WKHub", "Dock button added for mobile!", 3)
        end
    else
        warn("Load failed:", err)
        notify("WKHub Error", "Failed to load script. Check console.", 8)
    end
else
    -- Auto-detect by name
    print("Auto-detecting...")
    
    local scriptFile, gameName = detectGameByName()
    
    if scriptFile then
        print("Auto-detected:", gameName)
        
        local success, err = loadScript(scriptFile, gameName)
        
        if success then
            print("Script loaded!")
            notify("WKHub", gameName .. " loaded!", 5)
        else
            warn("Load failed:", err)
        end
    else
        local gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
        print("Game not supported:", gameName)
        print("Place ID:", currentPlace)
        
        notify("WKHub", "Game not supported! Place ID: " .. currentPlace, 10)
        
        if setclipboard then
            setclipboard(tostring(currentPlace))
            print("Place ID copied!")
        end
        
        print("Add to games.json on GitHub")
    end
end

-- Cleanup Anti-AFK on script end (optional, but keeps it simple)
if antiAFKConn then
    antiAFKConn:Disconnect()
end
