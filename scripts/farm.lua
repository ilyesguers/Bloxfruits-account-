--[[
    ══════════════════════════════════════════════
    🔥 BFF FARM v5.0 - MELEE EXTENDED 🔥
    ══════════════════════════════════════════════
    - نطاق الهجوم موسّع للماكس
    - يبقى قريب من العدو تماماً
    - Hitbox Expander
    - Auto Skills
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
-- الإعدادات
-- ═══════════════════════════════════════
local FLY_SPEED = 200
local FLY_HEIGHT = 100        -- لما ينتقل بين الجزر
local ATTACK_HEIGHT = 3       -- قريب جداً من العدو (كان 15)
local HITBOX_SIZE = 60        -- Hitbox موسّع

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
    Title = "🔥 BFF Farm v5.0";
    Text = "Melee Extended - بدأ!";
    Duration = 3;
})

print("╔═══════════════════════════════════╗")
print("║  🔥 BFF FARM v5.0 - MELEE EXT   ║")
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
-- 💥 HITBOX EXPANDER - يوسع نطاق الضربة!
-- ═══════════════════════════════════════
local function expandHitbox(enemy)
    if not enemy then return end
    local eHRP = enemy:FindFirstChild("HumanoidRootPart")
    if not eHRP then return end
    
    pcall(function()
        eHRP.Size = Vector3.new(HITBOX_SIZE, HITBOX_SIZE, HITBOX_SIZE)
        eHRP.Transparency = 0.7
        eHRP.Massless = true
        eHRP.CanCollide = false
    end)
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
-- نظام الطيران
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

-- ═══════════════════════════════════════
-- طيران لجزيرة (مرتفع)
-- ═══════════════════════════════════════
local function flyToIsland(targetPos)
    local hrp = getHRP()
    if not hrp then return end
    
    local bv, bg = createFlight()
    if not bv then return end
    
    local startTime = tick()
    while getgenv().BFF_FARM_ACTIVE and (tick() - startTime) < 30 do
        if not hrp or not hrp.Parent then break end
        
        local currentPos = hrp.Position
        
        -- ارفع أولاً
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
-- 💥 الهجوم بالكليك (Melee)
-- ═══════════════════════════════════════
local function attack()
    pcall(function()
        VIM:SendMouseButtonEvent(500, 500, 0, true, game, 1)
        wait(0.02)
        VIM:SendMouseButtonEvent(500, 500, 0, false, game, 1)
    end)
end

-- ═══════════════════════════════════════
-- الهجوم بالمهارات (Z, X, C)
-- ═══════════════════════════════════════
local skills = {Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V, Enum.KeyCode.F}
local skillIndex = 1

local function useSkill()
    pcall(function()
        local key = skills[skillIndex]
        VIM:SendKeyEvent(true, key, false, game)
        wait(0.05)
        VIM:SendKeyEvent(false, key, false, game)
        
        skillIndex = skillIndex + 1
        if skillIndex > #skills then skillIndex = 1 end
    end)
end

-- ═══════════════════════════════════════
-- Anti-Death
-- ═══════════════════════════════════════
LocalPlayer.CharacterAdded:Connect(function()
    stopFlight()
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
            
            equipWeapon()
            
            local targetName, islandName = getTarget()
            local enemy = findEnemy(targetName)
            
            if not enemy then
                local islandPos = ISLANDS[islandName]
                if islandPos then
                    local dist = (hrp.Position - islandPos).Magnitude
                    if dist > 500 then
                        print("✈️ [BFF] الطيران إلى: " .. islandName)
                        flyToIsland(islandPos)
                    else
                        wait(2)
                    end
                end
                return
            end
            
            print("⚔️ [BFF] مهاجمة: " .. targetName)
            
            local eHRP = enemy:FindFirstChild("HumanoidRootPart")
            local eHum = enemy:FindFirstChildOfClass("Humanoid")
            if not eHRP or not eHum then return end
            
            -- 💥 وسع Hitbox العدو
            expandHitbox(enemy)
            
            -- طيران للعدو
            local bv, bg = createFlight()
            if not bv then return end
            
            local killStart = tick()
            local attackCount = 0
            
            while enemy and enemy.Parent and eHum and eHum.Health > 0 
                  and getgenv().BFF_FARM_ACTIVE do
                if not eHRP.Parent then break end
                if (tick() - killStart) > 20 then break end
                
                -- 🎯 التصق بالعدو (خلف رأسه)
                local targetPos = eHRP.Position + Vector3.new(0, ATTACK_HEIGHT, 0)
                local myPos = hrp.Position
                local diff = (targetPos - myPos)
                local dist = diff.Magnitude
                
                if dist > 2 then
                    -- تحرك بسرعة نحوه
                    bv.Velocity = diff.Unit * math.min(150, dist * 10)
                else
                    -- ثبت على العدو
                    bv.Velocity = Vector3.new(0, 0, 0)
                    hrp.CFrame = CFrame.new(targetPos)
                end
                
                bg.CFrame = CFrame.new(myPos, eHRP.Position)
                
                -- 💥 اضرب!
                attack()
                
                -- استخدم مهارة كل 5 ضربات
                attackCount = attackCount + 1
                if attackCount % 5 == 0 then
                    useSkill()
                end
                
                -- وسع Hitbox باستمرار (اللعبة تعيدها)
                expandHitbox(enemy)
                
                wait(0.1)
            end
            
            print("💀 [BFF] Killed: " .. targetName)
            stopFlight()
        end)
        
        if not success then
            warn("⚠️ [BFF] " .. tostring(err))
        end
        
        wait(0.3)
    end
end)

print("✅ [BFF FARM v5.0] READY - Melee Extended")

StarterGui:SetCore("SendNotification", {
    Title = "✅ BFF v5.0";
    Text = "Hitbox موسّع + قريب من العدو";
    Duration = 5;
})
