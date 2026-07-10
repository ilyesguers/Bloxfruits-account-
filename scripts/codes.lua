--[[
    ══════════════════════════════════════════════════════════
    🎁 BFF AUTO CODES v4.0 - UPDATE 25 METHOD 🎁
    ══════════════════════════════════════════════════════════
    
    ✅ الطريقة الجديدة تماماً (Update 25 - P.V.P Update)
    ✅ نوعان من الأكواد:
       - أكواد عادية → Remote "Redeem"
       - أكواد DLC → Remote منفصل
    ✅ كل الأكواد الشغالة (تم التحقق من ديسمبر 2024)
    
    ══════════════════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════
-- 🎁 الأكواد الشغالة (محدثة - ديسمبر 2024)
-- ═══════════════════════════════════════════════════════════
local WORKING_CODES = {
    -- ═══ Double XP (20-30 دقيقة) ═══
    "UPD25",
    "UPDATE25",
    "STRAWHATMAINE",
    "KITT_RESET",
    "REWARD_YOU",
    "REWARD_JCWK",
    "REWARD_BLUXXY",
    "REWARD_ENYU",
    "kittgaming",
    "Sub2Fer999",
    "Enyu_is_Pro",
    "Magicbus",
    "JCWK",
    "Starcodeheo",
    "Bluxxy",
    "Sub2CaptainMaui",
    "Axiore",
    "TantaiGaming",
    "StrawHatMaine",
    "TheGreatAce",
    "Sub2UncleKizaru",
    "NoobMaster123",
    "GAMERROBOT_YT",
    
    -- ═══ Money ═══
    "fudd10",
    "fudd10_v2",
    "Bignews",
    
    -- ═══ Reset Stats ═══
    "3BILLION",
    "3BVISUALS",
    "Fanaticco",
    "PVPPPP",
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
-- 🔧 الحصول على Remote الصحيح
-- ═══════════════════════════════════════════════════════════
local function getCommE()
    -- في Update 25, أكواد بعضها انتقلت لـ CommE_
    local r = ReplicatedStorage:FindFirstChild("Remotes")
    return r and r:FindFirstChild("CommE_")
end

local function getCommF()
    local r = ReplicatedStorage:FindFirstChild("Remotes")
    return r and r:FindFirstChild("CommF_")
end

-- ═══════════════════════════════════════════════════════════
-- 🎯 تفعيل كود (كل الطرق المعروفة)
-- ═══════════════════════════════════════════════════════════
local function redeemCode(code)
    local success = false
    local result = ""
    
    -- الطريقة 1: CommF_ Redeem (الأصلية)
    local commF = getCommF()
    if commF then
        pcall(function()
            local r = commF:InvokeServer("Redeem", code)
            if r then
                success = true
                result = tostring(r)
            end
        end)
    end
    
    if success and not result:lower():find("invalid") then
        return true, result
    end
    
    -- الطريقة 2: CommE_ Redeem (Update 25)
    local commE = getCommE()
    if commE then
        pcall(function()
            if commE:IsA("RemoteFunction") then
                local r = commE:InvokeServer("Redeem", code)
                if r then success = true; result = tostring(r) end
            elseif commE:IsA("RemoteEvent") then
                commE:FireServer("Redeem", code)
                success = true
                result = "Fired"
            end
        end)
    end
    
    if success and not result:lower():find("invalid") then
        return true, result
    end
    
    -- الطريقة 3: RedeemCode
    if commF then
        pcall(function()
            local r = commF:InvokeServer("RedeemCode", code)
            if r then success = true; result = tostring(r) end
        end)
    end
    
    return success, result
end

-- ═══════════════════════════════════════════════════════════
-- 🎯 تفعيل كل الأكواد
-- ═══════════════════════════════════════════════════════════
local function redeemAll()
    local ok, fail, used = 0, 0, 0
    
    notify("🎁 Codes", "تفعيل " .. #WORKING_CODES .. " كود...", 3)
    log("═══════════════════════════════════")
    log("بدء تفعيل الأكواد...")
    
    for i, code in ipairs(WORKING_CODES) do
        local success, msg = redeemCode(code)
        local msgLower = tostring(msg):lower()
        
        if success then
            if msgLower:find("already") or msgLower:find("used") 
               or msgLower:find("expired") or msgLower:find("invalid") then
                used = used + 1
                log(string.format("🔄 [%d/%d] %s → %s", i, #WORKING_CODES, code, msg))
            else
                ok = ok + 1
                log(string.format("✅ [%d/%d] %s → %s", i, #WORKING_CODES, code, msg))
            end
        else
            fail = fail + 1
            log(string.format("❌ [%d/%d] %s", i, #WORKING_CODES, code))
        end
        
        task.wait(1)
    end
    
    log("═══════════════════════════════════")
    log(string.format("✅ نجح: %d | 🔄 مستخدم: %d | ❌ فشل: %d", ok, used, fail))
    
    notify("🎁 Codes Done", 
        string.format("✅%d | 🔄%d | ❌%d", ok, used, fail), 5)
    
    return ok, used, fail
end

-- ═══════════════════════════════════════════════════════════
-- 🚀 تشغيل
-- ═══════════════════════════════════════════════════════════
task.wait(3)
redeemAll()

-- إعادة تفعيل XP كل 20 دقيقة
spawn(function()
    while true do
        task.wait(1200)
        log("🔄 إعادة تفعيل Double XP...")
        redeemAll()
    end
end)

log("✅ Auto Codes v4.0 يعمل!")
