local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "WKHub - Mount Mono",
    SubTitle = "By Exodiuszord",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

Fluent:Notify({
    Title = "Notification",
    Content = "Mono module loaded!",
    Duration = 5
})

-- Mount Mono Section
local MonoSection = Tabs.Main:AddSection("Mount Mono")

local ToggleMonoAuto = Tabs.Main:AddToggle("AutoSummitMono", {
    Title = "Auto Summit", 
    Default = false
})

local monoRunning = false

ToggleMonoAuto:OnChanged(function()
    monoRunning = Options.AutoSummitMono.Value
    
    if monoRunning then
        Fluent:Notify({
            Title = "Mount Mono",
            Content = "Auto Summit Started",
            Duration = 3
        })
        
        task.spawn(function()
            local player = game.Players.LocalPlayer
            
            local targetCFrame = CFrame.new(49.215, 1138.000, -184.147)
            local walkDistance = 15
            local delayAfterRespawn = 5
            
            local function walkTo(humanoid, position)
                humanoid:MoveTo(position)
                humanoid.MoveToFinished:Wait()
            end
            
            local function teleportAndWalk()
                if not monoRunning then return false end
                
                local character = player.Character
                if not character then
                    player.CharacterAdded:Wait()
                    character = player.Character
                end
                
                local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 10)
                local humanoid = character:WaitForChild("Humanoid", 10)
                
                if not humanoidRootPart or not humanoid then
                    warn("Gagal menemukan HumanoidRootPart atau Humanoid!")
                    return false
                end
                
                humanoidRootPart.CFrame = targetCFrame
                print("✓ Teleport ke koordinat:", targetCFrame.Position)
                task.wait(0.5)
                
                if not monoRunning then return false end
                
                local forwardPosition = (targetCFrame * CFrame.new(0, 0, -walkDistance)).Position
                print("→ Berjalan menjauh...")
                walkTo(humanoid, forwardPosition)
                task.wait(0.5)
                
                if not monoRunning then return false end
                
                print("← Kembali ke posisi awal...")
                walkTo(humanoid, targetCFrame.Position)
                task.wait(0.5)
                
                if not monoRunning then return false end
                
                print("☠ Respawn karakter...")
                character:BreakJoints()
                
                return true
            end
            
            print("🔄 Mount Mono Script dimulai - Loop aktif!")
            local loopCount = 0
            
            while monoRunning do
                loopCount = loopCount + 1
                print("\n========== LOOP #" .. loopCount .. " ==========")
                
                local success = teleportAndWalk()
                
                if success and monoRunning then
                    print("⏳ Menunggu respawn...")
                    player.CharacterAdded:Wait()
                    task.wait(delayAfterRespawn)
                else
                    if monoRunning then
                        warn("Loop gagal, mencoba lagi...")
                        task.wait(2)
                    end
                end
            end
            
            print("✅ Mount Mono Script dihentikan!")
        end)
    else
        Fluent:Notify({
            Title = "Mount Mono",
            Content = "Auto Summit Stopped",
            Duration = 3
        })
    end
end)

-- Addons: SaveManager & InterfaceManager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("WKHub")
SaveManager:SetFolder("WKHub/MountMono")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "WKHub",
    Content = "Mount Mono module loaded.",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()


