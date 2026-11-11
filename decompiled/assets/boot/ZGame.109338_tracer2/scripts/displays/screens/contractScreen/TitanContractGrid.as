package displays.screens.contractScreen
{
   import core.entities.components.DecorationTargetComponent;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import dispatchers.UIDispatcher;
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class TitanContractGrid extends ContractGrid
   {
      
      private var m_discountInfo:Dictionary;
      
      private var m_requiredUnitTypes:Array = null;
      
      public function TitanContractGrid(param1:MovieClip, param2:SWFResource, param3:EventDispatcher, param4:IEntity, param5:String, param6:String, param7:Array)
      {
         this.m_discountInfo = DecorationTargetComponent.getDiscountForObject(param4);
         this.m_requiredUnitTypes = param7;
         super(param1,param2,param3,param4,param5,param6);
      }
      
      public function set requiredUnitTypes(param1:Array) : void
      {
         this.m_requiredUnitTypes = param1;
         this.createItemList();
         UIDispatcher.instance.dispatchEvent(new WorldEvent(ContractGrid.EVENT_UPDATE_SLOTS));
      }
      
      private function filterRequiredUnitType(param1:GameItem) : Boolean
      {
         var _loc3_:String = null;
         var _loc2_:UnitItem = param1 as UnitItem;
         if(_loc2_ != null)
         {
            if(this.m_requiredUnitTypes == null)
            {
               return true;
            }
            for each(_loc3_ in this.m_requiredUnitTypes)
            {
               if(!_loc2_.hasType(_loc3_))
               {
                  return false;
               }
            }
            return true;
         }
         return false;
      }
      
      override protected function getMultFactor() : Number
      {
         return 1.01;
      }
      
      override protected function createCard(param1:SWFResource, param2:MovieClip, param3:int, param4:int, param5:int = 0) : GridSlot
      {
         if(m_items[param5].usesCashOnly())
         {
            return new UnitCashContractSlot(param1,param2,screen,m_listener,param3,param4,m_entity,m_items[param5],this.getMultFactor());
         }
         return new UnitContractSlot(param1,param2,screen,m_listener,param3,param4,m_entity,m_items[param5],this.getMultFactor(),this.m_discountInfo);
      }
      
      override protected function initGridSize() : void
      {
         setDimensions(2,1);
      }
      
      override protected function createItemList() : void
      {
         m_items = ContractsScreenItemCache.instance.itemListForEntity(m_entity,m_type,m_subtype,UnitItem,true,this.filterRequiredUnitType);
      }
      
      override protected function preUpdateVisibility() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = int(m_cards.length);
         this.updateCardVisibility(_loc1_,_loc2_);
      }
      
      override protected function postUpdateVisibility() : void
      {
         var _loc1_:int = Math.abs(clickPosition) / width * numCardsPerPage;
         var _loc2_:int = _loc1_ + numCardsPerPage;
         this.updateCardVisibility(_loc1_,_loc2_);
      }
      
      private function updateCardVisibility(param1:int, param2:int) : void
      {
         var _loc4_:GridSlot = null;
         var _loc3_:int = 0;
         for each(_loc4_ in m_cards)
         {
            _loc4_.slot.visible = _loc3_ >= param1 && _loc3_ < param2;
            _loc3_++;
         }
      }
   }
}

