package displays.screens.neighborScreen
{
   import core.ui.menuitem.FriendsBarUIItem;
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import zlabs.resource.SWFResource;
   
   public class Varient1NeighborGrid extends ControlNeighborGrid
   {
      
      private var m_card:GridSlot = null;
      
      public function Varient1NeighborGrid(param1:MovieClip, param2:Array, param3:FriendsBarUIItem)
      {
         super(param1,param2,param3);
      }
      
      override protected function configureForWidth(param1:Number) : void
      {
         super.configureForWidth(param1);
         target.maskVarient_mc.width = (m_numSlots - 1) * target.slot_0.width;
      }
      
      override protected function get numSlots() : int
      {
         return m_numSlots - 1;
      }
      
      override protected function load(param1:MovieClip, param2:SWFResource) : void
      {
         super.load(param1,param2);
         param1.anchor_mc.mask = param1.maskVarient_mc;
         param1.mask_mc.visible = false;
         if(!this.m_card)
         {
            this.m_card = new RecommendedNeighborSlot(param2,param1,screen,param1.slot_7.x);
         }
         this.m_card.slot.y = param1.slot_7.y;
         param1.arrowSingleLt_bt.x = param1.arrowSingleLtVarient_bt.x;
         param1.arrowLt_bt.x = param1.arrowLtVarient_bt.x;
      }
      
      override public function startRotation() : void
      {
         RecommendedNeighborSlot(this.m_card).startRotation();
      }
   }
}

