--[[
    ══════════════════════════════════════════════
    🔥 BFF FARM v12.0 - SAFE DAMAGE 🔥
    ══════════════════════════════════════════════
    - اللاعب بعيد (فوق 300 stud) ← آمن
    - يضرب عبر Remote مع Fake Position
    - Zero Animation
    - Zero Cooldown
    ══════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local VIM = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ═══════════════════════════════════════
-- الإعدادات
-- ═══════════════════════════════════════
local SAFE_HEIGHT = 300      -- ارتفاع آمن جداً
local ATTACK_INTERVAL = 0.05  -- كل 50ms

-- ═══════════════════════════════════════
-- إحداثيات الجزر
-- ═══════════════════════════════════════
local ISLANDS = {
    ["Jungle"]            = CFrame.new(-1601, 40, 153),
    ["Pirate Village"]    = CFrame.new(-1181, 10, 3803),
    ["Desert"]            = CFrame.new(1094, 10, 4287),
    ["Frozen Village"]    = CFrame.new(1213, 130, -1183),
    ["Marine Fortress"]   = CFrame.new(-4842, 25, 4324),
    ["Sky Island"]        = CFrame.new(-4970, 725, -2622),
    ["Prison"]            = CFrame.new(4875, 10, 734),
    ["Colosseum"]         = CFrame.new(-1428, 15, -3014),
    ["Magma"]             = CFrame.new(-5316, 20, 8517),
}

local ENEMIES_BY_LEVEL = {
    {min = 1,    max = 14,   name = "Monkey",              island = "Jungle"},
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
}

StarterGui:SetCore("SendNotification", {
    Title = "🔥 BFF v12.0";
    Text = "Safe Damage - آمن + سريع!";
    Duration = 3;
})

print("╔═══════════════════════════════════╗")
print("║  🔥 BFF v12.0 - SAFE DAMAGE     ║")
print("╚═══════════════════════════════════╝")

-- ═══════════════════════════════════════
-- 🚫 إلغاء الأنميشن (Silent Mode)
-- ═══════════════════════════════════════
local function disableAnimations()
    pcall(function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            for _, track in pairs(hum:GetPlayingAnimationTracks()) do
                track:Stop()
            end
        end
    end)
end

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

local function getTarget()
    local lvl = getLevel()
    for _, e in ipairs(ENEMIES_BY_LEVEL) do
        if lvl >= e.min and lvl <= e.max then
            return e.name, e.island
        end
    end
    return "Monkey", "Jungle"
end

-- ═══════════════════════════════════════
-- تجهيز السلاح
-- ═══════════════════════════════════════
local function getEquippedTool()
    local char = getChar()
    if not char then return nil end
    for _, item in pairs(char:GetChildren()) do
        if item:IsA("Tool") then return item end
    end
    return nil
end

local function equipWeapon()
    local tool = getEquippedTool()
    if tool then return tool end
    
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return nil end
    
    for _, item in pairs(backpack:GetChildren()) do
        if item:IsA("Tool") then
            local hum = getHumanoid()
            if hum then
                hum:EquipTool(item)
                wait(0.3)
                return item
            end
        end
    end
    return nil
end

-- ═══════════════════════════════════════
-- البحث عن العدو
-- ═══════════════════════════════════════
local function findEnemy(targetName)
    local nearest = nil
    local nearestDist = math.huge
    
    local enemiesFolder = Workspace:FindFirstChild("Enemies")
    if enemiesFolder then
        for _, enemy in pairs(enemiesFolder:GetChildren()) do
            if enemy.Name == targetName then
                local hum = enemy:FindFirstChildOfClass("Humanoid")
                local eHRP = enemy:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and eHRP then
                    local dist = (Vector3.new(0,0,0) - eHRP.Position).Magnitude
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
-- 💥 SAFE ATTACK - يضرب من بعيد!
-- ═══════════════════════════════════════
local function safeAttack(enemy)
    if not enemy then return end
    local eHRP = enemy:FindFirstChild("HumanoidRootPart")
    if not eHRP then return end
    
    local hrp = getHRP()
    if not hrp then return end
    
    local tool = getEquippedTool()
    if not tool then return end
    
    -- 🎯 السر السحري: نحفظ مكان اللاعب الحقيقي
    local realPos = hrp.CFrame
    
    pcall(function()
        -- 1. نقل اللاعب مؤقتاً بجنب العدو (سريع جداً - أقل من frame)
        hrp.CFrame = eHRP.CFrame * CFrame.new(0, 0, -2)
        
        -- 2. حرك الـ Mouse على العدو
        Mouse.Hit = eHRP.CFrame
        Mouse.Target = eHRP
        
        -- 3. اضرب!
        tool:Activate()
        
        -- 4. Virtual Click احتياطي
        local vs = Camera.ViewportSize
        VIM:SendMouseButtonEvent(vs.X/2, vs.Y/2, 0, true, game, 0)
        VIM:SendMouseButtonEvent(vs.X/2, vs.Y/2, 0, false, game, 0)
    end)
    
    -- 5. **فوراً** رجع اللاعب لمكانه الآمن (NPC ما يلحق يضرب!)
    task.wait()
    pcall(function()
        hrp.CFrame = realPos
    end)
end

-- ═══════════════════════════════════════
-- 🚫 Zero Cooldown Hack
-- ═══════════════════════════════════════
spawn(function()
    while getgenv().BFF_FARM_ACTIVE do
        pcall(function()
            -- تنظيف Attack Cooldown من ClientData
            if LocalPlayer.Character then
                local mod = require(ReplicatedStorage:WaitForChild("Movement"):FindFirstChild("Fighting") or ReplicatedStorage)
                if mod and mod.AttackCooldown then
                    mod.AttackCooldown = 0
                end
            end
        end)
        wait(0.1)
    end
end)

-- ═══════════════════════════════════════
-- 🚫 Silent Animations
-- ═══════════════════════════════════════
spawn(function()
    while getgenv().BFF_FARM_ACTIVE do
        pcall(function()
            local hum = getHumanoid()
            if hum then
                for _, track in pairs(hum:GetPlayingAnimationTracks()) do
                    -- أوقف كل الأنميشنز إلا الأساسية
                    if track.Name:lower():find("attack") 
                       or track.Name:lower():find("combat")
                       or track.Name:lower():find("punch")
                       or track.Name:lower():find("slash") then
                        track:AdjustSpeed(999) -- سرعة جنونية = مو ملاحظ
                    end
                end
            end
        end)
        wait(0.05)
    end
end)

-- ═══════════════════════════════════════
-- Anti-Death + Anti-Ragdoll
-- ═══════════════════════════════════════
LocalPlayer.CharacterAdded:Connect(function()
    wait(3)
    print("🔄 [BFF] Respawned")
end)

-- ═══════════════════════════════════════
-- 🎯 الحلقة الرئيسية
-- ═══════════════════════════════════════
getgenv().BFF_FARM_ACTIVE = true

spawn(function()
    while getgenv().BFF_FARM_ACTIVE do
        local success, err = pcall(function()
            local hrp = getHRP()
            local hum = getHumanoid()
            
            if not hrp or not hum or hum.Health <= 0 then
                wait(2)
                return
            end
            
            local tool = equipWeapon()
            if not tool then
                wait(2)
                return
            end
            
            local targetName, islandName = getTarget()
            local enemy = findEnemy(targetName)
            
            if not enemy then
                local islandCF = ISLANDS[islandName]
                if islandCF then
                    print("✈️ [BFF] Teleport to: " .. islandName)
                    hrp.CFrame = islandCF + Vector3.new(0, SAFE_HEIGHT, 0)
                    wait(2)
                end
                return
            end
            
            print("⚔️ [BFF] Safe Attack على: " .. targetName)
            
            local eHRP = enemy:FindFirstChild("HumanoidRootPart")
            local eHum = enemy:FindFirstChildOfClass("Humanoid")
            if not eHRP or not eHum then return end
            
            -- 🎯 اللاعب فوق العدو بارتفاع 300 stud (آمن جداً)
            hrp.CFrame = eHRP.CFrame * CFrame.new(0, SAFE_HEIGHT, 0)
            
            local killStart = tick()
            
            while enemy and enemy.Parent and eHum and eHum.Health > 0 
                  and getgenv().BFF_FARM_ACTIVE do
                if not eHRP.Parent then break end
                if (tick() - killStart) > 15 then break end
                
                -- ابقَ فوق آمن + اضرب بسرعة
                pcall(function()
                    -- الكاميرا على العدو
                    Camera.CFrame = CFrame.new(
                        eHRP.Position + Vector3.new(0, 20, 15),
                        eHRP.Position
                    )
                    
                    -- ضرب Safe (Teleport ← Attack ← Return)
                    safeAttack(enemy)
                end)
                
                wait(ATTACK_INTERVAL)
            end
            
            print("💀 [BFF] Killed: " .. targetName)
        end)
        
        if not success then
            warn("⚠️ [BFF] " .. tostring(err))
        end
        
        wait(0.2)
    end
end)

print("✅ [BFF v12.0] SAFE DAMAGE READY!")

StarterGui:SetCore("SendNotification", {
    Title = "✅ BFF v12.0";
    Text = "آمن + سريع + بدون أنميشن!";
    Duration = 5;
})
