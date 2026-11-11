package core.managers.deathMatchManager
{
   import Engine.Managers.StatsManager;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GenericCountdownClock;
   import displays.popups.genericPopup.ModalPopup;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class DeathMatchLobby extends ZGamePopUp
   {
      
      private var assetUrl:String = "assets/displays/dialogs/PU_WarZoneLobby.swf";
      
      private const ELITE_ROOM_ID:String = "1";
      
      private const VETERAN_ROOM_ID:String = "3";
      
      private const MASTER_ROOM_ID:String = "2";
      
      private var m_loaders:Array;
      
      private var m_buttons:Array;
      
      private var m_clocks:Array;
      
      private var m_cards:Array = null;
      
      public function DeathMatchLobby()
      {
         super(ZGlobal.getAssetURL(this.assetUrl));
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         this.m_buttons = new Array();
         this.m_loaders = new Array();
         this.m_clocks = new Array();
         if(DeathMatchManager.instance.timeRemaining < 0)
         {
            m_window = param1.clip.expired_mc;
            this.contentWidth = m_window.panel_mc.width;
            this.contentHeight = m_window.panel_mc.height;
            TextFieldUtil.compactTextField(m_window.generic_tf,ZGameUtils.ZlocT("Dialogs","DM_Expire1"));
            TextFieldUtil.compactTextField(m_window.generic2_tf,ZGameUtils.ZlocT("Dialogs","DM_Expire2"));
            TextFieldUtil.compactTextField(m_window.ok_bt.generic_tf,ZGameUtils.ZlocT("Dialogs","DM_RewardBt_Ok"));
            param1.clip.screen_mc.visible = false;
            this.m_buttons.push(new ZGameButton(m_window.ok_bt,this.close));
            m_window.visible = true;
         }
         else
         {
            m_window = param1.clip.screen_mc;
            this.contentWidth = m_window.panel_mc.width;
            this.contentHeight = m_window.panel_mc.height;
            param1.clip.expired_mc.visible = false;
            this.setupActiveUI();
         }
         centerWithinStage(Zlab.mainStage);
         addChild(m_window);
      }
      
      protected function setupActiveUI() : void
      {
         var _loc7_:String = null;
         var _loc8_:Number = NaN;
         var _loc9_:String = null;
         var _loc10_:String = null;
         m_window.exit_bt.addEventListener(MouseEvent.CLICK,this.close);
         TextFieldUtil.compactTextField(m_window.title_tf,ZGameUtils.ZlocT("Dialogs","DM_LobbyHeader"));
         TextFieldUtil.compactTextField(m_window.description_tf,ZGameUtils.ZlocT("Dialogs","DM_LobbySubHeader"));
         TextFieldUtil.compactTextField(m_window.room1_mc.title_tf,ZGameUtils.ZlocT("Dialogs","DM_Category1"));
         TextFieldUtil.compactTextField(m_window.room2_mc.title_tf,ZGameUtils.ZlocT("Dialogs","DM_Category2"));
         TextFieldUtil.compactTextField(m_window.room3_mc.title_tf,ZGameUtils.ZlocT("Dialogs","DM_Category3"));
         var _loc1_:int = DeathMatchManager.instance.endTime;
         this.m_clocks.push(new GenericCountdownClock(m_window.clock_mc,_loc1_));
         var _loc2_:int = DeathMatchManager.instance.dmBand;
         var _loc3_:Object = DeathMatchManager.instance.deathMatchRewards;
         var _loc4_:Object = DeathMatchManager.instance.grandRewards;
         var _loc5_:Object = DeathMatchManager.instance.maxFragsForRooms;
         this.m_cards = new Array(m_window.room1_mc,m_window.room2_mc,m_window.room3_mc);
         var _loc6_:int = 0;
         while(_loc6_ < this.m_cards.length)
         {
            _loc7_ = _loc2_ + "_" + (_loc6_ + 1);
            _loc8_ = DeathMatchManager.instance.getRoomState(_loc7_);
            _loc10_ = ZGameUtils.ZlocT("Dialogs","DM_reqScore",{"x":_loc5_[_loc7_]});
            TextFieldUtil.compactTextField(this.m_cards[_loc6_].frags_tf,_loc10_);
            if(_loc6_ == 0)
            {
               TextFieldUtil.compactTextField(this.m_cards[_loc6_].generic1_tf,ZGameUtils.ZlocT("Dialogs","DM_CategoryText01"));
            }
            else
            {
               TextFieldUtil.compactTextField(this.m_cards[_loc6_].generic1_tf,ZGameUtils.ZlocT("Dialogs","DM_CategoryText11"));
            }
            TextFieldUtil.compactTextField(this.m_cards[_loc6_].generic2_tf,ZGameUtils.ZlocT("Dialogs","DM_CategoryText2"));
            this.m_cards[_loc6_].roomID = _loc7_;
            this.m_cards[_loc6_].state = _loc8_;
            this.m_buttons.push(new ZGameButton(this.m_cards[_loc6_].add_bt,this.onClick));
            switch(_loc8_)
            {
               case DeathMatchManager.NEW_USER:
                  _loc9_ = ZGameUtils.ZlocT("Dialogs","DM_JoinRoomButton");
                  this.m_cards[_loc6_].cardActive_mc.visible = false;
                  break;
               case DeathMatchManager.ACTIVE_BATTLE:
                  _loc9_ = ZGameUtils.ZlocT("Dialogs","DM_ContinueButton");
                  this.m_cards[_loc6_].cardActive_mc.visible = true;
                  break;
               case DeathMatchManager.NO_ACTIVE_BATTLE:
                  _loc9_ = ZGameUtils.ZlocT("Dialogs","DM_EnterRoomButton");
                  this.m_cards[_loc6_].cardActive_mc.visible = true;
                  break;
               case DeathMatchManager.HAS_REACHED_MAX_SCORE:
                  _loc9_ = "";
                  this.m_cards[_loc6_].add_bt.visible = false;
                  this.m_buttons[this.m_buttons.length - 1].disable();
            }
            TextFieldUtil.compactTextField(this.m_cards[_loc6_].add_bt.generic_tf,_loc9_);
            this.setUpCards(_loc6_,_loc3_[_loc7_],_loc4_[_loc7_]);
            _loc6_++;
         }
      }
      
      private function setUpGrandReward(param1:MovieClip, param2:String, param3:int) : void
      {
         var _loc7_:UnitItem = null;
         var _loc4_:GameItem = ZGlobal.gameSettings.getItemByCode(param2,GameItem) as GameItem;
         var _loc5_:String = ZGlobal.gameSettings.getImageByName(_loc4_.name,"icon");
         var _loc6_:ImageLoader = ImageLoaderFactory.CreateImageLoader(_loc5_,param1.icon);
         this.m_loaders.push(_loc6_);
         TextFieldUtil.compactTextField(param1.rewardName_tf,_loc4_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         TextFieldUtil.compactTextField(param1.qty_tf,"x" + param3.toString());
         if(_loc4_.isUnit())
         {
            _loc7_ = ZGlobal.gameSettings.getItemByCode(param2,UnitItem) as UnitItem;
            TextFieldUtil.compactTextField(param1.tier_mc.tier_tf,_loc7_.tier.toString());
            TextFieldUtil.compactTextField(param1.strength_mc.strength_tf,_loc7_.getStrength(null).toString());
         }
      }
      
      private function setUpCards(param1:int, param2:Array, param3:Array) : void
      {
         var _loc5_:GameItem = null;
         var _loc6_:ImageLoader = null;
         var _loc7_:String = null;
         var _loc9_:UnitItem = null;
         var _loc4_:Array = new Array(this.m_cards[param1].subReward1_mc,this.m_cards[param1].subReward2_mc,this.m_cards[param1].subReward3_mc,this.m_cards[param1].subReward4_mc,this.m_cards[param1].subReward5_mc,this.m_cards[param1].subReward6_mc);
         var _loc8_:int = 0;
         while(_loc8_ < _loc4_.length)
         {
            _loc5_ = ZGlobal.gameSettings.getItemByCode(param2[_loc8_][0],GameItem) as GameItem;
            _loc7_ = ZGlobal.gameSettings.getImageByName(_loc5_.name,"icon");
            _loc6_ = ImageLoaderFactory.CreateImageLoader(_loc7_,_loc4_[_loc8_].icon);
            _loc6_.smooth = true;
            TextFieldUtil.compactTextField(_loc4_[_loc8_].title_tf,_loc5_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
            TextFieldUtil.compactTextField(_loc4_[_loc8_].qty_tf,"x" + param2[1][1].toString());
            this.m_loaders.push(_loc6_);
            if(_loc5_.isUnit())
            {
               _loc9_ = ZGlobal.gameSettings.getItemByCode(param2[_loc8_][0],UnitItem) as UnitItem;
               TextFieldUtil.compactTextField(_loc4_[_loc8_].strength_mc.strength_tf,_loc9_.getStrength(null).toString());
            }
            else
            {
               _loc4_[_loc8_].strength_mc.visible = false;
            }
            _loc8_++;
         }
         switch(param1)
         {
            case 0:
               this.setUpGrandReward(this.m_cards[param1].mainReward1_mc,param3[0][0],param3[0][1]);
               break;
            case 1:
               this.setUpGrandReward(this.m_cards[param1].mainReward1_mc,param3[0][0],param3[0][1]);
               this.setUpGrandReward(this.m_cards[param1].mainReward2_mc,param3[1][0],param3[1][1]);
               break;
            case 2:
               this.setUpGrandReward(this.m_cards[param1].mainReward1_mc,param3[0][0],param3[0][1]);
               this.setUpGrandReward(this.m_cards[param1].mainReward2_mc,param3[1][0],param3[1][1]);
               this.setUpGrandReward(this.m_cards[param1].mainReward3_mc,param3[2][0],param3[2][1]);
         }
      }
      
      private function launchRoom(param1:Event) : void
      {
         DeathMatchManager.instance.removeEventListener(DeathMatchManager.OPPONENT_LIST_UPDATED,this.launchRoom);
         DeathMatchManager.instance.launchRoom();
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         var _loc2_:String = param1.currentTarget.parent.roomID;
         var _loc3_:Number = Number(param1.currentTarget.parent.state);
         var _loc4_:String = DeathMatchManager.instance.getPausedBattleOpponentForRoom(_loc2_);
         DeathMatchManager.instance.currentRoomID = _loc2_;
         var _loc5_:String = ZGameUtils.ZlocT("Dialogs","DM_loadingRoom");
         DeathMatchManager.instance.loadingScreen = new ModalPopup(_loc5_,null,DeathMatchManager.LOADING_SCREEN);
         PopupManager.instance.push(DeathMatchManager.instance.loadingScreen);
         var _loc6_:Object = DeathMatchManager.instance.counterData;
         if(!_loc6_.band)
         {
            _loc6_.band = "";
         }
         if(!_loc6_.level)
         {
            _loc6_.level = "";
         }
         switch(_loc3_)
         {
            case DeathMatchManager.ACTIVE_BATTLE:
               DeathMatchManager.instance.startFight(_loc4_,_loc2_);
               StatsManager.count("deathmatch.ui",_loc6_.band,_loc6_.level,"continue");
               break;
            case DeathMatchManager.NEW_USER:
               DeathMatchManager.instance.joinRoom(_loc2_);
               DeathMatchManager.instance.addEventListener(DeathMatchManager.OPPONENT_LIST_UPDATED,this.launchRoom);
               StatsManager.count("deathmatch.ui",_loc6_.band,_loc6_.level,"enter");
               break;
            case DeathMatchManager.NO_ACTIVE_BATTLE:
               if(DeathMatchManager.instance.isCacheValid(_loc2_))
               {
                  DeathMatchManager.instance.launchRoom();
               }
               else
               {
                  DeathMatchManager.instance.fetchOpponentsForRoom(_loc2_);
                  DeathMatchManager.instance.addEventListener(DeathMatchManager.OPPONENT_LIST_UPDATED,this.launchRoom);
               }
               StatsManager.count("deathmatch.ui",_loc6_.band,_loc6_.level,"enter");
         }
         this.close();
      }
      
      override protected function close(param1:Event = null) : void
      {
         var _loc2_:ZGameButton = null;
         var _loc3_:ImageLoader = null;
         var _loc4_:GenericCountdownClock = null;
         if(m_window.exit_bt != null)
         {
            m_window.exit_bt.removeEventListener(MouseEvent.CLICK,this.close);
         }
         for each(_loc2_ in this.m_buttons)
         {
            _loc2_.dispose();
            _loc2_ = null;
         }
         for each(_loc3_ in this.m_loaders)
         {
            _loc3_.destroy();
            _loc3_ = null;
         }
         for each(_loc4_ in this.m_clocks)
         {
            _loc4_.dispose();
            _loc4_ = null;
         }
         super.close();
      }
   }
}

