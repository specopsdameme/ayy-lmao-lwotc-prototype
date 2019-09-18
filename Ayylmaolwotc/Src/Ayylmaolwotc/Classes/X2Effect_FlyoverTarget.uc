
class X2Effect_FlyoverTarget extends X2Effect_Persistent;

var name abilityname;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{

local XComGameStateContext_Ability AbilityContext;

AbilityContext = XComGameStateContext_Ability(NewGameState.GetContext());

AbilityContext.PostBuildVisualizationFn.AddItem(PatchSequentialShots_PostBuildVisualization);

}

simulated function PatchSequentialShots_PostBuildVisualization(XComGameState VisualizeGameState)
{
    local XComGameStateVisualizationMgr VisMgr;
    local array<X2Action> arrActions;
	local X2AbilityTemplate AbilityTemplate;
	local XComGameStateContext_Ability  Context;
	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;
	local VisualizationActionMetadata ActionMetadata;
	local XComGameState_Unit UnitState;
	local XComGameStateHistory History;
	History= `XCOMHISTORY;
	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
    VisMgr = `XCOMVISUALIZATIONMGR;
	AbilityTemplate = class'XComGameState_Ability'.static.GetMyTemplateManager().FindAbilityTemplate(Context.InputContext.AbilityTemplateName);
    VisMgr.GetNodesOfType(VisMgr.BuildVisTree, class'X2Action_AbilityPerkEnd', arrActions);
		foreach VisualizeGameState.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		
		ActionMetadata.StateObject_NewState = UnitState;
		ActionMetadata.VisualizeActor = UnitState.GetVisualizer();
		History.GetCurrentAndPreviousGameStatesForObjectID(UnitState.ObjectID, ActionMetadata.StateObject_OldState, ActionMetadata.StateObject_NewState, , VisualizeGameState.HistoryIndex);
	
    
    if (arrActions.Length > 0 && UnitState.ObjectID==Context.InputContext.PrimaryTarget.ObjectID)
    {
        SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyover'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, arrActions[0]));
        SoundAndFlyOver.SetSoundAndFlyOverParameters(None, AbilityTemplate.LocFlyOverText, '', eColor_Bad, AbilityTemplate.IconImage);
    }

	}
}
