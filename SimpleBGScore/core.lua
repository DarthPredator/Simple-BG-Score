local SBGS = LibStub("AceAddon-3.0"):NewAddon("SimpleBGScore", "AceEvent-3.0") --, "AceHook-3.0")
local AddOnName, Engine = ...;

local _G = _G

local Holder = CreateFrame("Frame", "SBGSHolder", UIParent)

--functions
local ShowUIPanel, HideUIPanel = ShowUIPanel, HideUIPanel
local UnitName = UnitName
local ConfirmOrLeaveBattlefield = ConfirmOrLeaveBattlefield
local GetBattlefieldWinner, IsActiveBattlefieldArena = GetBattlefieldWinner, IsActiveBattlefieldArena
local GetCurrentMapAreaID = GetCurrentMapAreaID
local IsInInstance = IsInInstance
local GetNumBattlefieldScores, GetBattlefieldScore, GetBattlefieldStatInfo, GetBattlefieldStatData, GetBattlefieldTeamInfo = GetNumBattlefieldScores, GetBattlefieldScore, GetBattlefieldStatInfo, GetBattlefieldStatData, GetBattlefieldTeamInfo
local select, format, tostring = select, format, tostring
--strings
local RED_FONT_COLOR_CODE = RED_FONT_COLOR_CODE
local STATUS = STATUS
local VICTORY_TEXT0, VICTORY_TEXT1 = VICTORY_TEXT0, VICTORY_TEXT1
local HONORABLE_KILLS, KILLING_BLOWS, DAMAGE, DEATHS, SHOW_COMBAT_HEALING, HONOR = HONORABLE_KILLS, KILLING_BLOWS, DAMAGE, DEATHS, SHOW_COMBAT_HEALING, HONOR
local LEAVE_BATTLEGROUND, LEAVE_ARENA = LEAVE_BATTLEGROUND, LEAVE_ARENA
local ARENA_TEAM_NAME_GREEN, ARENA_TEAM_NAME_GOLD, VICTORY_TEXT_ARENA_WINS, VICTORY_TEXT_ARENA_DRAW, RATING_CHANGE = ARENA_TEAM_NAME_GREEN, ARENA_TEAM_NAME_GOLD, VICTORY_TEXT_ARENA_WINS, VICTORY_TEXT_ARENA_DRAW, RATING_CHANGE
local STAT_TEMPLATE = STAT_TEMPLATE
local SHOW, ALL = SHOW, ALL
local NormText = "Interface/Buttons/UI-Panel-Button-Up"
local HighText = "Interface/Buttons/UI-Panel-Button-Highlight"
local InProcessText = "|cffff8800"..WINTERGRASP_IN_PROGRESS.."|r"

local BS = {
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3, },
}

local FactionToken, Faction = UnitFactionGroup("player")
local WSG = 443
local TP = 626
local AV = 401
local SOTA = 512
local IOC = 540
-- local EOTS = 482
local TBFG = 736
local AB = 461
local TOK = 856
-- local SSM = 860
local DWG = 935
local name, myName, inInstance, instanceType, Path, Size, Flags 

