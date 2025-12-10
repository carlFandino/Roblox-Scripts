--[[
    zPsyc Studios Lua Script License
    Copyright (c) 2025 zPsyc Studios. All rights reserved.

    This script is licensed under the zPsyc Studios License.
    Unauthorized copying, modification, distribution, or use of this file,
    via any medium, is strictly prohibited unless prior written permission is granted
    by zPsyc Studios.

    For commercial use, licensing inquiries, or permission requests, contact: zpsycstudios@gmail.com | Discord: Carl.#9790
]]

local SSS = game:GetService("ServerScriptService")

local RS = game:GetService("ReplicatedStorage")
local Remotes = RS:WaitForChild("Events")
local ClaimDailyRewardRemote = Remotes:WaitForChild("ClaimDailyReward")
local GetMyDailyRewardDatasRemote = Remotes:WaitForChild("GetMyDailyRewardDatas")

local PlayerData = require(script.Parent.Parent.ServerModules.DataManager).Profiles
local ServerFunction  = require(SSS.ServerModules.ServerFunction)

local DailyRewards = {}
DailyRewards.__index = DailyRewards

DailyRewards["DAYS_REWARDS"] = {
	[1] = {
		rewardType = "CREDITS",
		rewardValue = 50,
		minimumHour = 0,
		image_id = "rbxassetid://93253109334123"
	},
	
	[2] = {
		rewardType = "BATTLEPASSEXP",
		rewardValue = 250,
		minimumHour = 24,
		image_id = "rbxassetid://15403116835"
	},
	
	[3] = {
		rewardType = "CREDITS",
		rewardValue = 200,
		minimumHour = 48,
		image_id = "rbxassetid://93253109334123"
	},
	
	[4] = {
		rewardType = "BATTLEPASSEXP",
		rewardValue = 500,
		minimumHour = 72,
		image_id = "rbxassetid://15403116835"
	},
	
	[5] = {
		rewardType = "CREDITS",
		rewardValue = 400,
		minimumHour = 96,
		image_id = "rbxassetid://93253109334123"
	},
	
	[6] = {
		rewardType = "CREDITS",
		rewardValue = 750,
		minimumHour = 120,
		image_id = "rbxassetid://93253109334123"
	},
	
	[7] = {
		rewardType = "UNIT",
		rewardValue = "Knight", ------- I will change it to lumberjack once it's in the system
		minimumHour = 144
	},
}

function DailyRewards.new()
	local self = setmetatable({}, DailyRewards)
	
	ClaimDailyRewardRemote.OnServerInvoke = function(player, day)
		return self:Claim(player, day)
	end
	
	GetMyDailyRewardDatasRemote.OnServerInvoke = function(player)		
		local _playerData = PlayerData[player].Data
		local _data = {}
		
		if not _playerData.dailyRewardsLastOnlineTick then
			_playerData.dailyRewardsLastOnlineTick = tick()
		else
			local seconds = math.floor(tick() - _playerData.dailyRewardsLastOnlineTick) 
			local minutes = math.floor(seconds / 60)
			local hours = math.floor(minutes / 60)
			if hours >= 168 then
				_playerData.dailyRewardsLastOnlineTick = tick()
				_playerData.claimedDailyRewards = {}
			end
		end
		_data["ClaimedDailyRewards"] = _playerData.claimedDailyRewards
		_data["LastOnlineTick"] = _playerData.dailyRewardsLastOnlineTick
		_data["DAYS_REWARDS"] = DailyRewards["DAYS_REWARDS"]
		return _data
	end
	
	return self
end

function DailyRewards:Claim(player, day)
	local _playerData = PlayerData[player].Data
	local _playerHours = math.floor((tick() - _playerData.dailyRewardsLastOnlineTick)) 
	
	local choosenDay = DailyRewards["DAYS_REWARDS"][day]
	local choosenDayMinimumHours = choosenDay.minimumHour
	
	local rewardType = choosenDay.rewardType
	local rewardValue = choosenDay.rewardValue
	
	if table.find(_playerData.claimedDailyRewards, day) then return "claimed" end

	if _playerHours >= choosenDayMinimumHours then
		if rewardType == "CREDITS" then
			ServerFunction.ModifyCredits(player, rewardValue, false)
		elseif rewardType == "BATTLEPASSEXP" then

			ServerFunction.ModifyBattlepassExp(player, rewardValue)
		elseif rewardType == "UNIT" then
			ServerFunction.UnlockTroop(player, rewardValue)
		end
		table.insert(_playerData.claimedDailyRewards, day)
		return "~claimed"
	else
		return "not"
	end
end

return DailyRewards
