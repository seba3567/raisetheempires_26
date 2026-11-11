package core.ui.menuitem
{
   import Engine.Managers.StatsManager;
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.player.Player;
   import dispatchers.UIDispatcher;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   
   public class PlayerStatsAlertToaster
   {
      
      private static const TWEEN_TIME:Number = 0.4;
      
      private var m_target:MovieClip = null;
      
      private var m_questGate:String = null;
      
      private var m_button:MovieClip = null;
      
      private var m_callback:Function = null;
      
      private var m_showing:Boolean = false;
      
      private var m_enabled:Boolean = false;
      
      private var m_threshold:Number = 0;
      
      private var m_lastValue:Number = 0;
      
      private var m_statsStrings:Array;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      public function PlayerStatsAlertToaster(param1:MovieClip, param2:Function = null, param3:Array = null)
      {
         super();
         this.m_target = param1;
         this.m_button = this.m_target.alert_bt;
         this.m_button.buttonMode = true;
         this.m_button.useHandCursor = true;
         this.m_callback = param2;
         this.m_statsStrings = param3;
         this.m_enabled = true;
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         if(this.m_button)
         {
            this.m_buttonSounds.addButton(this.m_button,ButtonSound.DEFAULT);
         }
         if(this.m_callback != null)
         {
            this.button.addEventListener(MouseEvent.CLICK,this.clicked);
         }
         UIDispatcher.instance.addEventListener(Player.QUEST_LABELS_UPDATED,this.onQuestsUpdated);
         this.hide(true);
      }
      
      private function clicked(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         if(Boolean(this.m_statsStrings) && Boolean(this.m_statsStrings.length))
         {
            _loc2_ = this.m_statsStrings[0];
            _loc3_ = this.m_statsStrings.length > 1 ? this.m_statsStrings[1] : "";
            _loc4_ = this.m_statsStrings.length > 2 ? this.m_statsStrings[2] : "";
            _loc5_ = this.m_statsStrings.length > 3 ? this.m_statsStrings[3] : "";
            _loc6_ = this.m_statsStrings.length > 4 ? this.m_statsStrings[4] : "";
            _loc7_ = this.m_statsStrings.length > 5 ? this.m_statsStrings[5] : "";
            StatsManager.count(_loc2_,_loc3_,_loc4_,_loc5_,_loc6_,_loc7_);
         }
         this.m_callback(param1);
      }
      
      public function dispose() : void
      {
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         this.button.removeEventListener(MouseEvent.CLICK,this.m_callback);
         UIDispatcher.instance.removeEventListener(Player.QUEST_LABELS_UPDATED,this.onQuestsUpdated);
         this.m_callback = null;
         this.m_button = null;
         this.m_target = null;
      }
      
      public function get button() : MovieClip
      {
         return this.m_target.alert_bt;
      }
      
      public function get showing() : Boolean
      {
         return this.m_showing;
      }
      
      public function show(param1:Boolean = false) : void
      {
         if(!this.m_showing || param1)
         {
            this.animateButton(this.m_target.mask_mc.x,param1);
            this.m_showing = true;
         }
      }
      
      public function hide(param1:Boolean = false) : void
      {
         if(this.m_showing || param1)
         {
            this.animateButton(this.m_target.mask_mc.x - this.m_button.width - 4,param1);
            this.m_showing = false;
         }
      }
      
      public function set threshold(param1:Number) : void
      {
         this.m_threshold = param1;
      }
      
      public function set questGate(param1:String) : void
      {
         this.m_questGate = param1;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         this.m_enabled = param1;
         if(this.m_enabled)
         {
            this.updateStateForValue(this.m_lastValue);
         }
      }
      
      public function updateStateForValue(param1:Number) : void
      {
         this.m_lastValue = param1;
         if(this.m_enabled)
         {
            if(param1 >= this.m_threshold)
            {
               this.hide();
            }
            else
            {
               if(this.isQuestLocked())
               {
                  return;
               }
               this.show();
            }
         }
      }
      
      private function isQuestLocked() : Boolean
      {
         var _loc1_:Array = null;
         var _loc2_:String = null;
         if(this.m_questGate)
         {
            _loc1_ = this.m_questGate.split(",");
            for each(_loc2_ in _loc1_)
            {
               if(ZGlobal.player.questGatesComplete || ZGlobal.player.didCompleteQuest(_loc2_))
               {
                  return false;
               }
            }
            return true;
         }
         return false;
      }
      
      private function animateButton(param1:Number, param2:Boolean = false) : void
      {
         TweenLite.killTweensOf(this.m_button);
         if(param2)
         {
            this.m_button.x = param1;
         }
         else
         {
            TweenLite.to(this.m_button,TWEEN_TIME,{"x":param1});
         }
      }
      
      private function onQuestsUpdated(param1:Event) : void
      {
         this.updateStateForValue(this.m_lastValue);
      }
   }
}

