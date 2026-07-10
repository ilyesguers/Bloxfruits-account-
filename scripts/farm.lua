--[[
    ══════════════════════════════════════════════════════════════
    🔥 BFF FARM v16.0 - UPDATE 24 COMPLETE EDITION 🔥
    ══════════════════════════════════════════════════════════════
    
    ✅ كل الأعداء محدثين (Level 1 → 2550+) - Update 24
    ✅ 3 عوالم (Sea 1, Sea 2, Sea 3) مع إحداثيات صحيحة
    ✅ انتقال تلقائي ذكي بين البحار
    ✅ حركة داخل الجزيرة لتحفيز Spawn
    ✅ نظام هجوم محسّن لـ iPhone 13
    ✅ Underground Safe Mode
    ✅ تحسين الذاكرة والأداء
    ✅ Anti-Death Recovery
    ✅ Smart Target Selection
    ✅ Quest Auto-Accept
    ✅ تحميل أقل على المعالج
    
    📱 مُحسّن خصيصاً لـ Delta Executor على iPhone 13
    ══════════════════════════════════════════════════════════════
]]

-- ═══════════════════════════════════════════════════════════
-- 🛡️ حماية من التشغيل المزدوج
-- ═══════════════════════════════════════════════════════════
if getgenv().BFF_FARM_ACTIVE then
    warn("⚠️ [FARM] الفارم شغال بالفعل!")
    return
end
getgenv().BFF_FARM_ACTIVE = true
getgenv().BFF_FARM_VERSION = "16.0"

-- ═══════════════════════════════════════════════════════════
-- 📦 تحميل الخدمات
-- ═══════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local VIM = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ═══════════════════════════════════════════════════════════
-- ⚙️ إعدادات الفارم
-- ═══════════════════════════════════════════════════════════
local FARM_CONFIG = {
    -- الهجوم
    UNDERGROUND_OFFSET    = -5,         -- عمق تحت الأرض
    ATTACK_SPEED          = 0.08,       -- سرعة الهجوم (0.05 سريع جداً = يعلق iPhone)
    KILL_TIMEOUT          = 20,         -- أقصى وقت لقتل عدو واحد (ثواني)
    
    -- الحركة والبحث
    SPAWN_MOVE_RADIUS     = 80,         -- نطاق الحركة داخل الجزيرة
    TELEPORT_HEIGHT       = 25,         -- ارتفاع الطيران
    SEARCH_WAIT           = 1.5,        -- انتظار بعد كل تحرك للبحث
    
    -- الأداء (مهم لـ iPhone 13)
    GC_BYPASS_INTERVAL    = 0.15,       -- تقليل استدعاء getgc (كان 0.05 = ثقيل جداً)
    GC_BYPASS_ENABLED     = true,       -- تفعيل/تعطيل الـ Cooldown Bypass
    ANIMATION_SPEED       = 3,          -- سرعة الأنيميشن (كان 5 = يسبب مشاكل)
    
    -- الانتقال بين البحار
    SEA_TRAVEL_WAIT       = 8,          -- انتظار بعد الانتقال
    
    -- Quest
    QUEST_ENABLED         = true,       -- تفعيل أخذ الـ Quest تلقائياً
}

-- ═══════════════════════════════════════════════════════════
-- 📢 نظام الإشعارات والتسجيل
-- ═══════════════════════════════════════════════════════════
local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "BFF Farm",
            Text = text or "",
            Duration = duration or 5,
        })
    end)
end

local function log(message)
    local timestamp = os.date("%H:%M:%S")
    print(string.format("[%s] ⚔️ FARM | %s", timestamp, message))
end

-- ═══════════════════════════════════════════════════════════
-- 🌊 تحديد البحر الحالي
-- ═══════════════════════════════════════════════════════════
local SEA_PLACE_IDS = {
    [2753915549]  = 1,   -- Sea 1 (Starter)
    [4442272183]  = 2,   -- Sea 2 (New World)
    [7449423635]  = 3,   -- Sea 3 (Third Sea)
}

local function getCurrentSea()
    return SEA_PLACE_IDS[game.PlaceId] or 1
end

local function getSeaName(seaNum)
    local names = {
        [1] = "Sea 1 (Old World)",
        [2] = "Sea 2 (New World)",
        [3] = "Sea 3 (Third Sea)",
    }
    return names[seaNum] or "Unknown"
end

