package displays.popups
{
   import core.ZGlobal;
   import core.ui.ZGameButton;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class WorldGamesRewardPopUp extends ZGamePopUp
   {
      
      public static const GOLD_BULL_TANK:String = "UN13";
      
      public static const GOLD_VARUN_SUB:String = "UT94";
      
      public static const GOLD_HORTEN_BOMBER:String = "UB90";
      
      protected var m_itemCode:String;
      
      private var m_initialised:Boolean = false;
      
      protected var gbt_btn:ZGameButton;
      
      protected var ghb_btn:ZGameButton;
      
      protected var gvs_btn:ZGameButton;
      
      public function WorldGamesRewardPopUp(param1:String)
      {
         this.m_itemCode = param1;
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_WorldGamesPopup.swf"));
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         PopupManager.instance.notifyLoadComplete(this);
      }
      
      override public function onShow() : void
      {
         super.onShow();
         this.setupWindow();
      }
      
      private function setupWindow() : void
      {
         if(Boolean(m_window) && !this.m_initialised)
         {
            this.m_initialised = true;
            this.initDialog();
            addChild(m_window);
         }
      }
      
      override protected function initDialog() : void
      {
         m_window.screen_mc.exit_bt.addEventListener(MouseEvent.CLICK,this.onExit);
         TextFieldUtil.compactTextField(m_window.screen_mc.title_tf,ZGameUtils.ZlocT("Dialogs","WGM_Exchange_Title"));
         switch(this.m_itemCode)
         {
            case GOLD_BULL_TANK:
               TextFieldUtil.compactTextField(m_window.screen_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","WGM_Exchange_GBT"));
               TextFieldUtil.compactTextField(m_window.screen_mc.unitName_tf,ZGameUtils.ZlocT("Items","Gold_Bull_Tank_menuName"));
               ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURLChecked("assets/game/units/Units_Land_Icons.swf/Unit_Land_SF_BullTank_Gold_SW_icon.png"),m_window.screen_mc.icon);
               break;
            case GOLD_VARUN_SUB:
               TextFieldUtil.compactTextField(m_window.screen_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","WGM_Exchange_GVS"));
               TextFieldUtil.compactTextField(m_window.screen_mc.unitName_tf,ZGameUtils.ZlocT("Items","Golden_Varun_Submarine_menuName"));
               ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURLChecked("assets/game/units/Units_Sea_Icons.swf/Unit_Sea_SF_VarunUUV2_Sub_01_Gold_SW_icon.png"),m_window.screen_mc.icon);
               break;
            case GOLD_HORTEN_BOMBER:
               TextFieldUtil.compactTextField(m_window.screen_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","WGM_Exchange_GHB"));
               TextFieldUtil.compactTextField(m_window.screen_mc.unitName_tf,ZGameUtils.ZlocT("Items","Golden_Horten_Bomber_menuName"));
               ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURLChecked("assets/game/units/Units_Air_Icons.swf/Unit_Air_HortenBomber_Gold_SW_icon.png"),m_window.screen_mc.icon);
         }
         m_window.screen_mc.share_bt.visible = false;
         centerWithinStage(Zlab.mainStage);
      }
      
      private function onghbClicked(param1:MouseEvent) : void
      {
      }
      
      private function ongvsClicked(param1:MouseEvent) : void
      {
      }
      
      private function ongbtClicked(param1:MouseEvent) : void
      {
      }
      
      private function onExit(param1:MouseEvent) : void
      {
         close();
      }
   }
}

