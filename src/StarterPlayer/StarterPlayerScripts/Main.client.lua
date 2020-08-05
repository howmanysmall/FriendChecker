local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FriendService = require(ReplicatedStorage.FriendService)
-- local BitBuffer = require(ReplicatedStorage.BitBuffer)

local Main = require(ReplicatedStorage.Components.Main)
local Roact = require(ReplicatedStorage.Vendor.Roact)

Roact.mount(Roact.createElement(Roact.createElement("ScreenGui", {
	ResetOnSpawn = true,
}, {
	MainFrame = Roact.createElement(Main),
})), Players.LocalPlayer:WaitForChild("PlayerGui"), "Main")

-- local function SaveToBitBuffer(FriendsData)
-- 	local Buffer = BitBuffer()
-- 	local PlayerFriends = FriendsData.PlayerFriends
-- 	local Length = #PlayerFriends

-- 	Buffer.WriteUInt8(Length)
-- 	Buffer.WriteUnsigned(64, FriendsData.LastLogin)
-- 	Buffer.WriteUInt16(FriendsData.TimesPlayed)
-- 	Buffer.WriteTerminatedString(FriendsData.InterfaceTheme)

-- 	for _, PlayerFriend in ipairs(PlayerFriends) do
-- 		Buffer.WriteUnsigned(48, PlayerFriend.UserId)
-- 		Buffer.WriteTerminatedString(PlayerFriend.Username)
-- 		Buffer.WriteTerminatedString(PlayerFriend.LastOnline)
-- 		Buffer.WriteBoolean(PlayerFriend.IsOnline)
-- 		Buffer.WriteString(PlayerFriend.LastLocation)
-- 		Buffer.WriteUnsigned(48, PlayerFriend.PlaceId)
-- 		Buffer.WriteUnsigned(48, PlayerFriend.GameId)
-- 		Buffer.WriteTerminatedString(PlayerFriend.LocationType)
-- 	end

-- 	return Buffer.DumpString()
-- end

-- local function LoadFromBitBuffer(BufferData)
-- 	local Buffer = BitBuffer(BufferData)
-- 	local Length = Buffer.ReadUInt8()

-- 	local Data = {}
-- 	Data.LastLogin = Buffer.ReadUnsigned(64)
-- 	Data.TimesPlayed = Buffer.ReadUInt16()
-- 	Data.InterfaceTheme = Buffer.ReadTerminatedString()

-- 	local PlayerFriends = table.create(Length)
-- 	Data.PlayerFriends = PlayerFriends

-- 	for Index = 1, Length do
-- 		local PlayerFriend = {}
-- 		PlayerFriend.UserId = Buffer.ReadUnsigned(48)
-- 		PlayerFriend.Username = Buffer.ReadTerminatedString()
-- 		PlayerFriend.LastOnline = Buffer.ReadTerminatedString()
-- 		PlayerFriend.IsOnline = Buffer.ReadBoolean()
-- 		PlayerFriend.LastLocation = Buffer.ReadString()
-- 		PlayerFriend.PlaceId = Buffer.ReadUnsigned(48)
-- 		PlayerFriend.GameId = Buffer.ReadUnsigned(48)
-- 		PlayerFriend.LocationType = Buffer.ReadTerminatedString()

-- 		PlayerFriends[Index] = PlayerFriend
-- 	end

-- 	return Data
-- end

FriendService.PromiseAllFriends(Players.LocalPlayer):AndThen(function(Friends)
	local _ = {
		PlayerFriends = Friends;
		LastLogin = 0;
		TimesPlayed = 0;
		InterfaceTheme = "Dark";
	}
end)