local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersPromise = require(ReplicatedStorage.PlayersPromise)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local PlayerThumbnail = Roact.Component:extend("PlayerThumbnail")
PlayerThumbnail.defaultProps = {
	UserId = 1,
	ThumbnailType = Enum.ThumbnailType.HeadShot,
	ThumbnailSize = Enum.ThumbnailSize.Size420x420,
	CornerRadius = UDim.new(0, 0),

	AnchorPoint = Vector2.new(),
	LayoutOrder = 0,
	Position = UDim2.new(),
	Size = UDim2.fromScale(1, 1),
	Visible = true,
	ZIndex = 1,
}

function PlayerThumbnail:init()
	self:setState({
		UserThumbnail = "rbxasset://textures/ui/GuiImagePlaceholder.png",
	})
end

function PlayerThumbnail:willUnmount()
	if self.Promise then
		self.Promise:Cancel()
		self.Promise = nil
	end
end

function PlayerThumbnail:didMount()
	self.Promise = PlayersPromise.PromiseUserThumbnail(self.props.UserId, self.props.ThumbnailType, self.props.ThumbnailSize):AndThen(function(UserThumbnail)
		self:setState({
			UserThumbnail = UserThumbnail,
		})
	end):Catch(function(Error)
		warn(string.format("PlayersPromise.PromiseUserThumbnail failed: %s", tostring(Error)))
		self:setState({
			UserThumbnail = "rbxasset://textures/ui/GuiImagePlaceholder.png",
		})
	end)
end

function PlayerThumbnail:render()
	return Roact.createElement("ImageLabel", {
		AnchorPoint = self.props.AnchorPoint,
		BackgroundTransparency = 1,
		LayoutOrder = self.props.LayoutOrder,
		Position = self.props.Position,
		Size = self.props.Size,
		Visible = self.props.Visible,
		ZIndex = self.props.ZIndex,
		Image = self.state.UserThumbnail,
	}, {
		UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint"),
		UICorner = Roact.createElement("UI" .. "Corner", {
			CornerRadius = self.props.CornerRadius,
		}),
	})
end

return PlayerThumbnail