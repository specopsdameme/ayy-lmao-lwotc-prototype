//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_Ayylmaolwotc.uc                                    
//           
//	Use the X2DownloadableContentInfo class to specify unique mod behavior when the 
//  player creates a new campaign or loads a saved game.
//  
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_Ayylmaolwotc extends X2DownloadableContentInfo config(Ayylmaoplaceholderconfigs);


var config int FOCUS4MOBILITY;
var config int FOCUS4DODGE;
var config int FOCUS4RENDDAMAGE;
/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the 
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static event OnLoadedSavedGame()
{}

/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed
/// </summary>
static event InstallNewCampaign(XComGameState StartState)
{}



//the entire thing here is just to change from LocFriendlyName to Locflyovertext
static event OnPostTemplatesCreated()
{
UpdateAbilityShooter('Evac');
UpdateAbilityShooter('Pillar');
UpdateAbilityShooter('Justice');
UpdateAbilityShooter('Grapple');
UpdateAbilityShooter('GrapplePowered');
UpdateAbilityShooter('SkirmisherGrapple');
UpdateAbilityShooter('LightningHands');
UpdateAbilityShooter('DoubleTap2');
UpdateAbilityShooter('KillZone');
UpdateAbilityShooter('FanFire');
UpdateAbilityShooter('ArcThrowerStun');
UpdateAbilityShooter('StreetSweeper2');
UpdateAbilityShooter('ChainLightning');
UpdateAbilityShooter('ArcWave');
UpdateAbilityShooter('RemoteStart');
UpdateAbilityShooter('SoulReaper');
UpdateAbilityShooter('SoulReaperContinue');
UpdateAbilityShooter('Battlelord');
UpdateAbilityShooter('AdvPurifierFlamethrower');
UpdateAbilityShooter('AdvPurifierFlamethrowerM2');
UpdateAbilityShooter('AdvPurifierFlamethrowerM3');
UpdateAbilityShooter('CyclicFire');
UpdateAbilityShooter('Rend');
UpdateAbilityShooter('Ghost');
UpdateAbilityShooter('Volt');
UpdateAbilityShooter('ChainShot');
UpdateAbilityShooter('ChainShot2');
UpdateAbilityShooter('SkirmisherFleche');
UpdateAbilityShooter('SkirmisherSlash');
UpdateAbilityShooter('Slash_LW ');
UpdateAbilityShooter('SwordSlice_LW');
UpdateAbilityShooter('Fleche');
UpdateAbilityShooter('SoulReaperContinue');
UpdateAbilityShooter('SkirmisherSlash');
//UpdateAbilityShooter('PurifierDeathExplosion');
UpdateAbilityShooter('Stasis');
UpdateAbilityShooter('Insanity');
UpdateAbilityShooter('Inspire');
UpdateAbilityShooter('Fuse');
UpdateAbilityShooter('Domination');
UpdateAbilityShooter('NullLance');
UpdateAbilityShooter('VoidRift');
UpdateAbilityTarget('VoidConduit');
UpdateAbilityTarget('AnimaConsume');
UpdateAbilityShooter('ParryActivate');
UpdateAbilityShooter('RapidFire2');
UpdateAbilityShooter('RunAndGun');
UpdateAbilityShooter('StreetSweeper2');
UpdateAbilityShooter('ChainLightning');
UpdateAbilityShooter('HomingMine');
UpdateAbilityShooter('BodyShield');
UpdateAbilityShooter('Vanish');
UpdateAbilityShooter('StunStrike');
UpdateAbilityShooter('Overdrive');
UpdateAbilityShooter('HolyWarriorM1');
UpdateAbilityShooter('HolyWarriorM2');
UpdateAbilityShooter('HolyWarriorM3');
UpdateAbilityShooter('StunLance');
UpdateAbilityShooter('CombatStims');
UpdateAbilityShooter('MassReanimation_LW');
UpdateAbilityShooter('LWFlamethrower');
}


static function UpdateAbilityShooter(name Ability)
{
local X2AbilityTemplateManager			AbilityManager;
	local array<X2AbilityTemplate>			TemplateAllDifficulties;
	local X2AbilityTemplate					Template;
			local X2Effect_FlyoverShooter Effect;
	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityManager.FindAbilityTemplateAllDifficulties(Ability, TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
			
			Effect= new class 'X2Effect_FlyoverShooter';
			Effect.abilityname=Ability;
			Template.AddShooterEffect(Effect);
			Template.bShowActivation = false;
	}
}
static function UpdateAbilityTarget(name Ability)
{
local X2AbilityTemplateManager			AbilityManager;
	local array<X2AbilityTemplate>			TemplateAllDifficulties;
	local X2AbilityTemplate					Template;
			local X2Effect_FlyoverTarget Effect;
	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityManager.FindAbilityTemplateAllDifficulties(Ability, TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
			Effect= new class 'X2Effect_FlyoverTarget';
			Effect.abilityname=Ability;
			Template.AddTargetEffect(Effect);
			Template.bShowActivation = false;

	}
}

