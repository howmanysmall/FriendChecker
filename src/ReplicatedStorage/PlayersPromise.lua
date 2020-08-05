local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Vendor.Promise)

local PlayersPromise = {}

-- type FriendInfo = {
-- 	Id: number,
-- 	Username: string,
-- 	IsOnline: boolean
-- }

local function PagesToArray(FriendPages)
	local Friends = {}
	local Length = 0

	while true do
		for _, Item in ipairs(FriendPages:GetCurrentPage()) do
			Length += 1
			Friends[Length] = Item
		end

		if FriendPages.IsFinished then
			break
		end

		FriendPages:AdvanceToNextPageAsync()
	end

	return Friends
end

function PlayersPromise.PromiseFriends(UserId)
	return Promise.Defer(function(Resolve, Reject)
		local Success, FriendPages = pcall(Players.GetFriendsAsync, Players, UserId)
		if Success then
			Resolve(PagesToArray(FriendPages))
		else
			Reject(FriendPages)
		end
	end)
end

local function GetUserThumbnail(UserId, ThumbnailType, ThumbnailSize)
	local Content, IsReady
	local Success, Error = pcall(function()
		Content, IsReady = Players:GetUserThumbnailAsync(UserId, ThumbnailType, ThumbnailSize)
	end)

	if not Success then
		return Promise.Reject(Error)
	else
		if IsReady then
			return Promise.Resolve(Content)
		end
	end
end

function PlayersPromise.PromiseUserThumbnail(UserId, ThumbnailType, ThumbnailSize)
	return Promise.Defer(function(Resolve)
		Resolve(Promise.Retry(GetUserThumbnail, 5, UserId, ThumbnailType, ThumbnailSize))
	end)
end

function PlayersPromise.PromiseNameFromUserId(UserId)
	return Promise.Defer(function(Resolve, Reject)
		local Success, Value = pcall(Players.GetNameFromUserIdAsync, Players, UserId);
		(Success and Resolve or Reject)(Value)
	end)
end

function PlayersPromise.PromiseUserIdFromName(Name)
	return Promise.Defer(function(Resolve, Reject)
		local Success, Value = pcall(Players.GetUserIdFromNameAsync, Players, Name);
		(Success and Resolve or Reject)(Value)
	end)
end

return PlayersPromise