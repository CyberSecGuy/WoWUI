if (AAP.Faction == "Horde") then
AAP.QuestStepList2060 = {
--- Tirisfal Glades ----
	["18-100-110"] = {
		{
			["Trigger"] = {
				["y"] = 2021.9,
				["x"] = 305.2,
			},
			["CRange"] = 43926,
			["Range"] = 0.75,
			["TT"] = {
				["y"] = 2070.4,
				["x"] = 289.3,
			},
			["ExtraLine"] = 59,
		}, -- [6]
		{
			["Done"] = {
				43926, -- [1]
			},
			["TT"] = {
				["y"] = 2070.1,
				["x"] = 289,
			},
			["ExtraLine"] = 59,
		}, -- [7]

	},
---- Orgrimmar ----
	["1-100to110"] = {
		{
			["Done"] = {
				43926, -- [1]
			},
			["TT"] = {
				["y"] = 1322.7,
				["x"] = -4395.3,
			},
		}, -- [1]
		{
			["PickUp"] = {
				43926, -- [1]
			},
			["TT"] = {
				["y"] = 1323,
				["x"] = -4393.9,
			},
		}, -- [1]
		{
			["Qpart"] = {
				[43926] = {
					["1"] = "1",
				},
			},
			["Gossip"] = 1,
			["Trigger"] = {
				["y"] = 1323,
				["x"] = -4393.9,
			},
			["Range"] = 0.75,
			["TT"] = {
				["y"] = 1323,
				["x"] = -4393.9,
			},
		}, -- [2]
	}, -- [1]
------------------------------------------------------
}
for AAP_index,AAP_value in pairs(AAP.QuestStepList2060) do
	AAP.QuestStepList[AAP_index] = AAP_value
end
AAP.QuestStepList2060 = nil
end