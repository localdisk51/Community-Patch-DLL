-------------------------------------------------
-- LeaderHeadRoot.lua
-- modified by bc1 from civ5 brave new world and civBE code
-- to add an event when displayed
-- code is common using *_mode switches
-------------------------------------------------
local gk_mode = Game.GetReligionName ~= nil
local bnw_mode = Game.GetActiveLeague ~= nil
local civ5_mode = InStrategicView ~= nil
local civBE_mode = not civ5_mode

----------------------------------------------------------------
----------------------------------------------------------------

include( "GameplayUtilities" ); local GameplayUtilities = GameplayUtilities
include( "EUI_tooltips" ); local IconHookup = EUI.IconHookup; local CivIconHookup = EUI.CivIconHookup; local GetMoodInfo = GetMoodInfo

local g_iAIPlayer = -1;
local g_iAITeam = -1;

local g_DiploUIState = -1;

local g_iRootMode = 0;
local g_iTradeMode = 1;
local g_iDiscussionMode = 2;

local g_strLeaveScreenText = Locale.ConvertTextKey("TXT_KEY_DIPLOMACY_ANYTHING_ELSE");

local offsetOfString = 32;
local bonusPadding = 16
local innerFrameWidth = 654;
local outerFrameWidth = 650;
local offsetsBetweenFrames = 4;

local g_oldCursor = 0;
local g_isAnimateOutComplete = false;
local g_isAnimatingIn = false;
local g_bRootWasShownThisEvent = false;


-- ===========================================================================
--
--	LEADER MESSAGE HANDLER
--	. If this can handle the type of leader message, it triggers show
--	. If it cannot handle the message it hides it's contents (not the context)
--
-- ===========================================================================
function LeaderMessageHandler( iPlayer, iDiploUIState, szLeaderMessage, iAnimationAction, iData1 )

	g_DiploUIState = iDiploUIState;

	g_iAIPlayer = iPlayer;
	g_iAITeam = Players[g_iAIPlayer]:GetTeam();

	local pActivePlayer = Players[Game.GetActivePlayer()];
	local pActiveTeam = Teams[pActivePlayer:GetTeam()];
	if civ5_mode then
		CivIconHookup( iPlayer, 64, Controls.ThemSymbolShadow, Controls.CivIconBG, Controls.CivIconShadow, false, true );
	else
		CivIconHookup( iPlayer, 45, Controls.CivIcon, Controls.CivIconBG, nil, false, false, Controls.CivIconHighlight );
	end

	-- Update title even if we're not in this mode, as we could exit to it somehow
	local player = Players[iPlayer];
	local strTitleText = GameplayUtilities.GetLocalizedLeaderTitle(player);
	Controls.TitleText:SetText(strTitleText);

	playerLeaderInfo = GameInfo.Leaders[player:GetLeaderType()];

	-- Mood
	local iApproach = pActivePlayer:GetApproachTowardsUsGuess(g_iAIPlayer);
	local strMoodText = Locale.ConvertTextKey("TXT_KEY_EMOTIONLESS");

	if (pActiveTeam:IsAtWar(g_iAITeam)) then
		strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_WAR" );
	elseif (Players[g_iAIPlayer]:IsDenouncingPlayer(Game.GetActivePlayer())) then
		strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_DENOUNCING" );
	elseif gk_mode and Players[g_iAIPlayer]:WasResurrectedThisTurnBy(iActivePlayer) then
		strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_LIBERATED" );
	else
		if( iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_WAR ) then
			strMoodText = Locale.ConvertTextKey( "TXT_KEY_WAR_CAPS" );
		elseif( iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_HOSTILE ) then
			strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_HOSTILE", playerLeaderInfo.Description );
		elseif( iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_GUARDED ) then
			strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_GUARDED", playerLeaderInfo.Description );
		elseif( iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_AFRAID ) then
			strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_AFRAID", playerLeaderInfo.Description );
		elseif( iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_FRIENDLY ) then
			strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_FRIENDLY", playerLeaderInfo.Description );
		elseif( iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_NEUTRAL ) then
			strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_NEUTRAL", playerLeaderInfo.Description );
		end
	end

	Controls.MoodText:SetText(strMoodText);
	Controls.MoodText:SetToolTipString( GetMoodInfo(g_iAIPlayer) );


	-- Whether it's handled here or in a leaderhead sub-screen, the root context should be visible if a
	-- leaderhead message is coming through...
	-- If animations need to kick off (coming from InGame) let that be signaled by the transition manager.
	if civBE_mode and ContextPtr:IsHidden() then
		ContextPtr:SetHide( false );
	end

	-- Is this a mode that this screen can handle?
	if g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DEFAULT_ROOT
		or iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_WAR_DECLARED_BY_HUMAN
		or iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_PEACE_MADE_BY_HUMAN
	then
		UI.SetLeaderHeadRootUp( true );
		Controls.LeaderSpeech:SetText( szLeaderMessage );

		if civ5_mode then
			-- Resize the height of the box to fit the text
			local contentSize = Controls.LeaderSpeech:GetSizeY() + offsetOfString + bonusPadding;
			Controls.LeaderSpeechBorderFrame:SetSizeY( contentSize );
			Controls.LeaderSpeechFrame:SetSizeY( contentSize - offsetsBetweenFrames );
		elseif Controls.RootOptions:IsHidden() then
			g_bRootWasShownThisEvent = true;
			Controls.RootOptions:SetHide( false );
		end

	else
		if civBE_mode then
			-- Hide the contents of the page, as another screen is handling it.
			Controls.RootOptions:SetHide( true );
		end
		Controls.LeaderSpeech:SetText( g_strLeaveScreenText );		-- Seed the text box with something reasonable so that we don't get leftovers from somewhere else

	end

	-- While leaderheadroot is a root context, it is necessary to invoke this as a popup
	-- so that any other pop-ups are dismissed.
	UIManager:QueuePopup( ContextPtr, PopupPriority.LeaderHead );

