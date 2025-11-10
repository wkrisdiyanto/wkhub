-- Script untuk join private server Fish It
-- Support untuk semua executor

local placeId = 121864768012064
local linkCode = "19324558882035812688234003364118"

-- Method 1: Menggunakan game:HttpGet (paling kompatibel)
local url = string.format(
    "https://www.roblox.com/games/start?placeId=%d&linkCode=%s",
    placeId,
    linkCode
)

-- Buka URL di browser (akan auto join)
if syn and syn.request then
    -- Untuk Synapse
    syn.request({
        Url = url,
        Method = "GET"
    })
elseif request then
    -- Untuk executor dengan request function
    request({
        Url = url,
        Method = "GET"
    })
elseif http_request then
    -- Untuk executor lain
    http_request({
        Url = url,
        Method = "GET"
    })
end

-- Alternatif: Copy link ke clipboard
if setclipboard then
    setclipboard("https://www.roblox.com/games/121864768012064/UPD-Fish-It?privateServerLinkCode=19324558882035812688234003364118")
    print("✅ Link private server disalin ke clipboard!")
    print("📋 Paste di browser untuk join")
else
    print("⚠️ Executor tidak support clipboard")
    print("🔗 Manual link: https://www.roblox.com/games/121864768012064/UPD-Fish-It?privateServerLinkCode=19324558882035812688234003364118")
end

-- Method 2: Teleport langsung (jika didukung)
local success = pcall(function()
    game:GetService("TeleportService"):TeleportToPrivateServer(
        placeId,
        linkCode,
        {game.Players.LocalPlayer}
    )
end)

if success then
    print("🎮 Joining private server...")
else
    print("⚠️ Gunakan link yang sudah disalin ke clipboard")
end
