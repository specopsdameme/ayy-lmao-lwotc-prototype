//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_Ayylmaolwotc.uc                                    
//           
//	Use the X2DownloadableContentInfo class to specify unique mod behavior when the 
//  player creates a new campaign or loads a saved game.
//  
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_Ayylmaolwotc extends X2DownloadableContentInfo config(GameData_AyyLmao);

var config array<name> FLYOVERS_ON_SHOOTERS;
var config array<name> FLYOVERS_ON_TARGETS;


/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the 
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static event OnLoadedSavedGame()
{

}

static function FinalizeUnitAbilitiesForInit(XComGameState_Unit UnitState, out array<AbilitySetupData> SetupData, optional XComGameState StartState, optional XComGameState_Player PlayerState, optional bool bMultiplayerDisplay)
{

}

/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed
/// </summary>
static event InstallNewCampaign(XComGameState StartState)
{}



//the entire thing here is just to change from LocFriendlyName to Locflyovertext
static event OnPostTemplatesCreated()
{

local name AbilityName;

foreach default.FLYOVERS_ON_SHOOTERS(AbilityName)
{
	UpdateAbilityShooter(AbilityName);
}


foreach default.FLYOVERS_ON_TARGETS(AbilityName)
{
	UpdateAbilityTarget(AbilityName);
}


UpdateWrath();

UpdateEvac();

UpdateGrapple('Grapple');
UpdateGrapple('GrapplePowered');
UpdateGrapple('SkirmisherGrapple');

}


static function UpdateAbilityShooter(name Ability)
{
	local X2AbilityTemplateManager			AbilityManager;
	local array<X2AbilityTemplate>			TemplateAllDifficulties;
	local X2AbilityTemplate					Template;
			local X2Effect_FlyoverShooter Effect;
	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	Template = AbilityManager.FindAbilityTemplate(Ability);

	Effect= new class 'X2Effect_FlyoverShooter';
	Effect.abilityname=Ability;
	Template.AddShooterEffect(Effect);
	Template.bShowActivation = false;
	
}
static function UpdateAbilityTarget(name Ability)
{
	local X2AbilityTemplateManager			AbilityManager;
	local array<X2AbilityTemplate>			TemplateAllDifficulties;
	local X2AbilityTemplate					Template;
			local X2Effect_FlyoverShooter Effect;
	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	Template = AbilityManager.FindAbilityTemplate(Ability);

	Effect= new class 'X2Effect_FlyoverShooter';
	Effect.abilityname=Ability;
	Template.AddTargetEffect(Effect);
	Template.bShowActivation = false;
	
}




static function UpdateWrath()
{
	local X2AbilityTemplateManager			AbilityManager;
	local X2AbilityTemplate Template;

	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	Template = AbilityManager.FindAbilityTemplate('SkirmisherVengeance');

	Template.BuildVisualizationFn = Vengeance_BuildVisualization_Flyover;
}



