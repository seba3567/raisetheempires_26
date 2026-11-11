package displays.screens.neighborScreen
{
   import core.managers.PVPManager;
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import zgame.assets.ui.StrangerBar.StrangerSlot;
   import zgame.assets.ui.StrangerBar.StrangerSlot2;
   import zlabs.resource.SWFResource;
   
   public class StrangerGrid extends UserGrid
   {
      
      public static const STRANGERBAR_DUMMY_SLOT:String = "dummySlotToken";
      
      public function StrangerGrid(param1:MovieClip, param2:Array, param3:Object)
      {
         super(param1,param2,param3);
      }
      
      public function set visible(param1:Boolean) : void
      {
         m_screen.visible = param1;
      }
      
      override protected function get slotClass() : Class
      {
         if(PVPManager.strangerBarType == PVPManager.STRANGERBAR_NORMAL)
         {
            return StrangerSlot;
         }
         return StrangerSlot2;
      }
      
      override protected function get gridSlotClass() : Class
      {
         if(PVPManager.strangerBarType == PVPManager.STRANGERBAR_NORMAL)
         {
            return StrangerGridSlot;
         }
         return StrangerGridSlotCompact;
      }
      
      override protected function shouldBeCustomCard(param1:Object) : Boolean
      {
         if(Boolean(param1 as String) && param1 as String == STRANGERBAR_DUMMY_SLOT)
         {
            return true;
         }
         return false;
      }
      
      override protected function createCustomCard(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:int) : GridSlot
      {
         return new StrangerGridBlankSlot(param1,param2,param3);
      }
      
      public function makeSlotsVisible(param1:int) : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc2_:int = m_clickPosition;
         var _loc3_:int = _loc2_ + numCardsPerPage - 1;
         var _loc4_:int = _loc3_;
         if(param1 - 1 >= _loc3_)
         {
            _loc4_ = param1;
         }
         else if(param1 <= _loc2_)
         {
            _loc4_ = param1;
         }
         if(_loc4_ != _loc3_)
         {
            _loc5_ = _loc4_ - numCardsPerPage + 1;
            _loc6_ = _loc5_ - m_clickPosition;
            slide(_loc6_);
         }
      }
   }
}

