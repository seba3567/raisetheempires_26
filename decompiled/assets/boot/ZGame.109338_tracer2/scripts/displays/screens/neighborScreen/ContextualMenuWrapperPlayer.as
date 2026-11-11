package displays.screens.neighborScreen
{
   import core.managers.tutorialManager.TutorialManager;
   import core.ui.ZGameButton;
   import core.ui.menuitem.FriendsBarUIItem;
   import flash.events.MouseEvent;
   import sound.ButtonSound;
   import utils.ZGameUtils;
   import zgame.assets.ui.FriendBar.ContextualMenuVisit;
   
   public class ContextualMenuWrapperPlayer extends ContextualMenuWrapperBase
   {
      
      private var m_button:ZGameButton;
      
      public function ContextualMenuWrapperPlayer(param1:NeighborSlot, param2:UserGrid)
      {
         super(param1,param2,ContextualMenuVisit);
         this.m_button = new ZGameButton(mc.orangeButton_01,this.onReturnHomeClick,1);
         this.m_button.text = ZGameUtils.ZlocT("Main","ContextMenuReturnHomeButton");
         buttonSounds.addButton(this.m_button.m_overlay,ButtonSound.DEFAULT);
         if(!TutorialManager.instance.neighborBarEnabled)
         {
            ZGameUtils.disableButton(mc.orangeButton_01,this.onReturnHomeClick);
            this.m_button.disable();
         }
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
      
      protected function onReturnHomeClick(param1:MouseEvent) : void
      {
         FriendsBarUIItem(FriendsBarUIItem.getFriendsBar()).returnToHomeIsland();
      }
   }
}

