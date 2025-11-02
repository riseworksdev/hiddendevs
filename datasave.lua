-- ========================================
-- DATA SAVING FUNCTIONS
-- ========================================

-- saves player youtuber data into their datafolder
local function savePlayerYoutuberData(player, data)
	local df = player:FindFirstChild("DataFolder")
	if not df then return false end

	local yv = df:FindFirstChild("Youtubers")
	if not yv then return false end

	local success = pcall(function()
		yv.Value = HttpService:JSONEncode(data)
	end)

	return success
end

-- adds a youtuber entry to the player data
local function addYoutuberToData(player, youtuberName, displayNum)
	if not player or not youtuberName then return false end
	local data = getPlayerYoutuberData(player)
	local newEntry = {
		Name = youtuberName,
		DisplayNum = displayNum or 1
	}
	table.insert(data, newEntry)
	return savePlayerYoutuberData(player, data)
end

-- removes a youtuber by their display number
local function removeYoutuberFromDataByDisplay(player, displayNum)
	if not player or not displayNum then return false end

	local data = getPlayerYoutuberData(player)

	for i = #data, 1, -1 do
		if data[i].DisplayNum == displayNum then
			table.remove(data, i)
			break -- only remove one
		end
	end

	return savePlayerYoutuberData(player, data)
end

-- removes a youtuber by their name (and optionally display num)
local function removeYoutuberFromData(player, youtuberName, displayNum)
	if not player or not youtuberName then return false end

	local data = getPlayerYoutuberData(player)

	for i = #data, 1, -1 do
		local entry = data[i]
		if entry.Name == youtuberName then
			if not displayNum or entry.DisplayNum == displayNum then
				table.remove(data, i)
				break -- stop after removing
			end
		end
	end

	return savePlayerYoutuberData(player, data)
end

-- updates the display number for a specific youtuber
local function updateYoutuberDisplayNum(player, oldDisplayNum, newDisplayNum)
	if not player or not oldDisplayNum or not newDisplayNum then return false end

	local data = getPlayerYoutuberData(player)

	for i, entry in ipairs(data) do
		if entry.DisplayNum == oldDisplayNum then
			entry.DisplayNum = newDisplayNum
			break 
		end
	end

	return savePlayerYoutuberData(player, data)
end

-- clears all youtuber data for that player
local function clearPlayerYoutuberData(player)
	if not player then return false end
	return savePlayerYoutuberData(player, {})
end

-- prints out the player’s current youtuber list to console
local function debugPrintPlayerData(player)
	local data = getPlayerYoutuberData(player)
	print("=== " .. player.Name .. "'s YouTuber Data ===")
	for i, entry in ipairs(data) do
		print(i .. ": " .. entry.Name .. " (Display " .. entry.DisplayNum .. ")")
	end
	print("=== End Data ===")
end


-- ========================================
-- GLOBAL FUNCTIONS
-- ========================================
_G.CancelSteal = function(stealingPlayer)
	if not stealingPlayer or not stolenYoutubers[stealingPlayer] then
		return false
	end

	local stolenData = stolenYoutubers[stealingPlayer]
	local originalOwner = stolenData.originalOwner
	local youtuberName = stolenData.youtuberName
	local clone = stolenData.clone
	local originalDisplayNum = stolenData.originalDisplayNum
	local carryingAnimation = stolenData.carryingAnimation

	if carryingAnimation then
		pcall(function()
			if carryingAnimation.IsPlaying then
				carryingAnimation:Stop()
			end
		end)
	end

	stolenYoutubers[stealingPlayer] = nil
	if clone and clone.Parent then
		clone:Destroy()
	end

	if originalOwner and originalOwner.Parent then
		addYoutuberToData(originalOwner, youtuberName, originalDisplayNum)

		local base = getPlayerBase(originalOwner)
		if base then
			local displays = base:FindFirstChild("Displays")
			if displays then
				local targetDisplay = displays:FindFirstChild("Display" .. originalDisplayNum)
				if targetDisplay and not targetDisplay:GetAttribute("Occupied") then
					assignToDisplay(originalOwner, youtuberName, targetDisplay, true)
				else
					assignToDisplay(originalOwner, youtuberName, nil, true)
				end
			end
		end
	end

	return true
end
