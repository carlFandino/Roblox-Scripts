-- MAIN SCRIPT -- 
local RS = game:GetService("ReplicatedStorage")
local CheckEvent = RS:WaitForChild("Events"):WaitForChild("CheckSummon")

local Players = game:GetService("Players")
local MessagingService = game:GetService("MessagingService")


local SummonModule = require(script.Main)
local SummonObject = SummonModule.new()


Players.PlayerAdded:Connect(function(player)
	local teleportData = player:GetJoinData()

	if teleportData.TeleportData then
		SummonObject.ReserveCode = teleportData.TeleportData["ACCESS_CODE"]
	end

	if table.find(SummonModule["ADMINS"], player.Name) then
		player.Chatted:Connect(function(message, recipient)
			SummonObject:ChatListener(player, message)
		end)
	end
end)

MessagingService:SubscribeAsync("SummonPlayer", function(message)
	SummonObject:CrossServerSummonMessageListener(message.Data)
end)

-- SUMMON MODULE (SEPARATED SCRIPT) -- 
local RS = game:GetService("ReplicatedStorage")
local CheckEvent = RS:WaitForChild("Events"):WaitForChild("CheckSummon")

local MessagingService = game:GetService("MessagingService")
local TeleportService = game:GetService("TeleportService")

local Summon = {}
Summon.__index = Summon

Summon["ADMINS"] = {"TMITD1"}

function Summon.new()
	local self = setmetatable({}, Summon)
	self.ReserveCode = false
	return self
end

function Summon:ChatListener(player : Player, message)
	local splittedMessage = string.split(message, " ")
	
	if #splittedMessage == 2 then
		if splittedMessage[1] == "!summon" then
			local playerName = splittedMessage[2]
			local isReserved = game.PrivateServerId ~= "" and game.PrivateServerOwnerId == 0
			
			if isReserved and self.ReserveCode then
				MessagingService:PublishAsync("SummonPlayer", `{playerName} {self.ReserveCode}`)
			end
		end
	elseif #splittedMessage == 1 then
		if splittedMessage[1] == "!reserveserver" then
			self:ReserveServer(player)
		end
	end
	
end

function Summon:CrossServerSummonMessageListener(message)
	local splittedMessage = string.split(message, " ")
	if #splittedMessage == 2 then
		local playerName = splittedMessage[1]
		local reservedAccessCode = splittedMessage[2]
		
		for i, v in pairs(game.Players:GetPlayers()) do
			if v.Name:lower() == playerName:lower() then
				self:PlayerSummoned(v, reservedAccessCode)	
				break
			end
		end
	end
end

function Summon:PlayerSummoned(player : Player, reservedAccessCode)
	local success, result = pcall(function()
		local TeleportOptions = Instance.new("TeleportOptions")
		TeleportOptions.ReservedServerAccessCode = reservedAccessCode
		TeleportService:TeleportAsync(game.PlaceId, {player}, TeleportOptions)
	end)
end

function Summon:ReserveServer(player : Player)
	local success, result = pcall(function()
		local PrivateServer = TeleportService:ReserveServer(game.PlaceId)
		local TeleportOptions = Instance.new("TeleportOptions")
		TeleportOptions:SetTeleportData({
			ACCESS_CODE = PrivateServer
		})
		TeleportOptions.ReservedServerAccessCode = PrivateServer
		TeleportService:TeleportAsync(game.PlaceId, {player}, TeleportOptions)
	end)
end

return Summon