end
Events.AILeaderMessage.Add( LeaderMessageHandler );


-- ===========================================================================
--	Request from use to close; either a button or the keyboard.
-- ===========================================================================
function OnClose()
	if civ5_mode then
		UIManager:DequeuePopup( ContextPtr );
	end
	UI.SetLeaderHeadRootUp( false );
	UI.RequestLeaveLeader();
end
Controls.BackButton:RegisterCallback( Mouse.eLClick, OnClose );
OnReturn = OnClose --compatibility

function OnLeavingLeader()
	-- we shouldn't be able to leave without this already being set to false,
	-- but just in case...
	UI.SetLeaderHeadRootUp( false );
	if civ5_mode then
		UIManager:DequeuePopup( ContextPtr );
	else
		g_bRootWasShownThisEvent = false;
		g_DiploUIState = DiploUIStateTypes.NO_DIPLO_UI_STATE;
	end
end
Events.LeavingLeaderViewMode.Add( OnLeavingLeader );


-- ===========================================================================
function UpdateDisplay()

	local pActiveTeam = Teams[Game.GetActiveTeam()];

	-- Hide or show war/peace button
	if (not pActiveTeam:CanChangeWarPeace(g_iAITeam)) then
		Controls.WarButton:SetHide(true);
	else
		Controls.WarButton:SetHide(false);
	end

	-- Hide or show the demand button
	if (Game.GetActiveTeam() == g_iAITeam) then
		Controls.DemandButton:SetHide(true);
	else
		Controls.DemandButton:SetHide(false);
	end

	g_oldCursor = UIManager:SetUICursor(0); -- make sure we start with the default cursor

	if (g_iAITeam ~= -1) then
		local bAtWar = pActiveTeam:IsAtWar(g_iAITeam);

		if (bAtWar) then
			Controls.WarButton:SetText( Locale.ConvertTextKey( "TXT_KEY_DIPLO_NEGOTIATE_PEACE" ));
			Controls.TradeButton:SetDisabled(true);
			Controls.DemandButton:SetDisabled(true);
			Controls.DiscussButton:SetDisabled(true);

			local iLockedWarTurns = pActiveTeam:GetNumTurnsLockedIntoWar(g_iAITeam);

			-- Not locked into war
			if (iLockedWarTurns == 0) then
				Controls.WarButton:SetDisabled(false);
				Controls.WarButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_DIPLO_NEGOTIATE_PEACE_TT" ));
			-- Locked into war
			else
				Controls.WarButton:SetDisabled(true);
				Controls.WarButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_DIPLO_NEGOTIATE_PEACE_BLOCKED_TT", iLockedWarTurns ));
			end
		else
			Controls.WarButton:SetText( Locale.ConvertTextKey( "TXT_KEY_DIPLO_DECLARE_WAR" ));
			Controls.TradeButton:SetDisabled(false);
			Controls.DemandButton:SetDisabled(false);
			Controls.DiscussButton:SetDisabled(false);

			if (pActiveTeam:IsForcePeace(g_iAITeam)) then
				Controls.WarButton:SetDisabled(true);
				Controls.WarButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAY_NOT_ATTACK" ));
			elseif (not pActiveTeam:CanDeclareWar(g_iAITeam)) then
				Controls.WarButton:SetDisabled(true);
				Controls.WarButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAY_NOT_ATTACK_MOD" ));
			else
				Controls.WarButton:SetDisabled(false);
				Controls.WarButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_DIPLO_DECLARES_WAR_TT" ));
			end

		end
	end
	if civBE_mode then
		Controls.TalkOptionStack:CalculateSize();
		Controls.TalkOptionStack:ReprocessAnchoring();
	end
