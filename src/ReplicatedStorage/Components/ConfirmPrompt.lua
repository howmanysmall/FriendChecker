local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GradientButton = require(ReplicatedStorage.Components.GradientButton)
local PerfectTextLabel = require(ReplicatedStorage.Components.PerfectTextLabel)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local DEFAULT_PADDING = {
	Horizontal = 50,
	Vertical = 10,
}

local BUTTON_HEIGHT = 30
local BUTTON_GAP = 10
local MAX_WIDTH = 300

local STYLES = {
	Neutral = {
		MinGradient = Color3.fromRGB(120, 120, 120),
		MaxGradient = Color3.fromRGB(120, 120, 120),
	},

	No = {
		MinGradient = Color3.fromRGB(201, 51, 37),
		MaxGradient = Color3.fromRGB(175, 38, 25),
		HoveredMaxGradient = Color3.fromRGB(197, 44, 30),
	},

	Yes = {
		MinGradient = Color3.fromRGB(49, 152, 48),
		MaxGradient = Color3.fromRGB(88, 169, 86),
		HoveredMaxGradient = Color3.fromRGB(120, 238, 118),
	},
}

local function Button(props)
	return Roact.createElement(PerfectTextLabel, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Font = Enum.Font.GothamSemibold,
		Position = UDim2.fromScale(0.5, 0.5),
		Text = props.Text,
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 24,

		RenderParent = function(Element, Size)
			return Roact.createElement(GradientButton, {
				BackgroundColor3 = Color3.new(1, 1, 1),
				BackgroundTransparency = 1,
				Image = "rbxassetid://4856545661",
				LayoutOrder = props.LayoutOrder,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(6, 4, 86, 20),
				Size = UDim2.new(0, math.max(Size.X.Offset + 25, 80), 1, 0),

				MinGradient = props.MinGradient,
				MaxGradient = props.MaxGradient,
				HoveredMaxGradient = props.HoveredMaxGradient,

				[Roact.Event.Activated] = props.Activated,
			}, {
				Element = Element,
			})
		end,
	})
end

local function ConfirmPrompt(props)
	local Buttons = {
		UIListLayout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	}

	for Name, ButtonObject in next, props.Buttons do
		local Style = STYLES[ButtonObject.Style] or {}

		Buttons[Name] = Roact.createElement(Button, {
			Activated = ButtonObject.Activated,
			LayoutOrder = ButtonObject.LayoutOrder,
			Text = ButtonObject.Text,

			MinGradient = Style.MinGradient,
			MaxGradient = Style.MaxGradient,
			HoveredMaxGradient = Style.HoveredMaxGradient,
		})
	end

	return Roact.createElement(PerfectTextLabel, {
		AnchorPoint = Vector2.new(0.5, 0),
		Font = Enum.Font.GothamSemibold,
		MaxWidth = props.MaxWidth or MAX_WIDTH,
		Position = UDim2.new(0.5, 0, 0, DEFAULT_PADDING.Vertical / 2),
		Text = props.Text,
		TextColor3 = Color3.new(1, 1, 1),
		TextScaled = true,
		TextSize = 26,

		RenderParent = function(Element, Size)
			return Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = "rbxassetid://4856545661",
				Position = UDim2.fromScale(0.5, 0.5),
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(6, 4, 86, 20),
				Size = Size
					+ UDim2.fromOffset(DEFAULT_PADDING.Horizontal, DEFAULT_PADDING.Vertical)
					+ UDim2.fromOffset(0, BUTTON_GAP + BUTTON_HEIGHT),
			}, {
				Text = Element,
				Buttons = Roact.createElement("Frame", {
					AnchorPoint = Vector2.new(0, 1),
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 1, -5),
					Size = UDim2.new(1, 0, 0, BUTTON_HEIGHT),
				}, Buttons),

				Gradient = Roact.createElement("UI" .. "Gradient", {
					Color = ColorSequence.new(Color3.fromRGB(65, 65, 65), Color3.fromRGB(82, 82, 82)),
					Rotation = 90,
				}),

				Scale = props.Scale and Roact.createElement("UIScale", {
					Scale = props.Scale,
				}),
			})
		end,
	})
end

return ConfirmPrompt