simulated function Vengeance_BuildVisualization_Flyover(XComGameState VisualizeGameState)
{
	local XComGameStateHistory History;
	local StateObjectReference MovingUnitRef;
	local VisualizationActionMetadata ActionMetadata;
	local VisualizationActionMetadata EmptyTrack;
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_EnvironmentDamage EnvironmentDamage;
	local X2Action_PlaySoundAndFlyOver CharSpeechAction, SoundAndFlyOver;
	local X2Action_Grapple GrappleAction;
	local X2Action_ExitCover ExitCoverAction;
	local X2Action_Fire FireMissAction;
	local X2AbilityTemplate AbilityTemplate;
	History = `XCOMHISTORY;
	AbilityContext = XComGameStateContext_Ability(VisualizeGameState.GetContext());

	MovingUnitRef = AbilityContext.InputContext.SourceObject;


	AbilityTemplate = class'XComGameState_Ability'.static.GetMyTemplateManager().FindAbilityTemplate(AbilityContext.InputContext.AbilityTemplateName);
	ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(MovingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	ActionMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(MovingUnitRef.ObjectID);
	ActionMetadata.VisualizeActor = History.GetVisualizer(MovingUnitRef.ObjectID);

	SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyover'.static.AddToVisualizationTree(ActionMetadata, AbilityContext));
	SoundAndFlyOver.SetSoundAndFlyOverParameters(None, AbilityTemplate.LocFlyOverText, '', eColor_Good, AbilityTemplate.IconImage);
	//SoundAndFlyOver.bUsePreviousGameState = true;

	ExitCoverAction = X2Action_ExitCover(class'X2Action_ExitCover'.static.AddToVisualizationTree(ActionMetadata, AbilityContext));
	ExitCoverAction.bUsePreviousGameState = true;

	if (!AbilityContext.IsResultContextMiss())
	{
		CharSpeechAction = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, AbilityContext));
		CharSpeechAction.SetSoundAndFlyOverParameters(None, "", 'GrapplingHook', eColor_Good);

		GrappleAction = X2Action_Grapple(class'X2Action_Grapple'.static.AddToVisualizationTree(ActionMetadata, AbilityContext));
		GrappleAction.DesiredLocation = `XWORLD.GetPositionFromTileCoordinates(XComGameState_Unit(ActionMetadata.StateObject_NewState).TileLocation);

		// destroy any windows we flew through
		foreach VisualizeGameState.IterateByClassType(class'XComGameState_EnvironmentDamage', EnvironmentDamage)
		{
			ActionMetadata = EmptyTrack;

			//Don't necessarily have a previous state, so just use the one we know about
			ActionMetadata.StateObject_OldState = EnvironmentDamage;
			ActionMetadata.StateObject_NewState = EnvironmentDamage;
			ActionMetadata.VisualizeActor = History.GetVisualizer(EnvironmentDamage.ObjectID);

			class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded);
			class'X2Action_ApplyWeaponDamageToTerrain'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext());
		}
	}
	else
	{
		FireMissAction = X2Action_Fire(class'X2Action_Fire'.static.AddToVisualizationTree(ActionMetadata, AbilityContext, false, ExitCoverAction));
		class'X2Action_EnterCover'.static.AddToVisualizationTree(ActionMetadata, AbilityContext, false, FireMissAction);
	}

}

static function UpdateEvac()
{
	local X2AbilityTemplateManager			AbilityManager;
	local X2AbilityTemplate Template;

	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	Template = AbilityManager.FindAbilityTemplate('Evac');

	Template.BuildVisualizationFn = EvacAbility_BuildVisualization_FlyOver;
}



