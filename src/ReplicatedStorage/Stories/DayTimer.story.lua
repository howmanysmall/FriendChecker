local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DayTimer = require(ReplicatedStorage.Components.DayTimer)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local function TextLabel(props)
	return Roact.createElement("TextLabel", {
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
		Text = props.Text,
		TextColor3 = Color3.new(1, 1, 1),
		TextScaled = true,
	})
end

local function TestDayTimer()
	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, {
		UIGridLayout = Roact.createElement("UIGridLayout", {
			CellSize = UDim2.fromScale(0.49, 0.1),
			CellPadding = UDim2.fromScale(0.01, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		DefaultPropsLabel = Roact.createElement(TextLabel, {
			LayoutOrder = 1,
			Text = "Default",
		}),

		DefaultPropsTimer = Roact.createElement(DayTimer, {
			Native = {
				LayoutOrder = 2,
			},
		}),

		TimeSinceLabel = Roact.createElement(TextLabel, {
			LayoutOrder = 3,
			Text = "TimeSince = os.time() - 60",
		}),

		TimeSinceTimer = Roact.createElement(DayTimer, {
			TimeSince = os.time() - 60,
			Native = {
				LayoutOrder = 4,
			},
		}),
	})
end

return function(Target: Instance): () -> nil
	local Handle = Roact.mount(Roact.createElement(TestDayTimer), Target, "DayTimer")
	return function(): nil
		Roact.unmount(Handle)
	end
end