-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local _, TSM = ...
local TexturePacks = TSM.UI:NewPackage("TexturePacks")
local private = {}
local TEXTURE_FILE_INFO = {
	uiFrames = {
		path = "Interface\\Addons\\TradeSkillMaster\\Media\\UIFrames.blp",
		scale = 1,
		width = 512,
		height = 512,
		coord = {
			["ActiveInputFieldLeft"] = { 323, 344, 146, 166 },
			["ActiveInputFieldMiddle"] = { 323, 344, 171, 191 },
			["ActiveInputFieldRight"] = { 320, 341, 196, 216 },
			["CraftingApplicationInnerFrameTopLeftCorner"] = { 3, 179, 3, 35 },
			["CraftingApplicationInnerFrameTopRightCorner"] = { 184, 360, 3, 35 },
			["DefaultUIButton"] = { 365, 496, 3, 19 },
			["DividerHandle"] = { 501, 509, 3, 85 },
			["HeaderLeft"] = { 155, 181, 132, 160 },
			["HeaderMiddle"] = { 292, 318, 146, 174 },
			["HeaderRight"] = { 87, 113, 176, 204 },
			["HighlightDot"] = { 277, 285, 153, 161 },
			["InactiveInputFieldLeft"] = { 320, 341, 221, 241 },
			["InactiveInputFieldMiddle"] = { 118, 139, 239, 259 },
			["InactiveInputFieldRight"] = { 246, 267, 184, 204 },
			["LargeActiveButtonLeft"] = { 161, 174, 261, 287 },
			["LargeActiveButtonMiddle"] = { 118, 144, 208, 234 },
			["LargeActiveButtonRight"] = { 222, 235, 255, 281 },
			["LargeApplicationCloseFrameBackground"] = { 155, 210, 99, 127 },
			["LargeApplicationFrameInnerFrameBottomEdge"] = { 87, 159, 165, 171 },
			["LargeApplicationFrameInnerFrameBottomLeftCorner"] = { 87, 113, 209, 235 },
			["LargeApplicationFrameInnerFrameBottomRightCorner"] = { 215, 241, 153, 179 },
			["LargeApplicationFrameInnerFrameLeftEdge"] = { 277, 284, 166, 238 },
			["LargeApplicationFrameInnerFrameRightEdge"] = { 149, 156, 221, 293 },
			["LargeApplicationInnerFrameTopEdge"] = { 365, 437, 146, 175 },
			["LargeApplicationInnerFrameTopLeftCorner"] = { 78, 150, 109, 141 },
			["LargeApplicationInnerFrameTopRightCorner"] = { 365, 437, 109, 141 },
			["LargeApplicationOuterFrameBottomEdge"] = { 215, 287, 125, 135 },
			["LargeApplicationOuterFrameBottomLeftCorner"] = { 149, 159, 176, 186 },
			["LargeApplicationOuterFrameBottomRightCorner"] = { 149, 159, 191, 201 },
			["LargeApplicationOuterFrameLeftEdge"] = { 350, 360, 86, 158 },
			["LargeApplicationOuterFrameRightEdge"] = { 349, 359, 163, 235 },
			["LargeApplicationOuterFrameTopEdge"] = { 3, 75, 40, 94 },
			["LargeApplicationOuterFrameTopLeftCorner"] = { 80, 144, 40, 94 },
			["LargeApplicationOuterFrameTopRightCorner"] = { 149, 213, 40, 94 },
			["LargeClickedButtonLeft"] = { 199, 212, 272, 298 },
			["LargeClickedButtonMiddle"] = { 246, 272, 153, 179 },
			["LargeClickedButtonRight"] = { 179, 192, 275, 301 },
			["LargeHoverButtonLeft"] = { 161, 174, 292, 318 },
			["LargeHoverButtonMiddle"] = { 289, 315, 179, 205 },
			["LargeHoverButtonRight"] = { 240, 253, 255, 281 },
			["LargeInactiveButtonLeft"] = { 258, 271, 255, 281 },
			["LargeInactiveButtonMiddle"] = { 289, 315, 210, 236 },
			["LargeInactiveButtonRight"] = { 364, 377, 180, 206 },
			["LoadingBarLeft"] = { 3, 23, 109, 148 },
			["LoadingBarMiddle"] = { 28, 48, 109, 148 },
			["LoadingBarRight"] = { 53, 73, 109, 148 },
			["MediumActiveButtonLeft"] = { 418, 431, 180, 200 },
			["MediumActiveButtonMiddle"] = { 164, 179, 165, 185 },
			["MediumActiveButtonRight"] = { 418, 431, 205, 225 },
			["MediumClickedButtonLeft"] = { 364, 377, 211, 231 },
			["MediumClickedButtonMiddle"] = { 164, 179, 190, 210 },
			["MediumClickedButtonRight"] = { 382, 395, 211, 231 },
			["MediumHoverButtonLeft"] = { 400, 413, 211, 231 },
			["MediumHoverButtonMiddle"] = { 164, 179, 215, 235 },
			["MediumHoverButtonRight"] = { 436, 449, 214, 234 },
			["MediumInactiveButtonLeft Copy"] = { 418, 431, 230, 250 },
			["MediumInactiveButtonLeft"] = { 364, 377, 236, 256 },
			["MediumInactiveButtonMiddle Copy"] = { 246, 261, 209, 229 },
			["MediumInactiveButtonMiddle"] = { 215, 230, 215, 235 },
			["MediumInactiveButtonRight Copy"] = { 346, 359, 240, 260 },
			["MediumInactiveButtonRight"] = { 320, 333, 246, 266 },
			["PopupBottomEdge"] = { 490, 502, 256, 268 },
			["PopupBottomLeftCorner"] = { 490, 502, 273, 285 },
			["PopupBottomRightCorner"] = { 436, 448, 260, 272 },
			["PopupLeftEdge"] = { 453, 465, 260, 272 },
			["PopupRightEdge"] = { 364, 376, 261, 273 },
			["PopupTopEdge"] = { 338, 350, 265, 277 },
			["PopupTopLeftCorner"] = { 320, 332, 271, 283 },
			["PopupTopRightCorner"] = { 302, 342, 119, 141 },
			["PromoTextureLeft"] = { 365, 444, 24, 104 },
			["PromoTextureMiddle"] = { 3, 82, 155, 235 },
			["PromoTextureRight"] = { 218, 297, 40, 120 },
			["RankFrame"] = { 449, 494, 70, 84 },
			["RegularActiveDropdownLeft"] = { 382, 395, 180, 206 },
			["RegularActiveDropdownMiddle"] = { 289, 315, 241, 267 },
			["RegularActiveDropdownRight"] = { 400, 413, 180, 206 },
			["RegularInactiveDropdownLeft"] = { 204, 217, 240, 267 },
			["RegularInactiveDropdownMiddle"] = { 118, 144, 176, 203 },
			["RegularInactiveDropdownRight"] = { 181, 194, 243, 270 },
			["SearchLeft"] = { 382, 395, 236, 256 },
			["SearchMiddle"] = { 400, 413, 236, 256 },
			["SearchRight"] = { 454, 467, 214, 234 },
			["SearchTypeIndicator"] = { 87, 146, 146, 158 },
			["SmallActiveButtonLeft"] = { 472, 485, 214, 230 },
			["SmallActiveButtonMiddle"] = { 184, 199, 222, 238 },
			["SmallActiveButtonRight"] = { 490, 503, 214, 230 },
			["SmallApplicationCloseFrameBackground"] = { 302, 345, 86, 114 },
			["SmallApplicationInnerFrameBottomEdge"] = { 87, 159, 165, 171 },
			["SmallApplicationInnerFrameBottomLeftCorner"] = { 87, 113, 209, 235 },
			["SmallApplicationInnerFrameBottomRightCorner"] = { 215, 241, 153, 179 },
			["SmallApplicationInnerFrameLeftEdge"] = { 277, 284, 166, 238 },
			["SmallApplicationInnerFrameRightEdge"] = { 149, 156, 221, 293 },
			["SmallApplicationInnerFrameTopEdge"] = { 215, 287, 140, 148 },
			["SmallApplicationInnerFrameTopLeftCorner"] = { 215, 241, 184, 210 },
			["SmallApplicationInnerFrameTopRightCorner"] = { 184, 210, 191, 217 },
			["SmallApplicationOuterFrameBottomEdge"] = { 215, 287, 125, 135 },
			["SmallApplicationOuterFrameBottomLeftCorner"] = { 149, 159, 176, 186 },
			["SmallApplicationOuterFrameBottomRightCorner"] = { 149, 159, 206, 216 },
			["SmallApplicationOuterFrameLeftEdge"] = { 350, 360, 86, 158 },
			["SmallApplicationOuterFrameRightEdge"] = { 349, 359, 163, 235 },
			["SmallApplicationOuterFrameTopEdge"] = { 3, 75, 40, 94 },
			["SmallApplicationOuterFrameTopLeftCorner"] = { 442, 506, 155, 209 },
			["SmallApplicationOuterFrameTopRightCorner"] = { 186, 210, 132, 186 },
			["SmallClickedButtonLeft"] = { 472, 485, 235, 251 },
			["SmallClickedButtonMiddle"] = { 161, 176, 240, 256 },
			["SmallClickedButtonRight"] = { 490, 503, 235, 251 },
			["SmallHoverButtonLeft"] = { 436, 449, 239, 255 },
			["SmallHoverButtonMiddle"] = { 235, 250, 234, 250 },
			["SmallHoverButtonRight"] = { 418, 431, 255, 271 },
			["SmallInactiveButtonLeft"] = { 454, 467, 239, 255 },
			["SmallInactiveButtonMiddle"] = { 255, 270, 234, 250 },
			["SmallInactiveButtonRight"] = { 472, 485, 256, 272 },
			["TSMLogo"] = { 449, 509, 90, 150 },
			["ToggleDisabledOff"] = { 449, 496, 24, 42 },
			["ToggleDisabledOn"] = { 449, 496, 47, 65 },
			["ToggleOff"] = { 302, 349, 40, 58 },
			["ToggleOn"] = { 302, 349, 63, 81 },
		},
	},
	iconPack = {
		path = "Interface\\Addons\\TradeSkillMaster\\Media\\IconPack.blp",
		scale = 2,
		width = 512,
		height = 1024,
		coord = {
			["10x10/Add/Circle"] = { 492, 512, 180, 200 },
			["10x10/Add/Default"] = { 492, 512, 200, 220 },
			["10x10/Arrow/Down"] = { 492, 512, 220, 240 },
			["10x10/Arrow/Up"] = { 492, 512, 240, 260 },
			["10x10/Auctions"] = { 492, 512, 260, 280 },
			["10x10/Bid"] = { 492, 512, 280, 300 },
			["10x10/Boxes"] = { 492, 512, 300, 320 },
			["10x10/Buyout"] = { 492, 512, 320, 340 },
			["10x10/Carot/Collapsed"] = { 492, 512, 340, 360 },
			["10x10/Carot/Expanded"] = { 288, 308, 436, 456 },
			["10x10/Checkmark/Circle"] = { 288, 308, 456, 476 },
			["10x10/Checkmark/Default"] = { 148, 168, 464, 484 },
			["10x10/Chevron/Collapsed"] = { 288, 308, 476, 496 },
			["10x10/Chevron/Expanded"] = { 268, 288, 484, 504 },
			["10x10/Chevron/Inactive"] = { 268, 288, 504, 524 },
			["10x10/Clock"] = { 336, 356, 496, 516 },
			["10x10/Close/Circle"] = { 336, 356, 516, 536 },
			["10x10/Close/Default"] = { 96, 116, 516, 536 },
			["10x10/Coins"] = { 172, 192, 508, 528 },
			["10x10/Configure"] = { 192, 212, 508, 528 },
			["10x10/Crafting"] = { 212, 232, 508, 528 },
			["10x10/Dashboard"] = { 232, 252, 508, 528 },
			["10x10/Delete"] = { 252, 272, 524, 544 },
			["10x10/DragHandle"] = { 172, 192, 528, 548 },
			["10x10/Duplicate"] = { 144, 164, 532, 552 },
			["10x10/Edit"] = { 96, 116, 536, 556 },
			["10x10/Expire"] = { 116, 136, 536, 556 },
			["10x10/Filter"] = { 192, 212, 528, 548 },
			["10x10/Groups"] = { 212, 232, 528, 548 },
			["10x10/Help"] = { 232, 252, 528, 548 },
			["10x10/Ignore"] = { 24, 44, 540, 560 },
			["10x10/Import"] = { 0, 20, 544, 564 },
			["10x10/Inventory"] = { 44, 64, 540, 560 },
			["10x10/Link"] = { 64, 84, 540, 560 },
			["10x10/More"] = { 380, 400, 520, 540 },
			["10x10/New"] = { 356, 376, 528, 548 },
			["10x10/Operations"] = { 336, 356, 536, 556 },
			["10x10/Pause"] = { 252, 272, 544, 564 },
			["10x10/Post"] = { 272, 292, 544, 564 },
			["10x10/Posting"] = { 292, 312, 544, 564 },
			["10x10/Queue"] = { 312, 332, 544, 564 },
			["10x10/Reset"] = { 164, 184, 548, 568 },
			["10x10/Resize"] = { 136, 156, 552, 572 },
			["10x10/Running"] = { 84, 104, 556, 576 },
			["10x10/SaleRate"] = { 104, 124, 556, 576 },
			["10x10/Search"] = { 20, 40, 560, 580 },
			["10x10/Settings"] = { 0, 20, 564, 584 },
			["10x10/Shopping"] = { 40, 60, 560, 580 },
			["10x10/SideArrow"] = { 60, 80, 560, 580 },
			["10x10/SkillUp"] = { 184, 204, 548, 568 },
			["10x10/SkillUp/1"] = { 204, 224, 548, 568 },
			["10x10/SkillUp/10"] = { 224, 244, 548, 568 },
			["10x10/SkillUp/2"] = { 400, 420, 520, 540 },
			["10x10/SkillUp/3"] = { 420, 440, 520, 540 },
			["10x10/SkillUp/4"] = { 440, 460, 520, 540 },
			["10x10/SkillUp/5"] = { 460, 480, 520, 540 },
			["10x10/SkillUp/6"] = { 480, 500, 520, 540 },
			["10x10/SkillUp/7"] = { 376, 396, 540, 560 },
			["10x10/SkillUp/8"] = { 356, 376, 548, 568 },
			["10x10/SkillUp/9"] = { 332, 352, 556, 576 },
			["10x10/Skip"] = { 244, 264, 564, 584 },
			["10x10/Sniper"] = { 264, 284, 564, 584 },
			["10x10/Star/Filled"] = { 284, 304, 564, 584 },
			["10x10/Star/Unfilled"] = { 304, 324, 564, 584 },
			["10x10/Stop"] = { 156, 176, 568, 588 },
			["10x10/Subtract/Circle"] = { 124, 144, 572, 592 },
			["10x10/Subtract/Default"] = { 80, 100, 576, 596 },
			["12x12/Add/Circle"] = { 360, 384, 192, 216 },
			["12x12/Add/Default"] = { 360, 384, 216, 240 },
			["12x12/Arrow/Down"] = { 360, 384, 240, 264 },
			["12x12/Arrow/Up"] = { 360, 384, 264, 288 },
			["12x12/Auctions"] = { 360, 384, 288, 312 },
			["12x12/Bid"] = { 360, 384, 312, 336 },
			["12x12/Boxes"] = { 396, 420, 344, 368 },
			["12x12/Buyout"] = { 396, 420, 368, 392 },
			["12x12/Carot/Collapsed"] = { 396, 420, 392, 416 },
			["12x12/Carot/Expanded"] = { 28, 52, 444, 468 },
			["12x12/Checkmark/Circle"] = { 52, 76, 444, 468 },
			["12x12/Checkmark/Default"] = { 76, 100, 444, 468 },
			["12x12/Chevron/Collapsed"] = { 100, 124, 444, 468 },
			["12x12/Chevron/Expanded"] = { 168, 192, 436, 460 },
			["12x12/Chevron/Inactive"] = { 192, 216, 436, 460 },
			["12x12/Clock"] = { 216, 240, 436, 460 },
			["12x12/Close/Circle"] = { 240, 264, 436, 460 },
			["12x12/Close/Default"] = { 264, 288, 436, 460 },
			["12x12/Coins"] = { 308, 332, 448, 472 },
			["12x12/Configure"] = { 332, 356, 448, 472 },
			["12x12/Crafting"] = { 356, 380, 456, 480 },
			["12x12/Dashboard"] = { 308, 332, 472, 496 },
			["12x12/Delete"] = { 332, 356, 472, 496 },
			["12x12/DragHandle"] = { 168, 192, 460, 484 },
			["12x12/Duplicate"] = { 124, 148, 464, 488 },
			["12x12/Edit"] = { 28, 52, 468, 492 },
			["12x12/Expire"] = { 0, 24, 472, 496 },
			["12x12/Filter"] = { 52, 76, 468, 492 },
			["12x12/Groups"] = { 76, 100, 468, 492 },
			["12x12/Help"] = { 100, 124, 468, 492 },
			["12x12/Ignore"] = { 192, 216, 460, 484 },
			["12x12/Import"] = { 216, 240, 460, 484 },
			["12x12/Inventory"] = { 240, 264, 460, 484 },
			["12x12/Link"] = { 264, 288, 460, 484 },
			["12x12/More"] = { 380, 404, 472, 496 },
			["12x12/New"] = { 356, 380, 480, 504 },
			["12x12/Operations"] = { 404, 428, 472, 496 },
			["12x12/Pause"] = { 428, 452, 472, 496 },
			["12x12/Post"] = { 452, 476, 472, 496 },
			["12x12/Posting"] = { 476, 500, 472, 496 },
			["12x12/Queue"] = { 380, 404, 496, 520 },
			["12x12/Reset"] = { 404, 428, 496, 520 },
			["12x12/Resize"] = { 428, 452, 496, 520 },
			["12x12/Running"] = { 452, 476, 496, 520 },
			["12x12/SaleRate"] = { 476, 500, 496, 520 },
			["12x12/Search"] = { 148, 172, 484, 508 },
			["12x12/Settings"] = { 124, 148, 488, 512 },
			["12x12/Shopping"] = { 24, 48, 492, 516 },
			["12x12/SideArrow"] = { 0, 24, 496, 520 },
			["12x12/SkillUp"] = { 48, 72, 492, 516 },
			["12x12/SkillUp/1"] = { 72, 96, 492, 516 },
			["12x12/SkillUp/10"] = { 96, 120, 492, 516 },
			["12x12/SkillUp/2"] = { 172, 196, 484, 508 },
			["12x12/SkillUp/3"] = { 196, 220, 484, 508 },
			["12x12/SkillUp/4"] = { 220, 244, 484, 508 },
			["12x12/SkillUp/5"] = { 244, 268, 484, 508 },
			["12x12/SkillUp/6"] = { 288, 312, 496, 520 },
			["12x12/SkillUp/7"] = { 312, 336, 496, 520 },
			["12x12/SkillUp/8"] = { 356, 380, 504, 528 },
			["12x12/SkillUp/9"] = { 288, 312, 520, 544 },
			["12x12/Skip"] = { 312, 336, 520, 544 },
			["12x12/Sniper"] = { 148, 172, 508, 532 },
			["12x12/Star/Filled"] = { 120, 144, 512, 536 },
			["12x12/Star/Unfilled"] = { 24, 48, 516, 540 },
			["12x12/Stop"] = { 0, 24, 520, 544 },
			["12x12/Subtract/Circle"] = { 48, 72, 516, 540 },
			["12x12/Subtract/Default"] = { 72, 96, 516, 540 },
			["14x14/Add/Circle"] = { 144, 172, 324, 352 },
			["14x14/Add/Default"] = { 172, 200, 324, 352 },
			["14x14/Arrow/Down"] = { 200, 228, 324, 352 },
			["14x14/Arrow/Up"] = { 228, 256, 324, 352 },
			["14x14/Auctions"] = { 256, 284, 324, 352 },
			["14x14/Bid"] = { 284, 312, 324, 352 },
			["14x14/Boxes"] = { 312, 340, 336, 364 },
			["14x14/Buyout"] = { 340, 368, 336, 364 },
			["14x14/Carot/Collapsed"] = { 368, 396, 344, 372 },
			["14x14/Carot/Expanded"] = { 420, 448, 360, 388 },
			["14x14/Checkmark/Circle"] = { 448, 476, 360, 388 },
			["14x14/Checkmark/Default"] = { 476, 504, 360, 388 },
			["14x14/Chevron/Collapsed"] = { 420, 448, 388, 416 },
			["14x14/Chevron/Expanded"] = { 448, 476, 388, 416 },
			["14x14/Chevron/Inactive"] = { 476, 504, 388, 416 },
			["14x14/Clock"] = { 144, 172, 352, 380 },
			["14x14/Close/Circle"] = { 172, 200, 352, 380 },
			["14x14/Close/Default"] = { 200, 228, 352, 380 },
			["14x14/Coins"] = { 228, 256, 352, 380 },
			["14x14/Configure"] = { 256, 284, 352, 380 },
			["14x14/Crafting"] = { 284, 312, 352, 380 },
			["14x14/Dashboard"] = { 312, 340, 364, 392 },
			["14x14/Delete"] = { 340, 368, 364, 392 },
			["14x14/DragHandle"] = { 368, 396, 372, 400 },
			["14x14/Duplicate"] = { 0, 28, 360, 388 },
			["14x14/Edit"] = { 28, 56, 360, 388 },
			["14x14/Expire"] = { 56, 84, 360, 388 },
			["14x14/Filter"] = { 84, 112, 360, 388 },
			["14x14/Groups"] = { 112, 140, 360, 388 },
			["14x14/Help"] = { 140, 168, 380, 408 },
			["14x14/Ignore"] = { 0, 28, 388, 416 },
			["14x14/Import"] = { 28, 56, 388, 416 },
			["14x14/Inventory"] = { 56, 84, 388, 416 },
			["14x14/Link"] = { 84, 112, 388, 416 },
			["14x14/More"] = { 112, 140, 388, 416 },
			["14x14/New"] = { 168, 196, 380, 408 },
			["14x14/Operations"] = { 196, 224, 380, 408 },
			["14x14/Pause"] = { 224, 252, 380, 408 },
			["14x14/Post"] = { 252, 280, 380, 408 },
			["14x14/Posting"] = { 280, 308, 380, 408 },
			["14x14/Queue"] = { 308, 336, 392, 420 },
			["14x14/Reset"] = { 336, 364, 392, 420 },
			["14x14/Resize"] = { 364, 392, 400, 428 },
			["14x14/Running"] = { 392, 420, 416, 444 },
			["14x14/SaleRate"] = { 420, 448, 416, 444 },
			["14x14/Search"] = { 448, 476, 416, 444 },
			["14x14/Settings"] = { 476, 504, 416, 444 },
			["14x14/Shopping"] = { 140, 168, 408, 436 },
			["14x14/SideArrow"] = { 0, 28, 416, 444 },
			["14x14/SkillUp"] = { 28, 56, 416, 444 },
			["14x14/SkillUp/1"] = { 56, 84, 416, 444 },
			["14x14/SkillUp/10"] = { 84, 112, 416, 444 },
			["14x14/SkillUp/2"] = { 112, 140, 416, 444 },
			["14x14/SkillUp/3"] = { 168, 196, 408, 436 },
			["14x14/SkillUp/4"] = { 196, 224, 408, 436 },
			["14x14/SkillUp/5"] = { 224, 252, 408, 436 },
			["14x14/SkillUp/6"] = { 252, 280, 408, 436 },
			["14x14/SkillUp/7"] = { 280, 308, 408, 436 },
			["14x14/SkillUp/8"] = { 308, 336, 420, 448 },
			["14x14/SkillUp/9"] = { 336, 364, 420, 448 },
			["14x14/Skip"] = { 364, 392, 428, 456 },
			["14x14/Sniper"] = { 392, 420, 444, 472 },
			["14x14/Star/Filled"] = { 420, 448, 444, 472 },
			["14x14/Star/Unfilled"] = { 448, 476, 444, 472 },
			["14x14/Stop"] = { 476, 504, 444, 472 },
			["14x14/Subtract/Circle"] = { 140, 168, 436, 464 },
			["14x14/Subtract/Default"] = { 0, 28, 444, 472 },
			["18x18/Add/Circle"] = { 472, 508, 0, 36 },
			["18x18/Add/Default"] = { 472, 508, 36, 72 },
			["18x18/Arrow/Down"] = { 336, 372, 36, 72 },
			["18x18/Arrow/Up"] = { 336, 372, 72, 108 },
			["18x18/Auctions"] = { 468, 504, 72, 108 },
			["18x18/Bid"] = { 468, 504, 108, 144 },
			["18x18/Boxes"] = { 336, 372, 108, 144 },
			["18x18/Buyout"] = { 432, 468, 144, 180 },
			["18x18/Carot/Collapsed"] = { 468, 504, 144, 180 },
			["18x18/Carot/Expanded"] = { 384, 420, 164, 200 },
			["18x18/Checkmark/Circle"] = { 420, 456, 180, 216 },
			["18x18/Checkmark/Default"] = { 456, 492, 180, 216 },
			["18x18/Chevron/Collapsed"] = { 0, 36, 180, 216 },
			["18x18/Chevron/Expanded"] = { 36, 72, 180, 216 },
			["18x18/Chevron/Inactive"] = { 72, 108, 180, 216 },
			["18x18/Clock"] = { 108, 144, 180, 216 },
			["18x18/Close/Circle"] = { 144, 180, 180, 216 },
			["18x18/Close/Default"] = { 180, 216, 180, 216 },
			["18x18/Coins"] = { 216, 252, 180, 216 },
			["18x18/Configure"] = { 252, 288, 180, 216 },
			["18x18/Crafting"] = { 288, 324, 180, 216 },
			["18x18/Dashboard"] = { 324, 360, 192, 228 },
			["18x18/Delete"] = { 384, 420, 200, 236 },
			["18x18/DragHandle"] = { 420, 456, 216, 252 },
			["18x18/Duplicate"] = { 384, 420, 236, 272 },
			["18x18/Edit"] = { 456, 492, 216, 252 },
			["18x18/Expire"] = { 420, 456, 252, 288 },
			["18x18/Filter"] = { 456, 492, 252, 288 },
			["18x18/Groups"] = { 0, 36, 216, 252 },
			["18x18/Help"] = { 36, 72, 216, 252 },
			["18x18/Ignore"] = { 72, 108, 216, 252 },
			["18x18/Import"] = { 108, 144, 216, 252 },
			["18x18/Inventory"] = { 144, 180, 216, 252 },
			["18x18/Link"] = { 180, 216, 216, 252 },
			["18x18/More"] = { 216, 252, 216, 252 },
			["18x18/New"] = { 252, 288, 216, 252 },
			["18x18/Operations"] = { 288, 324, 216, 252 },
			["18x18/Pause"] = { 324, 360, 228, 264 },
			["18x18/Post"] = { 0, 36, 252, 288 },
			["18x18/Posting"] = { 36, 72, 252, 288 },
			["18x18/Queue"] = { 72, 108, 252, 288 },
			["18x18/Reset"] = { 108, 144, 252, 288 },
			["18x18/Resize"] = { 144, 180, 252, 288 },
			["18x18/Running"] = { 180, 216, 252, 288 },
			["18x18/SaleRate"] = { 216, 252, 252, 288 },
			["18x18/Search"] = { 252, 288, 252, 288 },
			["18x18/Settings"] = { 288, 324, 252, 288 },
			["18x18/Shopping"] = { 324, 360, 264, 300 },
			["18x18/SideArrow"] = { 384, 420, 272, 308 },
			["18x18/SkillUp"] = { 420, 456, 288, 324 },
			["18x18/SkillUp/1"] = { 384, 420, 308, 344 },
			["18x18/SkillUp/10"] = { 456, 492, 288, 324 },
			["18x18/SkillUp/2"] = { 420, 456, 324, 360 },
			["18x18/SkillUp/3"] = { 456, 492, 324, 360 },
			["18x18/SkillUp/4"] = { 0, 36, 288, 324 },
			["18x18/SkillUp/5"] = { 36, 72, 288, 324 },
			["18x18/SkillUp/6"] = { 72, 108, 288, 324 },
			["18x18/SkillUp/7"] = { 108, 144, 288, 324 },
			["18x18/SkillUp/8"] = { 144, 180, 288, 324 },
			["18x18/SkillUp/9"] = { 180, 216, 288, 324 },
			["18x18/Skip"] = { 216, 252, 288, 324 },
			["18x18/Sniper"] = { 252, 288, 288, 324 },
			["18x18/Star/Filled"] = { 288, 324, 288, 324 },
			["18x18/Star/Unfilled"] = { 324, 360, 300, 336 },
			["18x18/Stop"] = { 0, 36, 324, 360 },
			["18x18/Subtract/Circle"] = { 36, 72, 324, 360 },
			["18x18/Subtract/Default"] = { 72, 108, 324, 360 },
			["24x24/Auctions"] = { 376, 424, 0, 48 },
			["24x24/Bid"] = { 424, 472, 0, 48 },
			["24x24/Boxes"] = { 0, 48, 36, 84 },
			["24x24/Buyout"] = { 48, 96, 36, 84 },
			["24x24/Close/Circle"] = { 96, 144, 36, 84 },
			["24x24/Close/Default"] = { 144, 192, 36, 84 },
			["24x24/Coins"] = { 192, 240, 36, 84 },
			["24x24/Crafting"] = { 240, 288, 36, 84 },
			["24x24/Dashboard"] = { 288, 336, 36, 84 },
			["24x24/Groups"] = { 372, 420, 48, 96 },
			["24x24/Import"] = { 420, 468, 48, 96 },
			["24x24/Inventory"] = { 372, 420, 96, 144 },
			["24x24/Mail"] = { 420, 468, 96, 144 },
			["24x24/Operations"] = { 0, 48, 84, 132 },
			["24x24/Other"] = { 48, 96, 84, 132 },
			["24x24/Pause"] = { 96, 144, 84, 132 },
			["24x24/Post"] = { 144, 192, 84, 132 },
			["24x24/Posting"] = { 192, 240, 84, 132 },
			["24x24/Send Mail"] = { 240, 288, 84, 132 },
			["24x24/Settings"] = { 288, 336, 84, 132 },
			["24x24/Shopping"] = { 0, 48, 132, 180 },
			["24x24/Skip"] = { 48, 96, 132, 180 },
			["24x24/Sniper"] = { 96, 144, 132, 180 },
			["24x24/Stop"] = { 144, 192, 132, 180 },
			["Misc/BackArrow"] = { 384, 432, 144, 164 },
			["Misc/Checkbox/Checked"] = { 192, 240, 132, 180 },
			["Misc/Checkbox/Checked/Disabled"] = { 240, 288, 132, 180 },
			["Misc/Checkbox/Unchecked"] = { 288, 336, 132, 180 },
			["Misc/Checkbox/Unchecked/Disabled"] = { 336, 384, 144, 192 },
			["Misc/Knob"] = { 108, 144, 324, 360 },
			["Misc/Toggle/Off"] = { 0, 94, 0, 36 },
			["Misc/Toggle/Off/Disabled"] = { 94, 188, 0, 36 },
			["Misc/Toggle/On"] = { 188, 282, 0, 36 },
			["Misc/Toggle/On/Disabled"] = { 282, 376, 0, 36 },
		},
	},
}



