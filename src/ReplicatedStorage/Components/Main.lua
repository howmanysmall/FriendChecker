local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Color3Lerp = require(ReplicatedStorage.Color3Lerp)
local Otter = require(ReplicatedStorage.Vendor.Otter)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)

local IS_READY = false

local Main = Roact.Component:extend("Main")
Main.defaultProps = {
	Theme = "Dark",
}

function Main:init(props)
	self.ThemeAlpha, self.SetThemeAlpha = Roact.createBinding(props.Theme == "Dark" and 0 or 1)
	self.ThemeMotor = Otter.createSingleMotor(self.ThemeAlpha:getValue())
	self.MainFrameLerp = Color3Lerp(Color3.fromRGB(36, 36, 36), Color3.new(1, 1, 1))

	self.ThemeMotor:onStep(self.SetThemeAlpha)
	self:setState({
		IsDarkTheme = props.Theme == "Dark",
	})
end

function Main:render()
	return Roact.createElement("Frame", {
		BackgroundColor3 = self.MainFrameLerp(self.ThemeAlpha:getValue()),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
	}, {
		ChangeTheme = Roact.createElement("TextButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(200, 50),
			Font = Enum.Font.GothamBlack,
			Text = "Change Theme",
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 24,
			TextStrokeColor3 = Color3.new(),
			TextStrokeTransparency = 0.8,

			[Roact.Event.MouseButton1Click] = function()
				local IsDarkTheme = not self.state.IsDarkTheme
				self:setState({
					IsDarkTheme = IsDarkTheme,
				})

				self.ThemeMotor:setGoal(Otter.spring(IsDarkTheme and 0 or 1, {
					frequency = 1,
					dampingRatio = 1,
				}))
			end,
		}),
	})
end

-- function Main:render()
-- 	return Roact.createElement("ScreenGui", {
-- 		ResetOnSpawn = false,
-- 	}, {
-- 		MainFrame = Roact.createElement("Frame", {
-- 			BackgroundColor3 = self.MainFrameLerp(self.ThemeAlpha:getValue()),
-- 			BorderSizePixel = 0,
-- 			Size = UDim2.fromScale(1, 1),
-- 		}, {
-- 			ChangeTheme = Roact.createElement("TextButton", {
-- 				AnchorPoint = Vector2.new(0.5, 0.5),
-- 				BackgroundTransparency = 1,
-- 				Position = UDim2.fromScale(0.5, 0.5),
-- 				Size = UDim2.fromOffset(200, 50),
-- 				Font = Enum.Font.GothamBlack,
-- 				Text = "Change Theme",
-- 				TextColor3 = Color3.new(1, 1, 1),
-- 				TextSize = 24,
-- 				TextStrokeColor3 = Color3.new(),
-- 				TextStrokeTransparency = 0.8,

-- 				[Roact.Event.MouseButton1Click] = function()
-- 					local IsDarkTheme = not self.state.IsDarkTheme
-- 					self:setState({
-- 						IsDarkTheme = IsDarkTheme,
-- 					})

-- 					self.ThemeMotor:setGoal(Otter.spring(IsDarkTheme and 0 or 1, {
-- 						frequency = 1,
-- 						dampingRatio = 1,
-- 					}))
-- 				end,
-- 			}),
-- 		}),
-- 	})
-- end

if IS_READY then
	return RoactRodux.connect(function(_, _)
	end, function(Dispatch)
		return {
			ChangeTheme = function()
				Dispatch({
					type = "ChangeTheme",
				})
			end,
		}
	end)(Main)
else
	return Main
end