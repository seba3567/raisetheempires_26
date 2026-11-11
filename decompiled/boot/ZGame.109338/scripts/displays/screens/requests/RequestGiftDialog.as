package displays.screens.requests
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.ExperimentsManager;
   import flash.events.MouseEvent;
   import transactions.TRequestSendGift;
   import utils.ZGameUtils;
   
   public class RequestGiftDialog extends RequestDialog
   {
      
      public static const DEFAULT_GIFTTYPE:String = "gift";
      
      public static const VICTORY_GIFTTYPE:String = "giftVictory";
      
      public static const RECENT_PLAYER_GIFTTYPE:String = "giftRecentPlayers";
      
      public static const RARE_GIFTTYPE:String = "giftRare";
      
      public static const ZRT_GIFT:String = "zrt";
      
      public static const VIRAL_SURFACING:String = "giftViralSurfacing";
      
      public static const FIRST_ARMY_GIFTTYPE:String = "giftFirstArmy";
      
      public static const FIRST_NAVY_GIFTTYPE:String = "giftFirstNavy";
      
      public static const FIRST_AIR_GIFTTYPE:String = "giftFirstAir";
      
      public static const VILLAIN_DEFEAT_GIFTTYPE:String = "giftVillainDefeat";
      
      public static const MYSTERY_GIFT:String = "mysterygift";
      
      public static const RAFFLE_GIFT:String = "giftRaffleReward";
      
      public static const DIALOG_TITLE:String = "GiftRequestTitle";
      
      public static const DIALOG_BODY:String = "GiftRequestBody";
      
      public static const DIALOG_BODY_INTERSTITIAL:String = "GiftRequestBodyInterstitial";
      
      public static const DIALOG_TOASTER:String = "GiftRequestToaster";
      
      private static var m_instanceExists:Boolean = false;
      
      private var m_gift:String;
      
      private var m_giftType:String;
      
      private var m_friends:Array;
      
      private var m_giftItem:GameItem;
      
      private var m_giftFriendlyName:String;
      
      private var m_onCloseCallback:Function;
      
      private var m_locTitle:String;
      
      private var m_locBody:String;
      
      public function RequestGiftDialog(param1:String, param2:String = "gift", param3:String = "gift", param4:String = "empire_request2_mfs_gift", param5:String = "", param6:Function = null)
      {
         this.m_gift = param1;
         this.m_giftType = param2;
         this.m_friends = getAllFriends(param4);
         this.m_giftItem = ZGlobal.gameSettings.getItemByName(param1,GameItem) as GameItem;
         this.m_giftFriendlyName = this.m_giftItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
         this.m_onCloseCallback = param6;
         this.m_locTitle = ZGameUtils.ZlocT("Dialogs",DIALOG_TITLE,{"item":this.m_giftFriendlyName});
         if(param4 == ExperimentsManager.EXPERIMENT_REQUEST2_MFS_GIFT_INTERSTITIAL)
         {
            this.m_locBody = ZGameUtils.ZlocT("Dialogs",DIALOG_BODY_INTERSTITIAL);
         }
         else
         {
            this.m_locBody = ZGameUtils.ZlocT("Dialogs",DIALOG_BODY,{
               "count":this.m_friends.length,
               "item":this.m_giftFriendlyName
            });
         }
         m_instanceExists = true;
         super(this.m_friends,this.m_locTitle,this.m_locBody,DIALOG_TOASTER,this.m_giftItem.getImageObject().url,param3,param5);
      }
      
      public static function instanceExists() : Boolean
      {
         return m_instanceExists;
      }
      
      public function forceRequest(param1:Array) : void
      {
         this.sendRequest(param1);
      }
      
      override protected function sendRequest(param1:Array) : void
      {
         TransactionManager.addTransaction(new TRequestSendGift(param1,this.m_gift,this.m_giftType,m_requestType,m_requestSubcategory));
      }
      
      override protected function deinitDialog() : void
      {
         m_instanceExists = false;
         super.deinitDialog();
      }
      
      override protected function exitButtonClicked(param1:MouseEvent) : void
      {
         if(this.m_onCloseCallback != null)
         {
            this.m_onCloseCallback();
         }
         super.exitButtonClicked(param1);
      }
      
      override protected function calculateMaxFriends() : uint
      {
         if(m_requestSubtype == RequestDialog.SUBTYPE_INTERSTITIAL || m_requestSubtype == RequestDialog.SUBTYPE_IDLE)
         {
            return 50;
         }
         return super.calculateMaxFriends();
      }
   }
}

