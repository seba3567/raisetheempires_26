package displays.screens
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.entities.components.behaviors.states.BehaviorState;
   import core.managers.prisoncamp.PrisonCampManager;
   import core.ui.ZGameButton;
   import displays.ImageLoaderFactory;
   import displays.popups.GenericCountdownClock;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import transactions.TGetPrisonerInfo;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.displays.popups.PopUpBase;
   import zlabs.events.WorldEvent;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class PrisonCampActivationDialog extends ZGamePopUp
   {
      
      public static var ACTIVATE_BUFF_EVENT:String = "activateBuff";
      
      protected var res:SWFResource = null;
      
      protected var m_slots:Array = null;
      
      private var m_start:int = 0;
      
      private var m_end:int = 0;
      
      private var m_total:int = 0;
      
      private var m_fwdButton:ZGameButton;
      
      private var m_backButton:ZGameButton;
      
      private var m_activated:Boolean;
      
      private var m_timer:Timer;
      
      private var m_button:ZGameButton;
      
      public var state:BehaviorState;
      
      public function PrisonCampActivationDialog(param1:Boolean = false)
      {
         this.m_activated = param1;
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PrisonCamp.swf"));
      }
      
      public static function display(param1:Boolean = false, param2:BehaviorState = null) : PopUpBase
      {
         var _loc3_:PrisonCampActivationDialog = null;
         if(ZGlobal.isHome())
         {
            _loc3_ = new PrisonCampActivationDialog(param1);
            if(param2)
            {
               _loc3_.state = param2;
            }
            WindowManager.instance.push(_loc3_);
            return _loc3_;
         }
         return null;
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         this.res = param1;
         var _loc2_:TGetPrisonerInfo = new TGetPrisonerInfo(this);
         TransactionManager.addTransaction(_loc2_,true);
      }
      
      private function resetSlots(param1:int, param2:int) : void
      {
         if(this.m_slots == null)
         {
            return;
         }
         var _loc3_:int = param1;
         while(_loc3_ <= param2 && this.m_slots.length >= param1 && this.m_slots.length >= param2)
         {
            this.m_slots[_loc3_].visible = false;
            _loc3_++;
         }
      }
      
      private function setSlots(param1:int, param2:int) : void
      {
         var _loc7_:MovieClip = null;
         var _loc8_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Number = Number(m_window.grid_mc.anchor_mc.x);
         var _loc5_:Number = Number(m_window.grid_mc.anchor_mc.y);
         if(this.m_slots == null)
         {
            return;
         }
         var _loc6_:int = param1;
         while(_loc6_ <= param2 && this.m_slots.length >= param1 && this.m_slots.length >= param2)
         {
            _loc7_ = this.m_slots[_loc6_];
            _loc7_.x = _loc4_;
            _loc7_.y = _loc5_;
            _loc7_.visible = true;
            if(++_loc3_ % 4 == 0)
            {
               _loc4_ = Number(m_window.grid_mc.anchor_mc.x);
               _loc8_ = _loc3_ / 4;
               _loc5_ = m_window.grid_mc.anchor_mc.y + _loc8_ * 106;
            }
            else
            {
               _loc4_ += 106;
            }
            _loc6_++;
         }
      }
      
      public function show(param1:Object) : void
      {
         var _loc4_:MovieClip = null;
         var _loc9_:Object = null;
         var _loc10_:Number = NaN;
         m_window = this.res.clip.screen_mc;
         var _loc2_:Number = ZGlobal.player.level;
         TextFieldUtil.compactTextField(m_window.title_tf,ZGameUtils.ZlocT("Dialogs","Prison_Camp_Parts_Title"));
         TextFieldUtil.compactTextField(m_window.body_tf,ZGameUtils.ZlocT("Dialogs","Prison_Camp_Desc"),{"fontSize":14});
         m_window.info_tf_2.visible = false;
         m_window.prisonstar2_mc.visible = false;
         m_window.info_tf_3.visible = false;
         m_window.prisonstar3_mc.visible = false;
         TextFieldUtil.compactTextField(m_window.info_tf_0,ZGameUtils.ZlocT("Dialogs","Prison_Camp_Point",{
            "low":1,
            "high":_loc2_ - 11,
            "value":0
         }));
         TextFieldUtil.compactTextField(m_window.info_tf_1,ZGameUtils.ZlocT("Dialogs","Prison_Camp_Point",{
            "low":_loc2_ - 10,
            "high":_loc2_,
            "value":1
         }));
         if(ZGlobal.gameSettings.getMaxLevel() > _loc2_ + 9)
         {
            TextFieldUtil.compactTextField(m_window.info_tf_2,ZGameUtils.ZlocT("Dialogs","Prison_Camp_Points",{
               "low":_loc2_ + 1,
               "high":_loc2_ + 9,
               "value":2
            }));
            m_window.info_tf_2.visible = true;
            m_window.prisonstar2_mc.visible = true;
         }
         else if(ZGlobal.gameSettings.getMaxLevel() > _loc2_)
         {
            TextFieldUtil.compactTextField(m_window.info_tf_2,ZGameUtils.ZlocT("Dialogs","Prison_Camp_Points",{
               "low":_loc2_ + 1,
               "high":ZGlobal.gameSettings.getMaxLevel(),
               "value":2
            }));
            m_window.info_tf_2.visible = true;
            m_window.prisonstar2_mc.visible = true;
         }
         if(ZGlobal.gameSettings.getMaxLevel() > _loc2_ + 10)
         {
            TextFieldUtil.compactTextField(m_window.info_tf_3,ZGameUtils.ZlocT("Dialogs","Prison_Camp_Points",{
               "low":_loc2_ + 10,
               "high":ZGlobal.gameSettings.getMaxLevel(),
               "value":3
            }));
            m_window.info_tf_3.visible = true;
            m_window.prisonstar3_mc.visible = true;
         }
         TextFieldUtil.compactTextField(m_window.key_tf,ZGameUtils.ZlocT("Dialogs","Prison_Camp_CP_Key"));
         TextFieldUtil.compactTextField(m_window.title_tf2,ZGameUtils.ZlocT("Dialogs","Capture_Points"));
         m_window.title_tf2.visible = true;
         TextFieldUtil.compactTextField(m_window.inmates_tf,ZGameUtils.ZlocT("Dialogs","Inmates"));
         var _loc3_:int = 0;
         this.m_slots = new Array();
         var _loc5_:Number = Number(m_window.grid_mc.anchor_mc.x);
         var _loc6_:Number = Number(m_window.grid_mc.anchor_mc.y);
         this.m_total = 0;
         if(param1 is Array)
         {
            for each(_loc9_ in param1)
            {
               if(_loc9_.cp)
               {
                  _loc3_ += _loc9_.cp;
               }
               _loc4_ = this.createSlot(_loc9_);
               this.m_slots.push(_loc4_);
               this.m_total += 1;
            }
         }
         while(this.m_slots.length < 36)
         {
            this.m_slots.push(this.createSlot(null));
         }
         this.m_start = 0;
         this.m_end = 11;
         m_window.grid_mc.forward_bt.addEventListener(MouseEvent.CLICK,this.onForward);
         m_window.grid_mc.back_bt.addEventListener(MouseEvent.CLICK,this.onBack);
         this.resetSlots(0,this.m_slots.length - 1);
         this.setSlots(this.m_start,this.m_end);
         this.m_button = new ZGameButton(m_window.activate_bt,this.onActivateClicked);
         this.m_button.disable();
         if(!this.m_activated)
         {
            this.m_button.compactText(ZGameUtils.ZlocT("Dialogs","Activate_text"),null);
         }
         var _loc7_:Object = PrisonCampManager.instance.getXPBuffThresholds();
         var _loc8_:Number = 0;
         if(_loc3_ <= _loc7_.buff0CP)
         {
            _loc8_ = 0.5 * (_loc3_ / _loc7_.buff0CP);
         }
         else
         {
            _loc8_ = 0.5 + 0.5 * ((_loc3_ - _loc7_.buff0CP) / (_loc7_.buff1CP - _loc7_.buff0CP));
         }
         TextFieldUtil.compactTextField(m_window.meter0_tf,"0");
         m_window.meter0_tf.visible = true;
         TextFieldUtil.compactTextField(m_window.meter1_tf,"" + _loc7_.buff0CP / 2);
         m_window.meter1_tf.visible = true;
         TextFieldUtil.compactTextField(m_window.meter2_tf,_loc7_.buff0CP);
         m_window.meter2_tf.visible = true;
         TextFieldUtil.compactTextField(m_window.meter3_tf,"" + (_loc7_.buff0CP + (_loc7_.buff1CP - _loc7_.buff0CP) / 2));
         m_window.meter3_tf.visible = true;
         TextFieldUtil.processTextField(m_window.meter4_tf,_loc7_.buff1CP);
         m_window.meter4_tf.visible = true;
         if(!this.m_activated)
         {
            if(_loc3_ >= _loc7_.buff1CP)
            {
               m_window.starIcon_mc2.visible = true;
               m_window.starIcon_mc1.visible = false;
               this.m_button.enable();
            }
            else if(_loc3_ >= _loc7_.buff0CP)
            {
               m_window.starIcon_mc2.visible = false;
               m_window.starIcon_mc1.visible = true;
               this.m_button.enable();
            }
            else
            {
               m_window.starIcon_mc2.visible = false;
               m_window.starIcon_mc1.visible = false;
            }
         }
         else
         {
            if(ZGlobal.player.xpMultiplier == 1.5)
            {
               m_window.starIcon_mc2.visible = false;
               m_window.starIcon_mc1.visible = true;
            }
            else
            {
               m_window.starIcon_mc2.visible = true;
               m_window.starIcon_mc1.visible = false;
            }
            _loc10_ = 0;
            if(Boolean(this.state.updateHelper) && Boolean(this.state.updateHelper.remainingDuration) && this.state.updateHelper.remainingDuration > 0)
            {
               _loc10_ = this.state.updateHelper.remainingDuration / 1000;
            }
            this.m_button.compactText(ZGameTimeUtil.instance.getClockString(_loc10_),null);
            this.m_timer = new Timer(1000);
            this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer.start();
         }
         m_window.progressBar_mc.meter_mc.width = m_window.progressBar_mc.base_mc.width * _loc8_;
         m_window.emptyprompt_tf.visible = false;
         addChild(m_window);
         m_origOffsetX = m_window.x;
         m_origOffsetY = m_window.y;
         this.contentWidth = m_window.panel_mc.width;
         this.contentHeight = m_window.panel_mc.height;
         centerWithinStage(Zlab.mainStage);
         m_window.exit_bt.addEventListener(MouseEvent.CLICK,this.onExitClicked,false,0,true);
         m_window.grid_mc.visible = true;
         for each(_loc4_ in this.m_slots)
         {
            m_window.grid_mc.addChild(_loc4_);
         }
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      private function onTimer(param1:Event) : void
      {
         var _loc2_:Number = 0;
         if(Boolean(this.state.updateHelper) && Boolean(this.state.updateHelper.remainingDuration) && this.state.updateHelper.remainingDuration > 0)
         {
            _loc2_ = this.state.updateHelper.remainingDuration / 1000;
         }
         this.m_button.compactText(ZGameTimeUtil.instance.getClockString(_loc2_),null);
      }
      
      private function onForward(param1:Event) : void
      {
         if(this.m_total > this.m_end + 1)
         {
            this.m_start += 12;
            this.m_end += 12;
            this.resetSlots(0,this.m_slots.length - 1);
            this.setSlots(this.m_start,this.m_end);
         }
      }
      
      private function onBack(param1:Event) : void
      {
         if(this.m_start > 0)
         {
            this.m_start -= 12;
            this.m_end -= 12;
            this.resetSlots(0,this.m_slots.length - 1);
            this.setSlots(this.m_start,this.m_end);
         }
      }
      
      private function createSlot(param1:Object) : MovieClip
      {
         var _loc2_:Class = this.res.getAssetClass("Card_mc");
         var _loc3_:MovieClip = new _loc2_();
         _loc3_.points_tf.visible = true;
         TextFieldUtil.compactTextField(_loc3_.points_tf,"+0");
         _loc3_.name_tf.visible = true;
         TextFieldUtil.compactTextField(_loc3_.name_tf,ZGameUtils.ZlocT("Dialogs","Prison_Camp_Empty_Cell"));
         _loc3_.empty_tf.visible = false;
         _loc3_.points_frame_1.visible = false;
         _loc3_.points_frame_2.visible = false;
         _loc3_.points_frame_3.visible = false;
         if(param1)
         {
            if(param1.cp)
            {
               if(param1.cp == 1)
               {
                  TextFieldUtil.compactTextField(_loc3_.points_tf,"+1");
                  _loc3_.points_frame_1.visible = true;
               }
               else if(param1.cp == 2)
               {
                  TextFieldUtil.compactTextField(_loc3_.points_tf,"+2");
                  _loc3_.points_frame_2.visible = true;
               }
               else if(param1.cp == 3)
               {
                  TextFieldUtil.compactTextField(_loc3_.points_tf,"+3");
                  _loc3_.points_frame_3.visible = true;
               }
            }
            if(param1.uid)
            {
               if(ZGlobal.player.getFriendName(param1.uid))
               {
                  TextFieldUtil.compactTextField(_loc3_.name_tf,ZGlobal.player.getFriendName(param1.uid));
               }
               else
               {
                  TextFieldUtil.compactTextField(_loc3_.name_tf,param1.uid);
               }
               if(ZGlobal.player.findFriendById(param1.uid))
               {
                  ImageLoaderFactory.CreateImageLoader(ZGlobal.player.findFriendById(param1.uid).portraitURL,_loc3_.player_mc.icon);
               }
            }
            if(param1.ts)
            {
               new GenericCountdownClock(_loc3_.clock_mc,param1.ts + 3 * 24 * 60 * 60);
            }
         }
         return _loc3_;
      }
      
      private function onExitClicked(param1:MouseEvent) : void
      {
         close();
      }
      
      private function onActivateClicked(param1:MouseEvent) : void
      {
         var _loc2_:Number = PrisonCampManager.instance.getPotentialXPMultiplier();
         if(_loc2_ > 1)
         {
            dispatchEvent(new WorldEvent(ACTIVATE_BUFF_EVENT,{"potentialMult":_loc2_}));
            close();
         }
      }
      
      override protected function deinitDialog() : void
      {
         m_window.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExitClicked);
         m_window.activate_bt.removeEventListener(MouseEvent.CLICK,this.onActivateClicked);
         super.deinitDialog();
      }
      
      public function get neighborGridWidth() : Number
      {
         return 600;
      }
   }
}

