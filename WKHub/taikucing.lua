-- Script Join Private Server untuk Delta Mobile
-- Dengan GUI notification

local link = "https://www.roblox.com/games/121864768012064/UPD-Fish-It?privateServerLinkCode=19324558882035812688234003364118"

-- Buat GUI Notification
local function createNotification(title, text, duration)
    local StarterGui = game:GetService("StarterGui")
    StarterGui:SetCore("SendNotification", {
        Title = title;
        Text = text;
        Duration = duration or 5;
    })
end

-- Copy ke clipboard
local function copyToClipboard()
    if setclipboard then
        setclipboard(link)
        createNotification("✅ Berhasil!", "Link disalin ke clipboard!", 5)
        return true
    else
        createNotification("❌ Gagal", "Clipboard tidak support", 5)
        return false
    end
end

-- Coba teleport (kemungkinan kecil work di mobile)
local function tryTeleport()
    local success = pcall(function()
        game:GetService("TeleportService"):Teleport(121864768012064, game.Players.LocalPlayer)
    end)
    
    if success then
        createNotification("🎮 Joining...", "Teleporting ke server...", 3)
        return true
    end
    return false
end

-- Main execution
createNotification("🔄 Memproses...", "Mencoba join server...", 3)
wait(1)

if not tryTeleport() then
    wait(1)
    if copyToClipboard() then
        wait(2)
        createNotification("📋 Langkah selanjutnya:", "1. Minimize Roblox\n2. Buka browser\n3. Paste link (tahan & paste)", 10)
        wait(3)
        createNotification("💡 Link sudah dicopy!", "Tinggal paste di browser!", 5)
    else
        createNotification("📝 Copy Manual", "Buka chat ini lagi untuk copy link", 8)
    end
end

-- Buat tombol GUI untuk re-copy
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Buat ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "JoinServerGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Buat tombol
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0.5, -100, 0, 20)
button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
button.Text = "📋 Copy Link Lagi"
button.TextColor3 = Color3.white
button.TextSize = 18
button.Font = Enum.Font.GothamBold
button.Parent = screenGui

-- Rounded corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = button

-- Tombol click
button.MouseButton1Click:Connect(function()
    if copyToClipboard() then
        button.Text = "✅ Berhasil Dicopy!"
        wait(2)
        button.Text = "📋 Copy Link Lagi"
    else
        button.Text = "❌ Gagal Copy"
        wait(2)
        button.Text = "📋 Copy Link Lagi"
    end
end)

-- Auto hide tombol setelah 15 detik
spawn(function()
    wait(15)
    button:TweenPosition(
        UDim2.new(0.5, -100, 0, -60),
        Enum.EasingDirection.In,
        Enum.EasingStyle.Back,
        0.5,
        true
    )
end)

-- Tampilkan tombol saat di-hover (untuk show lagi)
local showButton = Instance.new("TextButton")
showButton.Size = UDim2.new(0, 100, 0, 30)
showButton.Position = UDim2.new(0.5, -50, 0, 5)
showButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
showButton.BackgroundTransparency = 0.5
showButton.Text = "📋 Show"
showButton.TextColor3 = Color3.white
showButton.TextSize = 14
showButton.Font = Enum.Font.Gotham
showButton.Parent = screenGui

local corner2 = Instance.new("UICorner")
corner2.CornerRadius = UDim.new(0, 8)
corner2.Parent = showButton

showButton.MouseButton1Click:Connect(function()
    button:TweenPosition(
        UDim2.new(0.5, -100, 0, 20),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Back,
        0.5,
        true
    )
end)
