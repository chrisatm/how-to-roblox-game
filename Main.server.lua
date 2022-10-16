local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")


local function initiateSteps()
	
	Players.RespawnTime = 0.5
	
	local baseplate = game.Workspace.Baseplate
	baseplate:Destroy()
	
	local teleportPart = game.Workspace.TeleportPart
	teleportPart.CanCollide = false
	teleportPart.Transparency = 0.5
	teleportPart.Touched:Connect(function(partTouched)
		local partParent = partTouched.Parent
		local humanoid = partParent:FindFirstChild("Humanoid")
		local humanoidRootPart = partParent:FindFirstChild("HumanoidRootPart")
		local player = Players:GetPlayerFromCharacter(partParent)
		if player and humanoidRootPart and humanoid and humanoid.Health > 0 then
			local playerCheckpoint = player:FindFirstChild("Checkpoint")
			local heightOffset = Vector3.new(0, 10, 0)
			local spawnCFrame = game.Workspace.SpawnLocation.CFrame
			if playerCheckpoint and playerCheckpoint ~= nil and typeof(playerCheckpoint.Value) == "Instance" then
				spawnCFrame = playerCheckpoint.Value.CFrame
			end
			humanoidRootPart.CFrame = spawnCFrame + heightOffset
		end
	end)
	
	Players.PlayerAdded:Connect(function(player)
		local checkPoint = Instance.new("ObjectValue")
		checkPoint.Name = "Checkpoint"
		checkPoint.Value = nil
		checkPoint.Parent = player
		
		player.CharacterAdded:Connect(function(character)
			wait()
			local playerCheckpoint = player:FindFirstChild("Checkpoint")
			local heightOffset = Vector3.new(0, 10, 0)
			local spawnCFrame = game.Workspace.SpawnLocation.CFrame
			if playerCheckpoint and playerCheckpoint ~= nil and typeof(playerCheckpoint.Value) == "Instance" then
				spawnCFrame = playerCheckpoint.Value.CFrame
			end
			character:WaitForChild("HumanoidRootPart").CFrame = spawnCFrame + heightOffset
		end)
	end)
end


local function initiateLasers()
	local lasers = game.Workspace.Lasers:GetChildren()
	for i, laser in pairs(lasers) do
		local moving = laser.Moving.Value or false
		local moveDelay = laser.MoveDelay.Value or 0.5
		local moveDuration = laser.MoveDuration.Value or 2
		local moveDirection = laser.MoveDirection.Value or Vector3.new(12, 0, 0)
		laser.CanCollide = false
		laser.Touched:Connect(function(partTouched)
			local partParent = partTouched.Parent
			local humanoid = partParent:FindFirstChild("Humanoid")
			if humanoid then
				humanoid.Health = 0
			end
		end)
		
		if moving == true then
			local easingStyle = Enum.EasingStyle.Sine
			local easingDirection = Enum.EasingDirection.Out
			local repeatCount = -1
			local reverses = true
			local tweenInfo = TweenInfo.new(
				moveDuration,
				easingStyle,
				easingDirection,
				repeatCount,
				reverses,
				moveDelay
			)
			local newPosition = laser.Position + moveDirection
			local tweenTab = {Position = newPosition}
			local tween = TweenService:Create(laser, tweenInfo, tweenTab)
			tween:Play()
		end
	end
end


local function initiateCheckPoints()
	local checkpoints = game.Workspace.Checkpoints:GetChildren()
	for i, checkpoint in pairs(checkpoints) do
		local detectorPart = Instance.new("Part")
		detectorPart.Anchored = true
		detectorPart.Size = checkpoint.Size + Vector3.new(0, 12, 0)
		detectorPart.Position = checkpoint.Position + Vector3.new(0, detectorPart.Size.Y/2, 0)
		detectorPart.CanCollide = false
		detectorPart.Transparency = 0.5
		detectorPart.Parent = game.Workspace.Checkpoints
		detectorPart.Touched:Connect(function(partTouched)
			local partParent = partTouched.Parent
			local humanoid = partParent:FindFirstChild("Humanoid")
			local player = Players:GetPlayerFromCharacter(partParent)
			if player and humanoid and humanoid.Health > 0 then
				local playerCheckpoint = player:FindFirstChild("Checkpoint")
				if playerCheckpoint then
					playerCheckpoint.Value = checkpoint
				end
			end
		end)
	end
end


