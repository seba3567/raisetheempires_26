package displays.screens.partsGather
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.DeepSeaDrillManager;
   import core.managers.WorldResourceManager;
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
   
   public class DeepSeaDrillPartsGather extends BuildingPartsGather
   {
      
      public static const FINISHED:String = "deep_sea_drill_finished";
      
      protected static var m_window:DeepSeaDrillPartsGather = null;
      
      protected var m_timer:Timer = null;
      
      protected var m_timeLeft:int = 0;
      
      protected var m_clocks:Array = [];
      
      protected var m_defaultFilters:Array = null;
      
      protected var m_defaultCardFilters:Array = null;
      
      protected var m_colorMatrix:Array = [];
      
      public function DeepSeaDrillPartsGather(param1:EventDispatcher, param2:String, param3:String, param4:IEntity, param5:String = "", param6:String = null)
      {
         super(param1,param2,param3,param4,param5,param6);
         NUM_SLOTS = DeepSeaDrillManager.NUM_PARTS;
         this.m_colorMatrix = [this.GreenColorMatrix()];
      }
      
      public static function display(param1:EventDispatcher, param2:String, param3:String, param4:IEntity, param5:String = "", param6:String = null) : void
      {
         m_window = new DeepSeaDrillPartsGather(param1,param2,param3,param4,param5,param6);
         WindowManager.instance.push(m_window);
      }
      
      public static function isPartsGatherOpen() : Boolean
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
         ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/quests/Quests_Icons_1.swf/Quest_DeepSeaDrill_01_96.png"),m_partsWindow.icon);
         var _loc2_:String = WorldResourceManager.instance.getResourceFriendlyNameFromType(DeepSeaDrillManager.REWARD_TYPE,GameItem.MENU_FRIENDLYNAME,false);
         TextFieldUtil.compactTextField(m_partsWindow.rewardTitle_tf,_loc2_);
         TextFieldUtil.compactTextField(m_partsWindow.hintTitle_tf,ZGameUtils.ZlocT("Dialogs","DeepSeaDrill_Hint_Label"));
         TextFieldUtil.compactTextField(m_partsWindow.hint_tf,ZGameUtils.ZlocT("Dialogs","DeepSeaDrill_Hint"));
         var _loc3_:int = 1;
         while(_loc3_ <= 4)
         {
            TextFieldUtil.compactTextField(m_partsWindow["reward" + _loc3_ + "_tf"],"x" + DeepSeaDrillManager.REWARD_MULTI[_loc3_ - 1]);
            TextFieldUtil.compactTextField(m_partsWindow["day" + _loc3_ + "_tf"],ZGameUtils.ZlocT("Dialogs","ExpiresInDays",{"amount":DeepSeaDrillManager.REWARD_DAYS[_loc3_ - 1]}));
            _loc3_++;
         }
         this.updateUI();
      }
      
      protected function updateUI() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         this.m_timeLeft = DeepSeaDrillManager.instance.timeRemaining;
         var _loc1_:int = this.m_timeLeft / 86400;
         if(this.m_timeLeft > 0)
         {
            TextFieldUtil.compactTextField(m_partsWindow.instructions_tf,ZGameUtils.ZlocT("Dialogs","DeepSeaDrill_Desc2",{"x":_loc1_ + 1}));
            TextFieldUtil.compactTextField(m_partsWindow.description_tf,ZGameUtils.ZlocT("Dialogs","DeepSeaDrill_Desc1"));
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
                     TextFieldUtil.compactTextField(m_slotMCs[_loc5_ - 1].label_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","DeepSeaDrill_Card_3"));
                  }
                  else
                  {
                     m_slotMCs[_loc5_ - 1].label_mc["generic_tf"].filters = this.m_defaultCardFilters;
                     TextFieldUtil.compactTextField(m_slotMCs[_loc5_ - 1].label_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","DeepSeaDrill_Card_1"));
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
                  TextFieldUtil.compactTextField(m_slotMCs[_loc5_ - 1].label_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","DeepSeaDrill_Card_2"));
                  this.m_clocks.push(new GenericCountdownClock(m_slotMCs[_loc5_ - 1].label_mc.clock_mc,this.m_timeLeft - ((3 - _loc2_) * NUM_SLOTS + 6 - _loc5_) * 86400 + GlobalEngine.serverTime / 1000,null,true));
                  if(m_slotData[_loc5_ - 1].askButton)
                  {
                     m_slotData[_loc5_ - 1].askButton.enable();
                  }
               }
               else
               {
                  m_slotMCs[_loc5_ - 1].label_mc["generic_tf"].filters = this.m_defaultCardFilters;
                  TextFieldUtil.compactTextField(m_slotMCs[_loc5_ - 1].label_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","DeepSeaDrill_Card_1"));
                  this.m_clocks.push(new GenericCountdownClock(m_slotMCs[_loc5_ - 1].label_mc.clock_mc,this.m_timeLeft - ((3 - _loc2_) * NUM_SLOTS + 7 - _loc5_) * 86400 + GlobalEngine.serverTime / 1000,null,true));
                  if(m_slotData[_loc5_ - 1].askButton)
                  {
                     m_slotData[_loc5_ - 1].askButton.disable_visual(true);
                  }
               }
               _loc5_++;
            }
            if(!this.m_timer)
            {
               this.m_timer = new Timer(30000);
               this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
               this.m_timer.start();
            }
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
         if(this.m_timeLeft % 86400 == 0 && DeepSeaDrillPartsGather.m_window != null)
         {
            this.updateUI();
         }
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
         if(this.m_timer != null)
         {
            this.m_timer.stop();
         }
         this.m_timer = null;
         DeepSeaDrillPartsGather.m_window = null;
      }
      
      private function GreenColorMatrix() : ColorMatrixFilter
      {
         var _loc1_:AdjustColor = new AdjustColor();
         _loc1_.hue = -61;
         _loc1_.saturation = 75;
         _loc1_.brightness = 72;
         _loc1_.contrast = 0;
         var _loc2_:Array = _loc1_.CalculateFinalFlatArray();
         return new ColorMatrixFilter(_loc2_);
      }
   }
}

