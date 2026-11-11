package displays.popups.obtainRequirement
{
   import core.gameobjects.GameItem;
   import utils.ZGameUtils;
   
   public class ObtainRequirementPopupInfoGameItemPurchase implements IObtainRequirementPopupInfo
   {
      
      protected var m_item:GameItem = null;
      
      protected var m_amount:int = 0;
      
      public function ObtainRequirementPopupInfoGameItemPurchase(param1:GameItem, param2:int)
      {
         super();
         this.m_item = param1;
         this.m_amount = param2;
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
         return this.m_amount;
      }
      
      public function get resourceAmount() : Number
      {
         return this.m_amount;
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
         return null;
      }
      
      public function get askDescText() : String
      {
         return null;
      }
      
      public function get askButtonText() : String
      {
         return null;
      }
      
      public function get askIconURL() : String
      {
         return null;
      }
      
      public function get buyTitleText() : String
      {
         var _loc1_:String = this.m_amount > 1 ? "plural" : "singular";
         return ZGameUtils.ZlocT("Dialogs","ObtainRequirementGameItemBuyTitle",{"gameItem":this.m_item.getSentenceNameLocalizationObject(_loc1_)});
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

