package displays.screens.partsGather
{
   import ZLocalization.LocalizationObjectToken;
   import com.greensock.TweenLite;
   import com.greensock.easing.*;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.RewardHelper;
   import core.gameobjects.UnitItem;
   import core.managers.TimedBuildableManager;
   import core.managers.WorldResourceManager;
   import core.ui.ZGameButton;
   import displays.ImageLoaderFactory;
   import displays.popups.GenericCountdownClock;
   import fl.motion.AdjustColor;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.filters.GlowFilter;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class TimedBuildablePartsGather extends BuildingPartsGather
   {
      
      private static var m_window:TimedBuildablePartsGather;
      
      private static var Instance:TimedBuildableManager;
      
      private static var noOfCycles:int;
      
      private static var noOfDays:int;
      
      private static var volcanoReskinNumber:String;
      
      private static var m_reskinName:String;
      
      public static const FINISHED:String = "finished";
      
      public static const COLLECTED:String = "collected";
      
      public static const FAILURE_SPEECH:String = "failurespeech";
      
      protected var m_timer:Timer = null;
      
      protected var m_timeLeft:int = 0;
      
      protected var m_clocks:Array = [];
      
      protected var m_defaultFilters:Array = null;
      
      protected var m_defaultCardFilters:Array = null;
      
      protected var m_rewardsData:Object;
      
      protected var m_rewardsInfo:XMLList;
      
      private var m_colorMatrix:Array = [];
      
      private var m_colorMatrix1:Array = [];
      
      private var m_colorMatrix2:Array = [];
      
      private var m_glowFilter:Array = [];
      
      private var m_Xml:XML = null;
      
      private var m_textInfo:Object;
      
      private var m_version:int;
      
      public function TimedBuildablePartsGather(param1:EventDispatcher, param2:String, param3:String, param4:IEntity, param5:String = "", param6:String = null, param7:Object = null, param8:XMLList = null)
      {
         super(param1,param2,param3,param4,param5,param6);
         NUM_SLOTS = TimedBuildableManager.NUMOFPARTS;
         this.m_colorMatrix = [this.GreenColorMatrix()];
         this.m_colorMatrix1 = [this.GrayColorMatrix()];
         this.m_colorMatrix2 = [this.GrayDayColorMatrix()];
         this.m_glowFilter = [this.whiteGlow()];
         this.m_rewardsData = this.getRewardsData(param8);
         this.m_rewardsInfo = param8;
         this.m_Xml = ZGlobal.gameSettings.getXML().timedBuildable[0];
         this.m_version = TimedBuildableManager.instance.getVersion(param2);
         if(param7)
         {
            this.m_textInfo = param7;
         }
      }
      
      public static function display(param1:EventDispatcher, param2:String, param3:String, param4:String, param5:String, param6:IEntity, param7:String = "", param8:String = null, param9:Object = null, param10:XMLList = null) : void
      {
         m_window = new TimedBuildablePartsGather(param1,param2,param5,param6,param7,param8,param9,param10);
         volcanoReskinNumber = param4;
         noOfCycles = TimedBuildableManager.instance.getNumOfCycles(volcanoReskinNumber);
         noOfDays = TimedBuildableManager.instance.getNumOfDays(volcanoReskinNumber);
         m_reskinName = param3;
         WindowManager.instance.push(m_window);
      }
      
      public static function isTimedBuildableOpen() : Boolean
      {
         return m_window != null;
      }
      
      public static function closePartsGather() : void
      {
         if(m_window != null)
         {
            m_window.closeWindow(null);
         }
      }
      
      override protected function setTitleText() : void
      {
         var _loc1_:Object = null;
         var _loc2_:String = null;
         var _loc3_:LocalizationObjectToken = m_partsItem.getSentenceNameLocalizationObject("singular",false);
         if(_loc3_)
         {
            _loc1_ = {"item":_loc3_};
            _loc2_ = ZGameUtils.localizedStringForToken(this.m_textInfo.title,"Dialogs",_loc1_);
         }
         TextFieldUtil.compactTextField(m_partsWindow.title_tf,_loc2_);
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         var _loc12_:GameItem = null;
         var _loc13_:String = null;
         var _loc14_:int = 0;
         var _loc15_:UnitItem = null;
         var _loc16_:int = 0;
         var _loc17_:String = null;
         var _loc18_:int = 0;
         var _loc19_:int = 0;
         super.onLoadComplete(param1);
         var _loc2_:Array = [m_partsWindow.rewards_even.rewardTitle1_tf,m_partsWindow.rewards_even.rewardTitle2_tf,m_partsWindow.rewards_even.rewardTitle3_tf,m_partsWindow.rewards_even.rewardTitle4_tf];
         var _loc3_:Array = [m_partsWindow.rewards_even.icon1,m_partsWindow.rewards_even.icon2,m_partsWindow.rewards_even.icon3,m_partsWindow.rewards_even.icon4];
         var _loc4_:Array = [m_partsWindow.rewards_even.qty1_tf,m_partsWindow.rewards_even.qty2_tf,m_partsWindow.rewards_even.qty3_tf,m_partsWindow.rewards_even.qty4_tf];
         var _loc5_:Array = [m_partsWindow.rewards_even.tier1_mc,m_partsWindow.rewards_even.tier2_mc,m_partsWindow.rewards_even.tier3_mc,m_partsWindow.rewards_even.tier4_mc];
         var _loc6_:Array = [m_partsWindow.rewards_even.strength1_mc,m_partsWindow.rewards_even.strength2_mc,m_partsWindow.rewards_even.strength3_mc,m_partsWindow.rewards_even.strength4_mc];
         var _loc7_:Array = [m_partsWindow.rewards_odd.rewardTitle1_tf,m_partsWindow.rewards_odd.rewardTitle2_tf,m_partsWindow.rewards_odd.rewardTitle3_tf];
         var _loc8_:Array = [m_partsWindow.rewards_odd.icon1,m_partsWindow.rewards_odd.icon2,m_partsWindow.rewards_odd.icon3];
         var _loc9_:Array = [m_partsWindow.rewards_odd.qty1_tf,m_partsWindow.rewards_odd.qty2_tf,m_partsWindow.rewards_odd.qty3_tf];
         var _loc10_:Array = [m_partsWindow.rewards_odd.tier1_mc,m_partsWindow.rewards_odd.tier2_mc,m_partsWindow.rewards_odd.tier3_mc];
         var _loc11_:Array = [m_partsWindow.rewards_odd.strength1_mc,m_partsWindow.rewards_odd.strength2_mc,m_partsWindow.rewards_odd.strength3_mc];
         if(noOfCycles == 4)
         {
            if(TimedBuildableManager.instance.isManyRewards(volcanoReskinNumber))
            {
               _loc13_ = ZGlobal.getAssetURL(TimedBuildableManager.instance.manyRewardsURL(volcanoReskinNumber));
               _loc14_ = 0;
               while(_loc14_ < noOfCycles)
               {
                  ImageLoaderFactory.CreateImageLoader(_loc13_,_loc3_[_loc14_]);
                  TextFieldUtil.compactTextField(_loc2_[_loc14_],"Multiple Rewards");
                  _loc6_[_loc14_].visible = false;
                  _loc5_[_loc14_].visible = false;
                  _loc4_[_loc14_].visible = false;
                  if(this.m_version == TimedBuildableManager.PLAY_AGAIN_VERSION)
                  {
                     _loc19_ = int(TimedBuildableManager.REWARD_DAYS[_loc14_]);
                     _loc18_ = _loc19_ - TimedBuildableManager.DAYS_PER_CYCLE + 1;
                     _loc17_ = ZGameUtils.ZlocT("Dialogs","TimedBuildablePlayAgainCycle",{
                        "number1":_loc18_,
                        "number2":_loc19_
                     });
                  }
                  else
                  {
                     _loc17_ = ZGameUtils.ZlocT("Dialogs","TimedBuildableCycle",{"number":TimedBuildableManager.REWARD_DAYS[_loc14_]});
                  }
                  TextFieldUtil.compactTextField(m_partsWindow.rewards_even["day" + (_loc14_ + 1) + "_tf"],_loc17_);
                  _loc14_++;
               }
            }
            else
            {
               _loc14_ = 0;
               while(_loc14_ < noOfCycles)
               {
                  ImageLoaderFactory.CreateImageLoader(this.m_rewardsData.rewardIcons[_loc14_],_loc3_[_loc14_]);
                  TextFieldUtil.compactTextField(_loc2_[_loc14_],this.m_rewardsData.rewardPairs[_loc14_].reward);
                  TextFieldUtil.compactTextField(_loc4_[_loc14_],"x" + this.m_rewardsData.rewardPairs[_loc14_].count);
                  if(this.m_rewardsData.rewardPairs[_loc14_].strength)
                  {
                     _loc15_ = ZGlobal.gameSettings.getItemByCode(this.m_rewardsInfo[_loc14_].@item,UnitItem) as UnitItem;
                     _loc16_ = _loc15_.tier;
                     TextFieldUtil.compactTextField(_loc5_[_loc14_].tier_tf,String(_loc16_));
                     TextFieldUtil.compactTextField(_loc6_[_loc14_].strength_tf,this.m_rewardsData.rewardPairs[_loc14_].strength);
                  }
                  else
                  {
                     _loc6_[_loc14_].visible = false;
                     _loc5_[_loc14_].visible = false;
                  }
                  if(this.m_version == TimedBuildableManager.PLAY_AGAIN_VERSION)
                  {
                     _loc19_ = int(TimedBuildableManager.REWARD_DAYS[_loc14_]);
                     _loc18_ = _loc19_ - TimedBuildableManager.DAYS_PER_CYCLE + 1;
                     _loc17_ = ZGameUtils.ZlocT("Dialogs","TimedBuildablePlayAgainCycle",{
                        "number1":_loc18_,
                        "number2":_loc19_
                     });
                  }
                  else
                  {
                     _loc17_ = ZGameUtils.ZlocT("Dialogs","TimedBuildableCycle",{"number":TimedBuildableManager.REWARD_DAYS[_loc14_]});
                  }
                  TextFieldUtil.compactTextField(m_partsWindow.rewards_even["day" + (_loc14_ + 1) + "_tf"],_loc17_);
                  _loc14_++;
               }
            }
            m_partsWindow.rewards_odd.visible = false;
         }
         else
         {
            if(TimedBuildableManager.instance.isManyRewards(volcanoReskinNumber))
            {
               _loc13_ = ZGlobal.getAssetURL(TimedBuildableManager.instance.manyRewardsURL(volcanoReskinNumber));
               _loc14_ = 0;
               while(_loc14_ < noOfCycles)
               {
                  ImageLoaderFactory.CreateImageLoader(_loc13_,_loc8_[_loc14_]);
                  TextFieldUtil.compactTextField(_loc7_[_loc14_],"Multiple Rewards");
                  _loc11_[_loc14_].visible = false;
                  _loc10_[_loc14_].visible = false;
                  _loc9_[_loc14_].visible = false;
                  if(this.m_version == TimedBuildableManager.PLAY_AGAIN_VERSION)
                  {
                     _loc19_ = int(TimedBuildableManager.REWARD_DAYS[_loc14_]);
                     _loc18_ = _loc19_ - TimedBuildableManager.DAYS_PER_CYCLE + 1;
                     _loc17_ = ZGameUtils.ZlocT("Dialogs","TimedBuildablePlayAgainCycle",{
                        "number1":_loc18_,
                        "number2":_loc19_
                     });
                  }
                  else
                  {
                     _loc17_ = ZGameUtils.ZlocT("Dialogs","TimedBuildableCycle",{"number":TimedBuildableManager.REWARD_DAYS[_loc14_]});
                  }
                  TextFieldUtil.compactTextField(m_partsWindow.rewards_even["day" + (_loc14_ + 1) + "_tf"],_loc17_);
                  _loc14_++;
               }
            }
            else
            {
               _loc14_ = 0;
               while(_loc14_ < noOfCycles)
               {
                  ImageLoaderFactory.CreateImageLoader(this.m_rewardsData.rewardIcons[_loc14_],_loc8_[_loc14_]);
                  TextFieldUtil.compactTextField(_loc7_[_loc14_],this.m_rewardsData.rewardPairs[_loc14_].reward);
                  TextFieldUtil.compactTextField(_loc9_[_loc14_],"x" + this.m_rewardsData.rewardPairs[_loc14_].count);
                  if(this.m_rewardsData.rewardPairs[_loc14_].strength)
                  {
                     _loc15_ = ZGlobal.gameSettings.getItemByCode(this.m_rewardsInfo[_loc14_].@item,UnitItem) as UnitItem;
                     _loc16_ = _loc15_.tier;
                     TextFieldUtil.compactTextField(_loc10_[_loc14_].tier_tf,String(_loc16_));
                     TextFieldUtil.compactTextField(_loc11_[_loc14_].strength_tf,this.m_rewardsData.rewardPairs[_loc14_].strength);
                  }
                  else
                  {
                     _loc11_[_loc14_].visible = false;
                     _loc10_[_loc14_].visible = false;
                  }
                  if(this.m_version == TimedBuildableManager.PLAY_AGAIN_VERSION)
                  {
                     _loc19_ = int(TimedBuildableManager.REWARD_DAYS[_loc14_]);
                     _loc18_ = _loc19_ - TimedBuildableManager.DAYS_PER_CYCLE + 1;
                     _loc17_ = ZGameUtils.ZlocT("Dialogs","TimedBuildablePlayAgainCycle",{
                        "number1":_loc18_,
                        "number2":_loc19_
                     });
                  }
                  else
                  {
                     _loc17_ = ZGameUtils.ZlocT("Dialogs","TimedBuildableCycle",{"number":TimedBuildableManager.REWARD_DAYS[_loc14_]});
                  }
                  TextFieldUtil.compactTextField(m_partsWindow.rewards_odd["day" + (_loc14_ + 1) + "_tf"],_loc17_);
                  _loc14_++;
               }
            }
            m_partsWindow.rewards_even.visible = false;
         }
         TextFieldUtil.compactTextField(m_partsWindow.hintTitle_tf,ZGameUtils.ZlocT("Dialogs","TimedBuildableHintLabel"));
         TextFieldUtil.compactTextField(m_partsWindow.hint_tf,ZGameUtils.localizedStringForToken(this.m_textInfo.hint,"Dialogs"));
         this.updateUI();
      }
      
      protected function updateUI() : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:ZGameButton = null;
         this.m_timeLeft = TimedBuildableManager.instance.getTimeRemainingForIndex(volcanoReskinNumber);
         var _loc1_:int = this.m_timeLeft / 86400;
         var _loc2_:Array = [m_partsWindow.rewards_even.starburst1_mc,m_partsWindow.rewards_even.starburst2_mc,m_partsWindow.rewards_even.starburst3_mc,m_partsWindow.rewards_even.starburst4_mc];
         var _loc3_:Array = [m_partsWindow.rewards_odd.starburst1_mc,m_partsWindow.rewards_odd.starburst2_mc,m_partsWindow.rewards_odd.starburst3_mc];
         if(this.m_timeLeft > 0)
         {
            this.m_clocks = [];
            _loc6_ = _loc1_ >= noOfDays ? 1 : int(6 - _loc1_ % 6);
            TextFieldUtil.compactTextField(m_partsWindow.instructions_tf,ZGameUtils.localizedStringForToken(this.m_textInfo.dayCount,"Dialogs",{
               "num":_loc1_ + 1,
               "day":ZGameUtils.ZlocTk("Objects","day","",_loc1_ + 1)
            }));
            TextFieldUtil.compactTextField(m_partsWindow.description_tf,ZGameUtils.localizedStringForToken(this.m_textInfo.desc,"Dialogs"),{
               "filter":"ignore",
               "maxLines":2
            });
            _loc7_ = noOfCycles - this.m_timeLeft / (86400 * NUM_SLOTS);
            if(this.m_defaultFilters == null)
            {
               this.m_defaultFilters = m_partsWindow.rewards_even.rewardTitle1_tf.filters;
            }
            if(this.m_defaultCardFilters == null)
            {
               this.m_defaultCardFilters = m_slotMCs[0].label_mc["generic_tf"].filters;
            }
            if(noOfCycles == 4)
            {
               _loc4_ = 1;
               while(_loc4_ <= noOfCycles)
               {
                  if(_loc4_ - 1 == _loc7_)
                  {
                     m_partsWindow.rewards_even["rewardTitle" + _loc4_ + "_tf"].filters = this.m_defaultFilters;
                     m_partsWindow.rewards_even["icon" + _loc4_].filters = this.m_glowFilter;
                     _loc2_[_loc4_ - 1].visible = true;
                  }
                  else
                  {
                     m_partsWindow.rewards_even["rewardTitle" + _loc4_ + "_tf"].filters = this.m_colorMatrix2;
                     m_partsWindow.rewards_even["day" + _loc4_ + "_tf"].filters = this.m_colorMatrix2;
                     m_partsWindow.rewards_even["icon" + _loc4_].filters = this.m_colorMatrix2;
                     _loc2_[_loc4_ - 1].visible = false;
                  }
                  _loc4_++;
               }
               _loc5_ = 1;
               while(_loc5_ <= 6)
               {
                  if(m_slotData[_loc5_ - 1].haveCount >= m_slotData[_loc5_ - 1].requiredCount)
                  {
                     m_slotMCs[_loc5_ - 1].label_mc.visible = false;
                     m_slotMCs[_loc5_ - 1].glowAnim_mc.visible = false;
                  }
                  else if(_loc5_ < _loc6_)
                  {
                     m_slotMCs[_loc5_ - 1].label_mc.labelBack_mc.visible = false;
                     m_slotMCs[_loc5_ - 1].glowAnim_mc.visible = false;
                     if(_loc7_ == 3)
                     {
                        TextFieldUtil.compactTextField(m_slotMCs[_loc5_ - 1].label_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","TimedBuildableExpired"));
                     }
                     else
                     {
                        TextFieldUtil.compactTextField(m_slotMCs[_loc5_ - 1].label_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","TimedBuildableAvailableIn"));
                        this.m_clocks.push(new GenericCountdownClock(m_slotMCs[_loc5_ - 1].label_mc.clock_mc,this.m_timeLeft - ((noOfCycles - 1 - _loc7_) * NUM_SLOTS + 1 - _loc5_) * 86400 + GlobalEngine.serverTime / 1000,null,true));
                     }
                     if(m_slotData[_loc5_ - 1].askButton)
                     {
                        m_slotData[_loc5_ - 1].askButton.disable_visual(true);
                     }
                  }
                  else if(_loc5_ == _loc6_)
                  {
                     m_slotMCs[_loc5_ - 1].label_mc.labelBack_mc.visible = true;
                     m_slotMCs[_loc5_ - 1].glowAnim_mc.visible = true;
                     TextFieldUtil.compactTextField(m_slotMCs[_loc5_ - 1].label_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","TimedBuildableAvailableFor"));
                     this.m_clocks.push(new GenericCountdownClock(m_slotMCs[_loc5_ - 1].label_mc.clock_mc,this.m_timeLeft - ((noOfCycles - 1 - _loc7_) * NUM_SLOTS + 6 - _loc5_) * 86400 + GlobalEngine.serverTime / 1000,null,true));
                     if(m_slotData[_loc5_ - 1].askButton)
                     {
                        m_slotData[_loc5_ - 1].askButton.enable();
                     }
                  }
                  else
                  {
                     m_slotMCs[_loc5_ - 1].label_mc.labelBack_mc.visible = false;
                     m_slotMCs[_loc5_ - 1].glowAnim_mc.visible = false;
                     TextFieldUtil.compactTextField(m_slotMCs[_loc5_ - 1].label_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","TimedBuildableAvailableIn"));
                     this.m_clocks.push(new GenericCountdownClock(m_slotMCs[_loc5_ - 1].label_mc.clock_mc,this.m_timeLeft - ((noOfCycles - 1 - _loc7_) * NUM_SLOTS + 7 - _loc5_) * 86400 + GlobalEngine.serverTime / 1000,null,true));
                     if(m_slotData[_loc5_ - 1].askButton)
                     {
                        m_slotData[_loc5_ - 1].askButton.disable_visual(true);
                     }
                  }
                  _loc5_++;
               }
            }
            else
            {
               _loc4_ = 1;
               while(_loc4_ <= noOfCycles)
               {
                  if(_loc4_ - 1 == _loc7_)
                  {
                     m_partsWindow.rewards_odd["rewardTitle" + _loc4_ + "_tf"].filters = this.m_defaultFilters;
                     m_partsWindow.rewards_odd["day" + _loc4_ + "_tf"].filters = this.m_defaultFilters;
                     _loc3_[_loc4_ - 1].visible = true;
                  }
                  else
                  {
                     m_partsWindow.rewards_odd["rewardTitle" + _loc4_ + "_tf"].filters = this.m_colorMatrix2;
                     m_partsWindow.rewards_odd["day" + _loc4_ + "_tf"].filters = this.m_colorMatrix2;
                     _loc3_[_loc4_ - 1].visible = false;
                  }
                  _loc4_++;
               }
               _loc5_ = 1;
               while(_loc5_ <= 6)
               {
                  if(m_slotData[_loc5_ - 1].haveCount >= m_slotData[_loc5_ - 1].requiredCount)
                  {
                     m_slotMCs[_loc5_ - 1].label_mc.visible = false;
                     m_slotMCs[_loc5_ - 1].glowAnim_mc.visible = false;
                  }
                  else if(_loc5_ < _loc6_)
                  {
                     m_slotMCs[_loc5_ - 1].label_mc.labelBack_mc.visible = false;
                     m_slotMCs[_loc5_ - 1].glowAnim_mc.visible = false;
                     if(_loc7_ == 3)
                     {
                        TextFieldUtil.compactTextField(m_slotMCs[_loc5_ - 1].label_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","TimedBuildableExpired"));
                     }
                     else
                     {
                        TextFieldUtil.compactTextField(m_slotMCs[_loc5_ - 1].label_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","TimedBuildableAvailableIn"));
                        this.m_clocks.push(new GenericCountdownClock(m_slotMCs[_loc5_ - 1].label_mc.clock_mc,this.m_timeLeft - ((noOfCycles - 1 - _loc7_) * NUM_SLOTS + 1 - _loc5_) * 86400 + GlobalEngine.serverTime / 1000,null,true));
                     }
                     if(m_slotData[_loc5_ - 1].askButton)
                     {
                        m_slotData[_loc5_ - 1].askButton.disable_visual(true);
                     }
                  }
                  else if(_loc5_ == _loc6_)
                  {
                     m_slotMCs[_loc5_ - 1].label_mc.labelBack_mc.visible = true;
                     m_slotMCs[_loc5_ - 1].glowAnim_mc.visible = true;
                     TextFieldUtil.compactTextField(m_slotMCs[_loc5_ - 1].label_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","TimedBuildableAvailableFor"));
                     this.m_clocks.push(new GenericCountdownClock(m_slotMCs[_loc5_ - 1].label_mc.clock_mc,this.m_timeLeft - ((noOfCycles - 1 - _loc7_) * NUM_SLOTS + 6 - _loc5_) * 86400 + GlobalEngine.serverTime / 1000,null,true));
                     if(m_slotData[_loc5_ - 1].askButton)
                     {
                        m_slotData[_loc5_ - 1].askButton.enable();
                     }
                  }
                  else
                  {
                     m_slotMCs[_loc5_ - 1].label_mc.labelBack_mc.visible = false;
                     m_slotMCs[_loc5_ - 1].glowAnim_mc.visible = false;
                     TextFieldUtil.compactTextField(m_slotMCs[_loc5_ - 1].label_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","TimedBuildableAvailableIn"));
                     this.m_clocks.push(new GenericCountdownClock(m_slotMCs[_loc5_ - 1].label_mc.clock_mc,this.m_timeLeft - ((noOfCycles - 1 - _loc7_) * NUM_SLOTS + 7 - _loc5_) * 86400 + GlobalEngine.serverTime / 1000,null,true));
                     if(m_slotData[_loc5_ - 1].askButton)
                     {
                        m_slotData[_loc5_ - 1].askButton.disable_visual(true);
                     }
                  }
                  _loc5_++;
               }
            }
            this.m_timer = new Timer(1000);
            this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer.start();
         }
         else
         {
            this.m_timer = null;
            this.closeWindow(null);
         }
         if(m_partsWindow.hasOwnProperty("hintTip_mc") && m_partsWindow.hasOwnProperty("tooltipBtn"))
         {
            m_partsWindow.hintTip_mc.visible = false;
            TextFieldUtil.compactTextField(m_partsWindow.hintTip_mc.hint_tf,ZGameUtils.localizedStringForToken(this.m_textInfo.hint,"Dialogs"));
            _loc8_ = new ZGameButton(m_partsWindow.tooltipBtn,this.onHintShow,1.1,false,this.onHintHide,this.onHintShow);
         }
      }
      
      override public function buyPartResetScreen() : void
      {
         this.m_timeLeft = TimedBuildableManager.instance.getTimeRemainingForIndex(volcanoReskinNumber);
         var _loc1_:int = this.m_timeLeft / 86400;
         var _loc2_:int = _loc1_ >= noOfDays ? 1 : int(6 - _loc1_ % 6);
         var _loc3_:int = 1;
         while(_loc3_ <= 6)
         {
            if(_loc3_ != _loc2_)
            {
               if(m_slotData[_loc3_ - 1].askButton)
               {
                  m_slotData[_loc3_ - 1].askButton.disable_visual(true);
               }
            }
            _loc3_++;
         }
      }
      
      protected function onTimer(param1:Event) : void
      {
         --this.m_timeLeft;
         if(this.m_timeLeft % 86400 == 0 && m_window != null)
         {
            this.updateUI();
         }
      }
      
      protected function getAccumulatedCount() : int
      {
         var _loc3_:String = null;
         var _loc4_:GameItem = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < NUM_SLOTS)
         {
            _loc3_ = m_partsItem.getPartCodeForIndex(_loc2_);
            _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc3_,GameItem) as GameItem;
            if(_loc4_)
            {
               _loc5_ = ZGlobal.player.getNumberOfInventoryItems(_loc3_);
               _loc6_ = m_partsItem.getPartCountForIndex(_loc2_);
               _loc1_ += Math.min(_loc6_,_loc5_);
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      override protected function onFinishClick(param1:MouseEvent) : void
      {
         super.onFinishClick(param1);
      }
      
      override public function buyAllParts(param1:Dictionary, param2:Boolean = true) : void
      {
         super.buyAllParts(param1,param2);
         this.updateUI();
      }
      
      override protected function closeWindow(param1:MouseEvent) : void
      {
         super.closeWindow(param1);
         if(this.m_timer != null)
         {
            this.m_timer.stop();
         }
         this.m_timer = null;
         TimedBuildablePartsGather.m_window = null;
      }
      
      private function GreenColorMatrix() : ColorMatrixFilter
      {
         var _loc1_:AdjustColor = new AdjustColor();
         _loc1_.hue = 151;
         _loc1_.saturation = 56;
         _loc1_.brightness = 15;
         _loc1_.contrast = -1;
         var _loc2_:Array = _loc1_.CalculateFinalFlatArray();
         return new ColorMatrixFilter(_loc2_);
      }
      
      private function GrayColorMatrix() : ColorMatrixFilter
      {
         var _loc1_:AdjustColor = new AdjustColor();
         _loc1_.hue = -56;
         _loc1_.saturation = -100;
         _loc1_.brightness = -87;
         _loc1_.contrast = 0;
         var _loc2_:Array = _loc1_.CalculateFinalFlatArray();
         return new ColorMatrixFilter(_loc2_);
      }
      
      private function GrayDayColorMatrix() : ColorMatrixFilter
      {
         var _loc1_:AdjustColor = new AdjustColor();
         _loc1_.hue = -56;
         _loc1_.saturation = -100;
         _loc1_.brightness = -70;
         _loc1_.contrast = 0;
         var _loc2_:Array = _loc1_.CalculateFinalFlatArray();
         return new ColorMatrixFilter(_loc2_);
      }
      
      private function whiteGlow() : GlowFilter
      {
         var _loc1_:GlowFilter = new GlowFilter();
         _loc1_.color = 16736000;
         _loc1_.blurX = 9;
         _loc1_.blurY = 9;
         return _loc1_;
      }
      
      public function getRewardsData(param1:XMLList) : Object
      {
         var _loc3_:XML = null;
         var _loc4_:RewardHelper = null;
         var _loc2_:Object = new Object();
         _loc2_.rewardPairs = new Array();
         _loc2_.rewardIcons = new Array();
         for each(_loc3_ in param1)
         {
            _loc4_ = new RewardHelper(_loc3_);
            _loc4_.buildUI(_loc2_,WorldResourceManager.XTRA_LARGE_ICON);
         }
         return _loc2_;
      }
      
      private function onHintShow(param1:Event) : void
      {
         m_partsWindow.hintTip_mc.visible = true;
         TweenLite.to(m_partsWindow.hintTip_mc,0.1,{
            "alpha":1,
            "ease":Quint.easeIn
         });
      }
      
      private function onHintHide(param1:Event) : void
      {
         TweenLite.to(m_partsWindow.hintTip_mc,1,{
            "alpha":0,
            "ease":Quint.easeIn,
            "onComplete":this.hideTip
         });
      }
      
      private function hideTip() : void
      {
         m_partsWindow.hintTip_mc.visible = false;
      }
   }
}

