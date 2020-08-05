local Players = game:GetService("Players")
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CollectionService = game:GetService("CollectionService")

-- local Data = require(ServerStorage.Data)
-- local LuaDateTime = require(ReplicatedStorage.LuaDateTime)
local ProfileService = require(ServerStorage.ProfileService)

local PROFILE_TEMPLATE = {
	PlayerFriends = {};
	LastLogin = 0;
	TimesPlayed = 0;
}

local GameProfileStore = ProfileService.GetProfileStore("PlayerData", PROFILE_TEMPLATE)
local Profiles = {}

local function UpdateLastLogin(Player, Profile)
	Profile.Data.TimesPlayed += 1
	print(Player.Name, "has played", Profile.Data.TimesPlayed, "times.")
	-- Profile.Data.LastLogin = LuaDateTime.Now()
end

local function PlayerAdded(Player: Player): nil
	if not CollectionService:HasTag(Player, "PlayerSetup") then
		CollectionService:AddTag(Player, "PlayerSetup")
		local Profile = GameProfileStore:LoadProfileAsync("Player" .. Player.UserId, "ForceLoad")
		if Profile then
			Profile:ListenToRelease(function()
				Profiles[Player] = nil
				Player:Kick("Your data has been saved.")
			end)

			if Player:IsDescendantOf(Players) then
				Profiles[Player] = Profile
				UpdateLastLogin(Player, Profile)
			else
				Profile:Release()
			end
		else
			Player:Kick("Couldn't load data.")
		end
	end
end

local function PlayerRemoving(Player: Player): nil
	local Profile = Profiles[Player]
	if Profile then
		Profile:Release()
	end
end

Players.PlayerAdded:Connect(PlayerAdded)
Players.PlayerRemoving:Connect(PlayerRemoving)
for _, Player in ipairs(Players:GetPlayers()) do
	PlayerAdded(Player)
end