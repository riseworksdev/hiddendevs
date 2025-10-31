local DataStoreService = game:GetService("DataStoreService")
local config = script:WaitForChild("datastore_config")
local myDataStore = DataStoreService:GetDataStore("$Data$!"..config:FindFirstChild("DataVersion").Value)

local saving = config:FindFirstChild("Saving")
local autoSave = config:FindFirstChild("AutoSave")

local function create_table(plr)
	local player_stats = {}

	for _, folder in pairs(script:FindFirstChild("Plr"):GetChildren()) do
		if folder:IsA("Folder") then
			for _, stat in pairs(plr:FindFirstChild(folder.Name):GetChildren()) do
				player_stats[stat.Name.." "..folder.Name] = stat.Value
			end
		end
	end

	return player_stats
end

local function saveData(plr)


	local player_stats = create_table(plr)

	local success, err = pcall(function()
		local key = plr.UserId.."'s' Data"
		myDataStore:SetAsync(key, player_stats)
	end)

	if success then
		print("Saved Data Correctly!")
	else
		warn(err)
	end
end

local function autoSavePlayers()
	while true do
		wait(autoSave.Value * 60) 
		for _, player in ipairs(game.Players:GetPlayers()) do
			saveData(player)
		end
	end
end


coroutine.wrap(autoSavePlayers)()

game.Players.PlayerAdded:Connect(function(plr)
	local key = plr.UserId.."'s' Data"
	local data = myDataStore:GetAsync(key)

	for _, folder in pairs(script:FindFirstChild("Plr"):GetChildren()) do
		if folder:IsA("Folder") then
			local fc = folder:Clone()
			fc.Parent = plr

			if saving.Value == true then
				for _, item in pairs(fc:GetChildren()) do
					if data then
						if data[item.Name.." "..folder.Name] then
							item.Value = data[item.Name.." "..folder.Name]
							
						end	
					else
						warn("no data!")
					end
				end
			end
		end
	end
end)

game.Players.PlayerRemoving:Connect(function(plr)
	if saving.Value == true then
		saveData(plr)
	end
end)
