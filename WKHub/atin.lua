local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "WKHub - Mount Atin",
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
    Content = "Atin module loaded!",
    Duration = 5
})

-- Mount Atin Section
local AtinSection = Tabs.Main:AddSection("Mount Atin")

local ToggleAtinAuto = Tabs.Main:AddToggle("AutoSummitAtin", {
    Title = "Auto Summit", 
    Default = false
})

local atinRunning = false

ToggleAtinAuto:OnChanged(function()
    atinRunning = Options.AutoSummitAtin.Value
    
    if atinRunning then
        Fluent:Notify({
            Title = "Mount Atin",
            Content = "Auto Summit Started",
            Duration = 3
        })
        
        task.spawn(function()
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
            
            local cframes = {
                CFrame.new(70.4621277, 1719.31506, 3426.41553, 0.999119937, 0.0419389345, 0.000694667513, -0.0419446863, 0.998981237, 0.0166486613, 4.26732004e-06, -0.0166631453, 0.999861181),
                CFrame.new(435.741577, 1721.20032, 3430.40601, 0.999768972, 0.0214929376, -1.11325262e-05, -0.0214929376, 0.999768436, -0.00103580416, -1.11325262e-05, 0.00103580416, 0.999999464),
                CFrame.new(624.730652, 1799.73059, 3432.02881, 0.990095973, -0.140392154, -1.42259523e-05, 0.137154281, 0.967239797, 0.21362561, -0.0299775973, -0.211511821, 0.976915598),
                CFrame.new(780.575073, 2176.61157, 3922.71777, 1, 0, 0, 0, 1, 0, 0, 0, 1)
            }
            
            local delayTime = 2
            
            local function teleportSequence()
                for i, cf in ipairs(cframes) do
                    if not atinRunning then return end
                    print("Teleporting ke lokasi " .. i)
                    humanoidRootPart.CFrame = cf
                    if i < #cframes then
                        task.wait(delayTime)
                    end
                end
                print("Teleport selesai!")
            end
            
            local function rejoinNewServer()
                print("Mencari server baru...")
                local TeleportService = game:GetService("TeleportService")
                local HttpService = game:GetService("HttpService")
                local placeId = game.PlaceId
                local currentJobId = game.JobId
                local success = pcall(function()
                    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"))
                    for _, server in pairs(servers.data) do
                        if server.id ~= currentJobId and server.playing < server.maxPlayers then
                            print("Server baru ditemukan! Teleporting...")
                            TeleportService:TeleportToPlaceInstance(placeId, server.id, player)
                            return
                        end
                    end
                    print("Tidak ada server berbeda, rejoin normal...")
                    TeleportService:Teleport(placeId, player)
                end)
                if not success then
                    print("Error mencari server, rejoin normal...")
                    TeleportService:Teleport(placeId, player)
                end
            end
            
            teleportSequence()
            task.wait(1)
            if atinRunning then
                rejoinNewServer()
            end
        end)
    else
        Fluent:Notify({
            Title = "Mount Atin",
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
SaveManager:SetFolder("WKHub/MountAtin")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "WKHub",
    Content = "Mount Atin module loaded.",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()


