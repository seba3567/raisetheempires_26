package displays.screens.contractScreen
{
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class ContractSlot extends GridSlot
   {
      
      public static const CONTRACT_SLOT_PURCHASE:String = "contractSlotPurchase";
      
      protected var m_listener:EventDispatcher = null;
      
      protected var m_entity:IEntity = null;
      
      protected var m_buildBtn:ZGameButton = null;
      
      protected var m_imageLoaders:Array = null;
      
      protected var m_isBuyable:Boolean = false;
      
      protected var m_unlockBtn:ZGameButton = null;
      
      protected var m_isUnlockable:Boolean = false;
      
      public function ContractSlot(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:EventDispatcher, param5:int, param6:int, param7:IEntity, param8:Number)
      {
         this.m_listener = param4;
         this.m_entity = param7;
         super(param1,param2,param3);
         slot.x = param5 * param8 * slot.width;
         slot.y = param6 * param8 * slot.height;
         this.populateCard();
      }
      
      override public function dispose() : void
      {
         if(this.m_buildBtn)
         {
            this.m_buildBtn.dispose();
            this.m_buildBtn = null;
         }
         if(this.m_unlockBtn)
         {
            this.m_unlockBtn.dispose();
            this.m_unlockBtn = null;
         }
         this.disposeImageLoaders();
         this.m_listener = null;
         this.m_entity = null;
         super.dispose();
      }
      
      override protected function createSlot(param1:SWFResource) : MovieClip
      {
         return null;
      }
      
      protected function populateCard() : void
      {
      }
      
      protected function purchaseEventObject() : Object
      {
         return null;
      }
      
      protected function disposeImageLoaders() : void
      {
         var _loc1_:ImageLoader = null;
         for each(_loc1_ in this.m_imageLoaders)
         {
            if(_loc1_)
            {
               _loc1_.destroy();
            }
         }
         this.m_imageLoaders = null;
      }
      
      protected function onSelectButton(param1:MouseEvent) : void
      {
         if(this.m_isBuyable)
         {
            this.m_listener.dispatchEvent(new WorldEvent(CONTRACT_SLOT_PURCHASE,this.purchaseEventObject()));
         }
      }
      
      override protected function doOnClick(param1:MouseEvent) : void
      {
         this.onSelectButton(param1);
      }
   }
}

