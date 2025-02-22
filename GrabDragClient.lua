print("anydrag")
local player : Player = game.Players.LocalPlayer
print(player)


local camera : Camera = game.Workspace.CurrentCamera
local input = game.UserInputService
local mouse = game.Players.LocalPlayer:GetMouse()


local function PassCameraFrame()
	game.ReplicatedStorage.CameraUpdate:FireServer(camera.CFrame)
end


local function PassClickInfo()
	game.ReplicatedStorage.HitGrab:FireServer(camera.CFrame, mouse.UnitRay)
end

local function Ungrab()
	game.ReplicatedStorage.UnGrab:FireServer()
end

local function OnMouseUpdate()
	local delta :Vector2 = game.UserInputService:GetMouseDelta() 
	game.ReplicatedStorage.MouseUpdate:FireServer(delta)
end

mouse.Button2Down:Connect(Ungrab)
mouse.Button1Down:Connect(PassClickInfo)
game["Run Service"].Heartbeat:Connect(PassCameraFrame)
game["Run Service"]:BindToRenderStep("whatever", Enum.RenderPriority.Input.Value, OnMouseUpdate)
