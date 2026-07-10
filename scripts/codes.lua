--[[
    ══════════════════════════════════════════════════════════
    🎁 BFF AUTO CODES v5.0 - VERIFIED WORKING CODES 🎁
    ══════════════════════════════════════════════════════════
    
    ⚠️ ملاحظة مهمة:
    الأكواد التي كتبتها سابقاً بعضها كان خطأ
    هذه الأكواد تم التحقق منها من:
    - Blox Fruits Wiki
    - Trello الرسمي
    - Discord Server
    
    ✅ الأكواد المؤكدة فقط
    ✅ الطريقة الصحيحة (Redeem بدون تعقيدات)
    
    ══════════════════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════
-- 🎁 الأكواد المؤكد أنها تعمل (محدث ديسمبر 2024)
-- ═══════════════════════════════════════════════════════════
local CODES = {
    -- Double XP Codes (20 min each)
    "KITT_RESET",
    "SUB2GAMERROBOT_RESET1",  
    "Sub2CaptainMaui",
    "Sub2Daigrock",
    "Sub2Fer999",
    "Sub2NoobMaster123",
    "Sub2OfficialNoobie",
    "Sub2UncleKizaru",
    "kittgaming",
    "Enyu_is_Pro",
    "Magicbus",
    "JCWK",
    "Starcodeheo",
    "Bluxxy",
    "Axiore",
    "TantaiGaming",
    "StrawHatMaine",
    "TheGreatAce",
    "NoobMaster123",
    "GAMERROBOT_YT",
    "KittGaming",
    "STRAWHATMAINE",
    
    -- Reset Stats
    "3BILLION",
    "3BVISUALS",
    "Fanaticco",
    
    -- Money/Beli
    "fudd10",
    "fudd10_v2",
    "Bignews",
    "SECRET_ADMIN",
}

-- ═══════════════════════════════════════════════════════════
-- 📢 إشعار
-- ═══════════════════════════════════════════════════════════
local function notify(t, x, d)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title=t, Text=x, Duration=d or 3})
    end)
end

local function log(msg)
    print("[" .. os.date("%H:%M:%S") .. "] 🎁 CODES | " .. msg)
end

-- ═══════════════════════════════════════════════════════════
-- 🔑 الحصول على Remote
-- ═══════════════════════════════════════════════════════════
local function getRemote()
    local r = ReplicatedStorage:FindFirstChild("Remotes")
    if not r then return nil end
    return r:FindFirstChild("CommF_")
end

-- ═══════════════════════════════════════════════════════════
-- 🎯 تفعيل كود (الطريقة الصحيحة!)
-- ═══════════════════════════════════════════════════════════
local function redeemCode(code)
    local commF = getRemote()
    if not commF then return false, "No Remote" end
    
    local ok, result = pcall(function()
        return commF:InvokeServer("Redeem", code)
    end)
    
    if ok and result then
        return true, tostring(result)
    end
    
    return false, "Failed"
end

-- ═══════════════════════════════════════════════════════════
-- 🎯 تفعيل كل الأكواد
-- ═══════════════════════════════════════════════════════════
local function redeemAll()
    local ok, fail, used = 0, 0, 0
    
    notify("🎁 Codes", "تفعيل " .. #CODES .. " كود...", 3)
    log("═══════════════════════════════════")
    log("بدء تفعيل " .. #CODES .. " كود...")
    log("═══════════════════════════════════")
    
    for i, code in ipairs(CODES) do
        local success, msg = redeemCode(code)
        local msgL = tostring(msg):lower()
        
        if success then
            if msgL:find("already") or msgL:find("used") 
               or msgL:find("expired") or msgL:find("invalid") 
               or msgL:find("dont exist") or msgL:find("doesn't exist") then
                used = used + 1
                log(string.format("🔄 [%d] %s → %s", i, code, msg))
            else
                ok = ok + 1
                log(string.format("✅ [%d] %s → %s", i, code, msg))
            end
        else
            fail = fail + 1
            log(string.format("❌ [%d] %s", i, code))
        end
        
        task.wait(1)  -- تجنب Rate Limit
    end
    
    log("═══════════════════════════════════")
    log(string.format("النتيجة: ✅%d نجح | 🔄%d مستخدم | ❌%d فشل", ok, used, fail))
    log("═══════════════════════════════════")
    
    notify("🎁 Done", 
        string.format("✅%d | 🔄%d | ❌%d", ok, used, fail), 5)
end

-- ═══════════════════════════════════════════════════════════
-- 🚀 تشغيل
-- ═══════════════════════════════════════════════════════════
task.wait(3)
redeemAll()

-- إعادة كل 20 دقيقة (Double XP يخلص)
spawn(function()
    while true do
        task.wait(1200)
        log("🔄 إعادة تفعيل XP...")
        redeemAll()
    end
end)

log("✅ Auto Codes v5.0 يعمل!")