-- ═══════════════════════════════════════════════════════════
-- 🗺️ إحداثيات الجزر (محدثة - Update 24)
-- ═══════════════════════════════════════════════════════════
local ISLANDS = {
    -- ══════════════════════════════════════
    -- 🌊 SEA 1 - Old World
    -- ══════════════════════════════════════
    ["Starter Island"]     = CFrame.new(1071, 16, 1426),
    ["Jungle"]             = CFrame.new(-1601, 40, 153),
    ["Pirate Village"]     = CFrame.new(-1181, 10, 3803),
    ["Desert"]             = CFrame.new(1094, 10, 4287),
    ["Frozen Village"]     = CFrame.new(1213, 130, -1183),
    ["Marine Fortress"]    = CFrame.new(-4842, 25, 4324),
    ["Sky Island"]         = CFrame.new(-4970, 725, -2622),
    ["Prison"]             = CFrame.new(4875, 10, 734),
    ["Colosseum"]          = CFrame.new(-1428, 15, -3014),
    ["Magma Village"]      = CFrame.new(-5316, 20, 8517),
    ["Underwater City"]    = CFrame.new(61163, 11, 1819),
    ["Upper Skylands"]     = CFrame.new(-7862, 5545, -380),
    ["Fountain City"]      = CFrame.new(5127, 4, 4105),
    
    -- ══════════════════════════════════════
    -- 🌊 SEA 2 - New World
    -- ══════════════════════════════════════
    ["Kingdom of Rose"]    = CFrame.new(-427, 72, 1836),
    ["Green Zone"]         = CFrame.new(-2842, 100, 5320),
    ["Graveyard"]          = CFrame.new(-5390, 46, -793),
    ["Snow Mountain"]      = CFrame.new(597, 401, -5371),
    ["Hot and Cold"]       = CFrame.new(-5686, 8, -5254),
    ["Cursed Ship"]        = CFrame.new(923, 125, 32844),
    ["Ice Castle"]         = CFrame.new(6148, 294, -6741),
    ["Forgotten Island"]   = CFrame.new(-3055, 250, -10147),
    ["Dark Arena"]         = CFrame.new(-3788, 10, -3608),
    
    -- ══════════════════════════════════════
    -- 🌊 SEA 3 - Third Sea
    -- ══════════════════════════════════════
    ["Port Town"]          = CFrame.new(-291, 44, 5580),
    ["Hydra Island"]       = CFrame.new(5228, 604, 345),
    ["Great Tree"]         = CFrame.new(2192, 28, -6960),
    ["Castle on Sea"]      = CFrame.new(-5087, 315, -3153),
    ["Floating Turtle"]    = CFrame.new(-13232, 332, -7626),
    ["Haunted Castle"]     = CFrame.new(-9515, 142, 5548),
    ["Tiki Outpost"]       = CFrame.new(-12038, 332, -8412),
    ["Mansion"]            = CFrame.new(-12568, 332, -7536),
}

-- ═══════════════════════════════════════════════════════════
-- 👹 قاعدة بيانات الأعداء الكاملة (Update 24)
-- ═══════════════════════════════════════════════════════════
--[[
    كل عدو له:
    - min/max: نطاق الليفل المناسب
    - name: اسم العدو بالضبط كما في اللعبة
    - island: اسم الجزيرة
    - sea: رقم البحر (1, 2, 3)
    - questNPC: اسم NPC الـ Quest (إن وُجد)
    - questName: اسم المهمة (إن وُجد)
]]

