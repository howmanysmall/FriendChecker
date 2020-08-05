local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Constants)
local GlobalData = require(script.Parent.GlobalData)

return {
	[Constants.GET_INFO] = function(Player)
		return GlobalData[Player]
	end;
}