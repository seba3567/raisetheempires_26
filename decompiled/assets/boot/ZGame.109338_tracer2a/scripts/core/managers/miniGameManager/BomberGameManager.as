package core.managers.miniGameManager
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.managers.tutorialManager.TutorialHighlighter;
   import displays.popups.bomberGame.BomberGameTutorialPopup;
   import displays.popups.bomberGame.EndBomberPopup;
   import displays.popups.bomberGame.PlayBomberGame;
   import displays.popups.genericPopup.ModalPopup;
   import fl.containers.UILoader;
   import fl.motion.AdjustColor;
   import flash.display.Sprite;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.Point;
   import transactions.TStartMiniGame;
   import utils.ZGameUtils;
   import zlabs.managers.PopupManager;
   
   public class BomberGameManager
   {
      
      private static var m_instance:BomberGameManager = new BomberGameManager();
      
      public static const DAILY_FREE_BOMB_SUPPLY:Number = 2;
      
      public static const FREE_BOMB_CODE:String = "MGB0";
      
      public static const PAID_BOMB_CODE:String = "MGB1";
      
      public static const DAILY_FUEL_SUPPLY:Number = 35;
      
      public static const MIN_FUEL:Number = 0;
      
      public static const MINIGAME_COOLDOWN_TIME:Number = 86400;
      
      public static const BOMBERGAME_CODE:String = "MIG0";
      
      public static const MAX_REWARD_STORED:Number = 5;
      
      public static const BOMBER_FUEL_CODE:String = "MGF0";
      
      public static const MAX_TIERS:Number = 5;
      
      public static const FUEL_CONSUMED_PER_SECOND:Number = 0.5;
      
      public static const BOMBER_MIN_LEVEL:Number = 8;
      
      private var m_lastPlayedTime:Number;
      
      private var m_fuel:Number;
      
      private var m_bombTierReached:Number;
      
      private var m_rewardTierReached:Number;
      
      private var m_tierReset:Number;
      
      private var m_rewardTierReset:Number;
      
      private var m_xml:XMLList;
      
      private var m_rewardsWon:Array;
      
      private var m_bombMode:Boolean;
      
      private var m_rsc:Number;
      
      private var m_rsr:Array;
      
      private var m_crateProbabilities:Object;
      
      public var crateColourScheme:Object;
      
      private var crateScaling:Array;
      
      private var m_loadingScreenPopup:ModalPopup;
      
      private var m_key:String;
      
      private var m_overrideImageCode:Boolean;
      
      private var m_nextRewardCode:String;
      
      private var m_totalFuel:Number;
      
      private var m_hudIconMovie:UILoader;
      
      private var m_tutorial:TutorialHighlighter;
      
      public var gamePaused:Boolean;
      
      public var originalCrateX:Number;
      
      public var originalItemX:Number;
      
      public var originalmc:Array;
      
      private var m_nextRewardCalcDone:Boolean;
      
      public function BomberGameManager()
      {
         super();
      }
      
      public static function get instance() : BomberGameManager
      {
         return m_instance;
      }
      
      public function set hudIconMovie(param1:UILoader) : void
      {
         this.m_hudIconMovie = param1;
      }
      
      public function showTutorial() : void
      {
         this.m_tutorial = new TutorialHighlighter();
         var _loc1_:Point = new Point(-50,100);
         this.m_tutorial.setDisplayObject(Sprite(this.m_hudIconMovie),true,-90,false,_loc1_);
      }
      
      public function get lastPlayedTime() : Number
      {
         return this.m_lastPlayedTime;
      }
      
      public function getBombCount() : Number
      {
         return ZGlobal.player.getNumberOfInventoryItems(FREE_BOMB_CODE) + ZGlobal.player.getNumberOfInventoryItems(PAID_BOMB_CODE);
      }
      
      public function getCrateIcon(param1:String) : String
      {
         var iconData:String;
         var id:String = param1;
         if(this.m_overrideImageCode)
         {
            this.m_overrideImageCode = false;
            if(!this.m_nextRewardCalcDone)
            {
               return "";
            }
            this.m_nextRewardCalcDone = false;
            return this.m_nextRewardCode;
         }
         iconData = this.m_xml.crates.crate.(@id == id).@icon;
         return iconData;
      }
      
      public function get BombMode() : Boolean
      {
         return this.m_bombMode;
      }
      
      public function initFromSettings(param1:XMLList) : void
      {
         var list:XMLList = param1;
         this.m_xml = list.minigame.(@id == BOMBERGAME_CODE);
      }
      
      public function get rewards() : Array
      {
         return this.m_rewardsWon;
      }
      
      public function init(param1:Object) : void
      {
         this.m_lastPlayedTime = param1.miniGamePlayedTS;
         this.m_fuel = Number(param1.bomberFuel);
         this.m_bombTierReached = Number(param1.bombTierReached);
         this.m_rewardTierReached = Number(param1.miniGameRewardTier);
         this.m_rewardsWon = new Array();
         this.m_rewardsWon = param1.miniGameRewards;
         this.m_totalFuel = param1.miniGameTotalFuel;
         this.m_fuel = Math.min(this.m_totalFuel,this.m_fuel);
         this.m_key = param1.mgrsData;
         var _loc2_:String = BOMBERGAME_CODE;
         this.m_overrideImageCode = false;
         this.gamePaused = false;
         this.m_nextRewardCalcDone = false;
      }
      
      public function get TotalFuel() : Number
      {
         return this.m_totalFuel;
      }
      
      protected function adjustColor() : void
      {
         var _loc2_:XML = null;
         var _loc3_:AdjustColor = null;
         var _loc4_:ColorMatrixFilter = null;
         var _loc1_:XMLList = this.m_xml.crates.crate;
         this.crateColourScheme = new Object();
         this.crateScaling = new Array();
         for each(_loc2_ in _loc1_)
         {
            _loc3_ = new AdjustColor();
            _loc3_.hue = Number(_loc2_.@hue);
            _loc3_.saturation = Number(_loc2_.@saturation);
            _loc3_.brightness = Number(_loc2_.@brightness);
            _loc3_.contrast = Number(_loc2_.@contrast);
            _loc4_ = new ColorMatrixFilter(_loc3_.CalculateFinalFlatArray());
            this.crateColourScheme[_loc2_.@id.toString()] = [_loc4_];
            this.crateScaling[_loc2_.@id.toString()] = Number(_loc2_.@scale);
         }
      }
      
      public function getScale(param1:String) : Number
      {
         return this.crateScaling[param1];
      }
      
      public function addMiniGameReward(param1:String) : void
      {
         this.m_rewardsWon.push(param1);
         if(this.m_rewardsWon.length > MAX_REWARD_STORED)
         {
            this.m_rewardsWon.shift();
         }
      }
      
      public function setParams() : void
      {
         var _loc1_:Number = Number(this.m_xml.@resetTier);
         var _loc2_:Number = Number(this.m_xml.@numBombTiers);
         this.m_bombTierReached = this.m_bombTierReached % _loc1_ + 1;
         this.m_rewardTierReached = Math.min(_loc2_,this.m_bombTierReached);
         this.readNewCrateProbabilites();
      }
      
      public function readNewCrateProbabilites() : void
      {
         var resetTier:Number = NaN;
         var tier:Number = NaN;
         var crateProbList:XMLList = null;
         var crateProb:XML = null;
         resetTier = Number(this.m_xml.@resetTier);
         tier = Math.min(this.m_rewardTierReached + 1,MAX_TIERS,this.m_bombTierReached % resetTier + 1);
         crateProbList = this.m_xml.appearProbs.bombTier.(@index == tier).hitProbability;
         this.m_crateProbabilities = new Array();
         for each(crateProb in crateProbList)
         {
            this.m_crateProbabilities[crateProb.@crateName.toString()] = crateProb.@chance;
         }
      }
      
      public function set rsc(param1:Number) : void
      {
         this.m_rsc = param1;
      }
      
      public function canDropBomb() : Boolean
      {
         var _loc1_:Number = ZGlobal.player.getNumberOfInventoryItems(FREE_BOMB_CODE) + ZGlobal.player.getNumberOfInventoryItems(PAID_BOMB_CODE);
         if(this.m_fuel <= 0 || _loc1_ <= 0)
         {
            return false;
         }
         return true;
      }
      
      public function getCrateType() : String
      {
         var cum:Number = NaN;
         var prob:Number = NaN;
         var i:String = null;
         var crateProbList:XMLList = null;
         var crate:String = null;
         var crateProb:XML = null;
         var rsc:Number = Math.random();
         if(this.m_bombMode)
         {
            rsc = this.m_rsc;
            this.m_bombMode = false;
            this.m_overrideImageCode = true;
            if(!this.m_nextRewardCalcDone)
            {
               return "MCR0";
            }
            crateProbList = this.m_xml.bombTiers.bombTier.(@index == m_rewardTierReached).hitProbability;
            cum = 0;
            for each(crateProb in crateProbList)
            {
               prob = Number(crateProb.@chance);
               if(rsc <= prob + cum)
               {
                  crate = crateProb.@crateName;
                  break;
               }
               cum += prob;
            }
            return crate;
         }
         cum = 0;
         for(i in this.m_crateProbabilities)
         {
            prob = Number(this.m_crateProbabilities[i]);
            if(rsc <= prob + cum)
            {
               return i;
            }
            cum += prob;
         }
         return "";
      }
      
      public function set BombMode(param1:Boolean) : void
      {
         this.m_bombMode = param1;
      }
      
      public function onBombDrop(param1:Number, param2:Array) : String
      {
         if(ZGlobal.player.getNumberOfInventoryItems(FREE_BOMB_CODE) > 0)
         {
            ZGlobal.player.removeInventoryItem(FREE_BOMB_CODE);
         }
         else
         {
            ZGlobal.player.removeInventoryItem(PAID_BOMB_CODE);
         }
         return this.addReward(this.m_rsc,param2);
      }
      
      public function get Fuel() : Number
      {
         return this.m_fuel;
      }
      
      protected function addReward(param1:Number, param2:Array) : XMLList
      {
         var crateProbList:XMLList = null;
         var cum:Number = NaN;
         var crate:String = null;
         var crateProb:XML = null;
         var crateXML:XMLList = null;
         var prob:Number = NaN;
         var rsc:Number = param1;
         var rsr:Array = param2;
         this.setParams();
         crateProbList = this.m_xml.bombTiers.bombTier.(@index == m_rewardTierReached).hitProbability;
         cum = 0;
         for each(crateProb in crateProbList)
         {
            prob = Number(crateProb.@chance);
            if(rsc <= prob + cum)
            {
               crate = crateProb.@crateName;
               break;
            }
            cum += prob;
         }
         crateXML = this.m_xml.crates.crate.(@id == crate);
         return crateXML;
      }
      
      public function setLastPlayedTime() : void
      {
         this.m_lastPlayedTime = GlobalEngine.serverTime / 1000;
      }
      
      public function updateFuel(param1:Number) : void
      {
         var _loc2_:Number = this.m_fuel - param1 * FUEL_CONSUMED_PER_SECOND;
         this.m_fuel = _loc2_;
      }
      
      public function isBomberTutorialActive() : Boolean
      {
         if(this.m_tutorial)
         {
            return true;
         }
         return false;
      }
      
      public function reset(param1:Boolean = true) : void
      {
         this.m_lastPlayedTime = GlobalEngine.serverTime / 1000;
         if(param1)
         {
            this.m_bombTierReached = 0;
            this.m_rewardTierReached = 0;
         }
         this.m_fuel = this.m_totalFuel;
         ZGlobal.player.removeInventoryItem(FREE_BOMB_CODE,ZGlobal.player.getNumberOfInventoryItems(FREE_BOMB_CODE));
         ZGlobal.player.addToInventory(FREE_BOMB_CODE,DAILY_FREE_BOMB_SUPPLY);
      }
      
      public function canStartGame() : Boolean
      {
         this.m_crateProbabilities = new Object();
         this.m_bombMode = false;
         this.readNewCrateProbabilites();
         this.adjustColor();
         var _loc1_:Number = GlobalEngine.serverTime / 1000;
         var _loc2_:Number = Math.floor(_loc1_ - this.m_lastPlayedTime);
         if(_loc2_ > MINIGAME_COOLDOWN_TIME)
         {
            this.reset();
         }
         if(this.m_fuel <= 0)
         {
            return false;
         }
         return true;
      }
      
      public function set Fuel(param1:Number) : void
      {
         this.m_fuel = param1;
      }
      
      private function doXOR(param1:Number, param2:Array) : String
      {
         var _loc5_:Number = NaN;
         var _loc3_:String = "";
         var _loc4_:Number = 0;
         while(_loc4_ < param2.length)
         {
            _loc5_ = Number(param2[_loc4_]);
            _loc5_ = _loc5_ ^ param1;
            _loc3_ += String.fromCharCode(_loc5_);
            _loc4_++;
         }
         return _loc3_;
      }
      
      public function loadGame(param1:Object) : void
      {
         var _loc2_:Number = Number(param1.sc);
         var _loc3_:Array = param1.sr;
         if(param1.fuel < this.m_fuel)
         {
            this.m_fuel = param1.fuel;
         }
         this.m_rsc = _loc2_;
         this.calculateNextReward(_loc3_);
         this.m_loadingScreenPopup.pop();
         PopupManager.instance.push(new PlayBomberGame("true",_loc2_,_loc3_));
      }
      
      public function RemoveTutorial() : void
      {
         if(this.m_tutorial)
         {
            this.m_tutorial.dispose();
            this.m_tutorial = null;
         }
      }
      
      public function startBomberGame() : void
      {
         if(this.m_tutorial)
         {
            this.m_tutorial.dispose();
            this.m_tutorial = null;
         }
         if(this.canStartGame())
         {
            if(ZGlobal.player.getSeenFlag("bombergametutorial") == false)
            {
               PopupManager.instance.push(new BomberGameTutorialPopup("true"));
            }
            else
            {
               TransactionManager.addTransaction(new TStartMiniGame(this),true);
               this.m_loadingScreenPopup = new ModalPopup(ZGameUtils.ZlocT("Dialogs","bomber_loading"));
               PopupManager.instance.push(this.m_loadingScreenPopup);
            }
         }
         else
         {
            PopupManager.instance.push(new EndBomberPopup("true"));
         }
      }
      
      public function calculateNextReward(param1:Array) : void
      {
         var _loc2_:String = GlobalEngine.socialNetwork.getLoggedInUserId();
         var _loc3_:Number = Number(_loc2_) % 10000 ^ Number(this.m_key) ^ 0x1EE3;
         this.m_nextRewardCode = this.doXOR(_loc3_,param1);
         this.m_nextRewardCalcDone = true;
      }
   }
}

