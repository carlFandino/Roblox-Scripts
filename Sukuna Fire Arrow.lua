-- Link to the demo video showing the effect
-- https://zpsyc.pythonanywhere.com/assets/roblox/Sukuna%20Fire%20Arrow.mp4

-- Function to handle the explosion effect of the fire arrow
function explodeArrow(plr, ballExplosion, fireArrowExplosionBig, enemies)
    local done = false
    local ballDone = false

    -- Create and configure a NumberValue instance for scaling the ball explosion
    local ballScale = Instance.new("NumberValue")
    ballScale.Value = ballExplosion:GetScale()
    ballScale.Changed:Connect(function(val)
        ballExplosion:ScaleTo(ballScale.Value)
    end)

    -- Tween to animate the scaling of the ball explosion
    local ballSizeTween1 = TweenService:Create(ballScale, TweenInfo.new(8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), 
        {Value = 15})
    ballSizeTween1:Play()

    -- Toggle visibility of different parts of the ball explosion
    ballExplosion.BigBall.Inner.Transparency = 0
    ballExplosion.BigBall.Attachment2.PointLight.Enabled = true
    ballExplosion.BigBall.Transparency = 0

    -- Tween to change lighting effect color
    local lightingEffectTween = TweenService:Create(game.Lighting.ColorCorrection, TweenInfo.new(8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), 
        {TintColor = Color3.fromRGB(255, 128, 0)})
    lightingEffectTween:Play()

    -- Enable ParticleEmitters and Beams in various parts of the explosion
    for i, v in ballExplosion.BigBall.Attachment1:GetChildren() do
        if v:IsA("ParticleEmitter") then
            v.Enabled = true
        end
    end

    for i, v in ballExplosion.BigBall.Inner.BeamFolder:GetChildren() do
        if v:IsA("Beam") then
            v.Enabled = true
        end
    end

    for i, v in ballExplosion.BigBall:GetChildren() do
        if v:IsA("ParticleEmitter") then
            v.Enabled = true
        end
    end

    for i, v in ballExplosion.SmallBall:GetChildren() do
        if v:IsA("Attachment") and v.Name == "2" then
            for _, beam in v:GetChildren() do
                if beam:IsA("Beam") then
                    beam.Enabled = true
                end
            end
        end
        if v:IsA("ParticleEmitter") then
            v.Enabled = true
        end
    end

    -- Spawn a task to apply camera shake effect
    task.spawn(function()
        while task.wait(0.1) do
            if ballDone then break end
            cameraShake(plr, "hard")
        end
    end)

    -- When ballSizeTween1 completes, handle the next steps of the explosion effect
    ballSizeTween1.Completed:Once(function()
        ballDone = true
        task.wait(1)

        -- Emit particles from the ball explosion
        for i, v in ballExplosion.BigBall.Attachment2:GetChildren() do
            if v:IsA("ParticleEmitter") then
                v:Emit()
            end
        end
        task.wait(0.5)

        -- Tween to scale down the ball explosion
        local ballSizeTween2 = TweenService:Create(ballScale, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), 
            {Value = 0.5})
        ballSizeTween2:Play()

        ballSizeTween2.Completed:Once(function()
            ballExplosion:Destroy()

            -- Reset lighting color and brightness
            task.spawn(function()
                game.Lighting.ColorCorrection.TintColor = Color3.fromRGB(255, 255, 255)
                game.Lighting.ColorCorrection.Brightness = 100
                task.wait(.1)
                game.Lighting.ColorCorrection.Brightness = 0
            end)

            -- Tween to handle transparency of the fire arrow explosion
            local fireExplosionTransparency = TweenService:Create(fireArrowExplosionBig, TweenInfo.new(1, Enum.EasingStyle.Sine), 
                {Transparency = 0}):Play()
            fireArrowExplosionBig.Attachment.NUggat.Enabled = true
            fireArrowExplosionBig.Attachment.ugaga.Enabled = true

            -- Enable ParticleEmitters and Beams in the fire arrow explosion
            for i, v in fireArrowExplosionBig:GetChildren() do
                if v:IsA("ParticleEmitter") then
                    v.Enabled = true
                end
                if v:IsA("Attachment") and v.Name == "beam start" then
                    for _, beams in v:GetChildren() do
                        if beams:IsA("Beam") then
                            beams.Enabled = true
                        end
                    end
                end
            end

            -- Spawn a task to continuously damage enemies and shake the camera
            task.spawn(function()
                while true do
                    if done then
                        break
                    end
                    for i, v in enemies do
                        v.Humanoid:TakeDamage(character["ULTIMATE_ABILITIES"][2]["base_damage"])
                    end
                    cameraShake(plr, "hard")
                    task.wait(0.1)
                end
            end)

            task.wait(15)

            -- Tween to fade out the fire arrow explosion
            local fireExplosionTransparency2 = TweenService:Create(fireArrowExplosionBig, TweenInfo.new(0.5, Enum.EasingStyle.Sine), 
                {Transparency = 1})
            for i, v in fireArrowExplosionBig:GetChildren() do
                if v:IsA("ParticleEmitter") then
                    v.Enabled = false
                end
                if v:IsA("Attachment") and v.Name == "beam start" then
                    for _, beams in v:GetChildren() do
                        if beams:IsA("Beam") then
                            beams.Enabled = false
                        end
                    end
                end
            end
            fireExplosionTransparency2:Play()

            fireExplosionTransparency2.Completed:Once(function()
                done = true
                fireArrowExplosionBig:Destroy()
            end)
        end)
    end)