-- ============================================================================
-- Module Functions
-- ============================================================================

function TexturePacks.IsValid(key)
	-- if not key then return false end
	local fileInfo, coord = private.GetFileInfo(key)
	return fileInfo and coord and true or false
end

function TexturePacks.GetTexturePath(key)
	local fileInfo = private.GetFileInfo(key)
	assert(fileInfo)
	return fileInfo.path
end

function TexturePacks.GetTexCoord(key)
	local fileInfo, coord = private.GetFileInfo(key)
	assert(fileInfo and coord)
	local minX, maxX, minY, maxY = unpack(coord)
	minX = minX / fileInfo.width
	maxX = maxX / fileInfo.width
	minY = minY / fileInfo.height
	maxY = maxY / fileInfo.height
	return minX, maxX, minY, maxY
end

function TexturePacks.GetTexCoordRotated(key, angle)
	return private.RotateTexCoords(angle, TexturePacks.GetTexCoord(key))
end

function TexturePacks.GetSize(key)
	local fileInfo, coord = private.GetFileInfo(key)
	assert(fileInfo and coord)
	local minX, maxX, minY, maxY = unpack(coord)
	local width = (maxX - minX) / fileInfo.scale
	local height = (maxY - minY) / fileInfo.scale
	return width, height
end

function TexturePacks.GetWidth(key)
	local width = TexturePacks.GetSize(key)
	return width
