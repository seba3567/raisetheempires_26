package core.ui.menuitem
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import ZLocalization.LocalizationName;
   import core.ZGlobal;
   import core.ui.Tooltip;
   import dispatchers.NeighborsDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.screens.requests.RequestDialog;
   import displays.screens.requests.RequestGiftDialog;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import transactions.TRecentPlayers;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class RecentPlayersUIItem extends PromoMenuItem
   {
      
      public static const ITEM_ID:String = "recentPlayers";
      
      public static const RECENT_PLAYERS_RECEIVED:String = "recentPlayersReceived";
      
      private static const ZRT_GIFT:String = "mysterygift";
      
      private static const FETCH_DELAY:int = 5000;
      
      private var m_clip:MovieClip;
      
      private var m_imageLoader:ImageLoader;
      
      private var m_friends:Array;
      
      private var m_showTime:uint;
      
      private var m_timerDelay:int;
      
      public function RecentPlayersUIItem()
      {
         swfPath = "assets/ui/RecentlyPlayed.swf";
         toolTipFileName = "Main";
         toolTipText = "RecentlyPlayedHUDTooltip";
         visible = false;
         tweenTimeSeconds = 2;
         super(ITEM_ID);
         if(Config.DEBUG_MODE)
         {
            m_removeOnClick = false;
         }
         priority = 5;
         this.m_timerDelay = ZGlobal.gameSettings.getInt("viralNoActivityDelay",90000);
         Zlab.processManager.schedule(FETCH_DELAY,this,this.fetchDelayDone);
      }
      
      override protected function setUp() : void
      {
      }
      
      private function fetchDelayDone() : void
      {
         TransactionManager.addTransaction(new TRecentPlayers(null));
         NeighborsDispatcher.instance.addEventListener(RECENT_PLAYERS_RECEIVED,this.onPlayersReceived,false,0,true);
      }
      
      public function onPlayersReceived(param1:WorldEvent) : void
      {
         var _loc3_:String = null;
         var _loc2_:Array = param1.eventData as Array;
         if(Boolean(_loc2_) && Boolean(_loc2_.length))
         {
            _loc3_ = ZGlobal.getAssetURL(swfPath);
            if(Zlab.resourceManager.validUrl(_loc3_))
            {
               this.m_friends = _loc2_;
               Zlab.resourceManager.load(_loc3_,SWFResource,this.onSwfLoadComplete);
            }
         }
      }
      
      private function onSwfLoadComplete(param1:SWFResource) : void
      {
         var _loc2_:Class = param1.getAssetClass("recentlyPlayed_mc");
         this.m_clip = new _loc2_();
         this.m_clip.addEventListener(MouseEvent.CLICK,this.onClicked,false,0,true);
         addChild(this.m_clip);
         this.shuffle();
         show(false);
      }
      
      override protected function cleanup() : void
      {
         super.cleanup();
         NeighborsDispatcher.instance.removeEventListener(RECENT_PLAYERS_RECEIVED,this.onPlayersReceived);
         Zlab.processManager.removeScheduledObject(this);
         if(this.m_clip)
         {
            if(this.m_clip.parent)
            {
               this.m_clip.parent.removeChild(this.m_clip);
            }
            this.m_clip.removeEventListener(MouseEvent.CLICK,this.onClicked);
            Tooltip.unsubscribe(this.m_clip);
            this.m_clip = null;
         }
         this.disposeImageLoader();
      }
      
      private function shuffle() : void
      {
         Tooltip.unsubscribe(this.m_clip);
         var _loc1_:Array = this.m_friends.splice(0,1);
         var _loc2_:Object = _loc1_[0];
         this.m_friends.push(_loc2_);
         var _loc3_:String = _loc2_.sex == "F" ? ZGlobal.localizer.FEM : ZGlobal.localizer.MASC;
         var _loc4_:LocalizationName = ZGameUtils.ZlocTn(_loc2_.first_name,_loc3_);
         var _loc5_:String = ZGameUtils.ZlocT(toolTipFileName,toolTipText,{
            "user":_loc4_,
            "number":this.m_friends.length - 1
         });
         Tooltip.subscribe(this.m_clip,_loc5_);
         this.disposeImageLoader();
         this.m_imageLoader = ImageLoaderFactory.CreateImageLoader(_loc2_.pic_square,this.m_clip.player_mc);
         TextFieldUtil.processTextField(this.m_clip.counter_tf,String(this.m_friends.length));
         var _loc6_:Number = ZGlobal.gameSettings.getSeconds("RecentlyPlayedHUDRotationPeriod",60 * 2);
         Zlab.processManager.schedule(_loc6_ * 1000,this,this.shuffle);
      }
      
      private function disposeImageLoader() : void
      {
         if(this.m_imageLoader)
         {
            this.m_imageLoader.destroy();
            this.m_imageLoader = null;
         }
      }
      
      override protected function onClicked(param1:MouseEvent) : void
      {
         super.onClicked(param1);
         var _loc2_:String = this.getGiftName();
         this.displayRequestDialog();
         StatsManager.countSample(100,"HUD_icon","recently_played","delay","","","",elapsedSinceShow);
      }
      
      private function displayRequestDialog() : void
      {
         var _loc2_:String = null;
         var _loc1_:String = this.getGiftName();
         if(_loc1_)
         {
            _loc2_ = ZGlobal.getAssetURL("assets/game/contracts/Contracts_Icons_0.swf/MysteryGift_96.png");
            PopupManager.instance.push(new RequestGiftDialog(_loc1_,RequestGiftDialog.DEFAULT_GIFTTYPE,RequestDialog.TYPE_RECENTLY_PLAYED));
         }
      }
      
      private function getGiftName() : String
      {
         return ZRT_GIFT;
      }
   }
}

