-- Video Demo: https://zpsyc.pythonanywhere.com/assets/roblox/Cutscene%20Trigger.mp4
local Player = game:GetService("Players").LocalPlayer
local Controls = require(Player.PlayerScripts.PlayerModule):GetControls()
local RS = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local RunningService = game:GetService("RunService")
local TweeningService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local colorCorrection = Lighting.ColorCorrection

local teleEvent = RS.Events.Teleport
local BuildingAxe = game.Workspace.BuildingAxe
local axeTool = script.AxeCutscene
local bAxeCutscene = RS.Events.Camera.BuildingAxeCutscene
local blackTransition = RS.Events.ScreenEffects.BlackTransition
local currentCamera = game.Workspace.CurrentCamera

local camFocus = nil

local doorAxeAnimation = script.anim

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
bAxeCutscene.OnClientInvoke = function(player)
	Controls:Disable()
	local started = false
	local blackTransitionInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	local animTrack = player.Character.Humanoid:LoadAnimation(doorAxeAnimation)
	local _loop = RunningService.RenderStepped:Connect(function()
		if camFocus and started then
			currentCamera.CFrame = camFocus.CFrame
		end
	end)
	
	local function moveCamera1()
		local _moveAnim = TweeningService:Create(BuildingAxe.cameraCutscene1, TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), 
			{CFrame = BuildingAxe.cameraCutscene1.CFrame * CFrame.new(0, 20, -30)})
		_moveAnim:Play()
		coroutine.wrap(function()
			task.wait(2.5)
			local _animation1 = TweeningService:Create(colorCorrection, blackTransitionInfo, {Brightness = -1})
			_animation1:Play()
			_animation1.Completed:Connect(function()
				camFocus = BuildingAxe.cameraCutscene2
				local _animation2 = TweeningService:Create(colorCorrection, blackTransitionInfo, {Brightness = 0})
				_animation2:Play()
				task.wait(3)
				camFocus = nil
				started = false
				currentCamera.CameraType = Enum.CameraType.Custom
				currentCamera.CameraSubject = Player.Character
				player.Character.Humanoid:UnequipTools()
				Controls:Enable()
				_loop:Disconnect()
				return true
			end)
			
		end)()
		
	end
	
	animTrack:GetMarkerReachedSignal("axeGet"):Connect(function()
		BuildingAxe.cutsceneAxeTrigger.AxeHead.Transparency = 1
		BuildingAxe.cutsceneAxeTrigger.Body.Transparency = 1
		player.Character.Humanoid:EquipTool(axeTool)
		player.Character.Humanoid:EquipTool(axeTool)
	end)
	
	animTrack:GetMarkerReachedSignal("hit_1"):Connect(function()
		print("hit 1")
	end)
	
	animTrack:GetMarkerReachedSignal("hit_2"):Connect(function()
		print("hit 2")
	end)
	
	animTrack:GetMarkerReachedSignal("kick"):Connect(function()
		print("kick!")
		BuildingAxe.Model["double door"]:Destroy()
		task.wait(1)
		
		local _animation3 = TweeningService:Create(colorCorrection, blackTransitionInfo, {Brightness = -1})
		_animation3:Play()
		_animation3.Completed:Connect(function()
			teleEvent:FireServer(BuildingAxe.endingPos)
			local _animation4 = TweeningService:Create(colorCorrection, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Brightness = 0})
			_animation4:Play()
		end)
	end)



	
	local _animation1 = TweeningService:Create(colorCorrection, blackTransitionInfo, {Brightness = -1})
	_animation1:Play()
	_animation1.Completed:Connect(function()
		teleEvent:FireServer(BuildingAxe.Character)
		started = true
		currentCamera.CameraType = Enum.CameraType.Scriptable
		camFocus = BuildingAxe.cameraCutscene1
		local _animation2 = TweeningService:Create(colorCorrection, blackTransitionInfo, {Brightness = 0})
		_animation2:Play()
		task.wait(.3)
		animTrack:Play()
		moveCamera1()

	end)

end
