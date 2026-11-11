package displays.popups.buyAmmo
{
   import core.managers.viralsManager.ViralsManager;
   import displays.popups.buyEnergy.BuyEnergyCard;
   import displays.popups.buyEnergy.BuyEnergyPopup;
   import flash.display.MovieClip;
   import utils.ZGameUtils;
   
   public class BuyAmmoPopup extends BuyEnergyPopup
   {
      
      public function BuyAmmoPopup(param1:Function = null, param2:Boolean = false, param3:Array = null, param4:String = null)
      {
         super(param1,param2,param3,param4);
      }
      
      override protected function get title() : String
      {
         return "BuyAmmoTitle";
      }
      
      override protected function get message() : String
      {
         return "BuyAmmoMessage";
      }
      
      override protected function createInventoryCard(param1:MovieClip, param2:String) : BuyEnergyCard
      {
         return new BuyAmmoCard(this,param1,BuyEnergyCard.ENERGY_CARD_INVENTORY,param2);
      }
      
      override protected function createAskCard(param1:MovieClip) : BuyEnergyCard
      {
         return new BuyAmmoCard(this,param1,BuyEnergyCard.ENERGY_CARD_ASK);
      }
      
      override protected function createPurchaseCard(param1:MovieClip) : BuyEnergyCard
      {
         return new BuyAmmoCard(this,param1,BuyEnergyCard.ENERGY_CARD_PURCHASE,"AM5",toasterClicked);
      }
      
      override protected function createRefillCard(param1:MovieClip) : BuyEnergyCard
      {
         return new BuyAmmoCard(this,param1,BuyEnergyCard.ENERGY_CARD_REFILL);
      }
      
      override protected function getInventoryItems() : Array
      {
         return ["AM5","AM4","AM3","AM2","AM1"];
      }
      
      override public function askFriends() : void
      {
         onAccept(null);
         var _loc1_:String = ZGameUtils.ZlocTokenGetString(ZGameUtils.ZlocTk("Items","ammo_sentenceName","singular"));
         ViralsManager.instance.sendFeed("out_of_ammo",{"resource":_loc1_});
      }
   }
}

