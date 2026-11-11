package displays.screens.contractScreen
{
   import core.entities.components.DecorationTargetComponent;
   import core.gameobjects.GameItem;
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import zlabs.entity.IEntity;
   import zlabs.resource.SWFResource;
   
   public class ResourceContractGrid extends ContractGrid
   {
      
      protected var m_resourceType:String = null;
      
      protected var m_discountInfo:Dictionary;
      
      protected var m_decoEffects:Array;
      
      public function ResourceContractGrid(param1:MovieClip, param2:SWFResource, param3:EventDispatcher, param4:IEntity, param5:String, param6:String, param7:String = null)
      {
         this.m_resourceType = param7;
         this.m_decoEffects = DecorationTargetComponent.getDecoEffectsForTarget(param4);
         this.m_discountInfo = DecorationTargetComponent.getDiscountForObject(param4);
         super(param1,param2,param3,param4,param5,param6);
      }
      
      override protected function createCard(param1:SWFResource, param2:MovieClip, param3:int, param4:int, param5:int = 0) : GridSlot
      {
         return new ResourceContractSlot(param1,param2,screen,m_listener,param3,param4,m_entity,m_items[param5],getMultFactor(),this.m_resourceType,this.m_discountInfo,this.m_decoEffects);
      }
      
      override protected function initGridSize() : void
      {
         setDimensions(2,2);
      }
      
      override protected function createItemList() : void
      {
         m_items = ContractsScreenItemCache.instance.itemListForEntity(m_entity,m_type,m_subtype,GameItem,false);
      }
   }
}

