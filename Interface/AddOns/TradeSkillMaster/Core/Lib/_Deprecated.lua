-- NOTE: This file contains TSM3 functions which are deprecated and should be replaced before releasing TSM4.


do
	local private = { itemBOACache = {} }
	-- TODO: replace calls to this with new TSMAPI_FOUR.Item.IsSoulbound(itemString) and TSMAPI_FOUR.Inventory.IsSoulbound(bag, slot) APIs
	function TSMAPI.Item:IsSoulbound(...)
		local numArgs = select('#', ...)
		if numArgs == 0 then return end
		local itemString, ignoreBOA
		local firstArg = ...
		if type(firstArg) == "string" then
			assert(numArgs <= 2, "Too many arguments provided with itemString")
			itemString, ignoreBOA = ...
			local isSoulbound = TSMAPI_FOUR.Item.IsSoulbound(itemString)
			if isSoulbound == nil then return end
			if ignoreBOA then
				local isBOA = private.IsItemBOA(itemString)
				if isBOA == nil then return end
				return isSoulbound and not isBOA
			else
				return isSoulbound
			end
		elseif type(firstArg) == "number" then
			local bag, slot, ignoreBOA = ...
			local isBOP, isBOA = TSMAPI_FOUR.Inventory.IsSoulbound(bag, slot)
			if isBOP == nil then
				return nil
			end
			if ignoreBOA then
				return isBOP
			else
				return isBOP or isBOA
			end
		else
			error("Invalid arguments")
		end
	end

	function private.IsItemBOA(itemString)
		if private.itemBOACache[itemString] ~= nil then
			return private.itemBOACache[itemString]
		end

		local scanTooltip = private.GetScanTooltip()
		scanTooltip:SetHyperlink(TSMAPI_FOUR.Item.ToWowItemString(itemString))

		local numLines = scanTooltip:NumLines()
		if numLines <= 1 then
			-- the tooltip didn't fully load
			return nil
		end
		for id = 1, numLines do
			local text = private.GetTooltipText(_G[scanTooltip:GetName().."TextLeft"..id])
			if text then
				if (text == ITEM_BIND_ON_PICKUP and id < 4) or text == ITEM_SOULBOUND or text == ITEM_BIND_QUEST then
					private.itemBOACache[itemString] = false
					break
				elseif (text == ITEM_ACCOUNTBOUND or text == ITEM_BIND_TO_ACCOUNT or text == ITEM_BIND_TO_BNETACCOUNT or text == ITEM_BNETACCOUNTBOUND) then
					private.itemBOACache[itemString] = true
					break
				end
			end
		end

		return private.itemBOACache[itemString]
	end

	function private.GetScanTooltip()
		if not TSMScanTooltip then
			CreateFrame("GameTooltip", "TSMScanTooltip", UIParent, "GameTooltipTemplate")
		end
		TSMScanTooltip:Show()
		TSMScanTooltip:SetClampedToScreen(false)
		TSMScanTooltip:SetOwner(UIParent, "ANCHOR_BOTTOMRIGHT", 1000000, 100000)
		return TSMScanTooltip
	end

	function private.GetTooltipCharges(scanTooltip)
		for id = 1, scanTooltip:NumLines() do
			local text = private.GetTooltipText(_G[scanTooltip:GetName().."TextLeft"..id])
			local maxCharges = text and strmatch(text, "^([0-9]+) Charges?$")
			if maxCharges then
				return maxCharges
			end
		end
	end

	function private.GetTooltipText(text)
		local textStr = strtrim(text and text:GetText() or "")
		if textStr == "" then return end

		local r, g, b = text:GetTextColor()
		return textStr, floor(r * 256), floor(g * 256), floor(b * 256)
	end
end
