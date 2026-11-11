package core.ui
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.ExperimentsManager;
   import core.managers.FriendManager;
   import core.managers.PVPManager;
   import core.managers.viralSurfacingManager.ViralSurfacingManager;
   import core.managers.viralsManager.ViralsManager;
   import core.player.Player;
   import core.ui.menuitem.FriendsBarMessageTabUIItem;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.screens.requests.RequestGiftDialog;
   import displays.screens.requests.RequestNeighborDialog;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import transactions.TViralSurfacingSeen;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class ViralSurfacePopup extends MovieClip
   {
      
      public static const FADE:int = 0;
      
      public static const IMMEDIATE:int = 1;
      
      public static const NEIGHBOR:String = "neighbor";
      
      public static const ENERGY:String = "energy";
      
      public static const PARTS:String = "parts";
      
      private static const ASSET_FILE:String = "assets/ui/ViralNotification.swf";
      
      private static const NEIGHBOR_ICON:String = "assets/game/GeneralAssetGroup_UI.swf/Globe_RedDot_48.png";
      
      private static const TWEEN_SECONDS:Number = 0.5;
      
      private static const NUM_PORTRAITS:int = 4;
      
      private var m_xml:XML;
      
      private var m_mc:MovieClip;
      
      private var m_button:ZGameButton;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = new ButtonMouseEventSoundContainer();
      
      private var m_portraitUIDs:Array;
      
      private var m_seenCount:int;
      
      private var m_loaders:Array = [];
      
      private var m_durationSeconds:int;
      
      private var m_GPVPBackground:Boolean;
      
      private var m_users:Array = [];
      
      private var m_giftGameItem:GameItem;
      
      private var m_forceClose:Boolean;
      
      public function ViralSurfacePopup(param1:XML, param2:int, param3:int, param4:Boolean, param5:Array)
      {
         super();
         this.m_xml = param1;
         this.m_seenCount = param2;
         this.m_durationSeconds = param3;
         this.m_GPVPBackground = param4;
         this.m_users = param5;
         var _loc6_:String = ZGlobal.getAssetURL(ASSET_FILE);
         Zlab.resourceManager.load(_loc6_,SWFResource,this.onLoadComplete);
         var _loc7_:TViralSurfacingSeen = new TViralSurfacingSeen(this.m_xml.@type.toString());
         TransactionManager.addTransaction(_loc7_);
         PVPManager.instance.addEventListener(PVPManager.GLOBALPVP_UI_STATECHANGE,this.onGPVPStateChange,false,0,true);
         UIDispatcher.instance.addEventListener(FriendsBarMessageTabUIItem.NEW_MESSAGE,this.onNewToasterMessage,false,0,true);
      }
      
      public static function create(param1:XML, param2:int, param3:int, param4:Boolean) : ViralSurfacePopup
      {
         var _loc5_:Array = getDisplayedUserInfo(param1.@type.toString());
         if((Boolean(_loc5_)) && Boolean(_loc5_.length))
         {
            return new ViralSurfacePopup(param1,param2,param3,param4,_loc5_);
         }
         return null;
      }
      
      private static function getNonAppFriends(param1:int) : Array
      {
         var _loc4_:Object = null;
         var _loc2_:Array = [];
         var _loc3_:Array = FriendManager.instance.getRandomFriends(param1);
         for each(_loc4_ in _loc3_)
         {
            _loc2_.push({
               "uid":_loc4_.uid,
               "portrait":_loc4_.portraitURL
            });
         }
         return _loc2_;
      }
      
      private static function getDisplayedUserInfo(param1:String) : Array
      {
         var _loc3_:Array = null;
         var _loc4_:String = null;
         var _loc5_:Object = null;
         var _loc6_:Player = null;
         var _loc2_:Array = [];
         if(param1 == NEIGHBOR)
         {
            _loc2_ = getNonAppFriends(NUM_PORTRAITS);
         }
         else
         {
            _loc3_ = [];
            for(_loc4_ in ZGlobal.player.neighbors)
            {
               if(Number(_loc4_) >= 0)
               {
                  if(Math.random() < 0.5)
                  {
                     _loc3_.push(_loc4_);
                  }
                  else
                  {
                     _loc3_.unshift(_loc4_);
                  }
               }
            }
            for each(_loc4_ in _loc3_)
            {
               _loc5_ = ZGlobal.player.neighbors[_loc4_];
               _loc6_ = ZGlobal.player.findFriendById(_loc4_);
               if(_loc6_)
               {
                  _loc2_.push({
                     "uid":_loc4_,
                     "portrait":_loc6_.portraitURL
                  });
                  if(_loc2_.length == NUM_PORTRAITS)
                  {
                     break;
                  }
               }
            }
         }
         return _loc2_;
      }
      
      protected function onLoadComplete(param1:SWFResource) : void
      {
         if(this.m_forceClose)
         {
            this.close(IMMEDIATE);
            return;
         }
         var _loc2_:Class = param1.getAssetClass("viralNotification_mc");
         if(_loc2_)
         {
            this.m_mc = new _loc2_();
            addChild(this.m_mc);
         }
         this.initialize();
         Zlab.processManager.schedule(this.m_durationSeconds * 1000,this,this.onDurationExpired);
      }
      
      private function onDurationExpired() : void
      {
         this.logAction("no");
         this.close(FADE);
      }
      
      private function initialize() : void
      {
         y = this.m_mc.height;
         TweenLite.to(this,TWEEN_SECONDS,{"y":0});
         alpha = 0;
         TweenLite.to(this,TWEEN_SECONDS,{"alpha":1});
         this.initDesc();
         this.initButtons();
         this.initPortraits();
         this.initIcon();
         this.initBackground();
      }
      
      private function initBackground() : void
      {
         if(this.m_GPVPBackground)
         {
            this.m_mc.tab_mc.visible = false;
         }
         else
         {
            this.m_mc.tabgpvp_mc.visible = false;
         }
      }
      
      private function initIcon() : void
      {
         var _loc1_:ImageLoader = null;
         var _loc2_:String = null;
         var _loc3_:String = null;
         this.m_mc.item_icon.visible = false;
         if(this.m_xml.@type == NEIGHBOR)
         {
            this.m_mc.item_icon.visible = true;
            _loc2_ = ZGlobal.getAssetURL(NEIGHBOR_ICON);
            _loc1_ = ImageLoaderFactory.CreateImageLoader(_loc2_,this.m_mc.item_icon);
            if(_loc1_)
            {
               _loc1_.smooth = true;
               this.m_loaders.push(_loc1_);
            }
         }
         else if(this.m_xml.@itemCodes != undefined)
         {
            _loc3_ = this.getRandomItemCode(this.m_xml.@itemCodes.toString());
            this.m_giftGameItem = ZGlobal.gameSettings.getItemByCode(_loc3_,GameItem) as GameItem;
            if(this.m_giftGameItem)
            {
               _loc2_ = this.m_giftGameItem.getCachedImage("icon").url;
               _loc1_ = ImageLoaderFactory.CreateImageLoader(_loc2_,this.m_mc.item_icon);
               if(_loc1_)
               {
                  _loc1_.smooth = true;
                  this.m_loaders.push(_loc1_);
               }
               this.m_mc.item_icon.visible = true;
            }
         }
      }
      
      private function getRandomItemCode(param1:String) : String
      {
         var _loc2_:Array = param1.split(",");
         if(!_loc2_.length)
         {
            return null;
         }
         var _loc3_:int = this.m_seenCount % _loc2_.length;
         return _loc2_[_loc3_];
      }
      
      private function initPortraits() : void
      {
         var _loc2_:Object = null;
         var _loc3_:ImageLoader = null;
         var _loc1_:Array = [this.m_mc.profileIcon1_mc,this.m_mc.profileIcon2_mc,this.m_mc.profileIcon3_mc,this.m_mc.profileIcon4_mc];
         for each(_loc2_ in this.m_users)
         {
            if(_loc1_.length)
            {
               _loc3_ = ImageLoaderFactory.CreateImageLoader(_loc2_.portrait,_loc1_[0]);
               _loc1_.shift();
               if(_loc3_)
               {
                  _loc3_.smooth = true;
                  this.m_loaders.push(_loc3_);
               }
            }
         }
      }
      
      private function initButtons() : void
      {
         this.m_button = new ZGameButton(this.m_mc.action_mc,this.onClicked);
         this.m_button.text = ZGameUtils.ZlocT("Dialogs","SendNow");
         this.m_buttonSounds.addButton(this.m_button.m_overlay,ButtonSound.DEFAULT);
         this.m_mc.exit_bt.addEventListener(MouseEvent.CLICK,this.onExitClicked,false,0,true);
         this.m_buttonSounds.addButton(this.m_mc.exit_bt,ButtonSound.DEFAULT);
      }
      
      private function onClicked(param1:MouseEvent) : void
      {
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_REQUEST2_MASTER) == ExperimentsManager.VARIANT_VALUE_REQUEST2_MASTER_ON)
         {
            if(this.m_xml.@type.toString() == NEIGHBOR)
            {
               PopupManager.instance.push(new RequestNeighborDialog(ViralsManager.INVITE_REQUEST_SOURCE_IDLE));
            }
            else
            {
               PopupManager.instance.push(new RequestGiftDialog(this.m_giftGameItem.name,RequestGiftDialog.VIRAL_SURFACING));
            }
         }
         else
         {
            ZGlobal.navigateImmediatelyTo(this.targetString);
         }
         this.logAction("yes");
         this.close(FADE);
      }
      
      private function get targetString() : String
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         var _loc1_:Array = [];
         for each(_loc2_ in this.m_users)
         {
            _loc1_.push(_loc2_.uid);
         }
         _loc3_ = _loc1_.join(",");
         if(this.m_xml.@type.toString() == NEIGHBOR)
         {
            return this.m_xml.@url.toString();
         }
         if(this.m_giftGameItem)
         {
            return this.m_xml.@url.toString() + "&targetId=" + _loc1_.join(",") + "&gift=" + this.m_giftGameItem.name;
         }
         return this.m_xml.@url;
      }
      
      private function onExitClicked(param1:MouseEvent) : void
      {
         this.logAction("no");
         this.close(FADE);
      }
      
      private function initDesc() : void
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         if(this.m_xml.@desc == undefined)
         {
            this.m_mc.message_tf.visible = false;
         }
         else
         {
            _loc1_ = this.m_xml.@desc.toString();
            _loc2_ = ZGameUtils.ZlocTP("Dialogs",_loc1_);
            TextFieldUtil.processTextField(this.m_mc.message_tf,_loc2_);
         }
      }
      
      private function logAction(param1:String) : void
      {
         var _loc2_:String = "toast";
         var _loc3_:String = this.m_xml.@type.toString();
         var _loc4_:String = this.m_giftGameItem ? this.m_giftGameItem.name : "basic";
         var _loc5_:String = param1;
         StatsManager.count(_loc2_,_loc3_,_loc4_,_loc5_);
      }
      
      private function onGPVPStateChange(param1:WorldEvent) : void
      {
         if(!PVPManager.instance.isStrangerBarStable)
         {
            this.m_forceClose = true;
            this.logAction("no");
            this.close(IMMEDIATE);
         }
      }
      
      public function dispose() : void
      {
         var _loc1_:ImageLoader = null;
         if(parent)
         {
            parent.removeChild(this);
         }
         for each(_loc1_ in this.m_loaders)
         {
            _loc1_.destroy();
         }
         this.m_loaders = [];
         this.m_buttonSounds.release();
         this.m_portraitUIDs = null;
         this.m_mc = null;
         this.disable();
      }
      
      private function disable() : void
      {
         if(this.m_button)
         {
            this.m_button.dispose();
            this.m_button = null;
         }
         if(this.m_mc)
         {
            this.m_mc.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExitClicked);
         }
         PVPManager.instance.removeEventListener(PVPManager.GLOBALPVP_UI_STATECHANGE,this.onGPVPStateChange);
         UIDispatcher.instance.removeEventListener(FriendsBarMessageTabUIItem.NEW_MESSAGE,this.onNewToasterMessage);
         Zlab.processManager.removeScheduledObject(this);
      }
      
      private function onNewToasterMessage(param1:Event) : void
      {
         this.m_forceClose = true;
         this.logAction("no");
         this.close(IMMEDIATE);
      }
      
      private function close(param1:int) : void
      {
         if(param1 == FADE)
         {
            this.disable();
            TweenLite.to(this,TWEEN_SECONDS,{"y":this.m_mc.height});
            TweenLite.to(this,TWEEN_SECONDS,{
               "alpha":0,
               "onComplete":this.onTweenOutComplete
            });
         }
         else
         {
            ViralSurfacingManager.instance.dispatchEvent(new Event(ViralSurfacingManager.POPUP_CLOSED));
            this.dispose();
         }
      }
      
      private function onTweenOutComplete() : void
      {
         this.close(IMMEDIATE);
      }
   }
}

