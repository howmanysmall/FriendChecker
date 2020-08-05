local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Vendor.Roact)

local FitComponent = Roact.Component:extend("FitComponent")
FitComponent.defaultProps = {
	ContainerProps = {},
	LayoutProps = {},
}

function FitComponent:init()
	self.Size, self.UpdateSize = Roact.createBinding(0)

	function self.SizeChanged(GuiObject)
		self.UpdateSize(GuiObject.AbsoluteContentSize.Y)
	end
end

function FitComponent:render()
	local ContainerProps = {}
	for Name, Value in next, self.props.ContainerProps do
		ContainerProps[Name] = Value
	end

	local Children = {}
	for Name, Value in next, (assert(self.props[Roact.Children], "No children given to FitComponent")) do
		Children[Name] = Value
	end

	assert(Children.Layout == nil, "No children named Layout should exist!")
	local LayoutProps = {}
	for Name, Value in next, self.props.LayoutProps do
		LayoutProps[Name] = Value
	end

	LayoutProps[Roact.Change.AbsoluteContentSize] = self.SizeChanged
	Children.Layout = Roact.createElement(self.props.LayoutClass, LayoutProps)
	ContainerProps.Size = self.Size:map(function(Y)
		return UDim2.new(1, 0, 0, Y)
	end)

	ContainerProps[Roact.Children] = Children
	return Roact.createElement(self.props.ContainerClass, ContainerProps)
end

return FitComponent
