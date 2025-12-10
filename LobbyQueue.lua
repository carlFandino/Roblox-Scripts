--[[
    zPsyc Studios Lua Script License
    Copyright (c) 2025 zPsyc Studios. All rights reserved.

    This script is licensed under the zPsyc Studios License.
    Unauthorized copying, modification, distribution, or use of this file,
    via any medium, is strictly prohibited unless prior written permission is granted
    by zPsyc Studios.

    For commercial use, licensing inquiries, or permission requests, contact: zpsycstudios@gmail.com | Discord: Carl.#9790
]]


local TeleportService = game:GetService("TeleportService")
local RS = game:GetService("ReplicatedStorage")
local Remotes = RS:WaitForChild("Events")

local LobbyUpdateRemote = Remotes.LobbySystemRemotes:WaitForChild("LobbyUpdateRemote")
local KickRoomMember = Remotes.LobbySystemRemotes:WaitForChild("KickRoomMember")
local UpdatePlayerRoomRemote = Remotes.LobbySystemRemotes:WaitForChild("UpdatePlayerRoom")
local JoinLobbyRemote = Remotes.LobbySystemRemotes:WaitForChild("JoinLobby")
local CreateLobbyRemote = Remotes.LobbySystemRemotes:WaitForChild("CreateLobby")
local LeaveLobbyRemote = Remotes.LobbySystemRemotes:WaitForChild("LeaveLobby")
local StartLobbyRemote = Remotes.LobbySystemRemotes:WaitForChild("StartLobby")

local PlayerData = require(script.Parent.Parent.ServerModules.DataManager).Profiles
local GameConfigs = require(RS.ClientModules.GameConfigs)
local limitsAliases = {
	["Solo"] = 1,
	["Duo"] = 2,
	["Trio"] = 3
}


local placeIdVersus = {
	-- FOR OFFICIAL SERVER
	["0"] = 0,
	-- FOR TEST SERVER
	["0"] = 0
}

local placeIdZombie = {
	-- FOR OFFICIAL SERVER
	["0"] = 0,
	-- FOR TEST SERVER
	["0"] = 0
}

local Lobby = {}
Lobby.__index = Lobby

function countArray(arr)
	local count = 0
	for i, v in pairs(arr) do
		count += 1
	end

	return count
end

function Lobby.new()
	local self = setmetatable({}, Lobby)
	
	self.Lobbies = {} -- ["Player's Room"] = {Owner = "Player's Name", Members = {"Player 1", "Player 2"}, mode = "ZOMBIE", limit = 1, isStarted = false}
	
	LobbyUpdateRemote.OnServerInvoke = function(player : Player, mode, lobbyFilter, lobbyName) -- Mode : ["Room", "Lobbies"], LobbyFilter = ["ZOMBIE", "VERSUS"]
		if mode == "Room" then
			if lobbyName then
				return self:RetreiveRoom(lobbyName)
			else
				return false
			end
			
		elseif mode == "Lobbies" then
			return self:RetreiveLobbies(player, lobbyFilter)
		end
	end
	
	JoinLobbyRemote.OnServerInvoke = function(player : Player, lobbyName)
		return self:JoinLobby(player, lobbyName)
	end
	
	CreateLobbyRemote.OnServerInvoke = function(player : Player, mode, limit) -- Mode : ["ZOMBIE", "VERSUS"], Limit : ["Solo", "Duo", "Trio"] (only apply on zombie mode)
		return self:CreateLobby(player, mode, limit)
	end
	
	LeaveLobbyRemote.OnServerEvent:Connect(function(player : Player, lobbyName)
		self:LeaveLobby(player, lobbyName)
	end)
	
	StartLobbyRemote.OnServerEvent:Connect(function(owner, lobbyName)
		self:Start(owner, lobbyName)
	end)
	
	KickRoomMember.OnServerEvent:Connect(function(owner, playerName, lobbyName)
		self:KickRoomMember(owner, playerName, lobbyName)
	end)
	
	game.Players.PlayerRemoving:Connect(function(player)
		if player:GetAttribute("inLobby") and player:GetAttribute("LobbyName") then
			self:LeaveLobby(player, player:GetAttribute("LobbyName"))
		end
	end)
	
	return self
