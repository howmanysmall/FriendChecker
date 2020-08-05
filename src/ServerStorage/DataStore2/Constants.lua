local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Symbol = require(ReplicatedStorage.Vendor.Symbol)

return {
	SaveFailure = {
		BeforeSaveError = Symbol("BeforeSaveError"),
		DataStoreFailure = Symbol("DataStoreFailure"),
		InvalidData = Symbol("InvalidData"),
	},
}
