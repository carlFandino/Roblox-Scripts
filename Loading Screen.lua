-- Link To Video: https://zpsyc.pythonanywhere.com/assets/roblox/Game%20Intro.mp4

-- Services
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local RF = game:GetService("ReplicatedFirst")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local Ligthing = game:GetService("Lighting")
local Player = Players.LocalPlayer
local Controls = require(Player.PlayerScripts.PlayerModule):GetControls()
local Character = Player.Character or Player.CharacterAdded:Wait()

-- Components
local camera = game.Workspace["Loading Screen"]:WaitForChild("camera")
local loadScreenCharEvent = RS.loadScreenChar
local loadingScreenCharRig = game.Workspace["Loading Screen"].Rig.Humanoid
local CurrentCam = game.Workspace.CurrentCamera
local mouse = game:GetService("Players").LocalPlayer:GetMouse()
local uiElements = {Player.PlayerGui["Loading Screen"].clickToContinue, Player.PlayerGui["Loading Screen"].clickToContinue.UIStroke, Player.PlayerGui["Loading Screen"].title, Player.PlayerGui["Loading Screen"].title.UIStroke}

-- Vars
local canClick = false
local isLoadingScreen = false
local isClicked = false
local maxTilt = 3 -- max camera movement of mouse


Ligthing.ColorCorrection.Brightness = -5

-- Disable Reset Button to avoid bugs on the loading screen phase
repeat task.wait(0.5) until pcall(function() StarterGui:SetCore("ResetButtonCallback", false) end);

-- Checks if character is loaded so we can change the camera pov
repeat
	RF:RemoveDefaultLoadingScreen()
	CurrentCam.CameraType = Enum.CameraType.Scriptable
	CurrentCam.CFrame = camera.CFrame * CFrame.Angles(math.rad(-5), math.pi, 0)
	Controls:Disable()
	UIS.MouseIconEnabled = false
	loadScreenCharEvent:FireServer()
until Character


local tweenBrightness = TweenService:Create(Ligthing.ColorCorrection, TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), 
	{Brightness = 0}
)
tweenBrightness:Play()
tweenBrightness.Completed:Connect(function()
	canClick = true
	Player.PlayerGui["Loading Screen"].Enabled = true
	-- Smoothly reveal ui elements
	for i, v in uiElements do
		if v:IsA("UIStroke") then
			local _tween1 = TweenService:Create(v, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), 
				{Transparency = 0}
			)
			_tween1:Play()
		else
			local _tween2 = TweenService:Create(v, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), 
				{TextTransparency = 0}
			)
			_tween2:Play()
		end
	end
end)
-- Follows Movement of the mouse
game:GetService("RunService").RenderStepped:Connect(function()
	if isLoadingScreen then
		local tweenCam = TweenService:Create(CurrentCam, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{CFrame = camera.CFrame * CFrame.Angles(math.rad(-5), math.pi, 0) * CFrame.Angles(
				math.rad((((mouse.Y - mouse.ViewSizeY / 2) / mouse.ViewSizeY)) * -maxTilt),
				math.rad((((mouse.X - mouse.ViewSizeX / 2) / mouse.ViewSizeX)) * -maxTilt),
				0)}
		)
		tweenCam:Play()
	end
end)

-- Initialize Loading Screen from server
loadScreenCharEvent.OnClientEvent:Connect(function()
	local newHumanoid = Instance.new("Humanoid")
	newHumanoid.Name = "newHuman"
	newHumanoid.Parent = game.Workspace["Loading Screen"].Rig
	newHumanoid.NameDisplayDistance = 0
	newHumanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	isLoadingScreen = true
	loadingScreenCharRig:Destroy()
	newHumanoid:ApplyDescription(Players:GetHumanoidDescriptionFromUserId(Player.UserId), Enum.AssetTypeVerification.Always)
	local animTrack = newHumanoid:LoadAnimation(script.leaning)
	animTrack:Play()
end)

function loadingScreenDone()
	isClicked = true
	UIS.MouseIconEnabled = true
	Controls:Enable()
end


-- If game is loaded and then detects left click it will continue
UIS.InputBegan:Connect(function(input, isTyping)
	if isTyping then return end
	if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and game:IsLoaded() and not isClicked and canClick then
		print("aaa")
		canClick = false
		-- Smoothly dip to black ui elements
		Player.PlayerGui["Loading Screen"].clickToContinue.TextTransparency = 1
		Player.PlayerGui["Loading Screen"].clickToContinue.UIStroke.Transparency = 1
		task.wait(1.5)
		for i, v in uiElements do
			if v:IsA("UIStroke") then
				local _tween1 = TweenService:Create(v, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), 
					{Transparency = 1}
				)
				_tween1:Play()
			else
				local _tween2 = TweenService:Create(v, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), 
					{TextTransparency = 1}
				)
				_tween2:Play()
			end
		end
		


		local tweenBrightness1 = TweenService:Create(Ligthing.ColorCorrection, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), 
			{Brightness = -5}
		)
		tweenBrightness1:Play()
		tweenBrightness1.Completed:Connect(function()
			isLoadingScreen = false
			CurrentCam.CameraType = Enum.CameraType.Custom
			Player.PlayerGui["Loading Screen"].Enabled = false
			local tweenBrightness2 = TweenService:Create(Ligthing.ColorCorrection, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), 
				{Brightness = 0}	
			)
			tweenBrightness2:Play()
			-- Loading Screen Done
			tweenBrightness2.Completed:Connect(function()
				loadingScreenDone()
			end)
		end)
		repeat task.wait(0.5) until pcall(function() StarterGui:SetCore("ResetButtonCallback", true) end);
	end
end)


-- Checks if game is loaded
while task.wait(.1) do
	print("not")
	if game:IsLoaded() then
		Player.PlayerGui["Loading Screen"].clickToContinue.Text = "Click to Continue"
		if canClick then
			Player.PlayerGui["Loading Screen"].clickToContinue.TextTransparency = 0
			Player.PlayerGui["Loading Screen"].clickToContinue.UIStroke.Transparency = 0
		end
		break
	else
		Player.PlayerGui["Loading Screen"].clickToContinue.TextTransparency = 1
		Player.PlayerGui["Loading Screen"].clickToContinue.UIStroke.Transparency = 1
		Player.PlayerGui["Loading Screen"].clickToContinue.Text = "Loading"
	end
end
