package core.worlds.strategicWorld.swf.version2
{
   import Engine.MathUtil;
   import com.greensock.TweenLite;
   import com.greensock.easing.Cubic;
   import core.ZGlobal;
   import core.gameobjects.IslandGroupItem;
   import core.managers.ExperimentsManager;
   import core.managers.campaignManager.CampaignManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.ui.Tooltip;
   import core.ui.ZGameButton;
   import core.worlds.strategicWorld.StrategicRendererComponent;
   import dispatchers.StrategicDispatcher;
   import dispatchers.UIDispatcher;
   import events.RepositionEvent;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.FullScreenEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import rendering.rendering2d.FullScreenHorizontalBorders;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.core.InputManager;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class StrategicSWF2RendererComponent extends StrategicRendererComponent
   {
      
      public static const WIDTH:uint = 1520;
      
      private const REGION_NAME:String = "region";
      
      private const HEIGHT:uint = 640;
      
      private const INITIAL_PAN:String = "sinitialpan";
      
      private const NAV_WIDGET_BORDER:int = 20;
      
      private var m_resource:SWFResource = null;
      
      private var m_borders:FullScreenHorizontalBorders = null;
      
      private var m_clipRequests:Array = null;
      
      private var m_regions:Dictionary = null;
      
      private var m_islands:Dictionary = null;
      
      private var m_currentBattlePrompt:StrategicBattlePrompt = null;
      
      private var m_hoverBattlePrompt:StrategicScopedBattlePrompt = null;
      
      private var m_selectableRegions:Array = null;
      
      private var m_currentRegion:ISelectableRegion = null;
      
      private var m_loader:ResourceLoadHandler = null;
      
      private var m_mouseAnchor:Number = 0;
      
      private var m_resourceAnchor:Number = 0;
      
      private var m_ratio:Number = 1;
      
      private var m_uIOffset:Point = new Point(0,0);
      
      private var m_fullScreen:Boolean = false;
      
      private var m_activated:Boolean = false;
      
      private var m_loading:Boolean = false;
      
      private var m_mouseDown:Boolean = false;
      
      private var m_panning:Boolean = false;
      
      private var m_tweening:Boolean = false;
      
      private var m_ignoreClick:Boolean = false;
      
      private var m_navControl:MovieClip = null;
      
      private var m_battlePromptVersion:String = null;
      
      public function StrategicSWF2RendererComponent()
      {
         super();
      }
      
      public function loadRegionClip(param1:IslandGroupItem, param2:Function) : void
      {
         if(null != this.m_resource)
         {
            param2(this.getRegionClip(param1));
         }
         else
         {
            this.m_clipRequests.push({
               "islandGroupItem":param1,
               "func":param2
            });
         }
      }
      
      override protected function onActivated(param1:Event) : void
      {
         super.onActivated(param1);
         this.m_clipRequests = new Array();
         this.m_activated = true;
         this.m_selectableRegions = new Array();
         displayObject.addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
         displayObject.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         displayObject.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         Zlab.inputManager.addEventListener(InputManager.MOUSE_LEAVE,this.onMouseLeave);
         this.doMapLoad();
         StrategicDispatcher.instance.addEventListener(StrategicDispatcher.ISLAND_REGISTER,this.onRegisterRegion);
         StrategicDispatcher.instance.addEventListener(StrategicDispatcher.ISLAND_EXIT,this.onPanelExit);
         StrategicDispatcher.instance.addEventListener(StrategicDispatcher.ISLAND_SELECTED,this.onIslandSelected);
         StrategicDispatcher.instance.addEventListener(StrategicDispatcher.PICK_FOCUS,this.onPickFocus);
      }
      
      private function doMapLoad() : void
      {
         this.m_loading = true;
         this.m_loader = new ResourceLoadHandler(this.onSWFLoadComplete);
      }
      
      override protected function onDeactivated(param1:WorldEvent) : void
      {
         var _loc2_:String = null;
         super.onDeactivated(param1);
         this.m_clipRequests = null;
         if(this.m_loader)
         {
            this.m_loader.dispose();
            this.m_loader = null;
         }
         this.deInitNavButtons();
         this.unloadAssets();
         displayObject.removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
         displayObject.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         displayObject.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         Zlab.inputManager.removeEventListener(InputManager.MOUSE_LEAVE,this.onMouseLeave);
         StrategicDispatcher.instance.removeEventListener(StrategicDispatcher.ISLAND_REGISTER,this.onRegisterRegion);
         StrategicDispatcher.instance.removeEventListener(StrategicDispatcher.ISLAND_EXIT,this.onPanelExit);
         StrategicDispatcher.instance.removeEventListener(StrategicDispatcher.ISLAND_SELECTED,this.onIslandSelected);
         StrategicDispatcher.instance.removeEventListener(StrategicDispatcher.PICK_FOCUS,this.onPickFocus);
         for(_loc2_ in this.m_regions)
         {
            Tooltip.unsubscribe(this.m_regions[_loc2_].anchor_mc_mastery);
         }
         this.m_currentRegion = null;
         this.m_mouseDown = false;
         this.m_panning = false;
         this.m_activated = false;
         this.updateUIOffset(true);
      }
      
      override protected function onReload(param1:WorldEvent) : void
      {
         if(!this.m_loading)
         {
            this.unloadAssets();
            this.m_clipRequests = new Array();
            this.m_selectableRegions = new Array();
            this.doMapLoad();
         }
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         Zlab.mainStage.addEventListener(FullScreenEvent.FULL_SCREEN,this.onFullScreen);
         Zlab.mainStage.addEventListener(Event.RESIZE,this.onReposition);
         this.reposition(false);
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         Zlab.mainStage.removeEventListener(FullScreenEvent.FULL_SCREEN,this.onFullScreen);
         Zlab.mainStage.removeEventListener(Event.RESIZE,this.onReposition);
      }
      
      private function unloadAssets() : void
      {
         if(null != this.m_resource)
         {
            this.m_borders.dispose();
            this.m_borders = null;
            this.m_currentBattlePrompt.dispose();
            this.m_currentBattlePrompt = null;
            this.m_hoverBattlePrompt.dispose();
            this.m_hoverBattlePrompt = null;
            if(this.m_navControl)
            {
               this.m_resource.clip.parent.removeChild(this.m_navControl);
               this.m_navControl = null;
            }
            Sprite(displayObject).removeChild(this.m_resource.clip);
            this.stopTween();
            this.m_selectableRegions = null;
            this.m_islands = null;
            this.m_regions = null;
            this.m_resource = null;
         }
      }
      
      private function panTo(param1:Number, param2:Number) : void
      {
         if(this.isFullScreen)
         {
            param1 = MathUtil.clamp(param1,-(WIDTH * this.m_ratio - Zlab.mainStage.stageWidth),0);
         }
         else
         {
            param1 = MathUtil.clamp(param1,-(WIDTH * this.m_ratio * (Zlab.mainStage.stageHeight / this.HEIGHT) - Zlab.mainStage.stageWidth),0);
         }
         if(param1 != this.m_resource.clip.x)
         {
            if(param2 == 0)
            {
               this.m_resource.clip.x = param1;
            }
            else
            {
               this.m_tweening = true;
               TweenLite.to(this.m_resource.clip,param2,{
                  "x":param1,
                  "delay":0.5,
                  "ease":Cubic.easeInOut,
                  "onUpdate":this.onAutoPanUpdate
               });
            }
         }
      }
      
      private function onAutoPanUpdate() : void
      {
         this.m_currentBattlePrompt.updateSide();
      }
      
      private function stopTween() : void
      {
         if(this.m_tweening)
         {
            TweenLite.killTweensOf(this.m_resource.clip);
            this.m_tweening = false;
         }
      }
      
      private function onMouseMove(param1:MouseEvent) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Boolean = false;
         var _loc4_:ISelectableRegion = null;
         if(this.m_activated && !this.m_loading)
         {
            _loc2_ = null != param1 ? param1.stageX - this.m_mouseAnchor : 0;
            if(this.m_mouseDown && (this.m_panning || Math.abs(_loc2_) >= 1))
            {
               this.m_panning = true;
               this.stopTween();
               this.panTo(this.m_resourceAnchor + _loc2_,0);
               this.m_currentBattlePrompt.updateSide();
               if(null != this.m_currentRegion)
               {
                  this.m_currentRegion.focus = false;
                  this.m_currentRegion = null;
               }
            }
            else if(!this.m_currentBattlePrompt.blockingInput && !this.m_hoverBattlePrompt.blockingInput)
            {
               this.m_currentRegion = null;
               _loc3_ = false;
               for each(_loc4_ in this.m_selectableRegions)
               {
                  if(false == _loc3_ && _loc4_.hitTest())
                  {
                     _loc3_ = true;
                     this.m_currentRegion = _loc4_;
                     _loc4_.focus = true;
                  }
                  else
                  {
                     _loc4_.focus = false;
                  }
               }
               if(null == this.m_currentRegion)
               {
                  StrategicDispatcher.instance.dispatchEvent(new WorldEvent(StrategicDispatcher.ISLAND_SCOPE_ENTER,null));
               }
            }
         }
      }
      
      private function onMouseClick(param1:MouseEvent) : void
      {
         if(!this.m_ignoreClick)
         {
            displayObject.removeEventListener(MouseEvent.CLICK,this.onMouseClick);
            StrategicDispatcher.instance.dispatchEvent(new Event(StrategicDispatcher.ISLAND_FORCE_EXIT));
            this.onMouseMove(null);
         }
         this.m_ignoreClick = false;
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         if(!this.m_loading)
         {
            this.m_mouseDown = true;
            this.m_mouseAnchor = param1.stageX;
            this.m_resourceAnchor = this.m_resource.clip.x;
         }
      }
      
      private function onMouseUp(param1:MouseEvent) : void
      {
         if(this.m_activated && !this.m_loading)
         {
            if(!this.m_currentBattlePrompt.blockingInput && !this.m_hoverBattlePrompt.blockingInput)
            {
               if(!this.m_panning)
               {
                  if(null != this.m_currentRegion)
                  {
                     this.m_currentRegion.click();
                     this.m_currentRegion = null;
                     this.m_ignoreClick = true;
                     displayObject.addEventListener(MouseEvent.CLICK,this.onMouseClick);
                  }
               }
               this.m_mouseDown = false;
               this.m_panning = false;
               this.onMouseMove(param1);
            }
            else
            {
               this.m_mouseDown = false;
               this.m_panning = false;
            }
         }
      }
      
      private function onMouseLeave(param1:Event) : void
      {
         if(this.m_mouseDown)
         {
            this.m_mouseDown = false;
            this.m_panning = false;
            this.m_currentRegion = null;
         }
      }
      
      private function onRegisterRegion(param1:WorldEvent) : void
      {
         var _loc2_:ISelectableRegion = param1.eventData as ISelectableRegion;
         this.m_selectableRegions.push(_loc2_);
         if(_loc2_.code == ZGlobal.player.campaign.currentMapName)
         {
            if(ZGlobal.player.campaign.currentMap.inReplay)
            {
               _loc2_.focus = true;
               displayObject.addEventListener(MouseEvent.CLICK,this.onMouseClick);
            }
         }
      }
      
      private function onPanelExit(param1:Event) : void
      {
         this.onMouseMove(null);
         displayObject.removeEventListener(MouseEvent.CLICK,this.onMouseClick);
      }
      
      private function onIslandSelected(param1:Event) : void
      {
         displayObject.addEventListener(MouseEvent.CLICK,this.onMouseClick);
      }
      
      private function onPickFocus(param1:WorldEvent) : void
      {
         var _loc2_:ISelectableRegion = null;
         if(this.m_currentRegion)
         {
            if(this.m_currentRegion.code != param1.eventData)
            {
               this.m_currentRegion.focus = false;
               this.m_currentRegion = null;
               StrategicDispatcher.instance.dispatchEvent(new WorldEvent(StrategicDispatcher.ISLAND_SCOPE_ENTER,null));
            }
         }
         else
         {
            for each(_loc2_ in this.m_selectableRegions)
            {
               if(_loc2_.code == param1.eventData)
               {
                  this.m_currentRegion = _loc2_;
                  _loc2_.focus = true;
                  break;
               }
            }
         }
      }
      
      private function onSWFLoadComplete(param1:SWFResource) : void
      {
         var _loc2_:String = null;
         if(this.m_activated)
         {
            this.m_resource = param1;
            Sprite(displayObject).addChild(this.m_resource.clip);
            if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_CAMPV3_ENABLED) == ExperimentsManager.EXPERIMENT_CAMPV3_ENABLED_VARIANT_ENABLED)
            {
               _loc2_ = ZGlobal.player.campaign.currentCampaignName;
               if(_loc2_ == "camp003")
               {
                  this.showReward3DIcons();
                  this.m_battlePromptVersion = "v2";
               }
               else
               {
                  this.m_battlePromptVersion = null;
               }
            }
            this.m_currentBattlePrompt = new StrategicBattlePrompt(this.m_resource,this.m_battlePromptVersion);
            this.m_hoverBattlePrompt = new StrategicScopedBattlePrompt(this.m_resource,this.m_battlePromptVersion);
            this.fillIslandClips();
            this.initLines();
            this.doRequests();
            this.addUIControls();
            if(ZGlobal.player.campaign.isMasteryEnabled)
            {
               this.addCampaignMasteryIcons();
            }
            if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_CAMPV2_ENABLED) == ExperimentsManager.EXPERIMENT_CAMPV2_ENABLED_VARIANT_ENABLED)
            {
               if(ZGlobal.player.campaign.currentCampaignName == "camp002")
               {
                  this.setupCampaignV2Map();
               }
            }
            this.m_borders = new FullScreenHorizontalBorders(this.m_resource.clip,this.HEIGHT);
            this.reposition(this.isFullScreen);
            if(TutorialManager.instance.active)
            {
               TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.STRAT_MAP_LOADED));
            }
            this.m_loading = false;
         }
      }
      
      private function setupCampaignV2Map() : void
      {
         var _loc1_:int = 0;
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_CAMPAIGN_2_5) < ExperimentsManager.EXPERIMENT_CAMPAIGN_2_5_ENABLED_VARIANT)
         {
            _loc1_ = ZGlobal.player.campaign.getIslandMastery("D015");
            if(_loc1_ >= 1)
            {
               this.m_resource.clip.comingSoon_mc.visible = true;
               TextFieldUtil.processTextField(this.m_resource.clip.comingSoon_mc.title_tf,ZGameUtils.ZlocT("Campaign","CampaignBannerTitle"));
               TextFieldUtil.processTextField(this.m_resource.clip.comingSoon_mc.name_tf,ZGameUtils.ZlocT("Campaign","CampaignBannerBody"));
            }
            else
            {
               this.m_resource.clip.comingSoon_mc.visible = false;
            }
         }
         else
         {
            this.m_resource.clip.comingSoon_mc.visible = false;
            this.m_resource.clip.lock0.visible = false;
            this.m_resource.clip.lock1.visible = false;
            this.m_resource.clip.lock2.visible = false;
            this.m_resource.clip.lock3.visible = false;
         }
      }
      
      private function showReward3DIcons() : void
      {
         var _loc1_:ZGameButton = null;
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_CAMPAIGN_3) == ExperimentsManager.EXPERIMENT_CAMPAIGN_3_ENABLED_VARIANT)
         {
            this.m_resource.clip.comingSoon_mc.visible = false;
            this.m_resource.clip.rewardZone_mc.visible = false;
            _loc1_ = new ZGameButton(this.m_resource.clip.rewardZone_mc.reward1_bt,this.onShowReward3D);
         }
      }
      
      protected function onShowReward3D(param1:MouseEvent) : void
      {
      }
      
      private function addUIControls() : void
      {
      }
      
      private function addCampaignMasteryIcons() : void
      {
         var _loc2_:Class = null;
         var _loc3_:String = null;
         var _loc4_:MovieClip = null;
         var _loc5_:int = 0;
         var _loc1_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_CAMPAIGN_MASTERY);
         if(_loc1_ == ZGlobal.EXPERIMENT_CAMPAIGN_MASTERY_ENABLED)
         {
            _loc2_ = this.m_resource.getAssetClass("Mastery_mc");
            for(_loc3_ in this.m_regions)
            {
               if(this.m_regions[_loc3_].anchor_mc_mastery != null)
               {
                  _loc4_ = new _loc2_();
                  _loc5_ = ZGlobal.player.campaign.getIslandMastery(_loc3_);
                  if(_loc5_ == 1)
                  {
                     _loc4_.icon_0.visible = true;
                     _loc4_.icon_1.visible = false;
                     _loc4_.icon_2.visible = false;
                  }
                  else if(_loc5_ == 2)
                  {
                     _loc4_.icon_0.visible = false;
                     _loc4_.icon_1.visible = true;
                     _loc4_.icon_2.visible = false;
                  }
                  else if(_loc5_ == 3)
                  {
                     _loc4_.icon_0.visible = false;
                     _loc4_.icon_1.visible = false;
                     _loc4_.icon_2.visible = true;
                  }
                  if(_loc5_ > 0)
                  {
                     this.m_regions[_loc3_].anchor_mc_mastery.addChild(_loc4_);
                     Tooltip.subscribe(this.m_regions[_loc3_].anchor_mc_mastery,ZGameUtils.ZlocT("Dialogs","VillainTokenIslandTooltip"));
                  }
               }
            }
         }
      }
      
      private function initNavButtons() : void
      {
         var _loc1_:String = null;
         if(this.m_navControl)
         {
            _loc1_ = ZGlobal.player.campaign.currentCampaignName;
            if(CampaignManager.instance.prevEligibleCampaign(_loc1_))
            {
               this.m_navControl.prev_bt.addEventListener(MouseEvent.CLICK,this.onPrevClick);
            }
            else
            {
               ZGameUtils.disableButton(this.m_navControl.prev_bt,this.onPrevClick);
            }
            if(CampaignManager.instance.nextEligibleCampaign(_loc1_))
            {
               this.m_navControl.next_bt.addEventListener(MouseEvent.CLICK,this.onNextClick);
            }
            else
            {
               ZGameUtils.disableButton(this.m_navControl.next_bt,this.onNextClick);
            }
         }
      }
      
      private function deInitNavButtons() : void
      {
         if(this.m_navControl)
         {
            this.m_navControl.prev_bt.removeEventListener(MouseEvent.CLICK,this.onPrevClick);
            this.m_navControl.next_bt.removeEventListener(MouseEvent.CLICK,this.onNextClick);
         }
      }
      
      private function onPrevClick(param1:MouseEvent) : void
      {
         StrategicDispatcher.instance.dispatchEvent(new Event(StrategicDispatcher.LEFT));
      }
      
      private function onNextClick(param1:MouseEvent) : void
      {
         StrategicDispatcher.instance.dispatchEvent(new Event(StrategicDispatcher.RIGHT));
      }
      
      private function doRequests() : void
      {
         var _loc1_:Object = null;
         for each(_loc1_ in this.m_clipRequests)
         {
            _loc1_.func(this.getRegionClip(_loc1_.islandGroupItem));
         }
         this.m_clipRequests = null;
      }
      
      private function fillIslandClips() : void
      {
         var _loc4_:MovieClip = null;
         var _loc5_:IslandGroupItem = null;
         var _loc6_:Boolean = false;
         this.m_regions = new Dictionary();
         this.m_islands = new Dictionary();
         var _loc1_:uint = uint(this.m_resource.clip.numChildren);
         var _loc2_:uint = 0;
         while(_loc2_ < _loc1_)
         {
            _loc4_ = this.m_resource.clip.getChildAt(_loc2_) as MovieClip;
            this.addRegions(_loc4_);
            _loc2_++;
         }
         var _loc3_:String = ZGlobal.player.campaign.currentMapName;
         if(this.m_regions[_loc3_])
         {
            _loc5_ = ZGlobal.gameSettings.getItemByCode(_loc3_,IslandGroupItem) as IslandGroupItem;
            if(!_loc5_ || !_loc5_.uilocked)
            {
               _loc6_ = ZGlobal.player.campaign.isHomeIslandGroup(_loc3_);
               this.m_currentBattlePrompt.setTarget(this.m_regions[_loc3_],_loc3_,_loc6_);
               this.centreCurrentRegion();
            }
         }
      }
      
      private function initLines() : void
      {
         var _loc1_:String = null;
         var _loc2_:IslandGroupItem = null;
         var _loc3_:String = null;
         var _loc4_:Boolean = false;
         for(_loc1_ in this.m_islands)
         {
            _loc2_ = ZGlobal.gameSettings.getItemByCode(_loc1_,IslandGroupItem) as IslandGroupItem;
            if(null != _loc2_)
            {
               _loc3_ = _loc2_.unlocks;
               if(_loc3_)
               {
                  if(null != this.m_islands[_loc1_].dottedLine && null != this.m_islands[_loc1_].solidLine)
                  {
                     _loc4_ = ZGlobal.player.campaign.isMapLocked(_loc3_);
                     this.m_islands[_loc1_].dottedLine.visible = _loc4_;
                     this.m_islands[_loc1_].solidLine.visible = !_loc4_;
                  }
               }
            }
         }
      }
      
      private function centreCurrentRegion() : void
      {
         var _loc1_:Number = NaN;
         if(!this.isFullScreen)
         {
            _loc1_ = -this.m_regions[ZGlobal.player.campaign.currentMapName].parent.x;
            _loc1_ += Zlab.mainStage.stageWidth * 0.5;
            this.panTo(_loc1_,2);
         }
      }
      
      private function addRegions(param1:MovieClip) : void
      {
         var _loc6_:MovieClip = null;
         var _loc7_:String = null;
         var _loc8_:uint = 0;
         var _loc9_:String = null;
         var _loc2_:String = param1.name;
         var _loc3_:Array = _loc2_.split("_");
         var _loc4_:uint = uint(param1.numChildren);
         var _loc5_:uint = 0;
         while(_loc5_ < _loc4_)
         {
            _loc6_ = param1.getChildAt(_loc5_) as MovieClip;
            if(null != _loc6_)
            {
               _loc7_ = _loc6_.name;
               if(_loc7_.indexOf(this.REGION_NAME) == 0)
               {
                  param1.mouseEnabled = false;
                  _loc8_ = parseInt(_loc7_.substr(6));
                  _loc9_ = _loc3_[_loc8_ - 1];
                  this.m_regions[_loc9_] = _loc6_;
                  this.m_islands[_loc9_] = param1;
               }
            }
            _loc5_++;
         }
      }
      
      private function getRegionClip(param1:IslandGroupItem) : MovieClip
      {
         var _loc2_:String = param1.code;
         return this.m_regions[_loc2_];
      }
      
      private function onFullScreen(param1:FullScreenEvent) : void
      {
         this.reposition(param1.fullScreen);
      }
      
      private function onReposition(param1:Event) : void
      {
         this.reposition(this.isFullScreen);
      }
      
      private function get isFullScreen() : Boolean
      {
         var _loc1_:uint = 1280;
         var _loc2_:uint = 800;
         return Zlab.mainStage.stageHeight > _loc2_ && Zlab.mainStage.stageWidth > _loc1_;
      }
      
      private function reposition(param1:Boolean) : void
      {
         this.m_fullScreen = param1;
         this.m_ratio = 1;
         if(this.m_resource)
         {
            if(this.m_fullScreen)
            {
               this.stopTween();
               this.m_ratio = Zlab.mainStage.stageWidth / WIDTH;
               this.m_resource.clip.x = 0;
               this.m_resource.clip.scaleX = this.m_resource.clip.scaleY = this.m_ratio;
               this.m_resource.clip.y = Zlab.mainStage.stageHeight * 0.5;
               this.m_resource.clip.y -= this.HEIGHT * this.m_ratio * 0.5;
               this.m_uIOffset.x = this.m_resource.clip.x;
               this.m_uIOffset.y = this.m_resource.clip.y;
               if(null != this.m_borders)
               {
                  this.m_borders.scale = 1 / this.m_ratio;
                  this.m_borders.addBorders();
               }
               if(this.m_navControl)
               {
                  this.m_navControl.x = Zlab.mainStage.stageWidth * 0.5;
                  this.m_navControl.y = Zlab.mainStage.stageHeight * 0.5;
                  this.m_navControl.y += this.HEIGHT * this.m_ratio * 0.5;
                  this.m_navControl.y -= this.NAV_WIDGET_BORDER;
               }
            }
            else
            {
               if(!ZGlobal.player.getSeenFlag(this.INITIAL_PAN))
               {
                  this.m_resource.clip.x = -(WIDTH - Zlab.mainStage.stageWidth);
                  ZGlobal.player.setSeenFlag(this.INITIAL_PAN);
               }
               this.m_resource.clip.y = 0;
               this.m_resource.clip.scaleX = this.m_resource.clip.scaleY = Zlab.mainStage.stageHeight / this.HEIGHT;
               this.m_uIOffset.x = 0;
               this.m_uIOffset.y = 0;
               if(null != this.m_borders)
               {
                  this.m_borders.removeBorders();
               }
               this.centreCurrentRegion();
               if(this.m_navControl)
               {
                  this.m_navControl.x = Zlab.mainStage.stageWidth * 0.5;
                  this.m_navControl.y = Zlab.mainStage.stageHeight - this.NAV_WIDGET_BORDER;
               }
            }
         }
         this.updateUIOffset(false);
      }
      
      private function updateUIOffset(param1:Boolean) : void
      {
         if(param1)
         {
            UIDispatcher.instance.dispatchEvent(new RepositionEvent(UIDispatcher.UI_HEIGHT_OFFSET,0,0));
         }
         else if(null != this.m_borders)
         {
            UIDispatcher.instance.dispatchEvent(new RepositionEvent(UIDispatcher.UI_HEIGHT_OFFSET,this.m_uIOffset.x,this.m_uIOffset.y));
         }
      }
   }
}

