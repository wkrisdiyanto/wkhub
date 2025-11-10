-- Script Join/Rejoin Private Server Fish It
-- Universal untuk semua executor

local placeId = 121864768012064
local accessCode = "19324558882035812688234003364118"

-- Fungsi utama join server
local function joinServer()
    local TeleportService = game:GetService("TeleportService")
    local LocalPlayer = game:GetService("Players").LocalPlayer
    
    -- Coba berbagai method
    local methods = {
        -- Method 1: Standard TeleportToPrivateServer
        function()
            TeleportService:TeleportToPrivateServer(placeId, accessCode, {LocalPlayer})
        end,
        
        -- Method 2: Dengan TeleportOptions
        function()
            local teleportOptions = Instance.new("TeleportOptions")
            teleportOptions.ServerInstanceId = accessCode
            TeleportService:TeleportAsync(placeId, {LocalPlayer}, teleportOptions)
        end,
        
        -- Method 3: ReservedServerAccessCode
        function()
            TeleportService:TeleportToPrivateServer(placeId, accessCode, {LocalPlayer}, "", "", "")
        end,
    }
    
    -- Coba semua method
    for i, method in ipairs(methods) do
        local success, err = pcall(method)
        if success then
            print("✅ Method " .. i .. " berhasil! Joining server...")
            return true
        else
            warn("❌ Method " .. i .. " gagal: " .. tostring(err))
        end
    end
    
    return false
end

-- Jalankan
print("🎮 Mencoba join private server...")
print("🔗 Place ID: " .. placeId)
print("🔑 Access Code: " .. accessCode)
print("")

local worked = joinServer()

if not worked then
    print("")
    print("⚠️ Semua method gagal!")
    print("📋 Solusi alternatif:")
    print("")
    print("1️⃣ Copy link ini ke browser:")
    print("https://www.roblox.com/games/121864768012064/UPD-Fish-It?privateServerLinkCode=19324558882035812688234003364118")
    
    if setclipboard then
        setclipboard("https://www.roblox.com/games/121864768012064/UPD-Fish-It?privateServerLinkCode=19324558892035812688234003364118")
        print("")
        print("✅ Link sudah disalin ke clipboard!")
    end
    
    print("")
    print("2️⃣ Atau coba executor berbeda")
    print("3️⃣ Pastikan kamu TIDAK sedang di game yang sama")
end
