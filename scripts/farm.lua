--[[
    ══════════════════════════════════════════════════════════════
    🔥 BFF FARM v18.0 - INTELLIGENT QUEST SYSTEM 🔥
    ══════════════════════════════════════════════════════════════
    
    ✅ نظام Quest حقيقي (مثل Redz Hub / Rip Indra)
    ✅ يذهب لـ NPC الـ Quest أولاً (وليس العدو مباشرة!)
    ✅ ينتظر تفعيل الـ Quest قبل الفرم
    ✅ يعرف متى ينتقل للجزيرة التالية (بعد اكتمال Quest)
    ✅ سرعة قتل ممتازة (M1 Combat System صحيح)
    ✅ Bring Mobs (يجذب الأعداء إليك بدل الطيران)
    ✅ Auto Return (يرجع للنقطة بعد كل قتل)
    
    ══════════════════════════════════════════════════════════════
]]

-- ═══════════════════════════════════════════════════════════
-- 🛡️ حماية
-- ═══════════════════════════════════════════════════════════
if getgenv().BFF_FARM_ACTIVE then
    warn("⚠️ [FARM] شغال بالفعل!")
    return
end
getgenv().BFF_FARM_ACTIVE = true

-- ═══════════════════════════════════════════════════════════
-- 📦 الخدمات
-- ═══════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local VIM = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ═══════════════════════════════════════════════════════════
-- ⚙️ إعدادات
-- ═══════════════════════════════════════════════════════════
local CFG = {
    ATTACK_SPEED    = 0.1,
    KILL_TIMEOUT    = 30,
    UNDERGROUND_Y   = -3,      -- عمق تحت العدو (كان -5 كثير)
    TELEPORT_HEIGHT = 15,
    QUEST_CHECK     = 2,       -- تحقق Quest كل ثانيتين
    BRING_MOBS      = true,    -- جذب الأعداء بدل الطيران لهم
    ANIMATION_SPEED = 2.5,
}

-- ═══════════════════════════════════════════════════════════
-- 📢 التسجيل
-- ═══════════════════════════════════════════════════════════
local function notify(t, x, d)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title=t, Text=x, Duration=d or 3})
    end)
end

local function log(msg)
    print("[" .. os.date("%H:%M:%S") .. "] ⚔️ FARM | " .. msg)
end

-- ═══════════════════════════════════════════════════════════
-- 🌊 البحر
-- ═══════════════════════════════════════════════════════════
local function getCurrentSea()
    local pid = game.PlaceId
    if pid == 2753915549 then return 1
    elseif pid == 4442272183 then return 2
    elseif pid == 7449423635 then return 3 end
    return 1
end

-- ═══════════════════════════════════════════════════════════
-- 🎯 قاعدة بيانات المهام الكاملة
-- ═══════════════════════════════════════════════════════════
--[[
    هذه هي البيانات الصحيحة التي تستخدمها كل السكربتات الاحترافية:
    
    - questNpcName: اسم NPC الـ Quest بالضبط
    - questArg: الأرقام التي تُرسل لـ StartQuest 
    - npcCFrame: مكان الـ NPC (تلقيت للـ NPC مباشرة)
    - mobName: اسم العدو
    - mobCFrame: مكان تجمع الأعداء
    - minLvl / maxLvl: نطاق الليفل
]]