end

function TexturePacks.GetHeight(key)
	local _, height = TexturePacks.GetSize(key)
	return height
end

function TexturePacks.SetTexture(texture, key)
	texture:SetTexture(TexturePacks.GetTexturePath(key))
	texture:SetTexCoord(TexturePacks.GetTexCoord(key))
end

function TexturePacks.SetTextureRotated(texture, key, angle)
	texture:SetTexture(TexturePacks.GetTexturePath(key))
	texture:SetTexCoord(TexturePacks.GetTexCoordRotated(key, angle))
end

function TexturePacks.SetSize(texture, key)
	local width, height = TexturePacks.GetSize(key)
	texture:SetWidth(width)
	texture:SetHeight(height)
end

function TexturePacks.SetWidth(texture, key)
	texture:SetWidth(TexturePacks.GetWidth(key))
end

function TexturePacks.SetHeight(texture, key)
	texture:SetHeight(TexturePacks.GetHeight(key))
end

function TexturePacks.SetTextureAndWidth(texture, key)
	TexturePacks.SetTexture(texture, key)
	TexturePacks.SetWidth(texture, key)
end

function TexturePacks.SetTextureAndHeight(texture, key)
	TexturePacks.SetTexture(texture, key)
	TexturePacks.SetHeight(texture, key)