end

----------------------------------------------------------------
-- ===========================================================================
--	SHOW/HIDE
-- ===========================================================================
function OnShowHide( isHide, isInit )
	if isInit then
		if civBE_mode then
			-- set blackbar based on %
			local screenWidth, screenHeight = UIManager:GetScreenSizeVal();
			local blackBarTopSize			= (screenHeight * .20) / 2;		-- slightly less, male model's head is cropped otherwise in min-spec
			local blackBarBottomSize		= (screenHeight * .26) / 2;
			Controls.BlackBarTop:SetSizeY( blackBarTopSize );
			Controls.BlackBarBottom:SetSizeY( blackBarBottomSize );
			Controls.AnimBarTop:SetBeginVal(0, -blackBarTopSize);
			Controls.AnimBarBottom:SetBeginVal(0, blackBarBottomSize);
		end
	elseif isHide then
		-- Hiding Screen
		UIManager:SetUICursor(g_oldCursor); -- make sure we retrun the cursor to the previous state
		-- Do not attempt to set default leader text here; it's possible for this same screen to be queued.
	else
		-- Showing Screen
		LuaEvents.EUILeaderHeadRoot()
		if civ5_mode then
			Controls.RootOptions:SetHide( not UI.GetLeaderHeadRootUp() );
		end
		UpdateDisplay();
	end
end
ContextPtr:SetShowHideHandler( OnShowHide );


-- ===========================================================================
-- Key Down Processing
-- ===========================================================================
function InputHandler( uiMsg, wParam, lParam )
	if( uiMsg == KeyEvents.KeyDown )
	then
		if( wParam == Keys.VK_ESCAPE or wParam == Keys.VK_RETURN ) then
			if bnw_mode or Controls.WarConfirm:IsHidden() then
				OnClose();
			else
				Controls.WarConfirm:SetHide(true);
			end
		end
	end
	return true;
end
ContextPtr:SetInputHandler( InputHandler );




-- ===========================================================================
function OnDiscuss()
	Controls.LeaderSpeech:SetText( g_strLeaveScreenText );		-- Seed the text box with something reasonable so that we don't get leftovers from somewhere else

	Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_HUMAN_WANTS_DISCUSSION, g_iAIPlayer, 0, 0 );
