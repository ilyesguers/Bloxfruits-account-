--[[
    ══════════════════════════════════════════════
    🔥 BFF AUTO STATS - Melee & Defense 🔥
    ══════════════════════════════════════════════
    - يوزع 3 نقاط كل ليفل
    - 2 Melee + 1 Defense (نسبة ذهبية)
    - يشتغل تلقائياً في الخلفية
    ══════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════
-- الإعدادات
-- ═══════════════════════════════════════
local STAT_DISTRIBUTION = {
    Melee = 2,      -- 2 نقاط للـ Melee (الأهم للفرم)
    Defense = 1,    -- 1 نقطة للـ Defense
}
-- المجموع = 3 نقاط لكل ليفل ✓

StarterGui:SetCore("SendNotification", {
    Title = "📊 Auto Stats";
    Text = "2 Melee + 1 Defense كل ليفل";
    Duration = 3;
})

print("╔═══════════════════════════════════╗")
print("║  📊 BFF AUTO STATS ACTIVE       ║")
print("╚═══════════════════════════════════╝")

-- ═══════════════════════════════════════
-- الحصول على النقاط المتاحة
-- ═══════════════════════════════════════
local function getAvailablePoints()
    local points = 0
    pcall(function()
        local data = LocalPlayer:FindFirstChild("Data")
        if data then
            local stats = data:FindFirstChild("Stats")
            if stats then
                points = stats.Value or 0
            end
        end
    end)
    
    -- طريقة ثانية
    if points == 0 then
        pcall(function()
            local gui = LocalPlayer.PlayerGui:FindFirstChild("Main")
            if gui then
                for _, obj in pairs(gui:GetDescendants()) do
                    if obj:IsA("TextLabel") and obj.Text and obj.Text:find("Available Points") then
                        local n = obj.Text:match("%d+")
                        if n then points = tonumber(n) end
                    end
                end
            end
        end)
    end
    
    return points
end

-- ═══════════════════════════════════════
-- إضافة نقطة لـ Stat
-- ═══════════════════════════════════════
local function addStatPoint(statName, amount)
    amount = amount or 1
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if not remotes then return end
        
        local commF = remotes:FindFirstChild("CommF_")
        if not commF then return end
        
        for i = 1, amount do
            commF:InvokeServer("AddPoint", statName, 1)
            wait(0.1)
        end
    end)
end

-- ═══════════════════════════════════════
-- 🎯 الحلقة الرئيسية
-- ═══════════════════════════════════════
getgenv().BFF_STATS_ACTIVE = true

spawn(function()
    while getgenv().BFF_STATS_ACTIVE do
        pcall(function()
            local points = getAvailablePoints()
            
            if points >= 3 then
                print("📊 [STATS] نقاط متاحة: " .. points)
                
                -- وزّع النقاط
                local totalCycles = math.floor(points / 3)
                
                for i = 1, totalCycles do
                    addStatPoint("Melee", STAT_DISTRIBUTION.Melee)
                    addStatPoint("Defense", STAT_DISTRIBUTION.Defense)
                end
                
                print("✅ [STATS] تم توزيع " .. (totalCycles * 3) .. " نقطة")
            end
        end)
        wait(10) -- كل 10 ثواني
    end
end)

print("✅ [STATS] Auto Stats يعمل!")
