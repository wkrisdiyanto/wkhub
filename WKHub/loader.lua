-- ============================================
-- WKHUB MAIN LOADER (SIMPLE DYNAMIC VERSION)
-- Relies on games.json from GitHub
-- ============================================

local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")

-- Base URL for scripts
-- local BASE_URL = "https://raw.githubusercontent.com/wkrisdiyanto/wkhub/main/WKHub/"

-- Game name patterns for auto-detection
local GAME_PATTERNS = {
    ["99 [Nn]ights"] = "forest.lua",
    ["[Mm]ount [Ss]umbing"] = "sumbing.lua",
    ["[Mm]ount [Tt]aber"] = "taber.lua",
    ["[Mm]ount [Aa]tin"] = "atin.lua",
    ["[Mm]ount [Mm]ono"] = "mono.lua",
    ["[Vv]iolence [Dd]istrict"] = "vd.lua"
}

-- Add after the GAME_PATTERNS table
local UNIVERSAL_SCRIPT = [[
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "WKHub - Universal (Unsupported Game)",
    SubTitle = "By Exodiuszord - PlaceId: " .. tostring(game.PlaceId),
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 400),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})
_G.WKHubWindow = Window

local Tabs = {
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Visual = Window:AddTab({ Title = "Visual", Icon = "eye" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

Fluent:Notify({
    Title = "Universal Hub",
    Content = "Loaded for unsupported game! PlaceId: " .. tostring(game.PlaceId),
    Duration = 5
})

-- Player Tab
local WalkSpeedToggle = Tabs.Player:AddToggle("WalkSpeedToggle", {
    Title = "WalkSpeed",
    Default = false
})

local SliderWalkSpeed = Tabs.Player:AddSlider("WalkSpeedSlider", {
    Title = "WalkSpeed Amount",
    Default = 16,
    Min = 16,
    Max = 100,
    Rounding = 1,
})

local JumpPowerToggle = Tabs.Player:AddToggle("JumpPowerToggle", {
    Title = "JumpPower",
    Default = false
})

local SliderJumpPower = Tabs.Player:AddSlider("JumpPowerSlider", {
    Title = "JumpPower Amount",
    Default = 50,
    Min = 50,
    Max = 200,
    Rounding = 1,
})

local NoClipToggle = Tabs.Player:AddToggle("NoClip", {
    Title = "NoClip",
    Default = false
})

local noclipping = false
local noclipConnection

NoClipToggle:OnChanged(function()
    noclipping = Options.NoClip.Value
    local player = game.Players.LocalPlayer
    if noclipping then
        noclipConnection = game:GetService("RunService").Stepped:Connect(function()
            local character = player.Character
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
    end
end)

-- WalkSpeed implementation
WalkSpeedToggle:OnChanged(function()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if Options.WalkSpeedToggle.Value then
                humanoid.WalkSpeed = Options.WalkSpeedSlider.Value
            else
                humanoid.WalkSpeed = 16
            end
        end
    end
end)

SliderWalkSpeed:OnChanged(function(value)
    if Options.WalkSpeedToggle.Value then
        local player = game.Players.LocalPlayer
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = value
            end
        end
    end
end)

-- JumpPower implementation
JumpPowerToggle:OnChanged(function()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if Options.JumpPowerToggle.Value then
                humanoid.JumpPower = Options.JumpPowerSlider.Value
            else
                humanoid.JumpPower = 50
            end
        end
    end
end)

SliderJumpPower:OnChanged(function(value)
    if Options.JumpPowerToggle.Value then
        local player = game.Players.LocalPlayer
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.JumpPower = value
            end
        end
    end
end)

-- Visual Tab
local FullbrightToggle = Tabs.Visual:AddToggle("Fullbright", {
    Title = "Fullbright",
    Default = false
})

local originalAmbient, originalBrightness

FullbrightToggle:OnChanged(function()
    local Lighting = game:GetService("Lighting")
    if Options.Fullbright.Value then
        originalAmbient = Lighting.Ambient
        originalBrightness = Lighting.Brightness
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
    else
        if originalAmbient then
            Lighting.Ambient = originalAmbient
            Lighting.Brightness = originalBrightness
        end
    end
end)

-- Settings Tab
local AntiAFKToggle = Tabs.Settings:AddToggle("AntiAFK", {
    Title = "Anti AFK",
    Default = true
})

local antiAFKConnection

AntiAFKToggle:OnChanged(function()
    local player = game.Players.LocalPlayer
    local VirtualUser = game:GetService("VirtualUser")
    if Options.AntiAFK.Value then
        antiAFKConnection = player.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    else
        if antiAFKConnection then
            antiAFKConnection:Disconnect()
        end
    end
end)

Options.AntiAFK:SetValue(true)

-- SaveManager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("WKHub")
SaveManager:SetFolder("WKHub/Universal")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
Fluent:Notify({
    Title = "Universal Hub Loaded",
    Content = "Basic features for any game!",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()
]]

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

local function cacheBuster(url)
    return url .. (url:find("?") and "&" or "?") .. "t=" .. os.time()
end

local function fetchGamesFromGitHub()
    -- Hardcoded from local games.json - no network needed
    local gamesTable = {
        [14963184269] = { name = "Mount Sumbing", script = "sumbing.lua" },
        [12399530955] = { name = "Mount Taber", script = "taber.lua" },
        [1232242940] = { name = "Mount Atin", script = "atin.lua" },
        [914906594] = { name = "Mount Mono", script = "mono.lua" },
        [126509999114328] = { name = "99 Nights in the Forest", script = "forest.lua" },
        [93978595733734] = { name = "Violence District", script = "vd.lua" }
    }
    return true, gamesTable
end

local function loadScript(scriptName, gameName)
    notify("WKHub", "Loading " .. gameName .. "...", 3)
    
    -- Try local file first
    local success, result = pcall(function()
        local fileContent = readfile(scriptName)
        return loadstring(fileContent)()
    end)
    
    if not success then
        warn("Local load failed for " .. scriptName .. ": " .. tostring(result))
        -- Fallback to GitHub if local fails (optional, comment out if no GitHub)
        -- local url = BASE_URL .. scriptName
        -- local httpSuccess, httpResult = pcall(function()
        --     return game:HttpGet(cacheBuster(url), true)
        -- end)
        -- if httpSuccess then
        --     return pcall(loadstring, httpResult)
        -- end
        return false, "Local file not found: " .. scriptName .. ". Ensure script is in executor directory."
    end
    
    return success, result
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
local GAMES = fetchGamesFromGitHub()  -- Returns true, table
print("✅ Loaded games from local data")

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
        notify("WKHub Error", "Failed to load script: " .. tostring(err), 8)
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

-- Also update the fallback auto-detect to load universal if no match
if scriptFile then
    -- existing load
else
    -- load universal instead
    -- similar pcall loadstring(UNIVERSAL_SCRIPT)()
    local universalSuccess, universalErr = pcall(function()
        loadstring(UNIVERSAL_SCRIPT)()
    end)
    
    if universalSuccess then
        print("Universal Hub loaded!")
        notify("WKHub", "Universal Hub loaded with basic features!", 5)
        
        -- Add dock for universal
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
        warn("Universal load failed:", universalErr)
        notify("WKHub Error", "Failed to load Universal Hub: " .. tostring(universalErr), 8)
    end
end

-- Cleanup Anti-AFK on script end (optional, but keeps it simple)
if antiAFKConn then
    antiAFKConn:Disconnect()
end
