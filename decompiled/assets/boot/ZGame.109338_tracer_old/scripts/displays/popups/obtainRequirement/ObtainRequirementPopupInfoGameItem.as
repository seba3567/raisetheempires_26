package displays.popups.obtainRequirement
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.viralsManager.ViralsManager;
   import utils.ZGameUtils;
   
   public class ObtainRequirementPopupInfoGameItem implements IObtainRequirementPopupInfo
   {
      
      private var m_code:String = null;
      
      private var m_item:GameItem = null;
      
      private var m_amount:uint = 0;
      
      public function ObtainRequirementPopupInfoGameItem(param1:String, param2:uint)
      {
         super();
         this.m_code = param1;
         this.m_amount = param2;
         this.m_item = ZGlobal.gameSettings.getItemByCode(this.m_code,GameItem) as GameItem;
      }
      
      public function onAskButton() : void
      {
         ViralsManager.instance.sendItemFeed(this.m_code);
      }
      
      public function onPurchase() : void
      {
         ZGlobal.player.buyGameItem(this.m_item,true,this.m_amount);
      }
      
      public function get requirementGameItem() : GameItem
      {
         return this.m_item;
      }
      
      public function get buyQuantity() : Number
      {
         return this.m_amount;
      }
      
      public function get resourceAmount() : Number
      {
         return this.m_amount;
      }
      
      public function get dialogTitleText() : String
      {
         return ZGameUtils.ZlocT("Dialogs",this.m_code + "_OutofItemTitle");
      }
      
      public function get dialogSubtitleText() : String
      {
         return ZGameUtils.ZlocT("Dialogs",this.m_code + "_OutofItemMessage");
      }
      
      public function get askTitleText() : String
      {
         return ZGameUtils.ZlocT("Dialogs","ObtainRequirementGameItemAskTitle",{"gameItem":this.m_item.getSentenceNameLocalizationObject("plural")});
      }
      
      public function get askDescText() : String
      {
         return ZGameUtils.ZlocT("Dialogs","ObtainRequirementGameItemAskSubtitle");
      }
      
      public function get askButtonText() : String
      {
         return ZGameUtils.ZlocT("Dialogs","AskFriends");
      }
      
      public function get askIconURL() : String
      {
         return this.m_item.getCachedImage("icon").url;
      }
      
      public function get buyTitleText() : String
      {
         return ZGameUtils.ZlocT("Dialogs","ObtainRequirementGameItemBuyTitle",{"gameItem":this.m_item.getSentenceNameLocalizationObject("plural")});
      }
      
      public function get buyDescText() : String
      {
         var _loc1_:String = this.m_amount > 1 ? "plural" : "singular";
         return ZGameUtils.ZlocT("Dialogs","ObtainRequirementGameItemBuySubtitle",{
            "amount":this.m_amount,
            "gameItem":this.m_item.getSentenceNameLocalizationObject(_loc1_)
         });
      }
      
      public function get buyCost() : Number
      {
         return this.m_item.cash * this.m_amount;
      }
      
      public function get buyButtonText() : String
      {
         return ZGameUtils.ZlocT("Dialogs","BuyForAmount",{"amount":this.buyCost});
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

