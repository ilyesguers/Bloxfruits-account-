--[[
    ══════════════════════════════════════════════════════════
    🎁 BFF AUTO CODES v3.0 - UPDATE 24 METHOD 🎁
    ══════════════════════════════════════════════════════════
    
    ✅ الطريقة الجديدة: Settings → Redeem DLC Code
    ✅ يعمل بدون فتح أي قائمة
    ✅ كل الأكواد الشغالة محدثة
    ✅ إعادة تفعيل Double XP كل 20 دقيقة
    
    ══════════════════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════
-- 🎁 الأكواد الشغالة (محدثة - Update 24 / v31.2)
-- ═══════════════════════════════════════════════════════════
local CODES = {
    -- ═══ Double XP (20 دقيقة) ═══
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
    "NoobMaster123",
    "KittGaming",
    "STRAWHATMAINE",
    "GAMERROBOT_YT",
    
    -- ═══ Money ═══
    "fudd10",
    "fudd10_v2",
    "Bignews",
    
    -- ═══ Reset Stats ═══
    "Sub2UncleKizaru",
    "KITT_RESET",
    "3BVISUALS",
    "Fanaticco",
}

-- ═══════════════════════════════════════════════════════════
-- 🔑 الطريقة الرئيسية: عبر Remote (CommF_)
-- ═══════════════════════════════════════════════════════════
local function getRemote()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if not remotes then return nil end
    return remotes:FindFirstChild("CommF_")
end

local function redeemCodeViaRemote(code)
    local commF = getRemote()
    if not commF then return false, "No Remote" end
    
    local success = false
    local message = "Unknown"
    
    -- الطريقة 1: Redeem (الأكثر شيوعاً)
    pcall(function()
        local result = commF:InvokeServer("Redeem", code)
        if result then
            success = true
            message = tostring(result)
        end
    end)
    
    if success then return true, message end
    
    -- الطريقة 2: RedeemCode
    pcall(function()
        local result = commF:InvokeServer("RedeemCode", code)
        if result then
            success = true
            message = tostring(result)
        end
    end)
    
    if success then return true, message end
    
    -- الطريقة 3: Code
    pcall(function()
        local result = commF:InvokeServer("Code", code)
        if result then
            success = true
            message = tostring(result)
        end
    end)
    
    if success then return true, message end
    
    -- الطريقة 4: DLC Code (الطريقة الجديدة في Update 24)
    pcall(function()
        local result = commF:InvokeServer("RedeemDLCCode", code)
        if result then
            success = true
            message = tostring(result)
        end
    end)
    
    return success, message
end

-- ═══════════════════════════════════════════════════════════
-- 🖱️ الطريقة 2: عبر GUI (Settings → Redeem DLC Code)
-- ═══════════════════════════════════════════════════════════
local function redeemCodeViaGUI(code)
    local success = false
    
    pcall(function()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then return end
        
        -- ابحث عن TextBox الخاص بالأكواد
        for _, obj in pairs(playerGui:GetDescendants()) do
            if obj:IsA("TextBox") then
                local parent = obj.Parent
                local parentParent = parent and parent.Parent
                
                -- ابحث عن TextBox قريب من زر Redeem
                local hasRedeemButton = false
                if parent then
                    for _, sibling in pairs(parent:GetChildren()) do
                        if sibling:IsA("TextButton") or sibling:IsA("ImageButton") then
                            local btnText = ""
                            pcall(function()
                                if sibling:IsA("TextButton") then
                                    btnText = sibling.Text:lower()
                                end
                                for _, child in pairs(sibling:GetChildren()) do
                                    if child:IsA("TextLabel") then
                                        btnText = child.Text:lower()
                                    end
                                end
                            end)
                            if btnText:find("redeem") then
                                hasRedeemButton = true
                            end
                        end
                    end
                end
                
                if parentParent then
                    for _, sibling in pairs(parentParent:GetChildren()) do
                        if sibling:IsA("TextButton") or sibling:IsA("ImageButton") then
                            local btnText = ""
                            pcall(function()
                                if sibling:IsA("TextButton") then
                                    btnText = sibling.Text:lower()
                                end
                            end)
                            if btnText:find("redeem") then
                                hasRedeemButton = true
                            end
                        end
                    end
                end
                
                -- إذا لقينا TextBox مع زر Redeem
                if hasRedeemButton then
                    -- ضع الكود في TextBox
                    obj.Text = code
                    task.wait(0.2)
                    
                    -- اضغط زر Redeem
                    if parent then
                        for _, btn in pairs(parent:GetChildren()) do
                            if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                                pcall(function()
                                    firesignal(btn.MouseButton1Click)
                                end)
                                pcall(function()
                                    firesignal(btn.Activated)
                                end)
                                pcall(function()
                                    for _, conn in pairs(getconnections(btn.MouseButton1Click)) do
                                        conn:Fire()
                                    end
                                end)
                            end
                        end
                    end
                    
                    success = true
                end
            end
        end
    end)
    
    return success
end

-- ═══════════════════════════════════════════════════════════
-- 🔍 الطريقة 3: البحث في كل الـ Remotes
-- ═══════════════════════════════════════════════════════════
local function redeemCodeBruteForce(code)
    local success = false
    
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if not remotes then return end
        
        for _, remote in pairs(remotes:GetDescendants()) do
            if remote:IsA("RemoteFunction") then
                pcall(function()
                    local result = remote:InvokeServer("Redeem", code)
                    if result and tostring(result):lower():find("success") then
                        success = true
                    end
                end)
                
                pcall(function()
                    local result = remote:InvokeServer("RedeemCode", code)
                    if result and tostring(result):lower():find("success") then
                        success = true
                    end
                end)
            end
            
            if remote:IsA("RemoteEvent") then
                pcall(function()
                    remote:FireServer("Redeem", code)
                end)
                pcall(function()
                    remote:FireServer("RedeemCode", code)
                end)
            end
        end
    end)
    
    return success
end

-- ═══════════════════════════════════════════════════════════
-- 🎯 تفعيل كود واحد (يجرب كل الطرق)
-- ═══════════════════════════════════════════════════════════
local function redeemCode(code)
    -- الطريقة 1: Remote المباشر
    local ok1, msg1 = redeemCodeViaRemote(code)
    if ok1 then return true, msg1 end
    
    -- الطريقة 2: GUI
    local ok2 = redeemCodeViaGUI(code)
    if ok2 then return true, "GUI Success" end
    
    -- الطريقة 3: Brute Force
    local ok3 = redeemCodeBruteForce(code)
    if ok3 then return true, "BruteForce Success" end
    
    return false, "All methods failed"
end

-- ═══════════════════════════════════════════════════════════
-- 🎯 تفعيل كل الأكواد
-- ═══════════════════════════════════════════════════════════
local function redeemAllCodes()
    local successCount = 0
    local failCount = 0
    local alreadyCount = 0
    
    notify("🎁 Auto Codes", "جاري تفعيل " .. #CODES .. " كود...", 3)
    
    print("╔═══════════════════════════════════╗")
    print("║  🎁 BFF AUTO CODES v3.0          ║")
    print("║  " .. #CODES .. " أكواد                     ║")
    print("╚═══════════════════════════════════╝")
    
    for i, code in ipairs(CODES) do
        local ok, msg = redeemCode(code)
        
        if ok then
            local msgLower = tostring(msg):lower()
            if msgLower:find("already") or msgLower:find("used") or msgLower:find("expired") then
                alreadyCount = alreadyCount + 1
                print("🔄 [" .. i .. "/" .. #CODES .. "] " .. code .. " → مستخدم/منتهي")
            else
                successCount = successCount + 1
                print("✅ [" .. i .. "/" .. #CODES .. "] " .. code .. " → " .. tostring(msg))
            end
        else
            failCount = failCount + 1
            print("❌ [" .. i .. "/" .. #CODES .. "] " .. code .. " → " .. tostring(msg))
        end
        
        task.wait(0.8)
    end
    
    print("═══════════════════════════════════")
    print("✅ نجح: " .. successCount)
    print("🔄 مستخدم: " .. alreadyCount)
    print("❌ فشل: " .. failCount)
    print("═══════════════════════════════════")
    
    notify("🎁 Codes Done", 
        "✅ نجح: " .. successCount .. " | 🔄 مستخدم: " .. alreadyCount .. " | ❌ فشل: " .. failCount, 5)
end

-- ═══════════════════════════════════════════════════════════
-- 🚀 تشغيل
-- ═══════════════════════════════════════════════════════════
task.wait(3)
redeemAllCodes()

-- إعادة تفعيل Double XP كل 20 دقيقة
spawn(function()
    while true do
        task.wait(1200)
        print("🔄 [CODES] إعادة تفعيل Double XP...")
        redeemAllCodes()
    end
end)

print("✅ [CODES] Auto Redeem v3.0 يعمل!")
