package zlabs.displays.popups
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.resource.SWFResource;
   
   public class SWFPopUp extends PopUpBase
   {
      
      public function SWFPopUp(param1:String)
      {
         super();
         if(Zlab.resourceManager.validUrl(param1))
         {
            Zlab.resourceManager.load(param1,SWFResource,this.onLoadComplete,this.onLoadFail);
         }
      }
      
      protected function getWindowInstance(param1:SWFResource) : MovieClip
      {
         return param1.clip;
      }
      
      protected function onLoadComplete(param1:SWFResource) : void
      {
         m_window = this.getWindowInstance(param1);
         param1.destroy();
         param1 = null;
         this.contentWidth = m_window.width;
         this.contentHeight = m_window.height;
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      protected function onLoadFail(param1:SWFResource) : void
      {
         Logger.print(this,"Failed to load image \'" + param1.filename + "\'");
      }
   }
}

