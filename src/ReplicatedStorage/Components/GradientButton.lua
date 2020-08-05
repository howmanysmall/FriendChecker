local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Color3Lerp = require(ReplicatedStorage.Color3Lerp)
local Cryo = require(ReplicatedStorage.Vendor.Cryo)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local GradientButton = Roact.Component:extend("GradientButton")
GradientButton.defaultProps = {
	AnimateSpeed = 8,
	GradientRotation = 90,
	MinGradient = Color3.fromRGB(65, 65, 65),
	MaxGradient = Color3.fromRGB(82, 82, 82),
	HoveredMaxGradient = Color3.fromRGB(110, 110, 110),
}

function GradientButton:init()
	self.Total, self.SetTotal = Roact.createBinding(0)

	function self.Hover()
		self.Direction = 1
		self:Animate()

		if self.props[Roact.Event.MouseEnter] then
			self.props[Roact.Event.MouseEnter]()
		end
	end

	function self.Unhover()
		self.Direction = -1
		self:Animate()

		if self.props[Roact.Event.MouseLeave] then
			self.props[Roact.Event.MouseLeave]()
		end
	end

	function self.ColorMap(Total)
		return ColorSequence.new(
			self.props.MinGradient,
			Color3Lerp(self.props.MaxGradient, self.props.HoveredMaxGradient, math.sin(Total * 1.5707963267949))
		)
	end
end

function GradientButton:Animate()
	if self.AnimateLoop == nil then
		self.AnimateLoop = RunService.Heartbeat:Connect(function(DeltaTime)
			self.SetTotal(math.clamp(self.Total:getValue() + DeltaTime * self.Direction * self.props.AnimateSpeed, 0, 1))
		end)
	end
end

function GradientButton:willUnmount()
	if self.AnimateLoop then
		self.AnimateLoop = self.AnimateLoop:Disconnect()
	end
end

function GradientButton:render()
	local props = Cryo.Dictionary.copy(self.props)
	for DefaultProperty in next, GradientButton.defaultProps do
		props[DefaultProperty] = nil
	end

	props[Roact.Event.MouseEnter] = self.Hover
	props[Roact.Event.MouseLeave] = self.Unhover

	table.insert(props[Roact.Children], Roact.createElement("UI" .. "Gradient", {
		Color = self.Total:map(self.ColorMap),
		Rotation = self.props.GradientRotation,
	}))

	return Roact.createElement("ImageButton", props)
end

return GradientButton