function SBGS:CreateFrame()
	Holder:SetSize(400, 280)
	Holder:SetPoint("CENTER", UIParent, "CENTER", 0, 150)
	Holder:SetFrameStrata("HIGH")
	Holder:Hide()
	Holder.shown = false
	Holder:SetScript("OnShow", SBGS.OnShow)
	Holder:SetScript("OnHide", SBGS.OnHide)

	Holder.model = CreateFrame("PlayerModel", "SBGSModel", Holder);
	Holder.playerFaction = Holder:CreateTexture(nil, 'ARTWORK')
	Holder.button = CreateFrame("Button", "SBGSShowAllButton", Holder)
	Holder.leave = CreateFrame("Button", "SBGSLeaveButton", Holder)
	Holder.close = CreateFrame("Button", "SBGSCloseButton", Holder, "UIPanelButtonTemplate")
	local button, model, playerFaction, leave, close = Holder.button, Holder.model, Holder.playerFaction, Holder.leave, Holder.close

	Holder:SetBackdrop(BS)
	Holder:SetBackdropColor(0, 0, 0, 1)

	model:SetPoint("BOTTOMLEFT", Holder,"BOTTOMLEFT", 2, 2);
	model:SetPoint("TOPRIGHT", Holder,"TOPLEFT", 152, -4);

	playerFaction:SetPoint("BOTTOMRIGHT", Holder,"BOTTOMRIGHT", -4, 4)
	playerFaction:SetPoint("TOPLEFT", Holder,"TOPLEFT", 4, -4)

	button:SetSize(110, 20)
	button:SetPoint("BOTTOMLEFT", model, "BOTTOMRIGHT", 4, 4)
	button.pushed = false
	button:SetScript("OnClick", function() button.pushed = true; ShowUIPanel(WorldStateScoreFrame); Holder:Hide() end)

	button.NormTex = button:CreateTexture()
	button.NormTex:SetTexture(NormText)
	button.NormTex:SetTexCoord(0, 0.625, 0, 0.6875)
	button.NormTex:SetAllPoints()
	button:SetNormalTexture(button.NormTex)

	button.HighTex = button:CreateTexture()
	button.HighTex:SetTexture(HighText)
	button.HighTex:SetTexCoord(0, 0.625, 0, 0.6875)
	button.HighTex:SetAllPoints()
	button:SetHighlightTexture(button.HighTex)

	leave:SetSize(130, 20)
	leave:SetPoint("LEFT", button, "RIGHT", 0, 0)
	leave:SetScript("OnClick", function() ConfirmOrLeaveBattlefield() end)

	leave.NormTex = leave:CreateTexture()
	leave.NormTex:SetTexture(NormText)
	leave.NormTex:SetTexCoord(0, 0.625, 0, 0.6875)
	leave.NormTex:SetAllPoints()	
	leave:SetNormalTexture(leave.NormTex)

	leave.HighTex = leave:CreateTexture()
	leave.HighTex:SetTexture(HighText)
	leave.HighTex:SetTexCoord(0, 0.625, 0, 0.6875)
	leave.HighTex:SetAllPoints()
	leave:SetHighlightTexture(leave.HighTex)

	close:SetSize(18, 18)
	close:SetPoint("TOPRIGHT", Holder, "TOPRIGHT", -4, -4)
	close:SetScript("OnClick", function() button.pushed = false; Holder:Hide() end)

	if ElvUI then
		Holder:StripTextures()
		Holder:SetTemplate("Transparent")
		ElvUI[1]:GetModule("Skins"):HandleButton(button)
		ElvUI[1]:GetModule("Skins"):HandleButton(leave)
		ElvUI[1]:GetModule("Skins"):HandleButton(close)
		playerFaction:SetPoint("BOTTOMRIGHT", Holder,"BOTTOMRIGHT", -2, 2)
		playerFaction:SetPoint("TOPLEFT", Holder,"TOPLEFT", 2, -2)
	elseif Tukui then
		Holder:StripTextures()
		Holder:SetTemplate("Transparent")
		button:SkinButton()
		leave:SkinButton()
		close:SkinButton()
		playerFaction:SetPoint("BOTTOMRIGHT", Holder,"BOTTOMRIGHT", -2, 2)
		playerFaction:SetPoint("TOPLEFT", Holder,"TOPLEFT", 2, -2)
	end
end

function SBGS:AnimFinished(anim)
	Holder.model:SetAnimation(anim)
end

function SBGS:OnEvent()
	local winner = GetBattlefieldWinner()
	local isArena, isRegistered = IsActiveBattlefieldArena()
	SBGS:SetTexts(winner, isArena, isRegistered)
end

function SBGS:Comma(str)
	str = tostring(str)   -- now you can feed it numbers instead of strings
	local prefix, number, suffix = str:match"(%D*%d)(%d+)(%D*)"
	if prefix and number then
		return prefix .. number:reverse():gsub("(%d%d%d)","%1,"):reverse() .. suffix
	else
		return str
	end
