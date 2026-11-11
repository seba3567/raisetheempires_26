package core.entities.components
{
   import core.ZGlobal;
   import core.gameobjects.Fleet;
   import core.managers.questManager.ZGameTask;
   import dispatchers.UIDispatcher;
   import entity.GameDataComponent;
   import events.ProgressBarEvent;
   import flash.events.Event;
   import utils.MegaUnitUtils;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   
   public class MegaUnitProgressBarComponent extends ProgressBarComponent
   {
      
      public function MegaUnitProgressBarComponent()
      {
         super();
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         sprite.addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         UIDispatcher.instance.addEventListener(UIDispatcher.UI_PLAYER_ISLAND_MODE_ACTIVE,this.onIslandModeActivated);
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         sprite.removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         UIDispatcher.instance.removeEventListener(UIDispatcher.UI_PLAYER_ISLAND_MODE_ACTIVE,this.onIslandModeActivated);
      }
      
      override protected function onUpdateProgressBar(param1:ProgressBarEvent) : void
      {
         var _loc4_:Number = NaN;
         var _loc2_:String = this.getFleetName();
         var _loc3_:Fleet = Fleet.getFleet(_loc2_);
         if(_loc3_)
         {
            _loc4_ = _loc3_.getStrengthPercentage();
            param1.progress = _loc4_;
            param1.message = ZGameUtils.ZlocT("MegaUnit","WorldProgressBar",{"percent":int(_loc4_ * 100)});
            super.onUpdateProgressBar(param1);
         }
      }
      
      private function onIslandModeActivated(param1:WorldEvent) : void
      {
         if(param1.eventData.active)
         {
            if(ZGlobal.visitMode == ZGlobal.MODE_HOME)
            {
               this.onUpdateProgressBar(new ProgressBarEvent(ProgressBarEvent.START_PROGRESS_BAR));
            }
         }
      }
      
      private function getFleetName() : String
      {
         var _loc1_:GameDataComponent = GameDataComponent.getGameDataComponent(owner);
         var _loc2_:String = _loc1_.gameData.code;
         var _loc3_:ZGameTask = MegaUnitUtils.getQuestTask(_loc2_);
         if(_loc3_)
         {
            return _loc3_.fleetName;
         }
         return null;
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         owner.eventDispatcher.dispatchEvent(new ProgressBarEvent(ProgressBarEvent.PROGRESS_BAR_DRAWN));
      }
   }
}

