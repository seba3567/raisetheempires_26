package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.gameobjects.GameItem;
   import core.gameobjects.PartsBuildingItem;
   import displays.screens.partsGather.BuildingPartsGather;
   import displays.screens.partsGather.RebuildParliamentPartsGather;
   import events.CloseEvent;
   import flash.events.EventDispatcher;
   import flash.utils.getDefinitionByName;
   import zlabs.debug.Logger;
   
   public class RebuildDialogState extends BuildingPartsDialogState
   {
      
      private static var m_partsDialogClasses:Array = [RebuildParliamentPartsGather];
      
      public function RebuildDialogState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function showDialog() : void
      {
         var _loc1_:GameItem = null;
         var _loc2_:PartsBuildingItem = null;
         var _loc3_:Boolean = false;
         if(ZGlobal.isHome())
         {
            _loc1_ = stateMachine.propertyBag.getProperty(dataProperty,null) as GameItem;
            _loc2_ = ZGlobal.gameSettings.getItemByCode(_loc1_.code,PartsBuildingItem) as PartsBuildingItem;
            if(Boolean(_loc2_) && Boolean(_loc2_.numParts > 0) && _loc2_.requiresAnyParts())
            {
               stateMachine.propertyBag.eventDispatcher.addEventListener(BuildingPartsGather.FINISHED,onFinished,false,0,true);
               stateMachine.propertyBag.eventDispatcher.addEventListener(CloseEvent.CLOSE,onCloseClick,false,0,true);
               this.displayPartsGather(_loc2_);
               return;
            }
            onFinished(null);
         }
      }
      
      private function displayPartsGather(param1:PartsBuildingItem) : void
      {
         var _loc2_:Class = null;
         var _loc3_:String = null;
         var _loc4_:Function = null;
         Logger.print(this,"JMR: m_data.@dialogPrefix: " + m_data.@dialogPrefix);
         if(m_data.@dialogPrefix.toString().length > 0)
         {
            _loc3_ = "" + m_data.@dialogPrefix + "PartsGather";
         }
         else
         {
            _loc3_ = "BuildingPartsGather";
         }
         _loc2_ = getDefinitionByName("displays.screens.partsGather." + _loc3_) as Class;
         _loc4_ = _loc2_["display"] as Function;
         _loc4_(EventDispatcher(stateMachine.propertyBag.eventDispatcher),param1.code,data.@desc,owner);
      }
   }
}

