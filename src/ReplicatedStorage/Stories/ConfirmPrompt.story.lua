local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ConfirmPrompt = require(ReplicatedStorage.Components.ConfirmPrompt)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local function CreatePrompt()
	return Roact.createElement("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
	}, {
		ConfirmPrompt = Roact.createElement(ConfirmPrompt, {
			Buttons = {
				-- {
				-- 	Activated = function()
				-- 		print("Activated Neutral")
				-- 	end,
		
				-- 	Style = "Neutral",
				-- 	LayoutOrder = 0,
				-- 	Text = "Neutral",
				-- },
		
				{
					Activated = function()
						print("Activated Yes")
					end,
		
					Style = "Yes",
					LayoutOrder = 1,
					Text = "Yes",
				},
		
				{
					Activated = function()
						print("Activated No")
					end,
		
					Style = "No",
					LayoutOrder = 2,
					Text = "No",
				},
			},
		
			Text = "Properties.Text",
			Scale = 1,
		}),
	})
end

return function(Target: Instance): () -> nil
	local Tree = Roact.mount(Roact.createElement(CreatePrompt), Target, "ConfirmPrompt")
	return function(): nil
		Roact.unmount(Tree)
	end
end