local ENEMIES = {
    -- ══════════════════════════════════════════════════════
    -- 🌊 SEA 1 (Level 1 → 700)
    -- ══════════════════════════════════════════════════════
    
    -- Starter Island (غير مستخدم - مافي أعداء مناسبين)
    
    -- Jungle
    {min = 1,    max = 9,    name = "Bandit",               island = "Jungle",           sea = 1, questNPC = "Bandit Quest"},
    {min = 10,   max = 14,   name = "Monkey",               island = "Jungle",           sea = 1, questNPC = "Monkey Quest"},
    {min = 15,   max = 29,   name = "Gorilla",              island = "Jungle",           sea = 1, questNPC = "Gorilla Quest"},
    
    -- Pirate Village
    {min = 30,   max = 39,   name = "Pirate",               island = "Pirate Village",   sea = 1, questNPC = "Pirate Quest"},
    {min = 40,   max = 59,   name = "Brute",                island = "Pirate Village",   sea = 1, questNPC = "Brute Quest"},
    
    -- Desert
    {min = 60,   max = 74,   name = "Desert Bandit",        island = "Desert",           sea = 1, questNPC = "Desert Quest"},
    {min = 75,   max = 89,   name = "Desert Officer",       island = "Desert",           sea = 1, questNPC = "Desert Officer Quest"},
    
    -- Frozen Village
    {min = 90,   max = 104,  name = "Snow Bandit",          island = "Frozen Village",   sea = 1, questNPC = "Snow Bandit Quest"},
    {min = 105,  max = 119,  name = "Snowman",              island = "Frozen Village",   sea = 1, questNPC = "Snowman Quest"},
    
    -- Marine Fortress
    {min = 120,  max = 149,  name = "Chief Petty Officer",  island = "Marine Fortress",  sea = 1, questNPC = "Chief Petty Officer Quest"},
    
    -- Sky Island
    {min = 150,  max = 174,  name = "Sky Bandit",           island = "Sky Island",       sea = 1, questNPC = "Sky Bandit Quest"},
    {min = 175,  max = 189,  name = "Dark Master",          island = "Sky Island",       sea = 1, questNPC = "Dark Master Quest"},
    
    -- Prison
    {min = 190,  max = 209,  name = "Prisoner",             island = "Prison",           sea = 1, questNPC = "Prisoner Quest"},
    {min = 210,  max = 249,  name = "Dangerous Prisoner",   island = "Prison",           sea = 1, questNPC = "Dangerous Prisoner Quest"},
    
    -- Colosseum
    {min = 250,  max = 274,  name = "Toga Warrior",         island = "Colosseum",        sea = 1, questNPC = "Toga Warrior Quest"},
    {min = 275,  max = 299,  name = "Gladiator",            island = "Colosseum",        sea = 1, questNPC = "Gladiator Quest"},
    
    -- Magma Village
    {min = 300,  max = 324,  name = "Military Soldier",     island = "Magma Village",    sea = 1, questNPC = "Military Soldier Quest"},
    {min = 325,  max = 374,  name = "Military Spy",         island = "Magma Village",    sea = 1, questNPC = "Military Spy Quest"},
    
    -- Underwater City
    {min = 375,  max = 399,  name = "Fishman Warrior",      island = "Underwater City",  sea = 1, questNPC = "Fishman Warrior Quest"},
    {min = 400,  max = 449,  name = "Fishman Commando",     island = "Underwater City",  sea = 1, questNPC = "Fishman Commando Quest"},
    
    -- Upper Skylands
    {min = 450,  max = 474,  name = "God's Guard",          island = "Upper Skylands",   sea = 1, questNPC = "God's Guard Quest"},
    {min = 475,  max = 524,  name = "Shanda",               island = "Upper Skylands",   sea = 1, questNPC = "Shanda Quest"},
    
    -- Fountain City
    {min = 525,  max = 549,  name = "Royal Squad",          island = "Fountain City",    sea = 1, questNPC = "Royal Squad Quest"},
    {min = 550,  max = 624,  name = "Royal Soldier",        island = "Fountain City",    sea = 1, questNPC = "Royal Soldier Quest"},
    {min = 625,  max = 699,  name = "Galley Pirate",        island = "Fountain City",    sea = 1, questNPC = "Galley Pirate Quest"},
    
    -- ══════════════════════════════════════════════════════
    -- 🌊 SEA 2 (Level 700 → 1500)
    -- ══════════════════════════════════════════════════════
    
    -- Kingdom of Rose
    {min = 700,  max = 774,  name = "Raider",               island = "Kingdom of Rose",  sea = 2, questNPC = "Raider Quest"},
    {min = 775,  max = 824,  name = "Mercenary",            island = "Kingdom of Rose",  sea = 2, questNPC = "Mercenary Quest"},
    
    -- Green Zone
    {min = 825,  max = 874,  name = "Swan Pirate",          island = "Green Zone",       sea = 2, questNPC = "Swan Pirate Quest"},
    {min = 875,  max = 924,  name = "Factory Staff",        island = "Green Zone",       sea = 2, questNPC = "Factory Staff Quest"},
    
    -- Graveyard
    {min = 925,  max = 949,  name = "Marine Lieutenant",    island = "Graveyard",        sea = 2, questNPC = "Marine Lieutenant Quest"},
    {min = 950,  max = 974,  name = "Marine Captain",       island = "Graveyard",        sea = 2, questNPC = "Marine Captain Quest"},
    {min = 975,  max = 999,  name = "Zombie",               island = "Graveyard",        sea = 2, questNPC = "Zombie Quest"},
    {min = 1000, max = 1049, name = "Vampire",              island = "Graveyard",        sea = 2, questNPC = "Vampire Quest"},
    
    -- Snow Mountain
    {min = 1050, max = 1099, name = "Snow Trooper",         island = "Snow Mountain",    sea = 2, questNPC = "Snow Trooper Quest"},
    {min = 1100, max = 1124, name = "Winter Warrior",       island = "Snow Mountain",    sea = 2, questNPC = "Winter Warrior Quest"},
    
    -- Hot and Cold
    {min = 1125, max = 1174, name = "Lab Subordinate",      island = "Hot and Cold",     sea = 2, questNPC = "Lab Subordinate Quest"},
    {min = 1175, max = 1199, name = "Horned Warrior",       island = "Hot and Cold",     sea = 2, questNPC = "Horned Warrior Quest"},
    {min = 1200, max = 1249, name = "Magma Ninja",          island = "Hot and Cold",     sea = 2, questNPC = "Magma Ninja Quest"},
    
    -- Cursed Ship
    {min = 1250, max = 1299, name = "Cursed Pirate",        island = "Cursed Ship",      sea = 2, questNPC = "Cursed Pirate Quest"},
    
    -- Ice Castle
    {min = 1300, max = 1349, name = "Ice Viking",           island = "Ice Castle",       sea = 2, questNPC = "Ice Viking Quest"},
    
    -- Forgotten Island
    {min = 1350, max = 1424, name = "Marine Commodore",     island = "Forgotten Island", sea = 2, questNPC = "Marine Commodore Quest"},
    {min = 1425, max = 1499, name = "Reborn Skeleton",      island = "Forgotten Island", sea = 2, questNPC = "Reborn Skeleton Quest"},
    
    -- ══════════════════════════════════════════════════════
    -- 🌊 SEA 3 (Level 1500 → 2550+)
    -- ══════════════════════════════════════════════════════
    
    -- Port Town
    {min = 1500, max = 1524, name = "Pirate Millionaire",   island = "Port Town",        sea = 3, questNPC = "Pirate Millionaire Quest"},
    {min = 1525, max = 1574, name = "Pistol Billionaire",   island = "Port Town",        sea = 3, questNPC = "Pistol Billionaire Quest"},
    
    -- Hydra Island
    {min = 1575, max = 1624, name = "Dragon Crew Warrior",  island = "Hydra Island",     sea = 3, questNPC = "Dragon Crew Warrior Quest"},
    {min = 1625, max = 1649, name = "Dragon Crew Archer",   island = "Hydra Island",     sea = 3, questNPC = "Dragon Crew Archer Quest"},
    
    -- Great Tree
    {min = 1650, max = 1699, name = "Female Islander",      island = "Great Tree",       sea = 3, questNPC = "Female Islander Quest"},
    {min = 1700, max = 1749, name = "Giant Islander",       island = "Great Tree",       sea = 3, questNPC = "Giant Islander Quest"},
    
    -- Castle on Sea
    {min = 1750, max = 1799, name = "Marine Commodore",     island = "Castle on Sea",    sea = 3, questNPC = "Marine Commodore Quest"},
    {min = 1800, max = 1849, name = "Marine Rear Admiral",  island = "Castle on Sea",    sea = 3, questNPC = "Marine Rear Admiral Quest"},
    
    -- Floating Turtle
    {min = 1850, max = 1899, name = "Fishman Raider",       island = "Floating Turtle",  sea = 3, questNPC = "Fishman Raider Quest"},
    {min = 1900, max = 1949, name = "Fishman Captain",      island = "Floating Turtle",  sea = 3, questNPC = "Fishman Captain Quest"},
    {min = 1950, max = 1999, name = "Forest Pirate",        island = "Floating Turtle",  sea = 3, questNPC = "Forest Pirate Quest"},
    {min = 2000, max = 2074, name = "Mythological Pirate",  island = "Floating Turtle",  sea = 3, questNPC = "Mythological Pirate Quest"},
    {min = 2075, max = 2099, name = "Jungle Pirate",        island = "Floating Turtle",  sea = 3, questNPC = "Jungle Pirate Quest"},
    {min = 2100, max = 2149, name = "Musketeer Pirate",     island = "Floating Turtle",  sea = 3, questNPC = "Musketeer Pirate Quest"},
    
    -- Haunted Castle
    {min = 2150, max = 2199, name = "Reborn Skeleton",      island = "Haunted Castle",   sea = 3, questNPC = "Reborn Skeleton Quest"},
    {min = 2200, max = 2249, name = "Living Zombie",        island = "Haunted Castle",   sea = 3, questNPC = "Living Zombie Quest"},
    {min = 2250, max = 2299, name = "Demonic Soul",         island = "Haunted Castle",   sea = 3, questNPC = "Demonic Soul Quest"},
    {min = 2300, max = 2349, name = "Posessed Mummy",       island = "Haunted Castle",   sea = 3, questNPC = "Posessed Mummy Quest"},
    
    -- Tiki Outpost (Update 20+)
    {min = 2350, max = 2399, name = "Peanut Scout",         island = "Tiki Outpost",     sea = 3, questNPC = "Peanut Scout Quest"},
    {min = 2400, max = 2449, name = "Peanut President",     island = "Tiki Outpost",     sea = 3, questNPC = "Peanut President Quest"},
    
    -- Mansion (Update 20+)
    {min = 2450, max = 2499, name = "Ice Cream Chef",       island = "Mansion",          sea = 3, questNPC = "Ice Cream Chef Quest"},
    {min = 2500, max = 2550, name = "Cookie Crafter",       island = "Mansion",          sea = 3, questNPC = "Cookie Crafter Quest"},
}

