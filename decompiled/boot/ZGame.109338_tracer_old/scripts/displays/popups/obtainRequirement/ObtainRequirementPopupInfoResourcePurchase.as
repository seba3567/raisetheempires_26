package displays.popups.obtainRequirement
{
   import core.ZGlobal;
   import core.gameobjects.EnergyRefillItem;
   import core.gameobjects.GameItem;
   import core.managers.WorldResourceManager;
   import core.managers.viralsManager.ViralsManager;
   import utils.ZGameUtils;
   
   public class ObtainRequirementPopupInfoResourcePurchase implements IObtainRequirementPopupInfo
   {
      
      private var m_type:String = null;
      
      private var m_amount:int = 0;
      
      public function ObtainRequirementPopupInfoResourcePurchase(param1:String, param2:int)
      {
         super();
         this.m_type = param1;
         this.m_amount = param2;
      }
      
      public function onAskButton() : void
      {
         var _loc1_:String = "out_of_" + this.m_type;
         ViralsManager.instance.sendFeed(_loc1_,{"resource":ZGameUtils.ZlocTokenGetString(ZGameUtils.ZlocTk("Items",this.m_type + "_sentenceName","plural"))});
      }
      
      public function onPurchase() : void
      {
      }
      
      public function get requirementGameItem() : GameItem
      {
         if(this.m_type == "energy")
         {
            return ZGlobal.player.energyItem(this.m_amount);
         }
         return ZGlobal.player.resourceItem(this.m_type,this.m_type == ZGlobal.player.rareResourceName);
      }
      
      public function get buyQuantity() : Number
      {
         var _loc1_:GameItem = this.requirementGameItem;
         if(_loc1_.type == "consumable")
         {
            return 1;
         }
         return this.m_amount;
      }
      
      public function get resourceAmount() : Number
      {
         var _loc1_:GameItem = this.requirementGameItem;
         if(_loc1_.code == EnergyRefillItem.ITEM_CODE)
         {
            return ZGlobal.player.m_energy.energyMax - ZGlobal.player.m_energy.energy;
         }
         if(_loc1_.type == "consumable")
         {
            return _loc1_.energyYield;
         }
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
         var _loc1_:Object = new Object();
         _loc1_.item = ZGameUtils.ZlocTk("Items",this.m_type + "_sentenceName",this.resourceAmount == 1 ? "singular" : "plural").getString();
         return ZGameUtils.ZlocT("Dialogs","ObtainResourcesBuyTitle",_loc1_);
      }
      
      public function get buyDescText() : String
      {
         var _loc1_:Object = new Object();
         _loc1_.item = ZGameUtils.ZlocTk("Items",this.m_type + "_sentenceName",this.resourceAmount == 1 ? "singular" : "plural").getString();
         _loc1_.amount = this.resourceAmount.toString();
         return ZGameUtils.ZlocT("Dialogs","ObtainResourcesBuyMessage",_loc1_);
      }
      
      public function get buyCost() : Number
      {
         if(this.m_type == "energy")
         {
            if(this.requirementGameItem.code == EnergyRefillItem.ITEM_CODE)
            {
               return ZGlobal.player.m_energy.energyMax - ZGlobal.player.m_energy.energy;
            }
            return this.requirementGameItem.xml.cost.@cash;
         }
         return ZGlobal.player.resourceCashCost(this.m_type,this.m_amount);
      }
      
      public function get buyButtonText() : String
      {
         return ZGameUtils.ZlocT("Dialogs","BuyForAmount",{"amount":this.buyCost});
      }
      
      public function get buyIconURL() : String
      {
         return WorldResourceManager.instance.getResourceImageURLByType(this.m_type,WorldResourceManager.XTRA_LARGE_ICON);
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