local function createMovingParts(platform)
	platform.Transparency = 1
	platform.CanCollide = false
	
	local attachment1 = Instance.new("Attachment")
	attachment1.Parent = platform
	attachment1.Name = "Attachment1"
	
	local solidPart = Instance.new("Part")
	solidPart.Shape = platform.Shape
	solidPart.Name = "SolidMovingPart"
	solidPart.Anchored = false
	solidPart.Size = platform.Size
	solidPart.Position = platform.Position
	
	local attachment0 = Instance.new("Attachment")
	attachment0.Parent = solidPart
	attachment0.Name = "Attachment0"
	
	local alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Parent = platform
	alignOrientation.Attachment0 = attachment0
	alignOrientation.Attachment1 = attachment1
	alignOrientation.RigidityEnabled = true
	
	local alignPosition = Instance.new("AlignPosition")
	alignPosition.Parent = platform
	alignPosition.Attachment0 = attachment0
	alignPosition.Attachment1 = attachment1
	alignPosition.RigidityEnabled = true
	
	solidPart.Parent = game.Workspace.Platforms
	solidPart:SetNetworkOwner(nil)
	
	return solidPart
end


local function initiatePlatforms()
	local platforms = game.Workspace.Platforms:GetChildren()
	for i, platform in pairs(platforms) do
		
		local currentPlatform = platform
		
		local moving = platform:FindFirstChild("Moving").Value or false
		local moveDuration = platform:FindFirstChild("MoveDuration").Value or 2
		local moveDirection = platform:FindFirstChild("MoveDirection").Value or Vector3.new(24, 0, 0)
		local moveDelay = platform:FindFirstChild("MoveDelay").Value or 0.5
		local spinning = platform:FindFirstChild("Spinning").Value or false
		local spinDelay = platform:FindFirstChild("SpinDelay").Value or 0
		local spinDuration = platform:FindFirstChild("SpinDuration").Value or 10
		local spinDirection = platform:FindFirstChild("SpinDirection").Value or Vector3.new(360, 0, 0) --clockwise default
		local disappearing = platform:FindFirstChild("Disappear").Value or false
		local disappearDelay = platform:FindFirstChild("DisappearDelay").Value or 3
		
		if moving == true then
			local function playTween()
				local easingStyle = Enum.EasingStyle.Sine
				local easingDirection = Enum.EasingDirection.Out
				local repeatCount = -1
				local reverses = true
				local tweenInfo = TweenInfo.new(
					moveDuration,
					easingStyle,
					easingDirection,
					repeatCount,
					reverses,
					moveDelay
				)
				local newPosition = platform.Position + moveDirection
				local tweenTab = {Position = newPosition}
				local tween = TweenService:Create(platform, tweenInfo, tweenTab)
				tween:Play()
			end
			currentPlatform = createMovingParts(platform)
			playTween()
		end
		
		if spinning == true then
			local function playTween()
				local easingStyle = Enum.EasingStyle.Linear
				local easingDirection = Enum.EasingDirection.In
				local repeatCount = -1
				local reverses = false
				local tweenInfo = TweenInfo.new(
					spinDuration,
					easingStyle,
					easingDirection,
					repeatCount,
					reverses,
					spinDelay
				)
				local newOrientation = platform.Orientation + spinDirection
				local tweenTab = {Orientation = newOrientation}
				local tween = TweenService:Create(platform, tweenInfo, tweenTab)
				tween:Play()
			end
			currentPlatform = createMovingParts(platform)
			playTween()
		end
		
		if disappearing == true then
			local function updatePlatform()
				local skip = false
				local incUp = false
				RunService.Heartbeat:Connect(function()
					if skip == false then
						local originalValue = false
						if incUp == true then
							originalValue = true
						end
						if currentPlatform.Transparency > 1 then
							incUp = false
							currentPlatform.Transparency -= 0.01
							
						elseif currentPlatform.Transparency < 0 then
							incUp = true
							currentPlatform.Transparency += 0.01
							
						elseif currentPlatform.Transparency == 1 then
							incUp = false
							currentPlatform.Transparency -= 0.01
							
						elseif currentPlatform.Transparency == 0 then
							incUp = true
							currentPlatform.Transparency += 0.01
							
						elseif currentPlatform.Transparency < 1 and currentPlatform.Transparency > 0 then
							if incUp == true then
								currentPlatform.CanCollide = false
								currentPlatform.Transparency += 0.01
							else
								currentPlatform.CanCollide = true
								currentPlatform.Transparency -= 0.01
							end
						end
						if originalValue ~= incUp then
							if incUp == true then
								skip = true
								task.delay(disappearDelay, function()
									for count = 1, 3 do
										wait(0.5)
										currentPlatform.Transparency = 0.5
										wait(0.5)
										currentPlatform.Transparency = 0
									end
									wait(1)
									skip = false
								end)
							else
								skip = true
								task.delay(1, function()
									skip = false
								end)
							end
						end
					end
				end)
			end
			task.spawn(updatePlatform)
		end	
	end
end


initiateSteps()
initiateLasers()
initiateCheckPoints()
initiatePlatforms()
