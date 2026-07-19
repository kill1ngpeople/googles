

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local enabled = false
local highlights = {}

local Scripted = workspace:WaitForChild("Scripted")
local Other = Scripted:WaitForChild("Other")

local VendingFolder = Other:WaitForChild("VendingMachine")
local ItemSpawner = Scripted:WaitForChild("ItemSpawner")
local Interactable = Scripted:WaitForChild("Interactable")

--------------------------------------------------
-- Highlight Helper
--------------------------------------------------

local function getHighlightTarget(obj)
    if obj:IsA("Model") then
        return obj
    end

    local model = obj:FindFirstAncestorOfClass("Model")
    if model then
        return model
    end

    if obj:IsA("BasePart") then
        return obj
    end

    return nil
end

local function addHighlight(obj, color)
    local target = getHighlightTarget(obj)
    if not target then return end
    if highlights[target] then return end

    local highlight = Instance.new("Highlight")
    highlight.Adornee = target
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = color
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = target

    highlights[target] = highlight
end

local function removeAllHighlights()
    for _, highlight in pairs(highlights) do
        highlight:Destroy()
    end
    highlights = {}
end

--------------------------------------------------
-- Scan Folder
--------------------------------------------------

local function scanFolder(folder, color)
    for _, descendant in pairs(folder:GetDescendants()) do
        addHighlight(descendant, color)
    end
end

local function trackFolder(folder, color)
    folder.DescendantAdded:Connect(function(descendant)
        if enabled then
            task.wait(0.05)
            addHighlight(descendant, color)
        end
    end)
end

--------------------------------------------------
-- Setup Tracking
--------------------------------------------------

trackFolder(VendingFolder, Color3.fromRGB(0,255,0))     -- Green
trackFolder(ItemSpawner, Color3.fromRGB(0,170,255))     -- Blue
trackFolder(Interactable, Color3.fromRGB(255,170,0))    -- Orange

--------------------------------------------------
-- Toggle
--------------------------------------------------

local function enableESP()
    scanFolder(VendingFolder, Color3.fromRGB(0,255,0))
    scanFolder(ItemSpawner, Color3.fromRGB(0,170,255))
    scanFolder(Interactable, Color3.fromRGB(255,170,0))
    print("Dev Vision Enabled")
end

local function disableESP()
    removeAllHighlights()
    print("Dev Vision Disabled")
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    if input.KeyCode == Enum.KeyCode.V then
        enabled = not enabled

        if enabled then
            enableESP()
        else
            disableESP()
        end
    end
end)
-------------------
--Vending/Item Esp [V]
------------------
