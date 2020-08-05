-- local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local DataStore2 = require(ServerStorage.DataStore2)
local FunctionCalls = require(ServerStorage.FunctionCalls)
local GlobalData = require(ServerStorage.GlobalData)
local GameFunction = ReplicatedStorage.GameFunction

local DATA_TEMPLATE = {
	PlayerFriends = {};
	LastLogin = 0;
	TimesPlayed = 0;
	InterfaceTheme = "Dark";
}

DataStore2.Combine(
	"FriendsChecker" .. (RunService:IsStudio() and "Alpha" or "Release"),
	"PlayerData"
)

local function PlayerAdded(Player)
	if not CollectionService:HasTag(Player, "PlayerSetup") then
		CollectionService:AddTag(Player, "PlayerSetup")

		local PlayerDataStore = DataStore2("PlayerData", Player)

		PlayerDataStore:GetTableAsync(DATA_TEMPLATE):AndThen(function(PlayerData)
			GlobalData[Player] = PlayerData
		end):Catch(function(Error)
			warn(string.format("Error in PlayerDataStore:GetTableAsync(): %s", tostring(Error)))
			Player:Kick("Failed to load your data, we have kicked you as a safety precaution.")
		end):Finally(function()
			PlayerDataStore:OnUpdate(function(PlayerData)
				for Index, Value in next, PlayerData do
					if Index == "LastLogin" then
						continue
					end

					GlobalData[Player][Index] = Value
				end
			end)
		end)
	end
end

local function PlayerRemoving(Player)
	if GlobalData[Player] then
		GlobalData[Player] = nil
	end
end

local function OnServerInvoke(Player, FunctionCall, ...)
	local Function = FunctionCalls[FunctionCall]
	if Function then
		return Function(Player, ...)
	end
end

Players.PlayerAdded:Connect(PlayerAdded)
Players.PlayerRemoving:Connect(PlayerRemoving)
GameFunction.OnServerInvoke = OnServerInvoke
for _, Player in ipairs(Players:GetPlayers()) do
	PlayerAdded(Player)
end