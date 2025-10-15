-- 1. โหลด Universal Anti-Cheat Bypass
loadstring(game:HttpGet("https://raw.githubusercontent.com/Next1x/Nextix./main/UniversalACBypass"))()

-- 2. Hook ฟังก์ชัน 'observeTag' เพื่อปิดการเฝ้าระวังของ AC
local hk = false
for _, v in pairs(getgc(true)) do
    if typeof(v) == "table" then
        local fn = rawget(v, "observeTag")
        if typeof(fn) == "function" and not hk then
            hk = true
            hookfunction(fn, newcclosure(function(_, _)
                return {
                    Disconnect = function() end,
                    disconnect = function() end
                }
            end))
        end
    end
end

-- 3. เตรียมตัวแปรและยูทิลิตี้สำหรับ Deep Scan
local scanned = {} -- ป้องกันลูปไม่รู้จบ
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local Players = cloneref(game:GetService("Players"))
local FindFunc = loadstring(game:HttpGet("https://raw.githubusercontent.com/Awakenchan/GcViewerV2/refs/heads/main/Utility/FindFunction.lua"))()
local Class,Default = loadstring(game:HttpGet("https://raw.githubusercontent.com/Awakenchan/GcViewerV2/refs/heads/main/Utility/Data2Code%40Amity.lua"))()
getgenv().Log = getgenv().Log or function(...) print(...) end
local PlayerName = game.Players.LocalPlayer.Name

-- 4. ฟังก์ชันสำหรับ Hook RemoteEvent ที่อาจเป็นช่องทางสื่อสารของ AC
local function hookRemote(remote)
    if remote:IsA("RemoteEvent") then
        local oldFire
        oldFire = hookfunction(remote.FireServer, function(self, ...)
            local args = {...}
            -- ตรวจจับและบล็อกสัญญาณ 'x-15' หรือ 'x-16' (สัญญาณ AC)
            if args[1] and (tostring(args[1]):lower() == "x-15" or tostring(args[1]) == "X-15") or (tostring(args[1]):lower() == "x-16" or tostring(args[1]) == "X-16") then
                return task.wait(9e9) -- หยุดการส่งข้อมูล
            end
            return oldFire(self, unpack(args))
        end)
    end
end

local function isRemote(obj)
    return typeof(obj) == "Instance" and obj:IsA("RemoteEvent")
end

-- 5. ฟังก์ชันสแกนลึก (Deep Scan) เพื่อหา RemoteEvent ที่ซ่อนอยู่และ Hook ฟังก์ชันอื่นๆ
local function deepScan(value)
    if scanned[value] then return end
    scanned[value] = true

    if isRemote(value) then
        -- Hook RemoteEvent ที่ไม่ได้อยู่ใน ReplicatedStorage (อาจเป็น AC)
        if not value:IsDescendantOf(ReplicatedStorage) then
            hookRemote(value)
            -- Hook coroutine.wrap เพื่อปิดการทำงานของ AC พื้นฐาน
            local Old 
            Old = hookfunction(getrenv().coroutine.wrap, function(...)
                if not checkcaller() then -- ถ้าไม่ใช่โค้ดที่รันโดยผู้ใช้
                    print(...,getfenv(2).script)
                    return task.wait(9e9) -- หยุดการทำงาน
                end
                return Old(...)
            end)
        end
        return
    end

    -- สแกนต่อใน upvalues ของฟังก์ชันและในตาราง (tables)
    if typeof(value) == "function" then
        local upvalues = getupvalues(value)
        for i, v in pairs(upvalues) do
            deepScan(v)
        end
    end
    if typeof(value) == "table" then
        for k, v in pairs(value) do
            deepScan(v)
        end
    end
end

-- 6. เริ่มการสแกนทุกฟังก์ชันในหน่วยความจำ (GC)
for _, obj in next, getgc(true) do
    if typeof(obj) == "function" and islclosure(obj) and not isexecutorclosure(obj) then
        deepScan(obj)
    end
end
