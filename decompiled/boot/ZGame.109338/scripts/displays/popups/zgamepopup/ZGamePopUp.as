package displays.popups.zgamepopup
{
   import events.CloseEvent;
   import flash.events.Event;
   import sound.SoundEvent;
   import zlabs.displays.popups.SWFPopUp;
   
   public class ZGamePopUp extends SWFPopUp
   {
      
      public static const OPENED:String = "opened";
      
      public static const CLOSED:String = "closed";
      
      public function ZGamePopUp(param1:String)
      {
         super(param1);
      }
      
      override protected function initDialog() : void
      {
         super.initDialog();
         SoundEvent.getSoundEvent("windowOpen").play();
         dispatchEvent(new Event(OPENED));
      }
      
      override protected function deinitDialog() : void
      {
         super.deinitDialog();
         SoundEvent.getSoundEvent("windowClose").play();
         dispatchEvent(new Event(CLOSED));
      }
      
      override protected function close(param1:Event = null) : void
      {
         this.deinitDialog();
         this.dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
         super.close(param1);
      }
      
      public function forceClose() : void
      {
         this.close();
      }
   }
}

