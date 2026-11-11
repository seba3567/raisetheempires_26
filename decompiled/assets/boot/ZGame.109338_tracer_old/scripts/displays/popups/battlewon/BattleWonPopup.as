package displays.popups.battlewon
{
   import core.ui.ZGameButton;
   import displays.popups.battlebase.BattleBasePopup;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.events.GenericPopupEvent;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class BattleWonPopup extends BattleBasePopup
   {
      
      private var m_closeCallback:Function = null;
      
      private var m_textObj:Object = null;
      
      private var m_mainButton:ZGameButton = null;
      
      private var m_initialised:Boolean = false;
      
      protected var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      public function BattleWonPopup(param1:Array, param2:Dictionary, param3:Function = null, param4:Boolean = false)
      {
         this.m_closeCallback = param3;
         super(param1,param2,param4);
      }
      
      override protected function assetStr() : String
      {
         if(allowUnitBuyBack())
         {
            return "assets/displays/dialogs/PU_Victory2.swf";
         }
         return "assets/displays/dialogs/PU_Victory.swf";
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         PopupManager.instance.notifyLoadComplete(this);
      }
      
      override public function onShow() : void
      {
         super.onShow();
         this.setUpScreen();
      }
      
      protected function setUpScreen() : void
      {
         if(Boolean(m_window) && !this.m_initialised)
         {
            this.m_initialised = true;
            addChild(m_window);
            this.contentWidth = this.windowWidth;
            this.contentHeight = this.windowHeight;
            centerWithinStage(Zlab.mainStage);
            this.setUpPopupUI();
         }
      }
      
      protected function get windowWidth() : Number
      {
         return this.screen.background_mc.width;
      }
      
      protected function get windowHeight() : Number
      {
         return this.screen.background_mc.height;
      }
      
      override protected function get screen() : MovieClip
      {
         return m_window.popupBox_mc;
      }
      
      protected function get bonusHeight() : int
      {
         if(allowUnitBuyBack())
         {
            return 0;
         }
         return 145;
      }
      
      protected function get textObj() : Object
      {
         return this.m_textObj;
      }
      
      protected function set textObj(param1:Object) : void
      {
         this.m_textObj = param1;
      }
      
      protected function get closeCallback() : Function
      {
         return this.m_closeCallback;
      }
      
      protected function get mainButton() : ZGameButton
      {
         return this.m_mainButton;
      }
      
      protected function set mainButton(param1:ZGameButton) : void
      {
         this.m_mainButton = param1;
      }
      
      private function get totalUnits() : int
      {
         return numRemainingUnits + numLostUnits;
      }
      
      protected function setUpPopupUI() : void
      {
         initDialog();
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         if(this.screen.orangeButton_01)
         {
            this.m_mainButton = new ZGameButton(this.screen.orangeButton_01,this.onButtonClicked,1.1,true);
            this.m_buttonSounds.addButton(this.m_mainButton.m_overlay,ButtonSound.DEFAULT);
         }
         if(m_window.popupBox_mc)
         {
            m_window.popupBox_mc.visible = false;
         }
         if(m_window.victory_solo)
         {
            m_window.victory_solo.visible = false;
         }
         if(m_window.victory_pvp)
         {
            m_window.victory_pvp.visible = false;
         }
         this.screen.visible = true;
         ZGameUtils.hideIfExists(this.screen.background_mc);
         TextFieldUtil.processTextField(this.screen.popupBox_tf,ZGameUtils.ZlocT("Dialogs","WinShareDesc"));
         if(this.screen.bonusInd)
         {
            this.screen.bonusInd.visible = false;
         }
         if(null != this.m_closeCallback)
         {
            addEventListener(GenericPopupEvent.SELECTED,this.m_closeCallback,false,0,true);
         }
         this.screen.exit_bt.addEventListener(MouseEvent.CLICK,onExit,false,0,true);
         this.m_buttonSounds.addButton(this.screen.exit_bt,ButtonSound.DEFAULT);
      }
      
      override protected function deinitDialog() : void
      {
         super.deinitDialog();
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         if(null != this.m_closeCallback)
         {
            removeEventListener(GenericPopupEvent.SELECTED,this.m_closeCallback);
            this.m_closeCallback = null;
         }
         this.screen.exit_bt.removeEventListener(MouseEvent.CLICK,onExit);
         if(this.m_mainButton)
         {
            this.m_mainButton.dispose();
            this.m_mainButton = null;
         }
      }
      
      override protected function close(param1:Event = null) : void
      {
         this.deinitDialog();
         super.close();
      }
      
      protected function onButtonClicked(param1:MouseEvent) : void
      {
         this.close();
      }
      
      override protected function get isVictory() : Boolean
      {
         return true;
      }
   }
}

