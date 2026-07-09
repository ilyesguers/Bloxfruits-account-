--[[
    ══════════════════════════════════════════════
    🔍 BFF Explorer - اكتشاف أزرار الفرق 🔍
    ══════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

local RAILWAY_URL = "https://bloxfruits-account-production.up.railway.app"

wait(2)

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local results = {}

-- اكتشف كل عنصر GUI فيه كلمة marine أو pirate
for _, obj in pairs(PlayerGui:GetDescendants()) do
    local name = obj.Name:lower()
    local text = ""
    
    pcall(function()
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            text = (obj.Text or ""):lower()
        end
    end)
    
    if name:find("marine") or name:find("pirate") or name:find("team") 
       or name:find("side") or name:find("choose") or name:find("pick")
       or text:find("marine") or text:find("pirate") then
        
        local info = {
            Name = obj.Name,
            ClassName = obj.ClassName,
            FullPath = obj:GetFullName(),
            Text = text,
            Visible = tostring(obj.Visible or "N/A")
        }
        table.insert(results, info)
        print("🔎 [" .. obj.ClassName .. "] " .. obj:GetFullName() .. " | Text: '" .. text .. "'")
    end
end

-- ابحث أيضاً عن الـ Remotes في ReplicatedStorage
local ReplicatedStorage = game:GetService("ReplicatedStorage")
print("═══════════════════════════════════════")
print("📡 REMOTES في ReplicatedStorage:")
print("═══════════════════════════════════════")

local remotesFound = {}
for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        local n = obj.Name:lower()
        if n:find("team") or n:find("marine") or n:find("pirate") 
           or n:find("comm") or n:find("side") then
            table.insert(remotesFound, obj:GetFullName())
            print("📡 " .. obj.ClassName .. ": " .. obj:GetFullName())
        end
    end
end

print("═══════════════════════════════════════")
print("✅ تم العثور على " .. #results .. " عنصر GUI")
print("✅ تم العثور على " .. #remotesFound .. " Remote")
print("═══════════════════════════════════════")

-- إرسال النتائج للسيرفر
local payload = {
    username = LocalPlayer.Name,
    guiResults = results,
    remotes = remotesFound
}

pcall(function()
    local req = http_request or request or (syn and syn.request)
    if req then
        req({
            Url = RAILWAY_URL .. "/explore",
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(payload)
        })
    end
end)

StarterGui:SetCore("SendNotification", {
    Title = "🔍 Explorer";
    Text = "تم إرسال " .. #results .. " عنصر للسيرفر";
    Duration = 5;
})

print("✅ تم إرسال البيانات، افتح: " .. RAILWAY_URL .. "/explore-results")