end

-- Function to show the visual effects of the fire arrow
function showArrowVfx(plr, mousePos, anim, isFired, enemies)
    -- Clone and set up visual effects for the fire arrow
    local ballExplosion = script.VFX["Pre-Explosion"]:Clone()
    local fireArrowExplosionBig = script.VFX["Fire Arrow Explosion"]:Clone()
    local fireArrowVfx = script.VFX["Fire Arrow"]:Clone()
    local groundVfx = script.VFX.Ground:Clone()
    fireArrowVfx.Parent = plr.Character["Left Arm"]

    local fireTip1 = groundVfx.leftArm
    local fireTip2 = groundVfx.rightArm

    -- Create and configure transparency controls
    local disableTransparency = Instance.new("NumberValue")
    local enableTransparency = Instance.new("NumberValue")
    enableTransparency.Value = 1

    groundVfx.Parent = game.Workspace
    groundVfx.Position = plr.Character.HumanoidRootPart.Position - Vector3.new(0, 3, 0)
    groundVfx["Ground Shards and lines"].Position = plr.Character.HumanoidRootPart.Position
    fireTip1.Parent = plr.Character["Left Arm"]
    fireTip2.Parent = plr.Character["Right Arm"]

    ballExplosion.Parent = game.Workspace
    ballExplosion:PivotTo(CFrame.new(mousePos))
    fireArrowExplosionBig.Parent = game.Workspace
    fireArrowExplosionBig.Position = mousePos + Vector3.new(0, 530, 0)

    -- Function to control particle emit rates and enable/disable effects
    local function emitRateEnable(particles, _type)
        if _type == "emit" then
            for i, v in particles do
                if v:IsA("ParticleEmitter") then
                    v:Emit(v.Rate)
                end
            end
        elseif _type == "enable" then
            for i, v in particles do
                if v:IsA("ParticleEmitter") or v:IsA("Beam") then
                    v.Enabled = true
                end
            end
        end
    end

    -- Function to smoothly disable visual effects
    local function smoothDisableVFX(particles)
        local tweenTransparency = TweenService:Create(disableTransparency, TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Value = 1})
        tweenTransparency:Play()
        tweenTransparency.Completed:Once(function()
            fireTip1:Destroy()
            fireTip2:Destroy()
            groundVfx:Destroy()
            disableTransparency:Destroy()
            tweenTransparency:Destroy()
        end)
    end

    -- Update transparency of particles and beams based on enableTransparency
    enableTransparency.Changed:Connect(function(v)
        for i, v in fireTip1:GetChildren() do
            if v:IsA("ParticleEmitter") then
                v.Transparency = NumberSequence.new(enableTransparency.Value)
            end
        end

        for i, v in groundVfx:GetChildren() do
            if v:IsA("ParticleEmitter") then
                v.Transparency = NumberSequence.new(enableTransparency.Value)
            end
        end

        for i, v in groundVfx["Ground Shards and lines"]:GetChildren() do
            if v:IsA("ParticleEmitter") then
                v.Transparency = NumberSequence.new

        -- Update transparency of particles and beams based on enableTransparency
        for i, v in groundVfx["Ground Shards and lines"]:GetChildren() do
            if v:IsA("ParticleEmitter") then
                v.Transparency = NumberSequence.new(enableTransparency.Value)
            end
        end
    end)

    -- Update transparency of particles and beams based on disableTransparency
    disableTransparency.Changed:Connect(function(v)
        for i, v in fireTip1:GetChildren() do
            if v:IsA("ParticleEmitter") or v:IsA("Beam") then
                v.Transparency = NumberSequence.new(disableTransparency.Value)
            end
        end

        for i, v in fireTip2:GetChildren() do
            if v:IsA("ParticleEmitter") or v:IsA("Beam") then
                v.Transparency = NumberSequence.new(disableTransparency.Value)
            end
        end

        for i, v in groundVfx:GetChildren() do
            if v:IsA("ParticleEmitter") or v:IsA("Beam") then
                v.Transparency = NumberSequence.new(disableTransparency.Value)
            end
        end

        for i, v in groundVfx.Attachment:GetChildren() do
            if v:IsA("ParticleEmitter") or v:IsA("Beam") then
                v.Transparency = NumberSequence.new(disableTransparency.Value)
            end
        end

        for i, v in groundVfx["Ground Shards and lines"]:GetChildren() do
            if v:IsA("ParticleEmitter") or v:IsA("Beam") then
                v.Transparency = NumberSequence.new(disableTransparency.Value)
            end
        end
    end)

    -- Function to smoothly enable visual effects
    local function enableSmoothVFX()
        local tweenTransparency = TweenService:Create(enableTransparency, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Value = 0})
        tweenTransparency:Play()
        tweenTransparency.Completed:Once(function()
            enableTransparency:Destroy()
            tweenTransparency:Destroy()
        end)
    end

    -- Start enabling effects smoothly and enable particle emitters
    enableSmoothVFX()
    emitRateEnable(groundVfx.Attachment:GetChildren(), "enable")

    -- Spawn a task to control the fire arrow's animation and effects
    task.spawn(function()
        while true do
            -- Adjust the position of the fire arrow visual effect
            fireArrowVfx.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0.8, 0.5, -4)

            -- Enable effects based on animation time position
            if anim.TimePosition > 2.1 and anim.TimePosition < 2.3 then
                for i, v in fireTip2:GetChildren() do
                    if v:IsA("Beam") then
                        v.Attachment1 = fireTip1
                        v.Enabled = true
                    end
                    if v:IsA("ParticleEmitter") then
                        v.Enabled = true
                    end
                end
                task.wait(.1)
                cameraShake(plr, "mild")
            end

            if anim.TimePosition > 6.6 and anim.TimePosition < 6.8 then
                for i, v in fireArrowVfx:GetChildren() do
                    if v:IsA("Attachment") then
                        for _, vfx in v:GetChildren() do
                            vfx.Enabled = true
                        end
                    end
                    if v:IsA("ParticleEmitter") then
                        v.Enabled = true
                    end
                end
                cameraShake(plr, "mild")
            end

            -- Animate the fire arrow and handle the explosion
            if anim.TimePosition >= 9.7 then
                local animateArrow = TweenService:Create(fireArrowVfx, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Position = mousePos})
                animateArrow:Play()
                cameraShake(plr, "mild")
                smoothDisableVFX()
                animateArrow.Completed:Once(function()
                    explodeArrow(plr, ballExplosion, fireArrowExplosionBig, enemies)
                    enemies = {}
                    fireArrowVfx:Destroy()
                end)

                break
            end
            task.wait(.1)
        end
    end)
