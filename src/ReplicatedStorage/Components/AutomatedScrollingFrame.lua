local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Vendor.Roact)

local AutomatedScrollingFrame = Roact.Component:extend("AutomatedScrollingFrame")
AutomatedScrollingFrame.defaultProps = {
	LayoutProps = {},
	Native = {},
}

function AutomatedScrollingFrame:init()
	self.CanvasSize, self.UpdateCanvasSize = Roact.createBinding(UDim2.new())
	function self.Resize(GuiObject)
		self.UpdateCanvasSize(GuiObject.AbsoluteContentSize)
	end
end

function AutomatedScrollingFrame:render()
	local LayoutProps = {
		[Roact.Change.AbsoluteContentSize] = self.Resize,
	}

	for PropName, PropValue in next, self.props.LayoutProps do
		LayoutProps[PropName] = PropValue
	end

	local NativeProps = {
		CanvasSize = self.CanvasSize:map(function(Size)
			return UDim2.fromOffset(Size.X, Size.Y)
		end),
	}

	for PropName, PropValue in next, self.props.Native do
		NativeProps[PropName] = PropValue
	end

	return Roact.createElement("ScrollingFrame", NativeProps, {
		Layout = Roact.createElement(self.props.LayoutClass, LayoutProps),
		Children = Roact.createFragment(self.props[Roact.Children]),
	})
end

return AutomatedScrollingFrame
