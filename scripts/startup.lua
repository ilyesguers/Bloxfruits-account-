--[[
    ══════════════════════════════════════════════
    🔥 BFF - اختيار Marines تلقائياً 🔥
    ══════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════
-- إشعار البداية
-- ═══════════════════════════════════════
StarterGui:SetCore("SendNotification", {
    Title = "⚓ BFF Marines";
    Text = "جاري البحث عن زر Marines...";
    Duration = 3;
})

-- ═══════════════════════════════════════
-- الطريقة 1: استدعاء الـ Remote مباشرة
-- ═══════════════════════════════════════
local function TryRemote()
    local success = pcall(function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Marine")
    end)
    return success
end

-- ═══════════════════════════════════════
-- الطريقة 2: الضغط على الزر يدوياً
-- ═══════════════════════════════════════
local function TryClickButton()
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
    if not PlayerGui then return false end
    
    -- ابحث في كل الـ GUI
    for _, gui in pairs(PlayerGui:GetDescendants()) do
        if gui:IsA("TextButton") or gui:IsA("ImageButton") or gui:IsA("Frame") then
            local name = gui.Name:lower()
            local text = ""
            
            if gui:IsA("TextButton") then
                text = (gui.Text or ""):lower()
            end
            
            -- إذا الاسم أو النص فيه "marine"
            if name:find("marine") or text:find("marine") then
                print("🎯 [BFF] وجد زر Marines: " .. gui:GetFullName())
                
                -- محاولة الضغط
                pcall(function()
                    -- تشغيل حدث الضغط
                    for _, connection in pairs(getconnections(gui.MouseButton1Click or gui.Activated)) do
                        connection:Fire()
                    end
                end)
                
                -- محاولة ثانية: firesignal
                pcall(function()
                    if gui:IsA("TextButton") or gui:IsA("ImageButton") then
                        firesignal(gui.MouseButton1Click)
                        firesignal(gui.Activated)
                    end
                end)
                
                return true
            end
        end
    end
    return false
end

-- ═══════════════════════════════════════
-- المحاولات المتعددة
-- ═══════════════════════════════════════
spawn(function()
    local attempts = 0
    local maxAttempts = 30
    
    while attempts < maxAttempts do
        attempts = attempts + 1
        
        print("🔄 [BFF] محاولة " .. attempts .. "/" .. maxAttempts)
        
        -- جرب الطريقة 1
        if TryRemote() then
            print("✅ [BFF] Marines تم اختياره عبر Remote!")
            StarterGui:SetCore("SendNotification", {
                Title = "✅ Marines";
                Text = "تم اختيار Marines بنجاح!";
                Duration = 5;
            })
            break
        end
        
        -- جرب الطريقة 2
        if TryClickButton() then
            print("✅ [BFF] Marines تم الضغط عليه!")
            StarterGui:SetCore("SendNotification", {
                Title = "✅ Marines";
                Text = "تم الضغط على زر Marines!";
                Duration = 5;
            })
            wait(2)
            -- تأكيد
            TryRemote()
            break
        end
        
        wait(1)
    end
    
    if attempts >= maxAttempts then
        warn("❌ [BFF] فشلت جميع المحاولات")
        StarterGui:SetCore("SendNotification", {
            Title = "❌ فشل";
            Text = "لم يتم العثور على زر Marines";
            Duration = 5;
        })
    end
end)

print("✅ [BFF] Marines Script Started")
