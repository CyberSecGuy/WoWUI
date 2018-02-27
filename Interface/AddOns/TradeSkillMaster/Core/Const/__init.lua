-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
TSM.CONST = {}

-- Miscellaneous constants which should never change
TSM.CONST.GROUP_SEP = "`"
TSM.CONST.ROOT_GROUP_PATH = ""
TSM.CONST.NO_SOUND_KEY = "TSM_NO_SOUND" -- this can never change
TSM.CONST.OPERATION_DEFAULT_FIELDS = {
	ignorePlayer = {},
	ignoreFactionrealm = {},
	relationships = {},
}
TSM.CONST.OLD_TSM_MODULES = {
	"TradeSkillMaster_Accounting",
	"TradeSkillMaster_AuctionDB",
	"TradeSkillMaster_Auctioning",
	"TradeSkillMaster_Crafting",
	"TradeSkillMaster_Destroying",
	"TradeSkillMaster_Mailing",
	"TradeSkillMaster_Shopping",
	"TradeSkillMaster_Vendoring",
	"TradeSkillMaster_Warehousing",
}
TSM.CONST.TOOLTIP_SEP = "\001"
TSM.CONST.PET_CAGE_ITEMSTRING = "i:82800"
TSM.CONST.UNKNOWN_ITEM_ITEMSTRING = "i:0"