end
Controls.DiscussButton:RegisterCallback( Mouse.eLClick, OnDiscuss );


-- ===========================================================================
function OnTrade()
	-- This calls into CvDealAI and sets up the initial state of the UI
	Players[g_iAIPlayer]:DoTradeScreenOpened();

	Controls.LeaderSpeech:SetText( g_strLeaveScreenText );		-- Seed the text box with something reasonable so that we don't get leftovers from somewhere else

	UI.OnHumanOpenedTradeScreen(g_iAIPlayer);
end
Controls.TradeButton:RegisterCallback( Mouse.eLClick, OnTrade );


-- ===========================================================================
function OnDemand()

	Controls.LeaderSpeech:SetText( g_strLeaveScreenText );		-- Seed the text box with something reasonable so that we don't get leftovers from somewhere else

	UI.OnHumanDemand(g_iAIPlayer);
end
Controls.DemandButton:RegisterCallback( Mouse.eLClick, OnDemand );


-- ===========================================================================
function OnWarOrPeace()

	local bAtWar = Teams[Game.GetActiveTeam()]:IsAtWar(g_iAITeam);

	-- Asking for Peace (currently at war) - bring up the trade screen
	if (bAtWar) then
		Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_HUMAN_NEGOTIATE_PEACE, g_iAIPlayer, 0, 0 );

	-- Declaring War (currently at peace)
	elseif bnw_mode then
		UI.AddPopup{ Type = ButtonPopupTypes.BUTTONPOPUP_DECLAREWARMOVE, Data1 = g_iAITeam, Option1 = true};
	else
		Controls.WarConfirm:SetHide(false);
	end

end
Controls.WarButton:RegisterCallback( Mouse.eLClick, OnWarOrPeace );


-- ===========================================================================
function WarStateChangedHandler( iTeam1, iTeam2, bWar )

	-- Active player changed war state with this AI
	if (iTeam1 == Game.GetActiveTeam() and iTeam2 == g_iAITeam) then

		if (bWar) then
			Controls.WarButton:SetText( Locale.ConvertTextKey( "TXT_KEY_DIPLO_NEGOTIATE_PEACE" ));
			Controls.TradeButton:SetDisabled(true);
			Controls.DemandButton:SetDisabled(true);
			Controls.DiscussButton:SetDisabled(true);
		else
			Controls.WarButton:SetText(Locale.ConvertTextKey( "TXT_KEY_DIPLO_DECLARE_WAR" ));
			Controls.TradeButton:SetDisabled(false);
			Controls.DemandButton:SetDisabled(false);
			Controls.DiscussButton:SetDisabled(false);
		end

	end

end
Events.WarStateChanged.Add( WarStateChangedHandler );

if not bnw_mode then
	function OnYes( )
		Controls.WarConfirm:SetHide(true);

		Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_HUMAN_DECLARES_WAR, g_iAIPlayer, 0, 0 );
	end
	Controls.Yes:RegisterCallback( Mouse.eLClick, OnYes );

	function OnNo( )
		Controls.WarConfirm:SetHide(true);
	end
	Controls.No:RegisterCallback( Mouse.eLClick, OnNo );
