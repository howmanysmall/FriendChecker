local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Cryo = require(ReplicatedStorage.Vendor.Cryo)
local PlayersPromise = require(ReplicatedStorage.PlayersPromise)
local Promise = require(ReplicatedStorage.Vendor.Promise)

local FriendService = {}

local LocationTypeMap = {
	[0] = "MobileWebsite";
	[1] = "MobileInGame";
	[2] = "Website";
	[3] = "Studio";
	[4] = "InGame";
	[5] = "Xbox";
	[6] = "TeamCreate";
	[7] = "Offline";
}

function FriendService.PromiseFriendsOnline(Player: Player, MaxFriends: number)
	return Promise.Defer(function(Resolve, Reject)
		local Success, Friends = pcall(Player.GetFriendsOnline, Player, MaxFriends)
		if Success then
			local NewArray = table.create(#Friends)
			for Index, FriendData in ipairs(Friends) do
				NewArray[Index] = {
					UserId = FriendData.VisitorId;
					Username = FriendData.UserName;
					LastOnline = FriendData.LastOnline;
					IsOnline = FriendData.IsOnline;
					LastLocation = FriendData.LastLocation or "";
					PlaceId = FriendData.PlaceId or 0;
					GameId = FriendData.GameId or 0;
					LocationType = LocationTypeMap[FriendData.LocationType];
					-- LocationType = Enumeration.LocationType:Cast(FriendData.LocationType);
				}
			end

			Resolve(NewArray)
		else
			Reject(Friends)
		end
	end)
end

function FriendService.GetFriendsOnline(Player: Player, MaxFriends: number)
	local Success, Friends = FriendService.PromiseFriendsOnline(Player, MaxFriends):Await()
	if Success then
		return Friends
	else
		error(Friends, 2)
	end
end

function FriendService.PromiseAllFriends(Player: Player)
	local Promises = table.create(2)
	Promises[1] = FriendService.PromiseFriendsOnline(Player, 200)
	Promises[2] = PlayersPromise.PromiseFriends(Player.UserId)

	return Promise.All(Promises):AndThen(function(Array)
		local AllFriends = table.create(#Array[2])
		local Length = 0

		for _, OnlineFriend in ipairs(Array[1]) do
			Length += 1
			AllFriends[Length] = OnlineFriend
		end

		for _, OtherFriend in ipairs(Array[2]) do
			if Cryo.List.findWhere(AllFriends, function(Friend)
				return Friend.UserId == OtherFriend.Id
			end) then
				continue
			end

			Length += 1
			AllFriends[Length] = {
				UserId = OtherFriend.Id;
				Username = OtherFriend.Username;
				LastOnline = "";
				IsOnline = false;
				LastLocation = "Offline";
				PlaceId = 0;
				GameId = 0;
				LocationType = "Offline";
			}
		end

		return Promise.Resolve(AllFriends)
	end)
end

function FriendService.GetAllFriends(Player: Player)
	local Success, AllFriends = FriendService.PromiseAllFriends(Player):Await()
	if Success then
		return AllFriends
	else
		error(AllFriends, 2)
	end
end

return FriendService