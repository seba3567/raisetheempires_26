package core.ui.components.PortraitSlidePick
{
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   
   public class PortraitPickDissolveHelper extends EventDispatcher
   {
      
      public static const DONE:String = "dissolveHelperDone";
      
      public static const HIDE:String = "dissolveHelperHide";
      
      protected var m_parent:MovieClip = null;
      
      public function PortraitPickDissolveHelper(param1:MovieClip)
      {
         super();
         this.m_parent = param1;
      }
      
      protected function onDispose() : void
      {
      }
      
      final public function dispose() : void
      {
         this.onDispose();
      }
   }
}

