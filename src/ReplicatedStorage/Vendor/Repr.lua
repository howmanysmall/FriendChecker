local DEFAULT_SETTINGS = {
	Pretty = true;
	RobloxFullName = false;
	RobloxProperFullName = true;
	RobloxClassName = true;
	Tabs = true;
	Semicolons = true;
	Spaces = 4;
	SortKeys = true;
}

local LUA_KEYWORDS = {
	["and"] = true;
	["break"] = true;
	["do"] = true;
	["else"] = true;
	["elseif"] = true;
	["end"] = true;
	["false"] = true;
	["for"] = true;
	["function"] = true;
	["if"] = true;
	["in"] = true;
	["local"] = true;
	["nil"] = true;
	["not"] = true;
	["or"] = true;
	["repeat"] = true;
	["return"] = true;
	["then"] = true;
	["true"] = true;
	["until"] = true;
	["while"] = true;
}

local function IsLuaIdentifier(String)
	return not (type(String) ~= "string" or #String == 0 or string.find(String, "[^%d%a_]") or tonumber(string.sub(String, 1, 1)) or LUA_KEYWORDS[String])
end

local function ProperFullName(Object)
	if Object == nil or Object == game then
		return ""
	end

	local String = Object.Name
	local UsePeriod = true
	if not IsLuaIdentifier(String) then
		String = string.format("[%q]", String)
		UsePeriod = false
	end

	if not Object.Parent or Object.Parent == game then
		return String
	else
		return ProperFullName(Object.Parent) .. (UsePeriod and "." or "") .. String
	end
end

local Depth = 0
local Shown
local INDENT

local NormalIds = Enum.NormalId:GetEnumItems()

local function IntegerOrFloat(Number)
	Number = tonumber(Number)
	return Number % 1 == 0 and string.format("%d", Number) or string.format("%.4f", Number)
end

local function DictionaryJoin(...)
	local New = {}
	for Index = 1, select("#", ...) do
		local Dictionary = select(Index, ...)
		if Dictionary then
			for Key, Value in next, Dictionary do
				New[Key] = Value
			end
		end
	end

	return New
end

local function Repr(Value, ReprSettings)
	ReprSettings = DictionaryJoin(DEFAULT_SETTINGS, ReprSettings)

	INDENT = string.rep(" ", ReprSettings.Spaces)
	if ReprSettings.Tabs then
		INDENT = "\t"
	end

	local NewValue = Value
	local Tabs = string.rep(INDENT, Depth)

	if Depth == 0 then
		Shown = {}
	end

	local TypeOf = typeof(Value)
	if TypeOf == "string" then
		return string.format("%q", NewValue)
	elseif TypeOf == "number" then
		if NewValue == math.huge then
			return "math.huge"
		end

		if NewValue == -math.huge then
			return "-math.huge"
		end

		return IntegerOrFloat(NewValue)
	elseif TypeOf == "boolean" then
		return tostring(NewValue)
	elseif TypeOf == "nil" then
		return "nil"
	elseif TypeOf == "table" then
		if Shown[NewValue] then
			return "{CYCLIC}"
		end

		Shown[NewValue] = true
		local String = "{" .. (ReprSettings.Pretty and ("\n" .. INDENT .. Tabs) or "")
		local IsArray = true
		for Key in next, NewValue do
			if type(Key) ~= "number" then
				IsArray = false
				break
			end
		end

		if IsArray then
			for Index, ArrayValue in ipairs(NewValue) do
				if Index ~= 1 then
					String ..= (ReprSettings.Semicolons and ";" or ",") .. (ReprSettings.Pretty and ("\n" .. INDENT .. Tabs) or " ")
				end

				Depth = Depth + 1
				String ..= Repr(ArrayValue, ReprSettings)
				Depth = Depth - 1
			end
		else
			local KeyOrder = {}
			local Length = 0
			local KeyValueStrings = {}
			for Key, DictionaryValue in next, NewValue do
				Depth += 1
				local KeyString = IsLuaIdentifier(Key) and Key or ("[" .. Repr(Key, ReprSettings) .. "]")
				local ValueString = Repr(DictionaryValue, ReprSettings)

				Length += 1
				KeyOrder[Length] = KeyString

				KeyValueStrings[KeyString] = ValueString
				Depth -= 1
			end

			if ReprSettings.SortKeys then
				table.sort(KeyOrder)
			end

			local First = true
			for _, KeyString in ipairs(KeyOrder) do
				if not First then
					String ..= (ReprSettings.Semicolons and ";" or ",") .. (ReprSettings.Pretty and ("\n" .. INDENT .. Tabs) or " ")
				end

				String ..= string.format("%s = %s", KeyString, KeyValueStrings[KeyString])
				First = false
			end
		end

		Shown[NewValue] = false
		if ReprSettings.Pretty then
			String ..= "\n" .. Tabs
		end

		return String .. "}"
	elseif TypeOf == "table" and type(NewValue.__tostring) == "function" then
		return tostring(NewValue.__tostring(NewValue))
	elseif TypeOf == "table" and getmetatable(NewValue) and type(getmetatable(NewValue).__tostring) == "function" then
		return tostring(getmetatable(NewValue).__tostring(NewValue))
	elseif typeof then
		if TypeOf == "Instance" then
			return ((ReprSettings.RobloxFullName and (ReprSettings.RobloxProperFullName and ProperFullName(NewValue) or NewValue:GetFullName()) or NewValue.Name) .. (ReprSettings.RobloxClassName and (string.format(" (%s)", NewValue.ClassName)) or ""))
		elseif TypeOf == "Axes" then
			local Array = {}
			local Length = 0
			if NewValue.X then
				Length += 1
				Array[Length] = Repr(Enum.Axis.X, ReprSettings)
			end

			if NewValue.Y then
				Length += 1
				Array[Length] = Repr(Enum.Axis.Y, ReprSettings)
			end

			if NewValue.Z then
				Length += 1
				Array[Length] = Repr(Enum.Axis.Z, ReprSettings)
			end

			return string.format("Axes.new(%s)", table.concat(Array, ", "))
		elseif TypeOf == "BrickColor" then
			return string.format("BrickColor.new(%q)", NewValue.Name)
		elseif TypeOf == "CFrame" then
			return string.format("CFrame.new(%s)", table.concat({NewValue:GetComponents()}, ", "))
		elseif TypeOf == "Color3" then
			return string.format("Color3.fromRGB(%d, %d, %d)", NewValue.R * 255, NewValue.G * 255, NewValue.B * 255)
		elseif TypeOf == "ColorSequence" then
			if #NewValue.Keypoints > 2 then
				return string.format("ColorSequence.new(%s)", Repr(NewValue.Keypoints, ReprSettings))
			else
				if NewValue.Keypoints[1].Value == NewValue.Keypoints[2].Value then
					return string.format("ColorSequence.new(%s)", Repr(NewValue.Keypoints[1].Value, ReprSettings))
				else
					return string.format(
						"ColorSequence.new(%s, %s)",
						Repr(NewValue.Keypoints[1].Value, ReprSettings),
						Repr(NewValue.Keypoints[2].Value, ReprSettings)
					)
				end
			end
		elseif TypeOf == "ColorSequenceKeypoint" then
			return string.format("ColorSequenceKeypoint.new(%s, %s)", IntegerOrFloat(NewValue.Time), Repr(NewValue.Value, ReprSettings))
		elseif TypeOf == "DockWidgetPluginGuiInfo" then
			return string.format(
				"DockWidgetPluginGuiInfo.new(%s, %s, %s, %s, %s, %s, %s)",
				Repr(NewValue.InitialDockState, ReprSettings),
				Repr(NewValue.InitialEnabled, ReprSettings),
				Repr(NewValue.InitialEnabledShouldOverrideRestore, ReprSettings),
				Repr(NewValue.FloatingXSize, ReprSettings),
				Repr(NewValue.FloatingYSize, ReprSettings),
				Repr(NewValue.MinWidth, ReprSettings),
				Repr(NewValue.MinHeight, ReprSettings)
			)
		elseif TypeOf == "Enums" then
			return "Enums"
		elseif TypeOf == "Enum" then
			return string.format("Enum.%s", tostring(NewValue))
		elseif TypeOf == "EnumItem" then
			return string.format("Enum.%s.%s", tostring(NewValue.EnumType), NewValue.Name)
		elseif TypeOf == "Faces" then
			local Array = {}
			local Length = 0
			for _, EnumItem in ipairs(NormalIds) do
				if NewValue[EnumItem.Name] then
					Length += 1
					Array[Length] = Repr(EnumItem, ReprSettings)
				end
			end

			return string.format("Faces.new(%s)", table.concat(Array, ", "))
		elseif TypeOf == "NumberRange" then
			if NewValue.Min == NewValue.Max then
				return string.format("NumberRange.new(%s)", IntegerOrFloat(NewValue.Min))
			else
				return string.format("NumberRange.new(%s, %s)", IntegerOrFloat(NewValue.Min), IntegerOrFloat(NewValue.Max))
			end
		elseif TypeOf == "NumberSequence" then
			if #NewValue.Keypoints > 2 then
				return string.format("NumberSequence.new(%s)", Repr(NewValue.Keypoints, ReprSettings))
			else
				if NewValue.Keypoints[1].Value == NewValue.Keypoints[2].Value then
					return string.format("NumberSequence.new(%s)", IntegerOrFloat(NewValue.Keypoints[1].Value))
				else
					return string.format("NumberSequence.new(%s, %s)", IntegerOrFloat(NewValue.Keypoints[1].Value), IntegerOrFloat(NewValue.Keypoints[2].Value))
				end
			end
		elseif TypeOf == "NumberSequenceKeypoint" then
			if NewValue.Envelope ~= 0 then
				return string.format("NumberSequenceKeypoint.new(%s, %s, %s)", IntegerOrFloat(NewValue.Time), IntegerOrFloat(NewValue.Value), IntegerOrFloat(NewValue.Envelope))
			else
				return string.format("NumberSequenceKeypoint.new(%s, %s)", IntegerOrFloat(NewValue.Time), IntegerOrFloat(NewValue.Value))
			end
		elseif TypeOf == "PathWaypoint" then
			return string.format(
				"PathWaypoint.new(%s, %s)",
				Repr(NewValue.Position, ReprSettings),
				Repr(NewValue.Action, ReprSettings)
			)
		elseif TypeOf == "PhysicalProperties" then
			return string.format(
				"PhysicalProperties.new(%s, %s, %s, %s)",
				IntegerOrFloat(NewValue.Density), IntegerOrFloat(NewValue.Friction), IntegerOrFloat(NewValue.Elasticity), IntegerOrFloat(NewValue.FrictionWeight), IntegerOrFloat(NewValue.ElasticityWeight)
			)
		elseif TypeOf == "Random" then
			return "<Random>"
		elseif TypeOf == "Ray" then
			return string.format(
				"Ray.new(%s, %s)",
				Repr(NewValue.Origin, ReprSettings),
				Repr(NewValue.Direction, ReprSettings)
			)
		elseif TypeOf == "RaycastParams" then
			return string.format(
				"RaycastParams.new({\n\tFilterDescendantsInstances = %s;\n\tFilterType = %s;\n\tIgnoreWater = %s;\n})",
				Repr(NewValue.FilterDescendantsInstances, ReprSettings),
				Repr(NewValue.FilterType, ReprSettings),
				Repr(NewValue.IgnoreWater, ReprSettings)
			)
		elseif TypeOf == "RaycastResult" then
			return string.format(
				"RaycastResult({\n\tInstance = %s;\n\tPosition = %s;\n\tNormal = %s;\n\tMaterial = %s;\n})",
				Repr(NewValue.Instance, ReprSettings),
				Repr(NewValue.Position, ReprSettings),
				Repr(NewValue.Normal, ReprSettings),
				Repr(NewValue.Material, ReprSettings)
			)
		elseif TypeOf == "RBXScriptConnection" then
			return "<RBXScriptConnection>"
		elseif TypeOf == "RBXScriptSignal" then
			return "<RBXScriptSignal>"
		elseif TypeOf == "Rect" then
			return string.format("Rect.new(%s, %s, %s, %s)", IntegerOrFloat(NewValue.Min.X), IntegerOrFloat(NewValue.Min.Y), IntegerOrFloat(NewValue.Max.X), IntegerOrFloat(NewValue.Max.Y))
		elseif TypeOf == "Region3" then
			local min = NewValue.CFrame.Position + NewValue.Size / -2
			local max = NewValue.CFrame.Position + NewValue.Size / 2
			return string.format("Region3.new(%s, %s)", Repr(min, ReprSettings), Repr(max, ReprSettings))
		elseif TypeOf == "Region3int16" then
			return string.format(
				"Region3int16.new(%s, %s)",
				Repr(NewValue.Min, ReprSettings),
				Repr(NewValue.Max, ReprSettings)
			)
		elseif TypeOf == "TweenInfo" then
			return string.format(
				"TweenInfo.new(%s, %s, %s, %s, %s, %s)",
				IntegerOrFloat(NewValue.Time),
				Repr(NewValue.EasingStyle, ReprSettings),
				Repr(NewValue.EasingDirection, ReprSettings),
				IntegerOrFloat(NewValue.RepeatCount),
				Repr(NewValue.Reverses, ReprSettings),
				IntegerOrFloat(NewValue.DelayTime)
			)
		elseif TypeOf == "UDim" then
			return string.format("UDim.new(%s, %s)", IntegerOrFloat(NewValue.Scale), IntegerOrFloat(NewValue.Offset))
		elseif TypeOf == "UDim2" then
			return string.format("UDim2.new(%s, %s, %s, %s)", IntegerOrFloat(NewValue.X.Scale), IntegerOrFloat(NewValue.X.Offset), IntegerOrFloat(NewValue.Y.Scale), IntegerOrFloat(NewValue.Y.Offset))
		elseif TypeOf == "Vector2" then
			return string.format("Vector2.new(%s, %s)", IntegerOrFloat(NewValue.X), IntegerOrFloat(NewValue.Y))
		elseif TypeOf == "Vector2int16" then
			return string.format("Vector2int16.new(%s, %s)", IntegerOrFloat(NewValue.X), IntegerOrFloat(NewValue.Y))
		elseif TypeOf == "Vector3" then
			return string.format("Vector3.new(%s, %s, %s)", IntegerOrFloat(NewValue.X), IntegerOrFloat(NewValue.Y), IntegerOrFloat(NewValue.Z))
		elseif TypeOf == "Vector3int16" then
			return string.format("Vector3int16.new(%s, %s, %s)", IntegerOrFloat(NewValue.X), IntegerOrFloat(NewValue.Y), IntegerOrFloat(NewValue.Z))
		else
			return "<Roblox:" .. TypeOf .. ">"
		end
	else
		return "<" .. TypeOf .. ">"
	end
end

return Repr