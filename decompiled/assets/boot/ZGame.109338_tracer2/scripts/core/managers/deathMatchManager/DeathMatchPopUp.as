package core.managers.deathMatchManager
{
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.PVPManager;
   import core.managers.viralSurfacingManager.ViralSurfacingManager;
   import core.ui.ZGameButton;
   import core.ui.menuitem.FriendsBarMessageTabUIItem;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class DeathMatchPopUp extends MovieClip
   {
      
      private static const MAX_WIDTH:Number = 300;
      
      private static const ASSET_FILE:String = "assets/ui/ViralNotification.swf";
      
      private static const X_OFFSET:int = -20;
      
      public static const FADE:int = 0;
      
      public static const IMMEDIATE:int = 1;
      
      protected var m_mc:MovieClip;
      
      protected var m_item:GameItem = null;
      
      protected var m_button:ZGameButton = null;
      
      protected var m_unlockBt:ZGameButton = null;
      
      protected var m_obj:Object;
      
      protected var m_buttonSounds:ButtonMouseEventSoundContainer = new ButtonMouseEventSoundContainer();
      
      protected var m_durationSeconds:int = 10;
      
      protected var m_forceClose:Boolean;
      
      protected var m_loaders:Array = [];
      
      protected var m_discountCost:int = 0;
      
      private var m_acceptButton:ZGameButton;
      
      protected var m_placeholder:String;
      
      protected var m_date:Date;
      
      public function DeathMatchPopUp(param1:int)
      {
         super();
         this.m_durationSeconds = param1;
         var _loc2_:String = ZGlobal.getAssetURL(ASSET_FILE);
         Zlab.resourceManager.load(_loc2_,SWFResource,this.onLoadComplete);
         PVPManager.instance.addEventListener(PVPManager.GLOBALPVP_UI_STATECHANGE,this.onGPVPStateChange,false,0,true);
         UIDispatcher.instance.addEventListener(FriendsBarMessageTabUIItem.NEW_MESSAGE,this.onNewToasterMessage,false,0,true);
         x += X_OFFSET;
      }
      
      public static function create(param1:int) : DeathMatchPopUp
      {
         return new DeathMatchPopUp(param1);
      }
      
      protected function onGPVPStateChange(param1:WorldEvent) : void
      {
         if(!PVPManager.instance.isStrangerBarStable)
         {
            this.logAction("no");
            this.m_forceClose = true;
            this.close(IMMEDIATE);
         }
      }
      
      protected function close(param1:int) : void
      {
         if(param1 == FADE)
         {
            this.disable();
            if(this.m_mc)
            {
               TweenLite.to(this,1,{"y":this.m_mc.height});
               TweenLite.to(this,1,{
                  "alpha":0,
                  "onComplete":this.onTweenOutComplete
               });
            }
         }
         else
         {
            ViralSurfacingManager.instance.dispatchEvent(new Event(ViralSurfacingManager.POPUP_CLOSED));
            this.dispose();
         }
      }
      
      protected function onTweenOutComplete() : void
      {
         this.close(IMMEDIATE);
      }
      
      public function dispose() : void
      {
         var _loc1_:ImageLoader = null;
         UIDispatcher.instance.removeEventListener(FriendsBarMessageTabUIItem.NEW_MESSAGE,this.onNewToasterMessage);
         if(parent)
         {
            parent.removeChild(this);
         }
         for each(_loc1_ in this.m_loaders)
         {
            _loc1_.destroy();
         }
         this.m_loaders = [];
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         this.m_mc = null;
         if(this.m_button)
         {
            this.m_button.dispose();
         }
         if(this.m_acceptButton)
         {
            this.m_acceptButton.dispose();
            this.m_acceptButton = null;
         }
         if(this.m_unlockBt)
         {
            this.m_unlockBt.dispose();
         }
         this.disable();
      }
      
      protected function get exit_bt() : EventDispatcher
      {
         return this.m_mc.exit_bt;
      }
      
      protected function get action_mc() : EventDispatcher
      {
         return this.m_mc.action_mc;
      }
      
      protected function onExitClicked(param1:MouseEvent) : void
      {
         this.logAction("no");
         this.close(FADE);
      }
      
      protected function logAction(param1:String) : void
      {
      }
      
      protected function disable() : void
      {
         if(this.m_button)
         {
            this.m_button.dispose();
            this.m_button = null;
         }
         if(this.m_acceptButton)
         {
            this.m_acceptButton.dispose();
            this.m_acceptButton = null;
         }
         if(this.m_mc)
         {
            this.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExitClicked);
            if(this.action_mc != null)
            {
               this.action_mc.removeEventListener(MouseEvent.CLICK,this.onExitClicked);
            }
         }
         Zlab.processManager.removeScheduledObject(this);
         UIDispatcher.instance.removeEventListener(FriendsBarMessageTabUIItem.NEW_MESSAGE,this.onNewToasterMessage);
      }
      
      protected function onNewToasterMessage(param1:Event) : void
      {
         this.logAction("no");
         this.m_forceClose = true;
         this.close(IMMEDIATE);
      }
      
      protected function get assetClass() : String
      {
         return "EpicFight_mc";
      }
      
      protected function onLoadComplete(param1:SWFResource) : void
      {
         if(this.m_forceClose)
         {
            this.close(IMMEDIATE);
            return;
         }
         var _loc2_:Class = param1.getAssetClass(this.assetClass);
         if(_loc2_)
         {
            this.m_mc = new _loc2_();
            addChild(this.m_mc);
         }
         this.initialize();
         this.m_date = new Date();
         ZGlobal.player.m_survialModeToasterTime = this.m_date.time / 60000;
         Zlab.processManager.schedule(this.m_durationSeconds * 1000,this,this.onDurationExpired);
      }
      
      protected function initialize() : void
      {
         var _loc1_:ImageLoader = null;
         y = this.m_mc.height;
         TweenLite.to(this,1,{"y":-120});
         alpha = 0;
         TweenLite.to(this,1,{"alpha":1});
         this.m_mc.icon.visible = true;
         this.m_placeholder = ZGameUtils.ZlocT("Dialogs","DM_Toaster");
         TextFieldUtil.processTextField(this.m_mc.message_tf,this.m_placeholder);
         TextFieldUtil.processTextField(this.m_mc.action_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","DM_ToasterBt"));
         _loc1_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/LiveCombat_96.png"),this.m_mc.icon);
         _loc1_.smooth = true;
         this.exit_bt.addEventListener(MouseEvent.CLICK,this.onExitClicked,false,0,true);
         this.m_acceptButton = new ZGameButton(this.m_mc.action_mc,this.onActionClicked);
      }
      
      protected function onActionClicked(param1:MouseEvent) : void
      {
         this.close(FADE);
         DeathMatchManager.instance.launchLobby();
      }
      
      protected function onDurationExpired() : void
      {
         this.close(FADE);
      }
   }
}

