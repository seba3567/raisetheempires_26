package displays.popups.survivalMode
{
   import core.ZGlobal;
   import core.managers.survivalModeManager.SurvivalModeManager;
   import core.ui.Tooltip;
   import core.ui.ZGameButton;
   import displays.popups.GallantPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class SurvivalModeSelect extends GallantPopup
   {
      
      private var m_helpButton:ZGameButton = null;
      
      private var m_callback:Function = null;
      
      private var m_resource:SWFResource = null;
      
      private var m_set1Button:ZGameButton = null;
      
      private var m_set2Button:ZGameButton = null;
      
      public function SurvivalModeSelect(param1:Function = null)
      {
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_SurvivalModeSelect.swf"));
         this.m_callback = param1;
      }
      
      private function get mc() : MovieClip
      {
         return m_window.clip_mc;
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         this.m_resource = param1;
         super.onLoadComplete(param1);
      }
      
      override protected function initializeScreen() : void
      {
         super.initializeScreen();
         this.contentWidth = this.mc.background_mc.width;
         this.contentHeight = this.mc.background_mc.height;
         ZGameUtils.hideIfExists(this.mc.background_mc);
         centerWithinStage(Zlab.mainStage);
         this.mc.exit_bt.addEventListener(MouseEvent.CLICK,this.exitButtonClicked,false,0,true);
         this.mc.btn_help.addEventListener(MouseEvent.CLICK,this.onHelpClicked,false,0,true);
         TextFieldUtil.processTextField(this.mc.title_tf,ZGameUtils.ZlocT("Dialogs","SurvivalModeSelectTitle"));
         TextFieldUtil.processTextField(this.mc.description_tf,ZGameUtils.ZlocT("Dialogs","SurvivalModeSelectMessage"));
         this.createSetButtons();
      }
      
      private function createSetButtons() : void
      {
         var _loc1_:String = SurvivalModeManager.instance.getSetInProgress();
         var _loc2_:String = ZGameUtils.ZlocT("Dialogs","SurvivalModeSelectButtonSet1");
         this.m_set1Button = new ZGameButton(this.mc.Card1,this.onSet1Clicked,1.1,true);
         this.m_set1Button.compactText(_loc2_,{
            "maxLines":1,
            "minScale":0.5,
            "onFail":"return"
         });
         this.m_set1Button.show();
         if(_loc1_ == null || _loc1_ == SurvivalModeManager.SET_NAME_1)
         {
            this.m_set1Button.enable();
            if(_loc1_ == null)
            {
               Tooltip.subscribe(this.mc.Card1,ZGameUtils.ZlocT("Dialogs","SurvivalModeSelectButtonSet1"));
            }
            else
            {
               Tooltip.subscribe(this.mc.Card1,ZGameUtils.ZlocT("Dialogs","SurvivalModeSelectContinueTooltip"));
            }
         }
         else
         {
            this.m_set1Button.disable_visual();
            Tooltip.subscribe(this.mc.Card1,ZGameUtils.ZlocT("Dialogs","SurvivalModeSelectInProgressTooltip"));
         }
         var _loc3_:String = ZGameUtils.ZlocT("Dialogs","SurvivalModeSelectButtonSet2");
         this.m_set2Button = new ZGameButton(this.mc.Card2,this.onSet2Clicked,1.1,true);
         this.m_set2Button.compactText(_loc3_,{
            "maxLines":1,
            "minScale":0.5,
            "onFail":"return"
         });
         this.m_set2Button.show();
         this.m_set2Button.enable();
         if(_loc1_ == null || _loc1_ == SurvivalModeManager.SET_NAME_2)
         {
            this.m_set2Button.enable();
            if(_loc1_ == null)
            {
               Tooltip.subscribe(this.mc.Card2,ZGameUtils.ZlocT("Dialogs","SurvivalModeSelectButtonSet2"));
            }
            else
            {
               Tooltip.subscribe(this.mc.Card2,ZGameUtils.ZlocT("Dialogs","SurvivalModeSelectContinueTooltip"));
            }
         }
         else
         {
            this.m_set2Button.disable_visual();
            Tooltip.subscribe(this.mc.Card2,ZGameUtils.ZlocT("Dialogs","SurvivalModeSelectInProgressTooltip"));
         }
      }
      
      private function onSet1Clicked(param1:MouseEvent) : void
      {
         if(this.m_callback != null)
         {
            this.m_callback(SurvivalModeManager.SET_NAME_1);
         }
         close();
      }
      
      private function onSet2Clicked(param1:MouseEvent) : void
      {
         if(this.m_callback != null)
         {
            this.m_callback(SurvivalModeManager.SET_NAME_2);
         }
         close();
      }
      
      private function exitButtonClicked(param1:MouseEvent) : void
      {
         close();
      }
      
      private function onHelpClicked(param1:MouseEvent) : void
      {
         PopupManager.instance.push(new SurvivalModeIntroPopup(),0,false);
      }
      
      override protected function deinitDialog() : void
      {
         this.mc.exit_bt.removeEventListener(MouseEvent.CLICK,this.exitButtonClicked);
         this.mc.btn_help.removeEventListener(MouseEvent.CLICK,this.onHelpClicked);
         if(this.m_set1Button)
         {
            this.m_set1Button.dispose();
            this.m_set1Button = null;
         }
         if(this.m_set2Button)
         {
            this.m_set2Button.dispose();
            this.m_set2Button = null;
         }
         Tooltip.unsubscribe(this.mc.Card1);
         Tooltip.unsubscribe(this.mc.Card2);
         super.deinitDialog();
      }
   }
}

