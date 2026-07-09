--[[
    ══════════════════════════════════════
    🔥 BFF Reporter
    يرسل بيانات الحساب لـ Railway
    ══════════════════════════════════════
]]

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- ⚠️ ضع رابط Railway هنا
local RAILWAY_URL = "https://bloxfruits-account-production.up.railway.app"

-- ═══════════════════════════════════════
-- جمع بيانات اللاعب
-- ═══════════════════════════════════════
local function GetPlayerData()
    local data = {
        username = LocalPlayer.Name,
        level = "?",
        beli = 0,
        fragments = 0,
        sea = "Unknown",
        fruits = {},
        task = "لا يوجد"
    }
    
    -- الليفل والمال
    pcall(function()
        local stats = LocalPlayer:FindFirstChild("Data")
        if stats then
            if stats:FindFirstChild("Level") then data.level = stats.Level.Value end
            if stats:FindFirstChild("Beli") then data.beli = stats.Beli.Value end
            if stats:FindFirstChild("Fragments") then data.fragments = stats.Fragments.Value end
        end
    end)
    
    -- الفواكه في Backpack + في اليد
    pcall(function()
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, item in pairs(backpack:GetChildren()) do
                if item:IsA("Tool") then
                    table.insert(data.fruits, item.Name)
                end
            end
        end
        local char = LocalPlayer.Character
        if char then
            for _, item in pairs(char:GetChildren()) do
                if item:IsA("Tool") then
                    table.insert(data.fruits, item.Name)
                end
            end
        end
    end)
    
    -- العالم الحالي
    pcall(function()
        local placeId = game.PlaceId
        if placeId == 2753915549 then
            data.sea = "Sea 1"
        elseif placeId == 4442272183 then
            data.sea = "Sea 2"
        elseif placeId == 7449423635 then
            data.sea = "Sea 3"
        end
    end)
    
    return data
end

-- ═══════════════════════════════════════
-- إرسال البيانات لـ Railway
-- ═══════════════════════════════════════
local function SendData()
    local data = GetPlayerData()
    local json = HttpService:JSONEncode(data)
    
    pcall(function()
        -- طريقة request (تعمل في Delta)
        local req = http_request or request or (syn and syn.request)
        if req then
            req({
                Url = RAILWAY_URL .. "/update",
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = json
            })
        end
    end)
end

-- ═══════════════════════════════════════
-- تشغيل الإرسال كل 5 ثواني
-- ═══════════════════════════════════════
spawn(function()
    while true do
        pcall(SendData)
        wait(5)
    end
end)

-- إشعار في اللعبة
StarterGui:SetCore("SendNotification", {
    Title = "🔥 BFF Reporter";
    Text = "الإرسال بدأ! افتح الموقع لرؤية البيانات";
    Duration = 5;
})

print("✅ [BFF] البيانات تُرسل الآن كل 5 ثواني إلى Railway")
