package displays.screens.partsGather
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.VolcanoReskin6Manager;
   import displays.ImageLoaderFactory;
   import displays.popups.GenericCountdownClock;
   import fl.motion.AdjustColor;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class VolcanoReskin6PartsGather extends BuildingPartsGather
   {
      
      private static var m_window:VolcanoReskin6PartsGather;
      
      public static const FINISHED:String = "finished";
      
      public static const COLLECTED:String = "collected";
      
      public static const FAILURE_SPEECH:String = "failurespeech";
      
      protected var m_timer:Timer = null;
      
      protected var m_timeLeft:int = 0;
      
      protected var m_clocks:Array = [];
      
      protected var m_defaultFilters:Array = null;
      
      protected var m_defaultCardFilters:Array = null;
      
      protected var m_starBurst:Array = null;
      
      private var m_colorMatrix:Array = [];
      
      private var m_colorMatrix1:Array = [];
      
      private var m_colorMatrix2:Array = [];
      
      public function VolcanoReskin6PartsGather(param1:EventDispatcher, param2:String, param3:String, param4:IEntity, param5:String = "", param6:String = null)
      {
         super(param1,param2,param3,param4,param5,param6);
         NUM_SLOTS = VolcanoReskin6Manager.NUMOFPARTS;
         this.m_colorMatrix = [this.GreenColorMatrix()];
         this.m_colorMatrix1 = [this.GrayColorMatrix()];
         this.m_colorMatrix2 = [this.GrayDayColorMatrix()];
      }
      
      public static function display(param1:EventDispatcher, param2:String, param3:String, param4:IEntity, param5:String = "", param6:String = null) : void
      {
         m_window = new VolcanoReskin6PartsGather(param1,param2,param3,param4,param5,param6);
         WindowManager.instance.push(m_window);
      }
      
      public static function isVolcanoReskin6Open() : Boolean
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
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByCode(VolcanoReskin6Manager.REWARD_CODE[0],GameItem) as GameItem;
         var _loc3_:String = ZGlobal.gameSettings.getImageByName(_loc2_.name,"icon");
         ImageLoaderFactory.CreateImageLoader(_loc3_,m_partsWindow.icon1);
         TextFieldUtil.compactTextField(m_partsWindow.rewardTitle1_tf,_loc2_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         var _loc4_:GameItem = ZGlobal.gameSettings.getItemByCode(VolcanoReskin6Manager.REWARD_CODE[1],GameItem) as GameItem;
         var _loc5_:String = ZGlobal.gameSettings.getImageByName(_loc4_.name,"icon");
         ImageLoaderFactory.CreateImageLoader(_loc5_,m_partsWindow.icon2);
         TextFieldUtil.compactTextField(m_partsWindow.rewardTitle2_tf,_loc4_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         var _loc6_:GameItem = ZGlobal.gameSettings.getItemByCode(VolcanoReskin6Manager.REWARD_CODE[2],GameItem) as GameItem;
         var _loc7_:String = ZGlobal.gameSettings.getImageByName(_loc6_.name,"icon");
         ImageLoaderFactory.CreateImageLoader(_loc7_,m_partsWindow.icon3);
         TextFieldUtil.compactTextField(m_partsWindow.rewardTitle3_tf,_loc6_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         var _loc8_:GameItem = ZGlobal.gameSettings.getItemByCode(VolcanoReskin6Manager.REWARD_CODE[3],GameItem) as GameItem;
         var _loc9_:String = ZGlobal.gameSettings.getImageByName(_loc8_.name,"icon");
         ImageLoaderFactory.CreateImageLoader(_loc9_,m_partsWindow.icon4);
         TextFieldUtil.compactTextField(m_partsWindow.rewardTitle4_tf,_loc8_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         TextFieldUtil.compactTextField(m_partsWindow.hintTitle_tf,ZGameUtils.ZlocT("Dialogs","VolcanoReskin6_Hint_Label"));
         TextFieldUtil.compactTextField(m_partsWindow.hint_tf,ZGameUtils.ZlocT("Dialogs","VolcanoReskin6_Hint"));
         var _loc10_:int = 1;
         while(_loc10_ <= 4)
         {
            TextFieldUtil.compactTextField(m_partsWindow["day" + _loc10_ + "_tf"],ZGameUtils.ZlocT("Dialogs","ExpiresInDays",{"amount":VolcanoReskin6Manager.REWARD_DAYS[_loc10_ - 1]}));
            _loc10_++;
         }
         this.updateUI();
      }
      
      protected function updateUI() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         this.m_timeLeft = VolcanoReskin6Manager.instance.timeRemaining;
         var _loc1_:int = this.m_timeLeft / 86400;
         this.m_starBurst = [m_partsWindow.starburst1_mc,m_partsWindow.starburst2_mc,m_partsWindow.starburst3_mc,m_partsWindow.starburst4_mc];
         if(this.m_timeLeft > 0)
         {
            TextFieldUtil.compactTextField(m_partsWindow.instructions_tf,ZGameUtils.ZlocT("Dialogs","VolcanoReskin6_Desc2",{"x":_loc1_ + 1}));
            TextFieldUtil.compactTextField(m_partsWindow.description_tf,ZGameUtils.ZlocT("Dialogs","VolcanoReskin6_Desc1"));
            _loc2_ = 4 - this.m_timeLeft / (86400 * NUM_SLOTS);
            if(this.m_defaultFilters == null)
            {
               this.m_defaultFilters = m_partsWindow.rewardTitle1_tf.filters;
            }
            if(this.m_defaultCardFilters == null)
            {
               this.m_defaultCardFilters = m_slotMCs[0].label_mc["generic_tf"].filters;
            }
            _loc3_ = 1;
            while(_loc3_ <= 4)
            {
               if(_loc3_ - 1 == _loc2_)
               {
                  m_partsWindow["day" + _loc3_ + "_tf"].filters = this.m_defaultFilters;
                  m_partsWindow["rewardTitle" + _loc3_ + "_tf"].filters = this.m_defaultFilters;
                  this.m_starBurst[_loc3_ - 1].visible = true;
               }
               else
               {
                  m_partsWindow["rewardTitle" + _loc3_ + "_tf"].filters = this.m_colorMatrix1;
                  m_partsWindow["day" + _loc3_ + "_tf"].filters = this.m_colorMatrix2;
                  this.m_starBurst[_loc3_ - 1].visible = false;
               }
               _loc3_++;
            }
            this.m_clocks = [];
            _loc4_ = _loc1_ >= 24 ? 1 : int(6 - _loc1_ % 6);
            _loc5_ = 1;
            while(_loc5_ <= 6)
            {
               if(m_slotData[_loc5_ - 1].haveCount >= m_slotData[_loc5_ - 1].requiredCount)
               {
                  m_slotMCs[_loc5_ - 1].label_mc.visible = false;
                  TextFieldUtil.compactTextField(m_partsWindow.description_tf,ZGameUtils.ZlocT("Speeches","Speech_Volcano_Reskin6_01_Title"));
               }
               else if(_loc5_ < _loc4_)
               {
                  m_slotMCs[_loc5_ - 1].label_mc.labelBack_mc.visible = false;
                  if(_loc2_ == 3)
                  {
                     m_slotMCs[_loc5_ - 1].label_mc["generic_tf"].filters = this.m_defaultCardFilters;
                     TextFieldUtil.compactTextField(m_slotMCs[_loc5_ - 1].label_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","VolcanoReskin6_Card_3"));
                  }
                  else
                  {
                     m_slotMCs[_loc5_ - 1].label_mc["generic_tf"].filters = this.m_defaultCardFilters;
                     TextFieldUtil.compactTextField(m_slotMCs[_loc5_ - 1].label_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","VolcanoReskin6_Card_1"));
                     this.m_clocks.push(new GenericCountdownClock(m_slotMCs[_loc5_ - 1].label_mc.clock_mc,this.m_timeLeft - ((3 - _loc2_) * NUM_SLOTS + 1 - _loc5_) * 86400 + GlobalEngine.serverTime / 1000,null,true));
                  }
                  if(m_slotData[_loc5_ - 1].askButton)
                  {
                     m_slotData[_loc5_ - 1].askButton.disable_visual(true);
                  }
               }
               else if(_loc5_ == _loc4_)
               {
                  m_slotMCs[_loc5_ - 1].label_mc.labelBack_mc.visible = true;
                  TextFieldUtil.compactTextField(m_slotMCs[_loc5_ - 1].label_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","VolcanoReskin6_Card_2"));
                  this.m_clocks.push(new GenericCountdownClock(m_slotMCs[_loc5_ - 1].label_mc.clock_mc,this.m_timeLeft - ((3 - _loc2_) * NUM_SLOTS + 6 - _loc5_) * 86400 + GlobalEngine.serverTime / 1000,null,true));
                  if(m_slotData[_loc5_ - 1].askButton)
                  {
                     m_slotData[_loc5_ - 1].askButton.enable();
                  }
               }
               else
               {
                  m_slotMCs[_loc5_ - 1].label_mc.labelBack_mc.visible = false;
                  TextFieldUtil.compactTextField(m_slotMCs[_loc5_ - 1].label_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","VolcanoReskin6_Card_1"));
                  this.m_clocks.push(new GenericCountdownClock(m_slotMCs[_loc5_ - 1].label_mc.clock_mc,this.m_timeLeft - ((3 - _loc2_) * NUM_SLOTS + 7 - _loc5_) * 86400 + GlobalEngine.serverTime / 1000,null,true));
                  if(m_slotData[_loc5_ - 1].askButton)
                  {
                     m_slotData[_loc5_ - 1].askButton.disable_visual(true);
                  }
               }
               _loc5_++;
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
      
      protected function exchangeParts(param1:Event) : void
      {
         this.closeWindow(null);
         m_eventDispatcher.dispatchEvent(new Event(COLLECTED));
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
         VolcanoReskin6PartsGather.m_window = null;
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
      
      override public function centerWithinStage(param1:Stage) : void
      {
         centerX = param1.stageWidth / 2 + 40;
         centerY = param1.stageHeight / 2 + 120;
      }
   }
}

