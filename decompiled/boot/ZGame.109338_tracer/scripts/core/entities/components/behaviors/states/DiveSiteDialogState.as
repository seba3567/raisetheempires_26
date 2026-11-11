package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.states.IMachine;
   import core.managers.QuestBuildableManager;
   import core.managers.WorldObjectManager;
   import displays.popups.DiveSitePopUp;
   import displays.popups.QuestBuildableRewardPopup;
   import flash.events.Event;
   import zlabs.displays.popups.PopUpBase;
   import zlabs.entity.IEntity;
   
   public class DiveSiteDialogState extends CrewRewardDialogState
   {
      
      public function DiveSiteDialogState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function performEnterActions() : void
      {
         super.performEnterActions();
         QuestBuildableManager.instance.addEventListener(QuestBuildableManager.REMOVE_SITE,this.onRemoveSite,false,0,true);
      }
      
      override protected function createPopup(param1:IEntity) : PopUpBase
      {
         if(ZGlobal.player.getNumberOfInventoryItems(QuestBuildableManager.GOLDEN_STATUE) >= 1)
         {
            return new QuestBuildableRewardPopup(QuestBuildableManager.GOLDEN_STATUE);
         }
         return new DiveSitePopUp(param1,m_wrapper,m_item,m_crewInfo,textInfo,m_data.@crewBackgroundSWF,m_data.@teaserIcon,m_data.@crewPopupValue,m_data.@crewPopupChance,m_data.@paddingTop,m_data.@kingdom);
      }
      
      override public function onClick(param1:Event) : void
      {
         if(WorldObjectManager.instance.getNumberObjectsWithCode(QuestBuildableManager.GOLDEN_STATUE) > 0)
         {
            clickNextStateClientUpdateOnly();
         }
         else
         {
            super.onClick(param1);
         }
      }
      
      override protected function performExitActions(param1:IMachine) : void
      {
         QuestBuildableManager.instance.removeEventListener(QuestBuildableManager.REMOVE_SITE,this.onRemoveSite);
         super.performExitActions(param1);
      }
      
      private function onRemoveSite(param1:Event) : void
      {
         clickNextStateClientUpdateOnly();
      }
   }
}

