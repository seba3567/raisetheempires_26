package displays.popups.buyAmmo
{
   import core.ZGlobal;
   import core.gameobjects.AmmoRefillItem;
   import core.gameobjects.EnergyRefillItem;
   import core.gameobjects.GameItem;
   import displays.popups.buyEnergy.BuyEnergyCard;
   import displays.popups.buyEnergy.BuyEnergyPopup;
   import flash.display.MovieClip;
   
   public class BuyAmmoCard extends BuyEnergyCard
   {
      
      public function BuyAmmoCard(param1:BuyEnergyPopup, param2:MovieClip, param3:int, param4:String = null, param5:Boolean = false)
      {
         super(param1,param2,param3,param4,param5);
      }
      
      override protected function get yield() : int
      {
         return item.ammoYield;
      }
      
      override protected function get refillUrl() : String
      {
         return "assets/game/contracts/Contracts_Icons_0.swf/Ammo05_96.png";
      }
      
      override protected function get buyAmountText() : String
      {
         return "BuyAmmoAmount";
      }
      
      override protected function get buyRefillText() : String
      {
         return "BuyAmmoFullRefill";
      }
      
      override protected function get buyQuantityText() : String
      {
         return "BuyAmmoQuantity";
      }
      
      override protected function get askTitle() : String
      {
         return "BuyAmmoAskFriendsCardTitle";
      }
      
      override protected function get askUrl() : String
      {
         return "assets/game/contracts/Contracts_Icons_0.swf/Ammo05_96.png";
      }
      
      override protected function get kingdom() : String
      {
         return "BuyAmmoPopup";
      }
      
      override protected function get refillamount() : int
      {
         return ZGlobal.player.m_ammo.ammoMax - ZGlobal.player.m_ammo.ammo;
      }
      
      override protected function get refillItem() : EnergyRefillItem
      {
         return ZGlobal.gameSettings.getItemByCode(AmmoRefillItem.ITEM_CODE,AmmoRefillItem) as AmmoRefillItem;
      }
      
      override protected function alreadyAtMaxMessage(param1:GameItem) : String
      {
         var _loc2_:int = 0;
         if(Boolean(param1) && Boolean(param1.ammoYield))
         {
            _loc2_ = param1.ammoYield + ZGlobal.player.m_ammo.ammo;
            if(_loc2_ > ZGlobal.player.m_ammo.ammoMax)
            {
               return "BuyAmmoPurchaseExceedsMax";
            }
         }
         return null;
      }
   }
}

