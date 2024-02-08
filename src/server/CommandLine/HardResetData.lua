local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Configuration = require(ReplicatedStorage.Shared.Configuration)

DataStoreService:GetDataStore("DataService" .. Configuration.DataStoreVersion):RemoveAsync(tostring(676056))
