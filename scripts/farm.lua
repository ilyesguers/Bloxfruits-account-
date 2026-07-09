--[[
    ══════════════════════════════════════════════
    🔥 BFF FARM SYSTEM v1.0 🔥
    نظام الفرم الأسطوري الذكي
    ══════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local VIM = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════
-- قاعدة بيانات الأعداء حسب الليفل
-- ═══════════════════════════════════════
local ENEMIES_BY_LEVEL = {
    -- Sea 1
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
    Title = "🔥 BFF Farm";
    Text = "نظام الفرم بدأ!";
    Duration = 3;
})

print("🔥 [BFF FARM] بدأ نظام الفرم الأسطوري")

-- ═══════════════════════════════════════
-- دوال مساعدة
-- ═══════════════════════════════════════
local function getChar()
    return LocalPlayer.Character
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
-- تحديد العدو المطلوب حسب الليفل
-- ═══════════════════════════════════════
local function getTargetEnemyName()
    local lvl = getLevel()
    for _, enemy in ipairs(ENEMIES_BY_LEVEL) do
        if lvl >= enemy.min and lvl <= enemy.max then
            return enemy.name, enemy.island
        end
    end
    return "Bandit", "Starter Island" -- افتراضي
end

-- ═══════════════════════════════════════
-- البحث عن أقرب عدو من نوع معين
-- ═══════════════════════════════════════
local function findNearestEnemy(targetName)
    local hrp = getHRP()
    if not hrp then return nil end
    
    local nearest = nil
    local nearestDist = math.huge
    
    -- ابحث في Enemies folder (لو موجود)
    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if enemiesFolder then
        for _, enemy in pairs(enemiesFolder:GetChildren()) do
            if enemy.Name == targetName and enemy:FindFirstChild("Humanoid") 
               and enemy.Humanoid.Health > 0 and enemy:FindFirstChild("HumanoidRootPart") then
                local dist = (hrp.Position - enemy.HumanoidRootPart.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearest = enemy
                end
            end
        end
    end
    
    -- ابحث في Workspace مباشرة كـ backup
    if not nearest then
        for _, enemy in pairs(workspace:GetChildren()) do
            if enemy.Name == targetName and enemy:FindFirstChild("Humanoid") 
               and enemy.Humanoid.Health > 0 and enemy:FindFirstChild("HumanoidRootPart") then
                local dist = (hrp.Position - enemy.HumanoidRootPart.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearest = enemy
                end
            end
        end
    end
    
    return nearest
end

-- ═══════════════════════════════════════
-- الانتقال بـ Tween (سلس، لا يتكشف)
-- ═══════════════════════════════════════
local function tweenTo(targetCFrame, speed)
    local hrp = getHRP()
    if not hrp then return end
    
    speed = speed or 400
    local dist = (hrp.Position - targetCFrame.Position).Magnitude
    local time = math.max(dist / speed, 0.1)
    
    local tween = TweenService:Create(
        hrp,
        TweenInfo.new(time, Enum.EasingStyle.Linear),
        {CFrame = targetCFrame}
    )
    
    tween:Play()
    return tween
end

-- ═══════════════════════════════════════
-- تجهيز السلاح (السيف أو الفاكهة)
-- ═══════════════════════════════════════
local function equipWeapon()
    local char = getChar()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not char or not backpack then return end
    
    -- إذا في يده سلاح خلاص
    for _, item in pairs(char:GetChildren()) do
        if item:IsA("Tool") then return end
    end
    
    -- جيب أول سلاح من backpack
    for _, item in pairs(backpack:GetChildren()) do
        if item:IsA("Tool") then
            local humanoid = getHumanoid()
            if humanoid then
                humanoid:EquipTool(item)
                return
            end
        end
    end
end

-- ═══════════════════════════════════════
-- الهجوم (كليك)
-- ═══════════════════════════════════════
local function attack()
    pcall(function()
        VIM:SendMouseButtonEvent(500, 500, 0, true, game, 1)
        wait(0.1)
        VIM:SendMouseButtonEvent(500, 500, 0, false, game, 1)
    end)
end

-- ═══════════════════════════════════════
-- الحلقة الرئيسية للفرم
-- ═══════════════════════════════════════
getgenv().BFF_FARM_ACTIVE = true

spawn(function()
    while getgenv().BFF_FARM_ACTIVE do
        pcall(function()
            local hrp = getHRP()
            if not hrp then wait(2); return end
            
            equipWeapon()
            
            local targetName, targetIsland = getTargetEnemyName()
            local enemy = findNearestEnemy(targetName)
            
            if enemy and enemy:FindFirstChild("HumanoidRootPart") then
                local enemyHRP = enemy.HumanoidRootPart
                
                -- انتقل فوق العدو (لا يقدر يضربك)
                local targetPos = enemyHRP.CFrame * CFrame.new(0, 15, 0)
                hrp.CFrame = targetPos
                
                -- ثبت اللاعب
                local humanoid = getHumanoid()
                if humanoid then
                    humanoid.WalkSpeed = 0
                    humanoid.JumpPower = 0
                end
                
                -- هاجم
                repeat
                    hrp.CFrame = enemyHRP.CFrame * CFrame.new(0, 15, 0)
                    attack()
                    wait(0.3)
                until not enemy:FindFirstChild("Humanoid") 
                    or enemy.Humanoid.Health <= 0 
                    or not getgenv().BFF_FARM_ACTIVE
                
                print("✅ [BFF FARM] قتل: " .. targetName)
            else
                -- ما فيه عدو قريب، دور بالماب
                print("🔍 [BFF FARM] يبحث عن: " .. targetName .. " في " .. targetIsland)
                wait(2)
            end
        end)
        wait(0.3)
    end
end)

print("✅ [BFF FARM] النظام يعمل الآن")
StarterGui:SetCore("SendNotification", {
    Title = "✅ BFF Farm";
    Text = "الفرم يعمل! ابحث عن أعداء تلقائياً";
    Duration = 5;
})
