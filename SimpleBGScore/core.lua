local SBGS = LibStub("AceAddon-3.0"):NewAddon("SimpleBGScore", "AceEvent-3.0") --, "AceHook-3.0")
local AddOnName, Engine = ...;

local Holder = CreateFrame("Frame", "SBGSHolder", UIParent)
local model = CreateFrame("PlayerModel", "SBGSModel", Holder);
local playerFaction = SBGSHolder:CreateTexture(nil, 'ARTWORK')
local button = CreateFrame("Button", "SBGSFullButton", Holder)
local leave = CreateFrame("Button", "SBGSLeaveButton", Holder)
local close = CreateFrame("Button", "SBGSCloseButton", Holder, "UIPanelButtonTemplate")

local BS = {
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3, },
}

local FactionToken, Faction = UnitFactionGroup("player")
local title, stat
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
local IsInInstance = IsInInstance
local GetBattlefieldScore, GetBattlefieldStatInfo, GetBattlefieldStatData, GetBattlefieldTeamInfo = GetBattlefieldScore, GetBattlefieldStatInfo, GetBattlefieldStatData, GetBattlefieldTeamInfo
local NormText = "Interface/Buttons/UI-Panel-Button-Up"
local HighText = "Interface/Buttons/UI-Panel-Button-Highlight"
local InProcessText = "|cffff8800"..WINTERGRASP_IN_PROGRESS.."|r"

function SBGS:CreateFrame()
	Holder:SetSize(400, 280)
	Holder:SetPoint("CENTER", UIParent, "CENTER", 0, 150)
	Holder:SetFrameStrata("HIGH")
	Holder:Hide()
	Holder:SetScript("OnShow", SBGS.OnShow)

	Holder:SetBackdrop(BS)
	Holder:SetBackdropColor(0, 0, 0, 1)

	model:SetPoint("BOTTOMLEFT", Holder,"BOTTOMLEFT", 2, 2);
	model:SetPoint("TOPRIGHT", Holder,"TOPLEFT", 152, -4);

	playerFaction:SetPoint("BOTTOMRIGHT", Holder,"BOTTOMRIGHT", -4, 4)
	playerFaction:SetPoint("TOPLEFT", Holder,"TOPLEFT", 4, -4)

	button:SetSize(110, 20)
	button:SetPoint("BOTTOMLEFT", model, "BOTTOMRIGHT", 4, 4)
	button.pushed = false
	button:SetScript("OnClick", function() button.pushed = true; ShowUIPanel(WorldStateScoreFrame); SBGSHolder:Hide() end)

	local bntex = button:CreateTexture()
	bntex:SetTexture(NormText)
	bntex:SetTexCoord(0, 0.625, 0, 0.6875)
	bntex:SetAllPoints()	
	button:SetNormalTexture(bntex)

	local bhtex = button:CreateTexture()
	bhtex:SetTexture(HighText)
	bhtex:SetTexCoord(0, 0.625, 0, 0.6875)
	bhtex:SetAllPoints()
	button:SetHighlightTexture(bhtex)

	leave:SetSize(130, 20)
	leave:SetPoint("LEFT", button, "RIGHT", 0, 0)
	leave:SetScript("OnClick", function() ConfirmOrLeaveBattlefield() end)

	local lntex = leave:CreateTexture()
	lntex:SetTexture(NormText)
	lntex:SetTexCoord(0, 0.625, 0, 0.6875)
	lntex:SetAllPoints()	
	leave:SetNormalTexture(lntex)

	local lhtex = leave:CreateTexture()
	lhtex:SetTexture(HighText)
	lhtex:SetTexCoord(0, 0.625, 0, 0.6875)
	lhtex:SetAllPoints()
	leave:SetHighlightTexture(lhtex)

	close:SetSize(18, 18)
	close:SetPoint("TOPRIGHT", Holder, "TOPRIGHT", -4, -4)
	close:SetScript("OnClick", function() button.pushed = false; SBGSHolder:Hide() end)

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
	model:SetAnimation(anim)
end

function SBGS:OnEvent()
	local winner = GetBattlefieldWinner()
	local isArena, isRegistered = IsActiveBattlefieldArena()
	SBGS:SetTexts(winner, isArena, isRegistered)
end

