package displays.screens.pickAlliesScreen
{
   import core.ZGlobal;
   import core.player.Friend;
   import core.player.IAlly;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.screens.gridScreen.GridSlot;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.text.TextField;
   import rendering.rendering2d.SpriteClock;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class PlayerSlot extends GridSlot
   {
      
      public static const TYPE_FRIEND:String = "friend";
      
      protected var m_ally:IAlly = null;
      
      protected var m_iconLoader:ImageLoader = null;
      
      private var m_clock:SpriteClock = null;
      
      protected var m_timerClip:DisplayObject = null;
      
      protected var m_timerText:TextField = null;
      
      protected var m_ignoreTimeout:Boolean = false;
      
      public function PlayerSlot(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:int, param5:int, param6:IAlly, param7:Boolean, param8:Number, param9:Boolean = false)
      {
         super(param1,param2,param3,param4,param5);
         slot.x = param4 * (slot.width * param8);
         slot.y = param5 * (slot.height * param8);
         if(param7)
         {
            slot.selected_mc.visible = true;
         }
         this.m_ally = param6;
         this.m_ignoreTimeout = param9;
         this.filloutStats();
      }
      
      override protected function onSlotCreated() : void
      {
         this.m_timerClip = slot.timer_tf;
         this.m_timerText = slot.timer_tf;
      }
      
      override protected function get className() : String
      {
         return "PickPlayerCard";
      }
      
      override public function getData() : Object
      {
         return this.m_ally;
      }
      
      override protected function doOnClick(param1:MouseEvent) : void
      {
         if(slot.selected_mc.visible)
         {
            UIDispatcher.instance.dispatchEvent(new WorldEvent(DESELECTED,this));
         }
         else
         {
            UIDispatcher.instance.dispatchEvent(new WorldEvent(SELECTED,this));
         }
      }
      
      protected function filloutStats() : void
      {
         this.m_iconLoader = ImageLoaderFactory.CreateImageLoader(this.m_ally.imageUrl,slot.playerCard_mc.icon);
         TextFieldUtil.processTextField(slot.playerCard_mc.name_tf,this.m_ally.firstName);
         slot.playerCard_mc.name_tf.mouseEnabled = false;
         TextFieldUtil.processTextField(slot.playerCard_mc.level_tf,String(this.m_ally.level));
         slot.playerCard_mc.level_tf.mouseEnabled = false;
         this.m_timerClip.visible = false;
         if(this.m_ally is Friend && !this.m_ignoreTimeout && !ZGlobal.player.allies.isAllyValidForConsumable(this.m_ally.id))
         {
            slot.playerCard_mc.filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
            disable();
            this.updateRemainingTimeText();
         }
         else if(ZGlobal.player.allies.isAllyInBattle(this.m_ally.id))
         {
            slot.playerCard_mc.filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
            disable();
            this.m_timerClip.visible = true;
            TextFieldUtil.processTextField(this.m_timerText,ZGameUtils.ZlocT("Dialogs","InBattleMessage"));
         }
      }
      
      protected function updateTimeTextField(param1:Number) : void
      {
         var _loc2_:String = ZGameTimeUtil.instance.getTimeString(param1);
         TextFieldUtil.processTextField(this.m_timerText,ZGameUtils.ZlocT("Dialogs","RemainingAllyTime",{"timeStr":_loc2_}));
      }
      
      override protected function getObjectCode() : String
      {
         return this.m_ally.id;
      }
      
      protected function updateRemainingTimeText() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         if(!this.m_ignoreTimeout && !ZGlobal.player.allies.isAllyValidForConsumable(this.m_ally.id))
         {
            _loc1_ = ZGlobal.player.allies.getAllyTimeoutSeconds();
            _loc2_ = Number(ZGlobal.player.allies.allies[this.m_ally.id]);
            _loc3_ = GlobalEngine.serverTime;
            _loc3_ /= 1000;
            _loc4_ = _loc3_ - _loc2_;
            _loc5_ = Math.ceil(_loc1_ - _loc4_);
            if(null == this.m_clock)
            {
               this.m_clock = new SpriteClock(slot.playerCard_mc.icon);
            }
            this.m_clock.percent = _loc4_ / _loc1_;
            this.updateTimeTextField(_loc5_);
            this.m_timerClip.visible = true;
            Zlab.processManager.schedule(1000,this,this.updateRemainingTimeText);
         }
         else
         {
            if(null != this.m_clock)
            {
               this.m_clock.dispose();
               this.m_clock = null;
            }
            this.m_timerClip.visible = false;
            slot.playerCard_mc.filters = null;
            enable();
         }
      }
      
      override public function dispose() : void
      {
         Zlab.processManager.removeScheduledObject(this);
         if(null != this.m_iconLoader)
         {
            this.m_iconLoader.destroy();
            this.m_iconLoader = null;
         }
         if(null != this.m_clock)
         {
            this.m_clock.dispose();
            this.m_clock = null;
         }
         super.dispose();
      }
   }
}