end

function SBGS:OnShow()
	local winner = GetBattlefieldWinner()
	local isArena, isRegistered = IsActiveBattlefieldArena()
	local anim = 47
	if isArena then
		anim = 113
		Holder.playerFaction:SetTexture("Interface\\PVPFrame\\PvpBg-NagrandArena-ToastBG")
	else
		Holder.playerFaction:SetTexture("Interface\\LFGFrame\\UI-PVP-BACKGROUND-"..FactionToken)
		if winner == 0 then
			anim = FactionToken == "Horde" and 68 or 77
		elseif winner == 1 then
			anim = FactionToken == "Alliance" and 68 or 77
		end
	end
	Holder.playerFaction:SetAlpha(0.5)
	
	Holder.model:SetUnit('player')
	Holder.model:SetAnimation(anim)
	Holder.model:SetPosition(0.2, 0, -0.2) --(pos/neg) first number moves closer/farther, second right/left, third up/down
	Holder.model:SetScript("OnAnimFinished", function() SBGS:AnimFinished(anim) end)

	SBGS:SetTexts(winner, isArena, isRegistered)
	Holder.shown = true
end

function SBGS:OnHide()
	Holder.shown = false
end

function SBGS:SetTexts(winner, isArena, isRegistered)
	for i = 1, 22 do
		Holder["String"..i].text:SetText("")
	end

	if isArena then
		SBGS:SetTextArena(winner, isRegistered)
	else
		SBGS:SetTextBG(winner)
	end
end

function SBGS:SetTextBG(winner)
	local CurrentMapID = GetCurrentMapAreaID()
	--Winner text
	Holder.String1.text:SetText(STATUS..":")
	Holder.String12.text:SetText(winner == 0 and RED_FONT_COLOR_CODE..VICTORY_TEXT0.."|r" or winner == 1 and "|cff0070dd"..VICTORY_TEXT1.."|r" or InProcessText)
	--Stats labels
	Holder.String2.text:SetText(HONORABLE_KILLS..":")
	Holder.String3.text:SetText(KILLING_BLOWS..":")
	Holder.String4.text:SetText(DEATHS..":")
	Holder.String5.text:SetText(DAMAGE..":")
	Holder.String6.text:SetText(SHOW_COMBAT_HEALING..":")
	Holder.String7.text:SetText(HONOR..":")
	for index=1, GetNumBattlefieldScores() do
		name = GetBattlefieldScore(index)
		if name == myName then
				Holder.String13.text:SetText(select(3, GetBattlefieldScore(index))) --Honor kills
				Holder.String14.text:SetText(select(2, GetBattlefieldScore(index))) --Killing blows
				Holder.String15.text:SetText(select(4, GetBattlefieldScore(index))) --Deathes
				Holder.String16.text:SetText(SBGS:Comma(select(10, GetBattlefieldScore(index)))) --Damage
				Holder.String17.text:SetText(SBGS:Comma(select(11, GetBattlefieldScore(index)))) --Healing
				Holder.String18.text:SetText(select(5, GetBattlefieldScore(index))) --Honor
				--Mechanics texts
				Holder.String8.text:SetText(GetBattlefieldStatInfo(1)..":")
				Holder.String19.text:SetText(GetBattlefieldStatData(index, 1))
			if CurrentMapID == WSG or CurrentMapID == TP then
				Holder.String9.text:SetText(GetBattlefieldStatInfo(2)..":")
				Holder.String20.text:SetText(GetBattlefieldStatData(index, 2))
			-- elseif CurrentMapID == EOTS then
			elseif CurrentMapID == AV then
				Holder.String9.text:SetText(GetBattlefieldStatInfo(2)..":")
				Holder.String10.text:SetText(GetBattlefieldStatInfo(3)..":")
				Holder.String11.text:SetText(GetBattlefieldStatInfo(4)..":")

				Holder.String20.text:SetText(GetBattlefieldStatData(index, 2))
				Holder.String21.text:SetText(GetBattlefieldStatData(index, 3))
				Holder.String22.text:SetText(GetBattlefieldStatData(index, 4))
			elseif CurrentMapID == SOTA then
				Holder.String9.text:SetText(GetBattlefieldStatInfo(2)..":")
				Holder.String20.text:SetText(GetBattlefieldStatData(index, 2))
			elseif CurrentMapID == IOC or CurrentMapID == TBFG or CurrentMapID == AB then
				Holder.String9.text:SetText(GetBattlefieldStatInfo(2)..":")
				Holder.String20.text:SetText(GetBattlefieldStatData(index, 2))
			elseif CurrentMapID == TOK then
				Holder.String9.text:SetText(GetBattlefieldStatInfo(2)..":")
				Holder.String20.text:SetText(GetBattlefieldStatData(index, 2))
			-- elseif CurrentMapID == SSM then
			elseif CurrentMapID == DWG then
				Holder.String9.text:SetText(GetBattlefieldStatInfo(2)..":")
				Holder.String10.text:SetText(GetBattlefieldStatInfo(3)..":")
				Holder.String11.text:SetText(GetBattlefieldStatInfo(4)..":")

				Holder.String20.text:SetText(GetBattlefieldStatData(index, 2))
				Holder.String21.text:SetText(GetBattlefieldStatData(index, 3))
				Holder.String22.text:SetText(GetBattlefieldStatData(index, 4))
			end
			break
		end
	end

	Holder.leave.text:SetText(LEAVE_BATTLEGROUND)
