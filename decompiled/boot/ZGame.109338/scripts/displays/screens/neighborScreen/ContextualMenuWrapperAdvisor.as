package displays.screens.neighborScreen
{
   import core.ui.ZGameButton;
   import sound.ButtonSound;
   import utils.ZGameUtils;
   import zgame.assets.ui.FriendBar.ContextualMenuVisit;
   
   public class ContextualMenuWrapperAdvisor extends ContextualMenuWrapperBase
   {
      
      private var m_button:ZGameButton;
      
      public function ContextualMenuWrapperAdvisor(param1:NeighborSlot, param2:UserGrid)
      {
         super(param1,param2,ContextualMenuVisit);
         this.m_button = new ZGameButton(mc.orangeButton_01,onVisitClick,1);
         this.m_button.text = ZGameUtils.ZlocT("Main","ContextMenuVisitButton");
         buttonSounds.addButton(this.m_button.m_overlay,ButtonSound.DEFAULT);
      }
      
      override protected function onDispose() : void
      {
         super.onDispose();
         if(this.m_button)
         {
            this.m_button.dispose();
            this.m_button = null;
         }
      }
   }
}

