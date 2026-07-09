--[[
    ══════════════════════════════════════════════
    🔥 BFF FARM v8.0 - PRECISION M1 🔥
    ══════════════════════════════════════════════
    - كاميرا موجهة تحت للعدو (يضرب فعلاً)
    - Hitbox 120 (نطاق ماكس)
    - Animation خفيف + صوت طبيعي
    - يضرب من فوق مباشرة
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

-- ═══════════════════════════════════════
-- الإعدادات
-- ═══════════════════════════════════════
local FLY_SPEED = 200
local FLY_HEIGHT = 100
local ATTACK_HEIGHT = 12       -- أقرب للعدو (كان 20)
local HITBOX_SIZE = 120        -- كبير جداً (كان 80)
local M1_SPEED = 0.08          -- 12 ضربة/ثانية (أقل صخب)

-- ═══════════════════════════════════════
-- إحداثيات الجزر
-- ═══════════════════════════════════════
local ISLANDS = {
    ["Jungle"]            = Vector3.new(-1601, 100, 153),
    ["Pirate Village"]    = Vector3.new(-1181, 100, 3803),
    ["Desert"]            = Vector3.new(1094, 100, 4287),
    ["Frozen Village"]    = Vector3.new(1213, 200, -1183),
    ["Marine Fortress"]   = Vector3.new(-4842, 100, 4324),
    ["Sky Island"]        = Vector3.new(-4970, 800, -2622),
    ["Prison"]            = Vector3.new(4875, 100, 734),
    ["Colosseum"]         = Vector3.new(-1428, 100, -3014),
    ["Magma"]             = Vector3.new(-5316, 100, 8517),
}

-- ═══════════════════════════════════════
-- الأعداء
-- ═══════════════════════════════════════
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
    Title = "🔥 BFF v8.0";
    Text = "Precision M1 - يضرب فعلاً!";
    Duration = 3;
})

print("╔═══════════════════════════════════╗")
print("║  🔥 BFF v8.0 - PRECISION M1     ║")
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
-- 🎯 HITBOX EXPANDER (120 - ماكس!)
-- ═══════════════════════════════════════
local function expandHitbox(enemy)
    if not enemy then return end
    local eHRP = enemy:FindFirstChild("HumanoidRootPart")
    if not eHRP then return end
    
    pcall(function()
        eHRP.Size = Vector3.new(HITBOX_SIZE, HITBOX_SIZE, HITBOX_SIZE)
        eHRP.Transparency = 0.9  -- شفاف جداً (شبه غير مرئي)
        eHRP.CanCollide = false
        eHRP.Massless = true
    end)
end

-- ═══════════════════════════════════════
-- 🎯 CAMERA LOCK - كاميرا موجهة على العدو
-- ═══════════════════════════════════════
local cameraLockActive = false
local cameraTarget = nil

local function lockCameraOnTarget()
    if cameraLockActive then return end
    cameraLockActive = true
    
    spawn(function()
        while cameraLockActive and getgenv().BFF_FARM_ACTIVE do
            pcall(function()
                if cameraTarget and cameraTarget.Parent then
                    local eHRP = cameraTarget:FindFirstChild("HumanoidRootPart")
                    local hrp = getHRP()
                    if eHRP and hrp then
                        -- الكاميرا فوق اللاعب وتنظر تحت للعدو مباشرة
                        Camera.CFrame = CFrame.new(
                            hrp.Position + Vector3.new(0, 5, 0),  -- الكاميرا فوق اللاعب
                            eHRP.Position                         -- تنظر للعدو
                        )
                    end
                end
            end)
            RunService.RenderStepped:Wait()
        end
    end)
end

local function unlockCamera()
    cameraLockActive = false
    cameraTarget = nil
end

-- ═══════════════════════════════════════
-- تجهيز السلاح
-- ═══════════════════════════════════════
local function equipWeapon()
    local char = getChar()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not char or not backpack then return end
    
    for _, item in pairs(char:GetChildren()) do
        if item:IsA("Tool") then return true end
    end
    
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
-- الطيران
-- ═══════════════════════════════════════
local currentBV = nil
local currentBG = nil

local function stopFlight()
    if currentBV then pcall(function() currentBV:Destroy() end) currentBV = nil end
    if currentBG then pcall(function() currentBG:Destroy() end) currentBG = nil end
    
    local hrp = getHRP()
    if hrp then
        for _, obj in pairs(hrp:GetChildren()) do
            if obj.Name:find("BFF_") then obj:Destroy() end
        end
    end
end

local function createFlight()
    local hrp = getHRP()
    if not hrp then return nil, nil end
    
    stopFlight()
    
    local bv = Instance.new("BodyVelocity")
    bv.Name = "BFF_Fly"
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.P = 1250
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = hrp
    currentBV = bv
    
    local bg = Instance.new("BodyGyro")
    bg.Name = "BFF_Gyro"
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 3000
    bg.Parent = hrp
    currentBG = bg
    
    return bv, bg
end

