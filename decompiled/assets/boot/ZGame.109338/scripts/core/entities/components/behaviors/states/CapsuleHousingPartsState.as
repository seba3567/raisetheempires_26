package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.gameobjects.GameItem;
   import core.gameobjects.PartsBuildingItem;
   import displays.screens.partsGather.CapsuleHousingPartsGather;
   import events.CloseEvent;
   import flash.events.EventDispatcher;
   
   public class CapsuleHousingPartsState extends BuildingPartsDialogState
   {
      
      private static const QUEST_ID:String = "QBB35_01";
      
      public function CapsuleHousingPartsState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function showDialog() : void
      {
         var _loc1_:GameItem = null;
         var _loc2_:PartsBuildingItem = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         if(ZGlobal.isHome())
         {
            _loc1_ = stateMachine.propertyBag.getProperty(dataProperty,null) as GameItem;
            _loc2_ = ZGlobal.gameSettings.getItemByCode(_loc1_.code,PartsBuildingItem) as PartsBuildingItem;
            if(Boolean(_loc2_) && Boolean(_loc2_.numParts > 0) && _loc2_.requiresAnyParts())
            {
               stateMachine.propertyBag.eventDispatcher.addEventListener(CapsuleHousingPartsGather.FINISHED,onFinished,false,0,true);
               stateMachine.propertyBag.eventDispatcher.addEventListener(CloseEvent.CLOSE,onCloseClick,false,0,true);
               _loc3_ = data.@desc;
               _loc4_ = null;
               _loc5_ = null;
               if(_loc2_.xml.@buildingPartsDesc != undefined)
               {
                  _loc3_ = _loc2_.xml.@buildingPartsDesc;
               }
               if(_loc2_.xml.@buildingPartsDesc2 != undefined)
               {
                  _loc4_ = _loc2_.xml.@buildingPartsDesc2;
               }
               if(_loc2_.xml.@buildingPartsRewardDesc != undefined)
               {
                  _loc5_ = _loc2_.xml.@buildingPartsRewardDesc;
               }
               CapsuleHousingPartsGather.display(EventDispatcher(stateMachine.propertyBag.eventDispatcher),_loc2_.code,QUEST_ID,_loc3_,owner,data.@tit,_loc4_,_loc5_);
               return;
            }
            onFinished(null);
         }
      }
   }
}

