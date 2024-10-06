-- Video Demo: zpsyc.pythonanywhere.com/assets/roblox/Different Seating.mp4

local config = script.Parent.Configuration
local char = nil
local isThere = false
local WaitFor = (function(parent, child_name)
	local found = parent:FindFirstChild(child_name)
	while found == nil do
		parent.ChildAdded:wait()
		found = parent:FindFirstChild(child_name)
		if found then break end
	end
	return found
end)

local last = { neckC1 = nil, rshoC0 = nil, lshoC0 = nil, rhipC0 = nil, lhipC0 = nil, lSitAng = nil, lSitPos = nil}

local ApplyModifications = (function(weld, char)
	local torso = WaitFor(char, "Torso")
	local neck = WaitFor(torso, "Neck")
	local rsho = WaitFor(torso, "Right Shoulder")
	local lsho = WaitFor(torso, "Left Shoulder")
	local rhip = WaitFor(torso, "Right Hip")
	local lhip = WaitFor(torso, "Left Hip")

	local config = script.Parent.Configuration
	
	local head_angX = config["headAngX"].Value
	local head_angY = config["headAngY"].Value
	local head_angZ = config["headAngZ"].Value
	
	local head_angXPos = config["headAngXPos"].Value
	local head_angYPos = config["headAngYPos"].Value
	local head_angZPos = config["headAngZPos"].Value
	
	
	

	
	local rLegs_angX = config["rLegsX"].Value
	local rLegs_angY = config["rLegsY"].Value
	local rLegs_angZ = config["rLegsZ"].Value
	
	local rLegs_angXPos = config["rLegsXPos"].Value
	local rLegs_angYPos = config["rLegsYPos"].Value
	local rLegs_angZPos = config["rLegsZPos"].Value
	
	local lLegs_angY = config["lLegsX"].Value
	local lLegs_angX = config["lLegsY"].Value
	local lLegs_angZ = config["lLegsZ"].Value
	
	local lLegs_angYPos = config["lLegsXPos"].Value
	local lLegs_angXPos = config["lLegsYPos"].Value
	local lLegs_angZPos = config["lLegsZPos"].Value
	
	local rAngX = config["rShoulderX"].Value
	local rAngY = config["rShoulderY"].Value
	local rAngZ = config["rShoulderZ"].Value
	
	local rAngXPos = config["rShoulderXPos"].Value
	local rAngYPos = config["rShoulderYPos"].Value
	local rAngZPos = config["rShoulderZPos"].Value
	
	local lAngX = config["lShoulderX"].Value
	local lAngY = config["lShoulderY"].Value
	local lAngZ = config["lShoulderZ"].Value
	
	local lAngXPos = config["lShoulderXPos"].Value
	local lAngYPos = config["lShoulderYPos"].Value
	local lAngZPos = config["lShoulderZPos"].Value
	
	local sit_ang  = config["Sitting Angle"].Value
	local sit_pos  = config["Sitting Position"].Value

	--First adjust sitting position and angle
	--Add 90 to the angle because that's what most people will be expecting.

	

	last.lSitAng = weld.C1
	last.lSitPos = weld.C0
	last.neckC1 = neck.C1
	last.rshoC0 = rsho.C0
	last.lshoC0 = lsho.C0
	last.rhipC0 = rhip.C0
	last.lhipC0 = lhip.C0

	weld.C1 = weld.C1 * CFrame.fromEulerAnglesXYZ(math.rad((sit_ang) + 90), 0, 0)

	weld.C0 = CFrame.new(sit_pos)

	-- Head
	neck.C1 = neck.C1 * CFrame.new(head_angXPos, head_angYPos, head_angZPos) * CFrame.fromEulerAnglesXYZ(math.rad(head_angX), math.rad(head_angY), math.rad(head_angZ))


	-- Arms
	rsho.C0 = rsho.C0 * CFrame.new(rAngXPos, rAngYPos, rAngZPos) * CFrame.fromEulerAnglesXYZ(math.rad(rAngX), math.rad(rAngY), math.rad(rAngZ))
	lsho.C0 = lsho.C0 * CFrame.new(lAngXPos, lAngYPos, lAngZPos) * CFrame.fromEulerAnglesXYZ(math.rad(lAngX), math.rad(lAngY), math.rad(lAngZ))


	-- Legs
	rhip.C0 = rhip.C0 * CFrame.new(rLegs_angXPos, rLegs_angYPos, rLegs_angZPos) * CFrame.fromEulerAnglesXYZ(math.rad(rLegs_angX), math.rad(rLegs_angY), math.rad(rLegs_angZ))
	lhip.C0 = lhip.C0 * CFrame.new(lLegs_angXPos, lLegs_angYPos, lLegs_angZPos) * CFrame.fromEulerAnglesXYZ(math.rad(lLegs_angX), math.rad(lLegs_angY), math.rad(lLegs_angZ))

end)



local RevertModifications = (function(weld, char)
	--Any modifications done in ApplyModifications have to be reverted here if they
	--change any welds - otherwise people will wonder why their head is pointing the wrong way.

	local torso = WaitFor(char, "Torso")
	local neck = WaitFor(torso, "Neck")
	local rsho = WaitFor(torso, "Right Shoulder")
	local lsho = WaitFor(torso, "Left Shoulder")
	local rhip = WaitFor(torso, "Right Hip")
	local lhip = WaitFor(torso, "Left Hip")


	--Now adjust the neck angle.
	neck.C1 = last.neckC1 or CFrame.new()

	rsho.C0 = last.rshoC0 or CFrame.new()
	lsho.C0 = last.lshoC0 or CFrame.new()

	rhip.C0 = last.rhipC0 or CFrame.new()
	lhip.C0 = last.lhipC0 or CFrame.new()

	weld:Destroy()
end)

script.Parent.ChildAdded:connect(function(c)
	if c:IsA("Weld") then
		if c.Part1 ~= nil and c.Part1.Parent ~= nil and c.Part1.Parent:FindFirstChild("Humanoid") ~= nil then
			char = c.Part1.Parent
		else return end
		ApplyModifications(c, char)
	end
end)

script.Parent.ChildRemoved:connect(function(c)
	if c:IsA("Weld") then
		if c.Part1 ~= nil and c.Part1.Parent ~= nil and c.Part1.Parent:FindFirstChild("Humanoid") ~= nil then
			char = c.Part1.Parent
		else return end
		RevertModifications(c, char)
	end
end)
