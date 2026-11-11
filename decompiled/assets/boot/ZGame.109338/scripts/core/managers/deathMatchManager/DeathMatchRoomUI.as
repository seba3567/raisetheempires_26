package core.managers.deathMatchManager
{
   import core.ZGlobal;
   import core.gameobjects.Fleet;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.domination.DominationModeManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import fl.motion.AdjustColor;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.resource.SWFResource;
   
   public class DeathMatchRoomUI extends ZGamePopUp
   {
      
      private var assetUrl:String = "assets/displays/dialogs/PU_WarZone.swf";
      
      private var m_opponentsSlots:Array;
      
      private var m_leadersSlots:Array;
      
      private var m_buttons:Array = new Array();
      
      private var m_imageLoaders:Array = new Array();
      
      private var m_strength:Number;
      
      private var m_Matrix:Array = [];
      
      private var m_colorMatrix:ColorMatrixFilter;
      
      public function DeathMatchRoomUI()
      {
         super(ZGlobal.getAssetURL(this.assetUrl));
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         m_window = param1.clip.screen_mc;
         this.setupUI();
      }
      
      protected function setupUI() : void
      {
         var _loc1_:AdjustColor = new AdjustColor();
         _loc1_.hue = 50;
         _loc1_.saturation = -100;
         _loc1_.brightness = 50;
         _loc1_.contrast = 0;
         this.m_Matrix = _loc1_.CalculateFinalFlatArray();
         this.m_colorMatrix = new ColorMatrixFilter(this.m_Matrix);
         m_window.exit_bt.addEventListener(MouseEvent.CLICK,this.close);
         TextFieldUtil.compactTextField(m_window.title_tf,ZGameUtils.ZlocT("Dialogs","DM_LobbyHeader"));
         TextFieldUtil.compactTextField(m_window.leaderboard_tf,ZGameUtils.ZlocT("Dialogs","DM_RoomLeaderBoard"));
         var _loc2_:Object = new Object();
         _loc2_ = {
            "1":"DM_Category1",
            "2":"DM_Category2",
            "3":"DM_Category3"
         };
         TextFieldUtil.compactTextField(m_window.choose_tf,ZGameUtils.ZlocT("Dialogs",_loc2_[this.currentRoomID.charAt(2)]));
         this.contentWidth = m_window.panel_mc.width;
         this.contentHeight = m_window.panel_mc.height;
         centerWithinStage(Zlab.mainStage);
         ImageLoaderFactory.CreateImageLoader(ZGlobal.player.snUser.picture,m_window.icon);
         TextFieldUtil.processTextField(m_window.yourName_tf,ZGlobal.player.snUser.firstName);
         var _loc3_:int = DeathMatchManager.instance.getFragsForRoom(this.currentRoomID);
         TextFieldUtil.processTextField(m_window.fragCount_tf,ZGameUtils.ZlocT("Dialogs","DM_Score",{"x":_loc3_}));
         this.setUpOpponents();
         this.setUpDefenseForce();
         this.setUpStatusBar();
         this.setUpHint();
         addChild(m_window);
      }
      
      private function setUpHint() : void
      {
         m_window.hint_mc.visible = false;
         m_window.info_bt.generic_tf.addEventListener(MouseEvent.MOUSE_OVER,this.onHintBtClicked);
         m_window.info_bt.generic_tf.addEventListener(MouseEvent.MOUSE_OUT,this.onHintBtClicked);
         TextFieldUtil.compactTextField(m_window.hint_mc.hin1_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","DM_Tut_Pic"));
         TextFieldUtil.compactTextField(m_window.hint_mc.hin2_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","DM_Tut_Bar"));
         TextFieldUtil.compactTextField(m_window.hint_mc.hin3_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","DM_Tut_Fleet"));
         TextFieldUtil.compactTextField(m_window.hint_mc.hin4_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","DM_Tut_ScoreLimit"));
         TextFieldUtil.compactTextField(m_window.hint_mc.hin5_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","DM_Tut_Leaderboard"));
         TextFieldUtil.compactTextField(m_window.hint_mc.hin6_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","DM_Tut_Opponents"));
      }
      
      private function onHintBtClicked(param1:MouseEvent) : void
      {
         m_window.hint_mc.visible = !m_window.hint_mc.visible;
      }
      
      private function setUpDefenseForce() : void
      {
         this.m_buttons.push(new ZGameButton(m_window.change_bt,this.onUpdateDefenseForce));
         TextFieldUtil.compactTextField(m_window.change_bt.generic_tf,ZGameUtils.ZlocT("Dialogs","DominationUpdateDefenseForce"));
         TextFieldUtil.compactTextField(m_window.defense_tf,ZGameUtils.ZlocT("Dialogs","DominationDefenceForce"));
         this.initImageLoaders();
      }
      
      private function onUpdateDefenseForce(param1:MouseEvent) : void
      {
         DominationModeManager.instance.enterDefenseForceEditor();
         this.close();
      }
      
      private function setUpStatusBar() : void
      {
         var _loc7_:GameItem = null;
         var _loc8_:String = null;
         var _loc9_:ImageLoader = null;
         var _loc1_:Object = DeathMatchManager.instance.maxFragsForRooms;
         TextFieldUtil.compactTextField(m_window.progressBar_mc.target_tf,_loc1_[this.currentRoomID].toString());
         TextFieldUtil.compactTextField(m_window.defenseWins_tf,ZGameUtils.ZlocT("Dialogs","DM_RoomWins",{"x":DeathMatchManager.instance.winsByPlayer}));
         TextFieldUtil.compactTextField(m_window.wins_tf,ZGameUtils.ZlocT("Dialogs","DM_RoomLoss",{"x":DeathMatchManager.instance.lossByPlayer}));
         var _loc2_:Number = Number(m_window.progressBar_mc.meter_mc.width);
         m_window.progressBar_mc.meter_ep_mc.width = _loc2_ * DeathMatchManager.instance.getFragsForRoom(this.currentRoomID) / _loc1_[this.currentRoomID];
         var _loc3_:Array = new Array(m_window.progressBar_mc.icon_01,m_window.progressBar_mc.icon_02,m_window.progressBar_mc.icon_03,m_window.progressBar_mc.icon_04,m_window.progressBar_mc.icon_05,m_window.progressBar_mc.icon_06);
         var _loc4_:Object = DeathMatchManager.instance.deathMatchRewards;
         var _loc5_:int = DeathMatchManager.instance.getStage(this.currentRoomID);
         var _loc6_:int = 0;
         while(_loc6_ < _loc3_.length)
         {
            _loc7_ = ZGlobal.gameSettings.getItemByCode(_loc4_[this.currentRoomID][_loc6_][0],GameItem) as GameItem;
            _loc8_ = ZGlobal.gameSettings.getImageByName(_loc7_.name,"icon");
            _loc9_ = ImageLoaderFactory.CreateImageLoader(_loc8_,_loc3_[_loc6_].icon1);
            _loc9_.smooth = true;
            this.m_imageLoaders.push(_loc9_);
            TextFieldUtil.compactTextField(_loc3_[_loc6_].generic_tf,_loc7_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
            _loc3_[_loc6_].generic_tf.visible = false;
            _loc3_[_loc6_].addEventListener(MouseEvent.MOUSE_OVER,this.showRewardText);
            _loc3_[_loc6_].addEventListener(MouseEvent.MOUSE_OUT,this.showRewardText);
            if(_loc6_ + 1 == _loc5_)
            {
               _loc3_[_loc6_].starburst_mc.visible = true;
            }
            else if(_loc6_ + 1 > _loc5_)
            {
               _loc3_[_loc6_].starburst_mc.visible = false;
               this.greyOut(_loc3_[_loc6_]);
            }
            else
            {
               _loc3_[_loc6_].starburst_mc.visible = false;
            }
            _loc6_++;
         }
      }
      
      private function showRewardText(param1:MouseEvent) : void
      {
         param1.currentTarget.generic_tf.visible = !param1.currentTarget.generic_tf.visible;
      }
      
      private function greyOut(param1:MovieClip) : void
      {
         param1.filters = [this.m_colorMatrix];
      }
      
      private function get currentRoomID() : String
      {
         return DeathMatchManager.instance.currentRoomID;
      }
      
      private function setUpOpponents() : void
      {
         var _loc4_:ImageLoader = null;
         var _loc6_:String = null;
         var _loc7_:Number = NaN;
         var _loc8_:String = null;
         var _loc9_:Boolean = false;
         var _loc1_:Object = DeathMatchManager.instance.getOpponentsForRoom(this.currentRoomID);
         var _loc2_:Array = DeathMatchManager.instance.getSortedLeadersForRoom(this.currentRoomID);
         var _loc3_:MovieClip = m_window.slots_mc;
         this.m_opponentsSlots = new Array(_loc3_.card0,_loc3_.card1,_loc3_.card2,_loc3_.card3,_loc3_.card4,_loc3_.card5,_loc3_.card6,_loc3_.card7,_loc3_.card8,_loc3_.card9,_loc3_.card10,_loc3_.card11);
         var _loc5_:int = 0;
         while(_loc5_ < _loc1_.length && _loc5_ < this.m_opponentsSlots.length)
         {
            _loc6_ = _loc1_[_loc5_].pic;
            _loc4_ = ImageLoaderFactory.CreateImageLoader(_loc6_,this.m_opponentsSlots[_loc5_].icon);
            this.m_imageLoaders.push(_loc4_);
            _loc7_ = _loc1_[_loc5_].frags == -1 ? 0 : Number(_loc1_[_loc5_].frags);
            _loc8_ = ZGameUtils.ZlocT("Dialogs","DM_Score",{"x":_loc7_});
            TextFieldUtil.compactTextField(this.m_opponentsSlots[_loc5_].wins_tf,_loc8_);
            TextFieldUtil.compactTextField(this.m_opponentsSlots[_loc5_].name_tf,_loc1_[_loc5_].name);
            _loc9_ = DeathMatchManager.instance.isOpponentActive(_loc1_[_loc5_].zid,this.currentRoomID);
            if(_loc9_)
            {
               this.m_opponentsSlots[_loc5_].attack_bt.visible = true;
               this.m_opponentsSlots[_loc5_].coolDown_mc.visible = false;
               this.m_buttons.push(new ZGameButton(this.m_opponentsSlots[_loc5_].attack_bt,this.onAttackClicked));
               this.m_opponentsSlots[_loc5_].zid = _loc1_[_loc5_].zid;
               this.m_opponentsSlots[_loc5_].coolDown_mc.visible = false;
               TextFieldUtil.compactTextField(this.m_opponentsSlots[_loc5_].attack_bt.generic_tf,ZGameUtils.ZlocT("Dialogs","RepelButton"));
            }
            else
            {
               this.m_opponentsSlots[_loc5_].attack_bt.visible = false;
               this.m_opponentsSlots[_loc5_].coolDown_mc.visible = true;
               TextFieldUtil.compactTextField(this.m_opponentsSlots[_loc5_].coolDown_mc.progressBar_mc.count_tf,ZGameUtils.ZlocT("Dialogs","DM_RoomCoolDown"));
            }
            this.m_opponentsSlots[_loc5_].visible = true;
            _loc5_++;
         }
         while(_loc5_ < this.m_opponentsSlots.length)
         {
            this.m_opponentsSlots[_loc5_].visible = false;
            _loc5_++;
         }
         this.m_leadersSlots = new Array(m_window.card0,m_window.card1,m_window.card2);
         _loc5_ = 0;
         while(_loc5_ < _loc2_.length && _loc5_ < this.m_leadersSlots.length && _loc2_[_loc5_].frags > 0)
         {
            _loc9_ = DeathMatchManager.instance.isOpponentActive(_loc2_[_loc5_].zid,this.currentRoomID);
            if(_loc9_)
            {
               this.m_leadersSlots[_loc5_].attack_bt.visible = true;
               this.m_buttons.push(new ZGameButton(this.m_leadersSlots[_loc5_].attack_bt,this.onAttackClicked));
               this.m_leadersSlots[_loc5_].zid = _loc2_[_loc5_].zid;
               this.m_leadersSlots[_loc5_].coolDown_mc.visible = false;
               TextFieldUtil.compactTextField(this.m_leadersSlots[_loc5_].attack_bt.generic_tf,ZGameUtils.ZlocT("Dialogs","RepelButton"));
               if(_loc2_[_loc5_].zid == ZGlobal.player.uid)
               {
                  this.m_buttons[this.m_buttons.length - 1].disable(true);
               }
            }
            else
            {
               this.m_leadersSlots[_loc5_].attack_bt.visible = false;
               this.m_leadersSlots[_loc5_].coolDown_mc.visible = true;
               TextFieldUtil.compactTextField(this.m_leadersSlots[_loc5_].coolDown_mc.progressBar_mc.count_tf,ZGameUtils.ZlocT("Dialogs","DM_RoomCoolDown"));
            }
            _loc8_ = ZGameUtils.ZlocT("Dialogs","DM_Score",{"x":_loc2_[_loc5_].frags});
            TextFieldUtil.compactTextField(this.m_leadersSlots[_loc5_].wins_tf,_loc8_);
            TextFieldUtil.compactTextField(this.m_leadersSlots[_loc5_].name_tf,_loc2_[_loc5_].name);
            _loc6_ = _loc2_[_loc5_].pic;
            _loc4_ = ImageLoaderFactory.CreateImageLoader(_loc6_,this.m_leadersSlots[_loc5_].icon);
            this.m_imageLoaders.push(_loc4_);
            this.m_leadersSlots[_loc5_].visible = true;
            _loc5_++;
         }
         while(_loc5_ < this.m_leadersSlots.length)
         {
            this.m_leadersSlots[_loc5_].visible = false;
            _loc5_++;
         }
      }
      
      private function onAttackClicked(param1:MouseEvent) : void
      {
         var _loc2_:String = param1.currentTarget.parent.zid;
         DeathMatchManager.instance.startFight(_loc2_,this.currentRoomID);
         this.close();
      }
      
      override protected function close(param1:Event = null) : void
      {
         var _loc2_:ZGameButton = null;
         var _loc3_:ImageLoader = null;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         for each(_loc2_ in this.m_buttons)
         {
            _loc2_.dispose();
            _loc2_ = null;
         }
         for each(_loc3_ in this.m_imageLoaders)
         {
            if(_loc3_)
            {
               _loc3_.destroy();
               _loc3_ = null;
            }
         }
         this.m_imageLoaders = [];
         m_window.info_bt.generic_tf.removeEventListener(MouseEvent.MOUSE_OVER,this.onHintBtClicked);
         m_window.info_bt.generic_tf.removeEventListener(MouseEvent.MOUSE_OUT,this.onHintBtClicked);
         m_window.exit_bt.removeEventListener(MouseEvent.CLICK,this.close);
         _loc4_ = new Array(m_window.progressBar_mc.icon_01,m_window.progressBar_mc.icon_02,m_window.progressBar_mc.icon_03,m_window.progressBar_mc.icon_04,m_window.progressBar_mc.icon_05,m_window.progressBar_mc.icon_06);
         _loc5_ = 0;
         while(_loc5_ < _loc4_.length)
         {
            _loc4_[_loc5_].removeEventListener(MouseEvent.MOUSE_OVER,this.showRewardText);
            _loc4_[_loc5_].removeEventListener(MouseEvent.MOUSE_OUT,this.showRewardText);
            _loc5_++;
         }
         super.close();
      }
      
      private function initImageLoaders() : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:UnitItem = null;
         var _loc6_:ImageLoader = null;
         var _loc1_:Fleet = DominationModeManager.instance.getDefenseForce();
         if(_loc1_)
         {
            _loc2_ = _loc1_.units;
            this.m_strength = 0;
            if(_loc2_)
            {
               _loc3_ = int(_loc2_.length);
               _loc4_ = 0;
               while(_loc4_ < _loc3_)
               {
                  _loc5_ = ZGlobal.gameSettings.getItemByCode(_loc2_[_loc4_].code,UnitItem) as UnitItem;
                  this.m_strength += _loc5_.getUpgradedStrength();
                  _loc6_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(_loc5_.name,"icon"),this.defenceIcons[_loc4_]);
                  this.m_imageLoaders.push(_loc6_);
                  _loc4_++;
               }
            }
         }
      }
      
      private function get defenceIcons() : Array
      {
         return [m_window.defenseUnits_mc.icon0,m_window.defenseUnits_mc.icon1,m_window.defenseUnits_mc.icon2,m_window.defenseUnits_mc.icon3,m_window.defenseUnits_mc.icon4];
      }
   }
}

