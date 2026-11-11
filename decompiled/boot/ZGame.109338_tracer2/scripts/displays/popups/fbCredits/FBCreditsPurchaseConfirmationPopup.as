package displays.popups.fbCredits
{
   import ZLocalization.LocalizationObjectToken;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GallantPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   
   public class FBCreditsPurchaseConfirmationPopup extends GallantPopup
   {
      
      private var m_unitCode:String = null;
      
      private var m_goButton:ZGameButton = null;
      
      private var m_loaders:Array = null;
      
      public function FBCreditsPurchaseConfirmationPopup(param1:String)
      {
         this.m_unitCode = param1;
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_FacebookDiscount_Confirm.swf"));
      }
      
      override protected function initializeScreen() : void
      {
         var _loc2_:Object = null;
         var _loc3_:LocalizationObjectToken = null;
         super.initializeScreen();
         contentWidth = this.mc.panel_mc.width;
         contentHeight = this.mc.panel_mc.height;
         centerWithinStage(Zlab.mainStage);
         this.m_loaders = new Array();
         this.mc.exit_bt.addEventListener(MouseEvent.CLICK,this.exitButtonClicked,false,0,true);
         this.m_goButton = new ZGameButton(this.mc.accept_bt,this.onGoButton);
         this.m_goButton.text = ZGameUtils.ZlocT("Dialogs","Okay");
         TextFieldUtil.compactTextField(this.mc.title_tf,ZGameUtils.ZlocT("Dialogs","FBCreditsDiscountConfirmTitle"));
         var _loc1_:UnitItem = ZGlobal.gameSettings.getItemByCode(this.m_unitCode,UnitItem) as UnitItem;
         if(_loc1_)
         {
            _loc2_ = {"amount":40};
            _loc3_ = _loc1_.getSentenceNameLocalizationObject("singular,indefinite");
            _loc2_.unit = _loc3_ ? _loc3_ : _loc1_.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
            TextFieldUtil.compactTextField(this.mc.popupBox_tf,ZGameUtils.ZlocT("Dialogs","FBCreditsDiscountConfirmBody",_loc2_));
            this.m_loaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(_loc1_.name,"icon"),this.mc.unit_icon));
         }
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:ImageLoader = null;
         if(this.m_goButton)
         {
            this.m_goButton.dispose();
         }
         for each(_loc1_ in this.m_loaders)
         {
            if(_loc1_)
            {
               _loc1_.destroy();
            }
         }
         this.m_loaders = null;
         super.deinitDialog();
      }
      
      private function get mc() : MovieClip
      {
         return m_window.screen_mc;
      }
      
      private function onGoButton(param1:MouseEvent) : void
      {
         close();
      }
      
      private function exitButtonClicked(param1:MouseEvent) : void
      {
         close();
      }
   }
}

