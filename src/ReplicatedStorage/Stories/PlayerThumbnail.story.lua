local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Vendor.Roact)
local PlayerThumbnail = require(ReplicatedStorage.Components.PlayerThumbnail)

local function TestPlayerThumbnail()
	return Roact.createElement("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
	}, {
		UIGridLayout = Roact.createElement("UIGridLayout"),
		Pobammer = Roact.createElement(PlayerThumbnail, {
			UserId = 16492520,
			ThumbnailType = Enum.ThumbnailType.HeadShot,
			ThumbnailSize = Enum.ThumbnailSize.Size420x420,
			CornerRadius = UDim.new(0, 0),
		}),

		Movsb = Roact.createElement(PlayerThumbnail, {
			UserId = 77284141,
			ThumbnailType = Enum.ThumbnailType.AvatarBust,
			ThumbnailSize = Enum.ThumbnailSize.Size100x100,
			CornerRadius = UDim.new(1, 0),
			LayoutOrder = 1,
		}),

		Brookie = Roact.createElement(PlayerThumbnail, {
			UserId = 499349487,
			ThumbnailType = Enum.ThumbnailType.AvatarThumbnail,
			ThumbnailSize = Enum.ThumbnailSize.Size100x100,
			CornerRadius = UDim.new(0.25, 0),
			LayoutOrder = 2,
		}),
	})
end

return function(Target: Instance): () -> nil
	local Tree = Roact.mount(Roact.createElement(TestPlayerThumbnail), Target, "PlayerThumbnails")
	return function(): nil
		Roact.unmount(Tree)
	end
end