--====================================
-- TRAVEL MODE AUTO FARM (FIX STOP)
-- Anti-Ragdoll + Auto Travel + Auto Target Ragdoll
-- Rayfield UI
--====================================

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
   Name = "Auto Farm",
   LoadingTitle = "loading...",
   LoadingSubtitle = "by pond",
   ConfigurationSaving = {Enabled = false}
})

local Tab = Window:CreateTab("Main", 4483362458)

---------------------------------------------------
-- Services
---------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local rs = game:GetService("ReplicatedStorage")

local lp = Players.LocalPlayer
local ragRemote = rs:WaitForChild("Ragdoll")

---------------------------------------------------
-- Variables
---------------------------------------------------
local travelMode = false
local speed = 2
local targetX = 9268

-- ป้องกันไม่ให้เปิดกลับเองตอนปิด
local userStopped = false

---------------------------------------------------
-- Anti-Ragdoll Hook
---------------------------------------------------
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()

    if self == ragRemote and method == "FireServer" then
        if travelMode then
            return nil
        end
    end

    return oldNamecall(self, ...)
end)

---------------------------------------------------
-- Function: Force Ragdoll
---------------------------------------------------
local function ForceRagdoll()
    -- ปิด Travel ชั่วคราวให้ล้มได้
    travelMode = false
    task.wait(0.1)

    ragRemote:FireServer()

    Rayfield:Notify({
        Title = "Ragdoll!",
        Content = "ล้มแล้ว กลับบ้าน",
        Duration = 2
    })

    -- รอ 2 วิ แล้วค่อยกลับมาเดินต่อ (ถ้าผู้ใช้ยังไม่ได้ปิด)
    task.wait(2)

    if not userStopped then
        travelMode = true
    end
end

---------------------------------------------------
-- Auto Move +X + Target Check
---------------------------------------------------
RunService.Heartbeat:Connect(function()
    if travelMode then
        local char = lp.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local root = char.HumanoidRootPart

            -- เดินไปทาง +X
            root.CFrame = root.CFrame + Vector3.new(speed, 0, 0)

            -- ถึงเป้าหมาย → ล้มทันที
            if root.Position.X >= targetX then
                ForceRagdoll()
            end
        end
    end
end)

---------------------------------------------------
-- Toggle Travel Mode
---------------------------------------------------
Tab:CreateToggle({
    Name = "🚀 Travel Mode",
    CurrentValue = false,
    Callback = function(Value)

        travelMode = Value

        if Value then
            userStopped = false
            Rayfield:Notify({
                Title = "Travel Mode ON",
                Content = "เริ่มเดินทางแล้ว",
                Duration = 2
            })
        else
            userStopped = true
            travelMode = false

            Rayfield:Notify({
                Title = "Travel Mode OFF",
                Content = "หยุดเดินทางแล้ว",
                Duration = 2
            })
        end
    end
})

---------------------------------------------------
-- Slider Speed
---------------------------------------------------
Tab:CreateSlider({
    Name = "Travel Speed",
    Range = {1, 40},
    Increment = 1,
    CurrentValue = 2,
    Callback = function(Value)
        speed = Value
    end
})

---------------------------------------------------
-- Manual Ragdoll Button
---------------------------------------------------
Tab:CreateButton({
    Name = "💰 Ragdoll Now (กดเอง)",
    Callback = function()
        ForceRagdoll()
    end
})
