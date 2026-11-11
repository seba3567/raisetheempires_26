package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.gameobjects.GameItem;
   import displays.screens.SuperOreScreen;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import zlabs.entity.PropertyReference;
   import zlabs.events.WorldEvent;
   
   public class SuperOreDialogState extends DialogState
   {
      
      private var overlayIconNameProperty:PropertyReference = new PropertyReference("@Overlay.iconName");
      
      private var m_multiplier:int = 1;
      
      public function SuperOreDialogState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function showDialog() : void
      {
         var _loc1_:GameItem = stateMachine.propertyBag.getProperty(dataProperty,null) as GameItem;
         stateMachine.propertyBag.eventDispatcher.addEventListener(SuperOreScreen.CONTRACT_SELECTED,this.onContractSelected,false,0,true);
         window = SuperOreScreen.display(EventDispatcher(stateMachine.propertyBag.eventDispatcher),_loc1_.code,owner,this.multiplierCallback);
      }
      
      protected function multiplierCallback(param1:int) : void
      {
         this.m_multiplier = param1;
      }
      
      override public function buy(param1:GameItem, param2:Boolean, param3:Boolean = false) : void
      {
         var _loc4_:Dictionary = decoDiscountInfo;
         var _loc5_:Boolean = param1.usesCashOnly();
         ZGlobal.player.buyItem(param1,_loc5_,1,null,param3,_loc4_);
         m_stateMachine.storeReferenceData(param1.name);
      }
      
      protected function onContractSelected(param1:WorldEvent) : void
      {
         var _loc2_:GameItem = param1.eventData as GameItem;
         stateMachine.propertyBag.eventDispatcher.removeEventListener(SuperOreScreen.CONTRACT_SELECTED,this.onContractSelected);
         stateMachine.storeReferenceData(_loc2_.name);
         stateMachine.resourceType = _loc2_.resourceName;
         stateMachine.multiplier = ZGlobal.player.currentResourceMultiplier(_loc2_.resourceName);
         clickNextState();
      }
      
      override protected function getSetStateReferenceItemName() : String
      {
         var _loc1_:GameItem = ZGlobal.gameSettings.getItemByName(stateMachine.referenceItemName,GameItem) as GameItem;
         return _loc1_.code + ":" + stateMachine.resourceType + ":" + stateMachine.multiplier;
      }
   }
}

