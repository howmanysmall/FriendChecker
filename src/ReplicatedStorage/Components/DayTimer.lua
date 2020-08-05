local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Cryo = require(ReplicatedStorage.Vendor.Cryo)
local Promise = require(ReplicatedStorage.Vendor.Promise)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local DayTimer = Roact.Component:extend("DayTimer")
local SECONDS_IN_DAY = 24 * 60 * 60

local function GetTimerValue()
	local Date = os.date("!*t", os.time() + SECONDS_IN_DAY)
	return os.time {
		year = Date.year;
		month = Date.month;
		day = Date.day;
		hour = 0;
		minute = 0;
		sec = 0;
	} - os.time()
end

function DayTimer:init(props)
	local TimerValue
	if props.TimeSince then
		TimerValue = SECONDS_IN_DAY - (os.time() - props.TimeSince)
	else
		TimerValue = GetTimerValue()
	end

	self:setState({
		TimerValue = TimerValue,
	})
end

function DayTimer:didMount()
	self.Running = true
	self.Promise = Promise.Defer(function(_, _, OnCancel)
		if OnCancel(function()
			self.Running = false
		end) then return end

		while self.Running do
			print("Updating!")
			Promise.Delay(1):Await()
			if not self.Running then
				break
			end

			self:setState(function(State)
				local TimerValue = State.TimerValue - 1
				if TimerValue <= 0 and not self.props.Overflow then
					TimerValue = 0
					self.Promise:Cancel()
					self.Promise = nil
					self.Running = false
				end

				return {
					TimerValue = TimerValue,
				}
			end)
		end
	end)
end

function DayTimer:willUnmount()
	if self.Promise then
		self.Promise:Cancel()
		self.Promise = nil
	end
end

function DayTimer:render()
	return Roact.createElement("TextLabel", Cryo.Dictionary.assign({
		AutoLocalize = false,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		TextColor3 = Color3.new(1, 1, 1),
		TextScaled = true,
		Text = string.format(
			"%02d:%02d:%02d",
			math.floor(self.state.TimerValue / 3600),
			math.floor(self.state.TimerValue / 60) % 60,
			self.state.TimerValue % 60
		),
	}, self.props.Native or {}))
end

return DayTimer