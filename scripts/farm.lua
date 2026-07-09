--[[
    ══════════════════════════════════════════════
    🔥 BFF FARM PRO v2.0 - النسخة الأسطورية 🔥
    ══════════════════════════════════════════════
    - Auto Teleport للجزر
    - Anti-Damage (يبقى فوق العدو)
    - Attack Loop سريع جداً
    - Enemy Spawn Trigger
    ══════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local VIM = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════
-- إحداثيات الجزر (Sea 1)
-- ═══════════════════════════════════════
local ISLANDS = {
    ["Starter Island"]    = CFrame.new(1071, 16, 1426),
    ["Jungle"]            = CFrame.new(-1601, 36, 153),
    ["Pirate Village"]    = CFrame.new(-1181, 4, 3803),
    ["Desert"]            = CFrame.new(1094, 6, 4287),
    ["Frozen Village"]    = CFrame.new(1213, 126, -1183),
    ["Marine Fortress"]   = CFrame.new(-4842, 20, 4324),
    ["Sky Island"]        = CFrame.new(-4970, 719, -2622),
    ["Prison"]            = CFrame.new(4875, 5, 734),
    ["Colosseum"]         = CFrame.new(-1428, 7, -3014),
    ["Magma"]             = CFrame.new(-5316, 12, 8517),
    ["Underwater"]        = CFrame.new(61163, 11, 1819),
    ["Upper Sky"]         = CFrame.new(-7862, 5545, -380),
    ["Fountain City"]     = CFrame.new(5127, 4, 4105),
}

-- ═══════════════════════════════════════
-- قاعدة بيانات الأعداء
-- ═══════════════════════════════════════
local ENEMIES_BY_LEVEL = {
    {min = 1,    max = 9,    name = "Bandit",              island = "Starter Island"},
    {min = 10,   max = 14,   name = "Monkey",              island = "Jungle"},
    {min = 15,   max = 29,   name = "Gorilla",             island = "Jungle"},
    {min = 30,   max = 39,   name = "Pirate",              island = "Pirate Village"},
    {min = 40,   max = 59,   name = "Brute",               island = "Pirate Village"},
    {min = 60,   max = 74,   name = "Desert Bandit",       island = "Desert"},
    {min = 75,   max = 89,   name = "Desert Officer",      island = "Desert"},
    {min = 90,   max = 99,   name = "Snow Bandit",         island = "Frozen Village"},
    {min = 100,  max = 119,  name = "Snowman",             island = "Frozen Village"},
    {min = 120,  max = 149,  name = "Chief Petty Officer", island = "Marine Fortress"},
    {min = 150,  max = 174,  name = "Sky Bandit",          island = "Sky Island"},
    {min = 175,  max = 189,  name = "Dark Master",         island = "Sky Island"},
    {min = 190,  max = 209,  name = "Prisoner",            island = "Prison"},
    {min = 210,  max = 249,  name = "Dangerous Prisoner",  island = "Prison"},
    {min = 250,  max = 274,  name = "Toga Warrior",        island = "Colosseum"},
    {min = 275,  max = 299,  name = "Gladiator",           island = "Colosseum"},
    {min = 300,  max = 324,  name = "Military Soldier",    island = "Magma"},
    {min = 325,  max = 374,  name = "Military Spy",        island = "Magma"},
    {min = 375,  max = 399,  name = "Fishman Warrior",     island = "Underwater"},
    {min = 400,  max = 449,  name = "Fishman Commando",    island = "Underwater"},
    {min = 450,  max = 474,  name = "God's Guard",         island = "Upper Sky"},
    {min = 475,  max = 524,  name = "Shanda",              island = "Upper Sky"},
    {min = 525,  max = 549,  name = "Royal Squad",         island = "Fountain City"},
    {min = 550,  max = 624,  name = "Royal Soldier",       island = "Fountain City"},
    {min = 625,  max = 700,  name = "Galley Pirate",       island = "Fountain City"},
}

-- ═══════════════════════════════════════
-- إشعار البداية
-- ═══════════════════════════════════════
StarterGui:SetCore("SendNotification", {
    Title = "🔥 BFF Farm PRO";
    Text = "بدء الفرم الأسطوري...";
    Duration = 3;
})

print("╔═══════════════════════════════════╗")
print("║  🔥 BFF FARM PRO v2.0 STARTED    ║")
print("╚═══════════════════════════════════╝")

-- ═══════════════════════════════════════
-- دوال أساسية
-- ═══════════════════════════════════════
local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function getLevel()
    local ok, lvl = pcall(function()
        return LocalPlayer.Data.Level.Value
    end)
    return ok and lvl or 1
end

-- ═══════════════════════════════════════
-- تحديد العدو والجزيرة
-- ═══════════════════════════════════════
local function getTarget()
    local lvl = getLevel()
    for _, e in ipairs(ENEMIES_BY_LEVEL) do
        if lvl >= e.min and lvl <= e.max then
            return e.name, e.island
        end
    end
    return "Bandit", "Starter Island"
end

-- ═══════════════════════════════════════
-- تجهيز السلاح تلقائياً
-- ═══════════════════════════════════════
local function equipBestWeapon()
    local char = getChar()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not char or not backpack then return end
    
    -- إذا في يده سلاح فعلاً، خلاص
    for _, item in pairs(char:GetChildren()) do
        if item:IsA("Tool") then return true end
    end
    
    -- جيب أول سلاح
    for _, item in pairs(backpack:GetChildren()) do
        if item:IsA("Tool") then
            local hum = getHumanoid()
            if hum then
                hum:EquipTool(item)
                return true
            end
        end
    end
    return false
end

-- ═══════════════════════════════════════
-- Teleport للجزيرة
-- ═══════════════════════════════════════
local function teleportToIsland(islandName)
    local coords = ISLANDS[islandName]
    if not coords then return false end
    
    local hrp = getHRP()
    if not hrp then return false end
    
    hrp.CFrame = coords
    print("🚢 [BFF] Teleport إلى: " .. islandName)
    return true
end

-- ═══════════════════════════════════════
-- البحث عن أقرب عدو
-- ═══════════════════════════════════════
local function findEnemy(targetName)
    local hrp = getHRP()
    if not hrp then return nil end
    
    local nearest = nil
    local nearestDist = math.huge
    
    -- ابحث في Enemies folder
    local enemiesFolder = Workspace:FindFirstChild("Enemies")
    if enemiesFolder then
        for _, enemy in pairs(enemiesFolder:GetChildren()) do
            if enemy.Name == targetName then
                local hum = enemy:FindFirstChildOfClass("Humanoid")
                local eHRP = enemy:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and eHRP then
                    local dist = (hrp.Position - eHRP.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearest = enemy
                    end
                end
            end
        end
    end
    
    return nearest
end

-- ═══════════════════════════════════════
-- تثبيت اللاعب فوق العدو (Anti-Damage)
-- ═══════════════════════════════════════
local activeConnection = nil
local function lockAboveEnemy(enemy)
    if activeConnection then
        activeConnection:Disconnect()
        activeConnection = nil
    end
    
    local hrp = getHRP()
    if not hrp or not enemy then return end
    
    local eHRP = enemy:FindFirstChild("HumanoidRootPart")
    if not eHRP then return end
    
    -- تعطيل الجاذبية
    activeConnection = RunService.Heartbeat:Connect(function()
        if enemy and enemy.Parent and eHRP and hrp then
            local hum = enemy:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                -- ثبت اللاعب فوق العدو بارتفاع 20
                hrp.CFrame = eHRP.CFrame * CFrame.new(0, 20, 0)
                hrp.Velocity = Vector3.new(0, 0, 0)
                hrp.RotVelocity = Vector3.new(0, 0, 0)
            else
                if activeConnection then
                    activeConnection:Disconnect()
                    activeConnection = nil
                end
            end
        else
            if activeConnection then
                activeConnection:Disconnect()
                activeConnection = nil
            end
        end
    end)
end

-- ═══════════════════════════════════════
-- الهجوم السريع (Remote-based)
-- ═══════════════════════════════════════
local function fastAttack()
    -- محاولة استخدام Remote مباشرة (أسرع بكثير من الكليك)
    local success = pcall(function()
        local args = {"KillLegacy"}
        local remote = ReplicatedStorage:FindFirstChild("Remotes")
        if remote then
            local commE = remote:FindFirstChild("CommE")
            if commE then
                commE:FireServer(unpack(args))
            end
        end
    end)
    
    -- Fallback: Virtual Click
    if not success then
        pcall(function()
            VIM:SendMouseButtonEvent(500, 500, 0, true, game, 1)
            VIM:SendMouseButtonEvent(500, 500, 0, false, game, 1)
        end)
    end
end

-- ═══════════════════════════════════════
-- Anti-Death
-- ═══════════════════════════════════════
LocalPlayer.CharacterAdded:Connect(function()
    wait(3)
    print("🔄 [BFF] الشخصية عادت، إعادة تشغيل الفرم...")
end)

-- ═══════════════════════════════════════
-- الحلقة الرئيسية
-- ═══════════════════════════════════════
getgenv().BFF_FARM_ACTIVE = true

spawn(function()
    while getgenv().BFF_FARM_ACTIVE do
        pcall(function()
            local hrp = getHRP()
            local hum = getHumanoid()
            
            if not hrp or not hum or hum.Health <= 0 then
                wait(2)
                return
            end
            
            -- تجهيز السلاح
            equipBestWeapon()
            
            local targetName, islandName = getTarget()
            local enemy = findEnemy(targetName)
            
            if not enemy then
                -- ما فيه عدو، روح للجزيرة عشان يترسبنون
                print("🗺️ [BFF] لا يوجد " .. targetName .. "، الانتقال إلى " .. islandName)
                teleportToIsland(islandName)
                wait(3) -- انتظر spawn
                return
            end
            
            print("⚔️ [BFF] هدف: " .. targetName .. " | Distance: " .. math.floor((hrp.Position - enemy.HumanoidRootPart.Position).Magnitude))
            
            -- ثبت فوق العدو
            lockAboveEnemy(enemy)
            
            -- اضرب بسرعة جنونية
            local enemyHum = enemy:FindFirstChildOfClass("Humanoid")
            while enemy and enemy.Parent and enemyHum and enemyHum.Health > 0 and getgenv().BFF_FARM_ACTIVE do
                fastAttack()
                wait(0.1) -- سرعة عالية جداً
            end
            
            print("💀 [BFF] قتل: " .. targetName)
            
            -- فك التثبيت
            if activeConnection then
                activeConnection:Disconnect()
                activeConnection = nil
            end
        end)
        wait(0.2)
    end
end)

print("✅ [BFF FARM PRO] النظام يعمل الآن!")

StarterGui:SetCore("SendNotification", {
    Title = "✅ BFF Farm PRO";
    Text = "الفرم شغال! ينتقل ويقتل تلقائياً";
    Duration = 5;
})
