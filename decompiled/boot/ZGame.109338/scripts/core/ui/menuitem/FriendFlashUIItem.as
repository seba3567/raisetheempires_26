package core.ui.menuitem
{
   import core.ZGlobal;
   import core.ui.Tooltip;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.screens.requests.EPGiftSendFriendSelectDialog;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.resource.SWFResource;
   
   public class FriendFlashUIItem extends PromoMenuItem
   {
      
      private static var m_instance:FriendFlashUIItem;
      
      public static const ITEM_ID:String = "friendFlash";
      
      private static const ICON_PATH:String = "assets/game/quests/Quests_Icons_0.swf/Ep_Gift_96.png";
      
      private var m_clip:MovieClip;
      
      private var m_removed:Boolean;
      
      private var m_amount:int;
      
      private var m_imageLoader:ImageLoader;
      
      public function FriendFlashUIItem()
      {
         toolTipFileName = "Main";
         toolTipText = "RecentlyPlayedHUDTooltip";
         visible = false;
         tweenTimeSeconds = 2;
         super(ITEM_ID);
         priority = 1;
         m_instance = this;
         this.loadMC();
      }
      
      public static function get instance() : FriendFlashUIItem
      {
         return m_instance;
      }
      
      private function loadMC() : void
      {
         var _loc1_:String = ZGlobal.getAssetURL("assets/ui/FriendFlashHUDIcon.swf");
         Zlab.resourceManager.load(_loc1_,SWFResource,this.onSwfLoadComplete);
      }
      
      override protected function setUp() : void
      {
      }
      
      public function setAmount(param1:int) : void
      {
         var _loc2_:String = null;
         this.m_amount = param1;
         if(this.m_clip)
         {
            _loc2_ = param1 > 99 ? "99+" : String(param1);
            TextFieldUtil.compactTextField(this.m_clip.counter_tf,_loc2_);
         }
      }
      
      private function loadIcon() : void
      {
         var _loc1_:String = ZGlobal.getAssetURL(ICON_PATH);
         this.m_imageLoader = ImageLoaderFactory.CreateImageLoader(_loc1_,this.m_clip.loader_mc);
      }
      
      private function onSwfLoadComplete(param1:SWFResource) : void
      {
         var _loc2_:Class = null;
         if(!this.m_removed)
         {
            _loc2_ = param1.getAssetClass("recentlyPlayed_mc");
            this.m_clip = new _loc2_();
            this.m_clip.addEventListener(MouseEvent.CLICK,this.onClicked,false,0,true);
            Tooltip.subscribe(this.m_clip,ZGameUtils.ZlocT("Tooltips","FriendFlashUIItemTooltip"));
            this.loadIcon();
            addChild(this.m_clip);
            show(false);
            this.setAmount(this.m_amount);
         }
      }
      
      override protected function cleanup() : void
      {
         m_instance = null;
         this.m_removed = true;
         super.cleanup();
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
         if(this.m_imageLoader)
         {
            this.m_imageLoader.destroy();
         }
      }
      
      override protected function onClicked(param1:MouseEvent) : void
      {
         EPGiftSendFriendSelectDialog.show();
      }
      
      override public function get removeOnClicked() : Boolean
      {
         return false;
      }
   }
}

