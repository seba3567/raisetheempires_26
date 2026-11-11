package core.managers
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.ui.PlayerFeedbackManager;
   import displays.popups.GenericPopup;
   import flash.utils.Dictionary;
   import utils.ZGameUtils;
   import zlabs.managers.PopupManager;
   
   public class UnitContractUnlockManager
   {
      
      public static var instance:UnitContractUnlockManager = new UnitContractUnlockManager();
      
      private var m_dataCache:Dictionary = null;
      
      private const MAX_NEEDED_ITEMS_FOR_BONUS:int = 2;
      
      private const MIN_NEEDED_ITEMS_FOR_BONUS:int = 1;
      
      private const EXPERIMENT_FLEET_WEEK_SET_BONUS_ON:int = 3;
      
      public function UnitContractUnlockManager()
      {
         super();
      }
      
      public function unlockContractCost(param1:GameItem) : int
      {
         var _loc2_:int = this.getMechLeUnlockPrice(param1);
         var _loc3_:int = ExperimentsManager.instance.getExperimentVariant("empires_specops_parts");
         if(param1.xml.contractMultiple != undefined)
         {
            switch(_loc3_)
            {
               case 3:
                  _loc2_ = int(param1.xml.contractMultiple[0].@v3);
                  break;
               case 4:
                  _loc2_ = int(param1.xml.contractMultiple[0].@v4);
                  break;
               case 5:
                  _loc2_ = int(param1.xml.contractMultiple[0].@v5);
            }
         }
         var _loc4_:int = param1.cash;
         return _loc4_ * _loc2_;
      }
      
      public function checkAndAwardSetBonuses(param1:String) : void
      {
         var _loc3_:XML = null;
         var _loc4_:int = 0;
         var _loc5_:Array = null;
         var _loc6_:Boolean = false;
         var _loc7_:Array = null;
         var _loc8_:String = null;
         var _loc9_:GameItem = null;
         var _loc10_:int = 0;
         var _loc11_:GameItem = null;
         var _loc12_:GameItem = null;
         var _loc13_:GameItem = null;
         var _loc2_:XMLList = ZGlobal.gameSettings.getXML().unitBuyContractSetBonuses.unitBuyContractSetBonus;
         for each(_loc3_ in _loc2_)
         {
            _loc4_ = ExperimentsManager.instance.getExperimentVariant(_loc3_.@experiment.toString());
            if(_loc4_ == this.EXPERIMENT_FLEET_WEEK_SET_BONUS_ON)
            {
               _loc5_ = new Array();
               _loc6_ = true;
               _loc7_ = _loc3_.@unlocks.toString().split(",");
               for each(_loc8_ in _loc7_)
               {
                  if(!ZGlobal.player.hasPurchasedContract(_loc8_))
                  {
                     _loc5_.push(_loc8_);
                     _loc6_ = false;
                  }
               }
               if(_loc6_)
               {
                  if(!ZGlobal.player.hasPurchasedContract(_loc3_.@reward.toString()))
                  {
                     _loc9_ = GameItem(ZGlobal.gameSettings.getItemByCode(_loc3_.@reward.toString(),GameItem));
                     if(_loc9_)
                     {
                        ZGlobal.player.unlockContract(_loc9_,true);
                        PopupManager.instance.push(new GenericPopup(ZGameUtils.ZlocT("Dialogs","LESetBonusAwardConfirmation",{"item":_loc9_.getFriendlyName(GameItem.MENU_FRIENDLYNAME)}),GenericPopup.TYPE_OK));
                     }
                  }
               }
               else if(_loc7_.indexOf(param1) >= 0)
               {
                  _loc10_ = int(_loc5_.length);
                  if(_loc10_)
                  {
                     if(_loc10_ == this.MAX_NEEDED_ITEMS_FOR_BONUS)
                     {
                        _loc11_ = GameItem(ZGlobal.gameSettings.getItemByCode(_loc5_[0],GameItem));
                        _loc12_ = GameItem(ZGlobal.gameSettings.getItemByCode(_loc5_[1],GameItem));
                        if(Boolean(_loc11_) && Boolean(_loc12_))
                        {
                           PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Main","FeedbackLEContractUnlockBonusTwoLeft",{
                              "item":_loc11_.getFriendlyName(GameItem.MENU_FRIENDLYNAME),
                              "item2":_loc12_.getFriendlyName(GameItem.MENU_FRIENDLYNAME)
                           }));
                        }
                     }
                     else if(_loc10_ == this.MIN_NEEDED_ITEMS_FOR_BONUS)
                     {
                        _loc13_ = GameItem(ZGlobal.gameSettings.getItemByCode(_loc5_[0],GameItem));
                        if(_loc13_)
                        {
                           PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Main","FeedbackNeeLECOntractUnlockBonusOneLeft",{"item":_loc13_.getFriendlyName(GameItem.MENU_FRIENDLYNAME)}));
                        }
                     }
                  }
               }
            }
         }
      }
      
      private function getMechLeUnlockPrice(param1:GameItem) : Number
      {
         var _loc3_:XMLList = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:XML = null;
         var _loc2_:UnitItem = ZGlobal.gameSettings.getItemByCode(param1.code,UnitItem) as UnitItem;
         if(_loc2_.hasType(UnitItem.MEGA_UNIT))
         {
            _loc3_ = ZGlobal.gameSettings.getXML().mechLeUnlockPriceTest.value;
            _loc4_ = _loc3_.length();
            _loc5_ = ExperimentsManager.instance.getExperimentVariant("empire_mech_le_unlock_pricetest");
            while(_loc6_ < _loc4_)
            {
               _loc7_ = _loc3_[_loc6_];
               if(parseInt(_loc7_.@variant) == _loc5_)
               {
                  return parseFloat(_loc7_.@modifier);
               }
               _loc6_++;
            }
         }
         return ZGlobal.gameSettings.getInt("contractUnlockMultiple",4);
      }
   }
}

