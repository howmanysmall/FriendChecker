local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Roact = require(ReplicatedStorage.Vendor.Roact)

local Tooltip = Roact.Component:extend("Tooltip")
Tooltip.defaultProps = {
	HoverInSpeed = 3,
	HoverOutSpeed = 6,
	Size = UDim2.fromScale(1, 1),
}

function Tooltip:init()
	self.Transparency, self.UpdateTransparency = Roact.createBinding(0)

	function self.Heartbeat(DeltaTime)
		if self.props.Open and self.Transparency:getValue() < 1 then
			DeltaTime *= self.props.HoverInSpeed
			self.UpdateTransparency(math.min(1, self.Transparency:getValue() + DeltaTime))
		elseif not self.props.Open and self.Transparency:getValue() > 0 then
			DeltaTime *= self.props.HoverOutSpeed
			self.UpdateTransparency(math.max(0, self.Transparency:getValue() - DeltaTime))
		end
	end
end

function Tooltip:didMount()
	self.HeartbeatConnection = RunService.Heartbeat:Connect(self.Heartbeat)
end

function Tooltip:willUnmount()
	self.HeartbeatConnection = self.HeartbeatConnection:Disconnect()
end

function Tooltip:render()
	local TransparencyMap = self.Transparency:map(function(Transparency)
		return TweenService:GetValue(1 - Transparency, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	end)

	return Roact.createElement("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Image = "rbxassetid://4920898656",
		ImageColor3 = Color3.fromRGB(59, 59, 59),
		ImageTransparency = TransparencyMap,
		Position = UDim2.new(0.5, 0, 1, 5),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(24, 14, 45, 41),
		Size = self.props.Size,
	}, self.props.Render(TransparencyMap))
end

return Tooltip