package displays.popups.buyMana
{
   import core.ZGlobal;
   import core.gameobjects.EnergyRefillItem;
   import core.gameobjects.GameItem;
   import core.gameobjects.ManaItem;
   import core.gameobjects.ManaRefillItem;
   import displays.popups.buyEnergy.BuyEnergyCard;
   import displays.popups.buyEnergy.BuyEnergyPopup;
   import flash.display.MovieClip;
   
   public class BuyManaCard extends BuyEnergyCard
   {
      
      public function BuyManaCard(param1:BuyEnergyPopup, param2:MovieClip, param3:int, param4:String = null, param5:Boolean = false)
      {
         super(param1,param2,param3,param4,param5);
      }
      
      override protected function get yield() : int
      {
         return item.manaYield;
      }
      
      override protected function get refillUrl() : String
      {
         return "assets/game/contracts/Contracts_Icons_0.swf/ElementZ06_96.png";
      }
      
      override protected function get buyAmountText() : String
      {
         return "BuyManaAmount";
      }
      
      override protected function get buyRefillText() : String
      {
         return "BuyManaFullRefill";
      }
      
      override protected function get buyQuantityText() : String
      {
         return "BuyManaQuantity";
      }
      
      override protected function get askTitle() : String
      {
         return "BuyManaAskFriendsCardTitle";
      }
      
      override protected function get askUrl() : String
      {
         return "assets/game/contracts/Contracts_Icons_0.swf/ElementZ06_96.png";
      }
      
      override protected function get kingdom() : String
      {
         return "BuyManaPopup";
      }
      
      override protected function get refillamount() : int
      {
         return ZGlobal.player.mana.cap - ZGlobal.player.mana.value;
      }
      
      override protected function get refillItem() : EnergyRefillItem
      {
         return ZGlobal.gameSettings.getItemByCode(ManaRefillItem.ITEM_CODE,ManaRefillItem) as ManaRefillItem;
      }
      
      override protected function get itemClass() : Class
      {
         return ManaItem;
      }
      
      override protected function alreadyAtMaxMessage(param1:GameItem) : String
      {
         if(Boolean(param1) && Boolean(param1.manaYield))
         {
            if(!ZGlobal.player.mana.allowGive(param1.energyYield))
            {
               return "BuyManaPurchaseExceedsMax";
            }
         }
         return null;
      }
   }
}

