package displays.popups.genericPopup
{
   import core.managers.AlliancesManager;
   import displays.ImageLoaderFactory;
   import displays.popups.GenericPopup;
   import utils.TextFieldUtil;
   import zlabs.resource.SWFResource;
   
   public class ModalPopup extends GenericPopup
   {
      
      private var m_popped:Boolean = false;
      
      private var m_loaded:Boolean = false;
      
      private var m_info:Object;
      
      public function ModalPopup(param1:String, param2:Function = null, param3:String = "assets/displays/dialogs/PU_ModalPopUp.swf", param4:Object = null)
      {
         this.m_info = param4;
         super(param1,GenericPopup.TYPE_MODAL,param2,null,param3);
      }
      
      public function pop() : void
      {
         this.m_popped = true;
         if(this.m_loaded)
         {
            close();
         }
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         this.m_loaded = true;
         if(this.m_popped)
         {
            close();
         }
         else
         {
            this.setupClanData();
         }
      }
      
      override protected function setUpLook() : void
      {
         m_window.popupBox_mc.popupBox_tf.visible = true;
      }
      
      override protected function setUpScreen() : void
      {
         super.setUpScreen();
         if(m_window != null)
         {
            m_window.popupBox_mc.popupBox_tf.y = m_window.popupBox_mc.anchor_mc.y - m_window.popupBox_mc.popupBox_tf.textHeight * 0.5;
         }
      }
      
      public function setupClanData() : void
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         if(!this.m_info)
         {
            return;
         }
         if(Boolean(m_window) && Boolean(m_window.popupBox_mc) && Boolean(m_window.popupBox_mc.title_tf))
         {
            _loc1_ = AlliancesManager.instance.getAllianceName(this.m_info);
            TextFieldUtil.compactTextField(m_window.popupBox_mc.title_tf,_loc1_);
         }
         if(Boolean(m_window) && Boolean(m_window.popupBox_mc) && Boolean(m_window.popupBox_mc.icon))
         {
            _loc2_ = AlliancesManager.instance.getCrestIcon(this.m_info.crestId);
            ImageLoaderFactory.CreateImageLoader(_loc2_,m_window.popupBox_mc.icon);
         }
      }
      
      override protected function initButtons() : void
      {
      }
      
      override protected function deinitButtons() : void
      {
      }
   }
}

