package displays.screens.dominationMode
{
   import displays.screens.gridScreen.GridScreen;
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import sound.ButtonSound;
   import zlabs.resource.SWFResource;
   
   public class DominationModeChatHistoryGrid extends GridScreen
   {
      
      private static const NUM_CARDS_IN_GRID:int = 4;
      
      private var m_numCards:int = 10;
      
      private var m_chatData:Array = null;
      
      public function DominationModeChatHistoryGrid(param1:MovieClip, param2:SWFResource, param3:Array)
      {
         super();
         m_isVerticalGrid = true;
         setAnchor(param1.anchor_mc.x,param1.anchor_mc.y);
         setDimensions(1,NUM_CARDS_IN_GRID);
         m_resource = param2;
         this.m_chatData = param3;
         load(param1,param2);
      }
      
      override protected function setupArrows() : void
      {
         m_buttonSounds.addButton(m_screen.down_mc,ButtonSound.DEFAULT);
         m_buttonSounds.addButton(m_screen.up_mc,ButtonSound.DEFAULT);
         m_buttonSounds.addButton(m_screen.pageDown_mc,ButtonSound.DEFAULT);
         m_buttonSounds.addButton(m_screen.pageUp_mc,ButtonSound.DEFAULT);
         m_screen.down_mc.addEventListener(MouseEvent.CLICK,this.onDownClick,false,0,true);
         m_screen.up_mc.addEventListener(MouseEvent.CLICK,this.onUpClick,false,0,true);
         m_screen.pageDown_mc.addEventListener(MouseEvent.CLICK,this.onPageDownClick,false,0,true);
         m_screen.pageUp_mc.addEventListener(MouseEvent.CLICK,this.onPageUpClick,false,0,true);
      }
      
      override protected function disposeArrows() : void
      {
         m_screen.down_mc.removeEventListener(MouseEvent.CLICK,this.onDownClick);
         m_screen.up_mc.removeEventListener(MouseEvent.CLICK,this.onUpClick);
         m_screen.pageDown_mc.removeEventListener(MouseEvent.CLICK,this.onPageDownClick);
         m_screen.pageUp_mc.removeEventListener(MouseEvent.CLICK,this.onPageUpClick);
      }
      
      override public function get numCards() : int
      {
         return this.m_chatData ? int(this.m_chatData.length) : 0;
      }
      
      override protected function createCard(param1:SWFResource, param2:MovieClip, param3:int, param4:int, param5:int = 0) : GridSlot
      {
         if(this.m_chatData[param5] != null)
         {
            return new DominationModeChatHistoryGridSlot(m_resource,param2,param3,param4,this.m_chatData[param5],param5);
         }
         return null;
      }
      
      override protected function hasSpecialCard() : Boolean
      {
         return false;
      }
      
      override protected function fixArrows(param1:int) : void
      {
         if(this.numCards <= numCardsPerPage)
         {
            m_screen.down_mc.visible = false;
            m_screen.up_mc.visible = false;
            m_screen.pageDown_mc.visible = false;
            m_screen.pageUp_mc.visible = false;
         }
         else
         {
            m_screen.down_mc.visible = true;
            m_screen.up_mc.visible = true;
            m_screen.pageDown_mc.visible = true;
            m_screen.pageUp_mc.visible = true;
         }
      }
      
      protected function onDownClick(param1:MouseEvent) : void
      {
         slide(-1);
      }
      
      protected function onUpClick(param1:MouseEvent) : void
      {
         slide(1);
      }
      
      protected function onPageDownClick(param1:MouseEvent) : void
      {
         slide(-m_cardsPerPage);
      }
      
      protected function onPageUpClick(param1:MouseEvent) : void
      {
         slide(m_cardsPerPage);
      }
   }
}

