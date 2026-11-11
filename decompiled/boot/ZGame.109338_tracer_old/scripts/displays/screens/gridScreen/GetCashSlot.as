package displays.screens.gridScreen
{
   import core.ZGlobal;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import utils.ZGameUtils;
   import zlabs.resource.SWFResource;
   
   public class GetCashSlot extends GridSlot
   {
      
      public static const CLICKED:String = "clicked";
      
      public function GetCashSlot(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:int, param5:int, param6:Number)
      {
         super(param1,param2,param3);
         slot.x = param4 * (slot.width * param6);
         slot.y = param5 * (slot.height * param6);
         this.filloutStats();
      }
      
      override protected function get className() : String
      {
         return "GetCashCard";
      }
      
      override protected function doOnClick(param1:MouseEvent) : void
      {
         ZGlobal.switchToTab("money");
      }
      
      private function filloutStats() : void
      {
         slot.getCashCard_mc.getCash_tf.text = ZGameUtils.ZlocT("Dialogs","GetCashButton");
      }
      
      override public function isSpecialSlot() : Boolean
      {
         return true;
      }
   }
}

