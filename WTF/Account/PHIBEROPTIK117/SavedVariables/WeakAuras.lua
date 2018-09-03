
WeakAurasSaved = {
	["dynamicIconCache"] = {
		["Stealth"] = {
			[1784] = 132320,
		},
		["Lightning Shield"] = {
			[192106] = 136051,
		},
		["Earth Shield"] = {
			[974] = 136089,
		},
		["Cold Blood"] = {
			[213981] = 135988,
		},
	},
	["displays"] = {
		["Lightning Shield"] = {
			["text2Point"] = "CENTER",
			["text1FontSize"] = 12,
			["cooldownTextEnabled"] = true,
			["yOffset"] = 0,
			["anchorPoint"] = "CENTER",
			["activeTriggerMode"] = -10,
			["customTextUpdate"] = "update",
			["icon"] = true,
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
			["desaturate"] = false,
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
			["internalVersion"] = 6,
			["text2Containment"] = "INSIDE",
			["actions"] = {
				["start"] = {
				},
				["finish"] = {
				},
				["init"] = {
				},
			},
			["text1Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["text1Containment"] = "INSIDE",
			["selfPoint"] = "CENTER",
			["text2Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["regionType"] = "icon",
			["numTriggers"] = 1,
			["color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["text2FontSize"] = 24,
			["glow"] = false,
			["width"] = 60,
			["text1"] = "%s",
			["alpha"] = 1,
			["zoom"] = 0,
			["text2"] = "%p",
			["auto"] = true,
			["text2Enabled"] = false,
			["id"] = "Lightning Shield",
			["stickyDuration"] = false,
			["frameStrata"] = 1,
			["anchorFrameType"] = "SCREEN",
			["text2Font"] = "Friz Quadrata TT",
			["text1FontFlags"] = "OUTLINE",
			["inverse"] = false,
			["text1Font"] = "Friz Quadrata TT",
			["conditions"] = {
			},
			["untrigger"] = {
			},
			["parent"] = "Enhance Shaman",
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
			["activeTriggerMode"] = -10,
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
			["internalVersion"] = 6,
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
			["text1Containment"] = "OUTSIDE",
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
			["desaturate"] = true,
			["icon"] = true,
			["text2Font"] = "Friz Quadrata TT",
			["text2Containment"] = "INSIDE",
			["text2Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["text1Font"] = "Friz Quadrata TT",
			["text1Enabled"] = true,
			["numTriggers"] = 3,
			["text1FontFlags"] = "OUTLINE",
			["regionType"] = "icon",
			["selfPoint"] = "CENTER",
			["untrigger"] = {
			},
			["text2FontSize"] = 24,
			["width"] = 64,
			["alpha"] = 1,
			["text1"] = "MISSING!",
			["additional_triggers"] = {
				{
					["trigger"] = {
						["type"] = "status",
						["use_absorbMode"] = true,
						["use_targetRequired"] = true,
						["unit"] = "player",
						["use_genericShowOn"] = true,
						["event"] = "Cooldown Progress (Spell)",
						["use_unit"] = true,
						["realSpellName"] = "Cold Blood",
						["use_spellName"] = true,
						["unevent"] = "auto",
						["subeventSuffix"] = "_CAST_START",
						["use_inverse"] = true,
						["genericShowOn"] = "showOnReady",
						["subeventPrefix"] = "SPELL",
						["spellName"] = 213981,
					},
					["untrigger"] = {
						["genericShowOn"] = "showOnReady",
						["spellName"] = 213981,
					},
				}, -- [1]
				{
					["trigger"] = {
						["type"] = "aura",
						["subeventSuffix"] = "_CAST_START",
						["unevent"] = "auto",
						["use_absorbMode"] = true,
						["event"] = "Conditions",
						["use_unit"] = true,
						["buffShowOn"] = "showOnActive",
						["ownOnly"] = true,
						["spellIds"] = {
							1784, -- [1]
						},
						["subeventPrefix"] = "SPELL",
						["names"] = {
							"Stealth", -- [1]
						},
						["unit"] = "player",
						["debuffType"] = "HELPFUL",
					},
					["untrigger"] = {
					},
				}, -- [2]
			},
			["text2"] = "%p",
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
			["init_started"] = 1,
			["conditions"] = {
			},
			["text1Color"] = {
				1, -- [1]
				0, -- [2]
				0.0117647058823529, -- [3]
				1, -- [4]
			},
			["xOffset"] = 0,
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
			["activeTriggerMode"] = -10,
			["customTextUpdate"] = "update",
			["icon"] = true,
			["text2Font"] = "Friz Quadrata TT",
			["keepAspectRatio"] = false,
			["selfPoint"] = "CENTER",
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
			["desaturate"] = true,
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
			["actions"] = {
				["start"] = {
				},
				["finish"] = {
				},
				["init"] = {
				},
			},
			["internalVersion"] = 6,
			["text2Containment"] = "INSIDE",
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
			["text1Font"] = "Friz Quadrata TT",
			["xOffset"] = 0,
			["text1FontFlags"] = "OUTLINE",
			["text2Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["regionType"] = "icon",
			["numTriggers"] = 1,
			["glow"] = false,
			["text2FontSize"] = 24,
			["stickyDuration"] = false,
			["width"] = 60,
			["text1"] = "%s",
			["alpha"] = 1,
			["text2Enabled"] = false,
			["zoom"] = 0,
			["auto"] = true,
			["text2"] = "%p",
			["id"] = "Earth Shield 2",
			["cooldownTextEnabled"] = true,
			["frameStrata"] = 1,
			["anchorFrameType"] = "SCREEN",
			["text1Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["text1Containment"] = "INSIDE",
			["inverse"] = false,
			["text1Enabled"] = true,
			["conditions"] = {
			},
			["untrigger"] = {
			},
			["parent"] = "Enhance Shaman",
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
			["xOffset"] = -145,
			["regionType"] = "dynamicgroup",
			["border"] = "None",
			["yOffset"] = -300,
			["anchorPoint"] = "CENTER",
			["actions"] = {
				["start"] = {
				},
				["finish"] = {
				},
				["init"] = {
				},
			},
			["sort"] = "none",
			["radius"] = 200,
			["space"] = 2,
			["background"] = "None",
			["expanded"] = false,
			["constantFactor"] = "RADIUS",
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
			["internalVersion"] = 6,
			["align"] = "CENTER",
			["selfPoint"] = "LEFT",
			["id"] = "Enhance Shaman",
			["borderOffset"] = 16,
			["frameStrata"] = 1,
			["anchorFrameType"] = "SCREEN",
			["rotation"] = 0,
			["stagger"] = 0,
			["numTriggers"] = 1,
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
			["backgroundInset"] = 0,
			["conditions"] = {
			},
			["load"] = {
				["use_class"] = false,
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
			["untrigger"] = {
			},
		},
		["Flametounge"] = {
			["text2Point"] = "CENTER",
			["text1FontSize"] = 12,
			["cooldownTextEnabled"] = true,
			["yOffset"] = 0,
			["anchorPoint"] = "CENTER",
			["activeTriggerMode"] = -10,
			["customTextUpdate"] = "update",
			["icon"] = true,
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
			["desaturate"] = false,
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
			["internalVersion"] = 6,
			["actions"] = {
				["start"] = {
				},
				["finish"] = {
				},
				["init"] = {
				},
			},
			["text2Containment"] = "INSIDE",
			["xOffset"] = 0,
			["text1Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["parent"] = "Enhance Shaman",
			["selfPoint"] = "CENTER",
			["text2Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["regionType"] = "icon",
			["numTriggers"] = 1,
			["color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["text2FontSize"] = 24,
			["glow"] = false,
			["width"] = 64,
			["text1"] = "%s",
			["alpha"] = 1,
			["zoom"] = 0,
			["text2"] = "%p",
			["auto"] = true,
			["text2Enabled"] = false,
			["id"] = "Flametounge",
			["stickyDuration"] = false,
			["frameStrata"] = 1,
			["anchorFrameType"] = "SCREEN",
			["text2Font"] = "Friz Quadrata TT",
			["text1FontFlags"] = "OUTLINE",
			["inverse"] = false,
			["text1Font"] = "Friz Quadrata TT",
			["conditions"] = {
			},
			["text1Containment"] = "INSIDE",
			["untrigger"] = {
			},
		},
		["Earth Shield"] = {
			["text2Point"] = "CENTER",
			["text1FontSize"] = 12,
			["parent"] = "Enhance Shaman",
			["untrigger"] = {
			},
			["anchorPoint"] = "CENTER",
			["activeTriggerMode"] = -10,
			["customTextUpdate"] = "update",
			["icon"] = true,
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
			["desaturate"] = false,
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
			["yOffset"] = 0,
			["xOffset"] = 0,
			["text2Containment"] = "INSIDE",
			["actions"] = {
				["start"] = {
				},
				["init"] = {
				},
				["finish"] = {
				},
			},
			["text1Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["text1Font"] = "Friz Quadrata TT",
			["text1Containment"] = "INSIDE",
			["text1FontFlags"] = "OUTLINE",
			["regionType"] = "icon",
			["inverse"] = false,
			["cooldownTextEnabled"] = true,
			["text2FontSize"] = 24,
			["stickyDuration"] = false,
			["anchorFrameType"] = "SCREEN",
			["text1"] = "%s",
			["frameStrata"] = 1,
			["text2"] = "%p",
			["zoom"] = 0,
			["auto"] = true,
			["text2Enabled"] = false,
			["id"] = "Earth Shield",
			["glow"] = false,
			["alpha"] = 1,
			["width"] = 60,
			["color"] = {
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
			["numTriggers"] = 1,
			["selfPoint"] = "CENTER",
			["conditions"] = {
			},
			["internalVersion"] = 6,
			["text2Font"] = "Friz Quadrata TT",
		},
		["Lightning Shield - Missing"] = {
			["text2Point"] = "CENTER",
			["text1FontSize"] = 12,
			["parent"] = "Enhance Shaman",
			["untrigger"] = {
			},
			["anchorPoint"] = "CENTER",
			["activeTriggerMode"] = -10,
			["customTextUpdate"] = "update",
			["icon"] = true,
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
			["desaturate"] = true,
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
			["xOffset"] = 0,
			["text2Containment"] = "INSIDE",
			["actions"] = {
				["start"] = {
				},
				["init"] = {
				},
				["finish"] = {
				},
			},
			["text1Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["text1Font"] = "Friz Quadrata TT",
			["yOffset"] = 0,
			["text1FontFlags"] = "OUTLINE",
			["regionType"] = "icon",
			["inverse"] = false,
			["cooldownTextEnabled"] = true,
			["text2FontSize"] = 24,
			["stickyDuration"] = false,
			["anchorFrameType"] = "SCREEN",
			["text1"] = "%s",
			["frameStrata"] = 1,
			["text2"] = "%p",
			["zoom"] = 0,
			["auto"] = true,
			["text2Enabled"] = false,
			["id"] = "Lightning Shield - Missing",
			["glow"] = false,
			["alpha"] = 1,
			["width"] = 60,
			["color"] = {
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
			["numTriggers"] = 1,
			["selfPoint"] = "CENTER",
			["conditions"] = {
			},
			["internalVersion"] = 6,
			["text2Font"] = "Friz Quadrata TT",
		},
	},
	["login_squelch_time"] = 10,
	["registered"] = {
	},
	["frame"] = {
		["xOffset"] = -1297.50042724609,
		["yOffset"] = -173.166625976563,
		["height"] = 492,
		["width"] = 630,
	},
	["editor_theme"] = "Monokai",
}
