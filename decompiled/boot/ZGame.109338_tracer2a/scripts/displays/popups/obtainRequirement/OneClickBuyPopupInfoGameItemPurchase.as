package displays.popups.obtainRequirement
{
   import core.gameobjects.GameItem;
   
   public class OneClickBuyPopupInfoGameItemPurchase extends ObtainRequirementPopupInfoGameItemPurchase
   {
      
      public function OneClickBuyPopupInfoGameItemPurchase(param1:GameItem, param2:int)
      {
         super(param1,param2);
      }
      
      override public function get buyCost() : Number
      {
         return m_item.getModifiedCash(1,1,"oneClickBuy") * m_amount;
      }
   }
}