function SBGS:OnShow()
	local winner = GetBattlefieldWinner()
	local isArena, isRegistered = IsActiveBattlefieldArena()
	local anim = 47
	if isArena then
		anim = 113
		playerFaction:SetTexture("Interface\\PVPFrame\\PvpBg-NagrandArena-ToastBG")
	else
		playerFaction:SetTexture("Interface\\LFGFrame\\UI-PVP-BACKGROUND-"..FactionToken)
		if winner == 0 then
			anim = FactionToken == "Horde" and 68 or 77
		elseif winner == 1 then
			anim = FactionToken == "Alliance" and 68 or 77
		end
	end
	playerFaction:SetAlpha(0.5)
	
	model:SetUnit('player')
	model:SetAnimation(anim)
	model:SetPosition(0.2, 0, -0.2) --(pos/neg) first number moves closer/farther, second right/left, third up/down
	model:SetScript("OnAnimFinished", function() SBGS:AnimFinished(anim) end)

	SBGS:SetTexts(winner, isArena, isRegistered)
end

function SBGS:SetTexts(winner, isArena, isRegistered)
	for i = 1, 22 do
		_G["SBGSText"..i].text:SetText("")
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
	SBGSText1.text:SetText(STATUS..":")
	SBGSText12.text:SetText(winner == 0 and RED_FONT_COLOR_CODE..VICTORY_TEXT0.."|r" or winner == 1 and "|cff0070dd"..VICTORY_TEXT1.."|r" or InProcessText)
	--Stats labels
	SBGSText2.text:SetText(HONORABLE_KILLS..":")
	SBGSText3.text:SetText(KILLING_BLOWS..":")
	SBGSText4.text:SetText(DEATHS..":")
	SBGSText5.text:SetText(DAMAGE..":")
	SBGSText6.text:SetText(SHOW_COMBAT_HEALING..":")
	SBGSText7.text:SetText(HONOR..":")
	for index=1, GetNumBattlefieldScores() do
		name = GetBattlefieldScore(index)
		if name == myName then
				SBGSText13.text:SetText(select(3, GetBattlefieldScore(index))) --Honor kills
				SBGSText14.text:SetText(select(2, GetBattlefieldScore(index))) --Killing blows
				SBGSText15.text:SetText(select(4, GetBattlefieldScore(index))) --Deathes
				SBGSText16.text:SetText(select(10, GetBattlefieldScore(index))) --Damage
				SBGSText17.text:SetText(select(11, GetBattlefieldScore(index))) --Healing
				SBGSText18.text:SetText(select(5, GetBattlefieldScore(index))) --Honor
				--Mechanics texts
				SBGSText8.text:SetText(GetBattlefieldStatInfo(1)..":")
				SBGSText19.text:SetText(GetBattlefieldStatData(index, 1))
			if CurrentMapID == WSG or CurrentMapID == TP then
				SBGSText9.text:SetText(GetBattlefieldStatInfo(2)..":")
				SBGSText20.text:SetText(GetBattlefieldStatData(index, 2))
			-- elseif CurrentMapID == EOTS then
			elseif CurrentMapID == AV then
				SBGSText9.text:SetText(GetBattlefieldStatInfo(2)..":")
				SBGSText10.text:SetText(GetBattlefieldStatInfo(3)..":")
				SBGSText11.text:SetText(GetBattlefieldStatInfo(4)..":")

				SBGSText20.text:SetText(GetBattlefieldStatData(index, 2))
				SBGSText21.text:SetText(GetBattlefieldStatData(index, 3))
				SBGSText22.text:SetText(GetBattlefieldStatData(index, 4))
			elseif CurrentMapID == SOTA then
				SBGSText9.text:SetText(GetBattlefieldStatInfo(2)..":")
				SBGSText20.text:SetText(GetBattlefieldStatData(index, 2))
			elseif CurrentMapID == IOC or CurrentMapID == TBFG or CurrentMapID == AB then
				SBGSText9.text:SetText(GetBattlefieldStatInfo(2)..":")
				SBGSText20.text:SetText(GetBattlefieldStatData(index, 2))
			elseif CurrentMapID == TOK then
				SBGSText9.text:SetText(GetBattlefieldStatInfo(2)..":")
				SBGSText20.text:SetText(GetBattlefieldStatData(index, 2))
			-- elseif CurrentMapID == SSM then
			elseif CurrentMapID == DWG then
				SBGSText9.text:SetText(GetBattlefieldStatInfo(2)..":")
				SBGSText10.text:SetText(GetBattlefieldStatInfo(3)..":")
				SBGSText11.text:SetText(GetBattlefieldStatInfo(4)..":")

				SBGSText20.text:SetText(GetBattlefieldStatData(index, 2))
				SBGSText21.text:SetText(GetBattlefieldStatData(index, 3))
				SBGSText22.text:SetText(GetBattlefieldStatData(index, 4))
			end
			break
		end
	end

	leave.text:SetText(LEAVE_BATTLEGROUND)
