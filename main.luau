local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")
local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")

-- EMOTE DATA
local emotes = {
    ["MontagemMysteriousGame"] = {
        AnimationId = "rbxassetid://116903401280934",
        VfxFolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Vfx"):WaitForChild("MontagemMysteriosGame"),
        SoundId = "rbxassetid://105702960085125"
    },
    ["CrabRave"] = {
        AnimationId = "rbxassetid://113266568392185",
        Model = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Misc"):WaitForChild("CrabRave")
    },
    ["The Power"] = {
        AnimationId = "rbxassetid://116005479845915",
        Model = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Misc"):WaitForChild("ThePower")
    }
}

local activeEmote = nil
local track = nil
local spawnedVFX = nil
local spawnedFloor = nil
local spawnedArea = nil
local sound = nil
local connection = nil

local function stopEmote()
    if track then
        track:Stop()
        track:Destroy()
        track = nil
    end
    if sound then
        sound:Stop()
        sound:Destroy()
        sound = nil
    end
    if spawnedVFX then
        spawnedVFX:Destroy()
        spawnedVFX = nil
    end
    if spawnedFloor then
        spawnedFloor:Destroy()
        spawnedFloor = nil
    end
    if spawnedArea then
        spawnedArea:Destroy()
        spawnedArea = nil
    end
    if connection then
        connection:Disconnect()
        connection = nil
    end
    activeEmote = nil
end

local function playEmote(name)
    if activeEmote == name then
        stopEmote()
        return
    end
    stopEmote()
    local data = emotes[name]
    if not data then return end

    if name == "MontagemMysteriousGame" then
        local anim = Instance.new("Animation")
        anim.AnimationId = data.AnimationId
        track = humanoid:LoadAnimation(anim)
        track:Play()

        spawnedFloor = data.VfxFolder:WaitForChild("Floor"):Clone()
        spawnedArea = data.VfxFolder:WaitForChild("Area"):Clone()

        spawnedFloor.Parent = workspace
        spawnedArea.Parent = workspace

        sound = Instance.new("Sound", spawnedArea)
        sound.SoundId = data.SoundId
        sound.Volume = 1
        sound.Looped = true
        sound:Play()

        connection = RunService.RenderStepped:Connect(function()
            if spawnedFloor and hrp then
                spawnedFloor.Position = hrp.Position - Vector3.new(0, 3, 0)
            end
            if spawnedArea and torso then
                spawnedArea.Position = torso.Position
            end
        end)

        activeEmote = name

    elseif name == "CrabRave" then
        local anim = Instance.new("Animation")
        anim.AnimationId = data.AnimationId
        track = humanoid:LoadAnimation(anim)
        track:Play()

        spawnedVFX = data.Model:Clone()
        spawnedVFX.Name = "CrabRaveVFX"
        spawnedVFX.Parent = character

        local vfxRoot = spawnedVFX:FindFirstChild("HumanoidRootPart") or spawnedVFX.PrimaryPart
        if vfxRoot then
            vfxRoot.CFrame = hrp.CFrame
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = hrp
            weld.Part1 = vfxRoot
            weld.Parent = vfxRoot
            vfxRoot.Anchored = false
        end

        sound = spawnedVFX:FindFirstChildWhichIsA("Sound", true)
        if sound then
            sound.Looped = true
            sound:Play()
        end

        activeEmote = name

    elseif name == "The Power" then
        local anim = Instance.new("Animation")
        anim.AnimationId = data.AnimationId
        track = humanoid:LoadAnimation(anim)
        track:Play()

        spawnedVFX = data.Model:Clone()
        spawnedVFX.Name = "ThePowerVFX"
        spawnedVFX.Parent = character

        local function weldToCharacter(partName, targetName)
            local part = spawnedVFX:FindFirstChild(partName)
            local target = character:FindFirstChild(targetName)
            if part and target then
                part.CFrame = target.CFrame
                part.Anchored = false
                local weld = Instance.new("WeldConstraint")
                weld.Part0 = part
                weld.Part1 = target
                weld.Parent = part
            end
        end

        weldToCharacter("LeftArm", "LeftHand")
        weldToCharacter("RightArm", "RightHand")
        weldToCharacter("HumanoidRootPart", "HumanoidRootPart")
        weldToCharacter("Root", "HumanoidRootPart")

        local vfxHRP = spawnedVFX:FindFirstChild("HumanoidRootPart")
        if vfxHRP then
            sound = vfxHRP:FindFirstChildWhichIsA("Sound")
            if sound then
                sound.Looped = true
                sound:Play()
            end
        end

        activeEmote = name
    end
end

-- === DIBAWAH INI BAGIAN GUI === --

if game:GetService("CoreGui"):FindFirstChild("EmoteGuiExecutor") then
    game:GetService("CoreGui").EmoteGuiExecutor:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EmoteGuiExecutor"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 200)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(255, 191, 216)
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
frame.Name = "EmoteFrame"
frame.Active = true
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame

-- Drag Function
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Title
local title = Instance.new("Frame")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = frame.BackgroundColor3
title.BorderSizePixel = 0
title.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = title

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Emotes"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 24
titleLabel.Parent = title

-- Index manual
local buttonIndex = 0

-- Fungsi buat bikin tombol
local function createButton(name, callback)
    buttonIndex += 1
    local yPos = 45 + (buttonIndex - 1) * 45

    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(1, -20, 0, 40)
    shadow.Position = UDim2.new(0, 10, 0, yPos + 4)
    shadow.BackgroundColor3 = Color3.fromRGB(200, 140, 170)
    shadow.BorderSizePixel = 0
    shadow.Parent = frame

    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 15)
    shadowCorner.Parent = shadow

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(255, 182, 205)
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 20
    btn.Text = name
    btn.ClipsDescendants = true
    btn.TextWrapped = true
    btn.TextScaled = true
    btn.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 15)
    btnCorner.Parent = btn

    btn.MouseButton1Click:Connect(callback)
end

-- Contoh tombol dengan fungsi masing-masing
createButton("MontagemMysteriousGame", function() playEmote("MontagemMysteriousGame") end)
createButton("Crab Rave", function() playEmote("CrabRave") end)
createButton("The Power", function() playEmote("The Power") end)
