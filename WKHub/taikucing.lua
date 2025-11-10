-- Script untuk join private server Fish It
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local placeId = 121864768012064
local privateServerCode = "19324558882035812688234003364118"

local player = Players.LocalPlayer

-- Function untuk join private server
local function joinPrivateServer()
    local success, errorMessage = pcall(function()
        TeleportService:TeleportToPrivateServer(
            placeId,
            privateServerCode,
            {player}
        )
    end)
    
    if success then
        print("Berhasil join private server!")
    else
        warn("Gagal join private server: " .. tostring(errorMessage))
    end
end

-- Tunggu sebentar untuk memastikan player sudah load
wait(1)

-- Join private server
joinPrivateServer()
