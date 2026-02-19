-- ══════════════════════════════════════
--   Simple AimBot Button Script
--   زر AimBot بسيط وسريع
-- ══════════════════════════════════════

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")

local player  = Players.LocalPlayer
local Camera  = workspace.CurrentCamera

-- ══════════════════════════════════════
--   SETTINGS
-- ══════════════════════════════════════
local AimBot    = false
local AimPart   = "Head"      -- Head / HumanoidRootPart
local AimSmooth = 0.2         -- 0.1 = سريع | 0.5 = بطيء
local TeamCheck = true        -- تجاهل الفريق نفسه

-- ══════════════════════════════════════
--   HELPERS
-- ══════════════════════════════════════
local function getCharacter()
    return player.Character
end

local function isEnemy(p)
    if p == player then return false end
    if not p.Character then return false end
    local hum = p.Character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if TeamCheck and p.Team == player.Team then return false end
    return true
end

local function getNearest()
    local nearest   = nil
    local bestDist  = math.huge

    for _, p in ipairs(Players:GetPlayers()) do
        if isEnemy(p) then
            local part = p.Character:FindFirstChild(AimPart)
                      or p.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local mouse = UserInputService:GetMouseLocation()
                    local dist  = (Vector2.new(sp.X, sp.Y) - mouse).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        nearest  = p
                    end
                end
            end
        end
    end

    return nearest
end

-- ══════════════════════════════════════
--   AIM LOOP
-- ══════════════════════════════════════
RunService.RenderStepped:Connect(function()
    if not AimBot then return end

    local target = getNearest()
    if not target or not target.Character then return end

    local part = target.Character:FindFirstChild(AimPart)
              or target.Character:FindFirstChild("HumanoidRootPart")
    if not part then return end

    local goal = CFrame.new(Camera.CFrame.Position, part.Position)
    Camera.CFrame = Camera.CFrame:Lerp(goal, AimSmooth)
end)

-- ══════════════════════════════════════
--   GUI
-- ══════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "AimBotBtn"
ScreenGui.ResetOnSpawn   = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent         = player:WaitForChild("PlayerGui")

-- الزر الرئيسي
local Btn = Instance.new("TextButton")
Btn.Size            = UDim2.new(0, 120, 0, 50)
Btn.Position        = UDim2.new(0, 20, 0.5, -25)
Btn.BackgroundColor3= Color3.fromRGB(20, 20, 30)
Btn.TextColor3      = Color3.fromRGB(255, 255, 255)
Btn.Text            = "🎯 AimBot\nOFF"
Btn.Font            = Enum.Font.GothamBold
Btn.TextSize        = 16
Btn.BorderSizePixel = 0
Btn.Active          = true
Btn.Draggable       = true
Btn.Parent          = ScreenGui

-- زوايا مدورة
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 14)
Corner.Parent       = Btn

-- إطار ملون
local Stroke = Instance.new("UIStroke")
Stroke.Color     = Color3.fromRGB(150, 50, 50)
Stroke.Thickness = 2.5
Stroke.Parent    = Btn

-- ══════════════════════════════════════
--   TOGGLE LOGIC
-- ══════════════════════════════════════
local function setAim(state)
    AimBot = state

    -- ألوان ON / OFF
    local onColor  = Color3.fromRGB(0, 180, 80)
    local offColor = Color3.fromRGB(20, 20, 30)
    local onStroke = Color3.fromRGB(0, 220, 100)
    local offStroke= Color3.fromRGB(150, 50, 50)

    TweenService:Create(Btn, TweenInfo.new(0.25), {
        BackgroundColor3 = state and onColor or offColor,
    }):Play()

    TweenService:Create(Stroke, TweenInfo.new(0.25), {
        Color = state and onStroke or offStroke,
    }):Play()

    Btn.Text = state and "🎯 AimBot\nON" or "🎯 AimBot\nOFF"
end

Btn.MouseButton1Click:Connect(function()
    setAim(not AimBot)
end)

-- ══════════════════════════════════════
--   TARGET INDICATOR (اسم العدو المستهدف)
-- ══════════════════════════════════════
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size               = UDim2.new(0, 120, 0, 22)
InfoLabel.Position           = UDim2.new(0, 0, 1, 6)
InfoLabel.BackgroundColor3   = Color3.fromRGB(0, 0, 0)
InfoLabel.BackgroundTransparency = 0.4
InfoLabel.TextColor3         = Color3.fromRGB(255, 220, 80)
InfoLabel.Font               = Enum.Font.Gotham
InfoLabel.TextSize           = 12
InfoLabel.Text               = ""
InfoLabel.BorderSizePixel    = 0
InfoLabel.Parent             = Btn

local InfoCorner = Instance.new("UICorner")
InfoCorner.CornerRadius = UDim.new(0, 8)
InfoCorner.Parent       = InfoLabel

-- تحديث اسم الهدف
RunService.Heartbeat:Connect(function()
    if AimBot then
        local t = getNearest()
        InfoLabel.Text = t and ("→ " .. t.Name) or "No Target"
    else
        InfoLabel.Text = ""
    end
end)

print("[AimBot] Loaded! اضغط الزر لتفعيل AimBot")
