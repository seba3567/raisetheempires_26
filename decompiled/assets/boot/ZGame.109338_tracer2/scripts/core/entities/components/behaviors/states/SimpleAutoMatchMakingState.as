package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.states.IInput;
   import core.gameobjects.GameItem;
   import core.managers.CrewManager;
   import core.managers.MatchMakingManager;
   import displays.screens.CrewResizablePopUp;
   import displays.screens.MatchMakingScreen;
   import entity.GameDataComponent;
   import flash.events.Event;
   import zlabs.displays.popups.PopUpBase;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   
   public class SimpleAutoMatchMakingState extends SimpleAutoState implements IInput
   {
      
      private var m_gameItem:GameItem;
      
      private var m_gameObject:Object;
      
      private var m_window:PopUpBase;
      
      public function SimpleAutoMatchMakingState(param1:BehaviorStateInit)
      {
         this.m_gameItem = param1.m_gameItem;
         super(param1);
      }
      
      public function onClick(param1:Event) : void
      {
         var _loc2_:IEntity = null;
         var _loc3_:GameDataComponent = null;
         if(ZGlobal.isHome() && MatchMakingManager.instance.isActive() && MatchMakingManager.instance.initialized)
         {
            _loc2_ = stateMachine.propertyBag as IEntity;
            _loc3_ = GameDataComponent(_loc2_.lookupComponentByType(GameDataComponent));
            this.m_gameObject = _loc3_.userData;
            this.m_window = MatchMakingScreen.display(_loc2_,this.m_gameItem,this.m_gameObject);
            this.m_window.addEventListener(CrewResizablePopUp.BUILT,this.onBuilt,false,0,true);
         }
         else
         {
            ZGlobal.isHome() && MatchMakingManager.instance.isActive() && !MatchMakingManager.instance.initialized;
         }
         MatchMakingManager.instance.getMatchMakingData();
      }
      
      public function onBuilt(param1:Event) : void
      {
         if(CrewManager.isCrewBuildingFull(owner))
         {
            this.m_window.removeEventListener(CrewResizablePopUp.BUILT,this.onBuilt);
            clickNextState();
         }
      }
      
      public function onRollOver(param1:Event) : void
      {
      }
      
      override protected function performEnterActions() : void
      {
         super.performEnterActions();
         owner.eventDispatcher.addEventListener(GameDataComponent.CREW_UPDATED,this.onCrewUpdated,false,0,true);
      }
      
      protected function onCrewUpdated(param1:WorldEvent) : void
      {
         CrewManager.instance.dispatchEvent(new WorldEvent(CrewManager.CREW_UPDATED));
      }
   }
}

