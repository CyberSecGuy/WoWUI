-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

TSMAPI_FOUR.Exporter = {}
local _, TSM = ...
local Exporter = TSM:NewPackage("Exporter", "AceSerializer-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = {}
local ExporterClass = TSMAPI_FOUR.Class.DefineClass("ExporterClass")
