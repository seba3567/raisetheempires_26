package displays.popups.obtainRequirement
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import utils.ZGameUtils;
   
   public class ObtainRequirementPopupInfoLevelTargetedResources extends ObtainRequirementPopupInfoResources
   {
      
      private var m_packageCostEP:int = 0;
      
      private var m_quantity:int = 0;
      
      public function ObtainRequirementPopupInfoLevelTargetedResources(param1:Array)
      {
         super(param1);
      }
      
      override protected function determineResourceItem(param1:Boolean = false) : GameItem
      {
         var _loc2_:Boolean = true;
         switch(m_resource)
         {
            case "coins":
            case "wood":
            case "oil":
               break;
            default:
               _loc2_ = m_resource == ZGlobal.player.rareResourceName;
         }
         this.m_packageCostEP = ZGlobal.player.getResourcePackageCost(_loc2_);
         var _loc3_:GameItem = ZGlobal.player.resourceItem(m_resource,m_resource == ZGlobal.player.rareResourceName);
         this.m_quantity = ZGlobal.player.getResourcePackageQuantity(_loc3_,this.m_packageCostEP);
         return _loc3_;
      }
      
      override public function get buyQuantity() : Number
      {
         return this.m_quantity;
      }
      
      override public function onPurchase() : void
      {
         ZGlobal.player.buyResourceItem(m_item,this.m_quantity);
         ZGlobal.player.resources.updateResourceAmount(m_item.resourceType,m_item.resourceYield * this.m_quantity);
      }
      
      override public function get buyDescText() : String
      {
         return ZGameUtils.ZlocT("Dialogs","ObtainRequirementResourceBuySubtitle",{
            "amount":this.m_quantity,
            "resource":m_token
         });
      }
      
      override public function get buyCost() : Number
      {
         return this.m_packageCostEP;
      }
   }
}

