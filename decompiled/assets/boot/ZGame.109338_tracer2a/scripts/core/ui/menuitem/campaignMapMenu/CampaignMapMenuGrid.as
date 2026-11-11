package core.ui.menuitem.campaignMapMenu
{
   import displays.screens.gridScreen.GridScreen;
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import zlabs.resource.SWFResource;
   
   public class CampaignMapMenuGrid extends GridScreen
   {
      
      private static const NUM_CARDS_IN_GRID:int = 6;
      
      private var m_info:CampaignMapMenuInfo = null;
      
      public function CampaignMapMenuGrid(param1:MovieClip, param2:CampaignMapMenuInfo)
      {
         this.m_info = param2;
         super();
         m_isVerticalGrid = true;
         setAnchor(param1.anchor_mc.x,param1.anchor_mc.y);
         setDimensions(1,NUM_CARDS_IN_GRID);
         load(param1,null);
      }
      
      override public function get numCards() : int
      {
         return this.m_info.count;
      }
      
      override protected function createCard(param1:SWFResource, param2:MovieClip, param3:int, param4:int, param5:int = 0) : GridSlot
      {
         return new CampaignMapMenuGridSlot(param2,param3,param4,this.m_info.getCampaignMapData(param5));
      }
      
      override protected function hasSpecialCard() : Boolean
      {
         return false;
      }
      
      override protected function setupArrows() : void
      {
      }
      
      override protected function disposeArrows() : void
      {
      }
      
      override protected function fixArrows(param1:int) : void
      {
         if(Boolean(m_screen.arrowLt_bt) && Boolean(m_screen.arrowLt_bt))
         {
            if(this.numCards <= numCardsPerPage)
            {
               m_screen.arrowLt_bt.visible = false;
               m_screen.arrowRt_bt.visible = false;
            }
            else
            {
               m_screen.arrowLt_bt.visible = true;
               m_screen.arrowRt_bt.visible = true;
               super.fixArrows(param1);
            }
         }
      }
   }
}

