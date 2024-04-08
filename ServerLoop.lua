
print(game.ServerScriptService.Script.ServerLoop.Name.."📶")
-- TODO:
-- is it ok to not use WaitForChild inside server-script-service?
-- ... in relation to server-storage?
-- setup rojo for project

local function OnGameRestarted()
	print("Game restarted")
end

local function OnFlightStarted()
	print("Let's lfy!")
end


local SSS = game.ServerScriptService
local LOBBY_TIME = SSS.Property.LOBBY_TIME.Value
--BindableEvents
local GameRestarted = SSS.Event.GameRestarted
local FlightStarted = SSS.Event.FlightStarted


GameRestarted.Event:Connect(OnGameRestarted)
FlightStarted.Event:Connect(OnFlightStarted)


GameRestarted:Fire()

task.wait(LOBBY_TIME) 
FlightStarted:Fire()