simulated function EvacAbility_BuildVisualization_FlyOver(XComGameState VisualizeGameState)
{
	local XComGameStateHistory          History;
	local XComGameState_Unit            GameStateUnit;
	local VisualizationActionMetadata	EmptyTrack;
	local VisualizationActionMetadata	ActionMetadata;
	local X2Action_PlaySoundAndFlyOver  SoundAndFlyover;	
	local name                          nUnitTemplateName;
	local bool                          bIsVIP;
	local bool                          bNeedVIPVoiceover;
	local XComGameState_Unit            SoldierToPlayVoiceover;
	local array<XComGameState_Unit>     HumanPlayersUnits;
	local XComGameState_Effect          CarryEffect;
	local X2AbilityTemplate AbilityTemplate;
	local XComGameStateContext_Ability AbilityContext;


	AbilityContext = XComGameStateContext_Ability(VisualizeGameState.GetContext());

	AbilityTemplate = class'XComGameState_Ability'.static.GetMyTemplateManager().FindAbilityTemplate(AbilityContext.InputContext.AbilityTemplateName);

	if(`REPLAY.bInTutorial)
	{
		EvacAbility_BuildTutorialVisualization(VisualizeGameState );
	}
	else
	{
		History = `XCOMHISTORY;

		//Decide on which VO cue to play, and which unit says it
		foreach VisualizeGameState.IterateByClassType(class'XComGameState_Unit', GameStateUnit)
		{
			if (!GameStateUnit.bRemovedFromPlay)
				continue;

			nUnitTemplateName = GameStateUnit.GetMyTemplateName();
			switch(nUnitTemplateName)
			{
			case 'Soldier_VIP':
			case 'Scientist_VIP':
			case 'Engineer_VIP':
			case 'FriendlyVIPCivilian':
			case 'HostileVIPCivilian':
			case 'CommanderVIP':
			case 'Engineer':
			case 'Scientist':
				bIsVIP = true;
				break;
			default:
				bIsVIP = false;
			}

			if (bIsVIP)
			{
				bNeedVIPVoiceover = true;
			}
			else
			{
				if (SoldierToPlayVoiceover == None)
					SoldierToPlayVoiceover = GameStateUnit;
			}
		}

		//Build tracks for each evacuating unit
		foreach VisualizeGameState.IterateByClassType(class'XComGameState_Unit', GameStateUnit)
		{
			if (!GameStateUnit.bRemovedFromPlay)
				continue;

			//Start their track
			ActionMetadata = EmptyTrack;
			ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(GameStateUnit.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
			ActionMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(GameStateUnit.ObjectID);
			ActionMetadata.VisualizeActor = History.GetVisualizer(GameStateUnit.ObjectID);

			//Add this potential flyover (does this still exist in the game?)
			class'XComGameState_Unit'.static.SetUpBuildTrackForSoldierRelationship(ActionMetadata, VisualizeGameState, GameStateUnit.ObjectID);

			//Play the VO if this is the soldier we picked for it
			if (SoldierToPlayVoiceover == GameStateUnit)
			{
				SoundAndFlyOver = X2Action_PlaySoundAndFlyover(class'X2Action_PlaySoundAndFlyover'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext()));
				SoundAndFlyOver.SetSoundAndFlyOverParameters(None, AbilityTemplate.LocFlyOverText, '', eColor_Good, AbilityTemplate.IconImage);

				SoundAndFlyOver = X2Action_PlaySoundAndFlyover(class'X2Action_PlaySoundAndFlyover'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
				if (bNeedVIPVoiceover)
				{
					SoundAndFlyOver.SetSoundAndFlyOverParameters(None, "", 'VIPRescueComplete', eColor_Good);
					bNeedVIPVoiceover = false;
				}
				else
				{
					SoundAndFlyOver.SetSoundAndFlyOverParameters(None, "", 'EVAC', eColor_Good);
				}
			}

			//Note: AFFECTED BY effect state (being carried)
			CarryEffect = XComGameState_Unit(ActionMetadata.StateObject_OldState).GetUnitAffectedByEffectState(class'X2AbilityTemplateManager'.default.BeingCarriedEffectName);
			if (CarryEffect == None)
			{
				class'X2Action_Evac'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded); //Not being carried - rope out
			}				
			
			//Hide the pawn explicitly now - in case the vis block doesn't complete immediately to trigger an update
			class'X2Action_RemoveUnit'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded);
		}

		//If a VIP evacuated alone, we may need to pick an (arbitrary) other soldier on the squad to say the VO line about it.
		if (bNeedVIPVoiceover)
		{
			XGBattle_SP(`BATTLE).GetHumanPlayer().GetUnits(HumanPlayersUnits);
			foreach HumanPlayersUnits(GameStateUnit)
			{
				if (GameStateUnit.IsSoldier() && !GameStateUnit.IsDead() && !GameStateUnit.bRemovedFromPlay)
				{
					ActionMetadata = EmptyTrack;
					ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(GameStateUnit.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
					ActionMetadata.StateObject_NewState = ActionMetadata.StateObject_OldState;
					ActionMetadata.VisualizeActor = History.GetVisualizer(GameStateUnit.ObjectID);

					SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyover'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
					SoundAndFlyOver.SetSoundAndFlyOverParameters(None, "", 'VIPRescueComplete', eColor_Good);

										break;
				}
			}

		}
		
	}


	//****************************************************************************************
}

simulated function EvacAbility_BuildTutorialVisualization(XComGameState VisualizeGameState )
{
	local XComGameStateHistory History;
	local XComGameStateContext_Ability  AbilityContext;
	local VisualizationActionMetadata            ActionMetadata;
	local X2Action_PlayNarrative        EvacBink;

	History = `XCOMHISTORY;

	// In replay, just play the end mission bink and nothing else
	AbilityContext = XComGameStateContext_Ability(VisualizeGameState.GetContext());

	ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID,, VisualizeGameState.HistoryIndex - 1);
	ActionMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID);
	ActionMetadata.VisualizeActor = History.GetVisualizer(AbilityContext.InputContext.SourceObject.ObjectID);

	EvacBink = X2Action_PlayNarrative(class'X2Action_PlayNarrative'.static.AddToVisualizationTree(ActionMetadata, AbilityContext));
	EvacBink.bEndOfMissionNarrative = true;
	EvacBink.Moment = XComNarrativeMoment(DynamicLoadObject(class'X2Ability_DefaultAbilityset'.default.TutorialEvacBink, class'XComNarrativeMoment'));

	}


