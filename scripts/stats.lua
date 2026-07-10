--[[
    ══════════════════════════════════════════════════════════
    📊 BFF AUTO STATS v3.0 - NO GUI REQUIRED 📊
    ══════════════════════════════════════════════════════════
    
    ✅ يعمل AFK بدون فتح أي قائمة!
    ✅ يوزع النقاط عبر Remote مباشرة
    ✅ 2 Melee + 1 Defense كل ليفل
    ✅ يوزع فوري عند كل ليفل أب
    
    ══════════════════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════
-- ⚙️ الإعدادات
-- ═══════════════════════════════════════════════════════════
local STATS_CONFIG = {
    -- نسبة التوزيع (المجموع = 3 نقاط لكل ليفل)
    Melee   = 2,    -- 2 نقاط Melee (للفرم)
    Defense = 1,    -- 1 نقطة Defense (للبقاء)
    
    -- توقيت
    CHECK_INTERVAL = 5,     -- فحص كل 5 ثواني
    POINT_DELAY    = 0.15,  -- تأخير بين كل نقطة
}

-- ═══════════════════════════════════════════════════════════
-- 🛡️ حماية
-- ═══════════════════════════════════════════════════════════
if getgenv().BFF_STATS_ACTIVE then
    warn("⚠️ [STATS] شغال بالفعل!")
    return
end
getgenv().BFF_STATS_ACTIVE = true

-- ═══════════════════════════════════════════════════════════
-- 📢 إشعار
-- ═══════════════════════════════════════════════════════════
local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Stats",
            Text = text or "",
            Duration = duration or 3,
        })
    end)
end

local function log(msg)
    print("[" .. os.date("%H:%M:%S") .. "] 📊 STATS | " .. msg)
end

-- ═══════════════════════════════════════════════════════════
-- 🔧 دوال الـ Remote
-- ═══════════════════════════════════════════════════════════
local function getRemote()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if not remotes then return nil end
    return remotes:FindFirstChild("CommF_")
end

-- ═══════════════════════════════════════════════════════════
-- 📊 معرفة النقاط المتاحة (بدون فتح القائمة!)
-- ═══════════════════════════════════════════════════════════
local function getAvailablePoints()
    local points = 0
    
    -- الطريقة 1: من Data مباشرة
    pcall(function()
        local data = LocalPlayer:FindFirstChild("Data")
        if data then
            -- جرب أسماء مختلفة
            local possibleNames = {"Points", "StatPoints", "Stats", "AvailablePoints", "Stat_Points"}
            for _, name in ipairs(possibleNames) do
                local obj = data:FindFirstChild(name)
                if obj and obj:IsA("NumberValue") or obj:IsA("IntValue") then
                    if obj.Value > 0 then
                        points = obj.Value
                        return
                    end
                end
            end
        end
    end)
    
    if points > 0 then return points end
    
    -- الطريقة 2: حساب النقاط من الليفل
    -- كل ليفل = 3 نقاط، مجموع النقاط = Level * 3
    -- النقاط المستخدمة = مجموع كل الإحصائيات
    pcall(function()
        local data = LocalPlayer:FindFirstChild("Data")
        if data then
            local level = 1
            if data:FindFirstChild("Level") then
                level = data.Level.Value
            end
            
            local totalPoints = level * 3
            local usedPoints = 0
            
            local statNames = {"Melee", "Defense", "Blox Fruit", "Sword", "Gun"}
            for _, statName in ipairs(statNames) do
                local stat = data:FindFirstChild(statName)
                if stat then
                    usedPoints = usedPoints + stat.Value
                end
            end
            
            points = totalPoints - usedPoints
            if points < 0 then points = 0 end
        end
    end)
    
    return points
end

-- ═══════════════════════════════════════════════════════════
-- ➕ إضافة نقطة (عبر Remote - بدون فتح GUI!)
-- ═══════════════════════════════════════════════════════════
local function addStatPoint(statName, amount)
    amount = amount or 1
    local commF = getRemote()
    if not commF then return false end
    
    local success = false
    
    for i = 1, amount do
        -- الطريقة 1: AddPoint
        pcall(function()
            commF:InvokeServer("AddPoint", statName, 1)
            success = true
        end)
        
        -- الطريقة 2: AddStat (بعض النسخ)
        if not success then
            pcall(function()
                commF:InvokeServer("AddStat", statName, 1)
                success = true
            end)
        end
        
        -- الطريقة 3: Stats
        if not success then
            pcall(function()
                commF:InvokeServer("Stats", statName, 1)
                success = true
            end)
        end
        
        task.wait(STATS_CONFIG.POINT_DELAY)
    end
    
    return success
end

-- ═══════════════════════════════════════════════════════════
-- 📊 توزيع كل النقاط المتاحة
-- ═══════════════════════════════════════════════════════════
local function distributeAllPoints()
    local points = getAvailablePoints()
    
    if points < 3 then return 0 end
    
    local cycles = math.floor(points / 3)
    local distributed = 0
    
    for i = 1, cycles do
        -- 2 Melee
        addStatPoint("Melee", STATS_CONFIG.Melee)
        
        -- 1 Defense
        addStatPoint("Defense", STATS_CONFIG.Defense)
        
        distributed = distributed + 3
    end
    
    if distributed > 0 then
        log("تم توزيع " .. distributed .. " نقطة (Melee: " .. (cycles * 2) .. " | Defense: " .. cycles .. ")")
        notify("📊 Stats", "+" .. distributed .. " نقطة تم توزيعها!", 3)
    end
    
    return distributed
end

-- ═══════════════════════════════════════════════════════════
-- 🎬 بداية
-- ═══════════════════════════════════════════════════════════
notify("📊 Auto Stats v3.0", "2 Melee + 1 Defense | AFK Mode", 3)

log("Auto Stats v3.0 - يعمل AFK بدون فتح القائمة!")
log("التوزيع: Melee x" .. STATS_CONFIG.Melee .. " + Defense x" .. STATS_CONFIG.Defense)

print("╔═══════════════════════════════════╗")
print("║  📊 BFF AUTO STATS v3.0          ║")
print("║  ✅ يعمل AFK بدون فتح GUI       ║")
print("║  📊 2 Melee + 1 Defense          ║")
print("╚═══════════════════════════════════╝")

-- توزيع أول مرة
task.wait(2)
distributeAllPoints()

-- ═══════════════════════════════════════════════════════════
-- 🔄 حلقة التوزيع المستمرة
-- ═══════════════════════════════════════════════════════════
spawn(function()
    while getgenv().BFF_STATS_ACTIVE do
        pcall(function()
            distributeAllPoints()
        end)
        task.wait(STATS_CONFIG.CHECK_INTERVAL)
    end
end)

-- ═══════════════════════════════════════════════════════════
-- 🎯 مراقبة Level Up (توزيع فوري عند كل ليفل)
-- ═══════════════════════════════════════════════════════════
spawn(function()
    pcall(function()
        local data = LocalPlayer:FindFirstChild("Data")
        if data then
            local levelObj = data:FindFirstChild("Level")
            if levelObj then
                levelObj.Changed:Connect(function(newLevel)
                    log("🎉 Level Up! → " .. newLevel)
                    task.wait(0.5)
                    distributeAllPoints()
                end)
                log("✅ مراقبة Level Up مفعّلة!")
            end
        end
    end)
end)

log("✅ Auto Stats v3.0 جاهز!")
