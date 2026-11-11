package displays.popups
{
   import flash.display.MovieClip;
   import utils.TextFieldUtil;
   import zlabs.Zlab;
   
   public class CountdownClock
   {
      
      private static const UPDATE_FREQUENCY:int = 1000;
      
      private static const URGENT_THRESHOLD_SECONDS:Number = 60 * 60 * 6;
      
      protected var m_clip:MovieClip = null;
      
      protected var onUpdate:Function = null;
      
      protected var m_hideSeconds:Boolean = false;
      
      protected var m_hideDays:Boolean = false;
      
      public function CountdownClock(param1:MovieClip, param2:Function = null, param3:Boolean = false, param4:Boolean = false)
      {
         super();
         this.m_clip = param1;
         this.onUpdate = param2;
         this.m_hideSeconds = param3;
         this.m_hideDays = param4;
         if(Boolean(this.m_clip) && this.isValid)
         {
            this.onUpdateClock();
         }
      }
      
      public static function updateClockAsset(param1:MovieClip, param2:Boolean, param3:Object, param4:Boolean = false, param5:Boolean = false) : void
      {
         param1.num_tf3.visible = !param2;
         param1.num_tf4.visible = !param2;
         param1.num_tf5.visible = !param2;
         param1.num_tf6.visible = !param2;
         if(!param4)
         {
            param1.num_tf7.visible = !param2;
            param1.num_tf8.visible = !param2;
         }
         if(!param5)
         {
            param1.num_tf1.visible = !param2;
            param1.num_tf2.visible = !param2;
         }
         param1.num_tf3_red.visible = param2;
         param1.num_tf4_red.visible = param2;
         param1.num_tf5_red.visible = param2;
         param1.num_tf6_red.visible = param2;
         if(!param4)
         {
            param1.num_tf7_red.visible = param2;
            param1.num_tf8_red.visible = param2;
         }
         if(!param5)
         {
            param1.num_tf1_red.visible = param2;
            param1.num_tf2_red.visible = param2;
         }
         if(!param2)
         {
            TextFieldUtil.processTextField(param1.num_tf3,String(param3["hours.10"]));
            TextFieldUtil.processTextField(param1.num_tf4,String(param3["hours.1"]));
            TextFieldUtil.processTextField(param1.num_tf5,String(param3["minutes.10"]));
            TextFieldUtil.processTextField(param1.num_tf6,String(param3["minutes.1"]));
            if(!param4)
            {
               TextFieldUtil.processTextField(param1.num_tf7,String(param3["seconds.10"]));
               TextFieldUtil.processTextField(param1.num_tf8,String(param3["seconds.1"]));
            }
            if(!param5)
            {
               TextFieldUtil.processTextField(param1.num_tf1,String(param3["days.10"]));
               TextFieldUtil.processTextField(param1.num_tf2,String(param3["days.1"]));
            }
         }
         else
         {
            TextFieldUtil.processTextField(param1.num_tf3_red,String(param3["hours.10"]));
            TextFieldUtil.processTextField(param1.num_tf4_red,String(param3["hours.1"]));
            TextFieldUtil.processTextField(param1.num_tf5_red,String(param3["minutes.10"]));
            TextFieldUtil.processTextField(param1.num_tf6_red,String(param3["minutes.1"]));
            if(!param4)
            {
               TextFieldUtil.processTextField(param1.num_tf7_red,String(param3["seconds.10"]));
               TextFieldUtil.processTextField(param1.num_tf8_red,String(param3["seconds.1"]));
            }
            if(!param5)
            {
               TextFieldUtil.processTextField(param1.num_tf1_red,String(param3["days.10"]));
               TextFieldUtil.processTextField(param1.num_tf2_red,String(param3["days.1"]));
            }
         }
      }
      
      public function dispose() : void
      {
         Zlab.processManager.removeScheduledObject(this);
      }
      
      protected function get isValid() : Boolean
      {
         return true;
      }
      
      protected function get timeObject() : Object
      {
         return null;
      }
      
      protected function onUpdateClock() : void
      {
         var _loc2_:Boolean = false;
         var _loc1_:Object = this.timeObject;
         if(_loc1_)
         {
            _loc2_ = _loc1_["total"] < URGENT_THRESHOLD_SECONDS;
            updateClockAsset(this.m_clip,_loc2_,_loc1_,this.m_hideSeconds,this.m_hideDays);
            Zlab.processManager.schedule(UPDATE_FREQUENCY,this,this.onUpdateClock);
         }
         if(this.onUpdate != null)
         {
            this.onUpdate();
         }
      }
   }
}

