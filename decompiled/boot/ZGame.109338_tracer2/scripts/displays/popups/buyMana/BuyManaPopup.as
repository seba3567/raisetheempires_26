package displays.popups.buyMana
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.viralsManager.ViralsManager;
   import displays.popups.buyEnergy.BuyEnergyCard;
   import displays.popups.buyEnergy.BuyEnergyPopup;
   import flash.display.MovieClip;
   import utils.ZGameUtils;
   
   public class BuyManaPopup extends BuyEnergyPopup
   {
      
      public function BuyManaPopup(param1:Function = null, param2:Boolean = false, param3:Array = null, param4:String = null)
      {
         super(param1,param2,param3,param4);
      }
      
      override protected function get title() : String
      {
         return "BuyManaTitle";
      }
      
      override protected function get message() : String
      {
         return "BuyManaMessage";
      }
      
      override protected function createInventoryCard(param1:MovieClip, param2:String) : BuyEnergyCard
      {
         return new BuyManaCard(this,param1,BuyEnergyCard.ENERGY_CARD_INVENTORY,param2);
      }
      
      override protected function createAskCard(param1:MovieClip) : BuyEnergyCard
      {
         return new BuyManaCard(this,param1,BuyEnergyCard.ENERGY_CARD_ASK);
      }
      
      override protected function createPurchaseCard(param1:MovieClip) : BuyEnergyCard
      {
         return new BuyManaCard(this,param1,BuyEnergyCard.ENERGY_CARD_PURCHASE,this.getHighestYieldingItem(),toasterClicked);
      }
      
      override protected function createRefillCard(param1:MovieClip) : BuyEnergyCard
      {
         return new BuyManaCard(this,param1,BuyEnergyCard.ENERGY_CARD_REFILL);
      }
      
      override protected function getInventoryItems() : Array
      {
         return ["MA6","MA5","MA4","MA3","MA2","MA1"];
      }
      
      override protected function allowItem(param1:String) : Boolean
      {
         var _loc2_:GameItem = null;
         if(super.allowItem(param1))
         {
            _loc2_ = ZGlobal.gameSettings.getItemByCode(param1,GameItem) as GameItem;
            return ZGlobal.player.mana.allowGive(_loc2_.manaYield);
         }
         return false;
      }
      
      override public function askFriends() : void
      {
         onAccept(null);
         var _loc1_:String = ZGameUtils.ZlocTokenGetString(ZGameUtils.ZlocTk("Items","mana_sentenceName","singular"));
         ViralsManager.instance.sendFeed("out_of_mana",{"resource":_loc1_});
      }
      
      private function getHighestYieldingItem() : String
      {
         var _loc2_:String = null;
         var _loc3_:GameItem = null;
         var _loc1_:Array = this.getInventoryItems();
         for each(_loc2_ in _loc1_)
         {
            _loc3_ = ZGlobal.gameSettings.getItemByCode(_loc2_,GameItem) as GameItem;
            if(_loc3_.buyable && ZGlobal.player.mana.allowGive(_loc3_.manaYield))
            {
               return _loc2_;
            }
         }
         return "MA4";
      }
   }
}

