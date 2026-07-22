--// Services
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

--// SETTINGS
local ESP_ENABLED = true
local ENEMY_COLOR = Color3.fromRGB(255, 80, 80)
local FRIEND_COLOR = Color3.fromRGB(80, 255, 80)

--// Cache
local ESP_CACHE = {}

--// Apply color based on teams
local function updateColor(player, highlight)
	if not highlight or not player then return end
	
	if player.Team ~= LocalPlayer.Team then
		highlight.FillColor = ENEMY_COLOR
		highlight.OutlineColor = ENEMY_COLOR
	else
		highlight.FillColor = FRIEND_COLOR
		highlight.OutlineColor = FRIEND_COLOR
	end
end

--// Create ESP
local function createESP(player, character)
	if player == LocalPlayer then return end
	if ESP_CACHE[player] then return end
	if not character then return end

	local highlight = Instance.new("Highlight")
	highlight.Name = "TEAM_ESP"
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillTransparency = 0.75
	highlight.OutlineTransparency = 0
	highlight.Adornee = character
	highlight.Parent = game:GetService("CoreGui") -- more stable

	updateColor(player, highlight)

	ESP_CACHE[player] = highlight
end

--// Remove ESP
local function removeESP(player)
	if ESP_CACHE[player] then
		ESP_CACHE[player]:Destroy()
		ESP_CACHE[player] = nil
	end
end

--// Character handling
local function onCharacter(player, character)
	if not ESP_ENABLED then return end

	-- Wait until humanoid exists (fully loaded character)
	local humanoid = character:WaitForChild("Humanoid", 5)
	if not humanoid then return end

	createESP(player, character)

	humanoid.Died:Connect(function()
		removeESP(player)
	end)
end

--// Player setup
local function onPlayer(player)

	player.CharacterAdded:Connect(function(character)
		removeESP(player) -- clean old if any
		onCharacter(player, character)
	end)

	player:GetPropertyChangedSignal("Team"):Connect(function()
		if ESP_CACHE[player] then
			updateColor(player, ESP_CACHE[player])
		end
	end)

	-- If character already exists
	if player.Character then
		onCharacter(player, player.Character)
	end
end

--// Refresh when YOUR team changes
LocalPlayer:GetPropertyChangedSignal("Team"):Connect(function()
	for player, highlight in pairs(ESP_CACHE) do
		updateColor(player, highlight)
	end
end)

--// Init existing players
for _, player in ipairs(Players:GetPlayers()) do
	onPlayer(player)
end

--// Detect new players
Players.PlayerAdded:Connect(onPlayer)

--// Clean on leave
Players.PlayerRemoving:Connect(function(player)
	removeESP(player)
end)
------------------
--Esp Players / Teams
----------------
