local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "WKHub - Mount Taber",
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
    Content = "Taber module loaded!",
    Duration = 5
})

-- Mount Taber Section
local TaberSection = Tabs.Main:AddSection("Mount Taber")

local ToggleTaberAuto = Tabs.Main:AddToggle("AutoSummitTaber", {
    Title = "Auto Summit",
    Default = false
})

local SliderTaberYOffset = Tabs.Main:AddSlider("TaberYOffset", {
    Title = "Y Offset",
    Description = "Offset above target (studs)",
    Default = 5,
    Min = 0,
    Max = 20,
    Rounding = 1,
})

local SliderTaberWaitAfterKill = Tabs.Main:AddSlider("TaberWaitAfterKill", {
    Title = "Wait After Kill (s)",
    Default = 1.0,
    Min = 0,
    Max = 5,
    Rounding = 2,
})

local SliderTaberWaitBetween = Tabs.Main:AddSlider("TaberWaitBetween", {
    Title = "Wait Between Cycles (s)",
    Default = 0.5,
    Min = 0,
    Max = 3,
    Rounding = 2,
})

local taberRunning = false

ToggleTaberAuto:OnChanged(function()
    taberRunning = Options.AutoSummitTaber.Value

    if taberRunning then
        Fluent:Notify({
            Title = "Mount Taber",
            Content = "Auto Summit Started",
            Duration = 3
        })

        task.spawn(function()
            local Players = game:GetService("Players")
            local player = Players.LocalPlayer

            local targetCFrame = CFrame.new(-1589.294, 1870.212, 27.107)

            local function safeTeleportTo(cframe)
                local char = player.Character
                if not char then return false end
                local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
                if not hrp then return false end
                local ok = pcall(function()
                    local yOff = (Options.TaberYOffset and Options.TaberYOffset.Value) or 5
                    hrp.CFrame = cframe + Vector3.new(0, yOff, 0)
                end)
                return ok
            end

            local function killCharacter()
                local char = player.Character
                if not char then return end
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    pcall(function()
                        humanoid.Health = 0
                    end)
                else
                    pcall(function()
                        for _, part in ipairs(char:GetChildren()) do
                            if part:IsA("BasePart") then
                                pcall(function() part:BreakJoints() end)
                            end
                        end
                    end)
                end
            end

            while taberRunning do
                if not player.Character or not player.Character.Parent then
                    player.CharacterAdded:Wait()
                end

                local ok = safeTeleportTo(targetCFrame)
                if not ok then
                    task.wait(0.5)
                else
                    task.wait(0.1)
                    killCharacter()
                    pcall(function()
                        player.CharacterAdded:Wait()
                    end)
                    task.wait((Options.TaberWaitAfterKill and Options.TaberWaitAfterKill.Value) or 1.0)
                end
                task.wait((Options.TaberWaitBetween and Options.TaberWaitBetween.Value) or 0.5)
            end
        end)
    else
        Fluent:Notify({
            Title = "Mount Taber",
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
SaveManager:SetFolder("WKHub/MountTaber")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "WKHub",
    Content = "Mount Taber module loaded.",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()


