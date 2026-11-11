package displays
{
   import Engine.Managers.TransactionManager;
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.managers.ExperimentsManager;
   import core.ui.menuitem.PlayerStatsUIItem;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import sound.SoundEvent;
   import transactions.TStreakBonus;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   
   public class StreakBonus extends Sprite
   {
      
      public static const STREAKBONUS_REWARDTEXT_XOFFSET:int = 50;
      
      public static const STREAKBONUS_XOFFSET:int = 590;
      
      public static const STREAKBONUS_XINSET:int = 170;
      
      public static const STREAKBONUS_YOFFSET:int = 35;
      
      public static var streakBar:Class = StreakBonus_streakBar;
      
      public static var streakFrame:Class = StreakBonus_streakFrame;
      
      protected var m_xml:XML;
      
      public var m_progressBarBack:DisplayObject;
      
      protected var m_progressBar:DisplayObject;
      
      protected var m_originalProgressBarWidth:int;
      
      protected var m_expireTime:Number;
      
      protected var m_warningTime:Number;
      
      protected var m_startTime:Number;
      
      protected var m_isActive:Boolean;
      
      protected var m_isDisplayUpdating:Boolean;
      
      protected var m_inWarningPhase:Boolean;
      
      protected var m_streakMsgs:Array = [];
      
      protected var m_rewardMsg:TextField;
      
      protected var m_maxesReached:int;
      
      protected var m_tierReached:int;
      
      protected var m_maxTiers:int;
      
      protected var m_rewardMultiplier:Number;
      
      protected var m_warningBitmap:Bitmap = new Bitmap();
      
      protected var m_warningBitmapData:BitmapData;
      
      protected var m_soundLoaded:Boolean = false;
      
      protected var m_streakSounds:int = 6;
      
      protected var m_current_bonus:Number = 0;
      
      protected var m_current_progress:Number = 0;
      
      protected var m_displayed_progress:Number = 0;
      
      protected var m_rewardAmounts:Array = new Array();
      
      private var m_bonusAmountsQueue:Array = new Array();
      
      private var m_progressMaxed:Boolean = false;
      
      private var m_isModalDialogOpen:Boolean = false;
      
      protected const STREAKBONUS_REWARDTEXT_TIME:int = 2000;
      
      protected const STREAKBONUS_REWARD_DELAY:Number = 300;
      
      protected const STREAKBONUS_FONT_SIZE:Number = 16;
      
      protected const STREAKBONUS_REWARD_FONT_SIZE:Number = 24;
      
      private const USE_HOOBERS:int = 3;
      
      public function StreakBonus(param1:XML)
      {
         var _loc3_:DisplayObject = null;
         super();
         this.m_xml = param1;
         this.m_progressBarBack = new streakFrame();
         this.m_progressBar = new streakBar();
         this.m_progressBar.x = 8;
         this.m_progressBar.y = 5;
         this.m_originalProgressBarWidth = this.m_progressBar.width;
         var _loc2_:XMLList = param1.tier;
         this.m_maxTiers = _loc2_.length();
         this.m_expireTime = param1.@expire_time * 1000;
         this.m_warningTime = param1.@warning_time * 1000;
         this.m_rewardMultiplier = param1.@multiplier;
         this.initStreakMessages();
         addChild(this.m_warningBitmap);
         addChild(this.m_progressBarBack);
         addChild(this.m_progressBar);
         hitTestObject(this.m_progressBarBack);
         for each(_loc3_ in this.m_streakMsgs)
         {
            addChild(_loc3_);
         }
         PopupManager.instance.addEventListener(WindowManager.SHOW_SCREEN,this.onShowScreen,false,0,true);
         PopupManager.instance.addEventListener(WindowManager.HIDE_SCREEN,this.onHideScreen,false,0,true);
         this.m_progressBar.width = 0;
         this.reset();
      }
      
      protected function initStreakMessages() : void
      {
         var _loc2_:TextField = null;
         var _loc1_:int = 1;
         while(_loc1_ <= this.m_maxTiers)
         {
            _loc2_ = this.createStreakMessage(ZGameUtils.ZlocT("Dialogs","StreakMessage" + _loc1_),true,this.STREAKBONUS_FONT_SIZE);
            this.m_streakMsgs[_loc1_ - 1] = _loc2_;
            _loc1_++;
         }
      }
      
      private function createStreakMessage(param1:String, param2:Boolean, param3:Number) : TextField
      {
         var _loc4_:TextField = new TextField();
         _loc4_.text = param1;
         var _loc5_:TextFormat = new TextFormat();
         _loc5_.font = "CCSmash";
         _loc5_.size = param3;
         _loc5_.color = 2193847;
         _loc5_ = GlobalEngine.fontMapper.mapTextFormat("",_loc5_);
         _loc4_.setTextFormat(_loc5_);
         _loc4_.defaultTextFormat = _loc5_;
         _loc4_.filters = [new GlowFilter(16777215,1,5,5,15)];
         _loc4_.embedFonts = GlobalEngine.fontMapper.mapFontEmbed("","CCSmash",true);
         _loc4_.selectable = false;
         _loc4_.mouseEnabled = false;
         _loc4_.cacheAsBitmap = param2;
         _loc4_.autoSize = TextFieldAutoSize.LEFT;
         _loc4_.alpha = 0;
         _loc4_.scaleX = 0;
         _loc4_.scaleY = 0;
         return _loc4_;
      }
      
      protected function turnOnStreakMessage(param1:DisplayObject, param2:Number = 0, param3:Number = 0) : void
      {
         var _loc4_:DisplayObject = null;
         var _loc5_:int = 0;
         if(!param1)
         {
            return;
         }
         for each(_loc4_ in this.m_streakMsgs)
         {
            if(_loc4_.alpha)
            {
               this.turnOffStreakMessage(_loc4_);
            }
         }
         param1.scaleX = 1;
         param1.scaleY = 1;
         param1.x = this.m_progressBarBack.width / 2 + param2;
         param1.y = 15 + param3;
         _loc5_ = -param1.width / 2;
         param1.scaleX = 0;
         param1.scaleY = 0;
         TweenLite.to(param1,0.2,{
            "scaleX":1,
            "scaleY":1,
            "x":_loc5_ + this.m_progressBarBack.width / 2 + param2,
            "alpha":1
         });
      }
      
      protected function turnOffStreakMessage(param1:DisplayObject, param2:Boolean = false) : void
      {
         var streakMsg:DisplayObject = param1;
         var removeMsg:Boolean = param2;
         TweenLite.to(streakMsg,0.2,{
            "alpha":0,
            "onComplete":function():void
            {
               streakMsg.scaleX = 0;
               streakMsg.scaleY = 0;
               if(removeMsg && Boolean(streakMsg.parent))
               {
                  streakMsg.parent.removeChild(streakMsg);
                  streakMsg = null;
               }
            }
         });
      }
      
      protected function warningTimeReached() : void
      {
         var _loc1_:GlowFilter = null;
         if(!this.m_inWarningPhase)
         {
            this.m_inWarningPhase = true;
            this.m_warningBitmapData = new BitmapData(this.m_progressBarBack.width,this.m_progressBarBack.height,true,0);
            this.m_warningBitmapData.draw(this);
            this.m_warningBitmap.bitmapData = this.m_warningBitmapData;
            _loc1_ = new GlowFilter(16711680,0.8,15,15,5);
            this.m_warningBitmap.filters = [_loc1_];
            this.toggleBlink();
         }
      }
      
      protected function toggleBlink() : void
      {
         if(!this.m_inWarningPhase)
         {
            this.m_warningBitmap.alpha = 0;
            return;
         }
         if(this.m_warningBitmap.alpha)
         {
            TweenLite.to(this.m_warningBitmap,0.2,{
               "alpha":0,
               "onComplete":function():void
               {
                  toggleBlink();
               }
            });
         }
         else
         {
            TweenLite.to(this.m_warningBitmap,0.2,{
               "alpha":0.8,
               "onComplete":function():void
               {
                  toggleBlink();
               }
            });
         }
      }
      
      protected function reset() : void
      {
         this.alpha = 0;
         this.visible = false;
         this.mouseEnabled = false;
         this.mouseChildren = false;
         this.m_current_bonus = 0;
         this.m_current_progress = 0;
         this.m_displayed_progress = 0;
         this.m_maxesReached = 0;
         this.m_tierReached = 0;
         this.m_progressMaxed = false;
         this.m_startTime = 0;
         this.m_isActive = false;
         this.m_isDisplayUpdating = false;
         this.m_warningBitmap.alpha = 0;
         this.turnOnStreakMessage(this.m_streakMsgs[0]);
         this.m_inWarningPhase = false;
         this.m_rewardAmounts.splice(0,this.m_rewardAmounts.length);
      }
      
      protected function expireTimeReached() : void
      {
         this.m_isActive = false;
         if(this.m_maxesReached > 0)
         {
            this.rewardStreakBonus();
            SoundEvent.getSoundEvent("xpPickup").play();
         }
         else
         {
            TweenLite.to(this,0.2,{
               "alpha":0,
               "onComplete":function():void
               {
                  reset();
               }
            });
         }
      }
      
      protected function resetExpireTimeAndShow() : void
      {
         this.m_startTime = GlobalEngine.serverTime;
         this.m_inWarningPhase = false;
         this.m_isActive = true;
         TweenLite.to(this,0.5,{"alpha":1});
      }
      
      protected function stopWarning() : void
      {
         this.m_inWarningPhase = false;
      }
      
      public function incProgress(param1:Number) : void
      {
         this.visible = true;
         this.mouseEnabled = true;
         this.enableDisplayUpdating();
         if(!this.m_isActive)
         {
            this.m_startTime = GlobalEngine.serverTime;
            Zlab.processManager.schedule(10,this,this.onUpdate);
         }
         this.resetExpireTimeAndShow();
         if(this.m_rewardMsg)
         {
            this.turnOffStreakMessage(this.m_rewardMsg,true);
         }
         if(!this.m_progressMaxed && this.m_tierReached < this.m_maxTiers)
         {
            this.m_current_bonus += param1;
            this.m_current_progress += this.bonusPerClick;
            if(this.m_current_progress >= this.calculateMaxProgress())
            {
               this.m_tierReached += 1;
               this.m_progressMaxed = true;
            }
         }
         else
         {
            this.m_bonusAmountsQueue.push(param1);
         }
      }
      
      protected function maxProgressReached() : void
      {
         var _loc1_:Number = NaN;
         this.m_maxesReached += 1;
         this.m_current_bonus = 0;
         this.m_current_progress = 0;
         this.m_displayed_progress = 0;
         if(this.m_maxesReached <= this.m_streakSounds)
         {
            SoundEvent.getSoundEvent("streakBonus" + this.m_maxesReached).play();
         }
         else if(this.m_maxesReached > this.m_streakSounds)
         {
            SoundEvent.getSoundEvent("streakBonus" + (this.m_maxesReached - this.m_streakSounds)).play();
         }
         if(this.m_maxesReached >= this.m_maxTiers)
         {
            this.rewardStreakBonus();
         }
         else
         {
            this.turnOnStreakMessage(this.m_streakMsgs[this.m_maxesReached]);
         }
         this.m_progressMaxed = false;
         while(this.m_bonusAmountsQueue.length > 0 && !this.m_progressMaxed && this.m_tierReached < this.m_maxTiers)
         {
            _loc1_ = this.m_bonusAmountsQueue.shift();
            this.m_current_bonus += _loc1_;
            this.m_current_progress += this.bonusPerClick;
            if(this.m_current_progress >= this.calculateMaxProgress())
            {
               this.m_tierReached += 1;
               this.m_progressMaxed = true;
               break;
            }
         }
      }
      
      public function rewardStreakBonus() : void
      {
         var _loc3_:Number = NaN;
         var _loc1_:Number = 0;
         var _loc2_:Number = this.totalBonus;
         if(ExperimentsManager.instance.getExperimentVariant("empire_doober_pickup") == this.USE_HOOBERS)
         {
            _loc3_ = Math.ceil(_loc2_ * ZGlobal.gameSettings.getStreakReductionPercent());
            _loc2_ -= _loc3_;
         }
         this.m_rewardMsg = this.createStreakMessage(ZGameUtils.ZlocT("Dialogs","StreakRewardCoin",{
            "amount":_loc2_,
            "coin":ZGameUtils.ZlocTk("Objects","coin","",_loc2_)
         }),false,this.STREAKBONUS_REWARD_FONT_SIZE);
         this.stopWarning();
         PlayerStatsUIItem.getPlayerStats().addChild(this.m_rewardMsg);
         this.turnOnStreakMessage(this.m_rewardMsg,this.x - this.width + STREAKBONUS_REWARDTEXT_XOFFSET,this.y);
         this.addRewardToPlayer(_loc2_);
         TransactionManager.addTransaction(new TStreakBonus(_loc2_,this.m_tierReached));
         this.reset();
         Zlab.processManager.schedule(this.STREAKBONUS_REWARDTEXT_TIME,this,this.delayedTurnOffStreakMessage);
      }
      
      public function delayedTurnOffStreakMessage() : void
      {
         TweenLite.to(this,0.2,{
            "alpha":0,
            "onComplete":function():void
            {
               turnOffStreakMessage(m_rewardMsg,true);
            }
         });
      }
      
      protected function addRewardToPlayer(param1:Number) : void
      {
         ZGlobal.player.coins += param1;
      }
      
      protected function calculateMaxProgress() : Number
      {
         return Number(this.m_xml.tier[this.m_maxesReached].@threshold);
      }
      
      protected function get bonusPerClick() : Number
      {
         return Number(this.m_xml.tier[this.m_maxesReached].@bonus_per_click);
      }
      
      protected function calculateBonusForCurrentTier(param1:Number) : Number
      {
         var _loc2_:Number = Number(this.m_xml.tier[this.m_maxesReached].@reward_value);
         return Math.ceil(ZGlobal.player.level * this.m_rewardMultiplier * _loc2_);
      }
      
      public function get totalBonus() : Number
      {
         var _loc1_:Number = Number(this.m_xml.tier[this.m_tierReached - 1].@reward_value);
         return Math.ceil(ZGlobal.player.level * this.m_rewardMultiplier * _loc1_);
      }
      
      protected function enableDisplayUpdating() : void
      {
         this.m_isDisplayUpdating = true;
      }
      
      protected function disableDisplayUpdating() : void
      {
         this.m_isDisplayUpdating = false;
      }
      
      protected function updateStreakBonus() : void
      {
         if(this.m_displayed_progress >= this.m_current_progress)
         {
            this.disableDisplayUpdating();
         }
         this.m_displayed_progress += this.calculateMaxProgress() * 2 / 100;
         this.updateFrame();
      }
      
      public function updateFrame() : void
      {
         if(this.alpha == 0)
         {
            TweenLite.to(this,0.2,{"alpha":1});
         }
         this.m_progressBar.width = this.m_displayed_progress / this.calculateMaxProgress() * this.m_originalProgressBarWidth;
         var _loc1_:Number = this.calculateMaxProgress();
         if(this.m_displayed_progress >= _loc1_)
         {
            this.maxProgressReached();
         }
      }
      
      public function onUpdate() : void
      {
         var _loc1_:Number = NaN;
         if(this.m_isActive)
         {
            if(this.m_isModalDialogOpen)
            {
               Zlab.processManager.schedule(10,this,this.onUpdate);
               return;
            }
            _loc1_ = GlobalEngine.serverTime - this.m_startTime;
            if(this.m_isDisplayUpdating)
            {
               this.updateStreakBonus();
            }
            if(_loc1_ >= this.m_warningTime)
            {
               this.warningTimeReached();
            }
            if(_loc1_ >= this.m_expireTime)
            {
               this.expireTimeReached();
            }
            else
            {
               Zlab.processManager.schedule(10,this,this.onUpdate);
            }
         }
      }
      
      public function get midPointX() : Number
      {
         return this.x + this.m_progressBarBack.width / 2;
      }
      
      public function get midPointY() : Number
      {
         return this.y + this.m_progressBarBack.height / 2;
      }
      
      public function get maxesReached() : int
      {
         return this.m_maxesReached;
      }
      
      public function onShowScreen(param1:Event) : void
      {
         this.m_isModalDialogOpen = true;
      }
      
      public function onHideScreen(param1:Event) : void
      {
         this.m_isModalDialogOpen = false;
      }
   }
}