end
---------------------------------------------------------------------------------------
-- Support for Modded Add-in UI's
---------------------------------------------------------------------------------------
g_uiAddins = {};
for addin in Modding.GetActivatedModEntryPoints("DiplomacyUIAddin") do
	local addinFile = Modding.GetEvaluatedFilePath(addin.ModID, addin.Version, addin.File);
	local addinPath = addinFile.EvaluatedPath;

	-- Get the absolute path and filename without extension.
	local extension = Path.GetExtension(addinPath);
	local path = string.sub(addinPath, 1, #addinPath - #extension);

	table.insert(g_uiAddins, ContextPtr:LoadNewContext(path));
end

if civBE_mode then
	-- ===========================================================================
	--	Animate all controls for when the screen first comes up
	--	Kicked off by the game engine
	-- ===========================================================================
	function OnAnimateIn()

		if g_isAnimatingIn then
			return;
		end

		-- Reset
		g_isAnimatingIn = true;
		Controls.AnimBarTop:RegisterAnimCallback( function() end );
		Controls.AnimBarBottom:RegisterAnimCallback( function() end );
		Controls.GamestateTransitionAnimOut:SetToBeginning();

		Controls.AnimBarTop:SetToBeginning();
		Controls.AnimBarBottom:SetToBeginning();
		Controls.AnimAlphaTop:SetToBeginning();
		Controls.AnimAlphaBottom:SetToBeginning();

		Controls.AnimBarTop:Play();
		Controls.AnimBarBottom:Play();
		Controls.AnimAlphaTop:Play();
		Controls.AnimAlphaBottom:Play();
		Controls.BackButton:SetDisabled( false );
	end
	Controls.GamestateTransitionAnimIn:RegisterAnimCallback( OnAnimateIn );

	-- ===========================================================================
	--	Animate all controls for when the screen is being dismissed
	-- ===========================================================================
	function OnAnimateOut()

		-- Reset variables for next animation in.
		g_isAnimatingIn			= false;
		g_isAnimateOutComplete	= false;
		Controls.GamestateTransitionAnimIn:SetToBeginning();

		-- Play controls backwards

		Controls.AnimBarTop:Reverse();
		Controls.AnimBarTop:Play();
		Controls.AnimBarTop:RegisterAnimCallback( OnUpdateAnimate );

		Controls.AnimBarBottom:Reverse();
		Controls.AnimBarBottom:Play();
		Controls.AnimBarBottom:RegisterAnimCallback( OnUpdateAnimate );

		Controls.AnimAlphaTop:Reverse();
		Controls.AnimAlphaTop:Play();

		Controls.AnimAlphaBottom:Reverse();
		Controls.AnimAlphaBottom:Play();

		Controls.BackButton:SetDisabled( true );
	end
	Controls.GamestateTransitionAnimOut:RegisterAnimCallback( OnAnimateOut );

	-- ===========================================================================
	--	Callback, per-frame, for animation
	-- ===========================================================================
	function OnUpdateAnimate()
		if ( Controls.AnimBarTop:IsStopped() and Controls.AnimBarBottom:IsStopped() ) then
			OnAnimateOutComplete();
		end
	end

	-- ===========================================================================
	--	Called once when completed animating out
	-- ===========================================================================
	function OnAnimateOutComplete()
		if g_isAnimateOutComplete then
			return;
		end

		g_isAnimateOutComplete	= true;
		ContextPtr:SetHide( true );
		UIManager:DequeuePopup( ContextPtr );
	end


	-- ===========================================================================
	--	Raised from sub-screens when they are closed
	-- ===========================================================================
	function OnLeaderheadPopupClosed()

		-- If the popup screen was raised through the menu, just bring the menu (root) options back
		-- otherwise dismiss the whole leaderhead system because the pop-up was directly invoked.
		if g_bRootWasShownThisEvent then
			Controls.RootOptions:SetHide( false );
		else
			UI.SetLeaderHeadRootUp( false );
			UI.RequestLeaveLeader();
		end
	end
	LuaEvents.LeaderheadPopupClosed.Add( OnLeaderheadPopupClosed );


	-- ===========================================================================
	--	Raised from sub-screens as they exit (e.g., Trade logic)
	-- ===========================================================================
	function OnLeaderheadShow()
		-- If this wasn't shown, ignore the event as it may be raised by shared
		-- subscreend (e.g., tradelogic in multiplayer.)
		if g_bRootWasShownThisEvent then
			Controls.RootOptions:SetHide( false );
			ContextPtr:SetHide( false );
		else
			LuaEvents.LeaderheadPopupClosed();
		end
	end
	LuaEvents.LeaderheadRootShow.Add( OnLeaderheadShow );
end