package displays.popups
{
   import displays.popups.zgamepopup.ZGamePopUp;
   import zlabs.resource.SWFResource;
   
   public class GallantPopup extends ZGamePopUp
   {
      
      protected var m_initialized:Boolean = false;
      
      public function GallantPopup(param1:String)
      {
         super(param1);
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         if(m_managerToNotifyOnLoad)
         {
            m_managerToNotifyOnLoad.notifyLoadComplete(this);
         }
      }
      
      protected function setUpScreen() : void
      {
         if(!m_window || this.m_initialized)
         {
            return;
         }
         this.initializeScreen();
      }
      
      protected function initializeScreen() : void
      {
         addChild(m_window);
         initDialog();
         this.m_initialized = true;
      }
      
      override protected function deinitDialog() : void
      {
         if(Boolean(m_window) && this.contains(m_window))
         {
            removeChild(m_window);
         }
         super.deinitDialog();
      }
      
      override public function onShow() : void
      {
         this.setUpScreen();
         super.onShow();
      }
   }
}

