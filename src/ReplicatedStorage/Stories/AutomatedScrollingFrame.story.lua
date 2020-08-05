local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AutomatedScrollingFrame = require(ReplicatedStorage.Components.AutomatedScrollingFrame)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local function Cruft()
	return Roact.createElement("Frame", {
		BackgroundColor3 = Color3.new(math.random(), math.random(), math.random()),
		Size = UDim2.new(1, 0, 0, 150),
	})
end

local function TestScrollingFrame()
	return Roact.createElement(AutomatedScrollingFrame, {
		LayoutClass = "UIListLayout",
		Native = {
			Size = UDim2.fromScale(0.8, 0.8),
		},
	}, {
		Roact.createElement(Cruft),
		Roact.createElement(Cruft),
		Roact.createElement(Cruft),
		Roact.createElement(Cruft),
		Roact.createElement(Cruft),
		Roact.createElement(Cruft),
		Roact.createElement(Cruft),
		Roact.createElement(Cruft),
		Roact.createElement(Cruft),
		Roact.createElement(Cruft),
		Roact.createElement(Cruft),
		Roact.createElement(Cruft),
	})
end

return function(Target: Instance): () -> nil
	local Handle = Roact.mount(Roact.createElement(TestScrollingFrame), Target, "AutomatedScrollingFrame")

	return function(): nil
		Roact.unmount(Handle)
	end
end
