package core.ui.menuitem
{
   import Engine.Init.InitializationManager;
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.managers.ExperimentsManager;
   import core.managers.FlashFeedManager;
   import core.managers.TimedBuildableManager;
   import core.managers.WorldObjectManager;
   import core.managers.miniGameManager.BomberGameManager;
   import core.managers.promoManager.PromoManager;
   import dispatchers.UIDispatcher;
   import events.RepositionEvent;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.CriteriaUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.events.WorldEvent;
   
   public class PromoMenuItemContainer extends MenuItem
   {
      
      public static const ITEM_ID:String = "promoUIItemContainer";
      
      public static const FLAG_CV_GR_XPROMO_HUD:String = "CVGRxpromo01hud";
      
      public static const FLAG_DIRECT_RELIEF_HUD:String = "DirectReliefHud";
      
      private var m_iconSpacing:Number;
      
      private var m_icons:Vector.<MenuItem>;
      
      private var m_scrollIndex:Number;
      
      private var m_buttonLayer:Sprite;
      
      private var m_scrollButtonDown:MovieClip;
      
      private var m_scrollButtonUp:MovieClip;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private const OFFSET_X:Number = -10;
      
      private const OFFSET_Y:Number = 270;
      
      private const HOME_PIXEL_HEIGHT:Number = 168;
      
      private const MARGIN_TOP:Number = 8;
      
      private const XPROMO_MIN_LEVEL:int = 10;
      
      private var containerWidth:Number;
      
      private var containerHeight:Number;
      
      public function PromoMenuItemContainer()
      {
         super(ITEM_ID);
         this.m_icons = new Vector.<MenuItem>();
         this.m_iconSpacing = ZGlobal.gameSettings.getNumber("promoIconSpacing");
         this.m_scrollIndex = 0;
         this.m_buttonLayer = new Sprite();
         this.makeScrollButtons();
         this.containerWidth = 64;
         this.containerHeight = this.HOME_PIXEL_HEIGHT;
         UIDispatcher.instance.addEventListener(RepositionEvent.REPOSITION_HUD,this.onReposition,false,0,true);
         UIDispatcher.instance.addEventListener(UIDispatcher.UI_PLAYER_ISLAND_MODE_ACTIVE,this.onPlayerIslandModeChange,false,0,true);
         UIDispatcher.instance.addEventListener(UIDispatcher.UI_REMOVE_UI_ITEM,this.onRemoveMenuItem,false,0,true);
         InitializationManager.getInstance().addEventListener(Event.COMPLETE,this.initHUDIcons);
      }
      
      private function get maxIconsInContainer() : int
      {
         return Math.floor(this.containerHeight / this.m_iconSpacing);
      }
      
      private function makeScrollButtons() : void
      {
         this.m_scrollButtonDown = new scroll_bt_dn();
         this.m_scrollButtonUp = new scroll_bt_up();
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_buttonSounds.addButton(this.m_scrollButtonDown,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.m_scrollButtonUp,ButtonSound.DEFAULT);
         this.m_scrollButtonDown.addEventListener(MouseEvent.CLICK,this.onScrollDown);
         this.m_scrollButtonUp.addEventListener(MouseEvent.CLICK,this.onScrollUp);
         addChild(this.m_buttonLayer);
         this.m_buttonLayer.addChild(this.m_scrollButtonDown);
         this.m_buttonLayer.addChild(this.m_scrollButtonUp);
         this.updateButtonEnable();
      }
      
      private function initHUDIcons(param1:Event) : void
      {
         var _loc3_:XML = null;
         var _loc5_:XML = null;
         var _loc6_:BomberHudItem = null;
         var _loc7_:Number = NaN;
         InitializationManager.getInstance().removeEventListener(Event.COMPLETE,this.initHUDIcons);
         this.addItem(new RecentPlayersUIItem());
         if(ExperimentsManager.instance.getExperimentVariant("empire_bombingrun_master") == 1 && ZGlobal.player.level >= BomberGameManager.BOMBER_MIN_LEVEL)
         {
            _loc6_ = new BomberHudItem();
            this.addItem(_loc6_);
         }
         if(PromoManager.instance.meetsCriteriaStarterPack(false) && ZGlobal.player.getSeenFlag(PromoManager.FLAG_STARTER_PACK_HUD_ICON) < ZGlobal.gameSettings.getNumber("promoIconSeenAmount"))
         {
            this.addItem(new PromoStarterPackUIItem());
         }
         var _loc2_:XMLList = ZGlobal.gameSettings.getLEHudIcons();
         for each(_loc3_ in _loc2_)
         {
            if(CriteriaUtil.meetsCriteria(_loc3_.criteria))
            {
               this.addItem(new LEHudUIItem(_loc3_));
            }
         }
         if(ExperimentsManager.instance.getExperimentVariant("empire_wonders_master") == 3 && WorldObjectManager.instance.getNumberBuiltObjectsWithCode("BB22") < 1)
         {
            if(ZGlobal.player.level > 17)
            {
               this.addItem(new WondersMenuItem());
            }
         }
         if(ExperimentsManager.instance.getExperimentVariant(FlashFeedManager.EXPERIMENT_FLASHFEED_NEW) >= 1 && FlashFeedManager.exists() && ZGlobal.player.level >= FlashFeedManager.FLASH_FEED_LEVEL_GATE)
         {
            _loc7_ = GlobalEngine.serverTime;
            this.addItem(FlashFeedMenuItem.getInstance());
         }
         var _loc4_:XMLList = TimedBuildableManager.instance.getHUDItems();
         for each(_loc5_ in _loc4_)
         {
            if(CriteriaUtil.meetsCriteria(_loc5_.criteria))
            {
               this.addItem(new TimedBuildableMenuItem(_loc5_));
            }
         }
         if(DirectReliefPromoUIItem.isEnabled())
         {
            this.addItem(new DirectReliefPromoUIItem());
         }
         if(!PromoManager.instance.isInitialized())
         {
            PromoManager.instance.addEventListener(PromoManager.INITIALIZED,this.createFlashSaleFlyOut,false,0,true);
         }
         else
         {
            this.createFlashSaleFlyOut(null);
         }
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_MOTD_SCROLLING) == ExperimentsManager.VARIANT_VALUE_MOTD_SCROLLING_ON)
         {
            this.addItem(new MOTDPromoUIItem());
         }
      }
      
      private function createFlashSaleFlyOut(param1:Event) : void
      {
         var _loc2_:SaleFlyout = null;
         PromoManager.instance.removeEventListener(PromoManager.INITIALIZED,this.createFlashSaleFlyOut);
         if(PromoManager.instance.qualifyingPromotion)
         {
            _loc2_ = new SaleFlyout(PromoManager.instance.qualifyingPromotion);
            this.addChild(_loc2_);
         }
      }
      
      private function onPlayerIslandModeChange(param1:WorldEvent) : void
      {
         if(param1.eventData)
         {
            this.visible = param1.eventData.active;
         }
      }
      
      override public function addItem(param1:MenuItem, param2:int = 0) : MenuItem
      {
         var _loc3_:PromoMenuItem = super.addItem(param1,param2) as PromoMenuItem;
         if(_loc3_ == null)
         {
            throw new Error("item is not PromoMenuItem: " + _loc3_);
         }
         this.m_icons.unshift(_loc3_);
         _loc3_.addEventListener(MouseEvent.CLICK,this.menuItemClicked);
         this.updateIcons();
         return _loc3_;
      }
      
      private function menuItemClicked(param1:MouseEvent) : void
      {
         var _loc2_:PromoMenuItem = param1.currentTarget as PromoMenuItem;
         if(_loc2_.removeOnClicked)
         {
            this.removeMenuItem(_loc2_);
         }
      }
      
      private function onRemoveMenuItem(param1:WorldEvent) : void
      {
         var _loc2_:PromoMenuItem = null;
         if(param1.eventData)
         {
            _loc2_ = param1.eventData as PromoMenuItem;
            this.removeMenuItem(_loc2_);
         }
      }
      
      private function removeMenuItem(param1:PromoMenuItem) : void
      {
         var _loc2_:int = 0;
         if(param1 != null && param1.removeOnClick)
         {
            param1.removeEventListener(MouseEvent.CLICK,this.menuItemClicked);
            param1.removeItem();
            removeChild(param1);
            _loc2_ = this.m_icons.indexOf(param1);
            if(_loc2_ != -1)
            {
               this.m_icons.splice(_loc2_,1);
               --this.m_scrollIndex;
               this.m_scrollIndex = ZGameUtils.clamp(this.m_scrollIndex,0,this.m_icons.length);
            }
            this.updateIcons();
         }
      }
      
      private function updateIcons() : void
      {
         this.sortIcons();
         addChild(this.m_buttonLayer);
         this.updateButtonEnable();
         this.moveIcons(false);
         this.onReposition(null);
      }
      
      public function sortIcons() : void
      {
         this.m_icons.sort(this.sortByPriority);
      }
      
      private function sortByPriority(param1:PromoMenuItem, param2:PromoMenuItem) : Number
      {
         if(param1.priority == param2.priority && param1 is LEHudUIItem && param2 is LEHudUIItem)
         {
            return ZGameTimeUtil.instance.getStartSeconds((param2 as LEHudUIItem).m_xml) - ZGameTimeUtil.instance.getStartSeconds((param1 as LEHudUIItem).m_xml);
         }
         return param1.priority - param2.priority;
      }
      
      override public function removeItem() : void
      {
         var _loc1_:MenuItem = null;
         UIDispatcher.instance.removeEventListener(RepositionEvent.REPOSITION_HUD,this.onReposition);
         for each(_loc1_ in m_menuItems)
         {
            _loc1_.removeItem();
         }
         m_menuItems = null;
         this.m_buttonSounds.release();
         this.m_buttonSounds = null;
         removeChild(this.m_scrollButtonDown);
         removeChild(this.m_scrollButtonUp);
         this.m_scrollButtonDown.removeEventListener(MouseEvent.CLICK,this.onScrollDown);
         this.m_scrollButtonUp.removeEventListener(MouseEvent.CLICK,this.onScrollUp);
         super.removeItem();
      }
      
      protected function onReposition(param1:RepositionEvent) : void
      {
         x = Zlab.mainStage.stageWidth + this.OFFSET_X - this.containerWidth;
         y = this.OFFSET_Y;
         var _loc2_:Boolean = this.m_icons.length > this.maxIconsInContainer;
         this.m_scrollButtonDown.visible = _loc2_;
         this.m_scrollButtonUp.visible = _loc2_;
         this.m_scrollButtonUp.x = this.containerWidth - this.m_scrollButtonDown.width;
         this.m_scrollButtonUp.y = -this.m_scrollButtonUp.height;
         this.m_scrollButtonDown.x = this.m_scrollButtonUp.x;
         this.m_scrollButtonDown.y = this.containerHeight;
      }
      
      private function moveIcons(param1:Boolean) : void
      {
         var _loc3_:MenuItem = null;
         var _loc2_:int = -this.m_scrollIndex;
         for each(_loc3_ in this.m_icons)
         {
            this.moveTo(_loc3_,_loc2_,param1);
            _loc2_++;
         }
      }
      
      private function moveTo(param1:MenuItem, param2:int, param3:Boolean) : void
      {
         var _loc4_:Number = 0.5;
         TweenLite.killTweensOf(param1);
         param1.alpha = Math.round(param1.alpha);
         if(param3)
         {
            param1.x = 0;
            param1.y = this.iconYFromIndex(param2);
         }
         else
         {
            TweenLite.to(param1,_loc4_,{
               "x":0,
               "y":this.iconYFromIndex(param2)
            });
         }
         if(param2 >= 0 && param2 < this.maxIconsInContainer)
         {
            param1.mouseEnabled = true;
            param1.mouseChildren = true;
            if(param3)
            {
               param1.alpha = 1;
            }
            else
            {
               TweenLite.to(param1,_loc4_,{"alpha":1});
            }
         }
         else
         {
            param1.mouseEnabled = false;
            param1.mouseChildren = false;
            if(param3)
            {
               param1.alpha = 0;
            }
            else
            {
               TweenLite.to(param1,_loc4_,{"alpha":0});
            }
         }
      }
      
      private function iconYFromIndex(param1:Number) : Number
      {
         return param1 * this.m_iconSpacing + this.MARGIN_TOP;
      }
      
      private function onScrollDown(param1:MouseEvent) : void
      {
         ++this.m_scrollIndex;
         this.m_scrollIndex = ZGameUtils.clamp(this.m_scrollIndex,0,this.m_icons.length);
         this.updateButtonEnable();
         this.moveIcons(false);
         this.RemoveTutorials();
      }
      
      private function RemoveTutorials() : void
      {
         if(ExperimentsManager.instance.getExperimentVariant("empire_bombingrun_master") == 1 && ZGlobal.player.level >= BomberGameManager.BOMBER_MIN_LEVEL)
         {
            if(BomberGameManager.instance.isBomberTutorialActive())
            {
               BomberGameManager.instance.RemoveTutorial();
               return;
            }
         }
      }
      
      private function onScrollUp(param1:MouseEvent) : void
      {
         --this.m_scrollIndex;
         this.m_scrollIndex = ZGameUtils.clamp(this.m_scrollIndex,0,this.m_icons.length);
         this.updateButtonEnable();
         this.moveIcons(false);
         this.RemoveTutorials();
      }
      
      private function updateButtonEnable() : void
      {
         ZGameUtils.setButtonEnabled(this.m_scrollButtonDown,this.onScrollDown,this.m_scrollIndex + this.maxIconsInContainer < this.m_icons.length);
         ZGameUtils.setButtonEnabled(this.m_scrollButtonUp,this.onScrollUp,this.m_scrollIndex > 0);
      }
   }
}

