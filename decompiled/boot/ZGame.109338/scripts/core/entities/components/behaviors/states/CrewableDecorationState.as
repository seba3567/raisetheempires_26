package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.states.IMachine;
   import core.managers.CrewManager;
   import core.managers.decorationsManager.DecorationsManager;
   import displays.popups.decorations.CrewableDecorationPopup;
   import entity.GameDataComponent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.WindowManager;
   
   public class CrewableDecorationState extends DialogState
   {
      
      private var OVERLAY_STATE_EMPTY:int = 0;
      
      private var OVERLAY_STATE_CREWED:int = 1;
      
      private var OVERLAY_STATE_BUYOUTENABALED:int = 2;
      
      private var m_overlayLookups:Array = [{
         "icon":"CrewableIconEmpty.png",
         "bkgd":"Bubble.png"
      },{
         "icon":"CrewableIcon.png",
         "bkgd":"Bubble.png"
      },null];
      
      public function CrewableDecorationState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      private function get overlayState() : int
      {
         var _loc1_:GameDataComponent = GameDataComponent.getGameDataComponent(owner);
         if(_loc1_)
         {
            if(_loc1_.crewBuyOnceEnabled)
            {
               return this.OVERLAY_STATE_BUYOUTENABALED;
            }
            if(Boolean(_loc1_.userData) && Boolean(_loc1_.userData.crewInfo as Array) && Boolean(_loc1_.userData.crewInfo.length))
            {
               return this.OVERLAY_STATE_CREWED;
            }
         }
         return this.OVERLAY_STATE_EMPTY;
      }
      
      private function get overlayXML() : XML
      {
         var _loc1_:int = 0;
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:XML = null;
         if(this.enabled)
         {
            _loc1_ = this.overlayState;
            if(this.m_overlayLookups[_loc1_])
            {
               _loc2_ = this.m_overlayLookups[_loc1_].icon;
               _loc3_ = this.m_overlayLookups[_loc1_].bkgd;
               return <data icon={_loc2_} background={_loc3_} backgroundOffset="-25,-100" iconOffset="3,1"/>;
            }
         }
         return null;
      }
      
      override protected function updateOverlay() : void
      {
         var _loc1_:XML = null;
         if(this.enabled && !ZGlobal.isVisiting() && CrewManager.isCrewBuilding(owner))
         {
            _loc1_ = this.overlayXML;
            if(_loc1_)
            {
               owner.setProperty(overlayDataProperty,{"xml":_loc1_});
            }
            else
            {
               removeOverlay();
            }
         }
      }
      
      private function get enabled() : Boolean
      {
         return DecorationsManager.instance.enabled;
      }
      
      override protected function showDialog() : void
      {
         var _loc1_:CrewableDecorationPopup = null;
         if(this.enabled && !ZGlobal.isVisiting() && CrewManager.isCrewBuilding(owner))
         {
            _loc1_ = new CrewableDecorationPopup(owner);
            WindowManager.instance.push(_loc1_);
         }
      }
      
      override protected function performEnterActions() : void
      {
         super.performEnterActions();
         if(this.enabled)
         {
            owner.eventDispatcher.addEventListener(GameDataComponent.CREW_UPDATED,this.onCrewUpdated);
         }
      }
      
      override protected function performExitActions(param1:IMachine) : void
      {
         this.removeListener();
         super.performExitActions(param1);
      }
      
      override public function stop() : void
      {
         this.removeListener();
         super.stop();
      }
      
      private function removeListener() : void
      {
         owner.eventDispatcher.removeEventListener(GameDataComponent.CREW_UPDATED,this.onCrewUpdated);
      }
      
      private function onCrewUpdated(param1:WorldEvent) : void
      {
         this.updateOverlay();
      }
   }
}

