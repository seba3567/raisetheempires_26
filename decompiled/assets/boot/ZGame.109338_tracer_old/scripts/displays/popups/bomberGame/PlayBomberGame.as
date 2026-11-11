package displays.popups.bomberGame
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.WorldResourceManager;
   import core.managers.miniGameManager.BomberGameManager;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.popups.genericPopup.NotEnoughCashPopup;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import sound.SoundEvent;
   import transactions.TBuyItem;
   import transactions.TDropBomb;
   import transactions.TStopGame;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.events.GenericPopupEvent;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   import zlabs.sound.ISoundHandle;
   import zlabs.sound.SoundManager;
   
   public class PlayBomberGame extends ZGamePopUp
   {
      
      private static const BGSOUND_CLASSNAME:String = "minGameTrack";
      
      private static const BOMB_SOUND:String = "SmallCannonHit";
      
      public static const MAX_ANGLE:Number = 135;
      
      public static const MIN_ANGLE:Number = 0;
      
      public static const CRATE_MOVE_TICK_TIME:Number = 28;
      
      public static const CRATE_MOVE_PIXEL:Number = 5;
      
      public static const NO_OF_CRATES:int = 5;
      
      public static const BOMB_DROP_TIME:Number = 3644;
      
      private var rsr:Array;
      
      private var rsc:Number;
      
      private var gameTime:Timer;
      
      private var crateMoveTime:Timer;
      
      private var currentReward:String;
      
      private var m_bgMusic:Class;
      
      private var m_crates:Array = new Array();
      
      private var m_bg:Array = new Array();
      
      private var m_parts:Array;
      
      private var m_crateToHitIndex:Number;
      
      private var m_currentIndex:Number;
      
      private var m_buyPopup:GenericPopup2B;
      
      private var bombDropTimer:Timer;
      
      private var m_paused:Boolean;
      
      private var m_crateToHit:Number;
      
      private var m_rotation:Number;
      
      private var m_originalCrateX:Number;
      
      private var m_originalItemX:Number;
      
      private var m_bombDropStartedAt:Number;
      
      private var m_crateGeneratedAt:Number;
      
      private var m_bombPrice:Number;
      
      private var overlapChance:Boolean;
      
      private var m_rewardData:Object;
      
      private var m_stopped:Boolean;
      
      private var m_rewardWaitStarted:Boolean;
      
      private var m_rewardQueue:Array;
      
      private var numLoads:Number;
      
      private var m_buyCashActive:Boolean;
      
      private var m_endPopupShown:Boolean;
      
      private var m_transactionCompleted:Boolean;
      
      public function PlayBomberGame(param1:String, param2:Number, param3:Array)
      {
         this.rsc = param2;
         this.rsr = param3;
         super(ZGlobal.getAssetURL("assets/displays/dialogs/MiniGame_play.swf"));
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         StatsManager.count("dialog","mini_game","start_bomber");
         m_window = param1.clip.m_screen;
         m_window.bomb_mc.gotoAndStop(1);
         m_window.bomb_mc.visible = false;
         m_window.rewardPopup_mc.visible = false;
         m_window.buyBombs_mc.visible = false;
         this.m_currentIndex = 0;
         this.m_stopped = false;
         this.m_rewardWaitStarted = false;
         this.m_rewardQueue = new Array();
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByCode(BomberGameManager.PAID_BOMB_CODE,GameItem) as GameItem;
         this.m_bombPrice = _loc2_.cash;
         m_window.bomb_bt.ep_tf.text = _loc2_.cash;
         this.m_rotation = MIN_ANGLE;
         this.overlapChance = false;
         this.m_paused = false;
         this.m_bgMusic = param1.getAssetClass(BGSOUND_CLASSNAME);
         this.contentWidth = param1.clip.m_screen.panel_mc.width;
         this.contentHeight = param1.clip.m_screen.panel_mc.height;
         this.showDialog();
      }
      
      private function updateCashUI() : void
      {
         var _loc1_:String = String(ZGlobal.player.cash);
         TextFieldUtil.compactTextField(m_window.cash_mc.label_tf,_loc1_);
      }
      
      public function showDialog() : void
      {
         m_window.bomb_bt.enabled = false;
         m_window.bomb_bt.gotoAndStop(1);
         TextFieldUtil.compactTextField(m_window.generic_tf,String(BomberGameManager.instance.getBombCount()));
         m_window.bomb_bt.ep_tf.visible = false;
         if(!BomberGameManager.instance.gamePaused)
         {
            BomberGameManager.instance.originalmc = new Array(m_window.part1_mc,m_window.part2_mc,m_window.part3_mc,m_window.part4_mc,m_window.part5_mc);
         }
         else
         {
            m_window.part1_mc = BomberGameManager.instance.originalmc[0];
            m_window.part2_mc = BomberGameManager.instance.originalmc[1];
            m_window.part3_mc = BomberGameManager.instance.originalmc[2];
            m_window.part4_mc = BomberGameManager.instance.originalmc[3];
            m_window.part1_mc.x = BomberGameManager.instance.originalmc[0].x;
            m_window.part2_mc.x = BomberGameManager.instance.originalmc[1].x;
            m_window.part3_mc.x = BomberGameManager.instance.originalmc[2].x;
            m_window.part4_mc.x = BomberGameManager.instance.originalmc[3].x;
         }
         this.m_transactionCompleted = true;
         this.m_parts = new Array(m_window.part1_mc,m_window.part2_mc,m_window.part3_mc,m_window.part4_mc,m_window.part5_mc);
         var _loc1_:int = 0;
         while(_loc1_ < this.m_parts.length)
         {
            this.m_parts[_loc1_].crate_mc.visible = false;
            this.m_parts[_loc1_].icon.visible = false;
            _loc1_++;
         }
         m_window.cash_mc.getmore_bt.addEventListener(MouseEvent.CLICK,this.buyCash);
         this.m_rotation = (MAX_ANGLE - MIN_ANGLE) / BomberGameManager.instance.TotalFuel * BomberGameManager.instance.Fuel;
         centerWithinStage(Zlab.mainStage);
         this.updateCashUI();
         this.loadGame();
      }
      
      public function buyCash(param1:MouseEvent) : void
      {
         ZGlobal.switchToTab("money");
      }
      
      private function startSound(param1:Class, param2:String, param3:Number = -1, param4:int = 1) : void
      {
         var _loc5_:SoundManager = null;
         var _loc6_:ISoundHandle = null;
         if(param1)
         {
            _loc5_ = Zlab.soundManager as SoundManager;
            _loc6_ = _loc5_.play(new param1(),null,param2,0,param4);
            if(param3 > 0)
            {
               _loc6_.volume = 0;
               TweenLite.to(_loc6_,param3,{"volume":1});
            }
         }
      }
      
      public function enableBombing() : void
      {
         m_window.bomb_bt.enabled = true;
         if(BomberGameManager.instance.canDropBomb())
         {
            m_window.bomb_bt.gotoAndStop(2);
            m_window.bomb_bt.ep_tf.visible = false;
            TextFieldUtil.compactTextField(m_window.generic_tf,String(BomberGameManager.instance.getBombCount()));
            m_window.bomb_bt.addEventListener(MouseEvent.CLICK,this.onDropBombClicked);
         }
         else
         {
            m_window.bomb_bt.gotoAndStop(3);
            m_window.bomb_bt.ep_tf.visible = true;
            TextFieldUtil.compactTextField(m_window.generic_tf,String(BomberGameManager.instance.getBombCount()));
            m_window.bomb_bt.addEventListener(MouseEvent.CLICK,this.buyBomb);
         }
      }
      
      public function disableBombing() : void
      {
         m_window.bomb_bt.enabled = false;
         m_window.bomb_bt.ep_tf.visible = false;
         m_window.bomb_bt.gotoAndStop(4);
      }
      
      public function loadGame(param1:Object = null) : void
      {
         this.m_stopped = false;
         addChild(m_window);
         Zlab.soundManager.stopCategorySounds(SoundManager.MUSIC_MIXER_CATEGORY);
         this.startSound(this.m_bgMusic,SoundManager.MUSIC_MIXER_CATEGORY,4,int.MAX_VALUE);
         TextFieldUtil.compactTextField(m_window.bomb_bt.ep_tf,String(this.m_bombPrice));
         this.gameTime = new Timer(2000);
         this.gameTime.addEventListener(TimerEvent.TIMER,this.onGameTimerComplete);
         this.gameTime.start();
         m_window.exit_bt.addEventListener(MouseEvent.CLICK,this.onExit);
         m_window.bomb_bt.enabled = true;
         m_window.bomb_bt.mouseEnabled = true;
         m_window.bomb_bt.buttonMode = true;
         m_window.meter_mc.mask_mc.width = this.m_rotation;
         if(!BomberGameManager.instance.gamePaused)
         {
            this.m_originalCrateX = m_window.part1_mc.crate_mc.x;
            this.m_originalItemX = m_window.part1_mc.icon.x;
            BomberGameManager.instance.originalCrateX = this.m_originalCrateX;
            BomberGameManager.instance.originalItemX = this.m_originalItemX;
         }
         else
         {
            this.m_originalCrateX = BomberGameManager.instance.originalCrateX;
            this.m_originalItemX = BomberGameManager.instance.originalItemX;
            this.resetX();
         }
         this.crateMoveTime = new Timer(CRATE_MOVE_TICK_TIME);
         this.crateMoveTime.addEventListener(TimerEvent.TIMER,this.moveTerrain);
         m_window.bomb_bt.gotoAndStop(4);
         this.crateMoveTime.start();
         Zlab.processManager.schedule(3000,this,this.enableBombing);
         initDialog();
      }
      
      private function resetX() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < NO_OF_CRATES)
         {
            this.m_parts[_loc1_].crate_mc.x = this.m_originalCrateX;
            this.m_parts[_loc1_].icon.x = this.m_originalItemX;
            _loc1_++;
         }
      }
      
      protected function moveTerrain(param1:TimerEvent) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < NO_OF_CRATES)
         {
            this.m_parts[_loc2_].x -= CRATE_MOVE_PIXEL;
            if(this.m_parts[_loc2_].x < -200)
            {
               this.m_parts[_loc2_].crate_mc.filters = [];
               this.m_parts[_loc2_].x = this.m_parts[(_loc2_ - 1 + NO_OF_CRATES) % NO_OF_CRATES].x + 190;
               this.m_parts[_loc2_].crate_mc.scaleX = 1;
               this.m_parts[_loc2_].crate_mc.scaleY = 1;
               this.m_parts[_loc2_].icon.scaleX = 1;
               this.m_parts[_loc2_].icon.scaleY = 1;
               this.m_parts[_loc2_].icon.unload();
               this.changeCrateType(_loc2_);
            }
            _loc2_++;
         }
      }
      
      protected function changeCrateType(param1:int) : void
      {
         var _loc3_:Number = NaN;
         var _loc6_:Date = null;
         var _loc7_:Number = NaN;
         var _loc2_:Boolean = BomberGameManager.instance.BombMode;
         this.m_currentIndex = param1;
         if(this.overlapChance)
         {
            this.overlapChance = false;
            _loc3_ = 50 + Math.random() * 10;
         }
         else
         {
            _loc3_ = Math.random() * 10 - 40;
         }
         if(_loc2_)
         {
            this.m_crateToHitIndex = param1;
            _loc6_ = new Date();
            this.m_crateGeneratedAt = _loc6_.time;
            _loc7_ = 80;
            _loc3_ = m_window.bomb_mc.x + (this.m_bombDropStartedAt + BOMB_DROP_TIME - this.m_crateGeneratedAt) * (CRATE_MOVE_PIXEL / CRATE_MOVE_TICK_TIME) - this.m_parts[param1].x - this.m_originalCrateX - _loc7_;
            _loc3_ = Math.min(120,_loc3_);
            _loc3_ = Math.max(-100,_loc3_);
            this.overlapChance = true;
            _loc2_ = false;
         }
         var _loc4_:String = BomberGameManager.instance.getCrateType();
         this.m_parts[param1].crate_mc.filters = BomberGameManager.instance.crateColourScheme[_loc4_];
         this.m_parts[param1].crate_mc.scaleX = BomberGameManager.instance.getScale(_loc4_);
         this.m_parts[param1].crate_mc.scaleY = BomberGameManager.instance.getScale(_loc4_);
         this.m_parts[param1].crate_mc.x = this.m_originalCrateX + _loc3_;
         this.m_parts[param1].icon.scaleX = BomberGameManager.instance.getScale(_loc4_);
         this.m_parts[param1].icon.scaleY = BomberGameManager.instance.getScale(_loc4_);
         this.m_parts[param1].icon.x = this.m_parts[param1].crate_mc.x - this.m_parts[param1].icon.width / 2;
         this.m_parts[param1].icon.y = this.m_parts[param1].crate_mc.y - this.m_parts[param1].crate_mc.height / 2 - this.m_parts[param1].icon.height / 2;
         this.m_parts[param1].crate_mc.visible = true;
         this.m_parts[param1].icon.visible = true;
         var _loc5_:Number = Math.floor(this.m_parts[param1].background_mc.totalFrames * Math.random());
         this.m_parts[param1].background_mc.gotoAndStop(_loc5_);
         this.addIconToCrate(_loc4_,param1);
      }
      
      protected function onDropBombClicked(param1:MouseEvent = null) : void
      {
         m_window.bomb_bt.removeEventListener(MouseEvent.CLICK,this.onDropBombClicked);
         if(BomberGameManager.instance.Fuel <= 0 || BomberGameManager.instance.canDropBomb() == false)
         {
            return;
         }
         this.m_rewardWaitStarted = true;
         m_window.bomb_bt.enabled = false;
         m_window.bomb_bt.gotoAndStop(1);
         m_window.bomb_mc.visible = true;
         m_window.bomb_mc.play();
         var _loc2_:Date = new Date();
         this.m_bombDropStartedAt = _loc2_.time;
         BomberGameManager.instance.BombMode = true;
         Zlab.processManager.schedule(BOMB_DROP_TIME,this,this.pauseGame);
         var _loc3_:String = BomberGameManager.instance.onBombDrop(this.rsc,this.rsr);
         this.disableBombing();
         this.m_transactionCompleted = false;
         TransactionManager.addTransaction(new TDropBomb(this),true);
      }
      
      protected function checkBombState(param1:TimerEvent) : void
      {
         var _loc3_:Date = null;
         var _loc4_:Number = NaN;
         var _loc2_:Number = Number(m_window.bomb_mc.totalFrames);
         if(m_window.bomb_mc.currentFrame >= _loc2_ - 80 && !this.m_paused)
         {
            _loc3_ = new Date();
            _loc4_ = _loc3_.time;
            this.pauseGame();
         }
         if(m_window.bomb_mc.currentFrame >= _loc2_)
         {
            this.bombDropTimer.stop();
            this.bombDropTimer.removeEventListener(TimerEvent.TIMER,this.checkBombState);
         }
      }
      
      protected function onExit(param1:MouseEvent) : void
      {
         this.closeGame();
      }
      
      public function onBombDropSuccess(param1:Object) : void
      {
         this.rsc = param1.sc;
         this.rsr = param1.sr;
         BomberGameManager.instance.rsc = this.rsc;
         BomberGameManager.instance.calculateNextReward(this.rsr);
         this.m_transactionCompleted = true;
         if(!this.m_paused)
         {
            this.enableBombing();
         }
         if(param1.fuel < BomberGameManager.instance.Fuel)
         {
            BomberGameManager.instance.Fuel = param1.fuel;
         }
         this.m_rewardData = param1.reward;
         if(param1.reward == "0")
         {
            m_window.rewardPopup_mc.visible = false;
            return;
         }
         this.addToRewardQueue(this.m_rewardData);
      }
      
      private function showRewardToaster() : void
      {
         var _loc4_:String = null;
         var _loc5_:ImageLoader = null;
         var _loc7_:GameItem = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         if(this.m_rewardQueue.length == 0)
         {
            if(BomberGameManager.instance.Fuel <= 0)
            {
               Zlab.processManager.schedule(BOMB_DROP_TIME,this,this.closeGame);
            }
            return;
         }
         var _loc1_:Object = this.m_rewardQueue[0];
         this.m_rewardQueue.shift();
         this.currentReward = _loc1_.itemCode;
         var _loc2_:Number = Number(_loc1_.amount);
         var _loc3_:String = _loc1_.handler;
         var _loc6_:int = 0;
         TextFieldUtil.compactTextField(m_window.rewardPopup_mc.reward_tf,ZGameUtils.ZlocT("Dialogs","bomber_reward_title"));
         if(_loc3_ == "addLootToInventory")
         {
            ZGlobal.player.addToInventory(this.currentReward,_loc2_);
            _loc6_ = 2;
            _loc7_ = ZGlobal.gameSettings.getItemByCode(this.currentReward,GameItem) as GameItem;
            _loc4_ = ZGlobal.gameSettings.getImageByName(_loc7_.name,"icon");
            TextFieldUtil.compactTextField(m_window.rewardPopup_mc.name_tf,_loc7_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
            _loc5_ = ImageLoaderFactory.CreateImageLoader(_loc4_,m_window.rewardPopup_mc.rewardIcon);
            TextFieldUtil.compactTextField(m_window.rewardPopup_mc.qty_tf,"x" + _loc2_.toString());
         }
         else if(_loc3_ == "awardUserCash")
         {
            ZGlobal.player.cash += _loc2_;
            this.updateCashUI();
            _loc6_ = 3;
            TextFieldUtil.compactTextField(m_window.rewardPopup_mc.name_tf,ZGameUtils.ZlocT("Main","Cash"));
            _loc4_ = "assets/game/GeneralAssetGroup_UI.swf/EmpirePoints_60.png";
            _loc5_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(_loc4_),m_window.rewardPopup_mc.rewardIcon);
            TextFieldUtil.compactTextField(m_window.rewardPopup_mc.qty_tf,"x" + _loc2_.toString());
         }
         else if(_loc3_ == "awardUserXP")
         {
            _loc6_ = 0;
            ZGlobal.player.xp += _loc2_;
            TextFieldUtil.compactTextField(m_window.rewardPopup_mc.name_tf,ZGameUtils.ZlocT("Main","XP"));
            _loc4_ = "assets/game/GeneralAssetGroup_UI.swf/Star_60.png";
            _loc5_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(_loc4_),m_window.rewardPopup_mc.rewardIcon);
            TextFieldUtil.compactTextField(m_window.rewardPopup_mc.qty_tf,"x" + _loc2_.toString());
         }
         else
         {
            _loc6_ = 1;
            _loc8_ = WorldResourceManager.instance.getResourceImageURLByType(this.currentReward,WorldResourceManager.XTRA_LARGE_ICON);
            _loc9_ = WorldResourceManager.instance.getResourceFriendlyNameFromType(this.currentReward,GameItem.MENU_FRIENDLYNAME);
            TextFieldUtil.compactTextField(m_window.rewardPopup_mc.name_tf,_loc9_);
            _loc5_ = ImageLoaderFactory.CreateImageLoader(_loc8_,m_window.rewardPopup_mc.rewardIcon);
            TextFieldUtil.compactTextField(m_window.rewardPopup_mc.qty_tf,"x" + _loc2_.toString());
            ZGlobal.player.resources.updateResourceAmount(this.currentReward,_loc2_);
         }
         m_window.rewardPopup_mc.strength_mc.visible = false;
         _loc5_.smooth = true;
         m_window.rewardPopup_mc.visible = true;
         m_window.rewardPopup_mc.qty_tf.visible = true;
         BomberGameManager.instance.addMiniGameReward(_loc6_ + "," + this.currentReward + "," + _loc2_);
         if(BomberGameManager.instance.Fuel <= 0)
         {
            m_window.bomb_bt.enabled = false;
            m_window.bomb_bt.ep_tf.visible = false;
            m_window.bomb_bt.gotoAndStop(4);
            if(BomberGameManager.instance.getBombCount() > 0)
            {
               m_window.bomb_bt.removeEventListener(MouseEvent.CLICK,this.onDropBombClicked);
            }
            else
            {
               m_window.bomb_bt.removeEventListener(MouseEvent.CLICK,this.buyBomb);
            }
         }
         Zlab.processManager.schedule(1000,this,this.hideRewardToaster);
      }
      
      private function hideRewardToaster() : void
      {
         m_window.rewardPopup_mc.visible = false;
         m_window.rewardPopup_mc.rewardIcon.unload();
         if(Boolean(this.m_rewardQueue) && this.m_rewardQueue.length >= 1)
         {
            Zlab.processManager.schedule(2800,this,this.showRewardToaster);
         }
         else if(BomberGameManager.instance.Fuel <= 0)
         {
            Zlab.processManager.schedule(BOMB_DROP_TIME,this,this.closeGame);
            m_window.bomb_bt.enabled = false;
            m_window.bomb_bt.ep_tf.visible = false;
            m_window.bomb_bt.gotoAndStop(4);
            if(BomberGameManager.instance.getBombCount() > 0)
            {
               m_window.bomb_bt.removeEventListener(MouseEvent.CLICK,this.onDropBombClicked);
            }
            else
            {
               m_window.bomb_bt.removeEventListener(MouseEvent.CLICK,this.buyBomb);
            }
            this.m_rewardWaitStarted = false;
         }
         else
         {
            this.m_rewardWaitStarted = false;
         }
      }
      
      private function addToRewardQueue(param1:Object) : void
      {
         if(this.m_rewardQueue == null)
         {
            this.m_rewardQueue = new Array();
         }
         this.m_rewardQueue.push(param1);
         if(this.m_rewardQueue.length == 1)
         {
            Zlab.processManager.schedule(2800,this,this.showRewardToaster);
         }
      }
      
      private function addIconToCrate(param1:String, param2:Number) : void
      {
         var _loc7_:GameItem = null;
         var _loc8_:ImageLoader = null;
         var _loc3_:String = BomberGameManager.instance.getCrateIcon(param1);
         if(_loc3_ == "")
         {
            return;
         }
         var _loc4_:Array = _loc3_.split(",");
         if(_loc4_.length == 0)
         {
            return;
         }
         var _loc5_:Number = Math.floor(Math.random() * _loc4_.length);
         _loc5_ = Math.min(_loc5_,_loc4_.length - 1);
         _loc3_ = _loc4_[_loc5_];
         var _loc6_:String = "";
         if(_loc3_ == "xp")
         {
            _loc6_ = ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/Star_60.png");
         }
         else if(_loc3_ == "cash")
         {
            _loc6_ = ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/EmpirePoints_60.png");
         }
         else
         {
            _loc7_ = ZGlobal.gameSettings.getItemByCode(_loc3_,GameItem) as GameItem;
            if(!_loc7_)
            {
               _loc6_ = WorldResourceManager.instance.getResourceImageURLByType(_loc3_,WorldResourceManager.SMALL_ICON);
            }
            else
            {
               _loc6_ = ZGlobal.gameSettings.getImageByName(_loc7_.name,"icon");
            }
         }
         if(_loc6_ != "")
         {
            _loc8_ = ImageLoaderFactory.CreateImageLoader(_loc6_,this.m_parts[param2].icon);
         }
         _loc8_.smooth = true;
      }
      
      public function onGameTimerComplete(param1:TimerEvent) : void
      {
         BomberGameManager.instance.updateFuel(2);
         BomberGameManager.instance.setLastPlayedTime();
         this.m_rotation = (MAX_ANGLE - MIN_ANGLE) / BomberGameManager.instance.TotalFuel * BomberGameManager.instance.Fuel;
         if(this.m_rotation <= MIN_ANGLE)
         {
            this.m_rotation = MIN_ANGLE;
         }
         if(this.m_rotation >= MAX_ANGLE)
         {
            this.m_rotation = MAX_ANGLE;
         }
         m_window.meter_mc.mask_mc.width = this.m_rotation;
         if(BomberGameManager.instance.Fuel <= 0)
         {
            this.gameTime.stop();
            this.gameTime.removeEventListener(TimerEvent.TIMER,this.onGameTimerComplete);
            m_window.bomb_bt.ep_tf.visible = false;
            m_window.bomb_bt.gotoAndStop(4);
            if(!this.m_rewardWaitStarted && this.m_rewardQueue.length <= 0)
            {
               Zlab.processManager.schedule(BOMB_DROP_TIME,this,this.closeGame);
               m_window.bomb_bt.enabled = false;
               if(BomberGameManager.instance.getBombCount() > 0)
               {
                  m_window.bomb_bt.removeEventListener(MouseEvent.CLICK,this.onDropBombClicked);
               }
               else
               {
                  m_window.bomb_bt.removeEventListener(MouseEvent.CLICK,this.buyBomb);
               }
            }
         }
      }
      
      public function pauseGame() : void
      {
         var _loc1_:Number = NaN;
         if(!this.m_paused)
         {
            this.m_paused = true;
            this.crateMoveTime.stop();
            _loc1_ = Math.abs(this.m_parts[this.m_crateToHitIndex].x + this.m_parts[this.m_crateToHitIndex].crate_mc.x - m_window.bomb_mc.x);
            if(_loc1_ > 160)
            {
               StatsManager.count("dialog","mini_game","crate_miss",_loc1_.toString());
            }
            else
            {
               this.m_parts[this.m_crateToHitIndex].crate_mc.visible = false;
               this.m_parts[this.m_crateToHitIndex].icon.visible = false;
            }
            SoundEvent.getSoundEvent(BOMB_SOUND).play();
            Zlab.processManager.schedule(2000,this,this.unpauseGame);
         }
      }
      
      public function unpauseGame() : void
      {
         this.crateMoveTime.start();
         this.m_paused = false;
         if(BomberGameManager.instance.Fuel <= 0)
         {
            return;
         }
         if(this.m_transactionCompleted)
         {
            this.enableBombing();
         }
         m_window.bomb_mc.visible = false;
         m_window.bomb_mc.gotoAndStop(1);
      }
      
      public function loadEndBomberPopup(param1:Event = null) : void
      {
         close();
         PopupManager.instance.push(new EndBomberPopup("true"));
      }
      
      private function buyItemConfirmed(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.YES)
         {
            this.buyItem(BomberGameManager.PAID_BOMB_CODE);
         }
      }
      
      public function buyBomb(param1:MouseEvent) : void
      {
         var _loc4_:String = null;
         var _loc5_:Object = null;
         var _loc6_:String = null;
         m_window.bomb_bt.removeEventListener(MouseEvent.CLICK,this.buyBomb);
         if(BomberGameManager.instance.Fuel <= 0)
         {
            return;
         }
         m_window.bomb_bt.gotoAndStop(1);
         var _loc2_:XML = ZGlobal.gameSettings.getItemXMLByCode(BomberGameManager.PAID_BOMB_CODE);
         var _loc3_:Number = this.m_bombPrice;
         if(ZGlobal.player.canBuyCash(_loc3_,false,"",false))
         {
            if(ZGlobal.gameSettings.showConfirmationPopup(_loc3_))
            {
               _loc4_ = ZGameUtils.ZlocT("Dialogs","BuildingPartConfirmPartBuyTitle");
               _loc5_ = ZGameUtils.CashTokenReplacements(_loc3_);
               _loc6_ = ZGameUtils.ZlocT("Dialogs","BuyBomb",_loc5_);
               this.m_buyPopup = GenericPopup2B.NewYesNo(_loc6_,_loc4_,this.buyItemConfirmed);
               this.m_buyPopup.userData = {
                  "item":_loc2_.code,
                  "amount":_loc3_
               };
               PopupManager.instance.push(this.m_buyPopup,0,false);
            }
            else
            {
               this.buyItem(BomberGameManager.PAID_BOMB_CODE);
            }
         }
         else
         {
            PopupManager.instance.push(new NotEnoughCashPopup(ZGameUtils.ZlocT("Dialogs","ImpulseCash"),GenericPopup.TYPE_OK,this.closeGame),0,false);
            m_window.bomb_bt.gotoAndStop(4);
            m_window.bomb_bt.ep_tf.visible = false;
         }
      }
      
      private function buyItem(param1:String, param2:int = 1) : void
      {
         m_window.bomb_bt.gotoAndStop(2);
         m_window.bomb_bt.ep_tf.visible = false;
         var _loc3_:Boolean = true;
         var _loc4_:Object = new Object();
         _loc4_.buyType = "mini_game|extrabomb";
         var _loc5_:GameItem = ZGlobal.gameSettings.getItemByCode(param1,GameItem) as GameItem;
         ZGlobal.player.buyItem(_loc5_,_loc3_,param2);
         ZGlobal.player.addToInventory(param1,param2);
         this.updateCashUI();
         TextFieldUtil.compactTextField(m_window.generic_tf,String(BomberGameManager.instance.getBombCount()));
         TransactionManager.addTransaction(new TBuyItem(param1,_loc3_,param2,_loc4_));
         this.onDropBombClicked();
      }
      
      private function closeGame(param1:Event = null) : void
      {
         var _loc2_:XML = null;
         var _loc3_:String = null;
         BomberGameManager.instance.gamePaused = true;
         if(!this.m_stopped)
         {
            this.m_stopped = true;
            TransactionManager.addTransaction(new TStopGame(this),true);
            if(BomberGameManager.instance.getBombCount() > 0)
            {
               m_window.bomb_bt.removeEventListener(MouseEvent.CLICK,this.onDropBombClicked);
            }
            else
            {
               m_window.bomb_bt.removeEventListener(MouseEvent.CLICK,this.buyBomb);
            }
            if(this.gameTime)
            {
               this.gameTime.stop();
               this.gameTime.removeEventListener(TimerEvent.TIMER,this.onGameTimerComplete);
            }
            if(this.crateMoveTime)
            {
               this.crateMoveTime.stop();
               this.crateMoveTime.removeEventListener(TimerEvent.TIMER,this.moveTerrain);
            }
            if(this.bombDropTimer)
            {
               this.bombDropTimer.stop();
               this.bombDropTimer.removeEventListener(TimerEvent.TIMER,this.checkBombState);
            }
            Zlab.soundManager.stopCategorySounds(SoundManager.MUSIC_MIXER_CATEGORY);
            _loc2_ = ZGlobal.gameSettings.getSoundXMLByName("islandmusic");
            _loc3_ = _loc2_["@url"];
            Zlab.soundManager.stream(ZGlobal.getAssetURL(_loc3_),SoundManager.MUSIC_MIXER_CATEGORY,0,int.MAX_VALUE);
            Zlab.processManager.removeScheduledObject(this,this.pauseGame);
            Zlab.processManager.removeScheduledObject(this,this.showRewardToaster);
            Zlab.processManager.removeScheduledObject(this,this.closeGame);
            Zlab.processManager.removeScheduledObject(this,this.hideRewardToaster);
            Zlab.processManager.removeScheduledObject(this,this.unpauseGame);
            this.m_rewardQueue = null;
            removeChild(m_window);
         }
      }
   }
}

