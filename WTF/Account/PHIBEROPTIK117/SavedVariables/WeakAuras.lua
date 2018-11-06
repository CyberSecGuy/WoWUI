
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
	["minimap"] = {
		["hide"] = false,
	},
	["login_squelch_time"] = 10,
	["registered"] = {
	},
	["displays"] = {
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
			["glow"] = false,
			["text1Font"] = "Friz Quadrata TT",
			["internalVersion"] = 9,
			["text2Containment"] = "INSIDE",
			["glowType"] = "buttonOverlay",
			["text1Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["selfPoint"] = "CENTER",
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
				["finish"] = {
				},
				["init"] = {
				},
			},
			["text1FontFlags"] = "OUTLINE",
			["text2FontSize"] = 24,
			["color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
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
			["stickyDuration"] = false,
			["text2Font"] = "Friz Quadrata TT",
			["inverse"] = false,
			["parent"] = "Enhance Shaman",
			["conditions"] = {
			},
			["text1Containment"] = "INSIDE",
			["xOffset"] = 0,
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
				["class"] = {
					["single"] = "ROGUE",
					["multi"] = {
					},
				},
				["spec"] = {
					["single"] = 3,
					["multi"] = {
					},
				},
				["use_pvptalent"] = true,
				["size"] = {
					["multi"] = {
					},
				},
			},
			["zoom"] = 0,
			["desaturate"] = true,
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
						["use_genericShowOn"] = true,
						["use_targetRequired"] = true,
						["unit"] = "player",
						["use_absorbMode"] = true,
						["genericShowOn"] = "showOnReady",
						["use_unit"] = true,
						["realSpellName"] = "Cold Blood",
						["use_spellName"] = true,
						["unevent"] = "auto",
						["subeventSuffix"] = "_CAST_START",
						["use_inverse"] = true,
						["subeventPrefix"] = "SPELL",
						["event"] = "Cooldown Progress (Spell)",
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
			["text2Containment"] = "INSIDE",
			["glowType"] = "buttonOverlay",
			["text1Font"] = "Friz Quadrata TT",
			["text1Enabled"] = true,
			["text2Font"] = "Friz Quadrata TT",
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
			["text2"] = "%p",
			["auto"] = true,
			["cooldownTextEnabled"] = true,
			["id"] = "Cold Blood Buff",
			["glow"] = false,
			["frameStrata"] = 1,
			["anchorFrameType"] = "SCREEN",
			["text2Enabled"] = false,
			["uid"] = "7ChM(x)fpxV",
			["inverse"] = false,
			["stickyDuration"] = false,
			["conditions"] = {
			},
			["xOffset"] = 0,
			["icon"] = true,
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
			["stickyDuration"] = false,
			["text1Enabled"] = true,
			["internalVersion"] = 9,
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
			["parent"] = "Enhance Shaman",
			["text1Containment"] = "INSIDE",
			["text2FontSize"] = 24,
			["glow"] = false,
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
			["cooldownTextEnabled"] = true,
			["text1Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["inverse"] = false,
			["text2Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["conditions"] = {
			},
			["xOffset"] = 0,
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
			["xOffset"] = -145,
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
			["border"] = "None",
			["yOffset"] = -300,
			["anchorPoint"] = "CENTER",
			["scale"] = 1,
			["sort"] = "none",
			["regionType"] = "dynamicgroup",
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
			["backgroundInset"] = 0,
			["internalVersion"] = 9,
			["constantFactor"] = "RADIUS",
			["selfPoint"] = "LEFT",
			["align"] = "CENTER",
			["radius"] = 200,
			["frameStrata"] = 1,
			["anchorFrameType"] = "SCREEN",
			["rotation"] = 0,
			["borderOffset"] = 16,
			["stagger"] = 0,
			["id"] = "Enhance Shaman",
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
			["actions"] = {
				["start"] = {
				},
				["finish"] = {
				},
				["init"] = {
				},
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
			["text2"] = "%p",
			["parent"] = "Enhance Shaman",
			["actions"] = {
				["start"] = {
				},
				["finish"] = {
				},
				["init"] = {
				},
			},
			["text2Containment"] = "INSIDE",
			["glowType"] = "buttonOverlay",
			["text1Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["selfPoint"] = "CENTER",
			["text1Containment"] = "INSIDE",
			["text2Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["regionType"] = "icon",
			["xOffset"] = 0,
			["text1Font"] = "Friz Quadrata TT",
			["text2FontSize"] = 24,
			["glow"] = false,
			["text1"] = "%s",
			["width"] = 64,
			["alpha"] = 1,
			["zoom"] = 0,
			["auto"] = true,
			["text2Enabled"] = false,
			["id"] = "Flametounge",
			["stickyDuration"] = false,
			["frameStrata"] = 1,
			["anchorFrameType"] = "SCREEN",
			["text1FontFlags"] = "OUTLINE",
			["color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["inverse"] = false,
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
			["conditions"] = {
			},
			["internalVersion"] = 9,
			["text2Font"] = "Friz Quadrata TT",
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
			["stickyDuration"] = false,
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
			["xOffset"] = 0,
			["text2Containment"] = "INSIDE",
			["glowType"] = "buttonOverlay",
			["text1Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["text1Containment"] = "INSIDE",
			["internalVersion"] = 9,
			["text1FontFlags"] = "OUTLINE",
			["regionType"] = "icon",
			["text1Font"] = "Friz Quadrata TT",
			["text2Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["text2FontSize"] = 24,
			["cooldownTextEnabled"] = true,
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
			["glow"] = false,
			["color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["inverse"] = false,
			["selfPoint"] = "CENTER",
			["conditions"] = {
			},
			["text2Font"] = "Friz Quadrata TT",
			["actions"] = {
				["start"] = {
				},
				["init"] = {
				},
				["finish"] = {
				},
			},
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
			["stickyDuration"] = false,
			["text1Containment"] = "INSIDE",
			["xOffset"] = 0,
			["text2Containment"] = "INSIDE",
			["glowType"] = "buttonOverlay",
			["text1Color"] = {
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
			["internalVersion"] = 9,
			["text1FontFlags"] = "OUTLINE",
			["regionType"] = "icon",
			["text1Font"] = "Friz Quadrata TT",
			["text2Color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["text2FontSize"] = 24,
			["cooldownTextEnabled"] = true,
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
			["glow"] = false,
			["color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["inverse"] = false,
			["selfPoint"] = "CENTER",
			["conditions"] = {
			},
			["text2Font"] = "Friz Quadrata TT",
			["actions"] = {
				["start"] = {
				},
				["init"] = {
				},
				["finish"] = {
				},
			},
		},
	},
	["frame"] = {
		["xOffset"] = -1297.50042724609,
		["yOffset"] = -173.166625976563,
		["height"] = 492,
		["width"] = 630,
	},
	["editor_theme"] = "Monokai",
}
