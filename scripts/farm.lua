--[[
    ══════════════════════════════════════════════
    🔥 BFF FARM v14.0 - ZERO COOLDOWN 🔥
    ══════════════════════════════════════════════
    - 20 ضربة/ثانية (الحد الأقصى!)
    - Cooldown Bypass
    - Direct Remote Damage
    - تحت الأرض (آمن)
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
local UNDERGROUND_OFFSET = -5
local ATTACK_SPEED = 0.05      -- 20 ضربة/ثانية (الحد الأقصى الآمن!)

-- ═══════════════════════════════════════
-- الجزر والأعداء
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
    Title = "🔥 BFF v14.0";
    Text = "20 ضربة/ثانية - Zero Cooldown!";
    Duration = 3;
})

print("╔═══════════════════════════════════╗")
print("║  🔥 BFF v14.0 - ZERO COOLDOWN   ║")
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
-- 💥 COOLDOWN BYPASS - المفتاح السحري!
-- ═══════════════════════════════════════
spawn(function()
    while wait(0.05) do
        pcall(function()
            -- 1. Combat Framework Module
            local combatMod = LocalPlayer.PlayerScripts:FindFirstChild("CombatFramework", true)
            if combatMod then
                for _, v in pairs(getgc(true)) do
                    if type(v) == "table" and rawget(v, "activeController") then
                        if v.activeController then
                            v.activeController.AttackCooldown = 0
                            v.activeController.hitboxMagnitude = 100  -- نطاق الضربة موسع!
                            v.activeController.timeToNextAttack = 0
                        end
                    end
                    if type(v) == "table" and rawget(v, "AttackCooldown") then
                        v.AttackCooldown = 0
                    end
                    if type(v) == "table" and rawget(v, "timeToNextAttack") then
                        v.timeToNextAttack = 0
                    end
                end
            end
        end)
    end
end)

-- ═══════════════════════════════════════
-- 💥 CAMERA HOOK - وجّه الكاميرا دايماً
-- ═══════════════════════════════════════
local currentTarget = nil

spawn(function()
    while getgenv().BFF_FARM_ACTIVE do
        pcall(function()
            if currentTarget and currentTarget.Parent then
                local eHRP = currentTarget:FindFirstChild("HumanoidRootPart")
                if eHRP then
                    Camera.CFrame = CFrame.new(
                        eHRP.Position + Vector3.new(0, 15, 10),
                        eHRP.Position
                    )
                    Mouse.Hit = eHRP.CFrame
                    Mouse.Target = eHRP
                end
            end
        end)
        RunService.RenderStepped:Wait()
    end
end)

-- ═══════════════════════════════════════
-- 💥 ULTRA FAST M1 SPAMMER
-- ═══════════════════════════════════════
local clickActive = false

local function startUltraM1()
    if clickActive then return end
    clickActive = true
    
    -- Thread 1: Virtual Click
    spawn(function()
        while clickActive and getgenv().BFF_FARM_ACTIVE do
            pcall(function()
                local vs = Camera.ViewportSize
                VIM:SendMouseButtonEvent(vs.X/2, vs.Y/2, 0, true, game, 0)
                VIM:SendMouseButtonEvent(vs.X/2, vs.Y/2, 0, false, game, 0)
            end)
            wait(ATTACK_SPEED)
        end
    end)
    
    -- Thread 2: Tool Activate
    spawn(function()
        while clickActive and getgenv().BFF_FARM_ACTIVE do
            pcall(function()
                local tool = getEquippedTool()
                if tool then
                    tool:Activate()
                end
            end)
            wait(ATTACK_SPEED)
        end
    end)
    
    -- Thread 3: Combat Framework Direct Call
    spawn(function()
        while clickActive and getgenv().BFF_FARM_ACTIVE do
            pcall(function()
                for _, v in pairs(getgc(true)) do
                    if type(v) == "table" and rawget(v, "attack") and rawget(v, "activeController") then
                        if v.activeController and v.activeController.attack then
                            v.activeController:attack()
                        end
                    end
                end
            end)
            wait(ATTACK_SPEED)
        end
    end)
end

local function stopUltraM1()
    clickActive = false
end

-- ═══════════════════════════════════════
-- 🎬 Animation Speed
-- ═══════════════════════════════════════
spawn(function()
    while getgenv().BFF_FARM_ACTIVE do
        pcall(function()
            local hum = getHumanoid()
            if hum then
                for _, track in pairs(hum:GetPlayingAnimationTracks()) do
                    local n = track.Name:lower()
                    if n:find("attack") or n:find("combat") or n:find("punch") 
                       or n:find("slash") or n:find("hit") or n:find("swing") then
                        track:AdjustSpeed(5)
                    end
                end
            end
        end)
        wait(0.05)
    end
end)

-- ═══════════════════════════════════════
-- Anti-Death
-- ═══════════════════════════════════════
LocalPlayer.CharacterAdded:Connect(function()
    stopUltraM1()
    currentTarget = nil
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
                stopUltraM1()
                currentTarget = nil
                wait(2)
                return
            end
            
            local tool = equipWeapon()
            if not tool then wait(2); return end
            
            local targetName, islandName = getTarget()
            local enemy = findEnemy(targetName)
            
            if not enemy then
                stopUltraM1()
                currentTarget = nil
                local islandCF = ISLANDS[islandName]
                if islandCF then
                    print("✈️ [BFF] Teleport: " .. islandName)
                    hrp.CFrame = islandCF
                    wait(2)
                end
                return
            end
            
            print("⚔️ [BFF] TARGET: " .. targetName)
            
            local eHRP = enemy:FindFirstChild("HumanoidRootPart")
            local eHum = enemy:FindFirstChildOfClass("Humanoid")
            if not eHRP or not eHum then return end
            
            -- 🎯 تعيين الهدف الحالي
            currentTarget = enemy
            
            -- 🚀 ابدأ Ultra M1
            startUltraM1()
            
            local killStart = tick()
            
            -- 💥 حلقة اللصق تحت الأرض
            local positionConnection
            positionConnection = RunService.Heartbeat:Connect(function()
                if not (enemy and enemy.Parent and eHum and eHum.Health > 0 
                        and getgenv().BFF_FARM_ACTIVE and eHRP.Parent) then
                    if positionConnection then positionConnection:Disconnect() end
                    return
                end
                
                if (tick() - killStart) > 15 then
                    if positionConnection then positionConnection:Disconnect() end
                    return
                end
                
                pcall(function()
                    -- تحت الأرض بجنب العدو
                    hrp.CFrame = eHRP.CFrame * CFrame.new(0, UNDERGROUND_OFFSET, 0)
                end)
            end)
            
            -- انتظر حتى يموت
            while enemy and enemy.Parent and eHum and eHum.Health > 0 
                  and getgenv().BFF_FARM_ACTIVE do
                if (tick() - killStart) > 15 then break end
                wait(0.1)
            end
            
            if positionConnection then positionConnection:Disconnect() end
            stopUltraM1()
            currentTarget = nil
            print("💀 [BFF] KILLED: " .. targetName)
        end)
        
        if not success then
            warn("⚠️ [BFF] " .. tostring(err))
        end
        
        wait(0.2)
    end
end)

print("✅ [BFF v14.0] ZERO COOLDOWN READY!")

StarterGui:SetCore("SendNotification", {
    Title = "✅ BFF v14.0";
    Text = "20 ضربة/ثانية!";
    Duration = 5;
})
