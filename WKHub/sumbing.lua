local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "WKHub - Mount Sumbing",
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
    Content = "Sumbing module loaded!",
    Duration = 5
})

-- Mount Sumbing Section
local SumbingSection = Tabs.Main:AddSection("Mount Sumbing")

local ToggleSumbingAuto = Tabs.Main:AddToggle("AutoSummitSumbing", {
    Title = "Auto Summit", 
    Default = false
})

local sumbingRunning = false

ToggleSumbingAuto:OnChanged(function()
    sumbingRunning = Options.AutoSummitSumbing.Value
    
    if sumbingRunning then
        Fluent:Notify({
            Title = "Mount Sumbing",
            Content = "Auto Summit Started",
            Duration = 3
        })
        
        task.spawn(function()
            local player = game.Players.LocalPlayer
            local function getChar()
                return player.Character or player.CharacterAdded:Wait()
            end
            
            -- Daftar lokasi Camp
            local camps = {
                CFrame.new(-226.429001, 437.370758, 2142.48291),   -- Camp1
                CFrame.new(-427.695007, 845.370789, 3204.15894),   -- Camp2
                CFrame.new(42.3660011, 1265.37073, 4043.6521),     -- Camp3
                CFrame.new(-1142.23804, 1549.37073, 4900.125),     -- Camp4
                CFrame.new(-942.678, 1923.001, 5410.780)           -- Camp5
            }
            
            -- Fungsi teleport aman dengan multiple checks
            local function safeTeleport(hrp, targetCFrame)
                local originalCanCollide = {}
                for _, part in pairs(hrp.Parent:GetDescendants()) do
                    if part:IsA("BasePart") then
                        originalCanCollide[part] = part.CanCollide
                        part.CanCollide = false
                    end
                end
                
                local safeHeight = targetCFrame + Vector3.new(0, 20, 0)
                hrp.CFrame = safeHeight
                hrp.Velocity = Vector3.new(0, 0, 0)
                hrp.RotVelocity = Vector3.new(0, 0, 0)
                
                task.wait(0.5)
                
                hrp.CFrame = targetCFrame + Vector3.new(0, 5, 0)
                hrp.Velocity = Vector3.new(0, 0, 0)
                hrp.RotVelocity = Vector3.new(0, 0, 0)
                
                task.wait(0.3)
                
                for part, canCollide in pairs(originalCanCollide) do
                    if part and part.Parent then
                        part.CanCollide = canCollide
                    end
                end
            end
            
            local function teleportSequence()
                while sumbingRunning do
                    for i, campCFrame in ipairs(camps) do
                        if not sumbingRunning then break end
                        
                        local char = getChar()
                        local hrp = char:WaitForChild("HumanoidRootPart")
                        local humanoid = char:WaitForChild("Humanoid")
                        
                        while humanoid.Health <= 0 do
                            if not sumbingRunning then return end
                            player.CharacterAdded:Wait()
                            char = getChar()
                            hrp = char:WaitForChild("HumanoidRootPart")
                            humanoid = char:WaitForChild("Humanoid")
                            task.wait(0.5)
                        end
                        
                        print("Teleporting to Camp " .. i)
                        safeTeleport(hrp, campCFrame)
                        task.wait(7)
                    end
                    
                    if not sumbingRunning then break end
                    
                    print("Semua camp selesai. Respawn...")
                    local char = getChar()
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.Health = 0
                    end
                    
                    player.CharacterAdded:Wait()
                    task.wait(5)
                end
            end
            
            teleportSequence()
        end)
    else
        Fluent:Notify({
            Title = "Mount Sumbing",
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
SaveManager:SetFolder("WKHub/MountSumbing")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "WKHub",
    Content = "Mount Sumbing module loaded.",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()