end

function SBGS:SetTextArena(winner, isRegistered)
	-- local winner = GetBattlefieldWinner()
	SBGSText1.text:SetText(STATUS..":")
	if winner then
		if isRegistered then
			if ( GetBattlefieldTeamInfo(winner) ) then
				local teamName = winner == 0 and ARENA_TEAM_NAME_GREEN or ARENA_TEAM_NAME_GOLD
				local text = format(VICTORY_TEXT_ARENA_WINS, teamName)
				local color = winner == 0 and "|cffabd473" or "|cfffff569"
				SBGSText12.text:SetText(color..text.."|r");
			else
				SBGSText12.text:SetText("|cffff8800"..VICTORY_TEXT_ARENA_DRAW.."|r");							
			end
		else
			SBGSText12.text:SetText(_G["VICTORY_TEXT_ARENA"..battlefieldWinner])
		end
	else
		SBGSText12.text:SetText(InProcessText)
	end

	SBGSText2.text:SetText(DAMAGE..":")
	SBGSText3.text:SetText(SHOW_COMBAT_HEALING..":")
	SBGSText4.text:SetText(KILLING_BLOWS..":")
	SBGSText5.text:SetText(RATING_CHANGE..":")
	for index=1, GetNumBattlefieldScores() do
		name = GetBattlefieldScore(index)
		if name == myName then
			SBGSText13.text:SetText(select(10, GetBattlefieldScore(index)))
			SBGSText14.text:SetText(select(11, GetBattlefieldScore(index)))
			SBGSText15.text:SetText(select(2, GetBattlefieldScore(index)))
			if isRegistered then
				SBGSText16.text:SetText(select(13, GetBattlefieldScore(index)))
			else
				SBGSText16.text:SetText("0")
			end
		end
		break
	end

	leave.text:SetText(LEAVE_ARENA)
end

function SBGS:OnInitialize()
   	self:CreateFrame()

	myName = UnitName('player')

	Path, Size, Flags = GameTooltipHeader:GetFont()

	title = CreateFrame("Frame", "SBGSTitle", Holder)
	title:SetSize(240, 20)
	title:SetPoint("TOPRIGHT", Holder, "TOPRIGHT", -4, -4)
	title.text = title:CreateFontString(nil, "OVERLAY")
	title.text:SetPoint("CENTER", title, "CENTER", 0, 0)
	title.text:SetFont(Path, 14, Flags)
	title.text:SetText(format(STAT_TEMPLATE, myName))
	for i = 1, 22 do
		stat = CreateFrame("Frame", "SBGSText"..i, Holder)
		if i < 12 then
			stat:SetSize(140, 20)
		else
			stat:SetSize(100, 20)
		end
		-- stat:CreateBackdrop()
		if i == 1 then
			stat:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)
		elseif i == 12 then
			stat:SetPoint("LEFT", "SBGSText1", "RIGHT", 2, 0)
		else
			stat:SetPoint("TOP", "SBGSText"..(i-1), "BOTTOM", 0, 0)
		end
		stat.text = stat:CreateFontString(nil, "OVERLAY")
		stat.text:SetPoint("LEFT", stat, "LEFT", 2, 0)
		stat.text:SetFont(Path, 12, Flags)
		-- stat.text:SetText("Test text "..i)
	end

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
		if not SBGSFullButton.pushed then
			HideUIPanel(WorldStateScoreFrame)
			Holder:Show()
		end
	end)
	WorldStateScoreFrame:HookScript("OnHide", function() SBGSFullButton.pushed = false end)

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