end

function SBGS:SetTextArena(winner, isRegistered)
	-- local winner = GetBattlefieldWinner()
	Holder.String1.text:SetText(STATUS..":")
	if winner then
		if isRegistered then
			if ( GetBattlefieldTeamInfo(winner) ) then
				local teamName = winner == 0 and ARENA_TEAM_NAME_GREEN or ARENA_TEAM_NAME_GOLD
				local text = format(VICTORY_TEXT_ARENA_WINS, teamName)
				local color = winner == 0 and "|cffabd473" or "|cfffff569"
				Holder.String12.text:SetText(color..text.."|r");
			else
				Holder.String12.text:SetText("|cffff8800"..VICTORY_TEXT_ARENA_DRAW.."|r");
			end
		else
			Holder.String12.text:SetText(_G["VICTORY_TEXT_ARENA"..winner])
		end
	else
		Holder.String12.text:SetText(InProcessText)
	end

	Holder.String2.text:SetText(DAMAGE..":")
	Holder.String3.text:SetText(SHOW_COMBAT_HEALING..":")
	Holder.String4.text:SetText(KILLING_BLOWS..":")
	Holder.String5.text:SetText(RATING_CHANGE..":")

	for index=1, GetNumBattlefieldScores() do
		name = GetBattlefieldScore(index)
		if name == myName then
			Holder.String13.text:SetText(SBGS:Comma(select(10, GetBattlefieldScore(index))))
			Holder.String14.text:SetText(SBGS:Comma(select(11, GetBattlefieldScore(index))))
			Holder.String15.text:SetText(select(2, GetBattlefieldScore(index)))
			if isRegistered then
				Holder.String16.text:SetText(select(13, GetBattlefieldScore(index)))
			else
				Holder.String16.text:SetText("0")
			end
			break
		end
	end

	Holder.leave.text:SetText(LEAVE_ARENA)
end