end

-- Function to trigger the ultimate ability of the character
function character.Ultimate_Ability_2(plr, mousePos)
    -- Calculate the distance of the arrow shot
    local arrowMeterDistance = math.round(((plr.Character.HumanoidRootPart.Position - mousePos).Magnitude) / 3.571428571)
    if arrowMeterDistance > 10 then
        -- Load the animation for the ultimate ability
        local fireArrowAnim = plr.Character.Humanoid.Animator:LoadAnimation(character["ULTIMATE_ABILITIES"][2]["animation"])
        local isFired = false
        local playerParts = {"Left Arm", "Right Arm", "HumanoidRootPart", "Left Leg", "Right Leg", "Head"}
        local enemies = {}

        -- Create an area to detect enemies for the ultimate ability
        local _area = Instance.new("Part")
        _area.Parent = game.Workspace
        _area.Size = Vector3.new(200, 5, 200)
        _area.Anchored = true
        _area.CanCollide = false
        _area.Position = mousePos
        _area.Transparency = 1
        game.Debris:AddItem(_area, 0.5)

        -- Detect enemies within the area
        _area.Touched:Connect(function(_enemy)
            if table.find(playerParts, _enemy.Name) then
                if _enemy.Parent.Name ~= plr.Name and _enemy.Parent.Humanoid.Health ~= 0 then
                    local isPlayer = game.Players:GetPlayerFromCharacter(_enemy.Parent)
                    if isPlayer then
                        DisableControl:FireClient(isPlayer, "disable")
                    end
                    enemies[_enemy.Parent] = _enemy.Parent
                end
            end
        end)

        task.wait(0.5)

        -- Check if there are enemies detected
        if Length(enemies) ~= 0 then
            -- Tween to rotate the player towards the target
            local rotateTween = TweenService:Create(plr.Character.HumanoidRootPart, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.In), 
                {CFrame = CFrame.new(plr.Character.HumanoidRootPart.Position, mousePos)})
            rotateTween:Play()
            DisableControl:FireClient(plr, "disable")

            -- Spawn a task to monitor the animation and trigger effects
            task.spawn(function()
                while not isFired do
                    if fireArrowAnim.TimePosition >= 9.7 then
                        isFired = true
                        DisableControl:FireClient(plr, "enable")
                    end
                    task.wait(.1)
                end
                task.spawn(showArrowVfx, plr, mousePos, fireArrowAnim, isFired, enemies)
                fireArrowAnim:Play()
            end)
        else
            print("NO ENEMIES DETECTED!")
            DisableControl:FireClient(plr, "enable")
        end
    end
    return
end
	
