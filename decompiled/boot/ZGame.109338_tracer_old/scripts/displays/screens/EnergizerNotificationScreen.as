package displays.screens
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.ui.UIManager;
   import core.ui.ZGameButton;
   import core.ui.menuitem.PlayerStatsUIItem;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.displays.popups.PopUpBase;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class EnergizerNotificationScreen extends ZGamePopUp
   {
      
      protected var m_okButton:ZGameButton;
      
      public function EnergizerNotificationScreen()
      {
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_Energon_Congrats.swf"));
      }
      
      public static function display() : PopUpBase
      {
         var _loc1_:PopUpBase = new EnergizerNotificationScreen();
         WindowManager.instance.push(_loc1_);
         return _loc1_;
      }
      
      override protected function getWindowInstance(param1:SWFResource) : MovieClip
      {
         return param1.clip.screen_mc;
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         m_window.exit_bt.addEventListener(MouseEvent.CLICK,this.onExitClicked,false,0,true);
         initDialog();
         this.setupText();
         this.setupIcons();
         addChild(m_window);
         centerWithinStage(Zlab.mainStage);
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).toggleRarePanel(true);
         dispatchEvent(new Event(Event.COMPLETE));
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).moveToNewLayer(WindowManager.instance.container,0);
      }
      
      protected function setupText() : void
      {
         var _loc1_:String = ZGameUtils.ZlocT("Dialogs","Energiser_Dialog_01_Title");
         TextFieldUtil.compactTextField(m_window.title_tf,_loc1_);
         var _loc2_:String = ZGameUtils.ZlocT("Dialogs","Energiser_Dialog_01_Desc_01");
         TextFieldUtil.compactTextField(m_window.description_tf_0,_loc2_);
         var _loc3_:String = ZGameUtils.ZlocT("Dialogs","Energiser_Dialog_01_Desc_02");
         TextFieldUtil.compactTextField(m_window.description_tf_1,_loc3_);
      }
      
      protected function setupIcons() : void
      {
         var _loc1_:GameItem = ZGlobal.gameSettings.getItemByCode("EZ01",GameItem) as GameItem;
         var _loc2_:String = ZGlobal.gameSettings.getImageByName(_loc1_.name,"screenicon");
         ImageLoaderFactory.CreateImageLoader(_loc2_,m_window.icon);
         m_window.ok_bt.visible = false;
         this.m_okButton = null;
         m_window.ok_bt.visible = true;
         this.m_okButton = new ZGameButton(m_window.ok_bt,this.onExitClicked);
         this.m_okButton.text = ZGameUtils.ZlocT("Dialogs","Okay");
      }
      
      protected function onExitClicked(param1:MouseEvent) : void
      {
         this.close();
      }
      
      override protected function close(param1:Event = null) : void
      {
         m_window.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExitClicked);
         if(this.m_okButton)
         {
            this.m_okButton.dispose();
         }
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).toggleRarePanel(false);
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).moveToNewLayer(UIManager.instance.uiDisplay,0);
         super.close();
      }
   }
}

