package displays.screens.partsGather
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.MeteoriteMiningManager;
   import displays.ImageLoaderFactory;
   import displays.popups.GenericCountdownClock;
   import fl.motion.AdjustColor;
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
   
   public class MeteoriteMiningPartsGather extends BuildingPartsGather
   {
      
      private static var m_window:MeteoriteMiningPartsGather;
      
      public static const FINISHED:String = "meteorite_finished";
      
      public static const COLLECTED:String = "meteorite_collected";
      
      protected var m_timer:Timer = null;
      
      protected var m_timeLeft:int = 0;
      
      protected var m_clocks:Array = [];
      
      protected var m_defaultFilters:Array = null;
      
      protected var m_defaultCardFilters:Array = null;
      
      private var m_colorMatrix:Array = [];
      
      public function MeteoriteMiningPartsGather(param1:EventDispatcher, param2:String, param3:String, param4:IEntity, param5:String = "", param6:String = null)
      {
         super(param1,param2,param3,param4,param5,param6);
         NUM_SLOTS = 6;
         var _loc7_:AdjustColor = new AdjustColor();
         _loc7_.hue = -61;
         _loc7_.saturation = 75;
         _loc7_.brightness = 72;
         _loc7_.contrast = 0;
         var _loc8_:Array = _loc7_.CalculateFinalFlatArray();
         this.m_colorMatrix = [new ColorMatrixFilter(_loc8_)];
      }
      
      public static function display(param1:EventDispatcher, param2:String, param3:String, param4:IEntity, param5:String = "", param6:String = null) : void
      {
         m_window = new MeteoriteMiningPartsGather(param1,param2,param3,param4,param5,param6);
         WindowManager.instance.push(m_window);
      }
      
      public static function isMeteoriteMiningOpen() : Boolean
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
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByCode(MeteoriteMiningManager.REWARD_CODE,GameItem) as GameItem;
         var _loc3_:String = ZGlobal.gameSettings.getImageByName(_loc2_.name,"icon");
         ImageLoaderFactory.CreateImageLoader(_loc3_,m_partsWindow.icon);
         TextFieldUtil.compactTextField(m_partsWindow.rewardTitle_tf,_loc2_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         TextFieldUtil.compactTextField(m_partsWindow.hintTitle_tf,ZGameUtils.ZlocT("Dialogs","VolcanoPower_Hint_Label"));
         TextFieldUtil.compactTextField(m_partsWindow.hint_tf,ZGameUtils.ZlocT("Dialogs","MeteoriteMining_Hint"));
         var _loc4_:int = 1;
         while(_loc4_ <= 4)
         {
            TextFieldUtil.compactTextField(m_partsWindow["reward" + _loc4_ + "_tf"],"x" + MeteoriteMiningManager.REWARD_MULTI[_loc4_ - 1]);
            TextFieldUtil.compactTextField(m_partsWindow["day" + _loc4_ + "_tf"],ZGameUtils.ZlocT("Dialogs","ExpiresInDays",{"amount":MeteoriteMiningManager.REWARD_DAYS[_loc4_ - 1]}));
            _loc4_++;
         }
         this.updateUI();
      }
      
      protected function updateUI() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         this.m_timeLeft = MeteoriteMiningManager.instance.timeRemaining;
         var _loc1_:int = this.m_timeLeft / 86400;
         if(this.m_timeLeft > 0)
         {
            TextFieldUtil.compactTextField(m_partsWindow.instructions_tf,ZGameUtils.ZlocT("Dialogs","MeteoriteMining_Desc2",{"x":_loc1_ + 1}));
            TextFieldUtil.compactTextField(m_partsWindow.description_tf,ZGameUtils.ZlocT("Dialogs","MeteoriteMining_Desc1"));
            _loc2_ = 4 - this.m_timeLeft / (86400 * NUM_SLOTS);
            if(this.m_defaultFilters == null)
            {
               this.m_defaultFilters = m_partsWindow.reward1_tf.filters;
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
                  m_partsWindow["reward" + _loc3_ + "_tf"].filters = this.m_defaultFilters;
                  m_partsWindow["day" + _loc3_ + "_tf"].filters = this.m_defaultFilters;
               }
               else
               {
                  m_partsWindow["reward" + _loc3_ + "_tf"].filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
                  m_partsWindow["day" + _loc3_ + "_tf"].filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
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
               }
               else if(_loc5_ < _loc4_)
               {
                  if(_loc2_ == 3)
                  {
                     m_slotMCs[_loc5_ - 1].label_mc["generic_tf"].filters = this.m_defaultCardFilters;
                     TextFieldUtil.compactTextField(m_slotMCs[_loc5_ - 1].label_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","MeteoriteMining_Card_3"));
                  }
                  else
                  {
                     m_slotMCs[_loc5_ - 1].label_mc["generic_tf"].filters = this.m_defaultCardFilters;
                     TextFieldUtil.compactTextField(m_slotMCs[_loc5_ - 1].label_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","MeteoriteMining_Card_1"));
                     this.m_clocks.push(new GenericCountdownClock(m_slotMCs[_loc5_ - 1].label_mc.clock_mc,this.m_timeLeft - ((3 - _loc2_) * NUM_SLOTS + 1 - _loc5_) * 86400 + GlobalEngine.serverTime / 1000,null,true));
                  }
                  if(m_slotData[_loc5_ - 1].askButton)
                  {
                     m_slotData[_loc5_ - 1].askButton.disable_visual(true);
                  }
               }
               else if(_loc5_ == _loc4_)
               {
                  m_slotMCs[_loc5_ - 1].label_mc["generic_tf"].filters = this.m_colorMatrix;
                  TextFieldUtil.compactTextField(m_slotMCs[_loc5_ - 1].label_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","MeteoriteMining_Card_2"));
                  this.m_clocks.push(new GenericCountdownClock(m_slotMCs[_loc5_ - 1].label_mc.clock_mc,this.m_timeLeft - ((3 - _loc2_) * NUM_SLOTS + 6 - _loc5_) * 86400 + GlobalEngine.serverTime / 1000,null,true));
                  if(m_slotData[_loc5_ - 1].askButton)
                  {
                     m_slotData[_loc5_ - 1].askButton.enable();
                  }
               }
               else
               {
                  m_slotMCs[_loc5_ - 1].label_mc["generic_tf"].filters = this.m_defaultCardFilters;
                  TextFieldUtil.compactTextField(m_slotMCs[_loc5_ - 1].label_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","MeteoriteMining_Card_1"));
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
         m_eventDispatcher.dispatchEvent(new Event(FINISHED));
      }
      
      override public function buyAllParts(param1:Dictionary, param2:Boolean = true) : void
      {
         super.buyAllParts(param1,param2);
         this.updateUI();
      }
      
      override protected function closeWindow(param1:MouseEvent) : void
      {
         super.closeWindow(param1);
         m_window = null;
      }
   }
}

