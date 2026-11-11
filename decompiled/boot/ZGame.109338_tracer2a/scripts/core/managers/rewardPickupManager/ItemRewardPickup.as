package core.managers.rewardPickupManager
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.ui.feedbacktext.ItemFeedbackText;
   
   public class ItemRewardPickup extends RewardPickup
   {
      
      private var m_item:GameItem = null;
      
      public function ItemRewardPickup(param1:GameItem)
      {
         this.m_item = param1;
         m_feedbackText = new ItemFeedbackText(this.m_item.code,1);
         super(1,"item",false);
      }
      
      override protected function doReward(param1:int) : void
      {
         super.doReward(param1);
         ZGlobal.player.addToInventory(this.m_item.code);
      }
      
      override protected function getImageUrl(param1:int) : String
      {
         if(this.m_item.hasCachedImage("doober"))
         {
            return this.m_item.getCachedImage("doober").url;
         }
         return this.m_item.getCachedImage("icon").url;
      }
      
      override protected function get uiName() : String
      {
         return this.m_item.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
      }
      
      override public function get pickupName() : String
      {
         return "item";
      }
      
      override protected function get soundEvent() : String
      {
         if(Boolean(this.m_item.xml.sound) && this.m_item.xml.sound.length() > 0)
         {
            return this.m_item.xml.sound[0].@name;
         }
         return "xpPickup";
      }
      
      override protected function get scaleto60() : Boolean
      {
         return true;
      }
   }
}

