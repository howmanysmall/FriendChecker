local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local Cryo = require(ReplicatedStorage.Vendor.Cryo)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local function PerfectTextLabel(props)
	props = Cryo.Dictionary.copy(props)
	assert(props.Text ~= nil, "Text is nil")
	assert(props.TextSize ~= nil, "TextSize is nil")
	assert(props.Font ~= nil, "Font is nil")

	local TextSize = TextService:GetTextSize(
		props.Text,
		props.TextSize,
		props.Font,
		Vector2.new(props.MaxWidth or math.huge, math.huge)
	) + Vector2.new(2, 2)

	local TextSizeY = TextSize.Y
	if props.MaxHeight ~= nil then
		TextSizeY = math.min(TextSize.Y, props.MaxHeight)
	end

	props.MaxWidth = nil
	props.BackgroundTransparency = 1
	props.Size = UDim2.new(UDim.new(0, TextSize.X), props.ForceY or UDim.new(0, TextSizeY))
	props.TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center

	props.ForceY = nil
	props.MaxHeight = nil

	if props.RenderParent then
		local renderParent = props.RenderParent
		props.RenderParent = nil
		return renderParent(Roact.createElement("TextLabel", props), props.Size)
	else
		return Roact.createElement("TextLabel", props)
	end
end

return PerfectTextLabel