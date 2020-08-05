local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FitComponent = require(ReplicatedStorage.Components.FitComponent)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local function Content(props)
	return Roact.createElement("TextLabel", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.5,
		LayoutOrder = props.Number,
		Size = UDim2.new(1, 0, 0, 30),
		Text = props.Number,
		TextColor3 = Color3.new(1, 1, 1),
	})
end

local function TestFitComponent()
	return Roact.createElement(FitComponent, {
		ContainerClass = "Frame",
		ContainerProps = {
			BackgroundColor3 = Color3.new(1, 0, 0),
			ClipsDescendants = true,
		},

		LayoutClass = "UIListLayout",
		LayoutProps = {
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
	}, {
		Roact.createElement(Content, {Number = 3}),
		Roact.createElement(Content, {Number = 2}),
		Roact.createElement(Content, {Number = 1}),
	})
end

return function(Target: Instance): () -> nil
	local Handle = Roact.mount(Roact.createElement(TestFitComponent), Target, "FitComponent")

	return function(): nil
		Roact.unmount(Handle)
	end
end