-- ═══════════════════════════════════════════════════════════
-- 🎬 إشعار البداية
-- ═══════════════════════════════════════════════════════════
notify("🔥 BFF Farm v16.0", "Update 24 | Level 1 → 2550+ | Sea 1,2,3", 5)

print("╔═══════════════════════════════════════════════╗")
print("║  🔥 BFF FARM v16.0 - UPDATE 24 EDITION      ║")
print("║  Level 1 → 2550+ | Sea 1, 2, 3              ║")
print("║  📱 Optimized for iPhone 13                  ║")
print("║  🌊 Current Sea: " .. getSeaName(getCurrentSea()))
print("╚═══════════════════════════════════════════════╝")

-- ═══════════════════════════════════════════════════════════
-- 🔧 دوال أساسية (Helper Functions)
-- ═══════════════════════════════════════════════════════════

local function getCharacter()
    local char = LocalPlayer.Character
    if char and char.Parent then
        return char
    end
    return LocalPlayer.CharacterAdded:Wait()
end

local function getHumanoidRootPart()
    local char = getCharacter()
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = getCharacter()
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

local function isAlive()
    local hum = getHumanoid()
    local hrp = getHumanoidRootPart()
    return hum and hrp and hum.Health > 0 and hrp.Parent
end

local function getPlayerLevel()
    local level = 1
    pcall(function()
        local data = LocalPlayer:FindFirstChild("Data")
        if data then
            local lvlObj = data:FindFirstChild("Level")
            if lvlObj then
                level = lvlObj.Value
            end
        end
    end)
    return level
end

local function getPlayerBeli()
    local beli = 0
    pcall(function()
        local data = LocalPlayer:FindFirstChild("Data")
        if data and data:FindFirstChild("Beli") then
            beli = data.Beli.Value
        end
    end)
    return beli
end

