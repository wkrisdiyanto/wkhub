-- ============================================
-- WKHUB - CROCS QUEST (COMPKILLER UI)
-- Auto Kill Enemies with Modern UI
-- ============================================

print("WKHub - Crocs Quest Loading...")

-- Load Compkiller Library
local Compkiller = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/CompKiller/refs/heads/main/src/source.luau"))()

-- Create Notification
local Notifier = Compkiller.newNotify()

-- Create Config Manager
local ConfigManager = Compkiller:ConfigManager({
    Directory = "WKHub_Crocs",
    Config = "CrocsConfig"
})

-- Loading UI
Compkiller:Loader("rbxassetid://120245531583106", 2.5).yield()

-- Creating Window
local Window = Compkiller.new({
    Name = "WKHUB",
    Keybind = "LeftAlt",
    Logo = "rbxassetid://120245531583106",
    Scale = Compkiller.Scale.Window,
    TextSize = 15,
})

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- Detect Mobile
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

-- Notification
Notifier.new({
    Title = "WKHub - Crocs Quest",
    Content = isMobile and "Mobile UI Loaded! 📱" or "Desktop UI Loaded! 🖥️",
    Duration = 5,
    Icon = "rbxassetid://120245531583106"
})

-- Watermark
local Watermark = Window:Watermark()

Watermark:AddText({
    Icon = "user",
    Text = "Exodiuszord",
})

Watermark:AddText({
    Icon = "clock",
    Text = Compkiller:GetDate(),
})

local Time = Watermark:AddText({
    Icon = "timer",
    Text = "TIME",
})

task.spawn(function()
    while true do task.wait()
        Time:SetText(Compkiller:GetTimeNow())
    end
end)

-- Variables
local autoKillRunning = false
local killDelay = 0.2
local loopDelay = 1.0
local antiAFKConnection

-- Creating Tab Category
Window:DrawCategory({
    Name = "Main Features"
})

-- Combat Tab
local CombatTab = Window:DrawTab({
    Name = "Combat",
    Icon = "sword",
    Type = "Double",
    EnableScrolling = true
})

-- Combat Section
local CombatSection = CombatTab:DrawSection({
    Name = "Auto Kill System",
    Position = 'left'
})

CombatSection:AddParagraph({
    Title = "Auto Kill Enemies",
    Content = "Automatically kills all enemies in Level_Croctober zone.\nIncludes nested detection and auto-retry system.\nCheck console (F9) for detailed logs."
})

