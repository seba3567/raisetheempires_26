package core.worlds.strategicWorld.swf.version2
{
   import as3isolib.geom.Pt;
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.IslandGroupItem;
   import core.gameobjects.IslandItem;
   import core.gameobjects.UnitItem;
   import core.managers.tutorialManager.TutorialManager;
   import core.player.Player;
   import core.ui.FloatingText;
   import core.ui.Tooltip;
   import core.ui.ZGameButton;
   import core.worlds.strategicWorld.StrategicIslandDataComponent;
   import core.worlds.strategicWorld.StrategicMap;
   import dispatchers.StrategicDispatcher;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.HudsonPopup;
   import displays.popups.battleSelect.BattleSelectPopup;
   import fl.containers.UILoader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import sound.SoundEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class StrategicBattlePrompt
   {
      
      protected const SIDE_NONE:uint = 0;
      
      protected const SIDE_LEFT:uint = 1;
      
      protected const SIDE_RIGHT:uint = 2;
      
      private var m_clip:MovieClip = null;
      
      private var m_data:StrategicIslandDataComponent = null;
      
      private var m_islandGroupItem:IslandGroupItem = null;
      
      private var m_imageLoaders:Array = null;
      
      private var m_buttons:Array = null;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private var m_map:StrategicMap = null;
      
      private var m_side:uint = 0;
      
      private var m_xPosition:Number = 0;
      
      private var m_yPosition:Number = 0;
      
      private var m_currentUrl:String = null;
      
      private var m_showing:Boolean = false;
      
      private var m_mapLocked:Boolean = false;
      
      private var m_faded:Boolean = false;
      
      private var m_tutorialMode:Boolean = false;
      
      private var m_high:Boolean = false;
      
      private var m_parentMc:MovieClip = null;
      
      public function StrategicBattlePrompt(param1:SWFResource, param2:String = null)
      {
         super();
         switch(param2)
         {
            case "v2":
               this.m_clip = new BattlePromptV2();
               break;
            default:
               this.m_clip = new BattlePrompt();
         }
         this.m_clip.mouseEnabled = false;
         param1.clip.addChild(this.m_clip);
         this.m_clip.panel.villain.addEventListener(MouseEvent.CLICK,this.onClick,false,100);
         this.m_clip.panel.villain.addEventListener(MouseEvent.MOUSE_DOWN,this.onConsumeEvent,false,100);
         this.m_clip.panel.villain.addEventListener(MouseEvent.MOUSE_MOVE,this.onConsumeEvent,false,100);
         this.m_clip.panel.villain.addEventListener(MouseEvent.MOUSE_UP,this.onConsumeEvent,false,100);
         StrategicDispatcher.instance.addEventListener(StrategicDispatcher.ISLAND_CLICKED,this.onIslandClicked);
         StrategicDispatcher.instance.addEventListener(StrategicDispatcher.ISLAND_SCOPE_ENTER,this.onScopedEnter);
         StrategicDispatcher.instance.addEventListener(StrategicDispatcher.ISLAND_FORCE_EXIT,this.onForceExit);
         UIDispatcher.instance.addEventListener(Player.QUEST_LABELS_UPDATED,this.onQuestLabelsUpdated);
         TextFieldUtil.processTextField(this.m_clip.panel.menu.progbar_mc.title1_tf,ZGameUtils.ZlocT("Dialogs","BattleSelect_BattleTitle"));
         TextFieldUtil.processTextField(this.m_clip.panel.menu.progbar_mc.title2_tf,ZGameUtils.ZlocT("Dialogs","BattleSelect_UnitsNeeded"));
         TextFieldUtil.processTextField(this.m_clip.panel.menu.complete_dialog.title_tf,ZGameUtils.ZlocT("Dialogs","BattleSelect_BattlesCompleted"));
         TextFieldUtil.processTextField(this.m_clip.panel.menu.progbar_mc.vs_tf,ZGameUtils.ZlocT("Dialogs","BattleSelect_Vs"));
         this.m_imageLoaders = new Array();
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         if(TutorialManager.instance.active)
         {
            TutorialManager.instance.addEventListener(TutorialManager.UI_HIGHLIGHT_STRATMAP_VILLAIN,this.onHighlight);
         }
         this.m_showing = true;
         this.hidePanel();
      }
      
      public function dispose() : void
      {
         var _loc1_:ImageLoader = null;
         TweenLite.killTweensOf(this.m_clip);
         Tooltip.unsubscribe(this.m_clip.panel.menu.progbar_mc.icon1);
         Tooltip.unsubscribe(this.m_clip.panel.menu.progbar_mc.icon2);
         this.m_clip.parent.removeChild(this.m_clip);
         this.m_clip.panel.villain.removeEventListener(MouseEvent.CLICK,this.onClick);
         this.m_clip.panel.removeEventListener(MouseEvent.CLICK,this.onPanelClick);
         this.m_clip.panel.villain.removeEventListener(MouseEvent.MOUSE_DOWN,this.onConsumeEvent);
         this.m_clip.panel.villain.removeEventListener(MouseEvent.MOUSE_MOVE,this.onConsumeEvent);
         this.m_clip.panel.villain.removeEventListener(MouseEvent.MOUSE_UP,this.onConsumeEvent);
         StrategicDispatcher.instance.removeEventListener(StrategicDispatcher.ISLAND_CLICKED,this.onIslandClicked);
         StrategicDispatcher.instance.removeEventListener(StrategicDispatcher.ISLAND_SCOPE_ENTER,this.onScopedEnter);
         StrategicDispatcher.instance.removeEventListener(StrategicDispatcher.ISLAND_FORCE_EXIT,this.onForceExit);
         UIDispatcher.instance.removeEventListener(Player.QUEST_LABELS_UPDATED,this.onQuestLabelsUpdated);
         this.disposeButtons();
         for each(_loc1_ in this.m_imageLoaders)
         {
            _loc1_.destroy();
         }
         this.m_imageLoaders = null;
         this.m_map = null;
         this.m_islandGroupItem = null;
         this.m_parentMc = null;
         this.m_clip = null;
         this.m_data = null;
      }
      
      public function setTarget(param1:MovieClip, param2:String, param3:Boolean = false) : void
      {
         var _loc7_:ImageLoader = null;
         var _loc8_:String = null;
         this.m_map = ZGlobal.player.campaign.getMap(param2);
         this.m_tutorialMode = param3;
         if(null != param1)
         {
            this.m_parentMc = param1;
            this.m_clip.x = param1.parent.x + param1.x;
            this.m_clip.y = param1.parent.y + param1.y;
            if(param1.anchor_mc)
            {
               this.m_clip.x += param1.anchor_mc.x;
               this.m_clip.y += param1.anchor_mc.y;
            }
            else
            {
               Logger.error(this,"setTarget",param1.name + " missing anchor_mc");
            }
            this.m_xPosition = this.m_clip.x;
            this.m_yPosition = this.m_clip.y;
            this.setSide(this.m_clip);
            this.adjustPositionForSide();
            this.setDirectionArrows();
         }
         this.m_islandGroupItem = ZGlobal.gameSettings.getItemByCode(param2,IslandGroupItem) as IslandGroupItem;
         var _loc4_:Boolean = this.m_map.inReplay;
         var _loc5_:int = _loc4_ ? this.m_map.replayIsland : this.m_map.progressIsland;
         if(_loc5_ > this.m_map.numIslands)
         {
            _loc5_ = this.m_map.numIslands;
         }
         this.m_data = new StrategicIslandDataComponent(this.m_islandGroupItem.getIslandItem(_loc5_));
         TextFieldUtil.processTextField(this.m_clip.panel.menu.title.title0_tf,this.m_islandGroupItem.getMapName(!this.m_tutorialMode));
         this.reCreateButtons();
         this.m_clip.pick.visible = this.pickVisible;
         if(ZGlobal.player.campaign.isMapLocked(this.m_islandGroupItem.code))
         {
            this.m_mapLocked = true;
            this.m_clip.panel.numeral.visible = false;
            this.showVillainPick();
         }
         else
         {
            this.m_mapLocked = false;
            this.m_clip.panel.numeral.visible = true;
            this.m_clip.panel.numeral.mouseEnabled = false;
            this.m_clip.panel.numeral.mouseChildren = false;
            TextFieldUtil.processTextField(this.m_clip.panel.numeral.numeral_tf,this.m_islandGroupItem.getMapNumber());
            if(param3 || !_loc4_ && this.m_map.progressIsland >= this.m_map.numIslands)
            {
               this.m_clip.panel.menu.progbar_mc.visible = false;
               this.m_clip.panel.menu.complete_dialog.visible = true;
               this.m_buttons[0].hide();
               this.m_buttons[0].disable();
               this.m_buttons[1].hide();
               this.m_buttons[1].disable();
               if(ZGlobal.player.campaign.isMasteryEnabled)
               {
                  this.m_buttons[2].show();
                  this.m_buttons[2].enable();
               }
               else
               {
                  this.m_buttons[2].hide();
                  this.m_buttons[2].disable();
               }
            }
            else
            {
               this.m_clip.panel.menu.progbar_mc.visible = true;
               this.m_clip.panel.menu.complete_dialog.visible = false;
               this.setProgress(_loc5_);
               this.m_buttons[0].show();
               this.m_buttons[0].enable();
               if(ZGlobal.player.campaign.isMasteryEnabled)
               {
                  this.m_buttons[1].show();
                  this.m_buttons[1].enable();
               }
               else
               {
                  this.m_buttons[1].hide();
                  this.m_buttons[1].disable();
               }
               this.m_buttons[2].hide();
               this.m_buttons[2].disable();
            }
            if(_loc4_)
            {
               this.showPanel();
            }
            else if(_loc5_ >= this.m_map.numIslands || this.m_data.isDone())
            {
               this.m_clip.visible = false;
            }
            else if(!param3)
            {
               this.showVillainPick();
            }
         }
         var _loc6_:String = this.pickImageUrl;
         if(_loc6_ != this.m_currentUrl)
         {
            this.m_currentUrl = _loc6_;
            this.m_clip.panel.villain.icon.unload();
            _loc7_ = ImageLoaderFactory.CreateImageLoader(_loc6_,this.m_clip.panel.villain.icon);
            _loc7_.smooth = true;
            this.m_imageLoaders.push(_loc7_);
         }
         if(param3)
         {
            if(null == this.m_clip.pick.icon.source)
            {
               _loc7_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.player.snUser.picture,this.m_clip.pick.icon);
               _loc7_.smooth = true;
               this.m_imageLoaders.push(_loc7_);
               _loc8_ = this.m_islandGroupItem.getMapName(false);
               TextFieldUtil.processTextField(this.m_clip.pick.menu.title0_tf,_loc8_);
               TextFieldUtil.processTextField(this.m_clip.pick.generic_tf,ZGlobal.player.snUser.firstName);
               this.m_buttons[3].text = ZGameUtils.ZlocT("Dialogs","BattleSelect_ReturnHome");
               TextFieldUtil.processTextField(this.m_clip.panel.menu.title.title0_tf,_loc8_);
            }
         }
         else if(this.m_map.inProgress || this.m_map.inReplay)
         {
            this.m_buttons[0].text = ZGameUtils.ZlocT("Dialogs","BattleSelect_Continue");
         }
         else
         {
            this.m_buttons[0].text = ZGameUtils.ZlocT("Dialogs","BattleSelect_FightNow");
         }
      }
      
      public function get blockingInput() : Boolean
      {
         return this.m_showing;
      }
      
      public function updateSide() : void
      {
         var _loc1_:uint = 0;
         if(this.m_high)
         {
            _loc1_ = this.calculateSide();
            if(_loc1_ != this.m_side)
            {
               if(this.m_showing)
               {
                  this.hidePanel();
               }
               this.setTarget(this.m_parentMc,this.m_islandGroupItem.code,this.m_tutorialMode);
            }
         }
      }
      
      protected function get clip() : MovieClip
      {
         return this.m_clip;
      }
      
      protected function get side() : uint
      {
         return this.m_side;
      }
      
      protected function get pickVisible() : Boolean
      {
         return false;
      }
      
      protected function get pickImageUrl() : String
      {
         var _loc1_:String = this.m_islandGroupItem.villain;
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByCode(_loc1_,GameItem) as GameItem;
         return _loc2_.getCachedImage(this.pickName).url;
      }
      
      protected function get pickName() : String
      {
         if(this.m_mapLocked)
         {
            return "pickDark";
         }
         return "pick";
      }
      
      protected function onIslandClicked(param1:WorldEvent) : void
      {
         if(Boolean(this.m_islandGroupItem) && param1.eventData == this.m_islandGroupItem.code)
         {
            this.onClick(null);
         }
      }
      
      protected function onScopedEnter(param1:WorldEvent) : void
      {
         this.m_faded = null != param1.eventData;
         TweenLite.to(this.m_clip,0.3,{"alpha":(this.m_faded ? 0.4 : 1)});
      }
      
      private function onForceExit(param1:Event) : void
      {
         this.onExit(null);
      }
      
      private function onQuestLabelsUpdated(param1:Event) : void
      {
         if(this.m_mapLocked)
         {
            if(!ZGlobal.player.campaign.isMapLocked(this.m_islandGroupItem.code))
            {
               this.setTarget(null,this.m_islandGroupItem.code,this.m_tutorialMode);
               StrategicDispatcher.instance.dispatchEvent(new Event(StrategicDispatcher.QUEST_LOCKING_UPDATED));
            }
         }
      }
      
      protected function adjustPositionForSide() : void
      {
         if(this.side == this.SIDE_LEFT)
         {
            this.m_clip.x = this.m_xPosition + 19.85;
         }
         else if(this.side == this.SIDE_RIGHT)
         {
            this.m_clip.x = this.m_xPosition - 18.4;
         }
      }
      
      protected function showVillainPick() : void
      {
         if(this.side == this.SIDE_LEFT)
         {
            this.m_clip.gotoAndStop(9);
         }
         else
         {
            this.m_clip.gotoAndStop(27);
         }
      }
      
      private function setDirectionArrows() : void
      {
         var _loc1_:Number = NaN;
         this.m_clip.pick.arrow_lt.visible = false;
         this.m_clip.pick.arrow_rt.visible = false;
         this.m_clip.pick.arrow_dn.visible = false;
         this.m_clip.panel.arrow_lt.visible = false;
         this.m_clip.panel.arrow_rt.visible = false;
         this.m_clip.panel.arrow_dn.visible = false;
         this.m_high = false;
         if(this.m_yPosition < 170)
         {
            this.m_high = true;
            this.m_clip.y = this.m_yPosition + this.m_clip.pick.height * 0.6;
            _loc1_ = 60;
            if(this.m_side == this.SIDE_LEFT)
            {
               this.m_clip.x = this.m_xPosition - _loc1_;
               this.m_clip.pick.arrow_rt.visible = true;
               this.m_clip.panel.arrow_rt.visible = true;
            }
            else
            {
               this.m_clip.x = this.m_xPosition + _loc1_;
               this.m_clip.pick.arrow_lt.visible = true;
               this.m_clip.panel.arrow_lt.visible = true;
            }
         }
         else
         {
            this.m_clip.pick.arrow_dn.visible = true;
            this.m_clip.panel.arrow_dn.visible = true;
         }
      }
      
      private function setProgress(param1:uint) : void
      {
         var _loc2_:int = this.m_islandGroupItem.numIslands;
         var _loc3_:int = this.m_islandGroupItem.getMaxUnits(param1);
         var _loc4_:String = this.m_islandGroupItem.getPlayerType(param1);
         var _loc5_:IslandItem = this.m_islandGroupItem.getIslandItem(param1);
         var _loc6_:Array = _loc5_.getUnits();
         var _loc7_:uint = _loc6_.length;
         var _loc8_:UnitItem = ZGlobal.gameSettings.getItemByCode(_loc6_[0],UnitItem) as UnitItem;
         var _loc9_:MovieClip = this.m_clip.panel.menu.progbar_mc;
         _loc9_.num_tf1.mouseEnabled = false;
         _loc9_.num_tf2.mouseEnabled = false;
         TextFieldUtil.processTextField(_loc9_.num_tf1,ZGameUtils.ZlocT("Dialogs","BattleSelect_BattleUnitCount",{"amount":_loc3_}));
         TextFieldUtil.processTextField(_loc9_.num_tf2,ZGameUtils.ZlocT("Dialogs","BattleSelect_BattleUnitCount",{"amount":_loc7_}));
         TextFieldUtil.processTextField(_loc9_.currentBattle_tf,(param1 + 1).toString());
         TextFieldUtil.processTextField(_loc9_.totalBattles_tf,ZGameUtils.ZlocT("Dialogs","BattleSelect_BattleMapCount",{"amount":_loc2_}));
         this.setupTheatre(_loc4_,true,_loc3_,_loc9_.icon1,_loc9_.unitType_tf1);
         this.setupTheatre(_loc8_.subType,false,_loc7_,_loc9_.icon2,_loc9_.unitType_tf2);
      }
      
      private function setupTheatre(param1:String, param2:Boolean, param3:uint, param4:UILoader, param5:TextField) : void
      {
         var _loc6_:String = null;
         var _loc7_:String = null;
         if(param1 == UnitItem.AIR)
         {
            _loc6_ = "assets/game/GeneralAssetGroup_UI.swf/UnitTypeIcon_Air.png";
            _loc7_ = ZGameUtils.ZlocT("Dialogs","BattleSelect_AirType");
         }
         else if(param1 == UnitItem.ARMY)
         {
            _loc6_ = "assets/game/GeneralAssetGroup_UI.swf/UnitTypeIcon_land.png";
            _loc7_ = ZGameUtils.ZlocT("Dialogs","BattleSelect_LandType");
         }
         else if(param1 == UnitItem.NAVY)
         {
            _loc6_ = "assets/game/GeneralAssetGroup_UI.swf/UnitTypeIcon_Sea.png";
            _loc7_ = ZGameUtils.ZlocT("Dialogs","BattleSelect_NavyType");
         }
         var _loc8_:ImageLoader = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(_loc6_),param4);
         var _loc9_:String = null;
         _loc8_.reverse = !param2;
         this.m_imageLoaders.push(_loc8_);
         Tooltip.unsubscribe(param4);
         if(param2)
         {
            _loc9_ = "BattleSelect_UnitTypesRequired";
         }
         else
         {
            _loc9_ = "BattleSelect_UnitTypesCombating";
         }
         if(param3 == 1)
         {
            _loc9_ += "Single";
         }
         Tooltip.subscribe(param4,ZGameUtils.ZlocT("Dialogs",_loc9_,{
            "amount":param3,
            "type":_loc7_
         }));
         TextFieldUtil.compactTextField(param5,_loc7_,{
            "maxLines":1,
            "minScale":0.5,
            "onFail":"return"
         });
      }
      
      private function calculateSide() : uint
      {
         var _loc1_:int = this.clip.parent.x;
         if(this.m_xPosition + _loc1_ < Zlab.mainStage.stageWidth * 0.5)
         {
            return this.SIDE_RIGHT;
         }
         return this.SIDE_LEFT;
      }
      
      private function setSide(param1:MovieClip) : void
      {
         this.m_clip.panel.menu.exit_bt1.removeEventListener(MouseEvent.CLICK,this.onExit);
         this.m_clip.panel.menu.exit_bt2.removeEventListener(MouseEvent.CLICK,this.onExit);
         this.m_clip.panel.menu.exit_bt1.visible = false;
         this.m_clip.panel.menu.exit_bt2.visible = false;
         this.m_side = this.calculateSide();
         this.addExitButton();
      }
      
      private function addExitButton() : void
      {
         if(this.m_side == this.SIDE_RIGHT)
         {
            this.m_clip.panel.menu.exit_bt2.visible = true;
            this.m_clip.panel.menu.exit_bt2.addEventListener(MouseEvent.CLICK,this.onExit);
         }
         else
         {
            this.m_clip.panel.menu.exit_bt1.visible = true;
            this.m_clip.panel.menu.exit_bt1.addEventListener(MouseEvent.CLICK,this.onExit);
         }
      }
      
      private function reCreateButtons() : void
      {
         this.disposeButtons();
         this.m_buttons = new Array(3);
         this.m_buttons[0] = new ZGameButton(this.m_clip.panel.menu.greenButton,this.onFight);
         this.m_buttons[1] = new ZGameButton(this.m_clip.panel.menu.orangeButton1,this.onInfo);
         this.m_buttons[2] = new ZGameButton(this.m_clip.panel.menu.orangeButton2,this.onInfo);
         this.m_buttons[3] = new ZGameButton(this.m_clip.pick.menu.home,this.onInfo);
         this.m_buttons[1].text = ZGameUtils.ZlocT("Dialogs","BattleSelect_Info");
         this.m_buttons[2].text = ZGameUtils.ZlocT("Dialogs","BattleSelect_Battles");
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_buttonSounds.addButton(this.m_buttons[0].m_overlay,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.m_buttons[1].m_overlay,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.m_buttons[2].m_overlay,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.m_buttons[3].m_overlay,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.m_clip.panel.menu.exit_bt1,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.m_clip.panel.menu.exit_bt2,ButtonSound.DEFAULT);
      }
      
      private function disposeButtons() : void
      {
         var _loc1_:ZGameButton = null;
         this.m_buttonSounds.release();
         this.m_buttonSounds = null;
         for each(_loc1_ in this.m_buttons)
         {
            _loc1_.dispose();
         }
         this.m_buttons = null;
         this.m_clip.panel.menu.exit_bt1.removeEventListener(MouseEvent.CLICK,this.onExit);
         this.m_clip.panel.menu.exit_bt2.removeEventListener(MouseEvent.CLICK,this.onExit);
      }
      
      private function onFight(param1:MouseEvent) : void
      {
         if(this.m_showing)
         {
            ZGlobal.player.campaign.currentMapName = this.m_data.islandItem.map;
            this.m_data.click();
         }
      }
      
      private function onInfo(param1:MouseEvent) : void
      {
         var _loc2_:BattleSelectPopup = null;
         if(this.m_showing)
         {
            if(this.m_tutorialMode)
            {
               StrategicDispatcher.instance.dispatchEvent(new Event(StrategicDispatcher.TOGGLE));
            }
            else
            {
               _loc2_ = new BattleSelectPopup(this.m_islandGroupItem);
               WindowManager.instance.push(_loc2_);
            }
         }
      }
      
      protected function onExit(param1:MouseEvent) : void
      {
         if(this.m_showing)
         {
            if(null != param1)
            {
               param1.stopImmediatePropagation();
               param1.stopPropagation();
            }
            this.hidePanel();
            StrategicDispatcher.instance.dispatchEvent(new Event(StrategicDispatcher.ISLAND_EXIT));
         }
      }
      
      protected function onConsumeEvent(param1:MouseEvent) : void
      {
         param1.stopImmediatePropagation();
         param1.stopPropagation();
         StrategicDispatcher.instance.dispatchEvent(new WorldEvent(StrategicDispatcher.PICK_FOCUS,this.m_islandGroupItem.code));
      }
      
      protected function onClick(param1:MouseEvent) : void
      {
         if(!this.m_faded)
         {
            if(this.m_mapLocked)
            {
               if(this.m_islandGroupItem.questLocked)
               {
                  PopupManager.instance.push(new HudsonPopup(this.m_islandGroupItem.questLockedString,ZGameUtils.ZlocT("Campaign","Campaign_IslandLockedQuestPopupTitle")));
               }
               else
               {
                  this.floatingText(ZGameUtils.ZlocT("Main","Error_LockedIsland"));
               }
            }
            else if(!this.m_showing)
            {
               this.showPanel();
               StrategicDispatcher.instance.dispatchEvent(new Event(StrategicDispatcher.ISLAND_SELECTED));
            }
            if(param1)
            {
               param1.stopPropagation();
               param1.stopImmediatePropagation();
            }
         }
      }
      
      protected function floatingText(param1:String) : void
      {
         var _loc2_:FloatingText = new FloatingText(this.m_clip.parent);
         _loc2_.useWorldZoom = false;
         _loc2_.useParentExtents = true;
         _loc2_.position = new Pt(this.m_clip.x,this.m_clip.y);
         _loc2_.text = param1;
         _loc2_.disposeOnComplete = true;
      }
      
      protected function showPanel() : void
      {
         this.setSide(this.clip);
         if(!this.m_high)
         {
            this.adjustPositionForSide();
         }
         this.m_clip.visible = true;
         if(this.m_tutorialMode)
         {
            if(!this.m_showing)
            {
               this.m_clip.pick.visible = true;
               this.m_clip.gotoAndStop(1);
               this.m_clip.pick.gotoAndPlay("_show");
               this.m_showing = true;
            }
         }
         else
         {
            if(!this.m_showing)
            {
               SoundEvent.getSoundEvent("PromptOpen").play();
               this.m_clip.panel.mouseEnabled = true;
               this.enable = true;
               this.m_clip.panel.addEventListener(MouseEvent.CLICK,this.onPanelClick);
               this.m_showing = true;
            }
            if(this.m_side == this.SIDE_LEFT)
            {
               this.playClip("_show_lt");
               this.m_clip.panel.gotoAndPlay("_showLeft");
            }
            else
            {
               this.playClip("_show_rt");
               this.m_clip.panel.gotoAndPlay("_showRight");
            }
         }
      }
      
      private function onPanelClick(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         param1.stopImmediatePropagation();
      }
      
      private function playClip(param1:String) : void
      {
         if(this.m_clip.currentLabel != param1)
         {
            this.m_clip.gotoAndPlay(param1);
         }
      }
      
      protected function get playClipShow() : Boolean
      {
         return true;
      }
      
      protected function hidePanel() : void
      {
         this.clip.panel.gotoAndStop(1);
         if(this.m_showing)
         {
            this.m_clip.panel.mouseEnabled = false;
            this.m_clip.panel.villain.mouseChildren = false;
            this.enable = false;
            this.m_clip.panel.removeEventListener(MouseEvent.CLICK,this.onPanelClick);
            this.m_clip.pick.visible = false;
            SoundEvent.getSoundEvent("PromptClose").play();
            this.m_showing = false;
         }
      }
      
      private function set enable(param1:Boolean) : void
      {
         this.m_clip.panel.menu.mouseEnabled = param1;
         this.m_clip.panel.menu.mouseChildren = param1;
         this.m_clip.panel.menu.progbar_mc.currentBattle_tf.visible = param1;
         this.m_clip.panel.menu.progbar_mc.totalBattles_tf.visible = param1;
      }
      
      private function onHighlight(param1:WorldEvent) : void
      {
         var _loc2_:Point = null;
         if(Boolean(this.m_islandGroupItem) && this.m_islandGroupItem.villain == param1.eventData)
         {
            _loc2_ = new Point(0,-110);
            TutorialManager.instance.addArrowToUIElement(this.m_clip.panel.villain,true,false,_loc2_);
         }
      }
   }
}

