print("anydrag")
local character : Model = script.Parent
local player : Player = game.Players:GetPlayerFromCharacter(character)

local red = workspace.Debug.red:Clone()
local yellow = workspace.Debug.yellow:Clone()
local green = workspace.Debug.green:Clone()

local root : BasePart = character:WaitForChild("HumanoidRootPart")

red.CFrame = root.CFrame
red.Parent = root

local pack = Instance.new("Folder")
pack.Name = character.Name .. " debug"
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
	if owner ~= player then return end
	local offset = CFrame.new(0,0,-grabDistance)
	yellow.CFrame = cameraframe:ToWorldSpace(offset)
	yellow.CFrame = CFrame.fromMatrix(yellow.Position,yellow.CFrame.RightVector, workspace.WorldPivot.UpVector)
end

local function TryGrab(owner : Player, cameraframe : CFrame, cast : Ray)
	local Parameters = RaycastParams.new()
	Parameters.FilterType = Enum.RaycastFilterType.Exclude
	Parameters.FilterDescendantsInstances = {owner.Character}

	local Distance = 32

	local Raycast = game.Workspace:Raycast(cast.Origin, cast.Direction*Distance, Parameters)

	if Raycast then
		if Raycast.Instance then 
			grabDistance = Raycast.Distance
			green.CFrame = CFrame.lookAlong(Raycast.Position, cameraframe.LookVector)
			green.CFrame = CFrame.fromMatrix(green.Position,green.CFrame.RightVector, workspace.WorldPivot.UpVector)
			if Raycast.Instance:IsA("BasePart") then 
				grabpart = Raycast.Instance
				local desiredPivotCFrameInWorldSpace = green.CFrame
				grabpart.PivotOffset = grabpart.CFrame:ToObjectSpace(desiredPivotCFrameInWorldSpace)

				grabattach = Instance.new("Attachment")
				grabattach.Name = "grabattach"
				grabattach.Parent = grabpart
				grabattach.WorldCFrame = grabpart:GetPivot()


				alignerp = Instance.new("AlignPosition")
				alignerp.Name = "alignerposit"
				alignerp.Parent = pack
				alignerp.MaxForce = 10000000
				alignerp.MaxAxesForce = Vector3.new(10000000,10000000,10000000) 
				alignerp.Responsiveness = 50
				alignerp.Attachment0 = grabattach
				alignerp.Attachment1 = draghere

				alignero = Instance.new("AlignOrientation")
				alignerp.Name = "alignerorient"
				alignero.Parent = pack
				alignero.MaxTorque = 10000000
				alignero.Attachment0 = grabattach
				alignero.Attachment1 = draghere
			end
		end
	end
end

local function ungrab(owner : Player)
	if owner ~= player then return end
	grabpart = nil
	alignerp:Destroy()
	alignero:Destroy()
	alignerp = nil
	alignero = nil
end

local function LeftClick(owner : Player, cameraframe : CFrame, cast : Ray)
	if owner ~= player then return end
	
	print("left click from " .. character.Name)
	if not alignerp then
		TryGrab(owner,cameraframe,cast)
	else
		ungrab(owner)
	end
	
	
end




local function MoveGrabbed()
	if grabpart ~= nil then
		--grabpart:PivotTo(yellow.CFrame)
		green.CFrame = grabpart:GetPivot()
	end
end

local BezierPath =require(game.ReplicatedStorage["BezierPath2.0"])
local Positions = {
	red.Position,
	yellow.Position,
	green.Position
}
local visParts = {}
local NewPath = BezierPath.new(Positions,3)
local visFolder = Instance.new("Folder")
visFolder.Name = player.Name .. " arrows"
visFolder.Parent = workspace
for T = 0.0,1.0,1/30.0 do
	local arrowCopy = workspace.Debug.arrow:Clone()
	arrowCopy.Parent = visFolder
	arrowCopy.CFrame = NewPath:CalculateUniformCFrame(T)
	table.insert(visParts,arrowCopy)
end

local beamRY = workspace.Debug.BeamRY
local beamYG = workspace.Debug.BeamYG
beamRY.Attachment0 = root.RootAttachment


local function DrawGrabHint()
	--Positions = {
	--	red.Position,
	--	yellow.Position,
	--	green.Position
	--}
	--NewPath = BezierPath.new(Positions,3)

	--for index, value in visParts do
	--	value.CFrame = NewPath:CalculateUniformCFrame(index/30.0)
	--end
	beamRY.Attachment1 = draghere
	beamYG.Attachment0 = draghere
	beamYG.Attachment1 = grabattach
end

local function UpdateCurve(player : Player, delta : Vector2)
	if math.sign(delta.X) == math.sign(beamRY.CurveSize1) then 
		beamRY.CurveSize1 = 0
	end
	beamRY.CurveSize1 -= delta.X/100.0
	beamRY.CurveSize1 = math.clamp(beamRY.CurveSize1,-10,10)
end

local function ReachCurveZero()
	--beamRY.CurveSize1 = (math.abs(beamRY.CurveSize1) - 0.01) * math.sign(beamRY.CurveSize1)
	--local result = math.lerp(beamRY.CurveSize1, 0, 0.05)
	--beamRY.CurveSize1 = result
end

game.ReplicatedStorage.CameraUpdate.OnServerEvent:Connect(YellowToCamera)
game.ReplicatedStorage.HitGrab.OnServerEvent:Connect(LeftClick)
game.ReplicatedStorage.UnGrab.OnServerEvent:Connect(ungrab)
game.ReplicatedStorage.MouseUpdate.OnServerEvent:Connect(UpdateCurve)
game["Run Service"].Heartbeat:Connect(MoveGrabbed)
game["Run Service"].Heartbeat:Connect(DrawGrabHint)
game["Run Service"].Heartbeat:Connect(ReachCurveZero)
