package displays.screens.leaderboard
{
   import Engine.Managers.TransactionManager;
   import ZLocalization.LocaleFormatter;
   import core.ZGameStats;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.RewardHelper;
   import core.managers.WorldResourceManager;
   import core.managers.leaderboardManager.Leaderboard;
   import core.managers.leaderboardManager.LeaderboardManager;
   import core.managers.viralsManager.ViralsManager;
   import core.player.Player;
   import core.ui.Tooltip;
   import core.ui.ZGameButton;
   import core.ui.menuitem.FriendsBarUIItem;
   import displays.ImageLoaderFactory;
   import displays.popups.FeedPopup;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.popups.genericPopup.NotEnoughCashPopup;
   import displays.screens.neighborScreen.ContextualMenuWrapperAlly;
   import displays.screens.neighborScreen.NeighborGrid;
   import displays.screens.neighborScreen.NeighborSlot;
   import fl.containers.UILoader;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import transactions.TCollectLeaderBoard;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class Board
   {
      
      public static const ERROR:int = 0;
      
      public static const REWARD:int = 1;
      
      public static const PLAYER:int = 2;
      
      public static const SKIP_ENTRY:int = 3;
      
      protected const REWARD_NONE:int = -1;
      
      protected const REWARD_PLATINUM:uint = 0;
      
      protected const REWARD_GOLD:uint = 1;
      
      protected const REWARD_SILVER:uint = 2;
      
      protected const REWARD_BRONZE:uint = 3;
      
      protected var m_leaderboard:Leaderboard = null;
      
      protected var m_buttons:Array = null;
      
      protected var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private var m_barDisplay:BarDisplay = null;
      
      private var m_parentScreen:MovieClip = null;
      
      private var m_store:Dictionary = null;
      
      private var m_shareButton:ZGameButton = null;
      
      private var m_activeBars:Dictionary = null;
      
      private var m_clickHandlers:Array = null;
      
      private var m_contextMenu:MovieClip = null;
      
      private var m_allowPlayerClicking:Boolean = false;
      
      public function Board(param1:Leaderboard, param2:Boolean)
      {
         super();
         this.m_leaderboard = param1;
         this.m_barDisplay = param1.barDisplay;
         this.m_allowPlayerClicking = param2;
      }
      
      public static function createBoard(param1:Leaderboard, param2:Boolean) : Board
      {
         switch(param1.type)
         {
            case Leaderboard.TYPE_CAMPAIGN:
               return new CampaignBoard(param1,param2);
            case Leaderboard.TYPE_CAMPAIGN2:
               return new Campaign2Board(param1,param2);
            case Leaderboard.TYPE_SURVIVAL:
            case Leaderboard.TYPE_SURVIVAL3:
               return new SurvivalBoard(param1,param2);
            case Leaderboard.TYPE_SURVIVAL2:
               return new SurvivalBoard2(param1,param2);
            case Leaderboard.TYPE_DAMAGE:
               return new DamageDashBoard(param1,param2);
            case Leaderboard.TYPE_GPVP_DAMAGE:
               return new GlobalPVPDamageDashBoard(param1,param2);
            case Leaderboard.TYPE_SURVIVAL_DAMAGE:
               return new SurvivalDamageDashBoard(param1,param2);
            case Leaderboard.TYPE_RESOURCE:
               return new ResourceDashBoard(param1,param2);
            case Leaderboard.TYPE_HONOR:
               return new HonorDashBoard(param1,param2);
            case Leaderboard.TYPE_INFAMY:
               return new InfamyDashBoard(param1,param2);
            case Leaderboard.TYPE_XP:
               return new XpDashBoard(param1,param2);
            case Leaderboard.TYPE_UNITS_KILLED:
               return new UnitsKilledDashBoard(param1,param2);
            case Leaderboard.TYPE_CRITICAL_HITS:
               return new CriticalHitsDashBoard(param1,param2);
            case Leaderboard.TYPE_EXPANSIONS:
               return new ExpansionsDashBoard(param1,param2);
            case Leaderboard.TYPE_GLANCING_BLOWS:
               return new GlancingBlowsDashBoard(param1,param2);
            case Leaderboard.TYPE_NEIGHBOR_TENDS:
               return new NeighborTendsDashBoard(param1,param2);
            case Leaderboard.TYPE_RESEARCH_UPGRADES:
               return new ResearchUpgradesDashBoard(param1,param2);
            case Leaderboard.TYPE_ELEMENT_Z_CONSUMED:
               return new ElementZConsumedDashBoard(param1,param2);
            case Leaderboard.TYPE_WHITE_KNIGHT_REPELS:
               return new WhiteKnightRepelsDashBoard(param1,param2);
            case Leaderboard.TYPE_POWER_UP_ADDICT:
               return new PowerUpAddictDashBoard(param1,param2);
            case Leaderboard.TYPE_VILLAIN_TOKENS:
               return new VillainTokensBoard(param1,param2);
            case Leaderboard.TYPE_DOMINATION_SCORE_GAINED:
               return new DominationScoreGainedBoard(param1,param2);
            default:
               return new Board(param1,param2);
         }
      }
      
      public function dispose(param1:Array) : void
      {
         this.hide(param1);
         this.m_parentScreen = null;
         this.m_leaderboard = null;
         this.m_shareButton = null;
      }
      
      public function hide(param1:Array) : void
      {
         var _loc2_:EventDispatcher = null;
         var _loc3_:MovieClip = null;
         this.disposeButtons();
         this.disposeMenu();
         this.m_activeBars = null;
         for each(_loc2_ in this.m_clickHandlers)
         {
            _loc2_.removeEventListener(MouseEvent.CLICK,this.onPlayerClicked);
            _loc2_.removeEventListener(MouseEvent.MOUSE_OVER,this.onPlayerOver);
            _loc2_.removeEventListener(MouseEvent.MOUSE_OUT,this.onPlayerOut);
         }
         this.m_clickHandlers = null;
         for each(_loc3_ in param1)
         {
            this.hideAllTrophies(_loc3_);
            Tooltip.unsubscribe(_loc3_.icon_mc);
         }
      }
      
      public function get leaderboard() : Leaderboard
      {
         return this.m_leaderboard;
      }
      
      public function set parentScreen(param1:MovieClip) : void
      {
         this.m_parentScreen = param1;
      }
      
      public function getValues(param1:int, param2:int) : Array
      {
         return this.m_leaderboard.results.slice(param1,param2);
      }
      
      public function get numValues() : uint
      {
         return this.m_leaderboard.results.length;
      }
      
      public function get numValidEntries() : uint
      {
         return this.m_leaderboard.numEntries;
      }
      
      public function get activePlayers() : uint
      {
         return this.m_leaderboard.results.length - this.m_leaderboard.numParticipationRewards;
      }
      
      public function get id() : String
      {
         return this.m_leaderboard.id;
      }
      
      public function get title() : String
      {
         return ZGameUtils.ZlocT("Leaderboards",this.m_leaderboard.xml.info.@title);
      }
      
      public function get summary() : String
      {
         return ZGameUtils.ZlocT("Leaderboards",this.m_leaderboard.xml.info.@summary);
      }
      
      public function get description() : String
      {
         return ZGameUtils.ZlocT("Leaderboards",this.m_leaderboard.xml.info.@desc);
      }
      
      public function get hint() : String
      {
         return ZGameUtils.ZlocT("Leaderboards","Leaderboards_OreHint1");
      }
      
      public function get isTimed() : Boolean
      {
         return Boolean(this.m_leaderboard.xml.requiredDate) && this.m_leaderboard.xml.requiredDate != undefined;
      }
      
      public function get remainingTime() : String
      {
         var _loc1_:Object = new Object();
         var _loc2_:int = ZGameTimeUtil.instance.getDateStatus(_loc1_,this.m_leaderboard.xml);
         if(_loc2_ == ZGameTimeUtil.DATE_STATUS_ACTIVE)
         {
            return ZGameUtils.ZlocT("Leaderboards","Leaderboards_TimeLeft",{"time":_loc1_.string});
         }
         return null;
      }
      
      public function get tabIcon() : String
      {
         return this.m_leaderboard.tabIcon;
      }
      
      public function get icon() : String
      {
         return null;
      }
      
      public function get rank() : uint
      {
         return this.m_leaderboard.ranking(ZGlobal.player.uid);
      }
      
      public function getPlayerIndex(param1:String) : uint
      {
         return this.m_leaderboard.getIndex(param1);
      }
      
      public function get rewardToCollect() : Boolean
      {
         return this.m_leaderboard.rewardToCollect;
      }
      
      public function allRewardsCollected(param1:int) : Boolean
      {
         return this.m_leaderboard.allPossibleRewardsCollected(param1);
      }
      
      public function beginPopulation(param1:Array) : void
      {
         var _loc2_:Object = null;
         this.disposeButtons();
         this.disposeMenu();
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_store = new Dictionary();
         this.m_clickHandlers = new Array();
         if(this.m_activeBars)
         {
            for each(_loc2_ in this.m_activeBars)
            {
               if(Boolean(_loc2_.uiloader.source) && Boolean(_loc2_.uiloader.source.bitmapData))
               {
                  this.m_store[_loc2_.uid] = _loc2_.uiloader.source.bitmapData;
               }
            }
         }
         this.m_activeBars = new Dictionary();
         this.m_buttons = new Array();
      }
      
      public function populateBar(param1:MovieClip, param2:int) : int
      {
         var _loc3_:Object = null;
         if(param2 < this.m_leaderboard.results.length)
         {
            _loc3_ = this.m_leaderboard.results[param2];
            if(_loc3_.player)
            {
               if(this.validatePlayer(_loc3_.player))
               {
                  this.populatePlayer(param1,_loc3_);
                  return PLAYER;
               }
               return SKIP_ENTRY;
            }
            if(this.validateReward(_loc3_.reward))
            {
               this.populateReward(param1,_loc3_.reward,_loc3_.rewardIndex);
               return REWARD;
            }
            return SKIP_ENTRY;
         }
         this.initBar(param1);
         return ERROR;
      }
      
      public function getReward(param1:Object) : int
      {
         var _loc2_:int = 0;
         var _loc3_:Array = null;
         if(param1.value > 0)
         {
            _loc2_ = int(this.numValidEntries);
            if(param1.localRank < 4)
            {
               _loc3_ = [this.REWARD_GOLD,this.REWARD_SILVER,this.REWARD_BRONZE];
               return _loc3_[param1.localRank - 1];
            }
         }
         return this.REWARD_NONE;
      }
      
      protected function validatePlayer(param1:Player) : Boolean
      {
         return true;
      }
      
      protected function validateReward(param1:XML) : Boolean
      {
         return true;
      }
      
      public function trophies(param1:MovieClip) : Array
      {
         return [param1.platinumTrophy_mc,param1.goldTrophy_mc,param1.silverTrophy_mc,param1.bronzeTrophy_mc];
      }
      
      public function globeTrophies(param1:MovieClip) : Array
      {
         return [param1.platinumTrophy_mc,param1.goldTrophy_mc_globe,param1.silverTrophy_mc_globe,param1.bronzeTrophy_mc_globe];
      }
      
      private function initBar(param1:MovieClip) : void
      {
         param1.visible = true;
         ZGameUtils.hideIfExists(param1.check_mc);
         ZGameUtils.hideIfExists(param1.level_mc);
         ZGameUtils.hideIfExists(param1.reward_tf);
         ZGameUtils.hideIfExists(param1.return_mc);
         ZGameUtils.hideIfExists(param1.rank_tf);
         ZGameUtils.hideIfExists(param1.name_tf);
         ZGameUtils.hideIfExists(param1.blueBar_mc);
         ZGameUtils.hideIfExists(param1.goldBar_mc);
         ZGameUtils.hideIfExists(param1.rewardname_tf);
         ZGameUtils.hideIfExists(param1.requiredScore_tf);
         ZGameUtils.hideIfExists(param1.required_tf);
         ZGameUtils.hideIfExists(param1.score_tf);
         ZGameUtils.hideIfExists(param1.total_tf);
         ZGameUtils.hideIfExists(param1.brownBar_mc);
         if(ZGameUtils.hideIfExists(param1.profile_mc))
         {
            if(ZGameUtils.hideIfExists(param1.profile_mc.highlightSelect_mc))
            {
               param1.profile_mc.highlightSelect_mc.mouseEnabled = false;
            }
         }
         if(ZGameUtils.hideIfExists(param1.starburst_mc))
         {
            param1.starburst_mc.gotoAndStop(1);
         }
         if(ZGameUtils.hideIfExists(param1.icon_mc))
         {
            Tooltip.unsubscribe(param1.icon_mc);
         }
      }
      
      protected function populateReward(param1:MovieClip, param2:XML, param3:int) : void
      {
         var _loc4_:GameItem = null;
         var _loc5_:RewardHelper = null;
         var _loc6_:Object = null;
         var _loc7_:int = 0;
         var _loc8_:ZGameButton = null;
         this.initBar(param1);
         if(ZGameUtils.showIfExists(param1.required_tf))
         {
            TextFieldUtil.processTextField(param1.required_tf,ZGameUtils.ZlocT("Leaderboards","Leaderboards_RequireScore"));
         }
         if(ZGameUtils.showIfExists(param1.rewardname_tf))
         {
            TextFieldUtil.processTextField(param1.rewardname_tf,ZGameUtils.ZlocT("Leaderboards",param2.@name.toString()));
         }
         ZGameUtils.showIfExists(param1.goldBar_mc);
         ZGameUtils.showIfExists(param1.requiredScore_tf);
         TextFieldUtil.processTextField(param1.requiredScore_tf,LocaleFormatter.formatNumber(param2.@value));
         if(param2.@item != undefined)
         {
            param1.icon_mc.visible = true;
            _loc4_ = ZGlobal.gameSettings.getItemByCode(param2.@item,GameItem) as GameItem;
            ImageLoaderFactory.CreateImageLoader(_loc4_.getCachedImage("icon").url,param1.icon_mc);
            Tooltip.subscribe(param1.icon_mc,ZGameUtils.ZlocT("Leaderboards","Leaderboards_ParticipationTooltip"));
            if(ZGameUtils.showIfExists(param1.reward_tf))
            {
               _loc5_ = new RewardHelper(param2);
               _loc6_ = new Object();
               _loc6_.rewardText = new Array();
               _loc5_.buildUI(_loc6_,0);
               TextFieldUtil.processTextField(param1.reward_tf,_loc6_.rewardText[0]);
            }
         }
         if(this.m_leaderboard.completedRewards[param3])
         {
            this.rewardCollected(param1);
         }
         else
         {
            _loc7_ = this.m_leaderboard.getValue(ZGlobal.player.uid);
            if(_loc7_ >= param2.@value)
            {
               if(ZGameUtils.showIfExists(param1.return_mc))
               {
                  _loc8_ = new ZGameButton(param1.return_mc,this.onBarButtonClicked);
                  _loc8_.buttonValue = param3.toString();
                  _loc8_.text = ZGameUtils.ZlocT("Leaderboards","Leaderboards_Collect");
                  this.m_buttons.push(_loc8_);
                  this.m_buttonSounds.addButton(_loc8_.m_overlay,ButtonSound.DEFAULT);
               }
               if(ZGameUtils.showIfExists(param1.starburst_mc))
               {
                  param1.starburst_mc.gotoAndPlay(1);
               }
            }
         }
         this.hideAllTrophies(param1);
      }
      
      protected function populatePlayer(param1:MovieClip, param2:Object) : void
      {
         var _loc6_:ZGameButton = null;
         this.initBar(param1);
         var _loc3_:Player = param2.player;
         var _loc4_:int = int(param2.value);
         this.m_activeBars[param2.player.uid] = new Object();
         this.m_activeBars[param2.player.uid].bar = param1;
         if(ZGameUtils.showIfExists(param1.total_tf))
         {
            TextFieldUtil.processTextField(param1.total_tf,this.m_barDisplay.requireText(_loc4_));
         }
         if(ZGameUtils.showIfExists(param1.name_tf))
         {
            TextFieldUtil.processTextField(param1.name_tf,_loc3_.firstName);
            TextFieldUtil.processTextField(param1.level_mc.level_tf,_loc3_.level.toString());
         }
         param1.rank_tf.visible = true;
         TextFieldUtil.processTextField(param1.rank_tf,param2.localRank.toString());
         param1.score_tf.visible = true;
         TextFieldUtil.processTextField(param1.score_tf,LocaleFormatter.formatNumber(_loc4_));
         if(param1.profile_mc)
         {
            param1.profile_mc.visible = true;
            if(param1.profile_mc as UILoader)
            {
               this.loadPlayerImage(_loc3_,param1.profile_mc);
            }
            else
            {
               this.loadPlayerImage(_loc3_,param1.profile_mc.icon);
            }
         }
         var _loc5_:Boolean = _loc3_.uid == ZGlobal.player.uid;
         param1.blueBar_mc.visible = _loc5_;
         param1.brownBar_mc.visible = !_loc5_;
         if(this.allowPlacementRewardCollection(param2))
         {
            if(this.m_leaderboard.completedRewards[Leaderboard.PLACEMENT_REWARD_INDEX])
            {
               this.rewardCollected(param1);
            }
            else if(ZGameUtils.showIfExists(param1.return_mc))
            {
               _loc6_ = new ZGameButton(param1.return_mc,this.onPlacementRewardClicked);
               _loc6_.buttonValue = param2.localRank.toString();
               _loc6_.text = ZGameUtils.ZlocT("Leaderboards","Leaderboards_Collect");
               this.m_buttons.push(_loc6_);
               this.m_buttonSounds.addButton(_loc6_.m_overlay,ButtonSound.DEFAULT);
            }
         }
         if(this.addShareButton)
         {
            if(Boolean(this.m_parentScreen) && ZGameUtils.showIfExists(this.m_parentScreen.return_mc))
            {
               this.m_shareButton = new ZGameButton(this.m_parentScreen.return_mc,this.onPlacementShareClicked);
               this.m_shareButton.buttonValue = _loc3_.uid;
               this.m_shareButton.text = ZGameUtils.ZlocT("Dialogs","Share");
               this.m_buttons.push(this.m_shareButton);
               this.m_buttonSounds.addButton(this.m_shareButton.m_overlay,ButtonSound.DEFAULT);
            }
         }
         this.hideAllTrophies(param1);
         this.showTrophies(param1,param2);
      }
      
      private function loadPlayerImage(param1:Player, param2:UILoader) : void
      {
         this.m_activeBars[param1.uid].uiloader = param2;
         this.m_activeBars[param1.uid].url = param1.portraitURL;
         this.m_activeBars[param1.uid].uid = param1.uid;
         if(this.m_allowPlayerClicking && ZGlobal.player.uid != param1.uid)
         {
            param2.buttonMode = true;
            param2.useHandCursor = true;
            param2.addEventListener(MouseEvent.CLICK,this.onPlayerClicked);
            param2.addEventListener(MouseEvent.MOUSE_OVER,this.onPlayerOver);
            param2.addEventListener(MouseEvent.MOUSE_OUT,this.onPlayerOut);
            this.m_clickHandlers.push(param2);
            this.m_buttonSounds.addButton(param2,ButtonSound.DEFAULT);
         }
         else
         {
            param2.buttonMode = false;
            param2.useHandCursor = false;
         }
         if(this.m_store[param1.uid])
         {
            param2.source = new Bitmap(this.m_store[param1.uid]);
            param2.load();
         }
         else
         {
            param2.unload();
            ImageLoaderFactory.CreateImageLoader(param1.portraitURL,null,this.onPlayerImageLoaded);
         }
      }
      
      private function getPlayerObject(param1:Object) : Object
      {
         var _loc2_:Object = null;
         for each(_loc2_ in this.m_activeBars)
         {
            if(_loc2_.uiloader == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      private function onPlayerClicked(param1:MouseEvent) : void
      {
         var _loc3_:NeighborGrid = null;
         var _loc4_:NeighborSlot = null;
         var _loc5_:Point = null;
         var _loc2_:Object = this.getPlayerObject(param1.currentTarget);
         if(_loc2_)
         {
            _loc3_ = (FriendsBarUIItem.getFriendsBar() as FriendsBarUIItem).neighborGrid;
            _loc4_ = _loc3_.getNeighborSlot(_loc2_.uid);
            if(_loc4_)
            {
               this.m_contextMenu = new ContextualMenuWrapperAlly(_loc4_,_loc3_);
               _loc5_ = ZGameUtils.localToLocal(_loc2_.uiloader,_loc2_.bar.parent.parent);
               this.m_contextMenu.x = _loc5_.x + _loc2_.uiloader.width * 0.6;
               this.m_contextMenu.y = _loc5_.y + _loc2_.uiloader.height * 0.75;
               _loc2_.bar.parent.parent.addChild(this.m_contextMenu);
               this.m_contextMenu.addEventListener(MouseEvent.ROLL_OUT,this.onMenuRollOut,false,0,true);
            }
         }
      }
      
      private function onPlayerOver(param1:MouseEvent) : void
      {
         this.setHightlight(param1.currentTarget,true);
      }
      
      private function onPlayerOut(param1:MouseEvent) : void
      {
         this.setHightlight(param1.currentTarget,false);
      }
      
      private function setHightlight(param1:Object, param2:Boolean) : void
      {
         var _loc3_:Object = this.getPlayerObject(param1);
         if(_loc3_)
         {
            _loc3_.bar.profile_mc.highlightSelect_mc.visible = param2;
         }
      }
      
      private function onMenuRollOut(param1:MouseEvent) : void
      {
         this.disposeMenu();
      }
      
      private function disposeMenu() : void
      {
         if(this.m_contextMenu)
         {
            this.m_contextMenu.removeEventListener(MouseEvent.ROLL_OUT,this.onMenuRollOut);
            this.m_contextMenu.dispose();
            this.m_contextMenu = null;
         }
      }
      
      private function onPlayerImageLoaded(param1:String, param2:BitmapData) : void
      {
         var _loc3_:Object = null;
         if(this.m_activeBars)
         {
            for each(_loc3_ in this.m_activeBars)
            {
               if(_loc3_.url == param1)
               {
                  _loc3_.uiloader.source = new Bitmap(param2);
                  _loc3_.uiloader.load();
                  return;
               }
            }
         }
      }
      
      protected function showTrophies(param1:MovieClip, param2:Object) : void
      {
         var _loc3_:Array = this.m_barDisplay.getTrophies(this,param1);
         var _loc4_:int = this.getReward(param2);
         if(_loc4_ >= 0)
         {
            _loc3_[_loc4_].visible = true;
            Tooltip.subscribe(_loc3_[_loc4_],ZGameUtils.ZlocT("Leaderboards","Leaderboards_TrophyTooltipIcon"));
         }
      }
      
      protected function get name() : String
      {
         if(this.m_leaderboard.type.toString())
         {
            return this.m_leaderboard.type.toString();
         }
         return null;
      }
      
      protected function allowPlacementRewardCollection(param1:Object) : Boolean
      {
         return false;
      }
      
      protected function get addShareButton() : Boolean
      {
         return false;
      }
      
      protected function onPlacementRewardClicked(param1:MouseEvent) : void
      {
      }
      
      protected function onPlacementShareClicked(param1:MouseEvent) : void
      {
         this.m_parentScreen.return_mc.visible = false;
         this.m_shareButton.disable();
      }
      
      protected function hideAllTrophies(param1:MovieClip) : void
      {
         var _loc3_:MovieClip = null;
         var _loc2_:Array = this.trophies(param1);
         for each(_loc3_ in _loc2_)
         {
            _loc3_.visible = false;
         }
         _loc2_ = this.globeTrophies(param1);
         for each(_loc3_ in _loc2_)
         {
            _loc3_.visible = false;
         }
      }
      
      private function onBarButtonClicked(param1:MouseEvent) : void
      {
         ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_GENERIC_BUTTON_CLICKED,{
            "counter":"leaderboard",
            "kingdom":"participation_reward",
            "phylum":"click"
         }));
         if(this.collectReward(param1.target.parent,parseInt(param1.target.buttonValue),false))
         {
            this.rewardCollected(param1.target.parent);
         }
      }
      
      protected function rewardCollected(param1:MovieClip) : void
      {
         param1.check_mc.visible = true;
         param1.return_mc.visible = false;
         if(ZGameUtils.hideIfExists(param1.starburst_mc))
         {
            param1.starburst_mc.gotoAndStop(1);
         }
      }
      
      protected function collectReward(param1:MovieClip, param2:int, param3:Boolean) : Boolean
      {
         var _loc4_:int = 0;
         var _loc5_:XML = null;
         if(!this.m_leaderboard.completedRewards[param2])
         {
            if(this.m_leaderboard.xml.participation != undefined)
            {
               _loc4_ = int(this.m_leaderboard.xml.participation.reward.length());
               if(param2 < _loc4_)
               {
                  _loc5_ = this.m_leaderboard.xml.participation.reward[param2];
                  if(param3)
                  {
                     return this.buyReward(param1,_loc5_,param2,param3);
                  }
                  return this.doCollectReward(param1,_loc5_,param2,param3);
               }
            }
         }
         return false;
      }
      
      protected function doCollectReward(param1:MovieClip, param2:XML, param3:int, param4:Boolean) : Boolean
      {
         this.m_leaderboard.completedRewards[param3] = true;
         TransactionManager.addTransaction(new TCollectLeaderBoard(this.m_leaderboard.id,param3,0,false,param4));
         LeaderboardManager.instance.dispatchEvent(new Event(LeaderboardManager.LEADERBOARD_REWARD_COLLECTED));
         var _loc5_:RewardHelper = new RewardHelper(param2);
         _loc5_.execute();
         var _loc6_:Object = new Object();
         _loc6_.rewardIcons = new Array();
         _loc6_.rewardText = new Array();
         _loc6_.reward = param2;
         _loc5_.buildUI(_loc6_,WorldResourceManager.LARGE_ICON);
         var _loc7_:String = ZGameUtils.ZlocT("Leaderboards","Leaderboards_CollectRewardTitle");
         var _loc8_:String = ZGameUtils.ZlocT("Leaderboards","Leaderboards_CollectRewardMessageObject",{"itemamount":_loc6_.rewardText[0]});
         var _loc9_:String = ZGameUtils.ZlocT("Dialogs","Share");
         var _loc10_:FeedPopup = new FeedPopup(_loc8_,_loc7_,_loc9_,GenericPopup.TYPE_ACCEPTCANCEL,this.onShare,_loc6_.rewardIcons[0]);
         _loc10_.userData = _loc6_;
         PopupManager.instance.push(_loc10_,0,false);
         this.rewardCollected(param1);
         return true;
      }
      
      protected function getRewardItem(param1:XML) : GameItem
      {
         return null;
      }
      
      protected function calculateCost(param1:XML, param2:MovieClip = null) : int
      {
         return 0;
      }
      
      private function buyReward(param1:MovieClip, param2:XML, param3:int, param4:Boolean) : Boolean
      {
         var _loc6_:Object = null;
         var _loc7_:String = null;
         var _loc8_:GenericPopup = null;
         ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_GENERIC_BUTTON_CLICKED,{
            "counter":"dialog",
            "kingdom":"lb_placement_complete",
            "phylum":"buy"
         }));
         var _loc5_:int = this.calculateCost(param2);
         if(ZGlobal.player.canBuyCash(_loc5_,false))
         {
            if(!ZGlobal.gameSettings.showConfirmationPopup(_loc5_))
            {
               return this.doBuyReward(param1,param2,param3,param4);
            }
            _loc6_ = ZGameUtils.CashTokenReplacements(_loc5_);
            _loc6_.item = this.getRewardItem(param2).getSentenceNameLocalizationObject("singular",true);
            _loc7_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseMessage_Object",_loc6_);
            _loc8_ = GenericPopup2B.NewYesNo(_loc7_,null,this.onBuyConfirmed);
            _loc8_.userData = {
               "bar":param1,
               "reward":param2,
               "index":param3,
               "buying":param4
            };
            PopupManager.instance.push(_loc8_,0,false);
         }
         else
         {
            PopupManager.instance.push(new NotEnoughCashPopup(ZGameUtils.ZlocT("Dialogs","ImpulseCash")),0,false);
         }
         return false;
      }
      
      private function doBuyReward(param1:MovieClip, param2:XML, param3:int, param4:Boolean) : Boolean
      {
         var _loc5_:int = 0;
         if(this.doCollectReward(param1,param2,param3,param4))
         {
            _loc5_ = this.calculateCost(param2);
            ZGlobal.player.cash -= _loc5_;
            return true;
         }
         return false;
      }
      
      private function onBuyConfirmed(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.ACCEPT)
         {
            this.doBuyReward(param1.userData.bar,param1.userData.reward,param1.userData.index,param1.userData.buying);
         }
      }
      
      private function onShare(param1:GenericPopupEvent) : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         if(param1.button == GenericPopup.ACCEPT)
         {
            _loc2_ = param1.userData;
            _loc3_ = _loc2_.reward.@feed;
            if(_loc3_)
            {
               ViralsManager.instance.sendFeed(_loc3_,{
                  "title":this.title,
                  "user":ZGlobal.player.firstName,
                  "rank":this.rank,
                  "amount":this.numValidEntries
               });
            }
         }
      }
      
      private function disposeButtons() : void
      {
         var _loc1_:ZGameButton = null;
         if(this.m_buttons)
         {
            for each(_loc1_ in this.m_buttons)
            {
               _loc1_.dispose();
            }
            this.m_buttons = null;
         }
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
      }
   }
}