local QUESTS = {
    -- ══════════════════════════════════════════
    -- 🌊 SEA 1
    -- ══════════════════════════════════════════
    {
        minLvl = 1, maxLvl = 9,
        mobName = "Bandit",
        questNpc = "Bandit Quest Giver",
        questArg1 = "BanditQuest1", questArg2 = 1,
        npcCFrame = CFrame.new(1060.9, 15.9, 1547.5),
        mobCFrame = CFrame.new(1038, 21, 1583),
        island = "Jungle", sea = 1,
    },
    {
        minLvl = 10, maxLvl = 14,
        mobName = "Monkey",
        questNpc = "Jungle Quest Giver",
        questArg1 = "JungleQuest", questArg2 = 1,
        npcCFrame = CFrame.new(-1601.5, 36.8, 153.3),
        mobCFrame = CFrame.new(-1445, 40, -34),
        island = "Jungle", sea = 1,
    },
    {
        minLvl = 15, maxLvl = 29,
        mobName = "Gorilla",
        questNpc = "Jungle Quest Giver",
        questArg1 = "JungleQuest", questArg2 = 2,
        npcCFrame = CFrame.new(-1601.5, 36.8, 153.3),
        mobCFrame = CFrame.new(-1142, 40, -488),
        island = "Jungle", sea = 1,
    },
    {
        minLvl = 30, maxLvl = 39,
        mobName = "Pirate",
        questNpc = "Pirate Village Quest Giver",
        questArg1 = "PirateQuest1", questArg2 = 1,
        npcCFrame = CFrame.new(-1181.8, 4.7, 3803.1),
        mobCFrame = CFrame.new(-1094, 15, 3833),
        island = "Pirate Village", sea = 1,
    },
    {
        minLvl = 40, maxLvl = 59,
        mobName = "Brute",
        questNpc = "Pirate Village Quest Giver",
        questArg1 = "PirateQuest1", questArg2 = 2,
        npcCFrame = CFrame.new(-1181.8, 4.7, 3803.1),
        mobCFrame = CFrame.new(-1145, 20, 4015),
        island = "Pirate Village", sea = 1,
    },
    {
        minLvl = 60, maxLvl = 74,
        mobName = "Desert Bandit",
        questNpc = "Desert Quest Giver",
        questArg1 = "DesertQuest", questArg2 = 1,
        npcCFrame = CFrame.new(1093.9, 6.5, 4287.4),
        mobCFrame = CFrame.new(984, 6, 4390),
        island = "Desert", sea = 1,
    },
    {
        minLvl = 75, maxLvl = 89,
        mobName = "Desert Officer",
        questNpc = "Desert Quest Giver",
        questArg1 = "DesertQuest", questArg2 = 2,
        npcCFrame = CFrame.new(1093.9, 6.5, 4287.4),
        mobCFrame = CFrame.new(1521, 14, 4363),
        island = "Desert", sea = 1,
    },
    {
        minLvl = 90, maxLvl = 99,
        mobName = "Snow Bandit",
        questNpc = "Frozen Quest Giver",
        questArg1 = "SnowQuest", questArg2 = 1,
        npcCFrame = CFrame.new(1386.8, 87.2, -1298.4),
        mobCFrame = CFrame.new(1372, 105, -1355),
        island = "Frozen Village", sea = 1,
    },
    {
        minLvl = 100, maxLvl = 119,
        mobName = "Snowman",
        questNpc = "Frozen Quest Giver",
        questArg1 = "SnowQuest", questArg2 = 2,
        npcCFrame = CFrame.new(1386.8, 87.2, -1298.4),
        mobCFrame = CFrame.new(1237, 137, -1489),
        island = "Frozen Village", sea = 1,
    },
    {
        minLvl = 120, maxLvl = 149,
        mobName = "Chief Petty Officer",
        questNpc = "Marine Quest Giver",
        questArg1 = "MarineQuest2", questArg2 = 1,
        npcCFrame = CFrame.new(-5035.2, 28.7, 4325.5),
        mobCFrame = CFrame.new(-4956, 21, 4238),
        island = "Marine Fortress", sea = 1,
    },
    {
        minLvl = 150, maxLvl = 174,
        mobName = "Sky Bandit",
        questNpc = "Sky Quest Giver",
        questArg1 = "SkyQuest", questArg2 = 1,
        npcCFrame = CFrame.new(-4842.1, 717.7, -2623.6),
        mobCFrame = CFrame.new(-4996, 719, -2528),
        island = "Sky Island", sea = 1,
    },
    {
        minLvl = 175, maxLvl = 189,
        mobName = "Dark Master",
        questNpc = "Sky Quest Giver",
        questArg1 = "SkyQuest", questArg2 = 2,
        npcCFrame = CFrame.new(-4842.1, 717.7, -2623.6),
        mobCFrame = CFrame.new(-5195, 719, -2419),
        island = "Sky Island", sea = 1,
    },
    {
        minLvl = 190, maxLvl = 209,
        mobName = "Prisoner",
        questNpc = "Prisoner Quest Giver",
        questArg1 = "PrisonerQuest", questArg2 = 1,
        npcCFrame = CFrame.new(5308, 0.3, 474.7),
        mobCFrame = CFrame.new(5228, 2, 800),
        island = "Prison", sea = 1,
    },
    {
        minLvl = 210, maxLvl = 249,
        mobName = "Dangerous Prisoner",
        questNpc = "Prisoner Quest Giver",
        questArg1 = "PrisonerQuest", questArg2 = 2,
        npcCFrame = CFrame.new(5308, 0.3, 474.7),
        mobCFrame = CFrame.new(5391, 15, 780),
        island = "Prison", sea = 1,
    },
    {
        minLvl = 250, maxLvl = 274,
        mobName = "Toga Warrior",
        questNpc = "Colosseum Quest Giver",
        questArg1 = "ColosseumQuest", questArg2 = 1,
        npcCFrame = CFrame.new(-1576.5, 7.4, -2984.8),
        mobCFrame = CFrame.new(-1725, 45, -2903),
        island = "Colosseum", sea = 1,
    },
    {
        minLvl = 275, maxLvl = 299,
        mobName = "Gladiator",
        questNpc = "Colosseum Quest Giver",
        questArg1 = "ColosseumQuest", questArg2 = 2,
        npcCFrame = CFrame.new(-1576.5, 7.4, -2984.8),
        mobCFrame = CFrame.new(-1613, 45, -3068),
        island = "Colosseum", sea = 1,
    },
    {
        minLvl = 300, maxLvl = 324,
        mobName = "Military Soldier",
        questNpc = "Magma Quest Giver",
        questArg1 = "MagmaQuest", questArg2 = 1,
        npcCFrame = CFrame.new(-5316.3, 12.4, 8517.2),
        mobCFrame = CFrame.new(-5316, 24, 8517),
        island = "Magma Village", sea = 1,
    },
    {
        minLvl = 325, maxLvl = 374,
        mobName = "Military Spy",
        questNpc = "Magma Quest Giver",
        questArg1 = "MagmaQuest", questArg2 = 2,
        npcCFrame = CFrame.new(-5316.3, 12.4, 8517.2),
        mobCFrame = CFrame.new(-5544, 78, 8788),
        island = "Magma Village", sea = 1,
    },
    {
        minLvl = 375, maxLvl = 399,
        mobName = "Fishman Warrior",
        questNpc = "Fishman Quest Giver",
        questArg1 = "FishmanQuest", questArg2 = 1,
        npcCFrame = CFrame.new(61163.8, 11.5, 1819.7),
        mobCFrame = CFrame.new(61123, 18, 1569),
        island = "Underwater City", sea = 1,
    },
    {
        minLvl = 400, maxLvl = 449,
        mobName = "Fishman Commando",
        questNpc = "Fishman Quest Giver",
        questArg1 = "FishmanQuest", questArg2 = 2,
        npcCFrame = CFrame.new(61163.8, 11.5, 1819.7),
        mobCFrame = CFrame.new(61385, 18, 1440),
        island = "Underwater City", sea = 1,
    },
    {
        minLvl = 450, maxLvl = 474,
        mobName = "God's Guard",
        questNpc = "God's Guard Quest Giver",
        questArg1 = "SkyExp1Quest", questArg2 = 1,
        npcCFrame = CFrame.new(-4721.4, 845.3, -1953.8),
        mobCFrame = CFrame.new(-4869, 845, -1626),
        island = "Upper Skylands", sea = 1,
    },
    {
        minLvl = 475, maxLvl = 524,
        mobName = "Shanda",
        questNpc = "Upper Skyland Quest Giver",
        questArg1 = "SkyExp1Quest", questArg2 = 2,
        npcCFrame = CFrame.new(-7864.7, 5545.4, -381.7),
        mobCFrame = CFrame.new(-7748, 5606, -320),
        island = "Upper Skylands", sea = 1,
    },
    {
        minLvl = 525, maxLvl = 549,
        mobName = "Royal Squad",
        questNpc = "Fountain Quest Giver",
        questArg1 = "FountainQuest", questArg2 = 1,
        npcCFrame = CFrame.new(5254.5, 38.5, 4051.5),
        mobCFrame = CFrame.new(5522, 40, 4103),
        island = "Fountain City", sea = 1,
    },
    {
        minLvl = 550, maxLvl = 624,
        mobName = "Royal Soldier",
        questNpc = "Fountain Quest Giver",
        questArg1 = "FountainQuest", questArg2 = 2,
        npcCFrame = CFrame.new(5254.5, 38.5, 4051.5),
        mobCFrame = CFrame.new(5642, 60, 4185),
        island = "Fountain City", sea = 1,
    },
    {
        minLvl = 625, maxLvl = 699,
        mobName = "Galley Pirate",
        questNpc = "Galley Quest Giver",
        questArg1 = "Area2Quest", questArg2 = 1,
        npcCFrame = CFrame.new(5254.5, 38.5, 4051.5),
        mobCFrame = CFrame.new(5642, 60, 4185),
        island = "Fountain City", sea = 1,
    },
    
    -- ══════════════════════════════════════════
    -- 🌊 SEA 2
    -- ══════════════════════════════════════════
    {
        minLvl = 700, maxLvl = 774,
        mobName = "Raider",
        questNpc = "Rose Quest Giver",
        questArg1 = "Area1Quest", questArg2 = 1,
        npcCFrame = CFrame.new(-427.7, 72.9, 1836.5),
        mobCFrame = CFrame.new(-535, 72, 1875),
        island = "Kingdom of Rose", sea = 2,
    },
    {
        minLvl = 775, maxLvl = 824,
        mobName = "Mercenary",
        questNpc = "Rose Quest Giver",
        questArg1 = "Area1Quest", questArg2 = 2,
        npcCFrame = CFrame.new(-427.7, 72.9, 1836.5),
        mobCFrame = CFrame.new(-923, 148, 2144),
        island = "Kingdom of Rose", sea = 2,
    },
    {
        minLvl = 825, maxLvl = 874,
        mobName = "Swan Pirate",
        questNpc = "Green Zone Quest Giver",
        questArg1 = "Area2Quest", questArg2 = 1,
        npcCFrame = CFrame.new(-2842.4, 71.8, 5320.6),
        mobCFrame = CFrame.new(-3084, 88, 5117),
        island = "Green Zone", sea = 2,
    },
    {
        minLvl = 875, maxLvl = 924,
        mobName = "Factory Staff",
        questNpc = "Green Zone Quest Giver",
        questArg1 = "Area2Quest", questArg2 = 2,
        npcCFrame = CFrame.new(-2842.4, 71.8, 5320.6),
        mobCFrame = CFrame.new(-2725, 71, 5203),
        island = "Green Zone", sea = 2,
    },
    {
        minLvl = 925, maxLvl = 949,
        mobName = "Marine Lieutenant",
        questNpc = "Marine Quest Giver",
        questArg1 = "MarineQuest3", questArg2 = 1,
        npcCFrame = CFrame.new(-5035.2, 28.7, 4325.5),
        mobCFrame = CFrame.new(-5057, 45, 4249),
        island = "Marine Fortress", sea = 2,
    },
    {
        minLvl = 950, maxLvl = 974,
        mobName = "Marine Captain",
        questNpc = "Marine Quest Giver",
        questArg1 = "MarineQuest3", questArg2 = 2,
        npcCFrame = CFrame.new(-5035.2, 28.7, 4325.5),
        mobCFrame = CFrame.new(-4915, 45, 4318),
        island = "Marine Fortress", sea = 2,
    },
    {
        minLvl = 975, maxLvl = 999,
        mobName = "Zombie",
        questNpc = "Zombie Quest Giver",
        questArg1 = "ZombieQuest", questArg2 = 1,
        npcCFrame = CFrame.new(-5495.8, 47.5, -793.4),
        mobCFrame = CFrame.new(-5751, 12, -735),
        island = "Graveyard", sea = 2,
    },
    {
        minLvl = 1000, maxLvl = 1049,
        mobName = "Vampire",
        questNpc = "Zombie Quest Giver",
        questArg1 = "ZombieQuest", questArg2 = 2,
        npcCFrame = CFrame.new(-5495.8, 47.5, -793.4),
        mobCFrame = CFrame.new(-6019, 8, -1379),
        island = "Graveyard", sea = 2,
    },
    {
        minLvl = 1050, maxLvl = 1099,
        mobName = "Snow Trooper",
        questNpc = "Snow Mountain Quest Giver",
        questArg1 = "SnowMountainQuest", questArg2 = 1,
        npcCFrame = CFrame.new(605.5, 399.6, -5378.3),
        mobCFrame = CFrame.new(1345, 460, -5498),
        island = "Snow Mountain", sea = 2,
    },
    {
        minLvl = 1100, maxLvl = 1124,
        mobName = "Winter Warrior",
        questNpc = "Snow Mountain Quest Giver",
        questArg1 = "SnowMountainQuest", questArg2 = 2,
        npcCFrame = CFrame.new(605.5, 399.6, -5378.3),
        mobCFrame = CFrame.new(1245, 470, -5423),
        island = "Snow Mountain", sea = 2,
    },
    {
        minLvl = 1125, maxLvl = 1174,
        mobName = "Lab Subordinate",
        questNpc = "Hot Quest Giver",
        questArg1 = "HotAndColdQuest", questArg2 = 1,
        npcCFrame = CFrame.new(-5751.9, 6.4, -5459.5),
        mobCFrame = CFrame.new(-6094, 14, -5573),
        island = "Hot and Cold", sea = 2,
    },
    {
        minLvl = 1175, maxLvl = 1199,
        mobName = "Horned Warrior",
        questNpc = "Hot Quest Giver",
        questArg1 = "HotAndColdQuest", questArg2 = 2,
        npcCFrame = CFrame.new(-5751.9, 6.4, -5459.5),
        mobCFrame = CFrame.new(-6217, 82, -5911),
        island = "Hot and Cold", sea = 2,
    },
    {
        minLvl = 1200, maxLvl = 1249,
        mobName = "Magma Ninja",
        questNpc = "Hot Quest Giver",
        questArg1 = "HotAndColdQuest", questArg2 = 3,
        npcCFrame = CFrame.new(-5751.9, 6.4, -5459.5),
        mobCFrame = CFrame.new(-5934, 47, -5952),
        island = "Hot and Cold", sea = 2,
    },
    {
        minLvl = 1250, maxLvl = 1274,
        mobName = "Cursed Pirate",
        questNpc = "Cursed Ship Quest Giver",
        questArg1 = "CursedShipQuest", questArg2 = 1,
        npcCFrame = CFrame.new(923.8, 125.4, 32873.2),
        mobCFrame = CFrame.new(1246, 126, 32988),
        island = "Cursed Ship", sea = 2,
    },
    {
        minLvl = 1275, maxLvl = 1299,
        mobName = "Ice Viking",
        questNpc = "Ice Castle Quest Giver",
        questArg1 = "IceCastleQuest", questArg2 = 1,
        npcCFrame = CFrame.new(6187.9, 294.2, -6743.6),
        mobCFrame = CFrame.new(6403, 294, -6564),
        island = "Ice Castle", sea = 2,
    },
    {
        minLvl = 1300, maxLvl = 1324,
        mobName = "Snow Lurker",
        questNpc = "Ice Castle Quest Giver",
        questArg1 = "IceCastleQuest", questArg2 = 2,
        npcCFrame = CFrame.new(6187.9, 294.2, -6743.6),
        mobCFrame = CFrame.new(6403, 294, -6564),
        island = "Ice Castle", sea = 2,
    },
    {
        minLvl = 1325, maxLvl = 1349,
        mobName = "Marine Commodore",
        questNpc = "Forgotten Quest Giver",
        questArg1 = "FountainQuest", questArg2 = 2,
        npcCFrame = CFrame.new(-3054.9, 236.7, -10147.6),
        mobCFrame = CFrame.new(-3223, 250, -10112),
        island = "Forgotten Island", sea = 2,
    },
    {
        minLvl = 1350, maxLvl = 1424,
        mobName = "Marine Commodore",
        questNpc = "Forgotten Quest Giver",
        questArg1 = "FountainQuest", questArg2 = 2,
        npcCFrame = CFrame.new(-3054.9, 236.7, -10147.6),
        mobCFrame = CFrame.new(-3223, 250, -10112),
        island = "Forgotten Island", sea = 2,
    },
    {
        minLvl = 1425, maxLvl = 1499,
        mobName = "Marine Rear Admiral",
        questNpc = "Forgotten Quest Giver",
        questArg1 = "FountainQuest", questArg2 = 3,
        npcCFrame = CFrame.new(-3054.9, 236.7, -10147.6),
        mobCFrame = CFrame.new(-3078, 236, -9739),
        island = "Forgotten Island", sea = 2,
    },
    
    -- ══════════════════════════════════════════
    -- 🌊 SEA 3
    -- ══════════════════════════════════════════
    {
        minLvl = 1500, maxLvl = 1524,
        mobName = "Pirate Millionaire",
        questNpc = "Port Town Quest Giver",
        questArg1 = "PiratePortQuest", questArg2 = 1,
        npcCFrame = CFrame.new(-290.8, 43.5, 5581.6),
        mobCFrame = CFrame.new(-486, 72, 5747),
        island = "Port Town", sea = 3,
    },
    {
        minLvl = 1525, maxLvl = 1574,
        mobName = "Pistol Billionaire",
        questNpc = "Port Town Quest Giver",
        questArg1 = "PiratePortQuest", questArg2 = 2,
        npcCFrame = CFrame.new(-290.8, 43.5, 5581.6),
        mobCFrame = CFrame.new(-291, 43, 5581),
        island = "Port Town", sea = 3,
    },
    {
        minLvl = 1575, maxLvl = 1624,
        mobName = "Dragon Crew Warrior",
        questNpc = "Hydra Quest Giver",
        questArg1 = "AmazonQuest2", questArg2 = 1,
        npcCFrame = CFrame.new(5233.4, 603.7, 345.3),
        mobCFrame = CFrame.new(5433, 603, 400),
        island = "Hydra Island", sea = 3,
    },
    {
        minLvl = 1625, maxLvl = 1649,
        mobName = "Dragon Crew Archer",
        questNpc = "Hydra Quest Giver",
        questArg1 = "AmazonQuest2", questArg2 = 2,
        npcCFrame = CFrame.new(5233.4, 603.7, 345.3),
        mobCFrame = CFrame.new(5433, 603, 400),
        island = "Hydra Island", sea = 3,
    },
    {
        minLvl = 1650, maxLvl = 1699,
        mobName = "Female Islander",
        questNpc = "Great Tree Quest Giver",
        questArg1 = "MarineTreeIsland", questArg2 = 1,
        npcCFrame = CFrame.new(2192.8, 28.6, -6960.9),
        mobCFrame = CFrame.new(2350, 90, -6934),
        island = "Great Tree", sea = 3,
    },
    {
        minLvl = 1700, maxLvl = 1724,
        mobName = "Giant Islander",
        questNpc = "Great Tree Quest Giver",
        questArg1 = "MarineTreeIsland", questArg2 = 2,
        npcCFrame = CFrame.new(2192.8, 28.6, -6960.9),
        mobCFrame = CFrame.new(2350, 90, -6934),
        island = "Great Tree", sea = 3,
    },
    {
        minLvl = 1725, maxLvl = 1774,
        mobName = "Marine Commodore",
        questNpc = "Castle Quest Giver",
        questArg1 = "IceCastleQuest", questArg2 = 1,
        npcCFrame = CFrame.new(-5083.8, 314.8, -3145.6),
        mobCFrame = CFrame.new(-5083, 314, -3145),
        island = "Castle on Sea", sea = 3,
    },
    {
        minLvl = 1775, maxLvl = 1799,
        mobName = "Marine Rear Admiral",
        questNpc = "Castle Quest Giver",
        questArg1 = "IceCastleQuest", questArg2 = 2,
        npcCFrame = CFrame.new(-5083.8, 314.8, -3145.6),
        mobCFrame = CFrame.new(-5083, 314, -3145),
        island = "Castle on Sea", sea = 3,
    },
    {
        minLvl = 1800, maxLvl = 1824,
        mobName = "Fishman Raider",
        questNpc = "Fishman Quest Giver",
        questArg1 = "FishmanQuest2", questArg2 = 1,
        npcCFrame = CFrame.new(-10614.9, 331.4, -8090.7),
        mobCFrame = CFrame.new(-11141, 331, -8354),
        island = "Floating Turtle", sea = 3,
    },
    {
        minLvl = 1825, maxLvl = 1874,
        mobName = "Fishman Captain",
        questNpc = "Fishman Quest Giver",
        questArg1 = "FishmanQuest2", questArg2 = 2,
        npcCFrame = CFrame.new(-10614.9, 331.4, -8090.7),
        mobCFrame = CFrame.new(-11141, 331, -8354),
        island = "Floating Turtle", sea = 3,
    },
    {
        minLvl = 1875, maxLvl = 1924,
        mobName = "Forest Pirate",
        questNpc = "Forest Quest Giver",
        questArg1 = "ForgottenQuest", questArg2 = 1,
        npcCFrame = CFrame.new(-13232.6, 331.9, -7626.2),
        mobCFrame = CFrame.new(-13232, 331, -7626),
        island = "Floating Turtle", sea = 3,
    },
    {
        minLvl = 1925, maxLvl = 1974,
        mobName = "Mythological Pirate",
        questNpc = "Forest Quest Giver",
        questArg1 = "ForgottenQuest", questArg2 = 2,
        npcCFrame = CFrame.new(-13232.6, 331.9, -7626.2),
        mobCFrame = CFrame.new(-13232, 331, -7626),
        island = "Floating Turtle", sea = 3,
    },
    {
        minLvl = 1975, maxLvl = 2074,
        mobName = "Jungle Pirate",
        questNpc = "Pirate Quest Giver",
        questArg1 = "PiratePortQuest", questArg2 = 1,
        npcCFrame = CFrame.new(-11888.7, 331.7, -8794.8),
        mobCFrame = CFrame.new(-11888, 331, -8794),
        island = "Floating Turtle", sea = 3,
    },
    {
        minLvl = 2075, maxLvl = 2149,
        mobName = "Musketeer Pirate",
        questNpc = "Pirate Quest Giver",
        questArg1 = "PiratePortQuest", questArg2 = 2,
        npcCFrame = CFrame.new(-11888.7, 331.7, -8794.8),
        mobCFrame = CFrame.new(-11888, 331, -8794),
        island = "Floating Turtle", sea = 3,
    },
    {
        minLvl = 2150, maxLvl = 2199,
        mobName = "Reborn Skeleton",
        questNpc = "Haunted Quest Giver",
        questArg1 = "HauntedQuest1", questArg2 = 1,
        npcCFrame = CFrame.new(-9515.9, 142.9, 5548.8),
        mobCFrame = CFrame.new(-9515, 142, 5548),
        island = "Haunted Castle", sea = 3,
    },
    {
        minLvl = 2200, maxLvl = 2249,
        mobName = "Living Zombie",
        questNpc = "Haunted Quest Giver",
        questArg1 = "HauntedQuest1", questArg2 = 2,
        npcCFrame = CFrame.new(-9515.9, 142.9, 5548.8),
        mobCFrame = CFrame.new(-9515, 142, 5548),
        island = "Haunted Castle", sea = 3,
    },
    {
        minLvl = 2250, maxLvl = 2299,
        mobName = "Demonic Soul",
        questNpc = "Haunted Quest Giver",
        questArg1 = "HauntedQuest2", questArg2 = 1,
        npcCFrame = CFrame.new(-9515.9, 142.9, 5548.8),
        mobCFrame = CFrame.new(-9515, 142, 5548),
        island = "Haunted Castle", sea = 3,
    },
    {
        minLvl = 2300, maxLvl = 2374,
        mobName = "Posessed Mummy",
        questNpc = "Haunted Quest Giver",
        questArg1 = "HauntedQuest2", questArg2 = 2,
        npcCFrame = CFrame.new(-9515.9, 142.9, 5548.8),
        mobCFrame = CFrame.new(-9515, 142, 5548),
        island = "Haunted Castle", sea = 3,
    },
    {
        minLvl = 2375, maxLvl = 2399,
        mobName = "Peanut Scout",
        questNpc = "Peanut Quest Giver",
        questArg1 = "IceSideQuest", questArg2 = 1,
        npcCFrame = CFrame.new(-2038.9, 47.1, -10355.5),
        mobCFrame = CFrame.new(-2038, 47, -10355),
        island = "Tiki Outpost", sea = 3,
    },
    {
        minLvl = 2400, maxLvl = 2424,
        mobName = "Peanut President",
        questNpc = "Peanut Quest Giver",
        questArg1 = "IceSideQuest", questArg2 = 2,
        npcCFrame = CFrame.new(-2038.9, 47.1, -10355.5),
        mobCFrame = CFrame.new(-2038, 47, -10355),
        island = "Tiki Outpost", sea = 3,
    },
    {
        minLvl = 2425, maxLvl = 2449,
        mobName = "Ice Cream Chef",
        questNpc = "Ice Cream Quest Giver",
        questArg1 = "FireSideQuest", questArg2 = 1,
        npcCFrame = CFrame.new(-819.5, 66.9, -10967.7),
        mobCFrame = CFrame.new(-819, 66, -10967),
        island = "Ice Cream Island", sea = 3,
    },
    {
        minLvl = 2450, maxLvl = 2474,
        mobName = "Cookie Crafter",
        questNpc = "Ice Cream Quest Giver",
        questArg1 = "FireSideQuest", questArg2 = 2,
        npcCFrame = CFrame.new(-819.5, 66.9, -10967.7),
        mobCFrame = CFrame.new(-819, 66, -10967),
        island = "Ice Cream Island", sea = 3,
    },
    {
        minLvl = 2475, maxLvl = 2549,
        mobName = "Cake Guard",
        questNpc = "Ice Cream Quest Giver",
        questArg1 = "FireSideQuest", questArg2 = 3,
        npcCFrame = CFrame.new(-819.5, 66.9, -10967.7),
        mobCFrame = CFrame.new(-819, 66, -10967),
        island = "Ice Cream Island", sea = 3,
    },
}

