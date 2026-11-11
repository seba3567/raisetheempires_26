package displays.screens.commando
{
   import core.ZGlobal;
   import core.entities.components.behaviors.states.CommandoKillActivateDialogState;
   import core.ui.UIManager;
   import core.ui.ZGameButton;
   import core.ui.menuitem.PlayerStatsUIItem;
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
   
   public class CommandoDialog extends ZGamePopUp
   {
      
      protected var m_okButton:ZGameButton;
      
      protected var m_state:CommandoKillActivateDialogState;
      
      public function CommandoDialog(param1:CommandoKillActivateDialogState)
      {
         super(ZGlobal.getAssetURL("assets/displays/dialogs/Commando_Congratulation.swf"));
         this.m_state = param1;
      }
      
      public static function display(param1:CommandoKillActivateDialogState) : PopUpBase
      {
         var _loc2_:PopUpBase = new CommandoDialog(param1);
         WindowManager.instance.push(_loc2_);
         return _loc2_;
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
         var _loc1_:String = ZGameUtils.ZlocT("Dialogs","Commando_Assault_Yard_Title");
         TextFieldUtil.compactTextField(m_window.title_tf,_loc1_);
         var _loc2_:String = ZGameUtils.ZlocT("Dialogs","Commando_Assault_Yard_quest_1_Congratulations");
         TextFieldUtil.compactTextField(m_window.description_tf,_loc2_);
         var _loc3_:String = "15";
         var _loc4_:Object = {"total":_loc3_};
         var _loc5_:String = ZGameUtils.ZlocT("Dialogs","Commando_Assault_Yard_quest_1_Completion_Diag_1",_loc4_);
         TextFieldUtil.compactTextField(m_window.body_tf,_loc5_);
         var _loc6_:String = ZGameUtils.ZlocT("Dialogs","Commando_Assault_Yard_quest_1_Completion_Diag_2",_loc4_);
         TextFieldUtil.compactTextField(m_window.emptyprompt_tf,_loc6_);
      }
      
      protected function setupIcons() : void
      {
         m_window.green_bt.visible = false;
         this.m_okButton = null;
         m_window.green_bt.visible = true;
         this.m_okButton = new ZGameButton(m_window.green_bt,this.onActivated);
         this.m_okButton.text = ZGameUtils.ZlocT("Dialogs","Commando_Assault_Yard_quest_1_Completion_Diag_Button");
      }
      
      protected function onExitClicked(param1:MouseEvent) : void
      {
         this.close();
      }
      
      protected function onActivated(param1:MouseEvent) : void
      {
         this.close();
         if(this.m_state)
         {
            this.m_state.done();
         }
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

