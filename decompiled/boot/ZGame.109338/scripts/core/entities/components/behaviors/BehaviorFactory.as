package core.entities.components.behaviors
{
   import core.entities.components.behaviors.states.AMSBuildingPartsDialogState;
   import core.entities.components.behaviors.states.AccelerationAutoDialogState;
   import core.entities.components.behaviors.states.AccelerationDialogState;
   import core.entities.components.behaviors.states.AnimationState;
   import core.entities.components.behaviors.states.AutoDialogState;
   import core.entities.components.behaviors.states.BehaviorState;
   import core.entities.components.behaviors.states.BountyCenterDialogState;
   import core.entities.components.behaviors.states.BuildingPartsAmityState;
   import core.entities.components.behaviors.states.BuildingPartsCyberState;
   import core.entities.components.behaviors.states.BuildingPartsDialogState;
   import core.entities.components.behaviors.states.CampaignEntryState;
   import core.entities.components.behaviors.states.CapsuleAutoState;
   import core.entities.components.behaviors.states.CapsuleClickState;
   import core.entities.components.behaviors.states.CapsuleHousingCrewDialogState;
   import core.entities.components.behaviors.states.CapsuleHousingPartsState;
   import core.entities.components.behaviors.states.CommandoKillActivateDialogState;
   import core.entities.components.behaviors.states.CommandoKillActiveState;
   import core.entities.components.behaviors.states.CommandoKillCoolingState;
   import core.entities.components.behaviors.states.CommandoKillDialogState;
   import core.entities.components.behaviors.states.CommandoSimpleClickState;
   import core.entities.components.behaviors.states.CrewDialogState;
   import core.entities.components.behaviors.states.CrewExpansionDialogState;
   import core.entities.components.behaviors.states.CrewRewardDialogState;
   import core.entities.components.behaviors.states.CrewableDecorationState;
   import core.entities.components.behaviors.states.CyclonePowerDialogState;
   import core.entities.components.behaviors.states.DeathMatchDialogState;
   import core.entities.components.behaviors.states.DecoBuildableDefenseState;
   import core.entities.components.behaviors.states.DeepSeaDrillDialogState;
   import core.entities.components.behaviors.states.DefenseTowerDialogState;
   import core.entities.components.behaviors.states.DialogState;
   import core.entities.components.behaviors.states.DiveSiteDialogState;
   import core.entities.components.behaviors.states.DormantState;
   import core.entities.components.behaviors.states.DroneCommandAccumulatingState;
   import core.entities.components.behaviors.states.DroneCommandActiveState;
   import core.entities.components.behaviors.states.DroneCommandCooldownState;
   import core.entities.components.behaviors.states.EnergiserDialogState;
   import core.entities.components.behaviors.states.EnergiserTransmitterState;
   import core.entities.components.behaviors.states.EspionageHQDialogState;
   import core.entities.components.behaviors.states.EspionageHQSpeechClickState;
   import core.entities.components.behaviors.states.EventState;
   import core.entities.components.behaviors.states.FadeOutState;
   import core.entities.components.behaviors.states.FarmCampActiveState;
   import core.entities.components.behaviors.states.FarmCampCoolingState;
   import core.entities.components.behaviors.states.FarmCampDialogState;
   import core.entities.components.behaviors.states.FinishedState;
   import core.entities.components.behaviors.states.GoldenStatueDialogState;
   import core.entities.components.behaviors.states.InitBuildingState;
   import core.entities.components.behaviors.states.InitClearingState;
   import core.entities.components.behaviors.states.InitFinalingState;
   import core.entities.components.behaviors.states.LEUnitFactoryDialogState;
   import core.entities.components.behaviors.states.MasteryFactoryDialogState;
   import core.entities.components.behaviors.states.MechLabActivationAutoState;
   import core.entities.components.behaviors.states.MechLabConsumableAutoState;
   import core.entities.components.behaviors.states.MechLabPartsDialogState;
   import core.entities.components.behaviors.states.MechLabProductionAutoState;
   import core.entities.components.behaviors.states.MegaResearchAutoDialogState;
   import core.entities.components.behaviors.states.MegaResearchDialogState;
   import core.entities.components.behaviors.states.MeteoriteMiningDialogState;
   import core.entities.components.behaviors.states.MissionFactoryDialogState;
   import core.entities.components.behaviors.states.NeighborhoodDialogState;
   import core.entities.components.behaviors.states.NuclearPowerDialogState;
   import core.entities.components.behaviors.states.PVPImmunityDialogState;
   import core.entities.components.behaviors.states.PowerupFactoryDialogState;
   import core.entities.components.behaviors.states.PrisonCampActiveState;
   import core.entities.components.behaviors.states.PrisonCampDialogState;
   import core.entities.components.behaviors.states.PropFadeOutState;
   import core.entities.components.behaviors.states.PurchaseState;
   import core.entities.components.behaviors.states.QuestTreeDialogState;
   import core.entities.components.behaviors.states.RaffleCollectState;
   import core.entities.components.behaviors.states.RaffleRollState;
   import core.entities.components.behaviors.states.RandomRewardsState;
   import core.entities.components.behaviors.states.RebuildCrewDialogState;
   import core.entities.components.behaviors.states.RebuildDialogState;
   import core.entities.components.behaviors.states.ResearchAutoDialogState;
   import core.entities.components.behaviors.states.ResearchDialogState;
   import core.entities.components.behaviors.states.ResourceDialogState;
   import core.entities.components.behaviors.states.SimpleAutoCrewDialogState;
   import core.entities.components.behaviors.states.SimpleAutoMatchMakingState;
   import core.entities.components.behaviors.states.SimpleAutoState;
   import core.entities.components.behaviors.states.SimpleClickBuildingState;
   import core.entities.components.behaviors.states.SimpleClickState;
   import core.entities.components.behaviors.states.SpeechAutoState;
   import core.entities.components.behaviors.states.SuperOreDialogState;
   import core.entities.components.behaviors.states.SurveillanceScanPartsDialogState;
   import core.entities.components.behaviors.states.TBPlayAgainDialogState;
   import core.entities.components.behaviors.states.TimedBuildableDialogState;
   import core.entities.components.behaviors.states.TreasureVaultDialogState;
   import core.entities.components.behaviors.states.VolcanoPowerDialogState;
   import core.entities.components.behaviors.states.VolcanoReskin6DialogState;
   import core.entities.components.behaviors.states.WarRoomDialogState;
   import core.entities.components.behaviors.states.WarehouseDialogState;
   import core.entities.components.behaviors.states.WorldGamesDialogState;
   import core.entities.components.behaviors.states.ZGenerateState;
   import core.entities.components.behaviors.states.unitStates.AmphibiousIdleState;
   import core.entities.components.behaviors.states.unitStates.AmphibiousMoveToPositionState;
   import core.entities.components.behaviors.states.unitStates.IdleState;
   import core.entities.components.behaviors.states.unitStates.MoveToPositionState;
   import core.entities.components.behaviors.states.unitStates.RotateToPositionState;
   import core.entities.components.behaviors.states.unitStates.VisitorHelpState;
   import core.entities.components.states.IState;
   import core.entities.components.states.Machine;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import zlabs.debug.Logger;
   
   public class BehaviorFactory
   {
      
      private static var stateLocation:String = "core.entities.components.behaviors.states.";
      
      private var m_stateTypes:Array = [AnimationState,AutoDialogState,BehaviorState,BountyCenterDialogState,BuildingPartsDialogState,BuildingPartsCyberState,CapsuleAutoState,CapsuleClickState,CapsuleHousingCrewDialogState,CapsuleHousingPartsState,CrewableDecorationState,CrewDialogState,CrewExpansionDialogState,CrewRewardDialogState,DefenseTowerDialogState,DialogState,DormantState,EventState,FadeOutState,FinishedState,InitBuildingState,InitClearingState,InitFinalingState,LEUnitFactoryDialogState,MasteryFactoryDialogState,MechLabActivationAutoState,MechLabConsumableAutoState,MechLabPartsDialogState,MechLabProductionAutoState,MissionFactoryDialogState,PowerupFactoryDialogState,PrisonCampActiveState,PropFadeOutState,PurchaseState,PVPImmunityDialogState,QuestTreeDialogState,RandomRewardsState,RebuildDialogState,RebuildCrewDialogState,ResearchAutoDialogState,ResearchDialogState,ResourceDialogState,SimpleAutoCrewDialogState,SimpleAutoState,SimpleClickBuildingState,SimpleClickState,SurveillanceScanPartsDialogState
      ,WarehouseDialogState,AMSBuildingPartsDialogState,TreasureVaultDialogState,WarRoomDialogState,MegaResearchAutoDialogState,MegaResearchDialogState,AccelerationDialogState,AccelerationAutoDialogState,SuperOreDialogState,PrisonCampDialogState,EnergiserDialogState,EnergiserTransmitterState,SpeechAutoState,NeighborhoodDialogState,SimpleAutoMatchMakingState,DecoBuildableDefenseState,BuildingPartsAmityState,CommandoKillDialogState,CommandoSimpleClickState,CommandoKillActivateDialogState,CommandoKillActiveState,CommandoKillCoolingState,FarmCampDialogState,FarmCampActiveState,FarmCampCoolingState,DroneCommandActiveState,DroneCommandCooldownState,DroneCommandAccumulatingState,VolcanoPowerDialogState,WorldGamesDialogState,DiveSiteDialogState,GoldenStatueDialogState,RaffleCollectState,RaffleRollState,EspionageHQDialogState,EspionageHQSpeechClickState,MeteoriteMiningDialogState,DeepSeaDrillDialogState,CyclonePowerDialogState,NuclearPowerDialogState,VolcanoReskin6DialogState,TimedBuildableDialogState
      ,TBPlayAgainDialogState,IdleState,AmphibiousIdleState,MoveToPositionState,AmphibiousMoveToPositionState,RotateToPositionState,VisitorHelpState,ZGenerateState,DeathMatchDialogState,CampaignEntryState];
      
      public function BehaviorFactory()
      {
         super();
         throw new Error("Don\'t instantiate me, i have nothing but static functions...");
      }
      
      public static function createBehavior(param1:BehaviorStateInit) : void
      {
         var tempClass:Class = null;
         var stateIdx:int = 0;
         var stateClassName:String = null;
         var stateRefName:String = null;
         var _state:IState = null;
         var m:Machine = null;
         var behaviorStateInit:BehaviorStateInit = param1;
         var behaviorStates:Dictionary = new Dictionary();
         var stateList:XMLList = behaviorStateInit.m_behaviorData.state;
         if(stateList.length() > 0)
         {
            stateIdx = 0;
            while(stateIdx < stateList.length())
            {
               stateClassName = stateList[stateIdx].@className;
               try
               {
                  tempClass = getDefinitionByName(stateLocation + stateClassName + "State") as Class;
               }
               catch(e:ReferenceError)
               {
                  Logger.error("BehaviorFactory","createBehavior","Type is not found " + stateClassName + ", did you add it to the array in BehaviorFactory.as?");
               }
               if(tempClass)
               {
                  stateRefName = stateList[stateIdx].@stateName.toString();
                  behaviorStateInit.m_stateData = stateList[stateIdx];
                  _state = new tempClass(behaviorStateInit) as IState;
                  m = behaviorStateInit.m_machine;
                  behaviorStateInit.m_machine.addState(stateRefName,_state);
                  tempClass = null;
               }
               stateIdx++;
            }
         }
      }
   }
}

