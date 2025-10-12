local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- ============================================
-- GAME DETECTION
-- ============================================
-- Place ID untuk 99 Nights in the Forest
-- Menggunakan string untuk handle angka besar
local NIGHTS_FOREST_ID = "79546208627805"
local currentPlaceId = tostring(game.PlaceId)

print("Current Place ID:", currentPlaceId)
print("Expected Place ID:", NIGHTS_FOREST_ID)

-- Skip detection untuk testing (comment line ini jika mau strict detection)
-- if currentPlaceId ~= NIGHTS_FOREST_ID then
--     game:GetService("StarterGui"):SetCore("SendNotification", {
--         Title = "Wrong Game!";
--         Text = "This script is for 99 Nights in the Forest only!\nPlace ID: " .. currentPlaceId;
--         Duration = 8;
--     })
--     return
-- end

-- ============================================
-- CREATE WINDOW
-- ============================================
local Window = Fluent:CreateWindow({
    Title = "WKHub - 99 Nights in the Forest",
    SubTitle = "By Exodiuszord",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 480),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Combat = Window:AddTab({ Title = "Combat", Icon = "sword" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "map-pin" }),
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "box" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

Fluent:Notify({
    Title = "99 Nights Forest Hub",
    Content = "Script loaded successfully!",
    Duration = 5
})

-- ============================================
-- MAIN TAB - SURVIVAL FEATURES
-- ============================================

-- Auto Collect Section
local CollectSection = Tabs.Main:AddSection("Auto Collect")

local autoCollectRunning = false
local collectRadius = 50

local ToggleAutoCollect = Tabs.Main:AddToggle("AutoCollect", {
    Title = "Auto Collect Items",
    Description = "Automatically collect nearby items",
    Default = false
})

local SliderCollectRadius = Tabs.Main:AddSlider("CollectRadius", {
    Title = "Collection Radius",
    Description = "How far to collect items (studs)",
    Default = 50,
    Min = 10,
    Max = 200,
    Rounding = 1,
})

SliderCollectRadius:OnChanged(function(Value)
    collectRadius = Value
end)

ToggleAutoCollect:OnChanged(function()
    autoCollectRunning = Options.AutoCollect.Value
    
    if autoCollectRunning then
        Fluent:Notify({
            Title = "Auto Collect",
            Content = "Started collecting items",
            Duration = 3
        })
        
        task.spawn(function()
            local player = game.Players.LocalPlayer
            
            while autoCollectRunning do
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    
                    -- Scan workspace untuk items
                    for _, item in pairs(workspace:GetDescendants()) do
                        if not autoCollectRunning then break end
                        
                        pcall(function()
                            -- Cek apakah ini item yang bisa diambil
                            if item:IsA("BasePart") and item:FindFirstChild("ClickDetector") then
                                local distance = (item.Position - hrp.Position).Magnitude
                                
                                if distance <= collectRadius then
                                    -- Trigger click detector
                                    fireclickdetector(item.ClickDetector)
                                end
                            end
                        end)
                    end
                end
                
                task.wait(0.5)
            end
        end)
    else
        Fluent:Notify({
            Title = "Auto Collect",
            Content = "Stopped collecting",
            Duration = 3
        })
    end
end)

-- Campfire Section
local CampfireSection = Tabs.Main:AddSection("Campfire Management")

Tabs.Main:AddButton({
    Title = "Teleport to Campfire",
    Description = "Instantly teleport to the campfire",
    Callback = function()
        local player = game.Players.LocalPlayer
        local char = player.Character
        
        if char and char:FindFirstChild("HumanoidRootPart") then
            -- Cari campfire di workspace
            local campfire = workspace:FindFirstChild("Campfire") or workspace:FindFirstChild("Fire")
            
            if campfire then
                char.HumanoidRootPart.CFrame = campfire.CFrame + Vector3.new(0, 5, 0)
                Fluent:Notify({
                    Title = "Teleport",
                    Content = "Teleported to campfire!",
                    Duration = 3
                })
            else
                Fluent:Notify({
                    Title = "Error",
                    Content = "Campfire not found!",
                    Duration = 3
                })
            end
        end
    end
})

local ToggleAutofeedFire = Tabs.Main:AddToggle("AutoFeedFire", {
    Title = "Auto Feed Campfire",
    Description = "Automatically add wood to campfire",
    Default = false
})

local autoFeedRunning = false

ToggleAutofeedFire:OnChanged(function()
    autoFeedRunning = Options.AutoFeedFire.Value
    
    if autoFeedRunning then
        Fluent:Notify({
            Title = "Auto Feed",
            Content = "Auto feeding campfire enabled",
            Duration = 3
        })
        
        task.spawn(function()
            while autoFeedRunning do
                -- Logic untuk auto feed campfire
                -- Ini tergantung mekanisme game, biasanya via ProximityPrompt atau ClickDetector
                local campfire = workspace:FindFirstChild("Campfire")
                
                if campfire then
                    for _, obj in pairs(campfire:GetDescendants()) do
                        if obj:IsA("ProximityPrompt") then
                            pcall(function()
                                fireproximityprompt(obj)
                            end)
                        elseif obj:IsA("ClickDetector") then
                            pcall(function()
                                fireclickdetector(obj)
                            end)
                        end
                    end
                end
                
                task.wait(5)
            end
        end)
    else
        Fluent:Notify({
            Title = "Auto Feed",
            Content = "Auto feeding disabled",
            Duration = 3
        })
    end
end)

-- Resource Farming
local FarmSection = Tabs.Main:AddSection("Resource Farming")

local ToggleAutoChop = Tabs.Main:AddToggle("AutoChop", {
    Title = "Auto Chop Trees",
    Description = "Automatically chop nearby trees",
    Default = false
})

local autoChopRunning = false

ToggleAutoChop:OnChanged(function()
    autoChopRunning = Options.AutoChop.Value
    
    if autoChopRunning then
        Fluent:Notify({
            Title = "Auto Chop",
            Content = "Started chopping trees",
            Duration = 3
        })
        
        task.spawn(function()
            local player = game.Players.LocalPlayer
            
            while autoChopRunning do
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    
                    -- Cari trees di workspace
                    for _, tree in pairs(workspace:GetDescendants()) do
                        if not autoChopRunning then break end
                        
                        pcall(function()
                            if tree.Name == "Tree" or tree.Name == "TreeTrunk" or tree.Parent.Name == "Trees" then
                                local distance = (tree.Position - hrp.Position).Magnitude
                                
                                if distance <= 30 then
                                    -- Trigger tree chopping
                                    if tree:FindFirstChild("ClickDetector") then
                                        fireclickdetector(tree.ClickDetector)
                                    elseif tree:FindFirstChild("ProximityPrompt") then
                                        fireproximityprompt(tree.ProximityPrompt)
                                    end
                                end
                            end
                        end)
                    end
                end
                
                task.wait(1)
            end
        end)
    else
        Fluent:Notify({
            Title = "Auto Chop",
            Content = "Stopped chopping",
            Duration = 3
        })
    end
end)

-- ============================================
-- COMBAT TAB - DEER & ENEMY FEATURES
-- ============================================

-- Deer ESP Section
local DeerESPSection = Tabs.Combat:AddSection("Deer ESP")

local deerESPEnabled = false
local deerHighlights = {}

local ToggleDeerESP = Tabs.Combat:AddToggle("DeerESP", {
    Title = "Deer ESP",
    Description = "Highlight The Deer creature",
    Default = false
})

ToggleDeerESP:OnChanged(function()
    deerESPEnabled = Options.DeerESP.Value
    
    if deerESPEnabled then
        task.spawn(function()
            while deerESPEnabled do
                -- Cari The Deer di workspace
                for _, mob in pairs(workspace:GetDescendants()) do
                    pcall(function()
                        if mob.Name == "Deer" or mob.Name == "TheDeer" or mob.Parent.Name == "Deer" then
                            if not deerHighlights[mob] then
                                local highlight = Instance.new("Highlight")
                                highlight.Name = "DeerESP"
                                highlight.Adornee = mob
                                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                                highlight.FillTransparency = 0.5
                                highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                                highlight.OutlineTransparency = 0
                                highlight.Parent = mob
                                
                                deerHighlights[mob] = highlight
                            end
                        end
                    end)
                end
                
                task.wait(1)
            end
        end)
        
        Fluent:Notify({
            Title = "Deer ESP",
            Content = "Deer ESP enabled!",
            Duration = 3
        })
    else
        -- Remove all highlights
        for _, highlight in pairs(deerHighlights) do
            if highlight then
                highlight:Destroy()
            end
        end
        deerHighlights = {}
        
        Fluent:Notify({
            Title = "Deer ESP",
            Content = "Deer ESP disabled",
            Duration = 3
        })
    end
end)

-- Deer Notifications
local ToggleDeerNotif = Tabs.Combat:AddToggle("DeerNotifications", {
    Title = "Deer Spawn Notification",
    Description = "Get notified when The Deer spawns",
    Default = true
})

local deerNotifRunning = false

ToggleDeerNotif:OnChanged(function()
    deerNotifRunning = Options.DeerNotifications.Value
    
    if deerNotifRunning then
        task.spawn(function()
            local lastNotif = 0
            
            while deerNotifRunning do
                for _, mob in pairs(workspace:GetDescendants()) do
                    pcall(function()
                        if (mob.Name == "Deer" or mob.Name == "TheDeer") and os.clock() - lastNotif > 30 then
                            Fluent:Notify({
                                Title = "⚠️ DANGER!",
                                Content = "The Deer has spawned nearby!",
                                Duration = 5
                            })
                            lastNotif = os.clock()
                        end
                    end)
                end
                
                task.wait(5)
            end
        end)
    end
end)

-- Auto Stun Deer
local ToggleAutoStun = Tabs.Combat:AddToggle("AutoStunDeer", {
    Title = "Auto Stun Deer",
    Description = "Automatically stun The Deer when close",
    Default = false
})

local autoStunRunning = false

ToggleAutoStun:OnChanged(function()
    autoStunRunning = Options.AutoStunDeer.Value
    
    if autoStunRunning then
        Fluent:Notify({
            Title = "Auto Stun",
            Content = "Auto stun enabled",
            Duration = 3
        })
        
        task.spawn(function()
            local player = game.Players.LocalPlayer
            
            while autoStunRunning do
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    
                    -- Cari The Deer
                    for _, mob in pairs(workspace:GetDescendants()) do
                        if not autoStunRunning then break end
                        
                        pcall(function()
                            if mob.Name == "Deer" or mob.Name == "TheDeer" then
                                local distance = (mob.Position - hrp.Position).Magnitude
                                
                                if distance <= 50 then
                                    -- Logic untuk stun (tergantung item/weapon di game)
                                    -- Biasanya perlu trigger weapon/flashlight
                                    print("Deer detected at distance:", distance)
                                end
                            end
                        end)
                    end
                end
                
                task.wait(0.5)
            end
        end)
    else
        Fluent:Notify({
            Title = "Auto Stun",
            Content = "Auto stun disabled",
            Duration = 3
        })
    end
end)

-- Enemy ESP
local EnemySection = Tabs.Combat:AddSection("Enemy ESP")

local ToggleEnemyESP = Tabs.Combat:AddToggle("EnemyESP", {
    Title = "Cultist/Enemy ESP",
    Description = "Highlight hostile enemies",
    Default = false
})

local enemyESPEnabled = false
local enemyHighlights = {}

ToggleEnemyESP:OnChanged(function()
    enemyESPEnabled = Options.EnemyESP.Value
    
    if enemyESPEnabled then
        task.spawn(function()
            while enemyESPEnabled do
                for _, enemy in pairs(workspace:GetDescendants()) do
                    pcall(function()
                        if enemy.Name == "Cultist" or enemy.Name == "Ram" or enemy.Name == "Owl" then
                            if not enemyHighlights[enemy] then
                                local highlight = Instance.new("Highlight")
                                highlight.Name = "EnemyESP"
                                highlight.Adornee = enemy
                                highlight.FillColor = Color3.fromRGB(255, 100, 0)
                                highlight.FillTransparency = 0.5
                                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                                highlight.OutlineTransparency = 0
                                highlight.Parent = enemy
                                
                                enemyHighlights[enemy] = highlight
                            end
                        end
                    end)
                end
                
                task.wait(1)
            end
        end)
        
        Fluent:Notify({
            Title = "Enemy ESP",
            Content = "Enemy ESP enabled!",
            Duration = 3
        })
    else
        for _, highlight in pairs(enemyHighlights) do
            if highlight then highlight:Destroy() end
        end
        enemyHighlights = {}
        
        Fluent:Notify({
            Title = "Enemy ESP",
            Content = "Enemy ESP disabled",
            Duration = 3
        })
    end
end)

-- ============================================
-- TELEPORT TAB
-- ============================================

local TPSection = Tabs.Teleport:AddSection("Quick Teleports")

-- Teleport locations (sesuaikan dengan map game)
local teleportLocations = {
    ["Campfire"] = CFrame.new(0, 5, 0), -- Placeholder, sesuaikan dengan posisi sebenarnya
    ["Taming Tent"] = CFrame.new(50, 5, 50),
    ["Supply Drop"] = CFrame.new(-100, 5, 100),
    ["Cave Entrance"] = CFrame.new(200, 5, -200),
}

for name, cframe in pairs(teleportLocations) do
    Tabs.Teleport:AddButton({
        Title = "TP to " .. name,
        Description = "Teleport to " .. name,
        Callback = function()
            local player = game.Players.LocalPlayer
            local char = player.Character
            
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = cframe
                
                Fluent:Notify({
                    Title = "Teleported",
                    Content = "Teleported to " .. name,
                    Duration = 3
                })
            end
        end
    })
end

-- Waypoint System
local WaypointSection = Tabs.Teleport:AddSection("Waypoint System")

local savedWaypoint = nil

Tabs.Teleport:AddButton({
    Title = "Save Current Position",
    Description = "Save your current position as waypoint",
    Callback = function()
        local player = game.Players.LocalPlayer
        local char = player.Character
        
        if char and char:FindFirstChild("HumanoidRootPart") then
            savedWaypoint = char.HumanoidRootPart.CFrame
            
            Fluent:Notify({
                Title = "Waypoint",
                Content = "Position saved!",
                Duration = 3
            })
        end
    end
})

Tabs.Teleport:AddButton({
    Title = "Teleport to Waypoint",
    Description = "Teleport to saved waypoint",
    Callback = function()
        if savedWaypoint then
            local player = game.Players.LocalPlayer
            local char = player.Character
            
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = savedWaypoint
                
                Fluent:Notify({
                    Title = "Waypoint",
                    Content = "Teleported to waypoint!",
                    Duration = 3
                })
            end
        else
            Fluent:Notify({
                Title = "Error",
                Content = "No waypoint saved!",
                Duration = 3
            })
        end
    end
})

-- ============================================
-- PLAYER TAB - UNIVERSAL FEATURES
-- ============================================

-- WalkSpeed
local ToggleWalkSpeed = Tabs.Player:AddToggle("WalkSpeedToggle", {
    Title = "WalkSpeed", 
    Default = false
})

ToggleWalkSpeed:OnChanged(function()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if Options.WalkSpeedToggle.Value then
        if humanoid then
            humanoid.WalkSpeed = Options.WalkSpeedSlider.Value
        end
    else
        if humanoid then
            humanoid.WalkSpeed = 16
        end
    end
end)

local SliderWalkSpeed = Tabs.Player:AddSlider("WalkSpeedSlider", {
    Title = "WalkSpeed Amount",
    Default = 16,
    Min = 16,
    Max = 150,
    Rounding = 1,
})

SliderWalkSpeed:OnChanged(function(Value)
    if Options.WalkSpeedToggle.Value then
        local player = game.Players.LocalPlayer
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = Value
            end
        end
    end
end)

-- NoClip
local noclipping = false
local noclipConnection

local ToggleNoClip = Tabs.Player:AddToggle("NoClip", {
    Title = "NoClip", 
    Default = false
})

ToggleNoClip:OnChanged(function()
    noclipping = Options.NoClip.Value
    
    if noclipping then
        if noclipConnection then noclipConnection:Disconnect() end
        noclipConnection = game:GetService("RunService").Stepped:Connect(function()
            if noclipping then
                local player = game.Players.LocalPlayer
                local character = player.Character
                
                if character then
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end)
        
        Fluent:Notify({
            Title = "NoClip",
            Content = "NoClip Enabled",
            Duration = 3
        })
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        
        Fluent:Notify({
            Title = "NoClip",
            Content = "NoClip Disabled",
            Duration = 3
        })
    end
end)

-- Infinite Stamina
local ToggleInfStamina = Tabs.Player:AddToggle("InfStamina", {
    Title = "Infinite Stamina",
    Description = "Never run out of stamina",
    Default = false
})

ToggleInfStamina:OnChanged(function()
    -- Logic tergantung sistem stamina di game
    if Options.InfStamina.Value then
        Fluent:Notify({
            Title = "Infinite Stamina",
            Content = "Enabled (if supported)",
            Duration = 3
        })
    else
        Fluent:Notify({
            Title = "Infinite Stamina",
            Content = "Disabled",
            Duration = 3
        })
    end
end)

-- ============================================
-- MISC TAB
-- ============================================

-- Fullbright
local originalAmbient
local originalBrightness

local ToggleFullbright = Tabs.Misc:AddToggle("Fullbright", {
    Title = "Fullbright", 
    Default = false
})

ToggleFullbright:OnChanged(function()
    local Lighting = game:GetService("Lighting")
    
    if Options.Fullbright.Value then
        originalAmbient = Lighting.Ambient
        originalBrightness = Lighting.Brightness
        
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        
        Fluent:Notify({
            Title = "Fullbright",
            Content = "Fullbright Enabled",
            Duration = 3
        })
    else
        if originalAmbient then
            Lighting.Ambient = originalAmbient
            Lighting.Brightness = originalBrightness
        end
        
        Fluent:Notify({
            Title = "Fullbright",
            Content = "Fullbright Disabled",
            Duration = 3
        })
    end
end)

-- Remove Fog
local ToggleRemoveFog = Tabs.Misc:AddToggle("RemoveFog", {
    Title = "Remove Fog", 
    Default = false
})

ToggleRemoveFog:OnChanged(function()
    local Lighting = game:GetService("Lighting")
    
    if Options.RemoveFog.Value then
        Lighting.FogEnd = 100000
        
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("Atmosphere") then
                effect.Density = 0
            end
        end
        
        Fluent:Notify({
            Title = "Remove Fog",
            Content = "Fog Removed",
            Duration = 3
        })
    else
        Lighting.FogEnd = 500
        
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("Atmosphere") then
                effect.Density = 0.3
            end
        end
        
        Fluent:Notify({
            Title = "Remove Fog",
            Content = "Fog Restored",
            Duration = 3
        })
    end
end)

-- FPS Counter
local fpsLabel
local fpsConnection

local ToggleFPSCounter = Tabs.Misc:AddToggle("FPSCounter", {
    Title = "FPS Counter", 
    Default = false
})

ToggleFPSCounter:OnChanged(function()
    if Options.FPSCounter.Value then
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "FPSCounter"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
        
        fpsLabel = Instance.new("TextLabel")
        fpsLabel.Size = UDim2.new(0, 100, 0, 50)
        fpsLabel.Position = UDim2.new(1, -110, 0, 10)
        fpsLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        fpsLabel.BackgroundTransparency = 0.5
        fpsLabel.BorderSizePixel = 0
        fpsLabel.Text = "FPS: 0"
        fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        fpsLabel.TextScaled = true
        fpsLabel.Font = Enum.Font.GothamBold
        fpsLabel.Parent = screenGui
        
        local lastUpdate = os.clock()
        local frames = 0
        
        fpsConnection = game:GetService("RunService").RenderStepped:Connect(function()
            frames = frames + 1
            
            if os.clock() - lastUpdate >= 1 then
                local fps = frames
                fpsLabel.Text = "FPS: " .. fps
                
                if fps >= 60 then
                    fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                elseif fps >= 30 then
                    fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                else
                    fpsLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                end
                
                frames = 0
                lastUpdate = os.clock()
            end
        end)
    else
        if fpsConnection then
            fpsConnection:Disconnect()
            fpsConnection = nil
        end
        
        local gui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("FPSCounter")
        if gui then gui:Destroy() end
    end
end)

-- ============================================
-- SETTINGS TAB
-- ============================================

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("WKHub")
SaveManager:SetFolder("WKHub/99NightsForest")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- Anti AFK
local antiAFKConnection = nil

local ToggleAntiAFK = Tabs.Settings:AddToggle("AntiAFK", {
    Title = "Anti AFK", 
    Description = "Prevents being kicked for inactivity",
    Default = true
})

ToggleAntiAFK:OnChanged(function()
    if Options.AntiAFK.Value then
        if antiAFKConnection then antiAFKConnection:Disconnect() end
        
        local VirtualUser = game:GetService("VirtualUser")
        antiAFKConnection = game:GetService("Players").LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
        
        Fluent:Notify({
            Title = "Anti AFK",
            Content = "Anti AFK Enabled",
            Duration = 3
        })
    else
        if antiAFKConnection then
            antiAFKConnection:Disconnect()
            antiAFKConnection = nil
        end
        
        Fluent:Notify({
            Title = "Anti AFK",
            Content = "Anti AFK Disabled",
            Duration = 3
        })
    end
end)

Options.AntiAFK:SetValue(true)

-- Game Info
local GameInfoSection = Tabs.Settings:AddSection("Game Information")

Tabs.Settings:AddButton({
    Title = "Copy Place ID",
    Description = "Copy game Place ID to clipboard",
    Callback = function()
        local placeId = tostring(game.PlaceId)
        
        if setclipboard then
            setclipboard(placeId)
            Fluent:Notify({
                Title = "Copied",
                Content = "Place ID: " .. placeId,
                Duration = 3
            })
        else
            print("Place ID:", placeId)
        end
    end
})

-- ============================================
-- FINALIZE
-- ============================================
Window:SelectTab(1)

Fluent:Notify({
    Title = "WKHub Loaded",
    Content = "99 Nights in the Forest features loaded!",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()