local AutoKillToggle = CombatSection:AddToggle({
    Name = "Auto Kill Enemies",
    Flag = "Auto_Kill_Crocs",
    Default = false,
    Callback = function(Value)
        autoKillRunning = Value
        
        Notifier.new({
            Title = "Auto Kill",
            Content = Value and "Auto Kill Started 💀" or "Auto Kill Stopped",
            Duration = 3,
            Icon = "rbxassetid://120245531583106"
        })
        
        if Value then
            task.spawn(function()
                print("🔄 Memulai Auto Kill Aura...")
                
                local function killAllEnemies()
                    if not autoKillRunning then return 0 end
                    
                    local killCount = 0
                    local errorCount = 0
                    local skippedEnemies = {}
                    
                    local remote = ReplicatedStorage:FindFirstChild("ScarableEnemyHandler_EnemyKilledServerFunc")
                    
                    if not remote then
                        warn("❌ Remote tidak ditemukan! Retry...")
                        return 0
                    end
                    
                    local success, enemiesFolder = pcall(function()
                        return workspace:WaitForChild("World", 5)
                            :WaitForChild("Zones", 5)
                            :WaitForChild("Level_Croctober", 5)
                            :WaitForChild("Enemies", 5)
                    end)
                    
                    if not success or not enemiesFolder then
                        warn("❌ Enemies folder tidak ditemukan! Retry...")
                        return 0
                    end
                    
                    -- Scan GetDescendants untuk enemies yang nested
                    local allEnemies = {}
                    for _, obj in pairs(enemiesFolder:GetDescendants()) do
                        if obj:IsA("Model") and obj.Parent and obj:FindFirstChild("Humanoid") then
                            table.insert(allEnemies, obj)
                        end
                    end
                    
                    -- Tambahkan juga direct children
                    for _, obj in pairs(enemiesFolder:GetChildren()) do
                        if obj:IsA("Model") and obj.Parent then
                            local alreadyAdded = false
                            for _, existing in pairs(allEnemies) do
                                if existing == obj then
                                    alreadyAdded = true
                                    break
                                end
                            end
                            if not alreadyAdded then
                                table.insert(allEnemies, obj)
                            end
                        end
                    end
                    
                    print("🎯 Ditemukan " .. #allEnemies .. " enemies (including nested)")
                    
                    -- Kill pass pertama
                    for i, enemy in pairs(allEnemies) do
                        if not autoKillRunning then break end
                        
                        if enemy and enemy.Parent then
                            local success, err = pcall(function()
                                remote:InvokeServer(enemy)
                            end)
                            
                            if success then
                                killCount = killCount + 1
                                print("💀 Dibunuh:", enemy.Name, "(" .. killCount .. "/" .. #allEnemies .. ")")
                            else
                                errorCount = errorCount + 1
                                table.insert(skippedEnemies, enemy)
                                if errorCount <= 3 then
                                    warn("⚠️ Gagal membunuh:", enemy.Name, "-", tostring(err))
                                end
                            end
                            
                            task.wait(killDelay)
                        end
                    end
                    
                    -- Retry untuk enemies yang gagal
                    if #skippedEnemies > 0 and autoKillRunning then
                        print("🔄 Retry " .. #skippedEnemies .. " enemies yang gagal...")
                        task.wait(0.5)
                        
                        for _, enemy in pairs(skippedEnemies) do
                            if not autoKillRunning then break end
                            
                            if enemy and enemy.Parent then
                                local success = pcall(function()
                                    remote:InvokeServer(enemy)
                                end)
                                
                                if success then
                                    killCount = killCount + 1
                                    print("💀 Retry berhasil:", enemy.Name)
                                end
                                
                                task.wait(killDelay)
                            end
                        end
                    end
                    
                    if errorCount > 3 then
                        print("⚠️ Total " .. errorCount .. " errors dalam wave ini")
                    end
                    
                    return killCount
                end
                
                print("✅ Auto Kill Aura aktif!")
                local totalKills = 0
                local loopCount = 0
                
                while autoKillRunning do
                    loopCount = loopCount + 1
                    print("\n🔄 Wave #" .. loopCount .. " dimulai...")
                    
                    local success, result = pcall(function()
                        return killAllEnemies()
                    end)
                    
                    if success then
                        local kills = result or 0
                        totalKills = totalKills + kills
                        
                        if kills > 0 then
                            print("🔥 Wave #" .. loopCount .. " selesai! Kills: " .. kills .. " | Total: " .. totalKills)
                        else
                            print("⏸️ Tidak ada enemy di wave ini")
                        end
                    else
                        warn("❌ Error di wave #" .. loopCount .. ":", tostring(result))
                        print("🔄 Melanjutkan ke wave berikutnya...")
                    end
                    
                    if autoKillRunning then
                        task.wait(loopDelay)
                    end
                end
                
                print("⛔ Auto Kill dihentikan. Total kills: " .. totalKills)
            end)
        end
    end
})

CombatSection:AddSlider({
    Name = "Kill Delay",
    Min = 0.1,
    Max = 2,
    Default = 0.2,
    Round = 1,
    Flag = "Kill_Delay_Crocs",
    Callback = function(Value)
        killDelay = Value
        print("Kill Delay set to:", Value)
    end
})

CombatSection:AddSlider({
    Name = "Loop Delay",
    Min = 0.5,
    Max = 5,
    Default = 1.0,
    Round = 1,
    Flag = "Loop_Delay_Crocs",
    Callback = function(Value)
        loopDelay = Value
        print("Loop Delay set to:", Value)
    end
})

-- Info Section
local InfoSection = CombatTab:DrawSection({
    Name = "Information",
    Position = 'right'
})

InfoSection:AddParagraph({
    Title = "How It Works",
    Content = "• Kills all enemies in Level_Croctober\n• Deep scan with nested detection\n• Auto-retry failed kills\n• Continuous wave system"
})

InfoSection:AddParagraph({
    Title = "Settings Explained",
    Content = "Kill Delay: Time between each enemy kill\nLoop Delay: Time between wave cycles\n\nLower values = faster but more detectable"
})

InfoSection:AddParagraph({
    Title = "Script Info",
    Content = "Version: 1.3 (" .. (isMobile and "Mobile" or "Desktop") .. ")\nCreated by: Exodiuszord\nUI: Compkiller"
})

-- Misc Tab
local MiscTab = Window:DrawTab({
    Name = "Misc",
    Icon = "package",
    Type = "Single"
})

local MiscSection = MiscTab:DrawSection({
    Name = "Anti AFK System",
    Position = 'left'
})

MiscSection:AddParagraph({
    Title = "Anti AFK",
    Content = "Prevents you from getting kicked due to inactivity.\nEnabled by default when script loads."
})

MiscSection:AddToggle({
    Name = "Anti AFK",
    Flag = "Anti_AFK_Crocs",
    Default = true,
    Callback = function(Value)
        if Value then
            if antiAFKConnection then antiAFKConnection:Disconnect() end
            local VirtualUser = game:GetService("VirtualUser")
            antiAFKConnection = Players.LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
            print("✅ Anti AFK aktif")
        else
            if antiAFKConnection then
                antiAFKConnection:Disconnect()
                antiAFKConnection = nil
            end
            print("❌ Anti AFK nonaktif")
        end
    end
})

-- Settings Category
Window:DrawCategory({
    Name = "Settings"
})

-- Config Tab
local ConfigUI = Window:DrawConfig({
    Name = "Config",
    Icon = "folder",
    Config = ConfigManager
})

ConfigUI:Init()

-- Auto-enable Anti AFK on load
task.spawn(function()
    task.wait(0.5)
    local VirtualUser = game:GetService("VirtualUser")
    antiAFKConnection = Players.LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
    print("✅ Anti AFK enabled by default")
end)

print("✅ WKHub - Crocs Quest loaded successfully!")
