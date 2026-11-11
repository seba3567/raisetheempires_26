package displays.popups.obtainRequirement
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import utils.ZGameUtils;
   
   public class ObtainRequirementPopupInfoUseItem implements IObtainRequirementPopupInfo
   {
      
      private var m_item:GameItem = null;
      
      private var m_amount:uint = 0;
      
      public function ObtainRequirementPopupInfoUseItem(param1:int)
      {
         super();
         this.m_item = ZGlobal.player.energyItem(param1,false);
         this.m_amount = param1;
      }
      
      public function onAskButton() : void
      {
      }
      
      public function onPurchase() : void
      {
      }
      
      public function get requirementGameItem() : GameItem
      {
         return this.m_item;
      }
      
      public function get buyQuantity() : Number
      {
         return 0;
      }
      
      public function get resourceAmount() : Number
      {
         return this.m_item.energyYield;
      }
      
      public function get dialogTitleText() : String
      {
         return null;
      }
      
      public function get dialogSubtitleText() : String
      {
         return null;
      }
      
      public function get askTitleText() : String
      {
         return this.m_item.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
      }
      
      public function get askDescText() : String
      {
         return ZGameUtils.ZlocT("Dialogs","BuyEnergyAmount",{"amount":this.resourceAmount});
      }
      
      public function get askButtonText() : String
      {
         return ZGameUtils.ZlocT("Dialogs","Use");
      }
      
      public function get askIconURL() : String
      {
         return this.m_item.getCachedImage("icon").url;
      }
      
      public function get buyTitleText() : String
      {
         return null;
      }
      
      public function get buyDescText() : String
      {
         return null;
      }
      
      public function get buyCost() : Number
      {
         return 0;
      }
      
      public function get buyButtonText() : String
      {
         return null;
      }
      
      public function get buyIconURL() : String
      {
         return this.m_item.getCachedImage("icon").url;
      }
      
      public function get goNowTitleText() : String
      {
         return null;
      }
      
      public function get goNowDescText() : String
      {
         return null;
      }
      
      public function get goNowButtonText() : String
      {
         return null;
      }
      
      public function get goNowIconURL() : String
      {
         return null;
      }
   }
}

