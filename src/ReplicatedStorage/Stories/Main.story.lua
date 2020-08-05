local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Main = require(ReplicatedStorage.Components.Main)
local Roact = require(ReplicatedStorage.Vendor.Roact)

return function(Target: Instance): () -> nil
	local Handle = Roact.mount(Roact.createElement(Main), Target, "MainFrame")

	return function(): nil
		Roact.unmount(Handle)
	end
end