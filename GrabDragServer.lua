print("anydrag")
local player : Player = script.Parent

local red = workspace.Debug.red:Clone()
local yellow = workspace.Debug.yellow:Clone()
local green = workspace.Debug.green:Clone()

local root : BasePart = player:WaitForChild("HumanoidRootPart")

red.CFrame = root.CFrame
red.Parent = root

local pack = Instance.new("Folder")
pack.Name = player.Name .. " debug"
pack.Parent = workspace

yellow.Parent = pack
green.Parent = pack

local grabDistance = 15
local grabpart : BasePart = nil
local draghere : Attachment = yellow.draghere
local alignerp : AlignPosition = nil
local alignero : AlignOrientation = nil
local grabattach : Attachment = nil


local function YellowToCamera(owner : Player, cameraframe : CFrame)
	local offset = CFrame.new(0,0,-grabDistance)
	yellow.CFrame = cameraframe:ToWorldSpace(offset)
end

local function StickGreen(owner : Player, cameraframe : CFrame, cast : Ray)
	local Parameters = RaycastParams.new()
	Parameters.FilterType = Enum.RaycastFilterType.Exclude
	Parameters.FilterDescendantsInstances = {owner.Character}
	
	local Distance = 32

	local Raycast = game.Workspace:Raycast(cast.Origin, cast.Direction*Distance, Parameters)

	if Raycast then
		if Raycast.Instance then 
			grabDistance = Raycast.Distance
			green.CFrame = CFrame.lookAlong(Raycast.Position, cameraframe.LookVector)
			if Raycast.Instance:IsA("BasePart") then 
				grabpart = Raycast.Instance
				local desiredPivotCFrameInWorldSpace = green.CFrame
				grabpart.PivotOffset = grabpart.CFrame:ToObjectSpace(desiredPivotCFrameInWorldSpace)
				
				grabattach = Instance.new("Attachment")
				grabattach.Name = "grabattach"
				grabattach.Parent = grabpart
				grabattach.WorldCFrame = grabpart:GetPivot()
				
				alignerp = Instance.new("AlignPosition")
				alignerp.Parent = pack
				alignerp.MaxForce = 10000000
				alignerp.MaxAxesForce = Vector3.new(10000000,10000000,10000000) 
				alignerp.Responsiveness = 50
				alignerp.Attachment0 = grabattach
				alignerp.Attachment1 = draghere
				
				alignero = Instance.new("AlignOrientation")
				alignero.Parent = pack
				alignero.Attachment0 = grabattach
				alignero.Attachment1 = draghere
			end
		end
	end
end


local function MoveGrabbed()
	if grabpart ~= nil then
		--grabpart:PivotTo(yellow.CFrame)
	end
end

local function ungrab()
	grabpart = nil
	alignerp:Destroy()
	alignero:Destroy()
end

game.ReplicatedStorage.CameraUpdate.OnServerEvent:Connect(YellowToCamera)
game.ReplicatedStorage.HitGrab.OnServerEvent:Connect(StickGreen)
game.ReplicatedStorage.UnGrab.OnServerEvent:Connect(ungrab)
game["Run Service"].Heartbeat:Connect(MoveGrabbed)
