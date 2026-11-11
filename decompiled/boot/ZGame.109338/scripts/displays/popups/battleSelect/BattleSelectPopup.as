package displays.popups.battleSelect
{
   import core.ZGlobal;
   import core.gamemode.battle.BattleDispatcher;
   import core.gameobjects.GameItem;
   import core.gameobjects.IslandGroupItem;
   import core.gameobjects.IslandItem;
   import core.gameobjects.ItemImage;
   import core.gameobjects.UnitItem;
   import core.managers.ExperimentsManager;
   import core.ui.Tooltip;
   import core.ui.ZGameButton;
   import core.worlds.strategicWorld.StrategicIslandDataComponent;
   import core.worlds.strategicWorld.StrategicMap;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import rendering.rendering2d.MovieController;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class BattleSelectPopup extends ZGamePopUp
   {
      
      private static var m_barWidth:Number = -1;
      
      private var m_islandGroupItem:IslandGroupItem = null;
      
      private var m_imageLoaders:Array = null;
      
      private var m_islandData:Array = null;
      
      private var m_pageButtons:Array = null;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private var m_movieController:MovieController = null;
      
      private var m_movieClip:MovieClip = null;
      
      private var m_fightButton:ZGameButton = null;
      
      private var m_currentIndex:int = 0;
      
      private var m_initialised:Boolean = false;
      
      public function BattleSelectPopup(param1:IslandGroupItem)
      {
         var _loc2_:String = null;
         var _loc3_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_CAMPAIGN_MASTERY);
         if(_loc3_ == ZGlobal.EXPERIMENT_CAMPAIGN_MASTERY_ENABLED)
         {
            _loc2_ = "PU_battleSelect2.swf";
         }
         else
         {
            _loc2_ = "PU_battleSelect.swf";
         }
         super(ZGlobal.getAssetURL("assets/displays/dialogs/" + _loc2_));
         this.m_islandGroupItem = param1;
         this.m_islandData = new Array(this.m_islandGroupItem.numIslands);
         var _loc4_:int = 0;
         while(_loc4_ < this.m_islandGroupItem.numIslands)
         {
            this.m_islandData[_loc4_] = new StrategicIslandDataComponent(this.m_islandGroupItem.getIslandItem(_loc4_));
            _loc4_++;
         }
         ZGlobal.player.campaign.currentMapName = this.m_islandGroupItem.code;
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         PopupManager.instance.notifyLoadComplete(this);
      }
      
      override public function onShow() : void
      {
         super.onShow();
         this.setupWindow();
      }
      
      private function get screen() : MovieClip
      {
         return m_window.battle_select_mc;
      }
      
      private function setupWindow() : void
      {
         if(Boolean(m_window) && !this.m_initialised)
         {
            this.m_initialised = true;
            addChild(m_window);
            this.initDialog();
            this.m_currentIndex = this.initPageButtons();
            this.loadCharacter();
            this.setText();
            this.loadMap(this.m_currentIndex);
         }
      }
      
      override protected function initDialog() : void
      {
         var _loc1_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_CAMPAIGN_MASTERY);
         if(_loc1_ == ZGlobal.EXPERIMENT_CAMPAIGN_MASTERY_ENABLED)
         {
            contentWidth = 680;
            contentHeight = 400;
            Tooltip.subscribe(this.screen.token_mc1,ZGameUtils.ZlocT("Dialogs","VillainTokenBattleSelectVillainTokenTooltip"));
            Tooltip.subscribe(this.screen.token_mc2,ZGameUtils.ZlocT("Dialogs","VillainTokenBattleSelectVillainTokenTooltip"));
            Tooltip.subscribe(this.screen.token_mc3,ZGameUtils.ZlocT("Dialogs","VillainTokenBattleSelectVillainTokenTooltip"));
         }
         else
         {
            contentWidth = 559;
            contentHeight = 434;
         }
         super.initDialog();
         this.m_imageLoaders = new Array();
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_fightButton = new ZGameButton(this.screen.orangeButton,this.onFight);
         this.screen.exit_bt.addEventListener(MouseEvent.CLICK,this.onExit);
         this.m_buttonSounds.addButton(this.screen.arrowLt_bt,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.screen.arrowRt_bt,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.screen.exit_bt,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.m_fightButton.m_overlay,ButtonSound.DEFAULT);
         Tooltip.subscribe(m_window.battle_select_mc.Token,ZGameUtils.ZlocT("Dialogs","VillainTokenBattleSelectButtonTooltip"));
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:BattleSelectButton = null;
         var _loc2_:ImageLoader = null;
         super.deinitDialog();
         this.screen.arrowLt_bt.removeEventListener(MouseEvent.CLICK,this.onLeftClick);
         this.screen.arrowRt_bt.removeEventListener(MouseEvent.CLICK,this.onRightClick);
         this.screen.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExit);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_PRE_START,this.quitAndClose);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_START,this.quitAndClose);
         this.m_buttonSounds.release();
         this.m_buttonSounds = null;
         for each(_loc1_ in this.m_pageButtons)
         {
            _loc1_.dispose();
         }
         this.m_pageButtons = null;
         for each(_loc2_ in this.m_imageLoaders)
         {
            _loc2_.destroy();
         }
         this.m_imageLoaders = null;
         if(null != this.m_movieController)
         {
            this.m_movieController.dispose();
            this.m_movieController = null;
         }
         if(null != this.m_movieClip)
         {
            this.screen.clipAnchor_mc.removeChild(this.m_movieClip);
            this.m_movieClip = null;
         }
         this.m_fightButton.dispose();
         this.m_fightButton = null;
         this.m_islandGroupItem = null;
      }
      
      private function initPageButtons() : int
      {
         var _loc14_:MovieClip = null;
         var _loc15_:BattleSelectButton = null;
         var _loc16_:IslandItem = null;
         var _loc17_:int = 0;
         var _loc18_:String = null;
         var _loc19_:ImageLoader = null;
         var _loc1_:int = 0;
         var _loc2_:MovieClip = this.screen.pageButtons.odd;
         var _loc3_:Array = [_loc2_.page1,_loc2_.page2,_loc2_.page3,_loc2_.page4,_loc2_.page5,_loc2_.page6,_loc2_.page7,_loc2_.page8,_loc2_.page9];
         var _loc4_:uint = _loc3_.length;
         var _loc5_:int = this.m_islandGroupItem.numIslands;
         this.screen.pageButtons.even.visible = false;
         this.m_pageButtons = new Array(_loc4_);
         var _loc6_:StrategicMap = ZGlobal.player.campaign.getMap(this.m_islandGroupItem.code);
         var _loc7_:Boolean = _loc6_.inReplay;
         var _loc8_:Boolean = _loc6_.inProgress;
         var _loc9_:int = _loc7_ ? _loc6_.replayIsland : _loc6_.progressIsland;
         var _loc10_:int = 0;
         var _loc11_:int = _loc4_ - _loc5_;
         var _loc12_:int = 0;
         var _loc13_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_CAMPAIGN_MASTERY);
         if(_loc13_ != ZGlobal.EXPERIMENT_CAMPAIGN_MASTERY_ENABLED)
         {
            _loc11_ = 0;
         }
         for each(_loc14_ in _loc3_)
         {
            if(_loc12_ >= _loc11_)
            {
               if(_loc10_ < _loc5_)
               {
                  _loc15_ = new BattleSelectButton(_loc3_[_loc12_],this.onPageClicked);
                  _loc15_.text = (_loc10_ + 1).toString();
                  _loc15_.show();
                  _loc15_.enable();
                  _loc15_.buttonValue = _loc10_.toString();
                  this.m_pageButtons[_loc10_] = _loc15_;
                  if(_loc13_ == ZGlobal.EXPERIMENT_CAMPAIGN_MASTERY_ENABLED)
                  {
                     _loc16_ = this.m_islandGroupItem.getIslandItem(_loc10_);
                     _loc17_ = ZGlobal.player.campaign.getCappedMastery(_loc16_.index);
                     if(_loc9_ != _loc10_)
                     {
                        if(_loc17_ > 0)
                        {
                           if(_loc17_ == 1)
                           {
                              _loc18_ = "assets/game/GeneralAssetGroup_UI.swf/Mastery_Cheveron1_32.png";
                           }
                           else if(_loc17_ == 2)
                           {
                              _loc18_ = "assets/game/GeneralAssetGroup_UI.swf/Mastery_Cheveron2_32.png";
                           }
                           else if(_loc17_ >= 3)
                           {
                              _loc18_ = "assets/game/GeneralAssetGroup_UI.swf/Mastery_Star_32.png";
                           }
                           _loc3_[_loc12_].icon.visible = true;
                           _loc19_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(_loc18_),_loc3_[_loc12_].icon);
                           _loc19_.smooth = true;
                           this.m_imageLoaders.push(_loc19_);
                        }
                     }
                     else
                     {
                        _loc3_[_loc12_].icon.visible = false;
                     }
                     Tooltip.subscribe(_loc15_.hit,ZGameUtils.ZlocT("Dialogs","VillainTokenBattleSelectButtonTooltip"));
                  }
                  this.m_buttonSounds.addButton(_loc15_.m_overlay,ButtonSound.DEFAULT);
                  if(_loc9_ == _loc10_)
                  {
                     _loc1_ = _loc10_;
                     _loc15_.current = _loc7_ || _loc8_;
                     _loc15_.ready = true;
                  }
                  else if(this.m_islandData[_loc10_].isLocked())
                  {
                     _loc15_.locked = true;
                  }
                  else if(_loc17_ >= 3)
                  {
                     if(_loc13_ == ZGlobal.EXPERIMENT_CAMPAIGN_MASTERY_ENABLED)
                     {
                        _loc15_.completed = true;
                     }
                  }
               }
               else
               {
                  _loc3_[_loc12_].visible = false;
               }
               _loc10_++;
            }
            else
            {
               _loc3_[_loc12_].visible = false;
            }
            _loc12_++;
         }
         if(_loc13_ == ZGlobal.EXPERIMENT_CAMPAIGN_MASTERY_ENABLED)
         {
            this.setVillainTokens();
         }
         return _loc1_;
      }
      
      private function loadCharacter() : void
      {
         var _loc3_:ItemImage = null;
         var _loc4_:String = null;
         var _loc1_:String = this.m_islandGroupItem.villain;
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByCode(_loc1_,GameItem) as GameItem;
         if(null != _loc2_)
         {
            TextFieldUtil.processTextField(this.screen.name_tf,_loc2_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
            this.screen.name_tf.y = this.screen.villainTextAnchor_mc.y - this.screen.name_tf.textHeight * 0.5;
            _loc3_ = _loc2_.getCachedImage("victory");
            if(_loc3_)
            {
               _loc4_ = _loc3_.url;
               Zlab.resourceManager.load(_loc4_,SWFResource,this.onVillainLoadComplete);
            }
         }
      }
      
      private function onVillainLoadComplete(param1:SWFResource) : void
      {
         this.m_movieClip = param1.clip;
         this.m_movieController = new MovieController(this.m_movieClip);
         var _loc2_:int = this.m_islandGroupItem ? this.villainVictoryAnimationFramerate(this.m_islandGroupItem.villain) : 0;
         if(_loc2_)
         {
            this.m_movieController.fps = _loc2_;
         }
         this.screen.clipAnchor_mc.visible = true;
         this.screen.clipAnchor_mc.addChild(this.m_movieClip);
      }
      
      private function villainVictoryAnimationFramerate(param1:String) : int
      {
         var _loc3_:XMLList = null;
         var _loc4_:XML = null;
         var _loc5_:String = null;
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByCode(param1,GameItem) as GameItem;
         if(_loc2_)
         {
            _loc3_ = _loc2_.xml.image;
            for each(_loc4_ in _loc3_)
            {
               if(_loc4_.@name == "victory")
               {
                  _loc5_ = _loc4_.@fps.toString();
                  if(_loc5_.length)
                  {
                     return int(_loc5_);
                  }
               }
            }
         }
         return 0;
      }
      
      private function onFight(param1:MouseEvent) : void
      {
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_PRE_START,this.quitAndClose);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_START,this.quitAndClose);
         this.m_islandData[this.m_currentIndex].click();
      }
      
      private function onPageClicked(param1:MouseEvent) : void
      {
         this.m_currentIndex = parseInt(param1.target.buttonValue);
         this.loadMap(this.m_currentIndex);
      }
      
      private function quitAndClose(param1:Event) : void
      {
         this.close();
      }
      
      private function onExit(param1:MouseEvent) : void
      {
         this.close();
      }
      
      override protected function close(param1:Event = null) : void
      {
         var _loc2_:BattleSelectButton = null;
         for each(_loc2_ in this.m_pageButtons)
         {
            Tooltip.unsubscribe(_loc2_.hit);
         }
         super.close(param1);
      }
      
      private function onLeftClick(param1:MouseEvent) : void
      {
         if(this.m_currentIndex > 0)
         {
            --this.m_currentIndex;
            this.loadMap(this.m_currentIndex);
         }
      }
      
      private function onRightClick(param1:MouseEvent) : void
      {
         if(this.m_currentIndex < this.m_islandGroupItem.numIslands - 1)
         {
            ++this.m_currentIndex;
            this.loadMap(this.m_currentIndex);
         }
      }
      
      private function setText() : void
      {
         TextFieldUtil.processTextField(this.screen.title0_tf,this.m_islandGroupItem.getMapName(true));
         TextFieldUtil.processTextField(this.screen.battle_tf,ZGameUtils.ZlocT("Dialogs","BattleSelect_Battle"));
         TextFieldUtil.processTextField(this.screen.vs_tf,ZGameUtils.ZlocT("Dialogs","BattleSelect_Vs"));
         TextFieldUtil.processTextField(this.screen.enemyUnits_tf,ZGameUtils.ZlocT("Dialogs","BattleSelect_EnemyUnits"));
      }
      
      private function loadMap(param1:uint) : void
      {
         var _loc3_:IslandItem = null;
         var _loc4_:Array = null;
         var _loc5_:uint = 0;
         var _loc6_:String = null;
         var _loc7_:Boolean = false;
         var _loc8_:Boolean = false;
         var _loc9_:MovieClip = null;
         var _loc10_:Array = null;
         var _loc11_:uint = 0;
         var _loc12_:String = null;
         var _loc13_:uint = 0;
         var _loc14_:String = null;
         var _loc15_:int = 0;
         var _loc16_:BattleSelectButton = null;
         var _loc17_:int = 0;
         var _loc18_:UnitItem = null;
         var _loc2_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_CAMPAIGN_MASTERY);
         if(_loc2_ == ZGlobal.EXPERIMENT_CAMPAIGN_MASTERY_ENABLED)
         {
            this.loadMapWithCampaignMastery(param1);
         }
         else
         {
            _loc3_ = this.m_islandGroupItem.getIslandItem(param1);
            _loc4_ = _loc3_.getUnits();
            _loc5_ = _loc4_.length;
            _loc6_ = ZGameUtils.ZlocT("Campaign","map_" + this.m_islandGroupItem.code + "_" + _loc3_.name + "_name");
            TextFieldUtil.processTextField(this.screen.battleName_tf,_loc6_);
            _loc7_ = Boolean(this.m_islandData[param1].isLocked());
            _loc8_ = Boolean(this.m_islandData[param1].isDone());
            _loc9_ = null;
            _loc10_ = null;
            if(_loc5_ % 2 == 0)
            {
               _loc9_ = this.screen.enemyUnits.even;
               this.screen.enemyUnits.odd.visible = false;
               _loc10_ = [_loc9_.unit_icon1,_loc9_.unit_icon2,_loc9_.unit_icon0,_loc9_.unit_icon3];
            }
            else
            {
               _loc9_ = this.screen.enemyUnits.odd;
               this.screen.enemyUnits.even.visible = false;
               _loc10_ = [_loc9_.unit_icon2,_loc9_.unit_icon1,_loc9_.unit_icon3,_loc9_.unit_icon0,_loc9_.unit_icon4];
            }
            _loc9_.visible = true;
            _loc11_ = _loc10_.length;
            this.setBattleStatus();
            _loc12_ = null;
            _loc13_ = 0;
            for each(_loc14_ in _loc4_)
            {
               _loc18_ = ZGlobal.gameSettings.getItemByCode(_loc14_,UnitItem) as UnitItem;
               if(!_loc8_ && _loc18_.hasType(UnitItem.VILLAIN))
               {
                  this.m_imageLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/HideUnit_icon.png"),_loc10_[_loc13_]));
               }
               else
               {
                  this.m_imageLoaders.push(ImageLoaderFactory.CreateImageLoader(_loc18_.getCachedImage("icon").url,_loc10_[_loc13_]));
               }
               _loc13_++;
               if(null == _loc12_)
               {
                  _loc12_ = _loc18_.subType;
               }
            }
            while(_loc13_ < _loc11_)
            {
               _loc10_[_loc13_].unload();
               _loc13_++;
            }
            this.setTheatre(this.screen.theater_dialog.theater_info.theaterCard0_mc,_loc3_.playerType);
            this.setTheatre(this.screen.theater_dialog.theater_info.theaterCard1_mc,_loc12_);
            _loc15_ = 0;
            for each(_loc16_ in this.m_pageButtons)
            {
               _loc16_.selected = _loc15_ == param1;
               _loc15_++;
            }
            if(_loc7_)
            {
               this.m_fightButton.disable_visual();
            }
            else
            {
               this.m_fightButton.enable();
            }
            _loc17_ = this.m_islandGroupItem.numIslands;
            ZGameUtils.setButtonEnabled(this.screen.arrowRt_bt,this.onRightClick,param1 < _loc17_ - 1);
            ZGameUtils.setButtonEnabled(this.screen.arrowLt_bt,this.onLeftClick,param1 > 0);
         }
      }
      
      private function loadMapWithCampaignMastery(param1:uint) : void
      {
         var _loc22_:String = null;
         var _loc24_:BattleSelectButton = null;
         var _loc26_:String = null;
         var _loc27_:ImageLoader = null;
         var _loc28_:UnitItem = null;
         var _loc2_:IslandItem = this.m_islandGroupItem.getIslandItem(param1);
         var _loc3_:Array = _loc2_.getUnits();
         var _loc4_:uint = _loc3_.length;
         var _loc5_:int = this.m_islandGroupItem.getMaxUnits(param1);
         var _loc6_:String = this.m_islandGroupItem.getPlayerType(param1);
         var _loc7_:String = ZGameUtils.ZlocT("Campaign","map_" + this.m_islandGroupItem.code + "_" + _loc2_.name + "_name");
         var _loc8_:int = ZGlobal.player.campaign.getCappedMastery(_loc2_.index);
         var _loc9_:int = ZGlobal.player.campaign.getIslandMastery(this.m_islandGroupItem.code);
         TextFieldUtil.processTextField(this.screen.battleName_tf,_loc7_);
         TextFieldUtil.processTextField(this.screen.battleNum_tf,(param1 + 1).toString());
         TextFieldUtil.processTextField(this.screen.progress_tf,_loc9_.toString() + " / " + (ZGlobal.player.campaign.MAX_MASTERY_TIER + 1).toString());
         if(_loc8_ > 0)
         {
            if(_loc8_ == 1)
            {
               _loc26_ = "Mastery_Cheveron1_60.png";
            }
            else if(_loc8_ == 2)
            {
               _loc26_ = "Mastery_Cheveron2_60.png";
            }
            else if(_loc8_ >= 3)
            {
               _loc26_ = "Mastery_Star_60.png";
            }
            this.screen.rank_mc.icon.visible = true;
            _loc27_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/" + _loc26_),this.screen.rank_mc.icon);
            _loc27_.smooth = true;
            this.m_imageLoaders.push(_loc27_);
         }
         else
         {
            this.screen.rank_mc.icon.visible = false;
         }
         var _loc10_:Boolean = Boolean(this.m_islandData[param1].isLocked());
         var _loc11_:Boolean = Boolean(this.m_islandData[param1].isDone());
         var _loc12_:MovieClip = null;
         var _loc13_:Array = null;
         if(_loc5_ % 2 == 0)
         {
            _loc12_ = this.screen.playerUnits.even;
            this.screen.playerUnits.odd.visible = false;
            _loc13_ = [_loc12_.unit_icon1,_loc12_.unit_icon2,_loc12_.unit_icon0,_loc12_.unit_icon3];
         }
         else
         {
            _loc12_ = this.screen.playerUnits.odd;
            this.screen.playerUnits.even.visible = false;
            _loc13_ = [_loc12_.unit_icon2,_loc12_.unit_icon1,_loc12_.unit_icon3,_loc12_.unit_icon0,_loc12_.unit_icon4];
         }
         _loc12_.visible = true;
         var _loc14_:uint = _loc13_.length;
         var _loc15_:String = "PlayerUnit_Land_70.png";
         if(_loc6_ == "army")
         {
            _loc15_ = "PlayerUnit_Land_70.png";
         }
         else if(_loc6_ == "navy")
         {
            _loc15_ = "PlayerUnit_Sea_70.png";
         }
         else if(_loc6_ == "air")
         {
            _loc15_ = "PlayerUnit_Air_70.png";
         }
         var _loc16_:uint = 0;
         var _loc17_:uint = 0;
         while(_loc17_ < _loc5_)
         {
            this.m_imageLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/" + _loc15_),_loc13_[_loc16_]));
            _loc13_[_loc16_].visible = true;
            _loc16_++;
            _loc17_++;
         }
         while(_loc16_ < _loc14_)
         {
            _loc13_[_loc16_].unload();
            _loc16_++;
         }
         var _loc18_:MovieClip = null;
         var _loc19_:Array = null;
         if(_loc4_ % 2 == 0)
         {
            _loc18_ = this.screen.enemyUnits.even;
            this.screen.enemyUnits.odd.visible = false;
            _loc19_ = [_loc18_.unit_icon1,_loc18_.unit_icon2,_loc18_.unit_icon0,_loc18_.unit_icon3];
         }
         else
         {
            _loc18_ = this.screen.enemyUnits.odd;
            this.screen.enemyUnits.even.visible = false;
            _loc19_ = [_loc18_.unit_icon2,_loc18_.unit_icon1,_loc18_.unit_icon3,_loc18_.unit_icon0,_loc18_.unit_icon4];
         }
         _loc18_.visible = true;
         var _loc20_:uint = _loc19_.length;
         this.setBattleStatus();
         if(_loc8_ >= 3)
         {
            this.screen.title_frame_mc.gotoAndStop(5);
         }
         var _loc21_:String = null;
         _loc16_ = 0;
         for each(_loc22_ in _loc3_)
         {
            _loc28_ = ZGlobal.gameSettings.getItemByCode(_loc22_,UnitItem) as UnitItem;
            if(!_loc11_ && _loc28_.hasType(UnitItem.VILLAIN))
            {
               this.m_imageLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/HideUnit_icon.png"),_loc19_[_loc16_]));
            }
            else if(_loc28_)
            {
               this.m_imageLoaders.push(ImageLoaderFactory.CreateImageLoader(_loc28_.getCachedImage("icon").url,_loc19_[_loc16_]));
            }
            _loc16_++;
            if(null == _loc21_)
            {
               _loc21_ = _loc28_.subType;
            }
         }
         while(_loc16_ < _loc20_)
         {
            _loc19_[_loc16_].unload();
            _loc16_++;
         }
         TextFieldUtil.processTextField(this.screen.theater_dialog.theater_info.vs_tf,ZGameUtils.ZlocT("Dialogs","BattleSelect_Vs"));
         this.setTheatre(this.screen.theater_dialog.theater_info.theaterCard0_mc,_loc2_.playerType);
         this.setTheatre(this.screen.theater_dialog.theater_info.theaterCard1_mc,_loc21_);
         var _loc23_:int = 0;
         for each(_loc24_ in this.m_pageButtons)
         {
            _loc24_.selected = _loc23_ == param1;
            _loc23_++;
         }
         if(_loc10_)
         {
            this.m_fightButton.disable_visual();
            this.m_fightButton.hide();
         }
         else
         {
            this.m_fightButton.enable();
            this.m_fightButton.show();
         }
         var _loc25_:int = this.m_islandGroupItem.numIslands;
         ZGameUtils.setButtonEnabled(this.screen.arrowRt_bt,this.onRightClick,param1 < _loc25_ - 1);
         ZGameUtils.setButtonEnabled(this.screen.arrowLt_bt,this.onLeftClick,param1 > 0);
      }
      
      private function setVillainTokens() : void
      {
         var _loc1_:int = ZGlobal.player.campaign.getIslandMastery(this.m_islandGroupItem.code);
         if(_loc1_ == 1)
         {
            this.screen.token_mc1.gotoAndStop(2);
            this.screen.token_mc2.gotoAndStop(1);
            this.screen.token_mc3.gotoAndStop(1);
         }
         else if(_loc1_ == 2)
         {
            this.screen.token_mc1.gotoAndStop(2);
            this.screen.token_mc2.gotoAndStop(2);
            this.screen.token_mc3.gotoAndStop(1);
         }
         else if(_loc1_ >= 3)
         {
            this.screen.token_mc1.gotoAndStop(2);
            this.screen.token_mc2.gotoAndStop(2);
            this.screen.token_mc3.gotoAndStop(2);
         }
         else
         {
            this.screen.token_mc1.gotoAndStop(1);
            this.screen.token_mc2.gotoAndStop(1);
            this.screen.token_mc3.gotoAndStop(1);
         }
      }
      
      private function setBattleStatus() : void
      {
         var _loc1_:uint = 0;
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_CAMPAIGN_MASTERY);
         if(Boolean(this.m_islandData[this.m_currentIndex].isReplay()) || Boolean(this.m_islandData[this.m_currentIndex].isProgess()))
         {
            _loc1_ = 3;
            _loc2_ = "BattleSelect_BattleInProgress";
            _loc3_ = "BattleSelect_Continue";
            if(_loc4_ == ZGlobal.EXPERIMENT_CAMPAIGN_MASTERY_ENABLED)
            {
               this.screen.title_frame_mc.gotoAndStop(4);
            }
         }
         else if(this.m_islandData[this.m_currentIndex].isLocked())
         {
            _loc1_ = 1;
            _loc2_ = "BattleSelect_BattleLocked";
            _loc3_ = "BattleSelect_FightNow";
            if(_loc4_ == ZGlobal.EXPERIMENT_CAMPAIGN_MASTERY_ENABLED)
            {
               this.screen.title_frame_mc.gotoAndStop(3);
            }
         }
         else if(this.m_islandData[this.m_currentIndex].isDone())
         {
            _loc1_ = 2;
            _loc2_ = "BattleSelect_BattleCompleted";
            _loc3_ = "BattleSelect_Replay";
            if(_loc4_ == ZGlobal.EXPERIMENT_CAMPAIGN_MASTERY_ENABLED)
            {
               this.screen.title_frame_mc.gotoAndStop(1);
            }
         }
         else
         {
            _loc1_ = 4;
            _loc2_ = "BattleSelect_Ready";
            _loc3_ = "BattleSelect_FightNow";
            if(_loc4_ == ZGlobal.EXPERIMENT_CAMPAIGN_MASTERY_ENABLED)
            {
               this.screen.title_frame_mc.gotoAndStop(2);
            }
         }
         this.m_fightButton.text = ZGameUtils.ZlocT("Dialogs",_loc3_);
         this.screen.battleStatus_mc.gotoAndStop(_loc1_);
         TextFieldUtil.compactTextField(this.screen.battleStatus_mc.battleStatus_tf,ZGameUtils.ZlocT("Dialogs",_loc2_));
      }
      
      private function setTheatre(param1:MovieClip, param2:String) : void
      {
         param1.img_land_mc.visible = false;
         param1.img_air_mc.visible = false;
         param1.img_sea_mc.visible = false;
         var _loc3_:String = null;
         if(param2 == UnitItem.AIR)
         {
            param1.img_air_mc.visible = true;
            _loc3_ = "BattleSelect_Air";
         }
         else if(param2 == UnitItem.ARMY)
         {
            param1.img_land_mc.visible = true;
            _loc3_ = "BattleSelect_Land";
         }
         else if(param2 == UnitItem.NAVY)
         {
            param1.img_sea_mc.visible = true;
            _loc3_ = "BattleSelect_Navy";
         }
         TextFieldUtil.processTextField(param1.theater_tf,ZGameUtils.ZlocT("Dialogs",_loc3_));
      }
   }
}

