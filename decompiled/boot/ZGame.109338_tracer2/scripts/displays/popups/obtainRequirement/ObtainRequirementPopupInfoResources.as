package displays.popups.obtainRequirement
{
   import ZLocalization.LocalizationObjectToken;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.viralsManager.ViralsManager;
   import utils.ZGameUtils;
   
   public class ObtainRequirementPopupInfoResources implements IObtainRequirementPopupInfo
   {
      
      protected var m_resource:String;
      
      protected var m_item:GameItem = null;
      
      protected var m_token:LocalizationObjectToken;
      
      protected var m_amount:int = 0;
      
      public function ObtainRequirementPopupInfoResources(param1:Array, param2:Boolean = false)
      {
         super();
         this.m_resource = param1 ? this.calculateBestResource(param1) : "";
         this.m_item = this.determineResourceItem(param2);
         this.m_amount = this.m_item.resourceYield;
         this.m_token = ZGameUtils.ZlocTk("Items",this.m_resource + "_sentenceName","plural");
      }
      
      public function onAskButton() : void
      {
         var _loc1_:String = "out_of_" + this.m_resource;
         ViralsManager.instance.sendFeed(_loc1_,{"resource":ZGameUtils.ZlocTokenGetString(ZGameUtils.ZlocTk("Items",this.m_resource + "_sentenceName","plural"))});
      }
      
      public function onPurchase() : void
      {
         ZGlobal.player.buyGameItem(this.m_item,false);
         ZGlobal.player.resources.updateResourceAmount(this.m_item.resourceType,this.m_item.resourceYield);
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
         return ZGameUtils.ZlocT("Dialogs","ObtainRequirementResourceTitle",{"resource":this.m_token});
      }
      
      public function get dialogSubtitleText() : String
      {
         return ZGameUtils.ZlocT("Dialogs","ObtainRequirementResourceSubtitle",{"resource":this.m_token});
      }
      
      public function get askTitleText() : String
      {
         return ZGameUtils.ZlocT("Dialogs","ObtainRequirementResourceAskTitle",{"resource":this.m_token});
      }
      
      public function get askDescText() : String
      {
         return ZGameUtils.ZlocT("Dialogs","ObtainRequirementResourceAskSubtitle");
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
         return ZGameUtils.ZlocT("Dialogs","ObtainRequirementResourceBuyTitle",{"resource":this.m_token});
      }
      
      public function get buyDescText() : String
      {
         return ZGameUtils.ZlocT("Dialogs","ObtainRequirementResourceBuySubtitle",{
            "amount":this.m_item.resourceYield,
            "resource":this.m_token
         });
      }
      
      public function get buyCost() : Number
      {
         return this.m_item.cash;
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
         return ZGameUtils.ZlocT("Dialogs","SuperOreNeedMoreResources_SlotTitle",{"type":this.m_token});
      }
      
      public function get goNowDescText() : String
      {
         return ZGameUtils.ZlocT("Dialogs","SuperOreNeedMoreResources_SlotDesc");
      }
      
      public function get goNowButtonText() : String
      {
         return ZGameUtils.ZlocT("Dialogs","GoNow");
      }
      
      public function get goNowIconURL() : String
      {
         return this.m_item.getCachedImage("icon").url;
      }
      
      private function calculateBestResource(param1:Array) : String
      {
         var _loc3_:String = null;
         var _loc2_:Array = ["coins","wood","oil","aluminum","copper","gold","iron","uranium"];
         if(param1.length > 1)
         {
            for each(_loc3_ in _loc2_)
            {
               if(param1.indexOf(_loc3_) >= 0)
               {
                  return _loc3_;
               }
            }
         }
         return param1[0];
      }
      
      protected function determineResourceItem(param1:Boolean = false) : GameItem
      {
         var _loc6_:XML = null;
         var _loc7_:GameItem = null;
         var _loc2_:int = ZGlobal.gameSettings.getInt("minimumCashForConfirmation",20);
         var _loc3_:GameItem = null;
         var _loc4_:int = 0;
         var _loc5_:Array = this.m_resource == "energy" ? ZGlobal.gameSettings.getArrayOfItemXMLByType("consumable","energy") : ZGlobal.gameSettings.getArrayOfItemXMLByType("resource","resource");
         for each(_loc6_ in _loc5_)
         {
            if(_loc6_.@resourceType == this.m_resource && _loc6_.@buyable == "true")
            {
               _loc7_ = ZGlobal.gameSettings.getItemByName(_loc6_.@name,GameItem) as GameItem;
               if(_loc3_ == null)
               {
                  _loc3_ = _loc7_;
               }
               if(param1 && _loc7_.cash < _loc2_ && _loc7_.cash > _loc4_)
               {
                  _loc3_ = _loc7_;
                  _loc4_ = _loc7_.cash;
               }
            }
         }
         return _loc3_;
      }
   }
}