local function flyToIsland(targetPos)
    local hrp = getHRP()
    if not hrp then return end
    
    local bv, bg = createFlight()
    if not bv then return end
    
    local startTime = tick()
    while getgenv().BFF_FARM_ACTIVE and (tick() - startTime) < 30 do
        if not hrp or not hrp.Parent then break end
        
        local currentPos = hrp.Position
        
        if currentPos.Y < FLY_HEIGHT - 20 then
            bv.Velocity = Vector3.new(0, FLY_SPEED, 0)
            bg.CFrame = CFrame.new(currentPos, currentPos + Vector3.new(0, 1, 0))
        else
            local highTarget = Vector3.new(targetPos.X, math.max(targetPos.Y, FLY_HEIGHT), targetPos.Z)
            local direction = (highTarget - currentPos)
            local distance = direction.Magnitude
            
            if distance < 30 then break end
            
            bv.Velocity = direction.Unit * FLY_SPEED
            bg.CFrame = CFrame.new(currentPos, highTarget)
        end
        
        RunService.Heartbeat:Wait()
    end
    
    if currentBV then currentBV.Velocity = Vector3.new(0, 0, 0) end
end

-- ═══════════════════════════════════════
-- البحث عن العدو
-- ═══════════════════════════════════════
local function findEnemy(targetName)
    local hrp = getHRP()
    if not hrp then return nil end
    
    local nearest = nil
    local nearestDist = math.huge
    
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
-- 💥 M1 SPAM
-- ═══════════════════════════════════════
local m1Active = false

local function startM1Spam()
    if m1Active then return end
    m1Active = true
    
    spawn(function()
        while m1Active and getgenv().BFF_FARM_ACTIVE do
            pcall(function()
                -- كليك في منتصف الشاشة (على العدو تحت)
                local vs = Camera.ViewportSize
                local centerX = vs.X / 2
                local centerY = vs.Y / 2
                
                VIM:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
                VIM:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
            end)
            wait(M1_SPEED)
        end
    end)
end

local function stopM1Spam()
    m1Active = false
end

-- ═══════════════════════════════════════
-- Anti-Death
-- ═══════════════════════════════════════
LocalPlayer.CharacterAdded:Connect(function()
    stopFlight()
    stopM1Spam()
    unlockCamera()
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
                stopM1Spam()
                unlockCamera()
                wait(2)
                return
            end
            
            equipWeapon()
            
            local targetName, islandName = getTarget()
            local enemy = findEnemy(targetName)
            
            if not enemy then
                stopM1Spam()
                unlockCamera()
                local islandPos = ISLANDS[islandName]
                if islandPos then
                    local dist = (hrp.Position - islandPos).Magnitude
                    if dist > 500 then
                        print("✈️ [BFF] Fly to: " .. islandName)
                        flyToIsland(islandPos)
                    else
                        wait(2)
                    end
                end
                return
            end
            
            print("⚔️ [BFF] Target: " .. targetName)
            
            local eHRP = enemy:FindFirstChild("HumanoidRootPart")
            local eHum = enemy:FindFirstChildOfClass("Humanoid")
            if not eHRP or not eHum then return end
            
            -- 🎯 وسّع Hitbox
            expandHitbox(enemy)
            
            -- 🎯 ثبت الكاميرا على العدو
            cameraTarget = enemy
            lockCameraOnTarget()
            
            -- 🚀 طير فوق العدو
            local bv, bg = createFlight()
            if not bv then return end
            
            -- 💥 M1 Spam
            startM1Spam()
            
            local killStart = tick()
            
            while enemy and enemy.Parent and eHum and eHum.Health > 0 
                  and getgenv().BFF_FARM_ACTIVE do
                if not eHRP.Parent then break end
                if (tick() - killStart) > 15 then break end
                
                -- ثبت فوق العدو مباشرة (بدون إزاحة أفقية!)
                local targetPos = eHRP.Position + Vector3.new(0, ATTACK_HEIGHT, 0)
                local myPos = hrp.Position
                local diff = (targetPos - myPos)
                
                if diff.Magnitude > 1 then
                    bv.Velocity = diff.Unit * math.min(200, diff.Magnitude * 15)
                else
                    bv.Velocity = Vector3.new(0, 0, 0)
                end
                
                -- اللاعب ينظر تحت للعدو
                bg.CFrame = CFrame.new(myPos, eHRP.Position)
                
                -- كرر Hitbox
                expandHitbox(enemy)
                
                wait(0.03)
            end
            
            stopM1Spam()
            unlockCamera()
            print("💀 [BFF] Killed: " .. targetName)
        end)
        
        if not success then
            warn("⚠️ [BFF] " .. tostring(err))
        end
        
        wait(0.2)
    end
end)

print("✅ [BFF v8.0] PRECISION M1 READY!")

StarterGui:SetCore("SendNotification", {
    Title = "✅ BFF v8.0";
    Text = "كاميرا موجهة + Hitbox 120!";
    Duration = 5;
})
