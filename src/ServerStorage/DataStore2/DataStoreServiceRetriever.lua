-- This function is monkey patched to return MockDataStoreService during tests
local ServerStorage = game:GetService("ServerStorage")
local DataStoreService = require(ServerStorage.DataStoreService)

local DataStoreServiceRetriever = {}

function DataStoreServiceRetriever.Get()
	return DataStoreService
end

return DataStoreServiceRetriever
