package displays.screens.contractScreen
{
   import core.entities.components.DecorationTargetComponent;
   import core.gameobjects.UnitItem;
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import zlabs.entity.IEntity;
   import zlabs.resource.SWFResource;
   
   public class UnitContractGrid extends ContractGrid
   {
      
      private var m_discountInfo:Dictionary;
      
      private var m_decoEffects:Array;
      
      public function UnitContractGrid(param1:MovieClip, param2:SWFResource, param3:EventDispatcher, param4:IEntity, param5:String, param6:String)
      {
         this.m_decoEffects = DecorationTargetComponent.getDecoEffectsForTarget(param4);
         this.m_discountInfo = DecorationTargetComponent.getDiscountForObject(param4);
         super(param1,param2,param3,param4,param5,param6);
      }
      
      override protected function getMultFactor() : Number
      {
         return 0.98;
      }
      
      override protected function createCard(param1:SWFResource, param2:MovieClip, param3:int, param4:int, param5:int = 0) : GridSlot
      {
         if(m_items[param5].usesCashOnly())
         {
            return new UnitCashContractSlot(param1,param2,screen,m_listener,param3,param4,m_entity,m_items[param5],this.getMultFactor());
         }
         return new UnitContractSlot(param1,param2,screen,m_listener,param3,param4,m_entity,m_items[param5],this.getMultFactor(),this.m_discountInfo,this.m_decoEffects);
      }
      
      override protected function initGridSize() : void
      {
         setDimensions(2,2);
      }
      
      override protected function createItemList() : void
      {
         m_items = ContractsScreenItemCache.instance.itemListForEntity(m_entity,m_type,m_subtype,UnitItem,true);
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
         var _loc5_:GridSlot = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc3_:Array = [0,2,1,3];
         var _loc4_:int = 0;
         for each(_loc5_ in m_cards)
         {
            _loc6_ = _loc4_ / numCardsPerPage;
            _loc7_ = _loc4_ - _loc6_ * 4;
            _loc8_ = _loc3_[_loc7_] + _loc6_ * 4;
            _loc5_.slot.visible = _loc8_ >= param1 && _loc8_ < param2;
            _loc4_++;
         }
      }
   }
}

