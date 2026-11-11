package core.entities.components.utils
{
   import core.entities.components.UIControllerComponent;
   import core.entities.components.behaviors.states.BehaviorState;
   import core.gamemode.GMMultiHarvest;
   import dispatchers.UIDispatcher;
   import entity.GameDataComponent;
   import flash.events.Event;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   
   public class MultiHarvestHelper
   {
      
      private var m_id:int;
      
      private var m_owner:IEntity;
      
      private var m_state:BehaviorState;
      
      public function MultiHarvestHelper(param1:IEntity, param2:BehaviorState)
      {
         super();
         var _loc3_:GameDataComponent = GameDataComponent.getGameDataComponent(param1);
         this.m_id = _loc3_.id;
         this.m_owner = param1;
         this.m_state = param2;
      }
      
      public function enable() : void
      {
         UIDispatcher.instance.addEventListener(GMMultiHarvest.POLL,this.onPoll,false,0,true);
         UIDispatcher.instance.addEventListener(GMMultiHarvest.CLICKED,this.onClicked,false,0,true);
         UIDispatcher.instance.addEventListener(GMMultiHarvest.MODE_DISABLED,this.onModeDisabled,false,0,true);
         WindowManager.instance.addEventListener(WindowManager.SHOW_SCREEN,this.onShowScreen,false,0,true);
         PopupManager.instance.addEventListener(WindowManager.SHOW_SCREEN,this.onShowScreen,false,0,true);
         UIDispatcher.instance.dispatchEvent(new WorldEvent(GMMultiHarvest.HARVEST_ENABLED,{"id":this.m_id}));
      }
      
      public function dispose() : void
      {
         this.disable();
         this.m_owner = null;
         this.m_state = null;
      }
      
      public function disable() : void
      {
         UIDispatcher.instance.removeEventListener(GMMultiHarvest.POLL,this.onPoll);
         UIDispatcher.instance.removeEventListener(GMMultiHarvest.CLICKED,this.onClicked);
         UIDispatcher.instance.removeEventListener(GMMultiHarvest.MODE_DISABLED,this.onModeDisabled);
         WindowManager.instance.addEventListener(WindowManager.SHOW_SCREEN,this.onShowScreen,false,0,true);
         PopupManager.instance.addEventListener(WindowManager.SHOW_SCREEN,this.onShowScreen,false,0,true);
         this.setHighlightEnabled(false);
      }
      
      private function onPoll(param1:WorldEvent) : void
      {
         var _loc3_:GMMultiHarvest = null;
         var _loc2_:Boolean = false;
         if(param1.eventData.objIDs[this.m_id] != null)
         {
            _loc3_ = param1.eventData.gm as GMMultiHarvest;
            if(_loc3_)
            {
               this.generateInfo(_loc3_);
               _loc2_ = true;
            }
         }
         this.setHighlightEnabled(_loc2_);
      }
      
      private function onClicked(param1:WorldEvent) : void
      {
         var _loc2_:GMMultiHarvest = null;
         if(param1.eventData.objIDs[this.m_id] != null)
         {
            _loc2_ = param1.eventData.gm as GMMultiHarvest;
            if(_loc2_)
            {
               this.m_state.multiHarvest();
               this.setHighlightEnabled(false);
            }
         }
      }
      
      private function onModeDisabled(param1:Event = null) : void
      {
         this.setHighlightEnabled(false);
      }
      
      private function onShowScreen(param1:Event = null) : void
      {
         this.setHighlightEnabled(false);
      }
      
      private function setHighlightEnabled(param1:Boolean) : void
      {
         var _loc2_:String = param1 ? UIControllerComponent.FILTER_MULTIHARVEST_HIGHLIGHT_ON : UIControllerComponent.FILTER_MULTIHARVEST_HIGHLIGHT_OFF;
         var _loc3_:WorldEvent = new WorldEvent(UIControllerComponent.EVENT_FILTER_EFFECT,_loc2_);
         this.m_owner.eventDispatcher.dispatchEvent(_loc3_);
      }
      
      private function generateInfo(param1:GMMultiHarvest) : void
      {
         var _loc2_:Object = this.m_state.getEnergyDeductionInfo();
         if(_loc2_)
         {
            param1.registerEnergy(_loc2_.energy,_loc2_.pvp,this.m_id);
         }
      }
   }
}