end

function Lobby:_delete_lobby(name, mode)
	self.Lobbies[name] = nil
	UpdatePlayerRoomRemote:FireAllClients("Lobby", mode)
end

function Lobby:RetreiveRoom(lobbyName)
	return self.Lobbies[lobbyName]
end

function Lobby:RetreiveLobbies(player, mode) -- Mode : ["ZOMBIE", "VERSUS"]
	local PlayerLevel = player:WaitForChild("Stats"):WaitForChild("HighestLevel")
	
	if mode == "ZOMBIE" and PlayerLevel.Value < GameConfigs.ZombieModeLevelUnlock then return end
	if mode == "VERSUS" and PlayerLevel.Value < GameConfigs.VersusModeLevelUnlock then return end
	
	local temporaryArray = {}
	for i, v in pairs(self.Lobbies) do
		if v.mode == mode then
			temporaryArray[i] = v
		end
	end
	return temporaryArray
end

function Lobby:CreateLobby(player : Player, mode, limit)
	if self.Lobbies[`{player.Name}'s Room`] then return false end
	
	local PlayerLevel = player:WaitForChild("Stats"):WaitForChild("HighestLevel")
	if mode == "ZOMBIE" and PlayerLevel.Value < GameConfigs.ZombieModeLevelUnlock then return end
	if mode == "VERSUS" and PlayerLevel.Value < GameConfigs.VersusModeLevelUnlock then return end
	
	if mode == "ZOMBIE" then
		if limit then
			self.Lobbies[`{player.Name}'s Room`] = {
				Owner = player,
				Members = {},
				mode = "ZOMBIE",
				limit = limitsAliases[limit],
				isStarted = false
			}
			player:SetAttribute("inLobby", true)
			player:SetAttribute("LobbyName", `{player.Name}'s Room`)
			UpdatePlayerRoomRemote:FireAllClients("Lobby", mode)
			return self.Lobbies[`{player.Name}'s Room`]
		end
		
	elseif mode == "VERSUS" then
		self.Lobbies[`{player.Name}'s Room`] = {
			Owner = player,
			Members = {},
			mode = "VERSUS",
			limit = 2,
			isStarted = false
		}
		player:SetAttribute("inLobby", true)
		player:SetAttribute("LobbyName", `{player.Name}'s Room`)
		UpdatePlayerRoomRemote:FireAllClients("Lobby", mode)
		return self.Lobbies[`{player.Name}'s Room`]
	end
	
	return false
end

function Lobby:LeaveLobby(player : Player, lobbyName)
	if self.Lobbies[lobbyName] then
		if self.Lobbies[lobbyName].Owner.Name == player.Name then
			player:SetAttribute("inLobby", nil)
			player:SetAttribute("LobbyName", nil)
			
			for i, v : Player in pairs(self.Lobbies[lobbyName].Members) do
				v:SetAttribute("inLobby", nil)
				v:SetAttribute("LobbyName", nil)
			end
			
			self:UpdatePlayers(self.Lobbies[lobbyName].Owner, lobbyName, "Destroyed")
			self:_delete_lobby(lobbyName, self.Lobbies[lobbyName].mode)
		else
			self.Lobbies[lobbyName].Members[player.Name] = nil
			player:SetAttribute("inLobby", nil)
			player:SetAttribute("LobbyName", nil)
			self:UpdatePlayers(self.Lobbies[lobbyName].Owner, lobbyName, "Room")
			UpdatePlayerRoomRemote:FireAllClients("Lobby", self.Lobbies[lobbyName].mode)
		end
		return true
	end
	
	return false
end

