package core.ui.menuitem
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import com.greensock.TweenLite;
   import com.greensock.easing.Quart;
   import com.greensock.easing.Sine;
   import core.ZGlobal;
   import core.gamemode.GameModeManager;
   import core.managers.ExperimentsManager;
   import core.managers.animationManager.AnimationManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.ui.GenericButton;
   import core.ui.Tooltip;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import dispatchers.MessageDispatcher;
   import dispatchers.UIDispatcher;
   import events.IsoViewEvent;
   import events.RepositionEvent;
   import flash.events.Event;
   import flash.events.FullScreenEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import transactions.TSaveOptions;
   import utils.ZGameUtils;
   import zgame.assets.ui.SettingsMenu.SettingPanel;
   import zlabs.Zlab;
   import zlabs.components.LocalDataComponent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.WindowManager;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   import zlabs.sound.SoundManager;
   
   public class SettingsUIItem extends MenuItem
   {
      
      private static const BUTTON_MUSIC:int = 0;
      
      private static const BUTTON_SFX:int = 1;
      
      private static const BUTTON_ZOOMIN:int = 2;
      
      private static const BUTTON_ZOOMOUT:int = 3;
      
      private static const BUTTON_MENU:int = 5;
      
      private static const BUTTON_GRAPHICS:int = 6;
      
      private static const BUTTON_TWEEN_TIME:Number = 0.5;
      
      private static const X_OFFSET:Number = -11;
      
      private static const Y_OFFSET:Number = 68;
      
      public static const ITEM_ID:String = "settingItem";
      
      public static const TOGGLE_MUSIC:String = "togglemusic";
      
      public static const TOGGLE_SFX:String = "togglesfx";
      
      public static const ZOOM_CHANGED:String = "zoomChanged";
      
      public static const ZOOM_TASK_ACTIVE:String = "settingszoomactive";
      
      public static const ZOOM_TASK_DEACTIVE:String = "settingszoomdeactive";
      
      public static const GRAPHICS_TOGGLE:String = "graphicsLowQuality";
      
      private var m_displayObject:SettingPanel;
      
      private var m_buttons:Array = null;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private var m_destinationZoom:Number = 0;
      
      private var m_isOpen:Boolean = true;
      
      private var m_inTween:Boolean = false;
      
      private var m_zoomIndex:uint = 1;
      
      private var m_zoomValues:Array = null;
      
      private var m_minZoom:Number = 0;
      
      private var m_maxZoom:Number = 0;
      
      private var m_numActiveZoomTasks:int = 0;
      
      private var m_UIWidthOffset:Number = 0;
      
      private var m_UIHeightOffset:Number = 0;
      
      private var m_buttonOrigins:Array = null;
      
      public function SettingsUIItem()
      {
         var _loc1_:GenericButton = null;
         super(ITEM_ID);
         this.m_displayObject = new SettingPanel();
         addChild(this.m_displayObject);
         this.m_buttons = new Array();
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         Zlab.mainStage.addEventListener(FullScreenEvent.FULL_SCREEN,this.onFullScreen,false,0,true);
         Zlab.mainStage.addEventListener(Event.RESIZE,this.onReposition,false,0,true);
         this.m_buttons.push(new GenericButton(this.m_displayObject.menu.musicToggle_bt,this.toggleMusicMode));
         this.m_buttons.push(new GenericButton(this.m_displayObject.menu.sfxToggle_bt,this.toggleSFXMode));
         this.m_buttons.push(new GenericButton(this.m_displayObject.menu.zoomin_bt,this.zoomIn));
         this.m_buttons.push(new GenericButton(this.m_displayObject.menu.zoomout_bt,this.zoomOut));
         this.m_buttons.push(new GenericButton(this.m_displayObject.menu.fullScreen_bt,this.toggleFullScreenMode));
         this.m_buttons.push(new GenericButton(this.m_displayObject.menu.settings_bt,this.toggleMenu));
         this.m_buttons.push(new GenericButton(this.m_displayObject.menu.graphics_bt,this.toggleGraphicsMode));
         this.m_buttons[BUTTON_MUSIC].enableHitState(true);
         this.m_buttons[BUTTON_MUSIC].setHitFrameNumber(4);
         this.m_buttons[BUTTON_SFX].enableHitState(true);
         this.m_buttons[BUTTON_SFX].setHitFrameNumber(4);
         this.m_buttons[BUTTON_ZOOMIN].enableHitState(true);
         this.m_buttons[BUTTON_ZOOMIN].setHitFrameNumber(4);
         this.m_buttons[BUTTON_ZOOMOUT].enableHitState(true);
         this.m_buttons[BUTTON_ZOOMOUT].setHitFrameNumber(4);
         this.m_buttons[BUTTON_GRAPHICS].enableHitState(true);
         this.m_buttons[BUTTON_GRAPHICS].setHitFrameNumber(4);
         Tooltip.subscribe(this.m_buttons[0].m_overlay,ZGameUtils.ZlocT("Main","ToggleMusic_ToolTip"));
         Tooltip.subscribe(this.m_buttons[1].m_overlay,ZGameUtils.ZlocT("Main","ToggleSFX_ToolTip"));
         Tooltip.subscribe(this.m_buttons[2].m_overlay,ZGameUtils.ZlocT("Main","ZoomIn_ToolTip"));
         Tooltip.subscribe(this.m_buttons[3].m_overlay,ZGameUtils.ZlocT("Main","ZoomOut_ToolTip"));
         Tooltip.subscribe(this.m_buttons[4].m_overlay,ZGameUtils.ZlocT("Main","FullScreen_ToolTip"));
         Tooltip.subscribe(this.m_buttons[5].m_overlay,ZGameUtils.ZlocT("Main","Settings_ToolTip"));
         Tooltip.subscribe(this.m_buttons[6].m_overlay,ZGameUtils.ZlocT("Main","Graphics_ToolTip"));
         TutorialManager.instance.registerUIItem(this.m_displayObject.menu.zoomin_bt,"ZoomIn");
         TutorialManager.instance.registerUIItem(this.m_displayObject.menu.zoomout_bt,"ZoomOut");
         TutorialManager.instance.registerUIItem(this.m_displayObject.menu.fullScreen_bt,"FullScreen");
         TutorialManager.instance.addEventListener(TutorialManager.ADD_STENCIL,this.onStencilAdded);
         TutorialManager.instance.addEventListener(TutorialManager.REMOVE_STENCIL,this.onStencilRemoved);
         UIDispatcher.instance.addEventListener(UIDispatcher.OPTIONS_LOADED,this.onOptionsLoaded);
         Zlab.mainStage.addEventListener(SettingsUIItem.ZOOM_TASK_ACTIVE,this.onZoomTaskActive);
         Zlab.mainStage.addEventListener(SettingsUIItem.ZOOM_TASK_DEACTIVE,this.onZoomTaskDeactive);
         this.m_buttonOrigins = new Array();
         this.m_buttonOrigins.push({
            "clip":this.m_displayObject.menu.musicToggle_bt,
            "yOrigin":this.m_displayObject.menu.musicToggle_bt.y
         });
         this.m_buttonOrigins.push({
            "clip":this.m_displayObject.menu.sfxToggle_bt,
            "yOrigin":this.m_displayObject.menu.sfxToggle_bt.y
         });
         this.m_buttonOrigins.push({
            "clip":this.m_displayObject.menu.zoomin_bt,
            "yOrigin":this.m_displayObject.menu.zoomin_bt.y
         });
         this.m_buttonOrigins.push({
            "clip":this.m_displayObject.menu.zoomout_bt,
            "yOrigin":this.m_displayObject.menu.zoomout_bt.y
         });
         this.m_buttonOrigins.push({
            "clip":this.m_displayObject.menu.fullScreen_bt,
            "yOrigin":this.m_displayObject.menu.fullScreen_bt.y
         });
         this.m_buttonOrigins.push(null);
         this.m_buttonOrigins.push({
            "clip":this.m_displayObject.menu.graphics_bt,
            "yOrigin":this.m_displayObject.menu.graphics_bt.y
         });
         this.m_zoomValues = ZGlobal.gameSettings.zoomValues;
         this.m_minZoom = ZGlobal.gameSettings.getNumber("minZoom");
         this.m_maxZoom = ZGlobal.gameSettings.getNumber("maxZoom");
         for each(_loc1_ in this.m_buttons)
         {
            this.m_buttonSounds.addButton(_loc1_.m_overlay,ButtonSound.DEFAULT);
         }
         UIDispatcher.instance.addEventListener(UIDispatcher.UI_WIDTH_OFFSET,this.onUIWidthOffset);
         UIDispatcher.instance.addEventListener(UIDispatcher.UI_HEIGHT_OFFSET,this.onUIHeightOffset);
         this.zoomReset();
         this.onReposition(null);
      }
      
      private function onOptionsLoaded(param1:Event) : void
      {
         var _loc2_:Object = LocalDataComponent.getLocalData(SoundManager.MUSIC_MIXER_CATEGORY);
         if(null != _loc2_ && Zlab.soundManager.getCategoryMuted(SoundManager.MUSIC_MIXER_CATEGORY) != _loc2_)
         {
            Zlab.soundManager.toggleMusic();
            this.setButtonMode(BUTTON_MUSIC,false);
         }
         else if(Zlab.soundManager.getCategoryMuted(SoundManager.MUSIC_MIXER_CATEGORY) == true)
         {
            this.setButtonMode(BUTTON_MUSIC,true);
         }
         _loc2_ = LocalDataComponent.getLocalData(SoundManager.SFX_MIXER_CATEGORY);
         if(null != _loc2_ && Zlab.soundManager.getCategoryMuted(SoundManager.SFX_MIXER_CATEGORY) != _loc2_)
         {
            Zlab.soundManager.toggleSFX();
            this.setButtonMode(BUTTON_SFX,false);
         }
         else if(Zlab.soundManager.getCategoryMuted(SoundManager.SFX_MIXER_CATEGORY) == true)
         {
            this.setButtonMode(BUTTON_SFX,true);
         }
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_TOGGLE_QUALITY) == ExperimentsManager.VARIANT_VALUE_TOGGLE_QUALITY_ON)
         {
            _loc2_ = LocalDataComponent.getLocalData(GRAPHICS_TOGGLE);
            if(null != _loc2_ && ZGlobal.lowQualityMode != _loc2_)
            {
               this.toggleGraphicsMode(null);
            }
            this.setButtonMode(BUTTON_GRAPHICS,ZGlobal.lowQualityMode);
         }
         else
         {
            this.m_buttons[BUTTON_GRAPHICS].turnOff();
         }
      }
      
      public function set enableZoomButtons(param1:Boolean) : void
      {
         var _loc2_:Boolean = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_TOGGLE_QUALITY) == ExperimentsManager.VARIANT_VALUE_TOGGLE_QUALITY_ON;
         this.m_displayObject.menu.zoomin_bt.visible = param1;
         this.m_displayObject.menu.zoomout_bt.visible = param1;
         if(param1)
         {
            this.m_buttons[BUTTON_ZOOMIN].turnOn();
            this.m_buttons[BUTTON_ZOOMOUT].turnOn();
            if(_loc2_)
            {
               this.m_buttons[BUTTON_GRAPHICS].y = this.m_buttonOrigins[BUTTON_GRAPHICS].yOrigin;
            }
         }
         else
         {
            this.m_buttons[BUTTON_ZOOMIN].turnOff();
            this.m_buttons[BUTTON_ZOOMOUT].turnOff();
            if(_loc2_)
            {
               this.m_buttons[BUTTON_GRAPHICS].y = this.m_buttonOrigins[BUTTON_ZOOMOUT].yOrigin;
            }
         }
      }
      
      private function onUIWidthOffset(param1:RepositionEvent) : void
      {
         this.m_UIWidthOffset = param1.x;
         this.onReposition(null);
      }
      
      private function onUIHeightOffset(param1:RepositionEvent) : void
      {
         this.m_UIHeightOffset = param1.y;
         this.onReposition(null);
      }
      
      private function toggleButtons() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this.m_buttons.length - 1)
         {
            if(_loc1_ != BUTTON_MENU)
            {
               this.m_buttons[_loc1_].disabled = this.m_isOpen == false;
            }
            _loc1_++;
         }
      }
      
      private function toggleMenu(param1:Event) : void
      {
         this.m_isOpen = !this.m_isOpen;
         this.tweenMenuButtons(this.m_isOpen);
         this.setMenuButtonMode(BUTTON_MENU,this.m_isOpen);
         this.toggleButtons();
      }
      
      private function tweenMenuButtons(param1:Boolean) : void
      {
         var _loc2_:Object = null;
         for each(_loc2_ in this.m_buttonOrigins)
         {
            if(_loc2_)
            {
               TweenLite.to(_loc2_.clip,BUTTON_TWEEN_TIME,{
                  "y":(param1 ? _loc2_.yOrigin : 0),
                  "ease":Quart.easeOut
               });
            }
         }
      }
      
      private function setButtonMode(param1:int, param2:Boolean) : void
      {
         if(param2)
         {
            this.m_buttons[param1].state = GenericButton.HITSTATE;
         }
         else
         {
            this.m_buttons[param1].state = GenericButton.UPSTATE;
         }
      }
      
      private function setZoomButtonMode(param1:int, param2:Boolean) : void
      {
         if(param2)
         {
            this.m_buttons[param1].state = GenericButton.HITSTATE;
         }
         else
         {
            this.m_buttons[param1].state = GenericButton.UPSTATE;
         }
      }
      
      private function setMenuButtonMode(param1:int, param2:Boolean) : void
      {
         if(param2)
         {
            this.m_buttons[param1].setUpFrameNumber(1);
            this.m_buttons[param1].setOverFrameNumber(2);
            this.m_buttons[param1].setDownFrameNumber(3);
            this.m_buttons[param1].state = GenericButton.OVERSTATE;
         }
         else
         {
            this.m_buttons[param1].setUpFrameNumber(4);
            this.m_buttons[param1].setOverFrameNumber(5);
            this.m_buttons[param1].setDownFrameNumber(6);
            this.m_buttons[param1].state = GenericButton.OVERSTATE;
         }
      }
      
      private function toggleMusicMode(param1:Event) : void
      {
         var _loc2_:Boolean = Zlab.soundManager.toggleMusic();
         this.setButtonMode(BUTTON_MUSIC,_loc2_);
         LocalDataComponent.setLocalData(SoundManager.MUSIC_MIXER_CATEGORY,_loc2_);
         ZGlobal.player.options["musicDisabled"] = _loc2_;
         TransactionManager.addTransaction(new TSaveOptions(ZGlobal.player.options));
         MessageDispatcher.instance.dispatchEvent(new WorldEvent(TOGGLE_MUSIC,_loc2_));
      }
      
      private function toggleSFXMode(param1:Event) : void
      {
         var _loc2_:Boolean = Zlab.soundManager.toggleSFX();
         this.setButtonMode(BUTTON_SFX,_loc2_);
         LocalDataComponent.setLocalData(SoundManager.SFX_MIXER_CATEGORY,_loc2_);
         ZGlobal.player.options["sfxDisabled"] = _loc2_;
         TransactionManager.addTransaction(new TSaveOptions(ZGlobal.player.options));
         MessageDispatcher.instance.dispatchEvent(new WorldEvent(TOGGLE_SFX,_loc2_));
      }
      
      public function toggleFullScreenMode(param1:Event) : void
      {
         WindowManager.toggleFullScreen();
         if(TutorialManager.instance.active)
         {
            TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.FULL_SCREEN_CLICK));
         }
      }
      
      public function toggleGraphicsMode(param1:Event) : void
      {
         var _loc2_:String = "enable";
         if(ZGlobal.lowQualityMode)
         {
            ZGlobal.lowQualityMode = false;
            Zlab.mainStage.quality = "HIGH";
         }
         else
         {
            ZGlobal.lowQualityMode = true;
            Zlab.mainStage.quality = "MEDIUM";
            _loc2_ = "disable";
         }
         this.setButtonMode(BUTTON_GRAPHICS,ZGlobal.lowQualityMode);
         UIDispatcher.instance.dispatchEvent(new WorldEvent(ZGlobal.LOW_QUALITY_MODE));
         LocalDataComponent.setLocalData(GRAPHICS_TOGGLE,ZGlobal.lowQualityMode);
         ZGlobal.player.options["lowQualityMode"] = ZGlobal.lowQualityMode;
         TransactionManager.addTransaction(new TSaveOptions(ZGlobal.player.options));
         StatsManager.count("performance_toggle","click",_loc2_);
      }
      
      private function checkZoomExtents(param1:Number) : Number
      {
         var _loc2_:Number = Math.min(this.m_maxZoom,Math.max(this.m_minZoom,param1));
         this.setZoomButtonMode(BUTTON_ZOOMOUT,_loc2_ == this.m_minZoom);
         this.setZoomButtonMode(BUTTON_ZOOMIN,_loc2_ == this.m_maxZoom);
         return _loc2_;
      }
      
      private function setZoomLevel(param1:Number, param2:Boolean = false) : void
      {
         var _loc3_:IsoViewComponent = null;
         var _loc4_:Number = NaN;
         if(ZGlobal.stencilActive)
         {
            return;
         }
         if(!this.m_inTween)
         {
            param1 = this.checkZoomExtents(param1);
            AnimationManager.instance.zoom(param1);
            Zlab.mainStage.dispatchEvent(new WorldEvent(ZOOM_CHANGED,{"zoom":param1}));
            this.m_destinationZoom = param1;
            _loc3_ = this.getIsoViewComponent();
            _loc4_ = _loc3_.currentZoom;
            if(_loc4_ > this.m_destinationZoom)
            {
               _loc3_.zoom(param1);
               _loc3_.zoomLevel(_loc4_);
               this.m_destinationZoom = -1;
            }
            if(param2)
            {
               this.zoom = param1;
            }
            else
            {
               this.m_inTween = true;
               TweenLite.to(this,0.2,{
                  "zoom":param1,
                  "ease":Sine.easeInOut,
                  "onComplete":this.onTweenComplete
               });
            }
         }
      }
      
      public function onTweenComplete() : void
      {
         var _loc1_:IsoViewComponent = null;
         if(this.m_destinationZoom >= 0)
         {
            _loc1_ = this.getIsoViewComponent();
            _loc1_.zoom(this.m_destinationZoom);
         }
         this.m_inTween = false;
      }
      
      private function getIsoViewComponent() : IsoViewComponent
      {
         return ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
      }
      
      public function set zoom(param1:Number) : void
      {
         var _loc2_:IsoViewComponent = this.getIsoViewComponent();
         _loc2_.zoomLevel(param1);
         GameModeManager.instance.dispatchEvent(new IsoViewEvent(IsoViewEvent.ISOVIEW_ZOOM,param1));
      }
      
      public function get zoom() : Number
      {
         var _loc1_:IsoViewComponent = this.getIsoViewComponent();
         return _loc1_.currentZoom;
      }
      
      public function zoomInMax() : void
      {
         this.setZoomIndex(0);
         if(TutorialManager.instance.active)
         {
            TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.ZOOM_IN_CLICK));
         }
      }
      
      public function zoomInToIndex(param1:Number) : void
      {
         this.setZoomIndex(param1);
         if(TutorialManager.instance.active)
         {
            TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.ZOOM_IN_CLICK));
         }
      }
      
      public function zoomIn(param1:Event = null) : void
      {
         this.setZoomIndex(this.m_zoomIndex - 1);
         if(TutorialManager.instance.active)
         {
            TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.ZOOM_IN_CLICK));
         }
      }
      
      public function zoomOut(param1:Event = null) : void
      {
         this.setZoomIndex(this.m_zoomIndex + 1);
         if(TutorialManager.instance.active)
         {
            TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.ZOOM_OUT_CLICK));
         }
      }
      
      public function setZoomToDefault() : void
      {
         this.zoomReset();
      }
      
      private function zoomReset() : void
      {
         this.setZoomIndex(ZGlobal.gameSettings.zoomDefaultIndex);
      }
      
      private function setZoomIndex(param1:int, param2:Boolean = false) : void
      {
         if(!this.m_inTween && param1 >= 0 && param1 < this.m_zoomValues.length)
         {
            this.m_zoomIndex = param1;
            this.setZoomLevel(this.m_zoomValues[this.m_zoomIndex],param2);
         }
      }
      
      protected function onFullScreen(param1:FullScreenEvent) : void
      {
         this.onReposition(null);
      }
      
      private function snapZoom(param1:uint) : void
      {
         if(param1 != this.m_zoomIndex)
         {
            this.m_inTween = false;
            TweenLite.killTweensOf(this);
            this.setZoomIndex(param1,true);
         }
      }
      
      protected function onReposition(param1:Event) : void
      {
         this.x = Zlab.mainStage.stageWidth - this.width + X_OFFSET + this.m_UIWidthOffset;
         this.y = Y_OFFSET + this.m_UIHeightOffset;
      }
      
      private function onStencilAdded(param1:WorldEvent) : void
      {
         ZGameUtils.disableButton(this.m_displayObject.menu.musicToggle_bt,this.toggleMusicMode);
         ZGameUtils.disableButton(this.m_displayObject.menu.sfxToggle_bt,this.toggleSFXMode);
         ZGameUtils.disableButton(this.m_displayObject.menu.zoomin_bt,this.zoomIn);
         ZGameUtils.disableButton(this.m_displayObject.menu.zoomout_bt,this.zoomOut);
         ZGameUtils.disableButton(this.m_displayObject.menu.fullScreen_bt,this.toggleFullScreenMode);
         ZGameUtils.disableButton(this.m_displayObject.menu.graphics_bt,this.toggleGraphicsMode);
         ZGameUtils.disableButton(this.m_displayObject.menu.settings_bt,this.toggleMenu);
         var _loc2_:int = 0;
         while(_loc2_ < this.m_buttons.length)
         {
            this.m_buttons[_loc2_].disabled = true;
            _loc2_++;
         }
      }
      
      private function onStencilRemoved(param1:WorldEvent) : void
      {
         ZGameUtils.enableButton(this.m_displayObject.menu.musicToggle_bt,this.toggleMusicMode);
         ZGameUtils.enableButton(this.m_displayObject.menu.sfxToggle_bt,this.toggleSFXMode);
         ZGameUtils.enableButton(this.m_displayObject.menu.zoomin_bt,this.zoomIn);
         ZGameUtils.enableButton(this.m_displayObject.menu.zoomout_bt,this.zoomOut);
         ZGameUtils.enableButton(this.m_displayObject.menu.fullScreen_bt,this.toggleFullScreenMode);
         ZGameUtils.enableButton(this.m_displayObject.menu.graphics_bt,this.toggleGraphicsMode);
         ZGameUtils.enableButton(this.m_displayObject.menu.settings_bt,this.toggleMenu);
         var _loc2_:int = 0;
         while(_loc2_ < this.m_buttons.length)
         {
            this.m_buttons[_loc2_].disabled = false;
            _loc2_++;
         }
      }
      
      private function onZoomTaskActive(param1:Event) : void
      {
         ++this.m_numActiveZoomTasks;
      }
      
      private function onZoomTaskDeactive(param1:Event) : void
      {
         --this.m_numActiveZoomTasks;
      }
   }
}