-- ═══════════════════════════════════════════════════════════
-- 🎯 اختيار العدو المناسب للليفل
-- ═══════════════════════════════════════════════════════════
local function getTargetInfo()
    local level = getPlayerLevel()
    
    -- ابحث عن العدو المناسب
    for _, enemy in ipairs(ENEMIES) do
        if level >= enemy.min and level <= enemy.max then
            return {
                name     = enemy.name,
                island   = enemy.island,
                sea      = enemy.sea,
                questNPC = enemy.questNPC,
                minLevel = enemy.min,
                maxLevel = enemy.max,
            }
        end
    end
    
    -- إذا الليفل أعلى من كل الأعداء، استخدم آخر عدو
    local lastEnemy = ENEMIES[#ENEMIES]
    return {
        name     = lastEnemy.name,
        island   = lastEnemy.island,
        sea      = lastEnemy.sea,
        questNPC = lastEnemy.questNPC,
        minLevel = lastEnemy.min,
        maxLevel = lastEnemy.max,
    }
end

-- ═══════════════════════════════════════════════════════════
-- 🚢 نظام الانتقال بين البحار
-- ═══════════════════════════════════════════════════════════
local function getRemote()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if not remotes then return nil end
    return remotes:FindFirstChild("CommF_")
end

local function travelToSea(targetSea)
    local currentSea = getCurrentSea()
    if currentSea == targetSea then return true end
    
    log("🚢 انتقال من " .. getSeaName(currentSea) .. " إلى " .. getSeaName(targetSea))
    notify("🚢 انتقال", getSeaName(currentSea) .. " → " .. getSeaName(targetSea), 5)
    
    local commF = getRemote()
    if not commF then
        log("❌ لم يتم العثور على Remote!")
        return false
    end
    
    local travelCommands = {
        [1] = "TravelMain",
        [2] = "TravelDressrosa",
        [3] = "TravelZou",
    }
    
    local command = travelCommands[targetSea]
    if not command then
        log("❌ أمر انتقال غير معروف للبحر " .. targetSea)
        return false
    end
    
    local success = false
    pcall(function()
        local result = commF:InvokeServer(command)
        if result then
            success = true
            log("✅ تم إرسال أمر الانتقال: " .. command)
        end
    end)
    
    -- انتظار الانتقال
    task.wait(FARM_CONFIG.SEA_TRAVEL_WAIT)
    
    return success
end

-- ═══════════════════════════════════════════════════════════
-- 🗡️ تجهيز السلاح
-- ═══════════════════════════════════════════════════════════
local function getEquippedTool()
    local char = getCharacter()
    if not char then return nil end
    for _, item in pairs(char:GetChildren()) do
        if item:IsA("Tool") then
            return item
        end
    end
    return nil
end

local function equipBestWeapon()
    -- أولاً تحقق إذا فيه سلاح مجهز
    local currentTool = getEquippedTool()
    if currentTool then return currentTool end
    
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return nil end
    
    -- أولوية الأسلحة (الأفضل أولاً)
    local priorityWeapons = {
        -- Fighting Styles (الأفضل للفارم)
        "Superhuman", "Death Step", "Electric Claw", "Dragon Talon",
        "Sharkman Karate", "Dragon Claw", "Fishman Karate",
        "Electro", "Black Leg", "Combat",
        -- Swords
        "Cursed Dual Katana", "Yama", "Tushita", "Buddy Sword",
        "True Triple Katana", "Pole v2", "Saber",
        "Katana", "Cutlass",
    }
    
    -- ابحث عن أفضل سلاح
    for _, weaponName in ipairs(priorityWeapons) do
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") and item.Name == weaponName then
                local hum = getHumanoid()
                if hum then
                    hum:EquipTool(item)
                    task.wait(0.3)
                    return item
                end
            end
        end
    end
    
    -- إذا ما لقى أي سلاح من القائمة، جهّز أي Tool
    for _, item in pairs(backpack:GetChildren()) do
        if item:IsA("Tool") then
            local hum = getHumanoid()
            if hum then
                hum:EquipTool(item)
                task.wait(0.3)
                return item
            end
        end
    end
    
    return nil
end

-- ═══════════════════════════════════════════════════════════
-- 🔍 البحث عن الأعداء
-- ═══════════════════════════════════════════════════════════
local function findNearestEnemy(targetName)
    local hrp = getHumanoidRootPart()
    if not hrp then return nil, math.huge end
    
    local nearest = nil
    local nearestDist = math.huge
    
    -- ابحث في مجلد الأعداء
    local enemiesFolder = Workspace:FindFirstChild("Enemies")
    if not enemiesFolder then return nil, math.huge end
    
    for _, enemy in pairs(enemiesFolder:GetChildren()) do
        if enemy.Name == targetName then
            local enemyHum = enemy:FindFirstChildOfClass("Humanoid")
            local enemyHRP = enemy:FindFirstChild("HumanoidRootPart")
            
            if enemyHum and enemyHRP and enemyHum.Health > 0 and enemyHRP.Parent then
                local distance = (hrp.Position - enemyHRP.Position).Magnitude
                if distance < nearestDist then
                    nearestDist = distance
                    nearest = enemy
                end
            end
        end
    end
    
    return nearest, nearestDist
end

local function countEnemies(targetName)
    local count = 0
    local enemiesFolder = Workspace:FindFirstChild("Enemies")
    if not enemiesFolder then return 0 end
    
    for _, enemy in pairs(enemiesFolder:GetChildren()) do
        if enemy.Name == targetName then
            local hum = enemy:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                count = count + 1
            end
        end
    end
    
    return count
end

-- ═══════════════════════════════════════════════════════════
-- 📜 نظام الـ Quest (أخذ المهمة تلقائياً)
-- ═══════════════════════════════════════════════════════════
local currentQuestTarget = nil
local currentQuestAmount = nil

local function hasActiveQuest()
    local hasQuest = false
    pcall(function()
        local questUI = LocalPlayer.PlayerGui:FindFirstChild("Main")
        if questUI then
            for _, obj in pairs(questUI:GetDescendants()) do
                if obj:IsA("TextLabel") and obj.Visible then
                    local text = obj.Text or ""
                    if text:find("Quest") or text:find("quest") or text:find("Defeat") 
                       or text:find("defeat") or text:find("Kill") or text:find("kill") then
                        hasQuest = true
                    end
                end
            end
        end
    end)
    return hasQuest
end

local function acceptQuest(targetInfo)
    if not FARM_CONFIG.QUEST_ENABLED then return end
    if not targetInfo.questNPC then return end
    
    -- ابحث عن NPC الـ Quest
    pcall(function()
        local commF = getRemote()
        if commF then
            -- طريقة 1: StartQuest
            pcall(function()
                commF:InvokeServer("StartQuest", targetInfo.questNPC, 1)
            end)
            
            -- طريقة 2: AcceptQuest
            pcall(function()
                commF:InvokeServer("AcceptQuest", targetInfo.questNPC)
            end)
        end
    end)
    
    -- ابحث عن NPC في اللعبة واضغط عليه
    pcall(function()
        for _, npc in pairs(Workspace:GetDescendants()) do
            if npc:IsA("Model") and npc.Name:find("Quest") then
                if npc.Name:lower():find(targetInfo.name:lower():sub(1, 5)) then
                    local npcHRP = npc:FindFirstChild("HumanoidRootPart") 
                                   or npc:FindFirstChild("Head")
                    if npcHRP then
                        local hrp = getHumanoidRootPart()
                        if hrp then
                            -- اقترب من NPC
                            hrp.CFrame = npcHRP.CFrame * CFrame.new(0, 0, 3)
                            task.wait(1)
                            
                            -- حاول التفاعل
                            pcall(function()
                                fireclickdetector(npc:FindFirstChildOfClass("ClickDetector"))
                            end)
                            pcall(function()
                                fireproximityprompt(npc:FindFirstChildOfClass("ProximityPrompt"))
                            end)
                        end
                    end
                end
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
-- 💥 نظام الهجوم (محسّن لـ iPhone 13)
-- ═══════════════════════════════════════════════════════════
local attackActive = false
local currentTarget = nil

-- M1 Spammer (محسّن)
local function startAttack()
    if attackActive then return end
    attackActive = true
    
    -- Thread 1: Virtual Mouse Click
    spawn(function()
        while attackActive and getgenv().BFF_FARM_ACTIVE do
            pcall(function()
                local viewportSize = Camera.ViewportSize
                local centerX = viewportSize.X / 2
                local centerY = viewportSize.Y / 2
                VIM:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
                task.wait(0.02)
                VIM:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
            end)
            task.wait(FARM_CONFIG.ATTACK_SPEED)
        end
    end)
    
    -- Thread 2: Tool Activate
    spawn(function()
        while attackActive and getgenv().BFF_FARM_ACTIVE do
            pcall(function()
                local tool = getEquippedTool()
                if tool then
                    tool:Activate()
                end
            end)
            task.wait(FARM_CONFIG.ATTACK_SPEED)
        end
    end)
end

local function stopAttack()
    attackActive = false
end

-- ═══════════════════════════════════════════════════════════
-- 🎬 تسريع الأنيميشن
-- ═══════════════════════════════════════════════════════════
spawn(function()
    while getgenv().BFF_FARM_ACTIVE do
        pcall(function()
            local hum = getHumanoid()
            if hum then
                for _, track in pairs(hum:GetPlayingAnimationTracks()) do
                    local trackName = track.Name:lower()
                    if trackName:find("attack") or trackName:find("combat") 
                       or trackName:find("punch") or trackName:find("slash") 
                       or trackName:find("hit") or trackName:find("swing") then
                        track:AdjustSpeed(FARM_CONFIG.ANIMATION_SPEED)
                    end
                end
            end
        end)
        task.wait(0.1)
    end
end)

-- ═══════════════════════════════════════════════════════════
-- 💥 Cooldown Bypass (محسّن للأداء)
-- ═══════════════════════════════════════════════════════════
if FARM_CONFIG.GC_BYPASS_ENABLED then
    spawn(function()
        while getgenv().BFF_FARM_ACTIVE do
            pcall(function()
                if typeof(getgc) == "function" then
                    for _, v in pairs(getgc(true)) do
                        if type(v) == "table" then
                            local ok1, _ = pcall(function()
                                if rawget(v, "AttackCooldown") then
                                    v.AttackCooldown = 0
                                end
                            end)
                            
                            local ok2, _ = pcall(function()
                                if rawget(v, "timeToNextAttack") then
                                    v.timeToNextAttack = 0
                                end
                            end)
                            
                            local ok3, _ = pcall(function()
                                if rawget(v, "activeController") and v.activeController then
                                    if v.activeController.AttackCooldown then
                                        v.activeController.AttackCooldown = 0
                                    end
                                    if v.activeController.timeToNextAttack then
                                        v.activeController.timeToNextAttack = 0
                                    end
                                end
                            end)
                        end
                    end
                end
            end)
            task.wait(FARM_CONFIG.GC_BYPASS_INTERVAL)
        end
    end)
    log("✅ Cooldown Bypass مفعّل (Interval: " .. FARM_CONFIG.GC_BYPASS_INTERVAL .. "s)")
end

-- ═══════════════════════════════════════════════════════════
-- 📷 توجيه الكاميرا نحو العدو
-- ═══════════════════════════════════════════════════════════
spawn(function()
    while getgenv().BFF_FARM_ACTIVE do
        pcall(function()
            if currentTarget and currentTarget.Parent then
                local enemyHRP = currentTarget:FindFirstChild("HumanoidRootPart")
                if enemyHRP and enemyHRP.Parent then
                    Camera.CFrame = CFrame.new(
                        enemyHRP.Position + Vector3.new(0, 12, 8),
                        enemyHRP.Position
                    )
                end
            end
        end)
        RunService.RenderStepped:Wait()
    end
end)

-- ═══════════════════════════════════════════════════════════
-- 🚶 حركة داخل الجزيرة (لتحفيز Spawn)
-- ═══════════════════════════════════════════════════════════
local function wanderInIsland(islandCFrame, targetName)
    local hrp = getHumanoidRootPart()
    if not hrp then return false end
    
    log("🚶 البحث داخل الجزيرة عن " .. targetName .. "...")
    
    -- تحرك في 8 اتجاهات لتحفيز الـ Spawn
    local radius = FARM_CONFIG.SPAWN_MOVE_RADIUS
    local directions = {
        Vector3.new(radius, 0, 0),
        Vector3.new(-radius, 0, 0),
        Vector3.new(0, 0, radius),
        Vector3.new(0, 0, -radius),
        Vector3.new(radius * 0.7, 0, radius * 0.7),
        Vector3.new(-radius * 0.7, 0, radius * 0.7),
        Vector3.new(radius * 0.7, 0, -radius * 0.7),
        Vector3.new(-radius * 0.7, 0, -radius * 0.7),
    }
    
    for _, direction in ipairs(directions) do
        if not getgenv().BFF_FARM_ACTIVE then return false end
        
        pcall(function()
            local newPos = islandCFrame.Position + direction + Vector3.new(0, FARM_CONFIG.TELEPORT_HEIGHT, 0)
            hrp.CFrame = CFrame.new(newPos)
        end)
        
        task.wait(FARM_CONFIG.SEARCH_WAIT)
        
        -- تحقق من الأعداء
        local enemy = findNearestEnemy(targetName)
        if enemy then
            log("✅ وجدت عدو بعد التحرك!")
            return true
        end
    end
    
    return false
end

-- ═══════════════════════════════════════════════════════════
-- 🔄 Anti-Death Recovery
-- ═══════════════════════════════════════════════════════════
LocalPlayer.CharacterAdded:Connect(function(newChar)
    stopAttack()
    currentTarget = nil
    
    log("🔄 الشخصية ماتت - انتظار Respawn...")
    
    newChar:WaitForChild("Humanoid", 30)
    newChar:WaitForChild("HumanoidRootPart", 30)
    
    task.wait(3)
    log("✅ Respawn ناجح - استئناف الفارم!")
end)

-- ═══════════════════════════════════════════════════════════
-- 📊 عداد الإحصائيات
-- ═══════════════════════════════════════════════════════════
local farmStats = {
    totalKills = 0,
    startLevel = getPlayerLevel(),
    startTime  = tick(),
    errors     = 0,
}

local function printFarmStats()
    local elapsed = tick() - farmStats.startTime
    local minutes = math.floor(elapsed / 60)
    local levelsGained = getPlayerLevel() - farmStats.startLevel
    
    log(string.format(
        "📊 Kills: %d | Levels: +%d | Time: %dm | Errors: %d",
        farmStats.totalKills, levelsGained, minutes, farmStats.errors
    ))
end

-- طباعة إحصائيات كل 5 دقائق
spawn(function()
    while getgenv().BFF_FARM_ACTIVE do
        task.wait(300) -- 5 دقائق
        printFarmStats()
    end
end)

-- ═══════════════════════════════════════════════════════════
-- 🎯 الحلقة الرئيسية للفارم
-- ═══════════════════════════════════════════════════════════
log("🎯 بدء حلقة الفارم الرئيسية...")

spawn(function()
    while getgenv().BFF_FARM_ACTIVE do
        local success, errorMsg = pcall(function()
            
            -- ══════════════════════════════════════
            -- 1. تحقق من الشخصية
            -- ══════════════════════════════════════
            if not isAlive() then
                stopAttack()
                currentTarget = nil
                task.wait(3)
                return
            end
            
            local hrp = getHumanoidRootPart()
            if not hrp then
                task.wait(2)
                return
            end
            
            -- ══════════════════════════════════════
            -- 2. جهّز السلاح
            -- ══════════════════════════════════════
            local weapon = equipBestWeapon()
            if not weapon then
                log("⚠️ لا يوجد سلاح! انتظار...")
                task.wait(3)
                return
            end
            
            -- ══════════════════════════════════════
            -- 3. حدد العدو المناسب
            -- ══════════════════════════════════════
            local targetInfo = getTargetInfo()
            local currentSea = getCurrentSea()
            
            -- ══════════════════════════════════════
            -- 4. انتقل للبحر الصحيح
            -- ══════════════════════════════════════
            if currentSea ~= targetInfo.sea then
                stopAttack()
                currentTarget = nil
                
                log("🚢 يجب الانتقال إلى Sea " .. targetInfo.sea .. " (حالياً في Sea " .. currentSea .. ")")
                travelToSea(targetInfo.sea)
                task.wait(5)
                return
            end
            
            -- ══════════════════════════════════════
            -- 5. ابحث عن العدو
            -- ══════════════════════════════════════
            local enemy, distance = findNearestEnemy(targetInfo.name)
            
            -- ══════════════════════════════════════
            -- 6. إذا ما فيه عدو → انتقل للجزيرة
            -- ══════════════════════════════════════
            if not enemy then
                stopAttack()
                currentTarget = nil
                
                local islandCFrame = ISLANDS[targetInfo.island]
                if not islandCFrame then
                    log("❌ جزيرة غير معروفة: " .. targetInfo.island)
                    task.wait(5)
                    return
                end
                
                local distToIsland = (hrp.Position - islandCFrame.Position).Magnitude
                
                if distToIsland > 500 then
                    -- بعيد → Teleport مباشر
                    log("✈️ Teleport → " .. targetInfo.island .. " | Target: " .. targetInfo.name .. " | Level: " .. getPlayerLevel())
                    
                    pcall(function()
                        hrp.CFrame = islandCFrame + Vector3.new(0, FARM_CONFIG.TELEPORT_HEIGHT, 0)
                    end)
                    
                    task.wait(3)
                    
                    -- حاول أخذ Quest
                    if not hasActiveQuest() then
                        acceptQuest(targetInfo)
                    end
                else
                    -- قريب → تحرك داخل الجزيرة
                    wanderInIsland(islandCFrame, targetInfo.name)
                end
                
                return
            end
            
            -- ══════════════════════════════════════
            -- 7. وجدنا عدو → هاجمه!
            -- ══════════════════════════════════════
            local enemyHRP = enemy:FindFirstChild("HumanoidRootPart")
            local enemyHum = enemy:FindFirstChildOfClass("Humanoid")
            
            if not enemyHRP or not enemyHum then
                task.wait(0.5)
                return
            end
            
            log(string.format(
                "⚔️ %s | HP: %d | Level: %d | Sea %d | Dist: %dm",
                targetInfo.name,
                math.floor(enemyHum.Health),
                getPlayerLevel(),
                currentSea,
                math.floor(distance)
            ))
            
            currentTarget = enemy
            startAttack()
            
            local killStartTime = tick()
            
            -- ══════════════════════════════════════
            -- 8. ابقَ تحت العدو وهاجم
            -- ══════════════════════════════════════
            local positionUpdater = RunService.Heartbeat:Connect(function()
                -- تحقق من صلاحية العدو
                if not (enemy and enemy.Parent and enemyHum and enemyHum.Health > 0
                        and getgenv().BFF_FARM_ACTIVE and enemyHRP and enemyHRP.Parent) then
                    return
                end
                
                -- Timeout check
                if (tick() - killStartTime) > FARM_CONFIG.KILL_TIMEOUT then
                    return
                end
                
                -- انتقل تحت العدو
                pcall(function()
                    local myHRP = getHumanoidRootPart()
                    if myHRP then
                        myHRP.CFrame = enemyHRP.CFrame * CFrame.new(0, FARM_CONFIG.UNDERGROUND_OFFSET, 0)
                    end
                end)
            end)
            
            -- ══════════════════════════════════════
            -- 9. انتظر حتى يموت العدو
            -- ══════════════════════════════════════
            while enemy and enemy.Parent and enemyHum and enemyHum.Health > 0 
                  and getgenv().BFF_FARM_ACTIVE do
                
                -- Timeout
                if (tick() - killStartTime) > FARM_CONFIG.KILL_TIMEOUT then
                    log("⏰ Timeout! العدو أخذ وقت طويل - تخطي...")
                    break
                end
                
                task.wait(0.15)
            end
            
            -- ══════════════════════════════════════
            -- 10. تنظيف بعد القتل
            -- ══════════════════════════════════════
            if positionUpdater then
                positionUpdater:Disconnect()
                positionUpdater = nil
            end
            
            stopAttack()
            currentTarget = nil
            
            -- تحقق إذا تم القتل (وليس timeout)
            if not enemy or not enemy.Parent or (enemyHum and enemyHum.Health <= 0) then
                farmStats.totalKills = farmStats.totalKills + 1
                log("💀 Killed: " .. targetInfo.name .. " | Total: " .. farmStats.totalKills)
            end
            
        end) -- نهاية pcall
        
        -- ══════════════════════════════════════
        -- معالجة الأخطاء
        -- ══════════════════════════════════════
        if not success then
            farmStats.errors = farmStats.errors + 1
            warn("⚠️ [FARM ERROR] " .. tostring(errorMsg))
            
            stopAttack()
            currentTarget = nil
            
            -- إذا كثرت الأخطاء
            if farmStats.errors > 50 then
                log("❌ أخطاء كثيرة! إعادة تشغيل الفارم بعد 10 ثواني...")
                farmStats.errors = 0
                task.wait(10)
            end
        end
        
        -- استراحة قصيرة بين الأعداء
        task.wait(0.2)
        
    end -- نهاية while
end) -- نهاية spawn

-- ═══════════════════════════════════════════════════════════
-- 🧹 تنظيف الذاكرة الدوري (مهم لـ iPhone)
-- ═══════════════════════════════════════════════════════════
spawn(function()
    while getgenv().BFF_FARM_ACTIVE do
        task.wait(180) -- كل 3 دقائق
        pcall(function()
            collectgarbage("collect")
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════
-- ✅ الفارم جاهز!
-- ═══════════════════════════════════════════════════════════
log("✅ BFF Farm v16.0 - جاهز ويعمل!")
log("🌊 البحر الحالي: " .. getSeaName(getCurrentSea()))
log("⭐ الليفل: " .. getPlayerLevel())

local targetInfo = getTargetInfo()
log("🎯 العدو المستهدف: " .. targetInfo.name .. " في " .. targetInfo.island)

notify("✅ Farm v16.0 Ready!", 
    "Level " .. getPlayerLevel() .. " | Target: " .. targetInfo.name, 5)

print("╔═══════════════════════════════════════════════╗")
print("║  ✅ BFF FARM v16.0 ACTIVE!                   ║")
print("║  🎯 Target: " .. targetInfo.name)
print("║  🏝️ Island: " .. targetInfo.island)
print("║  🌊 Sea: " .. getCurrentSea())
print("║  ⭐ Level: " .. getPlayerLevel())
print("╚═══════════════════════════════════════════════╝")
