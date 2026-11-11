package displays.screens.dominationMode
{
   import core.ZGlobal;
   import core.managers.domination.DominationModeManager;
   import core.ui.Tooltip;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.AlarmCountdownClock;
   import displays.screens.gridScreen.GridSlot;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.resource.SWFResource;
   
   public class DominationModeScreenGridSlot extends GridSlot
   {
      
      private var m_mc:MovieClip = null;
      
      private var m_data:Object = null;
      
      private var m_index:int = 0;
      
      private var m_button:ZGameButton = null;
      
      private var m_chatButton:ZGameButton = null;
      
      private var m_hitListButton:ZGameButton = null;
      
      private var m_clock:AlarmCountdownClock;
      
      private var m_imageLoaders:Array = null;
      
      private var m_isRival:Boolean = false;
      
      private var m_activeEnemy:Boolean;
      
      public function DominationModeScreenGridSlot(param1:SWFResource, param2:MovieClip, param3:int, param4:int, param5:Object, param6:int, param7:Boolean, param8:String)
      {
         this.m_data = param5;
         this.m_index = param6;
         this.m_isRival = param7;
         this.m_activeEnemy = param8 == this.getEnemyID();
         super(param1,param2,null);
         slot.x = param3 * sizerWidth;
         slot.y = param4 * sizerHeight;
      }
      
      override public function dispose() : void
      {
         if(this.m_chatButton)
         {
            this.m_chatButton.dispose();
            this.m_chatButton = null;
         }
         if(this.m_hitListButton)
         {
            this.m_hitListButton.removeTooltip();
            this.m_hitListButton.dispose();
            this.m_hitListButton = null;
         }
         if(this.m_button)
         {
            this.m_button.dispose();
            this.m_button = null;
         }
         super.dispose();
      }
      
      override protected function get className() : String
      {
         return "Slot_mc";
      }
      
      override protected function createSlot(param1:SWFResource) : MovieClip
      {
         var _loc2_:Class = param1.getAssetClass(this.className);
         return new _loc2_();
      }
      
      override protected function onSlotCreated() : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         this.m_imageLoaders = new Array();
         var _loc1_:ImageLoader = ImageLoaderFactory.CreateImageLoader(this.m_data.u_info.image,slot.player_mc.icon_mc);
         this.m_imageLoaders.push(_loc1_);
         TextFieldUtil.processTextField(slot.num_tf,(1 + this.m_index).toString());
         var _loc2_:int = this.m_data.d_info.dr > 0 ? int(this.m_data.d_info.dr) : 1;
         TextFieldUtil.processTextField(slot.rank_tf,_loc2_.toString());
         TextFieldUtil.processTextField(slot.name_tf,this.m_data.u_info.name);
         TextFieldUtil.processTextField(slot.name_revenge_mc.name_tf,this.m_data.u_info.name);
         TextFieldUtil.processTextField(slot.level_mc.value_tf,this.m_data.u_info.level.toString());
         TextFieldUtil.compactTextField(slot.wins_tf,ZGameUtils.ZlocT("Dialogs","DominationSlotWins",{"num":this.m_data.d_info.w}));
         TextFieldUtil.compactTextField(slot.losses_tf,ZGameUtils.ZlocT("Dialogs","DominationSlotLosses",{"num":this.m_data.d_info.dfw}));
         if(!this.m_isRival)
         {
            slot.message_bt.visible = false;
            slot.skull_bt.visible = false;
            slot.bg_mc_revenge.visible = false;
            slot.points_revenge_mc.visible = false;
            slot.name_revenge_mc.visible = false;
         }
         else
         {
            slot.message_bt.generic_tf = new TextField();
            this.m_chatButton = new ZGameButton(slot.message_bt,this.onChatClicked);
            this.updateChatButton();
            slot.skull_bt.generic_tf = new TextField();
            this.m_hitListButton = new ZGameButton(slot.skull_bt,this.onHitRequestClicked);
            this.m_hitListButton.addTooltip(ZGameUtils.ZlocT("Dialogs","DominanceHitlistTooltip"),DominationModeManager.instance.tooltipOptions);
         }
         if(this.isWaiting)
         {
            slot.header_tf.visible = false;
            slot.points_tf.visible = false;
            slot.points_revenge_mc.visible = false;
         }
         else
         {
            TextFieldUtil.processTextField(slot.header_tf,ZGameUtils.ZlocT("Dialogs","DominationRewardHeader"));
            TextFieldUtil.processTextField(slot.points_tf,this.m_data.d_info.scInc.toString());
            TextFieldUtil.processTextField(slot.points_revenge_mc.points_tf,this.m_data.d_info.scInc.toString());
         }
         slot.waitinfo_tf.visible = false;
         if(!this.m_isRival)
         {
            slot.info_tf.visible = false;
            slot.clock_mc.visible = false;
            slot.bonus_mc.visible = false;
            this.m_button = new ZGameButton(slot.red_bt,this.onAttackClicked);
            this.m_button.text = ZLoc.t("Dialogs",this.attackButtonStringKey);
         }
         else if(this.isWaiting)
         {
            slot.revenge_bt.visible = false;
            slot.red_bt.visible = false;
            slot.clock_mc.visible = false;
            slot.info_tf.visible = false;
            slot.bonus_mc.visible = false;
            slot.waitinfo_tf.visible = true;
            TextFieldUtil.processTextField(slot.waitinfo_tf,ZGameUtils.ZlocT("Dialogs","DominationRivalWaitLabel"));
         }
         else
         {
            _loc3_ = GlobalEngine.serverTime / 1000;
            _loc4_ = this.revengeDuration;
            if(this.m_data.d_info.ts + _loc4_ > _loc3_)
            {
               TextFieldUtil.processTextField(slot.bonus_mc.bonus_tf,ZGameUtils.ZlocT("Dialogs","DominationRevengeBonus",{"amount":this.m_data.d_info.scBns}));
               slot.bonus_mc.visible = true;
               slot.revenge_bt.visible = true;
               slot.bg_mc_default.visible = false;
               slot.points_tf.visible = false;
               slot.bg_mc_revenge.visible = true;
               slot.points_revenge_mc.visible = true;
               slot.name_revenge_mc.visible = true;
               slot.name_tf.visible = false;
               slot.red_bt.visible = false;
               this.m_button = new ZGameButton(slot.revenge_bt,this.onRevengeClicked);
               this.m_button.text = ZLoc.t("Dialogs","DominationRevenge");
               slot.clock_mc.visible = true;
               this.m_clock = new AlarmCountdownClock(slot.clock_mc,this.m_data.d_info.ts + _loc4_);
               this.m_clock.alarm.addEventListener(AlarmCountdownClock.TIMER_EXPIRED,this.onTimerEnd);
               slot.info_tf.visible = false;
               Tooltip.subscribe(slot.clock_mc,ZGameUtils.ZlocT("Dialogs","DominanceTimerTooltip"));
               this.m_button.addTooltip(ZGameUtils.ZlocT("Dialogs","DominanceRevengeTooltip"));
            }
            else
            {
               this.setupRivalExpiredTimer();
            }
         }
      }
      
      private function get revengeDuration() : int
      {
         var _loc1_:String = ZGlobal.gameSettings.getString("DominanceRevengeDuration","24h");
         return ZGameTimeUtil.instance.parseTimeAsSeconds(_loc1_,0);
      }
      
      private function onChatClicked(param1:Event) : void
      {
         var _loc2_:String = this.m_data.u_info.id;
         DominationModeManager.instance.getDominationModeChatHistory(_loc2_);
         DominationModeManager.instance.clearHasNewChat(_loc2_);
         this.updateChatButton();
      }
      
      private function updateChatButton() : void
      {
         var _loc1_:String = null;
         var _loc2_:Boolean = false;
         var _loc3_:String = null;
         if(this.m_chatButton)
         {
            _loc1_ = this.getEnemyID();
            _loc2_ = DominationModeManager.instance.hasNewChat(_loc1_);
            slot.message_bt.new_mc.visible = _loc2_;
            _loc3_ = _loc2_ ? "DominanceNewMessageTooltip" : "DominanceChatButtonTooltip";
            this.m_chatButton.addTooltip(ZGameUtils.ZlocT("Dialogs",_loc3_),DominationModeManager.instance.tooltipOptions);
         }
      }
      
      private function onHitRequestClicked(param1:Event) : void
      {
         DominationModeManager.instance.sendHitListRequest(this.m_data.u_info.id);
      }
      
      private function setupRivalExpiredTimer() : void
      {
         slot.bonus_mc.visible = false;
         slot.revenge_bt.visible = false;
         slot.clock_mc.visible = false;
         slot.red_bt.visible = true;
         slot.info_tf.visible = true;
         slot.bg_mc_default.visible = true;
         slot.points_tf.visible = true;
         slot.bg_mc_revenge.visible = false;
         slot.points_revenge_mc.visible = false;
         slot.name_revenge_mc.visible = false;
         slot.name_tf.visible = true;
         this.calcLastResultTime(slot.info_tf);
         this.m_button = new ZGameButton(slot.red_bt,this.onAttackClicked);
         this.m_button.text = ZLoc.t("Dialogs",this.attackButtonStringKey);
      }
      
      protected function onTimerEnd(param1:Event) : void
      {
         this.m_clock.alarm.removeEventListener(AlarmCountdownClock.TIMER_EXPIRED,this.onTimerEnd);
         this.m_clock = null;
         this.setupRivalExpiredTimer();
      }
      
      private function calcLastResultTime(param1:TextField) : void
      {
         var _loc2_:int = GlobalEngine.serverTime / 1000 - this.m_data.d_info.ts;
         if(_loc2_ < 60 * 60)
         {
            _loc2_ = 60 * 60;
         }
         var _loc3_:String = ZGameTimeUtil.instance.getTimeString(_loc2_,false);
         TextFieldUtil.compactTextField(param1,ZLoc.t("Dialogs","DominationLastAttacked",{"time":_loc3_}));
      }
      
      private function onAttackClicked(param1:MouseEvent) : void
      {
         var _loc2_:String = this.m_data.u_info.id;
         DominationModeManager.instance.loadDominationModeBattle(null,_loc2_);
         DominationModeManager.instance.dispatchEvent(new Event(DominationModeManager.FIGHT_LIST_TARGET_SELECTED));
         DominationModeManager.instance.updateDominationSeenFlag(DominationModeManager.SEEN_FIRST_FIGHT);
      }
      
      private function onRevengeClicked(param1:MouseEvent) : void
      {
         var _loc2_:String = this.m_data.u_info.id;
         DominationModeManager.instance.loadDominationModeBattle(null,_loc2_);
         DominationModeManager.instance.dispatchEvent(new Event(DominationModeManager.FIGHT_LIST_TARGET_SELECTED));
      }
      
      override protected function onRollOver(param1:MouseEvent) : void
      {
      }
      
      override protected function onRollOut(param1:MouseEvent) : void
      {
      }
      
      override protected function doOnClick(param1:MouseEvent) : void
      {
      }
      
      public function getAttackButton() : DisplayObject
      {
         return Boolean(slot) && Boolean(slot.red_bt) ? slot.red_bt : null;
      }
      
      public function getEnemyID() : String
      {
         return this.m_data.u_info.id;
      }
      
      override public function enable() : void
      {
         super.enable();
         if(this.m_button)
         {
            this.m_button.enable();
         }
         super.setUseHandCursor(false);
         super.setButtonMode(false);
      }
      
      override public function disable() : void
      {
         Tooltip.unsubscribe(slot.clock_mc);
         if(this.m_button)
         {
            this.m_button.removeTooltip();
            this.m_button.disable_visual();
         }
         super.disable();
      }
      
      public function get active() : Boolean
      {
         return !this.isWaiting;
      }
      
      private function get isWaiting() : Boolean
      {
         return (this.m_data.d_info.status & DominationModeManager.DOM_VICTIMSTATUS_WAITING) != 0;
      }
      
      private function get attackButtonStringKey() : String
      {
         if(this.m_activeEnemy)
         {
            return "DominationContinue";
         }
         return "DominationAttack";
      }
   }
}

