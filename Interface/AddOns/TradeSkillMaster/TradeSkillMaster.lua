-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- This is the main TSM file that holds the majority of the APIs that modules will use.

local TSM = TSMAPI_FOUR.Addon.New(...)
TSM.old = {}
local LibRealmInfo = LibStub("LibRealmInfo")
local LibDBIcon = LibStub("LibDBIcon-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = { cachedConnectedRealms = nil, appInfo = nil }
TSMAPI = {Auction={}, GUI={}, Design={}, Debug={}, Item={}, ItemFilter={}, Conversions={}, Delay={}, Player={}, Inventory={}, Threading={}, Groups={}, Operations={}, Util={}, Settings={}, Class={}, Sync={}}
local APP_INFO_REQUIRED_KEYS = { "version", "lastSync", "addonVersions", "message", "news" }

TSM.designDefaults = {
	frameColors = {
		frameBG = { backdrop = { 24, 24, 24, .93 }, border = { 30, 30, 30, 1 } },
		frame = { backdrop = { 24, 24, 24, 1 }, border = { 255, 255, 255, 0.03 } },
		content = { backdrop = { 42, 42, 42, 1 }, border = { 0, 0, 0, 0 } },
	},
	textColors = {
		iconRegion = { enabled = { 249, 255, 247, 1 } },
		text = { enabled = { 255, 254, 250, 1 }, disabled = { 147, 151, 139, 1 } },
		label = { enabled = { 216, 225, 211, 1 }, disabled = { 150, 148, 140, 1 } },
		title = { enabled = { 132, 219, 9, 1 } },
		link = { enabled = { 49, 56, 133, 1 } },
	},
	inlineColors = {
		link = { 153, 255, 255, 1 },
		link2 = { 153, 255, 255, 1 },
		category = { 36, 106, 36, 1 },
		category2 = { 85, 180, 8, 1 },
		tooltip = { 130, 130, 250, 1 },
	},
	edgeSize = 1.5,
	fonts = {
		content = "Fonts\\ARIALN.TTF",
		bold = "Interface\\Addons\\TradeSkillMaster\\Media\\Montserrat-Bold.ttf",
	},
	fontSizes = {
		normal = 15,
		medium = 13,
		small = 12,
	},
}

-- Changelog:
-- [6] added 'global.locale' key
-- [7] changed default value of 'tsmItemTweetEnabled' to false
-- [8] added 'global.itemCacheVersion' key
-- [9] removed 'global.itemCacheVersion' key, added 'global.clientVersion' key
-- [10] first TSM4 version - combined all module settings into a single DB
-- [11] added profile.internalData.createdDefaultOperations
-- [12] added global.shoppingOptions.pctSource
-- [13] added profile.internalData.{managementGroupTreeContext,auctioningGroupTreeContext,shoppingGroupTreeContext}
-- [14] added global.userData.savedAuctioningSearches
-- [15] added global.coreOptions.bankUITab, profile.coreOptions.{bankUIBankFramePosition,bankUIGBankFramePosition}
-- [16] moved profile.coreOptions.{bankUIBankFramePosition,bankUIGBankFramePosition} to profile.internalData.{bankUIBankFramePosition,bankUIGBankFramePosition}
-- [17] added global.internalData.{mainUIFrameContext,auctionUIFrameContext,craftingUIFrameContext}
-- [18] removed global.internalData.itemStringLookup
-- [19] added sync scope (initially with internalData.{classKey,bagQuantity,bankQuantity,reagentBankQuantity,auctionQuantity,mailQuantity}), removed factionrealm.internalData.{syncMetadata,accountKey,inventory,characters} and factionrealm.coreOptions.syncAccounts, added global.debug.chatLoggingEnabled
-- [20] added global.tooltipOptions.enabled
-- [21] added global.craftingOptions.{profitPercent,questSmartCrafting,queueSort}
-- [22] added global.coreOptions.cleanGuildBank
-- [23] changed global.shoppingOptions.maxDeSearchPercent default to 100

local settingsInfo = {
	version = 23,
	global = {
		debug = {
			chatLoggingEnabled = { type = "boolean", default = false, lastModifiedVersion = 19 },
		},
		internalData = {
			vendorItems = { type = "table", default = {}, lastModifiedVersion = 10 },
			appMessageId = { type = "number", default = 0, lastModifiedVersion = 10 },
			destroyingHistory = { type = "table", default = {}, lastModifiedVersion = 10 },
			mainUIFrameContext = { type = "table", default = { width = 948, height = 757, centerX = 0, centerY = 0, page = 1 }, lastModifiedVersion = 17 },
			auctionUIFrameContext = { type = "table", default = { width = 830, height = 587, centerX = -300, centerY = 100, page = 1 }, lastModifiedVersion = 17 },
			craftingUIFrameContext = { type = "table", default = { width = 820, height = 587, centerX = -200, centerY = 0, page = 1 }, lastModifiedVersion = 17 },
			destroyingUIFrameContext = { type = "table", default = { width = 296, height = 442, centerX = 0, centerY = 0 }, lastModifiedVersion = 17 },
		},
		coreOptions = {
			globalOperations = { type = "boolean", default = false, lastModifiedVersion = 10 },
			chatFrame = { type = "string", default = "", lastModifiedVersion = 10 },
			auctionSaleEnabled = { type = "boolean", default = true, lastModifiedVersion = 10 },
			auctionSaleSound = { type = "string", default = TSM.CONST.NO_SOUND_KEY, lastModifiedVersion = 10 },
			auctionBuyEnabled = { type = "boolean", default = true, lastModifiedVersion = 10 },
			tsmItemTweetEnabled = { type = "boolean", default = false, lastModifiedVersion = 10 },
			moveDelay = { type = "number", default = 0, lastModifiedVersion = 10 },
			minimapIcon = { type = "table", default = { hide = false, minimapPos = 220, radius = 80 }, lastModifiedVersion = 10 },
			destroyValueSource = { type = "string", default = "dbmarket", lastModifiedVersion = 10 },
			bankUITab = { type = "string", default = "Warehousing", lastModifiedVersion = 15 },
		},
		accountingOptions = {
			trackTrades = { type = "boolean", default = true, lastModifiedVersion = 10 },
			autoTrackTrades = { type = "boolean", default = false, lastModifiedVersion = 10 },
			timeFormat = { type = "string", default = "ago", lastModifiedVersion = 10 },
			priceFormat = { type = "string", default = "avg", lastModifiedVersion = 10 },
			mvSource = { type = "string", default = "dbmarket", lastModifiedVersion = 10 },
			smartBuyPrice = { type = "boolean", default = false, lastModifiedVersion = 10 },
		},
		auctioningOptions = {
			cancelWithBid = { type = "boolean", default = false, lastModifiedVersion = 10 },
			disableInvalidMsg = { type = "boolean", default = false, lastModifiedVersion = 10 },
			roundNormalPrice = { type = "boolean", default = false, lastModifiedVersion = 10 },
			matchWhitelist = { type = "boolean", default = true, lastModifiedVersion = 10 },
			scanCompleteSound = { type = "string", default = TSM.CONST.NO_SOUND_KEY, lastModifiedVersion = 10 },
			confirmCompleteSound = { type = "string", default = TSM.CONST.NO_SOUND_KEY, lastModifiedVersion = 10 },
		},
		craftingOptions = {
			profitPercent = { type = "number", default = 5, lastModifiedVersion = 21 },
			questSmartCrafting = { type = "boolean", default = true, lastModifiedVersion = 21 },
			queueSort = { type = "number", default = 1, lastModifiedVersion = 21 },
			ignoreCDCraftCost = { type = "boolean", default = true, lastModifiedVersion = 10 },
			defaultMatCostMethod = { type = "string", default = "min(dbmarket, crafting, vendorbuy, convert(dbmarket))", lastModifiedVersion = 10 },
			defaultCraftPriceMethod = { type = "string", default = "first(dbminbuyout, dbmarket)", lastModifiedVersion = 10 },
			ignoreCharacters = { type = "table", default = {}, lastModifiedVersion = 10 },
			ignoreGuilds = { type = "table", default = {}, lastModifiedVersion = 10 },
		},
		destroyingOptions = {
			autoStack = { type = "boolean", default = true, lastModifiedVersion = 10 },
			includeSoulbound = { type = "boolean", default = false, lastModifiedVersion = 10 },
			autoShow = { type = "boolean", default = true, lastModifiedVersion = 10 },
			deMaxQuality = { type = "number", default = 3, lastModifiedVersion = 10 },
			deAbovePrice = { type = "string", default = "0c", lastModifiedVersion = 10 },
			logDays = { type = "number", default = 14, lastModifiedVersion = 10 },
			timeFormat = { type = "string", default = "ago", lastModifiedVersion = 10 },
		},
		mailingOptions = {
			defaultMailTab = { type = "boolean", default = true, lastModifiedVersion = 10 },
			autoCheck = { type = "boolean", default = true, lastModifiedVersion = 10 },
			displayMoneyCollected = { type = "boolean", default = true, lastModifiedVersion = 10 },
			sendItemsIndividually = { type = "boolean", default = false, lastModifiedVersion = 10 },
			deleteEmptyNPCMail = { type = "boolean", default = false, lastModifiedVersion = 10 },
			inboxMessages = { type = "boolean", default = true, lastModifiedVersion = 10 },
			sendMessages = { type = "boolean", default = true, lastModifiedVersion = 10 },
			showReloadBtn = { type = "boolean", default = true, lastModifiedVersion = 10 },
			resendDelay = { type = "number", default = 1, lastModifiedVersion = 10 },
			sendDelay = { type = "number", default = 0.5, lastModifiedVersion = 10 },
			defaultPage = { type = "number", default = 1, lastModifiedVersion = 10 },
			keepMailSpace = { type = "number", default = 0, lastModifiedVersion = 10 },
			deMaxQuality = { type = "number", default = 2, lastModifiedVersion = 10 },
			openMailSound = { type = "string", default = TSM.CONST.NO_SOUND_KEY, lastModifiedVersion = 10 },
		},
		shoppingOptions = {
			minDeSearchLvl = { type = "number", default = 1, lastModifiedVersion = 10 },
			maxDeSearchLvl = { type = "number", default = 735, lastModifiedVersion = 10 },
			maxDeSearchPercent = { type = "number", default = 100, lastModifiedVersion = 23 },
			pctSource  = { type = "string", default = "dbmarket", lastModifiedVersion = 12 },
		},
		sniperOptions = {
			sniperSound = { type = "string", default = TSM.CONST.NO_SOUND_KEY, lastModifiedVersion = 10 },
		},
		vendoringOptions = {
			displayMoneyCollected = { type = "boolean", default = false, lastModifiedVersion = 10 },
			defaultMerchantTab = { type = "boolean", default = false, lastModifiedVersion = 10 },
			autoSellTrash = { type = "boolean", default = false, lastModifiedVersion = 10 },
			qsHideGrouped = { type = "boolean", default = true, lastModifiedVersion = 10 },
			qsHideSoulbound = { type = "boolean", default = true, lastModifiedVersion = 10 },
			qsBatchSize = { type = "number", default = 12, lastModifiedVersion = 10 },
			defaultPage = { type = "number", default = 1, lastModifiedVersion = 10 },
			qsMarketValue = { type = "string", default = "dbmarket", lastModifiedVersion = 10 },
			qsMaxMarketValue = { type = "string", default = "100g", lastModifiedVersion = 10 },
			qsDestroyValue = { type = "string", default = "destroy", lastModifiedVersion = 10 },
			qsMaxDestroyValue = { type = "string", default = "100g", lastModifiedVersion = 10 },
		},
		tooltipOptions = {
			enabled = { type = "boolean", default = true, lastModifiedVersion = 20 },
			embeddedTooltip = { type = "boolean", default = true, lastModifiedVersion = 10 },
			customPriceTooltips = { type = "table", default = {}, lastModifiedVersion = 10 },
			moduleTooltips = { type = "table", default = {}, lastModifiedVersion = 10 },
			vendorBuyTooltip = { type = "boolean", default = true, lastModifiedVersion = 10 },
			vendorSellTooltip = { type = "boolean", default = true, lastModifiedVersion = 10 },
			groupNameTooltip = { type = "boolean", default = true, lastModifiedVersion = 10 },
			detailedDestroyTooltip = { type = "boolean", default = false, lastModifiedVersion = 10 },
			millTooltip = { type = "boolean", default = true, lastModifiedVersion = 10 },
			prospectTooltip = { type = "boolean", default = true, lastModifiedVersion = 10 },
			deTooltip = { type = "boolean", default = true, lastModifiedVersion = 10 },
			transformTooltip = { type = "boolean", default = true, lastModifiedVersion = 10 },
			operationTooltips = { type = "table", default = {}, lastModifiedVersion = 10 },
			tooltipShowModifier = { type = "string", default = "none", lastModifiedVersion = 10 },
			inventoryTooltipFormat = { type = "string", default = "full", lastModifiedVersion = 10 },
			tooltipPriceFormat = { type = "string", default = "text", lastModifiedVersion = 10 },
		},
		userData = {
			operations = { type = "table", default = {}, lastModifiedVersion = 10 },
			customPriceSources = { type = "table", default = {}, lastModifiedVersion = 10 },
			destroyingIgnore = { type = "table", default = {}, lastModifiedVersion = 10 },
			savedShoppingSearches = { type = "table", default = {}, lastModifiedVersion = 10 },
			vendoringIgnore = { type = "table", default = {}, lastModifiedVersion = 10 },
			savedAuctioningSearches = { type = "table", default = {}, lastModifiedVersion = 14 },
		},
	},
	profile = {
		internalData = {
			createdDefaultOperations = { type = "boolean", default = false, lastModifiedVersion = 11 },
			managementGroupTreeContext = { type = "table", default = {}, lastModifiedVersion = 13 },
			auctioningGroupTreeContext = { type = "table", default = {}, lastModifiedVersion = 13 },
			shoppingGroupTreeContext = { type = "table", default = {}, lastModifiedVersion = 13 },
			bankUIBankFramePosition = { type = "table", default = { 100, 300 }, lastModifiedVersion = 16 },
			bankUIGBankFramePosition = { type = "table", default = { 100, 300 }, lastModifiedVersion = 16 },
		},
		userData = {
			groups = { type = "table", default = {}, lastModifiedVersion = 10 },
			items = { type = "table", default = {}, lastModifiedVersion = 10 },
			operations = { type = "table", default = {}, lastModifiedVersion = 10 },
		},
		coreOptions = {
			cleanBags = { type = "boolean", default = false, lastModifiedVersion = 10 },
			cleanBank = { type = "boolean", default = false, lastModifiedVersion = 10 },
			cleanReagentBank = { type = "boolean", default = false, lastModifiedVersion = 10 },
			cleanGuildBank = { type = "boolean", default = false, lastModifiedVersion = 22 },
		},
	},
	factionrealm = {
		internalData = {
			characterGuilds = { type = "table", default = {}, lastModifiedVersion = 10 },
			guildVaults = { type = "table", default = {}, lastModifiedVersion = 10 },
			pendingMail = { type = "table", default = {}, lastModifiedVersion = 10 },
			playerProfessions = { type = "table", default = {}, lastModifiedVersion = 10 },
			gathering = { type = "table", default = { crafter = nil, professions = {}, neededMats = {}, shortItems = {}, availableMats = {}, extraMats = {}, selectedSources = {}, selectedSourceStatus = {}, gatheredMats = false, destroyingMats = {}, sessionOptions = {} }, lastModifiedVersion = 10 },
			crafts = { type = "table", default = {}, lastModifiedVersion = 10 },
			mats = { type = "table", default = {}, lastModifiedVersion = 10 },
		},
		coreOptions = {
			ignoreGuilds = { type = "table", default = {}, lastModifiedVersion = 10 },
		},
		auctioningOptions = {
			whitelist = { type = "table", default = {}, lastModifiedVersion = 10 },
		},
	},
	realm = {
		internalData = {
			csvSales = { type = "string", default = "", lastModifiedVersion = 10 },
			csvBuys = { type = "string", default = "", lastModifiedVersion = 10 },
			csvIncome = { type = "string", default = "", lastModifiedVersion = 10 },
			csvExpense = { type = "string", default = "", lastModifiedVersion = 10 },
			csvExpired = { type = "string", default = "", lastModifiedVersion = 10 },
			csvCancelled = { type = "string", default = "", lastModifiedVersion = 10 },
			saveTimeSales = { type = "string", default = "", lastModifiedVersion = 10 },
			saveTimeBuys = { type = "string", default = "", lastModifiedVersion = 10 },
			saveTimeExpires = { type = "string", default = "", lastModifiedVersion = 10 },
			saveTimeCancels = { type = "string", default = "", lastModifiedVersion = 10 },
			goldLog = { type = "table", default = {}, lastModifiedVersion = 10 },
			accountingTrimmed = { type = "table", default = {}, lastModifiedVersion = 10 },
			lastAuctionDBSaveTime = { type = "number", default = 0, lastModifiedVersion = 10 },
			lastAuctionDBCompleteScan = { type = "number", default = 0, lastModifiedVersion = 10 },
			auctionDBScanData = { type = "string", default = "", lastModifiedVersion = 10 },
		},
	},
	char = {
		internalData = {
			auctionPrices = { type = "table", default = {}, lastModifiedVersion = 10 },
			auctionMessages = { type = "table", default = {}, lastModifiedVersion = 10 },
		},
	},
	sync = {
		-- NOTE: whenever these are changed, the sync version needs to be increased in Core/Lib/Sync/Core.lua
		internalData = {
			classKey = { type = "string", default = "", lastModifiedVersion = 19 },
			bagQuantity = { type = "table", default = {}, lastModifiedVersion = 19 },
			bankQuantity = { type = "table", default = {}, lastModifiedVersion = 19 },
			reagentBankQuantity = { type = "table", default = {}, lastModifiedVersion = 19 },
			auctionQuantity = { type = "table", default = {}, lastModifiedVersion = 19 },
			mailQuantity = { type = "table", default = {}, lastModifiedVersion = 19 },
		},
	},
}



-- ============================================================================
-- Module Functions
-- ============================================================================

function TSM.OnInitialize()
	-- create setting migration table
	TradeSkillMasterModulesDB = TradeSkillMasterModulesDB or {}
	for _, moduleName in ipairs(TSM.CONST.OLD_TSM_MODULES) do
		moduleName = gsub(moduleName, "TradeSkillMaster_", "")
		TradeSkillMasterModulesDB[moduleName] = TradeSkillMasterModulesDB[moduleName] or {}
	end

	private.LoadDeprecatedTSMAPIs()

	-- load settings
	local upgradeObj = TSM:LoadSettings("TradeSkillMasterDB", settingsInfo)
	if upgradeObj then
		local prevVersion = upgradeObj:GetPrevVersion()
		if prevVersion < 10 then
			-- migrate all the old settings to their new namespaces
			for key, value in upgradeObj:RemovedSettingIterator() do
				local scopeType, scopeKey, _, settingKey = upgradeObj:GetKeyInfo(key)
				for namespace, namespaceInfo in pairs(settingsInfo[scopeType]) do
					if namespaceInfo[settingKey] then
						TSM.db:Set(scopeType, scopeKey, namespace, settingKey, value)
					end
				end
			end
			-- migrade all old module settings into the core settings
			local MIGRATION_INFO = {
				Accounting = {
					["global.trackTrades"] = "global.accountingOptions.trackTrades",
					["global.autoTrackTrades"] = "global.accountingOptions.autoTrackTrades",
					["global.timeFormat"] = "global.accountingOptions.timeFormat",
					["global.priceFormat"] = "global.accountingOptions.priceFormat",
					["global.mvSource"] = "global.accountingOptions.mvSource",
					["realm.csvSales"] = "realm.internalData.csvSales",
					["realm.csvBuys"] = "realm.internalData.csvBuys",
					["realm.csvIncome"] = "realm.internalData.csvIncome",
					["realm.csvExpense"] = "realm.internalData.csvExpense",
					["realm.csvExpired"] = "realm.internalData.csvExpired",
					["realm.csvCancelled"] = "realm.internalData.csvCancelled",
					["realm.saveTimeSales"] = "realm.internalData.saveTimeSales",
					["realm.saveTimeBuys"] = "realm.internalData.saveTimeBuys",
					["realm.saveTimeExpires"] = "realm.internalData.saveTimeExpires",
					["realm.saveTimeCancels"] = "realm.internalData.saveTimeCancels",
					["realm.goldLog"] = "realm.internalData.goldLog",
					["realm.accountingTrimmed"] = "realm.internalData.accountingTrimmed",
				},
				Auctioning = {
					["global.cancelWithBid"] = "global.auctioningOptions.cancelWithBid",
					["global.disableInvalidMsg"] = "global.auctioningOptions.disableInvalidMsg",
					["global.roundNormalPrice"] = "global.auctioningOptions.roundNormalPrice",
					["global.matchWhitelist"] = "global.auctioningOptions.matchWhitelist",
					["global.scanCompleteSound"] = "global.auctioningOptions.scanCompleteSound",
					["global.confirmCompleteSound"] = "global.auctioningOptions.confirmCompleteSound",
					["factionrealm.whitelist"] = "factionrealm.auctioningOptions.whitelist",
				},
				Crafting = {
					["global.questSmartCrafting"] = "global.craftingOptions.questSmartCrafting",
					["global.queueSort"] = "global.craftingOptions.queueSort", 
					["global.ignoreCDCraftCost"] = "global.craftingOptions.ignoreCDCraftCost",
					["global.defaultMatCostMethod"] = "global.craftingOptions.defaultMatCostMethod",
					["global.defaultCraftPriceMethod"] = "global.craftingOptions.defaultCraftPriceMethod",
					["global.ignoreCharacters"] = "global.craftingOptions.ignoreCharacters",
					["global.ignoreGuilds"] = "global.craftingOptions.ignoreGuilds",
					["factionrealm.playerProfessions"] = "factionrealm.internalData.playerProfessions",
					["factionrealm.gathering"] = "factionrealm.internalData.gathering",
					["factionrealm.crafts"] = "factionrealm.internalData.crafts",
					["factionrealm.mats"] = "factionrealm.internalData.mats",
				},
				Destroying = {
					["global.history"] = "global.internalData.destroyingHistory",
					["global.autoStack"] = "global.destroyingOptions.autoStack",
					["global.includeSoulbound"] = "global.destroyingOptions.includeSoulbound",
					["global.autoShow"] = "global.destroyingOptions.autoShow",
					["global.deMaxQuality"] = "global.destroyingOptions.deMaxQuality",
					["global.deAbovePrice"] = "global.destroyingOptions.deAbovePrice",
					["global.logDays"] = "global.destroyingOptions.logDays",
					["global.timeFormat"] = "global.destroyingOptions.timeFormat",
					["global.ignore"] = "global.userData.destroyingIgnore",
				},
				Mailing = {
					["global.defaultMailTab"] = "global.mailingOptions.defaultMailTab",
					["global.autoCheck"] = "global.mailingOptions.autoCheck",
					["global.displayMoneyCollected"] = "global.mailingOptions.displayMoneyCollected",
					["global.sendItemsIndividually"] = "global.mailingOptions.sendItemsIndividually",
					["global.deleteEmptyNPCMail"] = "global.mailingOptions.deleteEmptyNPCMail",
					["global.inboxMessages"] = "global.mailingOptions.inboxMessages",
					["global.sendMessages"] = "global.mailingOptions.sendMessages",
					["global.showReloadBtn"] = "global.mailingOptions.showReloadBtn",
					["global.resendDelay"] = "global.mailingOptions.resendDelay",
					["global.sendDelay"] = "global.mailingOptions.sendDelay",
					["global.defaultPage"] = "global.mailingOptions.defaultPage",
					["global.keepMailSpace"] = "global.mailingOptions.keepMailSpace",
					["global.deMaxQuality"] = "global.mailingOptions.deMaxQuality",
					["global.openMailSound"] = "global.mailingOptions.openMailSound",
				},
				Shopping = {
					["global.minDeSearchLvl"] = "global.shoppingOptions.minDeSearchLvl",
					["global.maxDeSearchLvl"] = "global.shoppingOptions.maxDeSearchLvl",
					["global.maxDeSearchPercent"] = "global.shoppingOptions.maxDeSearchPercent",
					["global.sniperSound"] = "global.sniperOptions.sniperSound",
					["global.savedSearches"] = "global.userData.savedShoppingSearches",
				},
				Vendoring = {
					["global.displayMoneyCollected"] = "global.vendoringOptions.displayMoneyCollected",
					["global.defaultMerchantTab"] = "global.vendoringOptions.defaultMerchantTab",
					["global.autoSellTrash"] = "global.vendoringOptions.autoSellTrash",
					["global.qsHideGrouped"] = "global.vendoringOptions.qsHideGrouped",
					["global.qsHideSoulbound"] = "global.vendoringOptions.qsHideSoulbound",
					["global.qsBatchSize"] = "global.vendoringOptions.qsBatchSize",
					["global.defaultPage"] = "global.vendoringOptions.defaultPage",
					["global.qsMarketValue"] = "global.vendoringOptions.qsMarketValue",
					["global.qsMaxMarketValue"] = "global.vendoringOptions.qsMaxMarketValue",
					["global.qsDestroyValue"] = "global.vendoringOptions.qsDestroyValue",
					["global.qsMaxDestroyValue"] = "global.vendoringOptions.qsMaxDestroyValue",
					["global.ignore"] = "global.userData.vendoringIgnore",
				},
			}
			for module, migrations in pairs(MIGRATION_INFO) do
				for key, value in pairs(TradeSkillMasterModulesDB[module]) do
					if strsub(key, 1, 1) ~= "_" then
						local scopeType, scopeKey, _, settingKey = upgradeObj:GetKeyInfo(key)
						local oldPath = strjoin(".", scopeType, settingKey)
						local newPath = migrations[oldPath]
						if newPath then
							local newScopeType, newNamespace, newSettingKey = strsplit(".", newPath)
							assert(newScopeType == scopeType)
							TSM.db:Set(newScopeType, scopeKey, newNamespace, newSettingKey, value)
						end
					end
				end
			end
		end
		if prevVersion < 19 then
			-- migrate inventory data to the sync scope
			local oldInventoryData = TSMAPI_FOUR.Util.AcquireTempTable()
			local oldSyncMetadata = TSMAPI_FOUR.Util.AcquireTempTable()
			local oldAccountKey = TSMAPI_FOUR.Util.AcquireTempTable()
			local oldCharacters = TSMAPI_FOUR.Util.AcquireTempTable()
			for key, value in upgradeObj:RemovedSettingIterator() do
				local scopeType, scopeKey, namespace, settingKey = upgradeObj:GetKeyInfo(key)
				if scopeType == "factionrealm" then
					if settingKey == "inventory" then
						oldInventoryData[scopeKey] = value
					elseif settingKey == "syncMetadata" then
						oldSyncMetadata[scopeKey] = value
					elseif settingKey == "accountKey" then
						oldAccountKey[scopeKey] = value
					elseif settingKey == "characters" then
						oldCharacters[scopeKey] = value
					end
				end
			end
			for factionrealm, characters in pairs(oldInventoryData) do
				local syncMetadata = oldSyncMetadata[factionrealm] and oldSyncMetadata[factionrealm].TSM_CHARACTERS
				for character, inventoryData in pairs(characters) do
					if not syncMetadata or not syncMetadata[character] or syncMetadata[character].owner == oldAccountKey[factionrealm] then
						TSM.db:NewSyncCharacter(character, TSM.db:GetSyncAccountKey(factionrealm), factionrealm)
						local syncScopeKey = TSM.db:GetSyncScopeKeyByCharacter(character, factionrealm)
						local class = oldCharacters[factionrealm] and oldCharacters[factionrealm][character]
						if type(class) == "string" then
							TSM.db:Set("sync", syncScopeKey, "internalData", "classKey", class)
						end
						TSM.db:Set("sync", syncScopeKey, "internalData", "bagQuantity", inventoryData.bag)
						TSM.db:Set("sync", syncScopeKey, "internalData", "bankQuantity", inventoryData.bank)
						TSM.db:Set("sync", syncScopeKey, "internalData", "reagentBankQuantity", inventoryData.reagentBank)
						TSM.db:Set("sync", syncScopeKey, "internalData", "auctionQuantity", inventoryData.auction)
						TSM.db:Set("sync", syncScopeKey, "internalData", "mailQuantity", inventoryData.mail)
					end
				end
			end
			TSMAPI_FOUR.Util.ReleaseTempTable(oldInventoryData)
			TSMAPI_FOUR.Util.ReleaseTempTable(oldSyncMetadata)
			TSMAPI_FOUR.Util.ReleaseTempTable(oldAccountKey)
			TSMAPI_FOUR.Util.ReleaseTempTable(oldCharacters)
		end
	end

	-- store the class of this character
	TSM.db.sync.internalData.classKey = select(2, UnitClass("player"))

	if TSM.db.global.coreOptions.globalOperations then
		TSM.operations = TSM.db.global.userData.operations
	else
		TSM.operations = TSM.db.profile.userData.operations
	end

	-- TSM core must be registered just like the modules
	TSM:RegisterModule()

	-- create / register the minimap button
	local dataObj = LibStub("LibDataBroker-1.1"):NewDataObject("TradeSkillMaster", {
		type = "launcher",
		icon = "Interface\\Addons\\TradeSkillMaster\\Media\\TSM_Icon2",
		OnClick = function(_, button)
			if button ~= "LeftButton" then return end
			TSM.MainUI.Toggle()
		end,
		OnTooltipShow = function(tooltip)
			local cs = "|cffffffcc"
			local ce = "|r"
			tooltip:AddLine("TradeSkillMaster " .. TSM:GetVersion())
			tooltip:AddLine(format(L["%sLeft-Click%s to open the main window"], cs, ce))
			tooltip:AddLine(format(L["%sDrag%s to move this button"], cs, ce))
		end,
	})
	LibDBIcon:Register("TradeSkillMaster", dataObj, TSM.db.global.coreOptions.minimapIcon)

	-- cache battle pet names
	for i = 1, C_PetJournal.GetNumPets() do
		C_PetJournal.GetPetInfoByIndex(i)
	end

	-- force a garbage collection
	collectgarbage()
end

function TSM.OnEnable()
	-- disable old TSM modules
	local didDisable = false
	for _, name in ipairs(TSM.CONST.OLD_TSM_MODULES) do
		if TSMAPI_FOUR.Util.IsAddonEnabled(name) then
			didDisable = true
			DisableAddOn(name, true)
		end
	end
	if didDisable then
		StaticPopupDialogs["TSM_OLD_MODULE_DISABLE"] = StaticPopupDialogs["TSM_OLD_MODULE_DISABLE"] or {
			text = L["Old TSM addons detected. TSM has disabled them and requires a reload."],
			button1 = L["Reload"],
			timeout = 0,
			whileDead = true,
			OnAccept = ReloadUI,
		}
		TSMAPI_FOUR.Util.ShowStaticPopupDialog("TSM_OLD_MODULE_DISABLE")
	else
		TradeSkillMasterModulesDB = nil
	end

	TSM.LoadAppData()
end

function TSM.LoadAppData()
	if not TSMAPI_FOUR.Util.IsAddonInstalled("TradeSkillMaster_AppHelper") then
		-- TSM_AppHelper is not installed
		-- TODO: remove this popup at the end of the beta (or make it show less often)
		StaticPopupDialogs["TSM_APP_DATA_ERROR"] = {
			text = L["The TradeSkillMaster_AppHelper addon is not installed and is required for proper operation of TSM."],
			button1 = OKAY,
			timeout = 0,
			whileDead = true,
		}
		TSMAPI_FOUR.Util.ShowStaticPopupDialog("TSM_APP_DATA_ERROR")
		return
	end

	if not TSMAPI_FOUR.Util.IsAddonEnabled("TradeSkillMaster_AppHelper") then
		-- TSM_AppHelper is disabled
		StaticPopupDialogs["TSM_APP_DATA_ERROR"] = {
			text = L["The TradeSkillMaster_AppHelper addon is not enabled and is required for proper operation of TSM. TSM has enabled it and requires a reload."],
			button1 = L["Reload"],
			timeout = 0,
			whileDead = true,
			OnAccept = function()
				EnableAddOn("TradeSkillMaster_AppHelper")
				ReloadUI()
			end,
		}
		TSMAPI_FOUR.Util.ShowStaticPopupDialog("TSM_APP_DATA_ERROR")
		return
	end

	assert(TSMAPI.AppHelper)
	local appInfo = TSMAPI.AppHelper:FetchData("APP_INFO")
	if not appInfo then
		-- The app hasn't run yet or isn't pointing at the right WoW directory
		StaticPopupDialogs["TSM_APP_DATA_ERROR"] = {
			text = L["TSM is missing important information from the TSM Desktop Application. Please ensure the TSM Desktop Application is running and is properly configured."],
			button1 = OKAY,
			timeout = 0,
			whileDead = true,
		}
		TSMAPI_FOUR.Util.ShowStaticPopupDialog("TSM_APP_DATA_ERROR")
		return
	end

	-- load the app info
	assert(#appInfo == 1 and #appInfo[1] == 2 and appInfo[1][1] == "Global")
	private.appInfo = assert(loadstring(appInfo[1][2]))()
	for _, key in ipairs(APP_INFO_REQUIRED_KEYS) do
		assert(private.appInfo[key])
	end

	if private.appInfo.message and private.appInfo.message.id > TSM.db.global.internalData.appMessageId then
		-- show the message from the app
		TSM.db.global.internalData.appMessageId = private.appInfo.message.id
		StaticPopupDialogs["TSM_APP_MESSAGE"] = {
			text = private.appInfo.message.msg,
			button1 = OKAY,
			timeout = 0,
		}
		TSMAPI.Util:ShowStaticPopupDialog("TSM_APP_MESSAGE")
	end

	if time() - private.appInfo.lastSync > 60 * 60 then
		-- the app hasn't been running for over an hour
		StaticPopupDialogs["TSM_APP_DATA_ERROR"] = {
			text = L["TSM is missing important information from the TSM Desktop Application. Please ensure the TSM Desktop Application is running and is properly configured."],
			button1 = OKAY,
			timeout = 0,
			whileDead = true,
		}
		TSMAPI_FOUR.Util.ShowStaticPopupDialog("TSM_APP_DATA_ERROR")
	end
end

function TSM:RegisterModule()
	-- Our price sources
	TSM:RegisterPriceSource("VendorBuy", L["Buy from Vendor"], TSMAPI_FOUR.Item.GetVendorBuy)
	TSM:RegisterPriceSource("VendorSell", L["Sell to Vendor"], TSMAPI_FOUR.Item.GetVendorSell)
	TSM:RegisterPriceSource("Destroy", L["Destroy Value"], function(itemString) return TSMAPI_FOUR.Conversions.GetValue(itemString, TSM.db.global.coreOptions.destroyValueSource) end)
	TSM:RegisterPriceSource("ItemQuality", L["Item Quality"], TSMAPI_FOUR.Item.GetQuality)
	TSM:RegisterPriceSource("ItemLevel", L["Item Level"], TSMAPI_FOUR.Item.GetItemLevel)
	TSM:RegisterPriceSource("RequiredLevel", L["Required Level"], TSMAPI_FOUR.Item.GetMinLevel)

	-- Auctioneer price sources
	if TSMAPI_FOUR.Util.IsAddonEnabled("Auc-Advanced") and AucAdvanced then
		if AucAdvanced.Modules.Util.Appraiser and AucAdvanced.Modules.Util.Appraiser.GetPrice then
			TSM:RegisterPriceSource("AucAppraiser", L["Auctioneer - Appraiser"], AucAdvanced.Modules.Util.Appraiser.GetPrice)
		end
		if AucAdvanced.Modules.Util.SimpleAuction and AucAdvanced.Modules.Util.SimpleAuction.Private.GetItems then
			local function GetAucMinBuyout(itemLink)
				return select(6, AucAdvanced.Modules.Util.SimpleAuction.Private.GetItems(itemLink)) or nil
			end
			TSM:RegisterPriceSource("AucMinBuyout", L["Auctioneer - Minimum Buyout"], GetAucMinBuyout)
		end
		if AucAdvanced.API.GetMarketValue then
			TSM:RegisterPriceSource("AucMarket", L["Auctioneer - Market Value"], AucAdvanced.API.GetMarketValue)
		end
	end

	-- Auctionator price sources
	if TSMAPI_FOUR.Util.IsAddonEnabled("Auctionator") and Atr_GetAuctionBuyout then
		TSM:RegisterPriceSource("AtrValue", L["Auctionator - Auction Value"], Atr_GetAuctionBuyout, true)
	end

	-- CostBasis price sources
	if TSMAPI_FOUR.Util.IsAddonEnabled("CostBasis") then
		local function GetCBPrice(itemLink)
			local CB = LibStub("AceAddon-3.0"):GetAddon("CostBasis", true)
			return CB and CB:QueryItem(itemLink) or nil
		end
		TSM:RegisterPriceSource("CostBasis", L["CostBasis"], GetCBPrice, true)
	end

	-- TheUndermineJournal price sources
	if TSMAPI_FOUR.Util.IsAddonEnabled("TheUndermineJournal") and TUJMarketInfo then
		local function GetTUJPrice(itemLink, arg)
			local data = TUJMarketInfo(itemLink)
			return data and data[arg] or nil
		end
		TSM:RegisterPriceSource("TUJRecent", L["TUJ 3-Day Price"], GetTUJPrice, true, "recent")
		TSM:RegisterPriceSource("TUJMarket", L["TUJ 14-Day Price"], GetTUJPrice, true, "market")
		TSM:RegisterPriceSource("TUJGlobalMean", L["TUJ Global Mean"], GetTUJPrice, true, "globalMean")
		TSM:RegisterPriceSource("TUJGlobalMedian", L["TUJ Global Median"], GetTUJPrice, true, "globalMedian")
	end

	TSM:RegisterSlashCommand("version", TSM.Modules.PrintVersions, L["Prints out the version numbers of all installed modules"])
	TSM:RegisterSlashCommand("freset", TSM.GUI.ResetFrames, L["Resets the position, scale, and size of all applicable TSM and module frames"])
	TSM:RegisterSlashCommand("bankui", TSM.toggleBankUI, L["Toggles the BankUI"])
	TSM:RegisterSlashCommand("sources", TSM.CustomPrice.PrintSources, L["Prints out the available price sources for use in custom prices"])
	TSM:RegisterSlashCommand("price", private.TestPriceSource, L["Allows for testing of custom prices"])
	TSM:RegisterSlashCommand("profile", private.ChangeProfile, L["Changes to the specified profile (i.e. '/tsm profile Default' changes to the 'Default' profile)"])
	TSM:RegisterSlashCommand("debug", private.DebugSlashCommandHandler)
	TSM:RegisterSlashCommand("destroy", TSM.UI.DestroyingUI.Toggle, L["Opens the Destroying frame if there's stuff in your bags to be destroyed."])
	TSM:RegisterSlashCommand("crafting", TSM.UI.CraftingUI.Toggle)
	TSM:RegisterSlashCommand("tasklist4", TSM.UI.TaskListUI.Toggle)

	TSMAPI_FOUR.Modules.Register(TSM)
end

function TSM:OnTSMDBShutdown(appDB)
	if not appDB then return end

	-- store region
	local region = TSMAPI:GetRegion()
	appDB.region = region

	-- save errors
	TSM.SaveErrorReports(appDB)

	local function GetShoppingMaxPrice(itemString, groupPath)
		local operationName = TSM.db.profile.userData.groups[groupPath].Shopping[1]
		if not operationName or operationName == "" or TSM.Modules:IsOperationIgnored("Shopping", operationName) then return end
		local operation = TSM.operations.Shopping[operationName]
		if not operation or type(operation.maxPrice) ~= "string" then return end
		local value = TSMAPI:GetCustomPriceValue(operation.maxPrice, itemString)
		if not value or value <= 0 then return end
		return value
	end

	-- save TSM_Shopping max prices in the app DB
	if TSM.operations.Shopping then
		appDB.shoppingMaxPrices = {}
		for profile in TSMAPI:GetTSMProfileIterator() do
			local profileGroupData = {}
			for itemString, groupPath in pairs(TSM.db.profile.userData.items) do
				local itemId = tonumber(strmatch(itemString, "^i:([0-9]+)$"))
				if itemId and TSM.db.profile.userData.groups[groupPath] and TSM.db.profile.userData.groups[groupPath].Shopping then
					local maxPrice = GetShoppingMaxPrice(itemString, groupPath)
					if maxPrice then
						if not profileGroupData[groupPath] then
							profileGroupData[groupPath] = {}
						end
						tinsert(profileGroupData[groupPath], "["..table.concat({itemId, maxPrice}, ",").."]")
					end
				end
			end
			if next(profileGroupData) then
				appDB.shoppingMaxPrices[profile] = {}
				for groupPath, data in pairs(profileGroupData) do
					appDB.shoppingMaxPrices[profile][groupPath] = "["..table.concat(data, ",").."]"
				end
				appDB.shoppingMaxPrices[profile].updateTime = time()
			end
		end
	end

	-- save black market data
	local realmName = GetRealmName()
	appDB.blackMarket = appDB.blackMarket or {}
	if TSM.Features.blackMarket then
		local hash = TSMAPI_FOUR.Util.CalculateHash(TSM.Features.blackMarket..":"..TSM.Features.blackMarketTime)
		appDB.blackMarket[realmName] = {data=TSM.Features.blackMarket, key=hash, updateTime=TSM.Features.blackMarketTime}
	end

	-- save analytics
	TSM.SaveAnalytics(appDB)
end



-- ============================================================================
-- TSM Tooltip Handling
-- ============================================================================

function TSM:LoadTooltip(itemString, quantity, moneyCoins, lines)
	local numStartingLines = #lines

	-- add group / operation info
	if TSM.db.global.tooltipOptions.groupNameTooltip then
		local isBaseItem
		local path = TSM.db.profile.userData.items[itemString]
		if not path then
			path = TSM.db.profile.userData.items[TSMAPI.Item:ToBaseItemString(itemString)]
			isBaseItem = true
		end
		if path and TSM.db.profile.userData.groups[path] then
			local leftText = nil
			if isBaseItem then
				leftText = L["Group(Base Item):"]
			else
				leftText = L["Group:"]
			end
			tinsert(lines, {left="  "..leftText, right = "|cffffffff"..TSMAPI.Groups:FormatPath(path).."|r"})
			local modules = {}
			for module, operations in pairs(TSM.db.profile.userData.groups[path]) do
				if operations[1] and operations[1] ~= "" and TSM.db.global.tooltipOptions.operationTooltips[module] then
					tinsert(modules, {module=module, operations=table.concat(operations, ", ")})
				end
			end
			sort(modules, function(a, b) return a.module < b.module end)
			for _, info in ipairs(modules) do
				tinsert(lines, {left="  "..format(L["%s operation(s):"], info.module), right="|cffffffff"..info.operations.."|r"})
			end
		end
	end

	-- add disenchant value info
	if TSM.db.global.tooltipOptions.deTooltip then
		local value = TSMAPI.Conversions:GetValue(itemString, TSM.db.global.coreOptions.destroyValueSource, "disenchant")
		if value then
			local leftText = "  "..(quantity > 1 and format(L["Disenchant Value x%s:"], quantity) or L["Disenchant Value:"])
			tinsert(lines, {left=leftText, right=TSMAPI:MoneyToString(value*quantity, "|cffffffff", "OPT_PAD", moneyCoins and "OPT_ICON" or nil)})
			if TSM.db.global.tooltipOptions.detailedDestroyTooltip then
				local rarity = TSMAPI.Item:GetQuality(itemString)
				local ilvl = TSMAPI.Item:GetItemLevel(itemString)
				local iType = GetItemClassInfo(TSMAPI.Item:GetClassId(itemString))
				for _, data in ipairs(TSM.CONST.DISENCHANT_INFO) do
					for targetItem, itemData in pairs(data) do
						if targetItem ~= "desc" then
							for _, deData in ipairs(itemData.sourceInfo) do
								if deData.itemType == iType and deData.rarity == rarity and ilvl >= deData.minItemLevel and ilvl <= deData.maxItemLevel then
									local matValue = (TSMAPI:GetCustomPriceValue(TSM.db.global.coreOptions.destroyValueSource, targetItem) or 0) * deData.amountOfMats
									local matQuality = TSMAPI.Item:GetQuality(targetItem)
									if matQuality and matValue > 0 then
										local colorName = format("|c%s%s x %s|r", select(4, GetItemQualityColor(matQuality)), TSMAPI.Item:GetName(targetItem), deData.amountOfMats)
										tinsert(lines, {left="    "..colorName, right=TSMAPI:MoneyToString(matValue, "|cffffffff", "OPT_PAD", moneyCoins and "OPT_ICON" or nil)})
									end
								end
							end
						end
					end
				end
			end
		end
	end

	-- add mill value info
	if TSM.db.global.tooltipOptions.millTooltip then
		local value = TSMAPI.Conversions:GetValue(itemString, TSM.db.global.coreOptions.destroyValueSource, "mill")
		if value then
			local leftText = "  "..(quantity > 1 and format(L["Mill Value x%s:"], quantity) or L["Mill Value:"])
			tinsert(lines, {left=leftText, right=TSMAPI:MoneyToString(value*quantity, "|cffffffff", "OPT_PAD", moneyCoins and "OPT_ICON" or nil)})

			if TSM.db.global.tooltipOptions.detailedDestroyTooltip then
				for _, targetItem in ipairs(TSMAPI.Conversions:GetTargetItemsByMethod("mill")) do
					local herbs = TSMAPI.Conversions:GetData(targetItem)
					if herbs[itemString] then
						local value = (TSMAPI:GetCustomPriceValue(TSM.db.global.coreOptions.destroyValueSource, targetItem) or 0) * herbs[itemString].rate
						local matQuality = TSMAPI.Item:GetQuality(targetItem)
						if matQuality then
							local colorName = format("|c%s%s%s%s|r", select(4, GetItemQualityColor(matQuality)), TSMAPI.Item:GetName(targetItem), " x ", herbs[itemString].rate * quantity)
							if value > 0 then
								tinsert(lines, {left="    "..colorName, right=TSMAPI:MoneyToString(value*quantity, "|cffffffff", "OPT_PAD", moneyCoins and "OPT_ICON" or nil)})
							end
						end
					end
				end
			end
		end
	end

	-- add prospect value info
	if TSM.db.global.tooltipOptions.prospectTooltip then
		local value = TSMAPI.Conversions:GetValue(itemString, TSM.db.global.coreOptions.destroyValueSource, "prospect")
		if value then
			local leftText = "  "..(quantity > 1 and format(L["Prospect Value x%s:"], quantity) or L["Prospect Value:"])
			tinsert(lines, {left=leftText, right=TSMAPI:MoneyToString(value*quantity, "|cffffffff", "OPT_PAD", moneyCoins and "OPT_ICON" or nil)})

			if TSM.db.global.tooltipOptions.detailedDestroyTooltip then
				for _, targetItem in ipairs(TSMAPI.Conversions:GetTargetItemsByMethod("prospect")) do
					local gems = TSMAPI.Conversions:GetData(targetItem)
					if gems[itemString] then
						local value = (TSMAPI:GetCustomPriceValue(TSM.db.global.coreOptions.destroyValueSource, targetItem) or 0) * gems[itemString].rate
						local matQuality = TSMAPI.Item:GetQuality(targetItem)
						if matQuality then
							local colorName = format("|c%s%s%s%s|r", select(4, GetItemQualityColor(matQuality)), TSMAPI.Item:GetName(targetItem), " x ", gems[itemString].rate * quantity)
							if value > 0 then
								tinsert(lines, {left="    "..colorName, right=TSMAPI:MoneyToString(value*quantity, "|cffffffff", "OPT_PAD", moneyCoins and "OPT_ICON" or nil)})
							end
						end
					end
				end
			end
		end
	end

	-- add transform value info
	if TSM.db.global.tooltipOptions.transformTooltip then
		local value = TSMAPI.Conversions:GetValue(itemString, TSM.db.global.coreOptions.destroyValueSource, "transform")
		if value then
			local leftText = "  "..(quantity > 1 and format(L["Transform Value x%s:"], quantity) or L["Transform Value:"])
			tinsert(lines, {left=leftText, right=TSMAPI:MoneyToString(value*quantity, "|cffffffff", "OPT_PAD", moneyCoins and "OPT_ICON" or nil)})

			if TSM.db.global.tooltipOptions.detailedDestroyTooltip then
				for _, targetItem in ipairs(TSMAPI.Conversions:GetTargetItemsByMethod("transform")) do
					local srcItems = TSMAPI.Conversions:GetData(targetItem)
					if srcItems[itemString] then
						local value = (TSMAPI:GetCustomPriceValue(TSM.db.global.coreOptions.destroyValueSource, targetItem) or 0) * srcItems[itemString].rate
						local matQuality = TSMAPI.Item:GetQuality(targetItem)
						if matQuality then
							local colorName = format("|c%s%s%s%s|r",select(4, GetItemQualityColor(matQuality)), TSMAPI.Item:GetName(targetItem), " x ", srcItems[itemString].rate * quantity)
							if value > 0 then
								tinsert(lines, {left="    "..colorName, right=TSMAPI:MoneyToString(value*quantity, "|cffffffff", "OPT_PAD", moneyCoins and "OPT_ICON" or nil)})
							end
						end
					end
				end
			end
		end
	end

	-- add vendor buy price
	if TSM.db.global.tooltipOptions.vendorBuyTooltip then
		local value = TSMAPI.Item:GetVendorCost(itemString) or 0
		if value > 0 then
			local leftText = "  "..(quantity > 1 and format(L["Vendor Buy Price x%s:"], quantity) or L["Vendor Buy Price:"])
			tinsert(lines, {left=leftText, right=TSMAPI:MoneyToString(value*quantity, "|cffffffff", "OPT_PAD", moneyCoins and "OPT_ICON" or nil)})
		end
	end

	-- add vendor sell price
	if TSM.db.global.tooltipOptions.vendorSellTooltip then
		local value = TSMAPI.Item:GetVendorPrice(itemString) or 0
		if value > 0 then
			local leftText = "  "..(quantity > 1 and format(L["Vendor Sell Price x%s:"], quantity) or L["Vendor Sell Price:"])
			tinsert(lines, {left=leftText, right=TSMAPI:MoneyToString(value*quantity, "|cffffffff", "OPT_PAD", moneyCoins and "OPT_ICON" or nil)})
		end
	end

	-- add custom price sources
	for name, method in pairs(TSM.db.global.userData.customPriceSources) do
		if TSM.db.global.tooltipOptions.customPriceTooltips[name] then
			local price = TSMAPI:GetCustomPriceValue(name, itemString) or 0
			if price > 0 then
				tinsert(lines, {left="  "..L["Custom Price Source"].." '"..name.."':", right=TSMAPI:MoneyToString(price*quantity, "|cffffffff", "OPT_PAD", moneyCoins and "OPT_ICON" or nil)})
			end
		end
	end

	-- add inventory information
	if TSM.db.global.tooltipOptions.inventoryTooltipFormat == "full" then
		local numLines = #lines
		local totalNum = 0
		for factionrealm in TSM.db:GetConnectedRealmIterator("factionrealm") do
			for _, character in TSM.db:FactionrealmCharacterIterator(factionrealm) do
				local bag = TSMAPI_FOUR.Inventory.GetBagQuantity(itemString, character, factionrealm)
				local bank = TSMAPI_FOUR.Inventory.GetBankQuantity(itemString, character, factionrealm)
				local reagentBank = TSMAPI_FOUR.Inventory.GetReagentBankQuantity(itemString, character, factionrealm)
				local auction = TSMAPI_FOUR.Inventory.GetAuctionQuantity(itemString, character, factionrealm)
				local mail = TSMAPI_FOUR.Inventory.GetMailQuantity(itemString, character, factionrealm)
				local playerTotal = bag + bank + reagentBank + auction + mail
				if playerTotal > 0 then
					totalNum = totalNum + playerTotal
					local classColor = RAID_CLASS_COLORS[TSM.db:Get("sync", TSM.db:GetSyncScopeKeyByCharacter(character), "internalData", "classKey")]
					local rightText = format(L["%s (%s bags, %s bank, %s AH, %s mail)"], "|cffffffff"..playerTotal.."|r", "|cffffffff"..bag.."|r", "|cffffffff"..(bank+reagentBank).."|r", "|cffffffff"..auction.."|r", "|cffffffff"..mail.."|r")
					if classColor then
						tinsert(lines, {left="    |c"..classColor.colorStr..character.."|r:", right=rightText})
					else
						tinsert(lines, {left="    "..character..":", right=rightText})
					end
				end
			end
		end
		for guildName in pairs(TSM.db.factionrealm.internalData.guildVaults) do
			local guildQuantity = TSMAPI_FOUR.Inventory.GetGuildQuantity(itemString, guildName)
			if guildQuantity > 0 then
				totalNum = totalNum + guildQuantity
				tinsert(lines, {left="    "..guildName..":", right=format(L["%s in guild vault"], "|cffffffff"..guildQuantity.."|r")})
			end
		end
		if #lines > numLines then
			tinsert(lines, numLines+1, {left="  "..L["Inventory:"], right=format(L["%s total"], "|cffffffff"..totalNum.."|r")})
		end
	elseif TSM.db.global.tooltipOptions.inventoryTooltipFormat == "simple" then
		local numLines = #lines
		local totalPlayer, totalAlt, totalGuild, totalAuction = 0, 0, 0, 0
		for factionrealm in TSM.db:GetConnectedRealmIterator("factionrealm") do
			for _, character in TSM.db:FactionrealmCharacterIterator(factionrealm) do
				local bag = TSMAPI_FOUR.Inventory.GetBagQuantity(itemString, character, factionrealm)
				local bank = TSMAPI_FOUR.Inventory.GetBankQuantity(itemString, character, factionrealm)
				local reagentBank = TSMAPI_FOUR.Inventory.GetReagentBankQuantity(itemString, character, factionrealm)
				local auction = TSMAPI_FOUR.Inventory.GetAuctionQuantity(itemString, character, factionrealm)
				local mail = TSMAPI_FOUR.Inventory.GetMailQuantity(itemString, character, factionrealm)
				if character == UnitName("player") then
					totalPlayer = totalPlayer + bag + bank + reagentBank + mail
					totalAuction = totalAuction + auction
				else
					totalAlt = totalAlt + bag + bank + reagentBank + mail
					totalAuction = totalAuction + auction
				end
			end
		end
		for guildName in pairs(TSM.db.factionrealm.internalData.guildVaults) do
			totalGuild = totalGuild + TSMAPI_FOUR.Inventory.GetGuildQuantity(itemString, guildName)
		end
		local totalNum = totalPlayer + totalAlt + totalGuild + totalAuction
		if totalNum > 0 then
			local rightText = format(L["%s (%s player, %s alts, %s guild, %s AH)"], "|cffffffff"..totalNum.."|r", "|cffffffff"..totalPlayer.."|r", "|cffffffff"..totalAlt.."|r", "|cffffffff"..totalGuild.."|r", "|cffffffff"..totalAuction.."|r")
			tinsert(lines, numLines+1, {left="  "..L["Inventory:"], right=rightText})
		end
	end

	-- add heading
	if #lines > numStartingLines then
		tinsert(lines, numStartingLines+1, "|cffffff00" .. L["TradeSkillMaster Info:"].."|r")
	end
end



-- ============================================================================
-- General Slash-Command Handlers
-- ============================================================================

function private.TestPriceSource(price)
	local _, endIndex, link = strfind(price, "(\124c[0-9a-f]+\124H[^\124]+\124h%[[^%]]+%]\124h\124r)")
	price = link and strtrim(strsub(price, endIndex + 1))
	if not price or price == "" then
		TSM:Print(L["Usage: /tsm price <ItemLink> <Price String>"])
		return
	end

	local isValid, err = TSMAPI_FOUR.CustomPrice.Validate(price)
	if not isValid then
		TSM:Printf(L["%s is not a valid custom price and gave the following error: %s"], TSMAPI.Design:GetInlineColor("link")..price.."|r", err)
		return
	end

	local itemString = TSMAPI_FOUR.Item.ToItemString(link)
	if not itemString then
		TSM:Printf(L["%s is a valid custom price but %s is an invalid item."], TSMAPI.Design:GetInlineColor("link")..price.."|r", link)
		return
	end

	local value = TSMAPI_FOUR.CustomPrice.GetValue(price, itemString)
	if not value then
		TSM:Printf(L["%s is a valid custom price but did not give a value for %s."], TSMAPI.Design:GetInlineColor("link")..price.."|r", link)
		return
	end

	TSM:Printf(L["A custom price of %s for %s evaluates to %s."], TSMAPI.Design:GetInlineColor("link")..price.."|r", link, TSMAPI_FOUR.Money.ToString(value))
end

function private.ChangeProfile(targetProfile)
	targetProfile = strtrim(targetProfile)
	local profiles = TSM.db:GetProfiles()
	if targetProfile == "" then
		TSM:Printf(L["No profile specified. Possible profiles: '%s'"], table.concat(profiles, "', '"))
	else
		for _, profile in ipairs(profiles) do
			if profile == targetProfile then
				if profile ~= TSM.db:GetCurrentProfile() then
					TSM.db:SetProfile(profile)
				end
				TSM:Printf(L["Profile changed to '%s'."], profile)
				return
			end
		end
		TSM:Printf(L["Could not find profile '%s'. Possible profiles: '%s'"], targetProfile, table.concat(profiles, "', '"))
	end
end

function private.DebugSlashCommandHandler(arg)
	if arg == "fstack" then
		TSM.UI.ToggleFrameStack()
	elseif arg == "error" then
		TSM:ShowManualError()
	elseif arg == "logging" then
		TSM.db.global.debug.chatLoggingEnabled = not TSM.db.global.debug.chatLoggingEnabled
		if TSM.db.global.debug.chatLoggingEnabled then
			TSM:Printf("Logging to chat enabled")
		else
			TSM:Printf("Logging to chat disabled")
		end
	end
end



-- ============================================================================
-- General Module Functions
-- ============================================================================

function TSM:GetAppVersion()
	return private.appInfo and private.appInfo.version or 0
end

function TSM:GetAppAddonVersions()
	return private.appInfo and private.appInfo.addonVersions
end

function TSM:GetAppNews()
	return private.appInfo and private.appInfo.news
end

function TSM:GetChatFrame()
	local chatFrame = DEFAULT_CHAT_FRAME
	for i = 1, NUM_CHAT_WINDOWS do
		local name = strlower(GetChatWindowInfo(i) or "")
		if name ~= "" and name == strlower(TSM.db.global.coreOptions.chatFrame) then
			chatFrame = _G["ChatFrame" .. i]
			break
		end
	end
	return chatFrame
end



-- ============================================================================
-- General TSMAPI Functions
-- ============================================================================

function TSMAPI:GetRegion()
	local cVar = GetCVar("Portal")
	return LibStub("LibRealmInfo"):GetCurrentRegion() or (cVar ~= "public-test" and cVar) or "PTR"
end

function TSMAPI:GetTSMProfileIterator()
	local originalProfile = TSM.db:GetCurrentProfile()
	local profiles = TSM.db:GetProfiles()

	return function()
		local profile = tremove(profiles)
		if profile then
			TSM.db:SetProfile(profile)
			return profile
		end
		TSM.db:SetProfile(originalProfile)
	end
end



-- ============================================================================
-- FIXME: this is all just temporary code which should eventually be removed
-- ============================================================================

function private.LoadDeprecatedTSMAPIs()
	local function CreateWrapper(func)
		return function(_, ...) return func(...) end
	end
	TSMAPI.Item.GetName = CreateWrapper(TSMAPI_FOUR.Item.GetName)
	TSMAPI.Item.GetLink = CreateWrapper(TSMAPI_FOUR.Item.GetLink)
	TSMAPI.Item.GetQuality = CreateWrapper(TSMAPI_FOUR.Item.GetQuality)
	TSMAPI.Item.GetItemLevel = CreateWrapper(TSMAPI_FOUR.Item.GetItemLevel)
	TSMAPI.Item.GetMinLevel = CreateWrapper(TSMAPI_FOUR.Item.GetMinLevel)
	TSMAPI.Item.GetMaxStack = CreateWrapper(TSMAPI_FOUR.Item.GetMaxStack)
	TSMAPI.Item.GetEquipSlot = CreateWrapper(TSMAPI_FOUR.Item.GetInvSlotId)
	TSMAPI.Item.GetTexture = CreateWrapper(TSMAPI_FOUR.Item.GetTexture)
	TSMAPI.Item.GetVendorPrice = CreateWrapper(TSMAPI_FOUR.Item.GetVendorSell)
	TSMAPI.Item.GetClassId = CreateWrapper(TSMAPI_FOUR.Item.GetClassId)
	TSMAPI.Item.GetSubClassId = CreateWrapper(TSMAPI_FOUR.Item.GetSubClassId)
	TSMAPI.Item.FetchInfo = CreateWrapper(TSMAPI_FOUR.Item.FetchInfo)
	TSMAPI.Item.GetVendorCost = CreateWrapper(TSMAPI_FOUR.Item.GetVendorBuy)
	TSMAPI.Item.IsSoulboundMat = CreateWrapper(TSMAPI_FOUR.Item.IsSoulboundMat)
	TSMAPI.Item.IsDisenchantable = CreateWrapper(TSMAPI_FOUR.Item.IsDisenchantable)
	TSMAPI.Item.IsCraftingReagent = CreateWrapper(TSMAPI_FOUR.Item.IsCraftingReagent)
	TSMAPI.Item.GeneralizeLink = CreateWrapper(TSMAPI_FOUR.Item.GeneralizeLink)
	TSMAPI.Delay.AfterTime = CreateWrapper(TSMAPI_FOUR.Delay.AfterTime)
	TSMAPI.Delay.AfterFrame = CreateWrapper(TSMAPI_FOUR.Delay.AfterFrame)
	TSMAPI.Delay.Cancel = CreateWrapper(TSMAPI_FOUR.Delay.Cancel)
	TSMAPI.ValidateCustomPrice = CreateWrapper(TSMAPI_FOUR.CustomPrice.Validate)
	TSMAPI.GetCustomPriceValue = CreateWrapper(TSMAPI_FOUR.CustomPrice.GetValue)
	TSMAPI.GetItemValue = CreateWrapper(TSMAPI_FOUR.CustomPrice.GetItemPrice)
	TSMAPI.GetPriceSources = CreateWrapper(TSMAPI_FOUR.CustomPrice.GetSources)
	TSMAPI.Conversions.Add = CreateWrapper(TSMAPI_FOUR.Conversions.Add)
	TSMAPI.Conversions.GetData = CreateWrapper(TSMAPI_FOUR.Conversions.GetData)
	TSMAPI.Conversions.GetTargetItemByName = CreateWrapper(TSMAPI_FOUR.Conversions.GetTargetItemByName)
	TSMAPI.Conversions.GetTargetItemNames = CreateWrapper(TSMAPI_FOUR.Conversions.GetTargetItemNames)
	TSMAPI.Conversions.GetSourceItems = CreateWrapper(TSMAPI_FOUR.Conversions.GetSourceItems)
	TSMAPI.Conversions.GetTargetItemsByMethod = CreateWrapper(TSMAPI_FOUR.Conversions.GetTargetItemsByMethod)
	TSMAPI.Conversions.GetValue = CreateWrapper(TSMAPI_FOUR.Conversions.GetValue)
	TSMAPI.Player.GetCharacters = CreateWrapper(TSMAPI_FOUR.PlayerInfo.GetCharacters)
	TSMAPI.Player.GetGuilds = CreateWrapper(TSMAPI_FOUR.PlayerInfo.GetGuilds)
	TSMAPI.Player.GetPlayerGuild = CreateWrapper(TSMAPI_FOUR.PlayerInfo.GetPlayerGuild)
	TSMAPI.Player.IsPlayer = CreateWrapper(TSMAPI_FOUR.PlayerInfo.IsPlayer)
	TSMAPI.Inventory.BagIterator = CreateWrapper(TSMAPI_FOUR.Inventory.BagIterator)
	TSMAPI.Inventory.BankIterator = CreateWrapper(TSMAPI_FOUR.Inventory.BankIterator)
	TSMAPI.Inventory.ItemWillGoInBag = CreateWrapper(TSMAPI_FOUR.Inventory.ItemWillGoInBag)
	TSMAPI.Inventory.GetBagQuantity = CreateWrapper(TSMAPI_FOUR.Inventory.GetBagQuantity)
	TSMAPI.Inventory.GetBankQuantity = CreateWrapper(TSMAPI_FOUR.Inventory.GetBankQuantity)
	TSMAPI.Inventory.GetReagentBankQuantity = CreateWrapper(TSMAPI_FOUR.Inventory.GetReagentBankQuantity)
	TSMAPI.Inventory.GetAuctionQuantity = CreateWrapper(TSMAPI_FOUR.Inventory.GetAuctionQuantity)
	TSMAPI.Inventory.GetMailQuantity = CreateWrapper(TSMAPI_FOUR.Inventory.GetMailQuantity)
	TSMAPI.Inventory.GetGuildQuantity = CreateWrapper(TSMAPI_FOUR.Inventory.GetGuildQuantity)
	TSMAPI.Inventory.GetPlayerTotals = CreateWrapper(TSMAPI_FOUR.Inventory.GetPlayerTotals)
	TSMAPI.Inventory.GetGuildTotal = CreateWrapper(TSMAPI_FOUR.Inventory.GetGuildTotal)
	TSMAPI.Inventory.GetTotalQuantity = CreateWrapper(TSMAPI_FOUR.Inventory.GetTotalQuantity)
	TSMAPI.Inventory.GetCraftingTotals = CreateWrapper(TSMAPI_FOUR.Inventory.GetCraftingTotals)
	TSMAPI.Groups.FormatPath = CreateWrapper(TSMAPI_FOUR.Groups.FormatPath)
	TSMAPI.Groups.JoinPath = CreateWrapper(TSMAPI_FOUR.Groups.JoinPath)
	TSMAPI.Groups.GetPath = CreateWrapper(TSMAPI_FOUR.Groups.GetPathByItem)
	TSMAPI.HasModule = CreateWrapper(TSMAPI_FOUR.Modules.IsPresent)
	TSMAPI.ModuleAPI = CreateWrapper(TSMAPI_FOUR.Modules.API)
	TSMAPI.MoveItems = CreateWrapper(TSMAPI_FOUR.Mover.MoveItems)
	TSMAPI.Settings.Init = function(_, name)
		local moduleName = gsub(name, "DB$", "")
		local AceAddon = LibStub("AceAddon-3.0")
		local obj = AceAddon and AceAddon:GetAddon(gsub(moduleName, "TradeSkillMaster", "TSM"))
		if obj and tContains(TSM.CONST.OLD_TSM_MODULES, moduleName) then
			obj.OnInitialize = nil
			obj.OnEnable = nil
			obj.OnDisable = nil
			for _, module in ipairs(obj.modules) do
				module.OnInitialize = nil
				module.OnEnable = nil
				module.OnDisable = nil
			end
			wipe(obj.modules)
			wipe(obj.orderedModules)
		end
		error(moduleName, 2)
	end
end
do
	TSMAPI.Assert = function(_, cond, msg) return assert(cond, msg) end
	TSMAPI.Error = function(_, msg) error(msg) end
	local function CreateWrapper(func)
		return function(_, ...) return func(...) end
	end
	TSMAPI.MoneyToString = CreateWrapper(TSMAPI_FOUR.Money.ToString)
	TSMAPI.MoneyFromString = CreateWrapper(TSMAPI_FOUR.Money.FromString)
	TSMAPI.Util.StrEscape = CreateWrapper(TSMAPI_FOUR.Util.StrEscape)
	TSMAPI.Util.SafeItemRef = CreateWrapper(TSMAPI_FOUR.Util.SafeItemRef)
	TSMAPI.Util.SafeTooltipLink = CreateWrapper(TSMAPI_FOUR.Util.SafeTooltipLink)
	TSMAPI.Util.ShowStaticPopupDialog = CreateWrapper(TSMAPI_FOUR.Util.ShowStaticPopupDialog)
	TSMAPI.Util.Round = CreateWrapper(TSMAPI_FOUR.Util.Round)
	local function SelectHelper(positions, ...)
		if #positions == 0 then return end
		return select(tremove(positions, 1), ...), SelectHelper(positions, ...)
	end
	TSMAPI.Util.Select = function(_, positions, ...)
		if type(positions) == "number" then
			return select(positions, ...)
		elseif type(positions) == "table" then
			return SelectHelper(positions, ...)
		else
			error(format("Bad argument #1. Expected number or table, got %s", type(positions)))
		end
	end
	TSMAPI.Threading.Start = CreateWrapper(TSMAPI_FOUR.Threading.Start)
	TSMAPI.Threading.StartImmortal = CreateWrapper(TSMAPI_FOUR.Threading.StartImmortal)
	TSMAPI.Threading.Kill = CreateWrapper(TSMAPI_FOUR.Threading.Kill)
	TSMAPI.GetNoSoundKey = CreateWrapper(TSMAPI_FOUR.Sound.GetNoSoundKey)
	TSMAPI.GetSounds = CreateWrapper(TSMAPI_FOUR.Sound.GetSounds)
	TSMAPI.DoPlaySound = CreateWrapper(TSMAPI_FOUR.Sound.PlaySound)
	TSMAPI.Debug.DumpTable = CreateWrapper(TSMAPI_FOUR.Debug.DumpTable)
	TSMAPI.Item.ToItemString = CreateWrapper(TSMAPI_FOUR.Item.ToItemString)
	TSMAPI.Item.ToBaseItemString = CreateWrapper(TSMAPI_FOUR.Item.ToBaseItemString)
	TSMAPI.Item.ToItemID = CreateWrapper(TSMAPI_FOUR.Item.ToItemID)
	TSMAPI.Item.GetItemClasses = CreateWrapper(TSMAPI_FOUR.Item.GetItemClasses)
	TSMAPI.Item.GetItemSubClasses = function(_, classId)
		return TSMAPI_FOUR.Item.GetItemSubClasses(GetItemClassInfo(classId))
	end
	TSMAPI.Item.GetClassIdFromClassString = CreateWrapper(TSMAPI_FOUR.Item.GetClassIdFromClassString)
	TSMAPI.Item.GetSubClassIdFromSubClassString = CreateWrapper(TSMAPI_FOUR.Item.GetSubClassIdFromSubClassString)
	TSMAPI.Item.GetInventorySlotIdFromInventorySlotString = CreateWrapper(TSMAPI_FOUR.Item.GetInventorySlotIdFromInventorySlotString)
end
