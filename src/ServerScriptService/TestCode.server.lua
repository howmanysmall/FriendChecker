local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enumeration = require(ReplicatedStorage.Enumerations)

print("3:", Enumeration.LocationType:Cast(3))
print("5:", Enumeration.LocationType:Cast(5))