function Lobby:JoinLobby(player : Player, lobbyName)
	local PlayerLevel = player:WaitForChild("Stats"):WaitForChild("HighestLevel")

	if self.Lobbies[lobbyName] then
		if (countArray(self.Lobbies[lobbyName].Members) + 1 --[[Owner]]) >= self.Lobbies[lobbyName].limit then return false end
		
		if self.Lobbies[lobbyName].mode == "ZOMBIE" and PlayerLevel.Value < GameConfigs.ZombieModeLevelUnlock then return end
		if self.Lobbies[lobbyName].mode == "VERSUS" and PlayerLevel.Value < GameConfigs.VersusModeLevelUnlock then return end
		
		if not self.Lobbies[lobbyName].Members[player.Name] then
			self.Lobbies[lobbyName].Members[player.Name] = player
			player:SetAttribute("inLobby", true)
			player:SetAttribute("LobbyName", lobbyName)
			self:UpdatePlayers(self.Lobbies[lobbyName].Owner, lobbyName, "Room")
			UpdatePlayerRoomRemote:FireAllClients("Lobby", self.Lobbies[lobbyName].mode)
			return self.Lobbies[lobbyName]
		else
			return false
		end
	end
	
	return false
end

function Lobby:Start(player : Player, lobbyName)
	if self.Lobbies[lobbyName] then
		local allPlayers = {}
		table.insert(allPlayers, self.Lobbies[lobbyName].Owner)
		for i, v in pairs(self.Lobbies[lobbyName].Members) do
			table.insert(allPlayers, v)
		end
		if self.Lobbies[lobbyName].mode == "VERSUS" then
			if countArray(self.Lobbies[lobbyName].Members) == 1 then
				self.Lobbies[lobbyName].isStarted = true
				self:UpdatePlayers(player, lobbyName, "Starting")
				task.wait(2)
				self:TeleportVersus(false, allPlayers)
				self:_delete_lobby(lobbyName, "VERSUS")
			end
		elseif self.Lobbies[lobbyName] .mode == "ZOMBIE" then
			self.Lobbies[lobbyName].isStarted = true
			self:UpdatePlayers(player, lobbyName, "Starting")
			
			task.wait(2)
			self:TeleportZombie(false, allPlayers)
			self:_delete_lobby(lobbyName, "ZOMBIE")
		end
	end
end

function Lobby:KickRoomMember(player, playerName, lobbyName)
	if self.Lobbies[lobbyName] then
		if self.Lobbies[lobbyName].isStarted then return end
		
		if self.Lobbies[lobbyName].Members[playerName] then
			KickRoomMember:FireClient(self.Lobbies[lobbyName].Members[playerName])
			self.Lobbies[lobbyName].Members[playerName]:SetAttribute("inLobby", nil)
			self.Lobbies[lobbyName].Members[playerName]:SetAttribute("LobbyName", nil)

			self.Lobbies[lobbyName].Members[playerName] = nil
			self:UpdatePlayers(player, lobbyName, "Room")
			UpdatePlayerRoomRemote:FireAllClients("Lobby", self.Lobbies[lobbyName].mode)
		end
	end
end

function Lobby:UpdatePlayers(owner, lobbyName, mode)
	UpdatePlayerRoomRemote:FireClient(owner, mode)
	for i, v in pairs(self.Lobbies[lobbyName].Members) do
		UpdatePlayerRoomRemote:FireClient(v, mode)
	end
end

function Lobby:TeleportVersus(lobbyArray, playersArray)
	for i, v in pairs(playersArray) do
		local teleportUI = script.TeleportUI:Clone()
		teleportUI.Parent = v.PlayerGui
	end
	
	local options = Instance.new("TeleportOptions")
	options.ShouldReserveServer = true
	options:SetTeleportData({
		["Difficulty"] = 1,
		["Map"] = "Forest",
		["Number"] = "1",
		["Skin"] = "None",
		["PlayerNum"] = 2,
	})
	TeleportService:TeleportAsync(placeIdVersus[tostring(game.PlaceId)], playersArray, options)
end

function Lobby:TeleportZombie(lobbyArray, playersArray)
	for i, v in pairs(playersArray) do
		local teleportUI = script.TeleportUI:Clone()
		teleportUI.Parent = v.PlayerGui
	end
	
	local options = Instance.new("TeleportOptions")
	options.ShouldReserveServer = true
	options:SetTeleportData({
		["Difficulty"] = 1,
		["Map"] = "Zombie",
		["Number"] = "1",
		["Skin"] = "None",
		["PlayerNum"] = 2,
	})
	TeleportService:TeleportAsync(placeIdZombie[tostring(game.PlaceId)], playersArray, options)
end
return Lobby
