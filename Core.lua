local myHuman = script.Parent:WaitForChild('Humanoid')
local myRoot = script.Parent:WaitForChild('Torso')
local myHead = script.Parent:WaitForChild('Head')

local PathfindingService = game:GetService('PathfindingService')

local meowTick,meowIteration = tick(),math.random(1,10) -- for the meows :3

-- prevents lagging from clientside
for i,v in pairs(script.Parent:GetChildren()) do
	if not v:IsA('BasePart') then continue end
	if v.Anchored then continue end
	v:SetNetworkOwner(nil)
end
-- auto delete cat if dead
myHuman.Died:Once(function()
	myHead.DIE:Play()
	
	script.Parent.Animate:Destroy()
	script.Parent.Core:Destroy()
end)


local function checkForPly()
	local t = nil
	local d = 100
	for _,v in pairs(game.Players:GetPlayers()) do
		local distance = (myRoot.Position - v.Character.HumanoidRootPart.Position).Magnitude
		if distance < d then
			d = distance; t = v
		end
	end
	return t
end
local function chaseTarget(t)
	local targetRootPart = t.Character:FindFirstChild('HumanoidRootPart'); if not targetRootPart then return end
	local path = PathfindingService:CreatePath({
		AgentHeight = 2;
		AgentCanJump = true;
		Costs = {
			Water = 100;
		};
	})
	
	repeat task.wait()
		local success,errormessage = pcall(function()
			path:ComputeAsync(myRoot.Position,targetRootPart.Position)
		end)
		
		local tMoved = false
		local oldPosition = (targetRootPart.Position - myRoot.Position).Magnitude
		if success and path.Status == Enum.PathStatus.Success then
			for i,v in pairs(path:GetWaypoints()) do
				if v.Action == Enum.PathWaypointAction.Jump then
					myHuman.Jump = true
					myHead['Cat' .. math.random(1,6)]:Play()
				end
				
				myHuman:MoveTo(v.Position)
				myHuman.MoveToFinished:Wait()
				
				local d = (targetRootPart.Position - myRoot.Position).Magnitude
				if math.abs(oldPosition - d) > 7 then
					tMoved = true; break
				elseif d <= 6 then
					if (tick() - meowTick) >= meowIteration then
						meowTick = tick()
						meowIteration = math.random(1,10)
						
						myHuman.Jump = true
						myHead['Cat' .. math.random(1,6)]:Play()
					end
					
				end
			end
		end
	until not t or not t.Character or not targetRootPart or t.Character.Humanoid.Health <= 0 or not success or not tMoved
	
end
while task.wait() do
	
	pcall(function()
		local target = checkForPly()
		if not target then task.wait(2) return end

		chaseTarget(target)
		
	end)
	
end