static function	UpdateGrapple(name Abilityname)
{
	local X2AbilityTemplateManager			AbilityManager;
	local X2AbilityTemplate Template;

	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	Template = AbilityManager.FindAbilityTemplate(Abilityname);

	Template.BuildVisualizationFn = Grapple_BuildVisualization_Flyover;
}



simulated function Grapple_BuildVisualization_Flyover(XComGameState VisualizeGameState)
{
	local XComGameStateHistory History;
	local StateObjectReference MovingUnitRef;	
	local VisualizationActionMetadata ActionMetadata;
	local VisualizationActionMetadata EmptyTrack;
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_EnvironmentDamage EnvironmentDamage;
	local X2Action_PlaySoundAndFlyOver CharSpeechAction, SoundAndFlyOver;
	local X2Action_Grapple GrappleAction;
	local X2Action_ExitCover ExitCoverAction;
	local X2Action_RevealArea RevealAreaAction;
	local X2Action_UpdateFOW FOWUpdateAction;
	local X2AbilityTemplate AbilityTemplate;

	AbilityTemplate = class'XComGameState_Ability'.static.GetMyTemplateManager().FindAbilityTemplate(AbilityContext.InputContext.AbilityTemplateName);

	History = `XCOMHISTORY;
	AbilityContext = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	MovingUnitRef = AbilityContext.InputContext.SourceObject;
	
	ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(MovingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	ActionMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(MovingUnitRef.ObjectID);
	ActionMetadata.VisualizeActor = History.GetVisualizer(MovingUnitRef.ObjectID);

	SoundAndFlyOver = X2Action_PlaySoundAndFlyover(class'X2Action_PlaySoundAndFlyover'.static.AddToVisualizationTree(ActionMetadata, AbilityContext));
	SoundAndFlyOver.SetSoundAndFlyOverParameters(None, AbilityTemplate.LocFlyOverText, '', eColor_Good, AbilityTemplate.IconImage);


	CharSpeechAction = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, AbilityContext));
	CharSpeechAction.SetSoundAndFlyOverParameters(None, "", 'GrapplingHook', eColor_Good);

	RevealAreaAction = X2Action_RevealArea(class'X2Action_RevealArea'.static.AddToVisualizationTree(ActionMetadata, AbilityContext));
	RevealAreaAction.TargetLocation = AbilityContext.InputContext.TargetLocations[0];
	RevealAreaAction.AssociatedObjectID = MovingUnitRef.ObjectID;
	RevealAreaAction.ScanningRadius = class'XComWorldData'.const.WORLD_StepSize * 4;
	RevealAreaAction.bDestroyViewer = false;

	FOWUpdateAction = X2Action_UpdateFOW(class'X2Action_UpdateFOW'.static.AddToVisualizationTree(ActionMetadata, AbilityContext));
	FOWUpdateAction.BeginUpdate = true;

	ExitCoverAction = X2Action_ExitCover(class'X2Action_ExitCover'.static.AddToVisualizationTree(ActionMetadata, AbilityContext));
	ExitCoverAction.bUsePreviousGameState = true;

	GrappleAction = X2Action_Grapple(class'X2Action_Grapple'.static.AddToVisualizationTree(ActionMetadata, AbilityContext));
	GrappleAction.DesiredLocation = AbilityContext.InputContext.TargetLocations[0];

	// destroy any windows we flew through
	foreach VisualizeGameState.IterateByClassType(class'XComGameState_EnvironmentDamage', EnvironmentDamage)
	{
		ActionMetadata = EmptyTrack;

		//Don't necessarily have a previous state, so just use the one we know about
		ActionMetadata.StateObject_OldState = EnvironmentDamage;
		ActionMetadata.StateObject_NewState = EnvironmentDamage;
		ActionMetadata.VisualizeActor = History.GetVisualizer(EnvironmentDamage.ObjectID);

		class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded);
		class'X2Action_ApplyWeaponDamageToTerrain'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext());
	}

	FOWUpdateAction = X2Action_UpdateFOW(class'X2Action_UpdateFOW'.static.AddToVisualizationTree(ActionMetadata, AbilityContext));
	FOWUpdateAction.EndUpdate = true;

	RevealAreaAction = X2Action_RevealArea(class'X2Action_RevealArea'.static.AddToVisualizationTree(ActionMetadata, AbilityContext));
	RevealAreaAction.AssociatedObjectID = MovingUnitRef.ObjectID;
	RevealAreaAction.bDestroyViewer = true;
}
