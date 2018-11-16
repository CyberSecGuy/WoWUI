
WeakAurasSaved = {
	["dynamicIconCache"] = {
		["Lightning Shield"] = {
			[192106] = 136051,
		},
		["Cold Blood"] = {
			[213981] = 135988,
		},
		["Earth Shield"] = {
			[974] = 136089,
		},
		["Stealth"] = {
			[1784] = 132320,
		},
	},
	["minimap"] = {
		["minimapPos"] = 14.3204276875232,
		["hide"] = false,
	},
	["login_squelch_time"] = 10,
	["registered"] = {
	},
	["displays"] = {
		["#5 - Arcane Blast"] = {
			["text2Point"] = "CENTER",
			["text1FontSize"] = 36,
			["parent"] = "Mage Helper - Opener",
			["yOffset"] = 0,
			["anchorPoint"] = "CENTER",
			["customTextUpdate"] = "update",
			["actions"] = {
				["start"] = {
				},
				["init"] = {
				},
				["finish"] = {
				},
			},
			["triggers"] = {
				{
					["trigger"] = {
						["duration"] = "1",
						["genericShowOn"] = "showOnReady",
						["unit"] = "player",
						["powertype"] = 0,
						["use_absorbMode"] = true,
						["names"] = {
						},
						["spellName"] = 12051,
						["use_powertype"] = true,
						["debuffType"] = "HELPFUL",
						["use_genericShowOn"] = true,
						["type"] = "status",
						["unevent"] = "auto",
						["useExactSpellId"] = true,
						["power_operator"] = ">=",
						["matchesShowOn"] = "showOnActive",
						["event"] = "Cooldown Progress (Spell)",
						["auraspellids"] = {
							"116014", -- [1]
						},
						["realSpellName"] = "Evocation",
						["use_spellName"] = true,
						["spellIds"] = {
						},
						["power"] = "2751",
						["subeventSuffix"] = "_CAST_START",
						["subeventPrefix"] = "SPELL",
						["use_power"] = false,
						["use_unit"] = true,
					},
					["untrigger"] = {
						["genericShowOn"] = "showOnReady",
					},
				}, -- [1]
				{
					["trigger"] = {
						["use_genericShowOn"] = true,
						["genericShowOn"] = "showOnReady",
						["use_unit"] = true,
						["debuffType"] = "HELPFUL",
						["type"] = "aura2",
						["use_absorbMode"] = true,
						["subeventSuffix"] = "_CAST_START",
						["unit"] = "player",
						["duration"] = "1",
						["event"] = "Cooldown Progress (Spell)",
						["spellName"] = 205025,
						["realSpellName"] = "Presence of Mind",
						["use_spellName"] = true,
						["useExactSpellId"] = true,
						["matchesShowOn"] = "showOnMissing",
						["subeventPrefix"] = "SPELL",
						["unevent"] = "auto",
						["auraspellids"] = {
							"263725", -- [1]
						},
						["ownOnly"] = true,
					},
					["untrigger"] = {
						["genericShowOn"] = "showOnReady",
					},
				}, -- [2]
				{
					["trigger"] = {
						["type"] = "status",
						["unevent"] = "auto",
						["duration"] = "1",
						["event"] = "Action Usable",
						["subeventPrefix"] = "SPELL",
						["realSpellName"] = "Arcane Blast",
						["use_spellName"] = true,
						["subeventSuffix"] = "_CAST_START",
						["unit"] = "player",
						["use_unit"] = true,
						["use_absorbMode"] = true,
						["spellName"] = 30451,
					},
					["untrigger"] = {
					},
				}, -- [3]
				["activeTriggerMode"] = 1,
			},
			["internalVersion"] = 9,
			["keepAspectRatio"] = false,
			["animation"] = {
				["start"] = {
					["type"] = "none",
					["duration_type"] = "seconds",
				},
				["main"] = {
					["type"] = "none",
					["duration_type"] = "seconds",
				},
				["finish"] = {
					["type"] = "none",
					["duration_type"] = "seconds",
				},
			},
			["desaturate"] = false,
			["glowColor"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["text1Point"] = "CENTER",
			["text2FontFlags"] = "OUTLINE",
			["height"] = 64,
			["anchorFrameType"] = "SCREEN",
			["load"] = {
				["talent2"] = {
					["single"] = 9,
				},
				["use_level"] = true,
				["talent"] = {
					["single"] = 11,
				},
				["use_size"] = false,
				["level_operator"] = "==",
				["spec"] = {
					["single"] = 1,
					["multi"] = {
					},
				},
				["use_talent"] = true,
				["use_class"] = true,
				["use_combat"] = true,
				["use_talent2"] = true,
				["use_spec"] = true,
				["use_name"] = false,
				["level"] = "120",
				["class"] = {
					["single"] = "MAGE",
					["multi"] = {
					},
				},
				["size"] = {
					["multi"] = {
						["party"] = true,
						["scenario"] = true,
						["flexible"] = true,
						["ten"] = true,
						["twentyfive"] = true,
						["twenty"] = true,
						["fortyman"] = true,
					},
				},
			},
			["text1Containment"] = "INSIDE",
			["useglowColor"] = false,
			["text1Enabled"] = true,
			["text2Containment"] = "INSIDE",
			["glowType"] = "buttonOverlay",
			["text1Color"] = {
				1, -- [1]
				0, -- [2]
				0, -- [3]
				1, -- [4]
			},
			["displayIcon"] = 135735,
			["text1FontFlags"] = "OUTLINE",
			["text2Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["regionType"] = "icon",
			["selfPoint"] = "CENTER",
			["text1Font"] = "Friz Quadrata TT",
			["text2FontSize"] = 24,
			["text2Enabled"] = false,
			["text1"] = "2",
			["alpha"] = 1,
			["zoom"] = 0,
			["text2"] = "%p",
			["auto"] = false,
			["stickyDuration"] = false,
			["id"] = "#5 - Arcane Blast",
			["glow"] = true,
			["frameStrata"] = 1,
			["width"] = 64,
			["icon"] = true,
			["text2Font"] = "Friz Quadrata TT",
			["inverse"] = false,
			["xOffset"] = 0,
			["conditions"] = {
			},
			["color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["cooldownTextEnabled"] = true,
		},
		["#3 - Arcane Power"] = {
			["text2Point"] = "CENTER",
			["text1FontSize"] = 36,
			["cooldownTextEnabled"] = true,
			["yOffset"] = 0,
			["anchorPoint"] = "CENTER",
			["customTextUpdate"] = "update",
			["actions"] = {
				["start"] = {
				},
				["init"] = {
				},
				["finish"] = {
				},
			},
			["useglowColor"] = false,
			["text1Enabled"] = true,
			["keepAspectRatio"] = false,
			["animation"] = {
				["start"] = {
					["type"] = "none",
					["duration_type"] = "seconds",
				},
				["main"] = {
					["type"] = "none",
					["duration_type"] = "seconds",
				},
				["finish"] = {
					["type"] = "none",
					["duration_type"] = "seconds",
				},
			},
			["desaturate"] = false,
			["glowColor"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["text1Point"] = "CENTER",
			["text2FontFlags"] = "OUTLINE",
			["height"] = 64,
			["anchorFrameType"] = "SCREEN",
			["load"] = {
				["talent2"] = {
					["single"] = 9,
				},
				["use_level"] = true,
				["talent"] = {
					["single"] = 11,
				},
				["use_size"] = false,
				["class"] = {
					["single"] = "MAGE",
					["multi"] = {
					},
				},
				["spec"] = {
					["single"] = 1,
					["multi"] = {
					},
				},
				["use_talent"] = true,
				["use_class"] = true,
				["use_combat"] = false,
				["use_talent2"] = true,
				["use_spec"] = true,
				["use_name"] = false,
				["level"] = "120",
				["level_operator"] = "==",
				["size"] = {
					["multi"] = {
						["party"] = true,
						["scenario"] = true,
						["flexible"] = true,
						["ten"] = true,
						["twentyfive"] = true,
						["twenty"] = true,
						["fortyman"] = true,
					},
				},
			},
			["text1Color"] = {
				1, -- [1]
				0, -- [2]
				0, -- [3]
				1, -- [4]
			},
			["color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["text1Containment"] = "INSIDE",
			["text2Containment"] = "INSIDE",
			["glowType"] = "buttonOverlay",
			["text1Font"] = "Friz Quadrata TT",
			["conditions"] = {
			},
			["triggers"] = {
				{
					["trigger"] = {
						["use_genericShowOn"] = true,
						["genericShowOn"] = "showOnReady",
						["use_unit"] = true,
						["debuffType"] = "HELPFUL",
						["spellName"] = 12051,
						["type"] = "status",
						["unit"] = "player",
						["auraspellids"] = {
							"116014", -- [1]
						},
						["duration"] = "1",
						["use_absorbMode"] = true,
						["event"] = "Cooldown Progress (Spell)",
						["useExactSpellId"] = true,
						["realSpellName"] = "Evocation",
						["use_spellName"] = true,
						["spellIds"] = {
						},
						["matchesShowOn"] = "showOnActive",
						["subeventPrefix"] = "SPELL",
						["unevent"] = "auto",
						["subeventSuffix"] = "_CAST_START",
						["names"] = {
						},
					},
					["untrigger"] = {
						["genericShowOn"] = "showOnReady",
					},
				}, -- [1]
				{
					["trigger"] = {
						["duration"] = "1",
						["genericShowOn"] = "showOnReady",
						["unit"] = "player",
						["debuffType"] = "HELPFUL",
						["type"] = "aura2",
						["useExactSpellId"] = true,
						["subeventSuffix"] = "_CAST_START",
						["unevent"] = "auto",
						["event"] = "Cooldown Progress (Spell)",
						["subeventPrefix"] = "SPELL",
						["realSpellName"] = "Evocation",
						["use_spellName"] = true,
						["matchesShowOn"] = "showOnActive",
						["spellName"] = 12051,
						["auraspellids"] = {
							"116014", -- [1]
						},
						["use_absorbMode"] = true,
						["use_unit"] = true,
						["use_genericShowOn"] = true,
					},
					["untrigger"] = {
						["genericShowOn"] = "showOnReady",
					},
				}, -- [2]
				{
					["trigger"] = {
						["type"] = "status",
						["unevent"] = "auto",
						["event"] = "Cooldown Progress (Spell)",
						["duration"] = "1",
						["genericShowOn"] = "showOnReady",
						["subeventPrefix"] = "SPELL",
						["realSpellName"] = "Arcane Power",
						["use_spellName"] = true,
						["unit"] = "player",
						["use_unit"] = true,
						["use_absorbMode"] = true,
						["subeventSuffix"] = "_CAST_START",
						["use_genericShowOn"] = true,
						["spellName"] = 12042,
					},
					["untrigger"] = {
						["genericShowOn"] = "showOnReady",
					},
				}, -- [3]
				["activeTriggerMode"] = 2,
			},
			["text2Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["regionType"] = "icon",
			["text2Font"] = "Friz Quadrata TT",
			["text1FontFlags"] = "OUTLINE",
			["text2FontSize"] = 24,
			["stickyDuration"] = false,
			["text1"] = "Q",
			["text2Enabled"] = false,
			["zoom"] = 0,
			["text2"] = "%p",
			["auto"] = false,
			["alpha"] = 1,
			["id"] = "#3 - Arcane Power",
			["glow"] = true,
			["frameStrata"] = 1,
			["width"] = 64,
			["selfPoint"] = "CENTER",
			["icon"] = true,
			["inverse"] = false,
			["internalVersion"] = 9,
			["displayIcon"] = 136048,
			["xOffset"] = 0,
			["parent"] = "Mage Helper - Opener",
		},
		["Enhance Shaman"] = {
			["grow"] = "RIGHT",
			["controlledChildren"] = {
				"Lightning Shield", -- [1]
				"Lightning Shield - Missing", -- [2]
				"Earth Shield", -- [3]
				"Earth Shield 2", -- [4]
				"Flametounge", -- [5]
			},
			["animate"] = false,
			["scale"] = 1,
			["radius"] = 200,
			["border"] = "None",
			["yOffset"] = -365.000289916992,
			["regionType"] = "dynamicgroup",
			["xOffset"] = -150.832580566406,
			["sort"] = "none",
			["actions"] = {
				["start"] = {
				},
				["finish"] = {
				},
				["init"] = {
				},
			},
			["space"] = 2,
			["background"] = "None",
			["expanded"] = false,
			["triggers"] = {
				{
					["trigger"] = {
						["debuffType"] = "HELPFUL",
						["type"] = "aura",
						["spellIds"] = {
						},
						["subeventSuffix"] = "_CAST_START",
						["unit"] = "player",
						["subeventPrefix"] = "SPELL",
						["event"] = "Health",
						["names"] = {
						},
					},
					["untrigger"] = {
					},
				}, -- [1]
				["activeTriggerMode"] = -10,
			},
			["borderOffset"] = 16,
			["backgroundInset"] = 0,
			["id"] = "Enhance Shaman",
			["selfPoint"] = "LEFT",
			["align"] = "CENTER",
			["constantFactor"] = "RADIUS",
			["frameStrata"] = 1,
			["anchorFrameType"] = "SCREEN",
			["rotation"] = 0,
			["internalVersion"] = 9,
			["stagger"] = 0,
			["animation"] = {
				["start"] = {
					["duration_type"] = "seconds",
					["type"] = "none",
				},
				["main"] = {
					["duration_type"] = "seconds",
					["type"] = "none",
				},
				["finish"] = {
					["duration_type"] = "seconds",
					["type"] = "none",
				},
			},
			["conditions"] = {
			},
			["load"] = {
				["use_class"] = "true",
				["spec"] = {
					["multi"] = {
					},
				},
				["class"] = {
					["single"] = "SHAMAN",
					["multi"] = {
					},
				},
				["size"] = {
					["multi"] = {
					},
				},
			},
			["anchorPoint"] = "CENTER",
		},
		["Mage Helper - Opener"] = {
			["grow"] = "RIGHT",
			["controlledChildren"] = {
				"#0 - Arcane Intellect", -- [1]
				"#1 - Charged Up", -- [2]
				"#2 - Rune of Power", -- [3]
				"#3 - Arcane Power", -- [4]
				"#4 - Presence of Mind", -- [5]
				"#5 - Arcane Blast", -- [6]
				"#6 - Arcane Missiles", -- [7]
				"#7 - Arcane Barrage", -- [8]
				"#8 - Evocate", -- [9]
				"#9 - Rune of Power", -- [10]
			},
			["animate"] = false,
			["scale"] = 1,
			["borderOffset"] = 16,
			["border"] = "None",
			["yOffset"] = -188.33251953125,
			["regionType"] = "dynamicgroup",
			["anchorPoint"] = "CENTER",
			["sort"] = "none",
			["actions"] = {
				["start"] = {
				},
				["finish"] = {
				},
				["init"] = {
				},
			},
			["space"] = 2,
			["background"] = "None",
			["expanded"] = false,
			["triggers"] = {
				{
					["trigger"] = {
						["debuffType"] = "HELPFUL",
						["type"] = "aura2",
						["spellIds"] = {
						},
						["subeventSuffix"] = "_CAST_START",
						["unit"] = "player",
						["subeventPrefix"] = "SPELL",
						["event"] = "Health",
						["names"] = {
						},
					},
					["untrigger"] = {
					},
				}, -- [1]
			},
			["radius"] = 200,
			["backgroundInset"] = 0,
			["id"] = "Mage Helper - Opener",
			["selfPoint"] = "LEFT",
			["align"] = "CENTER",
			["internalVersion"] = 9,
			["frameStrata"] = 1,
			["anchorFrameType"] = "SCREEN",
			["stagger"] = 0,
			["constantFactor"] = "RADIUS",
			["rotation"] = 0,
			["animation"] = {
				["start"] = {
					["duration_type"] = "seconds",
					["type"] = "none",
				},
				["main"] = {
					["duration_type"] = "seconds",
					["type"] = "none",
				},
				["finish"] = {
					["duration_type"] = "seconds",
					["type"] = "none",
				},
			},
			["conditions"] = {
			},
			["load"] = {
				["use_class"] = "true",
				["spec"] = {
					["multi"] = {
					},
				},
				["class"] = {
					["single"] = "MAGE",
					["multi"] = {
					},
				},
				["size"] = {
					["multi"] = {
					},
				},
			},
			["xOffset"] = -31.6666259765625,
		},
		["#7 - Arcane Barrage"] = {
			["text2Point"] = "CENTER",
			["text1FontSize"] = 36,
			["xOffset"] = 0,
			["yOffset"] = 0,
			["anchorPoint"] = "CENTER",
			["customTextUpdate"] = "update",
			["actions"] = {
				["start"] = {
				},
				["init"] = {
				},
				["finish"] = {
				},
			},
			["useglowColor"] = false,
			["text1Enabled"] = true,
			["keepAspectRatio"] = false,
			["animation"] = {
				["start"] = {
					["type"] = "none",
					["duration_type"] = "seconds",
				},
				["main"] = {
					["type"] = "none",
					["duration_type"] = "seconds",
				},
				["finish"] = {
					["type"] = "none",
					["duration_type"] = "seconds",
				},
			},
			["text1Containment"] = "INSIDE",
			["glowColor"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["text1Point"] = "CENTER",
			["text2FontFlags"] = "OUTLINE",
			["height"] = 64,
			["anchorFrameType"] = "SCREEN",
			["load"] = {
				["talent2"] = {
					["single"] = 9,
				},
				["use_level"] = true,
				["talent"] = {
					["single"] = 11,
				},
				["use_size"] = false,
				["level_operator"] = "==",
				["spec"] = {
					["single"] = 1,
					["multi"] = {
					},
				},
				["use_talent"] = true,
				["use_name"] = false,
				["use_combat"] = true,
				["use_talent2"] = true,
				["use_spec"] = true,
				["use_class"] = true,
				["level"] = "120",
				["class"] = {
					["single"] = "MAGE",
					["multi"] = {
					},
				},
				["size"] = {
					["multi"] = {
						["party"] = true,
						["scenario"] = true,
						["flexible"] = true,
						["ten"] = true,
						["twentyfive"] = true,
						["twenty"] = true,
						["fortyman"] = true,
					},
				},
			},
			["desaturate"] = false,
			["triggers"] = {
				{
					["trigger"] = {
						["use_absorbMode"] = true,
						["genericShowOn"] = "showOnReady",
						["names"] = {
						},
						["powertype"] = 0,
						["use_inverse"] = true,
						["use_genericShowOn"] = true,
						["use_unit"] = true,
						["debuffType"] = "HELPFUL",
						["use_powertype"] = true,
						["spellName"] = 12051,
						["use_power"] = false,
						["type"] = "status",
						["subeventSuffix"] = "_CAST_START",
						["unevent"] = "auto",
						["power_operator"] = ">=",
						["matchesShowOn"] = "showOnActive",
						["event"] = "Cooldown Progress (Spell)",
						["auraspellids"] = {
							"116014", -- [1]
						},
						["realSpellName"] = "Evocation",
						["use_spellName"] = true,
						["spellIds"] = {
						},
						["power"] = "2751",
						["useExactSpellId"] = true,
						["duration"] = "1",
						["unit"] = "player",
						["subeventPrefix"] = "SPELL",
					},
					["untrigger"] = {
						["genericShowOn"] = "showOnReady",
					},
				}, -- [1]
				{
					["trigger"] = {
						["type"] = "status",
						["power"] = "4",
						["power_operator"] = ">=",
						["duration"] = "1",
						["event"] = "Power",
						["subeventPrefix"] = "SPELL",
						["subeventSuffix"] = "_CAST_START",
						["powertype"] = 16,
						["use_power"] = true,
						["use_unit"] = true,
						["use_absorbMode"] = true,
						["unit"] = "player",
						["use_powertype"] = true,
						["unevent"] = "auto",
					},
					["untrigger"] = {
					},
				}, -- [2]
				{
					["trigger"] = {
						["type"] = "status",
						["unevent"] = "auto",
						["duration"] = "1",
						["event"] = "Action Usable",
						["subeventPrefix"] = "SPELL",
						["realSpellName"] = "Arcane Blast",
						["use_spellName"] = true,
						["use_inverse"] = true,
						["unit"] = "player",
						["use_unit"] = true,
						["use_absorbMode"] = true,
						["subeventSuffix"] = "_CAST_START",
						["spellName"] = 30451,
					},
					["untrigger"] = {
					},
				}, -- [3]
				["activeTriggerMode"] = 1,
			},
			["parent"] = "Mage Helper - Opener",
			["text2Containment"] = "INSIDE",
			["glowType"] = "buttonOverlay",
			["text1Color"] = {
				1, -- [1]
				0, -- [2]
				0, -- [3]
				1, -- [4]
			},
			["displayIcon"] = 236205,
			["icon"] = true,
			["text2Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["regionType"] = "icon",
			["text2Font"] = "Friz Quadrata TT",
			["text1FontFlags"] = "OUTLINE",
			["text2FontSize"] = 24,
			["text2Enabled"] = false,
			["text1"] = "1",
			["alpha"] = 1,
			["zoom"] = 0,
			["text2"] = "%p",
			["auto"] = false,
			["stickyDuration"] = false,
			["id"] = "#7 - Arcane Barrage",
			["glow"] = true,
			["frameStrata"] = 1,
			["width"] = 64,
			["selfPoint"] = "CENTER",
			["text1Font"] = "Friz Quadrata TT",
			["inverse"] = false,
			["color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["conditions"] = {
			},
			["internalVersion"] = 9,
			["cooldownTextEnabled"] = true,
		},
		["Earth Shield 2"] = {
			["text2Point"] = "CENTER",
			["text1FontSize"] = 12,
			["color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["yOffset"] = 0,
			["anchorPoint"] = "CENTER",
			["customTextUpdate"] = "update",
			["icon"] = true,
			["useglowColor"] = false,
			["text2Font"] = "Friz Quadrata TT",
			["keepAspectRatio"] = false,
			["selfPoint"] = "CENTER",
			["desaturate"] = true,
			["glowColor"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["text1Point"] = "CENTER",
			["text2FontFlags"] = "OUTLINE",
			["height"] = 60,
			["load"] = {
				["use_class"] = true,
				["spec"] = {
					["multi"] = {
					},
				},
				["class"] = {
					["single"] = "SHAMAN",
					["multi"] = {
					},
				},
				["size"] = {
					["multi"] = {
					},
				},
			},
			["text1Containment"] = "INSIDE",
			["animation"] = {
				["start"] = {
					["duration_type"] = "seconds",
					["type"] = "none",
				},
				["main"] = {
					["duration_type"] = "seconds",
					["type"] = "none",
				},
				["finish"] = {
					["duration_type"] = "seconds",
					["type"] = "none",
				},
			},
			["cooldownTextEnabled"] = true,
			["text2Containment"] = "INSIDE",
			["glowType"] = "buttonOverlay",
			["text1Font"] = "Friz Quadrata TT",
			["parent"] = "Enhance Shaman",
			["text1Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["text2Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["regionType"] = "icon",
			["text1Enabled"] = true,
			["xOffset"] = 0,
			["text2FontSize"] = 24,
			["stickyDuration"] = false,
			["text1"] = "%s",
			["width"] = 60,
			["alpha"] = 1,
			["zoom"] = 0,
			["auto"] = true,
			["text2Enabled"] = false,
			["id"] = "Earth Shield 2",
			["text2"] = "%p",
			["frameStrata"] = 1,
			["anchorFrameType"] = "SCREEN",
			["internalVersion"] = 9,
			["text1FontFlags"] = "OUTLINE",
			["inverse"] = false,
			["triggers"] = {
				{
					["trigger"] = {
						["type"] = "aura",
						["subeventSuffix"] = "_CAST_START",
						["ownOnly"] = true,
						["event"] = "Health",
						["subeventPrefix"] = "SPELL",
						["spellIds"] = {
							974, -- [1]
						},
						["debuffType"] = "HELPFUL",
						["unit"] = "player",
						["names"] = {
							"Earth Shield", -- [1]
						},
						["buffShowOn"] = "showOnMissing",
					},
					["untrigger"] = {
					},
				}, -- [1]
				["activeTriggerMode"] = -10,
			},
			["conditions"] = {
			},
			["actions"] = {
				["start"] = {
				},
				["finish"] = {
				},
				["init"] = {
				},
			},
			["glow"] = false,
		},
		["#4 - Presence of Mind"] = {
			["text2Point"] = "CENTER",
			["text1FontSize"] = 36,
			["cooldownTextEnabled"] = true,
			["yOffset"] = 0,
			["anchorPoint"] = "CENTER",
			["customTextUpdate"] = "update",
			["actions"] = {
				["start"] = {
				},
				["finish"] = {
				},
				["init"] = {
				},
			},
			["useglowColor"] = false,
			["internalVersion"] = 9,
			["keepAspectRatio"] = false,
			["animation"] = {
				["start"] = {
					["duration_type"] = "seconds",
					["type"] = "none",
				},
				["main"] = {
					["duration_type"] = "seconds",
					["type"] = "none",
				},
				["finish"] = {
					["duration_type"] = "seconds",
					["type"] = "none",
				},
			},
			["desaturate"] = false,
			["glowColor"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["text1Point"] = "CENTER",
			["text2FontFlags"] = "OUTLINE",
			["height"] = 64,
			["width"] = 64,
			["load"] = {
				["talent2"] = {
					["single"] = 9,
				},
				["use_level"] = true,
				["talent"] = {
					["single"] = 11,
				},
				["use_size"] = false,
				["class"] = {
					["single"] = "MAGE",
					["multi"] = {
					},
				},
				["use_name"] = false,
				["use_talent"] = true,
				["use_class"] = true,
				["level"] = "120",
				["use_talent2"] = true,
				["use_spec"] = true,
				["spec"] = {
					["single"] = 1,
					["multi"] = {
					},
				},
				["use_combat"] = false,
				["level_operator"] = "==",
				["size"] = {
					["multi"] = {
						["party"] = true,
						["scenario"] = true,
						["flexible"] = true,
						["ten"] = true,
						["twentyfive"] = true,
						["twenty"] = true,
						["fortyman"] = true,
					},
				},
			},
			["xOffset"] = 0,
			["color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["parent"] = "Mage Helper - Opener",
			["text2Containment"] = "INSIDE",
			["glowType"] = "buttonOverlay",
			["text1Color"] = {
				1, -- [1]
				0, -- [2]
				0, -- [3]
				1, -- [4]
			},
			["conditions"] = {
			},
			["selfPoint"] = "CENTER",
			["text2Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["regionType"] = "icon",
			["text1Font"] = "Friz Quadrata TT",
			["icon"] = true,
			["text2FontSize"] = 24,
			["glow"] = true,
			["text1"] = "5",
			["frameStrata"] = 1,
			["text2"] = "%p",
			["zoom"] = 0,
			["auto"] = false,
			["stickyDuration"] = false,
			["id"] = "#4 - Presence of Mind",
			["alpha"] = 1,
			["text2Enabled"] = false,
			["anchorFrameType"] = "SCREEN",
			["text2Font"] = "Friz Quadrata TT",
			["text1FontFlags"] = "OUTLINE",
			["inverse"] = false,
			["text1Enabled"] = true,
			["displayIcon"] = 136031,
			["text1Containment"] = "INSIDE",
			["triggers"] = {
				{
					["trigger"] = {
						["use_genericShowOn"] = true,
						["genericShowOn"] = "showOnReady",
						["names"] = {
						},
						["debuffType"] = "HELPFUL",
						["subeventPrefix"] = "SPELL",
						["type"] = "status",
						["unevent"] = "auto",
						["subeventSuffix"] = "_CAST_START",
						["use_unit"] = true,
						["matchesShowOn"] = "showOnActive",
						["event"] = "Cooldown Progress (Spell)",
						["auraspellids"] = {
							"116014", -- [1]
						},
						["realSpellName"] = "Evocation",
						["use_spellName"] = true,
						["spellIds"] = {
						},
						["useExactSpellId"] = true,
						["use_absorbMode"] = true,
						["duration"] = "1",
						["unit"] = "player",
						["spellName"] = 12051,
					},
					["untrigger"] = {
						["genericShowOn"] = "showOnReady",
					},
				}, -- [1]
				{
					["trigger"] = {
						["subeventPrefix"] = "SPELL",
						["type"] = "aura2",
						["subeventSuffix"] = "_CAST_START",
						["auraspellids"] = {
							"12042", -- [1]
						},
						["unit"] = "player",
						["useExactSpellId"] = true,
						["event"] = "Health",
						["debuffType"] = "HELPFUL",
					},
					["untrigger"] = {
					},
				}, -- [2]
				{
					["trigger"] = {
						["duration"] = "1",
						["genericShowOn"] = "showOnReady",
						["unit"] = "player",
						["debuffType"] = "HELPFUL",
						["type"] = "status",
						["useExactSpellId"] = true,
						["auraspellids"] = {
							"12042", -- [1]
						},
						["unevent"] = "auto",
						["event"] = "Cooldown Progress (Spell)",
						["subeventPrefix"] = "SPELL",
						["realSpellName"] = "Presence of Mind",
						["use_spellName"] = true,
						["matchesShowOn"] = "showOnMissing",
						["spellName"] = 205025,
						["subeventSuffix"] = "_CAST_START",
						["use_absorbMode"] = true,
						["use_unit"] = true,
						["use_genericShowOn"] = true,
					},
					["untrigger"] = {
						["genericShowOn"] = "showOnReady",
					},
				}, -- [3]
				["activeTriggerMode"] = 1,
			},
		},
		["#1 - Charged Up"] = {
			["text2Point"] = "CENTER",
			["text1FontSize"] = 36,
			["color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["yOffset"] = 0,
			["anchorPoint"] = "CENTER",
			["customTextUpdate"] = "update",
			["icon"] = true,
			["useglowColor"] = false,
			["text1Enabled"] = true,
			["keepAspectRatio"] = false,
			["animation"] = {
				["start"] = {
					["duration_type"] = "seconds",
					["type"] = "none",
				},
				["main"] = {
					["duration_type"] = "seconds",
					["type"] = "none",
				},
				["finish"] = {
					["duration_type"] = "seconds",
					["type"] = "none",
				},
			},
			["desaturate"] = false,
			["glowColor"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["text1Point"] = "CENTER",
			["alpha"] = 1,
			["text2FontFlags"] = "OUTLINE",
			["height"] = 64,
			["internalVersion"] = 9,
			["load"] = {
				["talent2"] = {
					["single"] = 9,
				},
				["use_level"] = true,
				["talent"] = {
					["single"] = 11,
					["multi"] = {
						[9] = true,
						[11] = true,
					},
				},
				["use_size"] = false,
				["spec"] = {
					["single"] = 1,
					["multi"] = {
					},
				},
				["class"] = {
					["single"] = "MAGE",
					["multi"] = {
					},
				},
				["use_talent"] = true,
				["use_class"] = true,
				["level"] = "120",
				["use_talent2"] = true,
				["use_spec"] = true,
				["level_operator"] = "==",
				["use_combat"] = false,
				["use_name"] = false,
				["size"] = {
					["multi"] = {
						["party"] = true,
						["scenario"] = true,
						["flexible"] = true,
						["ten"] = true,
						["twentyfive"] = true,
						["twenty"] = true,
						["fortyman"] = true,
					},
				},
			},
			["triggers"] = {
				{
					["trigger"] = {
						["duration"] = "1",
						["genericShowOn"] = "showOnReady",
						["unit"] = "player",
						["debuffType"] = "HELPFUL",
						["names"] = {
						},
						["type"] = "status",
						["use_unit"] = true,
						["auraspellids"] = {
							"1459", -- [1]
						},
						["subeventPrefix"] = "SPELL",
						["spellName"] = 12051,
						["event"] = "Cooldown Progress (Spell)",
						["subeventSuffix"] = "_CAST_START",
						["realSpellName"] = "Evocation",
						["use_spellName"] = true,
						["spellIds"] = {
						},
						["use_absorbMode"] = true,
						["use_genericShowOn"] = true,
						["unevent"] = "auto",
						["useExactSpellId"] = true,
						["matchesShowOn"] = "showOnActive",
					},
					["untrigger"] = {
						["genericShowOn"] = "showOnReady",
					},
				}, -- [1]
				{
					["trigger"] = {
						["type"] = "aura2",
						["subeventSuffix"] = "_CAST_START",
						["ownOnly"] = true,
						["event"] = "Health",
						["subeventPrefix"] = "SPELL",
						["spellIds"] = {
						},
						["names"] = {
						},
						["unit"] = "player",
						["useExactSpellId"] = true,
						["auraspellids"] = {
							"1459", -- [1]
						},
						["debuffType"] = "HELPFUL",
					},
					["untrigger"] = {
					},
				}, -- [2]
				{
					["trigger"] = {
						["type"] = "status",
						["unevent"] = "auto",
						["event"] = "Cooldown Progress (Spell)",
						["duration"] = "1",
						["genericShowOn"] = "showOnReady",
						["subeventPrefix"] = "SPELL",
						["realSpellName"] = "Charged Up",
						["use_spellName"] = true,
						["unit"] = "player",
						["use_unit"] = true,
						["use_absorbMode"] = true,
						["subeventSuffix"] = "_CAST_START",
						["use_genericShowOn"] = true,
						["spellName"] = 205032,
					},
					["untrigger"] = {
						["genericShowOn"] = "showOnReady",
					},
				}, -- [3]
				["activeTriggerMode"] = -10,
			},
			["cooldownTextEnabled"] = true,
			["conditions"] = {
			},
			["text2Containment"] = "INSIDE",
			["glowType"] = "buttonOverlay",
			["text1Color"] = {
				1, -- [1]
				0, -- [2]
				0, -- [3]
				1, -- [4]
			},
			["selfPoint"] = "CENTER",
			["xOffset"] = 0,
			["text2Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["regionType"] = "icon",
			["glow"] = true,
			["frameStrata"] = 1,
			["text2FontSize"] = 24,
			["width"] = 64,
			["text1"] = "4",
			["text2Font"] = "Friz Quadrata TT",
			["auto"] = false,
			["text2"] = "%p",
			["useGlowColor"] = false,
			["zoom"] = 0,
			["id"] = "#1 - Charged Up",
			["stickyDuration"] = false,
			["text2Enabled"] = false,
			["anchorFrameType"] = "SCREEN",
			["text1FontFlags"] = "OUTLINE",
			["text1Font"] = "Friz Quadrata TT",
			["inverse"] = false,
			["text1Containment"] = "INSIDE",
			["displayIcon"] = 839979,
			["parent"] = "Mage Helper - Opener",
			["actions"] = {
				["start"] = {
				},
				["finish"] = {
				},
				["init"] = {
				},
			},
		},
		["#0 - Arcane Intellect"] = {
			["text2Point"] = "CENTER",
			["text1FontSize"] = 36,
			["cooldownTextEnabled"] = true,
			["yOffset"] = 0,
			["anchorPoint"] = "CENTER",
			["customTextUpdate"] = "update",
			["actions"] = {
				["start"] = {
				},
				["init"] = {
				},
				["finish"] = {
				},
			},
			["useglowColor"] = false,
			["text1Enabled"] = true,
			["keepAspectRatio"] = false,
			["animation"] = {
				["start"] = {
					["type"] = "none",
					["duration_type"] = "seconds",
				},
				["main"] = {
					["type"] = "none",
					["duration_type"] = "seconds",
				},
				["finish"] = {
					["type"] = "none",
					["duration_type"] = "seconds",
				},
			},
			["desaturate"] = false,
			["glowColor"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["text1Point"] = "CENTER",
			["text2Enabled"] = false,
			["text2FontFlags"] = "OUTLINE",
			["height"] = 64,
			["triggers"] = {
				{
					["trigger"] = {
						["duration"] = "1",
						["genericShowOn"] = "showOnReady",
						["unit"] = "player",
						["debuffType"] = "HELPFUL",
						["names"] = {
						},
						["type"] = "status",
						["auraspellids"] = {
							"1459", -- [1]
						},
						["useExactSpellId"] = true,
						["unevent"] = "auto",
						["subeventPrefix"] = "SPELL",
						["event"] = "Cooldown Progress (Spell)",
						["matchesShowOn"] = "showOnMissing",
						["realSpellName"] = "Evocation",
						["use_spellName"] = true,
						["spellIds"] = {
						},
						["use_absorbMode"] = true,
						["spellName"] = 12051,
						["subeventSuffix"] = "_CAST_START",
						["use_unit"] = true,
						["use_genericShowOn"] = true,
					},
					["untrigger"] = {
						["genericShowOn"] = "showOnReady",
					},
				}, -- [1]
				{
					["trigger"] = {
						["use_genericShowOn"] = true,
						["genericShowOn"] = "showOnReady",
						["unit"] = "player",
						["debuffType"] = "HELPFUL",
						["use_absorbMode"] = true,
						["type"] = "aura2",
						["duration"] = "1",
						["auraspellids"] = {
							"1459", -- [1]
						},
						["spellName"] = 12051,
						["unevent"] = "auto",
						["event"] = "Cooldown Progress (Spell)",
						["subeventPrefix"] = "SPELL",
						["realSpellName"] = "Evocation",
						["use_spellName"] = true,
						["spellIds"] = {
						},
						["use_unit"] = true,
						["names"] = {
						},
						["useExactSpellId"] = true,
						["subeventSuffix"] = "_CAST_START",
						["matchesShowOn"] = "showOnMissing",
					},
					["untrigger"] = {
						["genericShowOn"] = "showOnReady",
					},
				}, -- [2]
				["activeTriggerMode"] = -10,
			},
			["load"] = {
				["talent2"] = {
					["single"] = 9,
				},
				["use_level"] = true,
				["talent"] = {
					["single"] = 11,
					["multi"] = {
						[9] = true,
						[11] = true,
					},
				},
				["use_size"] = false,
				["spec"] = {
					["single"] = 1,
					["multi"] = {
					},
				},
				["level_operator"] = "==",
				["use_talent"] = true,
				["use_class"] = true,
				["use_combat"] = false,
				["use_talent2"] = true,
				["use_spec"] = true,
				["class"] = {
					["single"] = "MAGE",
					["multi"] = {
					},
				},
				["level"] = "120",
				["use_name"] = false,
				["size"] = {
					["multi"] = {
						["party"] = true,
						["scenario"] = true,
						["flexible"] = true,
						["ten"] = true,
						["twentyfive"] = true,
						["twenty"] = true,
						["fortyman"] = true,
					},
				},
			},
			["icon"] = true,
			["text1Containment"] = "INSIDE",
			["displayIcon"] = 135932,
			["text2Containment"] = "INSIDE",
			["glowType"] = "buttonOverlay",
			["text1Color"] = {
				1, -- [1]
				0, -- [2]
				0, -- [3]
				1, -- [4]
			},
			["parent"] = "Mage Helper - Opener",
			["xOffset"] = 0,
			["text2Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["regionType"] = "icon",
			["selfPoint"] = "CENTER",
			["text1FontFlags"] = "OUTLINE",
			["text2FontSize"] = 24,
			["anchorFrameType"] = "SCREEN",
			["text1"] = "N1",
			["text2Font"] = "Friz Quadrata TT",
			["zoom"] = 0,
			["text2"] = "%p",
			["auto"] = false,
			["useGlowColor"] = false,
			["id"] = "#0 - Arcane Intellect",
			["frameStrata"] = 1,
			["alpha"] = 1,
			["width"] = 64,
			["glow"] = true,
			["text1Font"] = "Friz Quadrata TT",
			["inverse"] = false,
			["internalVersion"] = 9,
			["conditions"] = {
			},
			["stickyDuration"] = false,
			["color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
		},
		["Earth Shield"] = {
			["text2Point"] = "CENTER",
			["text1FontSize"] = 12,
			["parent"] = "Enhance Shaman",
			["yOffset"] = 0,
			["anchorPoint"] = "CENTER",
			["customTextUpdate"] = "update",
			["icon"] = true,
			["useglowColor"] = false,
			["text1Enabled"] = true,
			["keepAspectRatio"] = false,
			["animation"] = {
				["start"] = {
					["type"] = "none",
					["duration_type"] = "seconds",
				},
				["main"] = {
					["type"] = "none",
					["duration_type"] = "seconds",
				},
				["finish"] = {
					["type"] = "none",
					["duration_type"] = "seconds",
				},
			},
			["desaturate"] = false,
			["glowColor"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["text1Point"] = "CENTER",
			["text2FontFlags"] = "OUTLINE",
			["height"] = 60,
			["load"] = {
				["use_class"] = true,
				["spec"] = {
					["multi"] = {
					},
				},
				["class"] = {
					["single"] = "SHAMAN",
					["multi"] = {
					},
				},
				["size"] = {
					["multi"] = {
					},
				},
			},
			["xOffset"] = 0,
			["stickyDuration"] = false,
			["color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["text2Containment"] = "INSIDE",
			["glowType"] = "buttonOverlay",
			["text1Font"] = "Friz Quadrata TT",
			["text2Font"] = "Friz Quadrata TT",
			["text1Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["text2Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["regionType"] = "icon",
			["actions"] = {
				["start"] = {
				},
				["init"] = {
				},
				["finish"] = {
				},
			},
			["internalVersion"] = 9,
			["text2FontSize"] = 24,
			["triggers"] = {
				{
					["trigger"] = {
						["type"] = "aura",
						["subeventSuffix"] = "_CAST_START",
						["ownOnly"] = true,
						["event"] = "Health",
						["subeventPrefix"] = "SPELL",
						["spellIds"] = {
							974, -- [1]
						},
						["buffShowOn"] = "showOnActive",
						["names"] = {
							"Earth Shield", -- [1]
						},
						["unit"] = "player",
						["debuffType"] = "HELPFUL",
					},
					["untrigger"] = {
					},
				}, -- [1]
				["activeTriggerMode"] = -10,
			},
			["text1"] = "%s",
			["anchorFrameType"] = "SCREEN",
			["frameStrata"] = 1,
			["text2"] = "%p",
			["auto"] = true,
			["zoom"] = 0,
			["id"] = "Earth Shield",
			["text2Enabled"] = false,
			["alpha"] = 1,
			["width"] = 60,
			["text1FontFlags"] = "OUTLINE",
			["selfPoint"] = "CENTER",
			["inverse"] = false,
			["text1Containment"] = "INSIDE",
			["conditions"] = {
			},
			["glow"] = false,
			["cooldownTextEnabled"] = true,
		},
		["Cold Blood Buff"] = {
			["text2Point"] = "CENTER",
			["text1FontSize"] = 18,
			["color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["yOffset"] = 0,
			["anchorPoint"] = "CENTER",
			["customTextUpdate"] = "update",
			["actions"] = {
				["start"] = {
					["do_glow"] = false,
					["glow_action"] = "show",
				},
				["init"] = {
					["do_custom"] = false,
				},
				["finish"] = {
				},
			},
			["useglowColor"] = false,
			["internalVersion"] = 9,
			["keepAspectRatio"] = false,
			["animation"] = {
				["start"] = {
					["duration_type"] = "seconds",
					["type"] = "none",
				},
				["main"] = {
					["type"] = "preset",
					["preset"] = "pulse",
					["duration_type"] = "seconds",
				},
				["finish"] = {
					["duration_type"] = "seconds",
					["type"] = "none",
				},
			},
			["text1Containment"] = "OUTSIDE",
			["glowColor"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["text1Point"] = "TOP",
			["text2FontFlags"] = "OUTLINE",
			["height"] = 64,
			["load"] = {
				["use_class"] = true,
				["use_warmode"] = true,
				["use_spec"] = true,
				["pvptalent"] = {
					["single"] = 13,
					["multi"] = {
						[13] = true,
					},
				},
				["spec"] = {
					["single"] = 3,
					["multi"] = {
					},
				},
				["class"] = {
					["single"] = "ROGUE",
					["multi"] = {
					},
				},
				["use_pvptalent"] = true,
				["size"] = {
					["multi"] = {
					},
				},
			},
			["text2"] = "%p",
			["text1Enabled"] = true,
			["desaturate"] = true,
			["text2Containment"] = "INSIDE",
			["glowType"] = "buttonOverlay",
			["text1Font"] = "Friz Quadrata TT",
			["triggers"] = {
				{
					["trigger"] = {
						["type"] = "aura",
						["subeventSuffix"] = "_CAST_START",
						["ownOnly"] = true,
						["event"] = "Health",
						["names"] = {
							"Cold Blood", -- [1]
						},
						["spellIds"] = {
							213981, -- [1]
						},
						["buffShowOn"] = "showOnMissing",
						["subeventPrefix"] = "SPELL",
						["unit"] = "player",
						["debuffType"] = "HELPFUL",
					},
					["untrigger"] = {
					},
				}, -- [1]
				{
					["trigger"] = {
						["duration"] = "1",
						["type"] = "status",
						["use_absorbMode"] = true,
						["use_targetRequired"] = true,
						["use_unit"] = true,
						["use_genericShowOn"] = true,
						["event"] = "Cooldown Progress (Spell)",
						["subeventPrefix"] = "SPELL",
						["realSpellName"] = "Cold Blood",
						["use_spellName"] = true,
						["unevent"] = "auto",
						["subeventSuffix"] = "_CAST_START",
						["use_inverse"] = true,
						["unit"] = "player",
						["genericShowOn"] = "showOnReady",
						["spellName"] = 213981,
					},
					["untrigger"] = {
						["genericShowOn"] = "showOnReady",
						["spellName"] = 213981,
					},
				}, -- [2]
				{
					["trigger"] = {
						["type"] = "aura",
						["subeventSuffix"] = "_CAST_START",
						["use_absorbMode"] = true,
						["event"] = "Conditions",
						["use_unit"] = true,
						["buffShowOn"] = "showOnActive",
						["unevent"] = "auto",
						["spellIds"] = {
							1784, -- [1]
						},
						["ownOnly"] = true,
						["subeventPrefix"] = "SPELL",
						["names"] = {
							"Stealth", -- [1]
						},
						["unit"] = "player",
						["debuffType"] = "HELPFUL",
					},
					["untrigger"] = {
					},
				}, -- [3]
				["activeTriggerMode"] = -10,
			},
			["xOffset"] = 0,
			["text2Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["regionType"] = "icon",
			["text1Color"] = {
				1, -- [1]
				0, -- [2]
				0.0117647058823529, -- [3]
				1, -- [4]
			},
			["text1FontFlags"] = "OUTLINE",
			["text2FontSize"] = 24,
			["selfPoint"] = "CENTER",
			["text1"] = "MISSING!",
			["width"] = 64,
			["alpha"] = 1,
			["zoom"] = 0,
			["auto"] = true,
			["cooldownTextEnabled"] = true,
			["id"] = "Cold Blood Buff",
			["glow"] = false,
			["text2Enabled"] = false,
			["anchorFrameType"] = "SCREEN",
			["frameStrata"] = 1,
			["uid"] = "7ChM(x)fpxV",
			["inverse"] = false,
			["stickyDuration"] = false,
			["conditions"] = {
			},
			["icon"] = true,
			["text2Font"] = "Friz Quadrata TT",
		},
		["#2 - Rune of Power"] = {
			["text2Point"] = "CENTER",
			["text1FontSize"] = 36,
			["color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["yOffset"] = 0,
			["anchorPoint"] = "CENTER",
			["customTextUpdate"] = "update",
			["icon"] = true,
			["useglowColor"] = false,
			["text1Enabled"] = true,
			["keepAspectRatio"] = false,
			["animation"] = {
				["start"] = {
					["duration_type"] = "seconds",
					["type"] = "none",
				},
				["main"] = {
					["duration_type"] = "seconds",
					["type"] = "none",
				},
				["finish"] = {
					["duration_type"] = "seconds",
					["type"] = "none",
				},
			},
			["desaturate"] = false,
			["glowColor"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["text1Point"] = "CENTER",
			["text2FontFlags"] = "OUTLINE",
			["height"] = 64,
			["width"] = 64,
			["load"] = {
				["talent2"] = {
					["single"] = 9,
				},
				["use_level"] = true,
				["talent"] = {
					["single"] = 11,
				},
				["use_size"] = false,
				["spec"] = {
					["single"] = 1,
					["multi"] = {
					},
				},
				["class"] = {
					["single"] = "MAGE",
					["multi"] = {
					},
				},
				["use_talent"] = true,
				["use_class"] = true,
				["use_combat"] = false,
				["use_talent2"] = true,
				["use_spec"] = true,
				["use_name"] = false,
				["level"] = "120",
				["level_operator"] = "==",
				["size"] = {
					["multi"] = {
						["party"] = true,
						["scenario"] = true,
						["flexible"] = true,
						["ten"] = true,
						["twentyfive"] = true,
						["twenty"] = true,
						["fortyman"] = true,
					},
				},
			},
			["internalVersion"] = 9,
			["triggers"] = {
				{
					["trigger"] = {
						["duration"] = "1",
						["genericShowOn"] = "showOnReady",
						["unit"] = "player",
						["debuffType"] = "HELPFUL",
						["type"] = "status",
						["auraspellids"] = {
							"205032", -- [1]
						},
						["useExactSpellId"] = true,
						["names"] = {
						},
						["unevent"] = "auto",
						["event"] = "Cooldown Progress (Spell)",
						["subeventPrefix"] = "SPELL",
						["realSpellName"] = "Evocation",
						["use_spellName"] = true,
						["spellIds"] = {
						},
						["use_absorbMode"] = true,
						["spellName"] = 12051,
						["use_unit"] = true,
						["subeventSuffix"] = "_CAST_START",
						["use_genericShowOn"] = true,
					},
					["untrigger"] = {
						["genericShowOn"] = "showOnReady",
					},
				}, -- [1]
				{
					["trigger"] = {
						["duration"] = "1",
						["genericShowOn"] = "showOnCooldown",
						["unit"] = "player",
						["debuffType"] = "HELPFUL",
						["names"] = {
						},
						["type"] = "status",
						["auraspellids"] = {
							"205032", -- [1]
						},
						["useExactSpellId"] = true,
						["unevent"] = "auto",
						["subeventPrefix"] = "SPELL",
						["event"] = "Cooldown Progress (Spell)",
						["matchesShowOn"] = "showOnActive",
						["realSpellName"] = "Charged Up",
						["use_spellName"] = true,
						["spellIds"] = {
						},
						["use_absorbMode"] = true,
						["spellName"] = 205032,
						["subeventSuffix"] = "_CAST_START",
						["use_unit"] = true,
						["use_genericShowOn"] = true,
					},
					["untrigger"] = {
						["genericShowOn"] = "showOnCooldown",
					},
				}, -- [2]
				{
					["trigger"] = {
						["type"] = "aura2",
						["subeventSuffix"] = "_CAST_START",
						["matchesShowOn"] = "showOnMissing",
						["event"] = "Health",
						["subeventPrefix"] = "SPELL",
						["auraspellids"] = {
							"116014", -- [1]
						},
						["unit"] = "player",
						["useExactSpellId"] = true,
						["debuffType"] = "HELPFUL",
					},
					["untrigger"] = {
					},
				}, -- [3]
				["activeTriggerMode"] = 2,
			},
			["cooldownTextEnabled"] = true,
			["text2Containment"] = "INSIDE",
			["glowType"] = "buttonOverlay",
			["text1Color"] = {
				1, -- [1]
				0, -- [2]
				0, -- [3]
				1, -- [4]
			},
			["conditions"] = {
			},
			["selfPoint"] = "CENTER",
			["text2Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["regionType"] = "icon",
			["xOffset"] = 0,
			["glow"] = true,
			["text2FontSize"] = 24,
			["frameStrata"] = 1,
			["text1"] = "V",
			["alpha"] = 1,
			["text2Font"] = "Friz Quadrata TT",
			["text2"] = "%p",
			["auto"] = false,
			["zoom"] = 0,
			["id"] = "#2 - Rune of Power",
			["stickyDuration"] = false,
			["text2Enabled"] = false,
			["anchorFrameType"] = "SCREEN",
			["text1FontFlags"] = "OUTLINE",
			["text1Font"] = "Friz Quadrata TT",
			["inverse"] = false,
			["text1Containment"] = "INSIDE",
			["displayIcon"] = 609815,
			["parent"] = "Mage Helper - Opener",
			["actions"] = {
				["start"] = {
				},
				["finish"] = {
				},
				["init"] = {
				},
			},
		},
		["Plasma Discharge"] = {
			["text2Point"] = "CENTER",
			["text1FontSize"] = 12,
			["color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["yOffset"] = -450.832901000977,
			["anchorPoint"] = "CENTER",
			["customTextUpdate"] = "update",
			["icon"] = true,
			["useglowColor"] = false,
			["text1Enabled"] = true,
			["keepAspectRatio"] = false,
			["animation"] = {
				["start"] = {
					["duration_type"] = "seconds",
					["type"] = "none",
				},
				["main"] = {
					["duration_type"] = "seconds",
					["type"] = "none",
				},
				["finish"] = {
					["duration_type"] = "seconds",
					["type"] = "none",
				},
			},
			["desaturate"] = false,
			["glowColor"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["text1Point"] = "BOTTOMRIGHT",
			["text2FontFlags"] = "OUTLINE",
			["height"] = 64,
			["load"] = {
				["spec"] = {
					["multi"] = {
					},
				},
				["class"] = {
					["multi"] = {
					},
				},
				["size"] = {
					["multi"] = {
					},
				},
			},
			["text1Font"] = "Friz Quadrata TT",
			["text1FontFlags"] = "OUTLINE",
			["text2Containment"] = "INSIDE",
			["glowType"] = "buttonOverlay",
			["text1Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["actions"] = {
				["start"] = {
				},
				["finish"] = {
				},
				["init"] = {
				},
			},
			["glow"] = false,
			["text2Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["regionType"] = "icon",
			["triggers"] = {
				{
					["trigger"] = {
						["type"] = "aura2",
						["subeventSuffix"] = "_CAST_START",
						["event"] = "Health",
						["subeventPrefix"] = "SPELL",
						["spellIds"] = {
						},
						["auraspellids"] = {
							"271222", -- [1]
						},
						["unit"] = "player",
						["names"] = {
						},
						["useExactSpellId"] = true,
						["debuffType"] = "HARMFUL",
					},
					["untrigger"] = {
					},
				}, -- [1]
				["activeTriggerMode"] = -10,
			},
			["cooldownTextEnabled"] = true,
			["text2FontSize"] = 24,
			["internalVersion"] = 9,
			["text1"] = "%s",
			["frameStrata"] = 1,
			["width"] = 64,
			["text2"] = "%p",
			["auto"] = true,
			["alpha"] = 1,
			["id"] = "Plasma Discharge",
			["zoom"] = 0,
			["text2Enabled"] = false,
			["anchorFrameType"] = "SCREEN",
			["stickyDuration"] = false,
			["text1Containment"] = "INSIDE",
			["inverse"] = false,
			["xOffset"] = -305.832702636719,
			["conditions"] = {
			},
			["text2Font"] = "Friz Quadrata TT",
			["selfPoint"] = "CENTER",
		},
		["#9 - Rune of Power"] = {
			["text2Point"] = "CENTER",
			["text1FontSize"] = 36,
			["cooldownTextEnabled"] = true,
			["yOffset"] = 0,
			["anchorPoint"] = "CENTER",
			["customTextUpdate"] = "update",
			["actions"] = {
				["start"] = {
				},
				["init"] = {
				},
				["finish"] = {
				},
			},
			["useglowColor"] = false,
			["text1Enabled"] = true,
			["keepAspectRatio"] = false,
			["animation"] = {
				["start"] = {
					["type"] = "none",
					["duration_type"] = "seconds",
				},
				["main"] = {
					["type"] = "none",
					["duration_type"] = "seconds",
				},
				["finish"] = {
					["type"] = "none",
					["duration_type"] = "seconds",
				},
			},
			["desaturate"] = false,
			["glowColor"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["text1Point"] = "CENTER",
			["text2FontFlags"] = "OUTLINE",
			["height"] = 64,
			["anchorFrameType"] = "SCREEN",
			["load"] = {
				["talent2"] = {
					["single"] = 9,
				},
				["use_level"] = true,
				["talent"] = {
					["single"] = 11,
				},
				["use_size"] = false,
				["spec"] = {
					["single"] = 1,
					["multi"] = {
					},
				},
				["use_name"] = false,
				["use_talent"] = true,
				["use_class"] = true,
				["level"] = "120",
				["use_talent2"] = true,
				["use_spec"] = true,
				["class"] = {
					["single"] = "MAGE",
					["multi"] = {
					},
				},
				["use_combat"] = true,
				["level_operator"] = "==",
				["size"] = {
					["multi"] = {
						["party"] = true,
						["scenario"] = true,
						["flexible"] = true,
						["ten"] = true,
						["twentyfive"] = true,
						["twenty"] = true,
						["fortyman"] = true,
					},
				},
			},
			["parent"] = "Mage Helper - Opener",
			["text1Containment"] = "INSIDE",
			["icon"] = true,
			["text2Containment"] = "INSIDE",
			["glowType"] = "buttonOverlay",
			["text1Color"] = {
				1, -- [1]
				0, -- [2]
				0, -- [3]
				1, -- [4]
			},
			["displayIcon"] = 609815,
			["xOffset"] = 0,
			["text2Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["regionType"] = "icon",
			["selfPoint"] = "CENTER",
			["text1FontFlags"] = "OUTLINE",
			["text2FontSize"] = 24,
			["stickyDuration"] = false,
			["text1"] = "V",
			["text2Enabled"] = false,
			["text2Font"] = "Friz Quadrata TT",
			["text2"] = "%p",
			["auto"] = false,
			["zoom"] = 0,
			["id"] = "#9 - Rune of Power",
			["alpha"] = 1,
			["frameStrata"] = 1,
			["width"] = 64,
			["glow"] = true,
			["text1Font"] = "Friz Quadrata TT",
			["inverse"] = false,
			["internalVersion"] = 9,
			["conditions"] = {
			},
			["triggers"] = {
				{
					["trigger"] = {
						["use_genericShowOn"] = true,
						["genericShowOn"] = "showOnReady",
						["use_unit"] = true,
						["debuffType"] = "HELPFUL",
						["type"] = "status",
						["unit"] = "player",
						["auraspellids"] = {
							"205032", -- [1]
						},
						["duration"] = "1",
						["spellName"] = 12051,
						["event"] = "Cooldown Progress (Spell)",
						["useExactSpellId"] = true,
						["realSpellName"] = "Evocation",
						["use_spellName"] = true,
						["spellIds"] = {
						},
						["use_absorbMode"] = true,
						["subeventPrefix"] = "SPELL",
						["unevent"] = "auto",
						["names"] = {
						},
						["subeventSuffix"] = "_CAST_START",
					},
					["untrigger"] = {
						["genericShowOn"] = "showOnReady",
					},
				}, -- [1]
				{
					["trigger"] = {
						["type"] = "aura2",
						["subeventSuffix"] = "_CAST_START",
						["matchesShowOn"] = "showOnMissing",
						["event"] = "Health",
						["subeventPrefix"] = "SPELL",
						["ownOnly"] = true,
						["unit"] = "player",
						["useExactSpellId"] = true,
						["auraspellids"] = {
							"116014", -- [1]
						},
						["debuffType"] = "HELPFUL",
					},
					["untrigger"] = {
					},
				}, -- [2]
				{
					["trigger"] = {
						["charges_operator"] = "<=",
						["type"] = "status",
						["charges"] = "1",
						["unevent"] = "auto",
						["duration"] = "1",
						["use_charges"] = true,
						["event"] = "Action Usable",
						["subeventPrefix"] = "SPELL",
						["realSpellName"] = "Rune of Power",
						["use_spellName"] = true,
						["use_unit"] = true,
						["use_absorbMode"] = true,
						["unit"] = "player",
						["subeventSuffix"] = "_CAST_START",
						["use_powertype"] = true,
						["spellName"] = 116011,
					},
					["untrigger"] = {
					},
				}, -- [3]
				["activeTriggerMode"] = -10,
			},
			["color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
		},
		["Lightning Shield"] = {
			["text2Point"] = "CENTER",
			["text1FontSize"] = 12,
			["cooldownTextEnabled"] = true,
			["yOffset"] = 0,
			["anchorPoint"] = "CENTER",
			["customTextUpdate"] = "update",
			["icon"] = true,
			["useglowColor"] = false,
			["text1Enabled"] = true,
			["keepAspectRatio"] = false,
			["animation"] = {
				["start"] = {
					["duration_type"] = "seconds",
					["type"] = "none",
				},
				["main"] = {
					["duration_type"] = "seconds",
					["type"] = "none",
				},
				["finish"] = {
					["duration_type"] = "seconds",
					["type"] = "none",
				},
			},
			["desaturate"] = false,
			["glowColor"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["text1Point"] = "CENTER",
			["text2FontFlags"] = "OUTLINE",
			["height"] = 60,
			["load"] = {
				["use_class"] = true,
				["spec"] = {
					["multi"] = {
					},
				},
				["class"] = {
					["single"] = "SHAMAN",
					["multi"] = {
					},
				},
				["size"] = {
					["multi"] = {
					},
				},
			},
			["stickyDuration"] = false,
			["glow"] = false,
			["selfPoint"] = "CENTER",
			["text2Containment"] = "INSIDE",
			["glowType"] = "buttonOverlay",
			["text1Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["internalVersion"] = 9,
			["actions"] = {
				["start"] = {
				},
				["finish"] = {
				},
				["init"] = {
				},
			},
			["text1FontFlags"] = "OUTLINE",
			["regionType"] = "icon",
			["xOffset"] = 0,
			["text1Font"] = "Friz Quadrata TT",
			["text2FontSize"] = 24,
			["text1Containment"] = "INSIDE",
			["text1"] = "%s",
			["width"] = 60,
			["alpha"] = 1,
			["zoom"] = 0,
			["auto"] = true,
			["text2"] = "%p",
			["id"] = "Lightning Shield",
			["text2Enabled"] = false,
			["frameStrata"] = 1,
			["anchorFrameType"] = "SCREEN",
			["text2Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["parent"] = "Enhance Shaman",
			["inverse"] = false,
			["text2Font"] = "Friz Quadrata TT",
			["conditions"] = {
			},
			["color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["triggers"] = {
				{
					["trigger"] = {
						["type"] = "aura",
						["subeventSuffix"] = "_CAST_START",
						["ownOnly"] = true,
						["event"] = "Health",
						["subeventPrefix"] = "SPELL",
						["spellIds"] = {
							192106, -- [1]
						},
						["debuffType"] = "HELPFUL",
						["unit"] = "player",
						["names"] = {
							"Lightning Shield", -- [1]
						},
						["buffShowOn"] = "showOnActive",
					},
					["untrigger"] = {
					},
				}, -- [1]
				["activeTriggerMode"] = -10,
			},
		},
		["Flametounge"] = {
			["text2Point"] = "CENTER",
			["text1FontSize"] = 12,
			["cooldownTextEnabled"] = true,
			["yOffset"] = 0,
			["anchorPoint"] = "CENTER",
			["customTextUpdate"] = "update",
			["icon"] = true,
			["useglowColor"] = false,
			["text1Enabled"] = true,
			["keepAspectRatio"] = false,
			["animation"] = {
				["start"] = {
					["duration_type"] = "seconds",
					["type"] = "none",
				},
				["main"] = {
					["duration_type"] = "seconds",
					["type"] = "none",
				},
				["finish"] = {
					["duration_type"] = "seconds",
					["type"] = "none",
				},
			},
			["desaturate"] = false,
			["glowColor"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["text1Point"] = "BOTTOMRIGHT",
			["text2FontFlags"] = "OUTLINE",
			["height"] = 64,
			["load"] = {
				["use_class"] = true,
				["spec"] = {
					["multi"] = {
					},
				},
				["class"] = {
					["single"] = "SHAMAN",
					["multi"] = {
					},
				},
				["size"] = {
					["multi"] = {
					},
				},
			},
			["zoom"] = 0,
			["text1Containment"] = "INSIDE",
			["text2Font"] = "Friz Quadrata TT",
			["text2Containment"] = "INSIDE",
			["glowType"] = "buttonOverlay",
			["text1Font"] = "Friz Quadrata TT",
			["selfPoint"] = "CENTER",
			["actions"] = {
				["start"] = {
				},
				["finish"] = {
				},
				["init"] = {
				},
			},
			["text1FontFlags"] = "OUTLINE",
			["regionType"] = "icon",
			["xOffset"] = 0,
			["color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["text2FontSize"] = 24,
			["glow"] = false,
			["text1"] = "%s",
			["width"] = 64,
			["alpha"] = 1,
			["text2"] = "%p",
			["auto"] = true,
			["text2Enabled"] = false,
			["id"] = "Flametounge",
			["stickyDuration"] = false,
			["frameStrata"] = 1,
			["anchorFrameType"] = "SCREEN",
			["text1Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["text2Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["inverse"] = false,
			["internalVersion"] = 9,
			["conditions"] = {
			},
			["triggers"] = {
				{
					["trigger"] = {
						["type"] = "aura",
						["subeventSuffix"] = "_CAST_START",
						["event"] = "Health",
						["subeventPrefix"] = "SPELL",
						["spellIds"] = {
						},
						["debuffType"] = "HELPFUL",
						["unit"] = "player",
						["names"] = {
						},
						["buffShowOn"] = "showOnActive",
					},
					["untrigger"] = {
					},
				}, -- [1]
				["activeTriggerMode"] = -10,
			},
			["parent"] = "Enhance Shaman",
		},
		["#6 - Arcane Missiles"] = {
			["text2Point"] = "CENTER",
			["text1FontSize"] = 36,
			["xOffset"] = 0,
			["yOffset"] = 0,
			["anchorPoint"] = "CENTER",
			["customTextUpdate"] = "update",
			["actions"] = {
				["start"] = {
				},
				["finish"] = {
				},
				["init"] = {
				},
			},
			["triggers"] = {
				{
					["trigger"] = {
						["matchesShowOn"] = "showOnActive",
						["genericShowOn"] = "showOnReady",
						["subeventPrefix"] = "SPELL",
						["debuffType"] = "HELPFUL",
						["use_unit"] = true,
						["type"] = "status",
						["unevent"] = "auto",
						["auraspellids"] = {
							"263725", -- [1]
						},
						["use_genericShowOn"] = true,
						["useExactSpellId"] = true,
						["event"] = "Cooldown Progress (Spell)",
						["subeventSuffix"] = "_CAST_START",
						["realSpellName"] = "Evocation",
						["use_spellName"] = true,
						["spellIds"] = {
						},
						["duration"] = "1",
						["unit"] = "player",
						["use_absorbMode"] = true,
						["spellName"] = 12051,
						["names"] = {
						},
					},
					["untrigger"] = {
						["genericShowOn"] = "showOnReady",
					},
				}, -- [1]
				{
					["trigger"] = {
						["type"] = "aura2",
						["subeventSuffix"] = "_CAST_START",
						["ownOnly"] = true,
						["event"] = "Health",
						["subeventPrefix"] = "SPELL",
						["auraspellids"] = {
							"263725", -- [1]
						},
						["unit"] = "player",
						["useExactSpellId"] = true,
						["debuffType"] = "HELPFUL",
					},
					["untrigger"] = {
					},
				}, -- [2]
				["activeTriggerMode"] = 1,
			},
			["text1Enabled"] = true,
			["keepAspectRatio"] = false,
			["animation"] = {
				["start"] = {
					["duration_type"] = "seconds",
					["type"] = "none",
				},
				["main"] = {
					["duration_type"] = "seconds",
					["type"] = "none",
				},
				["finish"] = {
					["duration_type"] = "seconds",
					["type"] = "none",
				},
			},
			["desaturate"] = false,
			["glowColor"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["text1Point"] = "CENTER",
			["text2FontFlags"] = "OUTLINE",
			["height"] = 64,
			["width"] = 64,
			["load"] = {
				["talent2"] = {
					["single"] = 9,
				},
				["use_level"] = true,
				["talent"] = {
					["single"] = 11,
				},
				["use_size"] = false,
				["class"] = {
					["single"] = "MAGE",
					["multi"] = {
					},
				},
				["use_class"] = true,
				["use_talent"] = true,
				["use_name"] = false,
				["level"] = "120",
				["use_talent2"] = true,
				["use_spec"] = true,
				["spec"] = {
					["single"] = 1,
					["multi"] = {
					},
				},
				["use_combat"] = true,
				["level_operator"] = "==",
				["size"] = {
					["multi"] = {
						["party"] = true,
						["scenario"] = true,
						["flexible"] = true,
						["ten"] = true,
						["twentyfive"] = true,
						["twenty"] = true,
						["fortyman"] = true,
					},
				},
			},
			["color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["internalVersion"] = 9,
			["parent"] = "Mage Helper - Opener",
			["text2Containment"] = "INSIDE",
			["glowType"] = "buttonOverlay",
			["text1Color"] = {
				1, -- [1]
				0, -- [2]
				0, -- [3]
				1, -- [4]
			},
			["conditions"] = {
			},
			["text2Font"] = "Friz Quadrata TT",
			["text1FontFlags"] = "OUTLINE",
			["regionType"] = "icon",
			["text2Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["selfPoint"] = "CENTER",
			["text2FontSize"] = 24,
			["glow"] = true,
			["text1"] = "3",
			["frameStrata"] = 1,
			["text2"] = "%p",
			["zoom"] = 0,
			["auto"] = false,
			["stickyDuration"] = false,
			["id"] = "#6 - Arcane Missiles",
			["alpha"] = 1,
			["text2Enabled"] = false,
			["anchorFrameType"] = "SCREEN",
			["text1Font"] = "Friz Quadrata TT",
			["icon"] = true,
			["inverse"] = false,
			["text1Containment"] = "INSIDE",
			["displayIcon"] = 136096,
			["useglowColor"] = false,
			["cooldownTextEnabled"] = true,
		},
		["#8 - Evocate"] = {
			["text2Point"] = "CENTER",
			["text1FontSize"] = 36,
			["xOffset"] = 0,
			["yOffset"] = 0,
			["anchorPoint"] = "CENTER",
			["customTextUpdate"] = "update",
			["actions"] = {
				["start"] = {
				},
				["finish"] = {
				},
				["init"] = {
				},
			},
			["useglowColor"] = false,
			["internalVersion"] = 9,
			["keepAspectRatio"] = false,
			["animation"] = {
				["start"] = {
					["duration_type"] = "seconds",
					["type"] = "none",
				},
				["main"] = {
					["duration_type"] = "seconds",
					["type"] = "none",
				},
				["finish"] = {
					["duration_type"] = "seconds",
					["type"] = "none",
				},
			},
			["text1Containment"] = "INSIDE",
			["glowColor"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["text1Point"] = "CENTER",
			["text2FontFlags"] = "OUTLINE",
			["height"] = 64,
			["width"] = 64,
			["load"] = {
				["talent2"] = {
					["single"] = 9,
				},
				["use_level"] = true,
				["talent"] = {
					["single"] = 11,
				},
				["use_size"] = false,
				["class"] = {
					["single"] = "MAGE",
					["multi"] = {
					},
				},
				["use_name"] = false,
				["use_talent"] = true,
				["use_class"] = true,
				["level"] = "120",
				["use_talent2"] = true,
				["use_spec"] = true,
				["spec"] = {
					["single"] = 1,
					["multi"] = {
					},
				},
				["use_combat"] = true,
				["level_operator"] = "==",
				["size"] = {
					["multi"] = {
						["party"] = true,
						["scenario"] = true,
						["flexible"] = true,
						["ten"] = true,
						["twentyfive"] = true,
						["twenty"] = true,
						["fortyman"] = true,
					},
				},
			},
			["color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["text1Enabled"] = true,
			["parent"] = "Mage Helper - Opener",
			["text2Containment"] = "INSIDE",
			["glowType"] = "buttonOverlay",
			["text1Color"] = {
				1, -- [1]
				0, -- [2]
				0, -- [3]
				1, -- [4]
			},
			["conditions"] = {
			},
			["text1Font"] = "Friz Quadrata TT",
			["text2Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["regionType"] = "icon",
			["icon"] = true,
			["text2Font"] = "Friz Quadrata TT",
			["text2FontSize"] = 24,
			["glow"] = true,
			["text1"] = "E",
			["frameStrata"] = 1,
			["text2"] = "%p",
			["zoom"] = 0,
			["auto"] = false,
			["stickyDuration"] = false,
			["id"] = "#8 - Evocate",
			["alpha"] = 1,
			["text2Enabled"] = false,
			["anchorFrameType"] = "SCREEN",
			["text1FontFlags"] = "OUTLINE",
			["selfPoint"] = "CENTER",
			["inverse"] = false,
			["desaturate"] = false,
			["displayIcon"] = 136075,
			["triggers"] = {
				{
					["trigger"] = {
						["duration"] = "1",
						["genericShowOn"] = "showOnReady",
						["unit"] = "player",
						["powertype"] = 0,
						["subeventPrefix"] = "SPELL",
						["names"] = {
						},
						["use_absorbMode"] = true,
						["power"] = "2751",
						["use_powertype"] = true,
						["debuffType"] = "HELPFUL",
						["unevent"] = "auto",
						["type"] = "status",
						["useExactSpellId"] = true,
						["subeventSuffix"] = "_CAST_START",
						["power_operator"] = ">=",
						["matchesShowOn"] = "showOnActive",
						["event"] = "Cooldown Progress (Spell)",
						["auraspellids"] = {
							"116014", -- [1]
						},
						["realSpellName"] = "Evocation",
						["use_spellName"] = true,
						["spellIds"] = {
						},
						["use_power"] = false,
						["spellName"] = 12051,
						["use_unit"] = true,
						["use_genericShowOn"] = true,
						["use_inverse"] = true,
					},
					["untrigger"] = {
						["genericShowOn"] = "showOnReady",
					},
				}, -- [1]
				{
					["trigger"] = {
						["type"] = "status",
						["power"] = "0",
						["power_operator"] = "==",
						["duration"] = "1",
						["event"] = "Power",
						["subeventPrefix"] = "SPELL",
						["unevent"] = "auto",
						["powertype"] = 16,
						["use_power"] = true,
						["unit"] = "player",
						["use_absorbMode"] = true,
						["use_unit"] = true,
						["use_powertype"] = true,
						["subeventSuffix"] = "_CAST_START",
					},
					["untrigger"] = {
					},
				}, -- [2]
				{
					["trigger"] = {
						["use_inverse"] = true,
						["unit"] = "player",
						["powertype"] = 0,
						["use_powertype"] = true,
						["spellName"] = 30451,
						["type"] = "status",
						["unevent"] = "auto",
						["duration"] = "1",
						["event"] = "Power",
						["use_percentpower"] = true,
						["realSpellName"] = "Arcane Blast",
						["use_spellName"] = true,
						["subeventPrefix"] = "SPELL",
						["use_unit"] = true,
						["use_absorbMode"] = true,
						["subeventSuffix"] = "_CAST_START",
						["percentpower"] = "3",
						["percentpower_operator"] = "<",
					},
					["untrigger"] = {
					},
				}, -- [3]
				["activeTriggerMode"] = 1,
			},
			["cooldownTextEnabled"] = true,
		},
		["Lightning Shield - Missing"] = {
			["text2Point"] = "CENTER",
			["text1FontSize"] = 12,
			["parent"] = "Enhance Shaman",
			["yOffset"] = 0,
			["anchorPoint"] = "CENTER",
			["customTextUpdate"] = "update",
			["icon"] = true,
			["useglowColor"] = false,
			["text1Enabled"] = true,
			["keepAspectRatio"] = false,
			["animation"] = {
				["start"] = {
					["type"] = "none",
					["duration_type"] = "seconds",
				},
				["main"] = {
					["type"] = "none",
					["duration_type"] = "seconds",
				},
				["finish"] = {
					["type"] = "none",
					["duration_type"] = "seconds",
				},
			},
			["desaturate"] = true,
			["glowColor"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["text1Point"] = "CENTER",
			["text2FontFlags"] = "OUTLINE",
			["height"] = 60,
			["load"] = {
				["use_class"] = true,
				["spec"] = {
					["multi"] = {
					},
				},
				["class"] = {
					["single"] = "SHAMAN",
					["multi"] = {
					},
				},
				["size"] = {
					["multi"] = {
					},
				},
			},
			["xOffset"] = 0,
			["stickyDuration"] = false,
			["color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["text2Containment"] = "INSIDE",
			["glowType"] = "buttonOverlay",
			["text1Font"] = "Friz Quadrata TT",
			["text2Font"] = "Friz Quadrata TT",
			["text1Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["text2Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["regionType"] = "icon",
			["actions"] = {
				["start"] = {
				},
				["init"] = {
				},
				["finish"] = {
				},
			},
			["internalVersion"] = 9,
			["text2FontSize"] = 24,
			["text1Containment"] = "INSIDE",
			["text1"] = "%s",
			["anchorFrameType"] = "SCREEN",
			["frameStrata"] = 1,
			["text2"] = "%p",
			["auto"] = true,
			["zoom"] = 0,
			["id"] = "Lightning Shield - Missing",
			["text2Enabled"] = false,
			["alpha"] = 1,
			["width"] = 60,
			["text1FontFlags"] = "OUTLINE",
			["selfPoint"] = "CENTER",
			["inverse"] = false,
			["triggers"] = {
				{
					["trigger"] = {
						["type"] = "aura",
						["subeventSuffix"] = "_CAST_START",
						["ownOnly"] = true,
						["event"] = "Health",
						["subeventPrefix"] = "SPELL",
						["spellIds"] = {
							192106, -- [1]
						},
						["buffShowOn"] = "showOnMissing",
						["names"] = {
							"Lightning Shield", -- [1]
						},
						["unit"] = "player",
						["debuffType"] = "HELPFUL",
					},
					["untrigger"] = {
					},
				}, -- [1]
				["activeTriggerMode"] = -10,
			},
			["conditions"] = {
			},
			["glow"] = false,
			["cooldownTextEnabled"] = true,
		},
	},
	["frame"] = {
		["xOffset"] = -448.3349609375,
		["yOffset"] = -207.333068847656,
		["height"] = 492,
		["width"] = 630,
	},
	["editor_theme"] = "Monokai",
}
