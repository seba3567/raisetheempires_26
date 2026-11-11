package displays.popups
{
   import core.ZGlobal;
   import flash.events.Event;
   import utils.ZGameUtils;
   
   public class NameTitanPopup extends NamePopup
   {
      
      public function NameTitanPopup(param1:String, param2:Function = null)
      {
         super(param1,param2);
      }
      
      override public function get assetURL() : String
      {
         return ZGlobal.getAssetURL("assets/displays/dialogs/MechLabName.swf");
      }
      
      override protected function get greeting() : String
      {
         return ZGameUtils.ZlocT("Dialogs","NameTitanGreeting");
      }
      
      override protected function get title() : String
      {
         return ZGameUtils.ZlocT("Dialogs","NameTitanTitle");
      }
      
      override protected function get detail() : String
      {
         return ZGameUtils.ZlocT("Dialogs","NameTitanDetail",{"num":maxChars});
      }
      
      override protected function close(param1:Event = null) : void
      {
         super.close(param1);
      }
   }
}

