package core.managers
{
   import Engine.Managers.TransactionManager;
   import com.adobe.serialization.json.JSON;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.PlayerFeedbackManager;
   import displays.screens.FlashFeedScreen;
   import displays.screens.requests.RequestAskPartsDialog;
   import flash.events.EventDispatcher;
   import transactions.TFlashFeedRedeemItem;
   import utils.ZGameUtils;
   import zlabs.debug.Logger;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class FlashFeedManager extends EventDispatcher
   {
      
      private static const FEED_TYPE_A:String = "flash_feedA";
      
      private static const FEED_TYPE_B:String = "flash_feedB";
      
      public static var instance:FlashFeedManager = null;
      
      public static const SHOW_FLASHFEED_DIALOG:String = "showFlashFeedDialog";
      
      public static const ASK_FOR_TOKENS_TIMER_STARTED:String = "ask_for_tokens_timer_started";
      
      public static const ASK_FOR_TOKENS_TIMER_EXPIRED:String = "ask_for_tokens_timer_expired";
      
      public static const VARIANT_FLASH_FEED:int = 1;
      
      public static const VARIANT_FLASH_REQUEST:int = 2;
      
      public static const EXPERIMENT_FLASHFEED_NEW:String = "empire_flashfeeds_master_new";
      
      public static const FLASH_FEED_LEVEL_GATE:int = 10;
      
      public var m_itemCode:String;
      
      public var m_userRewardSlab:int;
      
      public var m_rewardItemGrid:Object;
      
      public var m_expireDate:Date;
      
      public function FlashFeedManager()
      {
         super();
      }
      
      public static function getInstance() : FlashFeedManager
      {
         if(instance == null)
         {
            instance = new FlashFeedManager();
         }
         return instance;
      }
      
      public static function exists() : Boolean
      {
         if(instance == null)
         {
            return false;
         }
         return true;
      }
      
      public function init(param1:String, param2:String, param3:String) : void
      {
         var itemCode:String = param1;
         var rewardItemGrid:String = param2;
         var expireTimeStr:String = param3;
         this.m_itemCode = itemCode;
         try
         {
            this.m_rewardItemGrid = com.adobe.serialization.json.JSON.decode(rewardItemGrid);
         }
         catch(e:Error)
         {
            Logger.error("FlashFeedManager","init","m_rewardItemGrid is not a valid JSON object.");
            m_rewardItemGrid = null;
         }
         this.m_expireDate = new Date(expireTimeStr);
         addEventListener(FlashFeedManager.SHOW_FLASHFEED_DIALOG,this.showDialog,false,0,true);
      }
      
      public function showDialog(param1:WorldEvent) : void
      {
         var _loc4_:Object = null;
         var _loc5_:int = 0;
         var _loc2_:int = ZGlobal.player.level;
         var _loc3_:int = 0;
         if(this.m_rewardItemGrid != null)
         {
            this.m_userRewardSlab = 0;
            for each(_loc4_ in this.m_rewardItemGrid)
            {
               if(_loc2_ >= _loc4_.start && _loc2_ <= _loc4_.end)
               {
                  this.m_userRewardSlab = _loc3_;
                  break;
               }
               _loc3_++;
            }
            _loc5_ = int(ZGlobal.player.inventory[this.m_itemCode]);
            PopupManager.instance.push(new FlashFeedScreen(_loc5_,this.m_rewardItemGrid[this.m_userRewardSlab].rewards,this.m_expireDate));
         }
      }
      
      public function getItemCode() : String
      {
         return this.m_itemCode;
      }
      
      public function didRedeemItem(param1:String, param2:int) : void
      {
         if(ZGlobal.player.inventory[this.m_itemCode] >= param2)
         {
            ZGlobal.player.removeInventoryItem(this.m_itemCode,param2);
            ZGlobal.player.addToInventory(param1,1);
            TransactionManager.addTransaction(new TFlashFeedRedeemItem(param1),true);
         }
         else
         {
            Logger.debug(this,"didRedeemItem","User doesn\'t have sufficient tokens to redeem item. (We should not be reaching here)");
         }
      }
      
      public function didRedeemItemCallBack(param1:Object, param2:String) : void
      {
         Logger.debug(this,"redeemItemCallBack","redeemed item " + param2);
      }
      
      public function postFlashFeedToWall() : void
      {
         ViralsManager.instance.sendFeed(this.getFlashFeedName(),{},null);
      }
      
      public function sendFlashRequest() : void
      {
         var _loc1_:RequestAskPartsDialog = new RequestAskPartsDialog(this.getItemName(this.m_itemCode),"");
         PopupManager.instance.push(_loc1_,0,false);
      }
      
      public function postToWallResetTime() : Number
      {
         var _loc1_:Number = ViralsManager.instance.getViralResetTime(this.getFlashFeedName());
         return _loc1_ - GlobalEngine.serverTime / 1000;
      }
      
      public function rewardAddedToInventory(param1:String) : void
      {
         var _loc2_:UnitItem = ZGlobal.gameSettings.getItemByCode(param1,UnitItem) as UnitItem;
         var _loc3_:String = _loc2_.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
         PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Main","FeedbackGiftReceived",{"item":_loc3_}));
      }
      
      public function showTokensExpiredMessage() : void
      {
      }
      
      private function getFlashFeedName() : String
      {
         if(this.m_itemCode == "FF03")
         {
            return FEED_TYPE_A;
         }
         if(this.m_itemCode == "FF04")
         {
            return FEED_TYPE_B;
         }
         return FEED_TYPE_A;
      }
      
      private function getItemName(param1:String) : String
      {
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByCode(param1,GameItem) as GameItem;
         return _loc2_.name;
      }
   }
}