function SBGS:OnInitialize()
   	self:CreateFrame()

	myName = UnitName('player')

	Path, Size, Flags = GameTooltipHeader:GetFont()

	Holder.Title = CreateFrame("Frame", "SBGSTitle", Holder)
	Holder.Title:SetSize(240, 20)
	Holder.Title:SetPoint("TOPRIGHT", Holder, "TOPRIGHT", -4, -4)
	Holder.Title.text = Holder.Title:CreateFontString(nil, "OVERLAY")
	Holder.Title.text:SetPoint("CENTER", Holder.Title, "CENTER", 0, 0)
	Holder.Title.text:SetFont(Path, 14, Flags)
	Holder.Title.text:SetText(format(STAT_TEMPLATE, myName))
	for i = 1, 22 do
		Holder["String"..i] = CreateFrame("Frame", "SBGSString"..i, Holder)
		if i == 1 then
			Holder["String"..i]:SetSize(80, 20)
		elseif i >= 1 and i < 12 then
			Holder["String"..i]:SetSize(140, 20)
		elseif i == 12 then
			Holder["String"..i]:SetSize(160, 20)
		else
			Holder["String"..i]:SetSize(100, 20)
		end
		-- Holder["String"..i]:CreateBackdrop()
		if i == 1 then
			Holder["String"..i]:SetPoint("TOPLEFT", Holder.Title, "BOTTOMLEFT", 0, -2)
		elseif i == 12 then
			Holder["String"..i]:SetPoint("LEFT", Holder.String1, "RIGHT", 2, 0)
		elseif i == 2 then
			Holder["String"..i]:SetPoint("TOPLEFT", Holder.String1, "BOTTOMLEFT", 0, 0)
		elseif i == 13 then
			Holder["String"..i]:SetPoint("LEFT", Holder.String2, "RIGHT", 2, 0)
		else
			Holder["String"..i]:SetPoint("TOP", Holder["String"..(i-1)], "BOTTOM", 0, 0)
		end
		Holder["String"..i].text = Holder["String"..i]:CreateFontString(nil, "OVERLAY")
		Holder["String"..i].text:SetPoint("LEFT", Holder["String"..i], "LEFT", 2, 0)
		Holder["String"..i].text:SetFont(Path, 12, Flags)
		-- Holder["String"..i].text:SetText("Test text "..i)
	end
	local button, leave, close = Holder.button, Holder.leave, Holder.close

	button.text = button:CreateFontString(nil, "OVERLAY")
	button.text:SetPoint("CENTER", button, "CENTER", 0, 0)
	button.text:SetFont(Path, 12, Flags)
	button.text:SetText(SHOW.." "..ALL)

	leave.text = leave:CreateFontString(nil, "OVERLAY")
	leave.text:SetPoint("CENTER", leave, "CENTER", 0, 0)
	leave.text:SetFont(Path, 12, Flags)
	leave.text:SetText("")

	close.text = close:CreateFontString(nil, "OVERLAY")
	close.text:SetPoint("CENTER", close, "CENTER", 0, 0)
	close.text:SetFont(Path, 10, Flags)
	close.text:SetText("X")

	--Hook stuff
	WorldStateScoreFrame:HookScript("OnShow", function()
		inInstance, instanceType = IsInInstance()
		if not (inInstance and (instanceType == "pvp")) and not (inInstance and (instanceType == "arena")) then return end --Just in case
		if not Holder.button.pushed and not Holder.shown then
			HideUIPanel(WorldStateScoreFrame)
			Holder:Show()
		elseif not Holder.button.pushed and Holder.shown then
			HideUIPanel(WorldStateScoreFrame)
			Holder:Hide()
		end
	end)
	WorldStateScoreFrame:HookScript("OnHide", function() Holder.button.pushed = false end)

	self:RegisterEvent('UPDATE_BATTLEFIELD_SCORE', SBGS.OnEvent)
	hooksecurefunc("LeaveBattlefield", function() Holder:Hide() end)

	--Enabling dragging around
	Holder:EnableMouse(true)
	Holder:SetMovable(true)

	Holder:RegisterForDrag("LeftButton")
	Holder:SetScript("OnDragStart", function(self) 
			self:StartMoving()
	end)

	Holder:SetScript("OnDragStop", function(self) 
			self:StopMovingOrSizing()
	end)

	--Registe to plugin list in ElvUI
	if ElvUI then
		local EP = LibStub("LibElvUIPlugin-1.0")
		EP:RegisterPlugin(AddOnName)
	end
end