-- ═══════════════════════════════════════════════════════════
-- 🔧 دوال أساسية
-- ═══════════════════════════════════════════════════════════
local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function isAlive()
    local h = getHum()
    local r = getHRP()
    return h and r and h.Health > 0 and r.Parent
end

local function getLevel()
    local l = 1
    pcall(function() l = LocalPlayer.Data.Level.Value end)
    return l
end

local function getRemote()
    local r = ReplicatedStorage:FindFirstChild("Remotes")
    return r and r:FindFirstChild("CommF_")
end

-- ═══════════════════════════════════════════════════════════
-- 🎯 اختيار Quest المناسب
-- ═══════════════════════════════════════════════════════════
local function getCurrentQuest()
    local lvl = getLevel()
    for _, q in ipairs(QUESTS) do
        if lvl >= q.minLvl and lvl <= q.maxLvl then
            return q
        end
    end
    return QUESTS[#QUESTS]
end

-- ═══════════════════════════════════════════════════════════
-- 📜 تحقق من وجود Quest نشط (الطريقة الصحيحة)
-- ═══════════════════════════════════════════════════════════
local function hasActiveQuest()
    local active = false
    pcall(function()
        -- تحقق من QuestGui في PlayerGui
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then return end
        
        -- في Blox Fruits، Quest يظهر في Main.Quest
        local main = pg:FindFirstChild("Main")
        if main then
            local quest = main:FindFirstChild("Quest")
            if quest and quest.Visible then
                active = true
                return
            end
            
            -- أو من خلال البحث عن Frame اسمه Quest
            for _, obj in pairs(main:GetDescendants()) do
                if (obj:IsA("Frame") or obj:IsA("ImageLabel")) and obj.Name:lower():find("quest") then
                    if obj.Visible then
                        -- تحقق أن فيه نص "Defeat" أو رقم
                        for _, sub in pairs(obj:GetDescendants()) do
                            if sub:IsA("TextLabel") then
                                local t = sub.Text or ""
                                if t:find("Defeat") or t:find("/") then
                                    active = true
                                    return
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    return active
end

-- ═══════════════════════════════════════════════════════════
-- 🚢 انتقال للبحر
-- ═══════════════════════════════════════════════════════════
local function travelToSea(targetSea)
    if getCurrentSea() == targetSea then return true end
    
    log("🚢 انتقال إلى Sea " .. targetSea)
    notify("🚢 Traveling", "Sea " .. getCurrentSea() .. " → " .. targetSea, 5)
    
    local commF = getRemote()
    if not commF then return false end
    
    local cmds = {[1]="TravelMain", [2]="TravelDressrosa", [3]="TravelZou"}
    
    pcall(function()
        commF:InvokeServer(cmds[targetSea])
    end)
    
    task.wait(8)
    return true
end

-- ═══════════════════════════════════════════════════════════
-- 🗣️ أخذ Quest (الطريقة الصحيحة!)
-- ═══════════════════════════════════════════════════════════
local function acceptQuest(quest)
    local commF = getRemote()
    if not commF then return false end
    
    -- الطريقة الصحيحة المستخدمة في كل السكربتات
    local success = false
    pcall(function()
        commF:InvokeServer("StartQuest", quest.questArg1, quest.questArg2)
        success = true
    end)
    
    if success then
        log("📜 Quest مأخوذ: " .. quest.questArg1 .. " - " .. quest.questArg2 .. " (" .. quest.mobName .. ")")
    end
    
    return success
end

-- ═══════════════════════════════════════════════════════════
-- 🗡️ تجهيز السلاح
-- ═══════════════════════════════════════════════════════════
local function getEquippedTool()
    local c = getChar()
    if not c then return nil end
    for _, i in pairs(c:GetChildren()) do
        if i:IsA("Tool") then return i end
    end
    return nil
end

local function equipWeapon()
    local t = getEquippedTool()
    if t then return t end
    
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if not bp then return nil end
    
    for _, i in pairs(bp:GetChildren()) do
        if i:IsA("Tool") then
            local h = getHum()
            if h then
                h:EquipTool(i)
                task.wait(0.3)
                return i
            end
        end
    end
    return nil
end

-- ═══════════════════════════════════════════════════════════
-- 🔍 البحث عن العدو المستهدف
-- ═══════════════════════════════════════════════════════════
local function findMob(mobName)
    local hrp = getHRP()
    if not hrp then return nil end
    
    local folder = Workspace:FindFirstChild("Enemies")
    if not folder then return nil end
    
    local nearest, minDist = nil, math.huge
    for _, m in pairs(folder:GetChildren()) do
        if m.Name == mobName then
            local mh = m:FindFirstChildOfClass("Humanoid")
            local mr = m:FindFirstChild("HumanoidRootPart")
            if mh and mr and mh.Health > 0 and mr.Parent then
                local d = (hrp.Position - mr.Position).Magnitude
                if d < minDist then
                    minDist = d
                    nearest = m
                end
            end
        end
    end
    return nearest, minDist
end

-- ═══════════════════════════════════════════════════════════
-- 🧲 جذب الأعداء (Bring Mobs) - أفضل من الطيران!
-- ═══════════════════════════════════════════════════════════
local function bringMobs(mobName, playerPos)
    if not CFG.BRING_MOBS then return end
    
    pcall(function()
        local folder = Workspace:FindFirstChild("Enemies")
        if not folder then return end
        
        for _, m in pairs(folder:GetChildren()) do
            if m.Name == mobName then
                local mh = m:FindFirstChildOfClass("Humanoid")
                local mr = m:FindFirstChild("HumanoidRootPart")
                if mh and mr and mh.Health > 0 then
                    local d = (playerPos - mr.Position).Magnitude
                    -- اجذب فقط الأعداء ضمن 500 دراع
                    if d < 500 then
                        mr.CFrame = CFrame.new(playerPos + Vector3.new(3, 0, 3))
                    end
                end
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
-- 💥 نظام الهجوم M1 (الطريقة الصحيحة)
-- ═══════════════════════════════════════════════════════════
local attackOn = false
local currentTarget = nil

local function startAttack()
    if attackOn then return end
    attackOn = true
    
    -- Thread 1: Click Simulation
    spawn(function()
        while attackOn and getgenv().BFF_FARM_ACTIVE do
            pcall(function()
                local vs = Camera.ViewportSize
                VIM:SendMouseButtonEvent(vs.X/2, vs.Y/2, 0, true, game, 0)
                task.wait(0.03)
                VIM:SendMouseButtonEvent(vs.X/2, vs.Y/2, 0, false, game, 0)
            end)
            task.wait(CFG.ATTACK_SPEED)
        end
    end)
    
    -- Thread 2: Tool Activate
    spawn(function()
        while attackOn and getgenv().BFF_FARM_ACTIVE do
            pcall(function()
                local t = getEquippedTool()
                if t then t:Activate() end
            end)
            task.wait(CFG.ATTACK_SPEED)
        end
    end)
end

local function stopAttack()
    attackOn = false
end

-- ═══════════════════════════════════════════════════════════
-- 🎬 Animation Speed
-- ═══════════════════════════════════════════════════════════
spawn(function()
    while getgenv().BFF_FARM_ACTIVE do
        pcall(function()
            local h = getHum()
            if h then
                for _, tr in pairs(h:GetPlayingAnimationTracks()) do
                    local n = tr.Name:lower()
                    if n:find("attack") or n:find("combat") or n:find("punch") 
                       or n:find("slash") or n:find("hit") then
                        tr:AdjustSpeed(CFG.ANIMATION_SPEED)
                    end
                end
            end
        end)
        task.wait(0.2)
    end
end)

-- ═══════════════════════════════════════════════════════════
-- 📷 كاميرا
-- ═══════════════════════════════════════════════════════════
spawn(function()
    while getgenv().BFF_FARM_ACTIVE do
        pcall(function()
            if currentTarget and currentTarget.Parent then
                local er = currentTarget:FindFirstChild("HumanoidRootPart")
                if er and er.Parent then
                    Camera.CFrame = CFrame.new(
                        er.Position + Vector3.new(0, 10, 5),
                        er.Position
                    )
                end
            end
        end)
        RunService.RenderStepped:Wait()
    end
end)

-- ═══════════════════════════════════════════════════════════
-- 🔄 Anti-Death
-- ═══════════════════════════════════════════════════════════
LocalPlayer.CharacterAdded:Connect(function(c)
    stopAttack()
    currentTarget = nil
    log("🔄 Respawning...")
    c:WaitForChild("Humanoid", 30)
    c:WaitForChild("HumanoidRootPart", 30)
    task.wait(3)
end)

-- ═══════════════════════════════════════════════════════════
-- 📊 إحصائيات
-- ═══════════════════════════════════════════════════════════
local stats = {kills=0, quests=0, startLvl=getLevel(), startTime=tick()}

spawn(function()
    while getgenv().BFF_FARM_ACTIVE do
        task.wait(180)
        local mins = math.floor((tick() - stats.startTime)/60)
        local gained = getLevel() - stats.startLvl
        log(string.format("📊 Kills:%d | Quests:%d | +%d Lvls | %dm",
            stats.kills, stats.quests, gained, mins))
    end
end)

-- ═══════════════════════════════════════════════════════════
-- 🎯 الحلقة الرئيسية الذكية (النظام الصحيح!)
-- ═══════════════════════════════════════════════════════════
notify("🔥 Farm v18.0", "Smart Quest System | Lvl " .. getLevel(), 5)

log("🎯 بدء الفارم الذكي...")
log("⭐ Level: " .. getLevel() .. " | Sea: " .. getCurrentSea())

-- انتظر تحميل كامل
task.wait(3)

spawn(function()
    while getgenv().BFF_FARM_ACTIVE do
        local ok, err = pcall(function()
            
            -- ═══ 1. تحقق من الحياة ═══
            if not isAlive() then
                stopAttack()
                currentTarget = nil
                task.wait(3)
                return
            end
            
            -- ═══ 2. جهّز السلاح ═══
            local weapon = equipWeapon()
            if not weapon then
                log("⚠️ لا يوجد سلاح!")
                task.wait(3)
                return
            end
            
            -- ═══ 3. حدد Quest الحالي ═══
            local quest = getCurrentQuest()
            
            -- ═══ 4. تحقق من البحر ═══
            if getCurrentSea() ~= quest.sea then
                log("🚢 يجب الانتقال إلى Sea " .. quest.sea)
                stopAttack()
                currentTarget = nil
                travelToSea(quest.sea)
                return
            end
            
            local hrp = getHRP()
            if not hrp then task.wait(2); return end
            
            -- ═══ 5. تحقق من وجود Quest نشط ═══
            if not hasActiveQuest() then
                -- لا يوجد Quest → روح لـ NPC وخذ Quest
                log("📜 لا Quest نشط → الذهاب لـ NPC (" .. quest.questNpc .. ")")
                
                stopAttack()
                currentTarget = nil
                
                -- Teleport لـ NPC
                pcall(function()
                    hrp.CFrame = quest.npcCFrame + Vector3.new(0, 3, 0)
                end)
                task.wait(1.5)
                
                -- خذ Quest عبر Remote
                acceptQuest(quest)
                stats.quests = stats.quests + 1
                task.wait(1)
                
                return -- ارجع للأول عشان يتحقق من Quest
            end
            
            -- ═══ 6. يوجد Quest نشط → روح مكان الأعداء ═══
            local mob, dist = findMob(quest.mobName)
            
            if not mob then
                -- لا يوجد عدو → روح لموقع تجمع الأعداء
                stopAttack()
                currentTarget = nil
                
                local distToMobArea = (hrp.Position - quest.mobCFrame.Position).Magnitude
                
                if distToMobArea > 200 then
                    log("✈️ الذهاب لموقع " .. quest.mobName .. " في " .. quest.island)
                    pcall(function()
                        hrp.CFrame = quest.mobCFrame + Vector3.new(0, CFG.TELEPORT_HEIGHT, 0)
                    end)
                    task.wait(2)
                else
                    -- قريب من الموقع لكن ما فيه أعداء → استنى
                    log("⏳ انتظار spawn " .. quest.mobName .. "...")
                    task.wait(2)
                end
                return
            end
            
            -- ═══ 7. وجدنا عدو → جيبه واقتله ═══
            local mr = mob:FindFirstChild("HumanoidRootPart")
            local mh = mob:FindFirstChildOfClass("Humanoid")
            if not mr or not mh then task.wait(0.5); return end
            
            log(string.format("⚔️ %s | HP:%d | Lvl.%d | Dist:%dm",
                quest.mobName, math.floor(mh.Health), getLevel(), math.floor(dist)))
            
            currentTarget = mob
            startAttack()
            
            local killStart = tick()
            
            -- ═══ 8. حلقة القتل (التصق تحت العدو) ═══
            local killConn = RunService.Heartbeat:Connect(function()
                if not (mob and mob.Parent and mh and mh.Health > 0 
                        and mr and mr.Parent and getgenv().BFF_FARM_ACTIVE) then
                    return
                end
                if (tick() - killStart) > CFG.KILL_TIMEOUT then return end
                
                pcall(function()
                    local myHrp = getHRP()
                    if myHrp then
                        -- التصق فوق العدو (أفضل من تحت)
                        myHrp.CFrame = mr.CFrame * CFrame.new(0, CFG.UNDERGROUND_Y, 0)
                    end
                end)
                
                -- جذب الأعداء الأخرى
                if CFG.BRING_MOBS and (tick() - killStart) % 2 < 0.1 then
                    bringMobs(quest.mobName, mr.Position)
                end
            end)
            
            -- ═══ 9. انتظر الموت ═══
            while mob and mob.Parent and mh and mh.Health > 0 
                  and getgenv().BFF_FARM_ACTIVE do
                if (tick() - killStart) > CFG.KILL_TIMEOUT then
                    log("⏰ Timeout للعدو - تخطي")
                    break
                end
                task.wait(0.1)
            end
            
            -- ═══ 10. تنظيف ═══
            if killConn then killConn:Disconnect() end
            stopAttack()
            currentTarget = nil
            
            if not mob or not mob.Parent or (mh and mh.Health <= 0) then
                stats.kills = stats.kills + 1
                log("💀 " .. quest.mobName .. " | Total: " .. stats.kills)
            end
            
            -- ═══ 11. تحقق سريع من Quest بعد القتل ═══
            task.wait(0.3)
            if not hasActiveQuest() then
                log("🎁 Quest مكتمل!")
                -- الحلقة راح ترجع تلقائياً وتاخذ Quest جديد
            end
            
        end)
        
        if not ok then
            warn("⚠️ [FARM ERR] " .. tostring(err))
            stopAttack()
            currentTarget = nil
            task.wait(2)
        end
        
        task.wait(0.2)
    end
end)

-- ═══════════════════════════════════════════════════════════
-- 🧹 GC
-- ═══════════════════════════════════════════════════════════
spawn(function()
    while getgenv().BFF_FARM_ACTIVE do
        task.wait(180)
        pcall(collectgarbage, "collect")
    end
end)

-- ═══════════════════════════════════════════════════════════
-- ✅ جاهز
-- ═══════════════════════════════════════════════════════════
local q = getCurrentQuest()
log("✅ Farm v18.0 - Intelligent Quest System Ready!")
log("🎯 Target: " .. q.mobName .. " @ " .. q.island)
log("📜 Quest: " .. q.questArg1 .. " (" .. q.questArg2 .. ")")

print("╔═══════════════════════════════════════════════╗")
print("║  ✅ BFF FARM v18.0 - INTELLIGENT SYSTEM     ║")
print("║  🎯 " .. q.mobName)
print("║  🏝️ " .. q.island)
print("║  📜 " .. q.questArg1 .. " (Arg " .. q.questArg2 .. ")")
print("║  🌊 Sea " .. getCurrentSea())
print("║  ⭐ Level " .. getLevel())
print("╚═══════════════════════════════════════════════╝")