end

function TexturePacks.SetTextureAndSize(texture, key)
	TexturePacks.SetTexture(texture, key)
	TexturePacks.SetSize(texture, key)
end

function TexturePacks.SetTextureAndSizeRotated(texture, key, angle)
	TexturePacks.SetTextureRotated(texture, key, angle)
	TexturePacks.SetSize(texture, key)
end



-- ============================================================================
-- Private Helper Functions
-- ============================================================================

function private.GetFileInfo(key)
	local file, entry = strmatch(key, "^([^%.]+)%.(.+)$")
	local fileInfo = file and TEXTURE_FILE_INFO[file]
	return fileInfo, fileInfo and fileInfo.coord[entry]
end

function private.RotateTexCoords(angle, minX, maxX, minY, maxY)
	local centerX = (minX + maxX) / 2
	local centerY = (minY + maxY) / 2
	local ULx, ULy = private.RotateCoordPair(minX, minY, centerX, centerY, angle)
	local LLx, LLy = private.RotateCoordPair(minX, maxY, centerX, centerY, angle)
	local URx, URy = private.RotateCoordPair(maxX, minY, centerX, centerY, angle)
	local LRx, LRy = private.RotateCoordPair(maxX, maxY, centerX, centerY, angle)
	return ULx, ULy, LLx, LLy, URx, URy, LRx, LRy
end

function private.RotateCoordPair(x, y, originX, originY, angle)
	local cosResult = cos(angle)
	local sinResult = sin(angle)
	local resultX = originX + (x - originX) * cosResult - (y - originY) * sinResult
	local resultY = originY + (y - originY) * cosResult + (x - originX) * sinResult
	return resultX, resultY
end
