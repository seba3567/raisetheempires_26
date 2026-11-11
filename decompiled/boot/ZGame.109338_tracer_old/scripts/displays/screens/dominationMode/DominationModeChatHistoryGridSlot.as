package displays.screens.dominationMode
{
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import utils.TextFieldUtil;
   import zlabs.resource.SWFResource;
   
   public class DominationModeChatHistoryGridSlot extends GridSlot
   {
      
      private var m_data:Object = null;
      
      private var m_index:int = 0;
      
      public function DominationModeChatHistoryGridSlot(param1:SWFResource, param2:MovieClip, param3:int, param4:int, param5:Object, param6:int)
      {
         this.m_data = param5;
         this.m_index = param6;
         super(param1,param2,null);
         slot.x = param3 * sizerWidth;
         slot.y = param4 * sizerHeight;
      }
      
      override protected function get className() : String
      {
         return Boolean(this.m_data) && Boolean(this.m_data.player) ? "Slot_mc" : "MessageSlot2";
      }
      
      override protected function createSlot(param1:SWFResource) : MovieClip
      {
         var _loc2_:Class = param1.getAssetClass(this.className);
         return new _loc2_();
      }
      
      override protected function onSlotCreated() : void
      {
         TextFieldUtil.processTextField(slot.message_tf,this.m_data.msg);
         var _loc1_:Date = new Date(this.m_data.ts * 1000);
         var _loc2_:Number = _loc1_.getDate();
         var _loc3_:Number = _loc1_.getMonth() + 1;
         var _loc4_:Number = _loc1_.getFullYear();
         var _loc5_:Number = _loc1_.getHours();
         var _loc6_:Number = _loc1_.getMinutes();
         var _loc7_:Number = _loc1_.getSeconds();
         var _loc8_:String = _loc3_ + "/" + _loc2_ + "/" + _loc4_ + " " + _loc5_ + ":" + _loc6_ + ":" + _loc7_;
         TextFieldUtil.processTextField(slot.date_tf,_loc8_);
         TextFieldUtil.processTextField(slot.players_tf,this.m_data.name);
      }
   }
}

