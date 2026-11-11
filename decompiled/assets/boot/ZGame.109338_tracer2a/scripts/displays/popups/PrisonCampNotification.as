package displays.popups
{
   import core.ZGlobal;
   import core.managers.ChallengeModeManager;
   import core.managers.PVPManager;
   import core.player.IPVPPlayer;
   import core.player.Player;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class PrisonCampNotification extends ZGamePopUp
   {
      
      public static const TYPE_ESCAPED:String = "ESCAPED";
      
      public static const TYPE_CAPTURED:String = "CAPTURED";
      
      protected var m_type:String = null;
      
      protected var m_message:String = null;
      
      protected var m_title:String = null;
      
      protected var m_cardInfo:Array = new Array();
      
      protected var m_cards:Array = new Array();
      
      protected var m_closeCallback:Function;
      
      protected var m_buttonSounds:ButtonMouseEventSoundContainer = new ButtonMouseEventSoundContainer();
      
      protected var m_loaders:Array = new Array();
      
      private var m_shiftBy:Number;
      
      public function PrisonCampNotification(param1:String, param2:Array, param3:Function = null, param4:String = "assets/displays/screens/PrisonCamp_CaptureNotice.swf")
      {
         super(ZGlobal.getAssetURL(param4));
         this.m_type = param1;
         if(param3 != null)
         {
            this.m_closeCallback = param3;
            addEventListener(CLOSED,param3,false,0,true);
         }
         this.m_cardInfo = param2;
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         if(Boolean(param1) && !m_window)
         {
            m_window = param1.clip as MovieClip;
         }
         param1.destroy();
         this.m_cards.push(m_window.screen_mc.card_0);
         this.m_cards.push(m_window.screen_mc.card_1);
         this.m_cards.push(m_window.screen_mc.card_2);
         this.m_cards.push(m_window.screen_mc.card_3);
         this.m_cards.push(m_window.screen_mc.card_4);
         PopupManager.instance.notifyLoadComplete(this);
         dispatchEvent(new Event(Event.COMPLETE));
         this.setUpMessaging();
         this.setUpExitButton();
         this.setUpCards();
         initDialog();
         this.contentWidth = m_window.width;
         this.contentHeight = m_window.height;
         centerWithinStage(Zlab.mainStage);
         addChild(m_window);
      }
      
      override public function onShow() : void
      {
         super.onShow();
      }
      
      protected function setUpMessaging() : void
      {
         switch(this.m_type)
         {
            case TYPE_CAPTURED:
               TextFieldUtil.compactTextField(m_window.screen_mc.title_tf,ZGameUtils.ZlocT("Dialogs","Prison_Camp_Victim_Title"));
               TextFieldUtil.compactTextField(m_window.screen_mc.body_tf,ZGameUtils.ZlocT("Dialogs","Prison_Camp_Victim_Body_1"));
               TextFieldUtil.compactTextField(m_window.screen_mc.explain_tf,ZGameUtils.ZlocT("Dialogs","Prison_Camp_Victim_Body_2"));
               m_window.screen_mc.explain_tf.visible = true;
               break;
            case TYPE_ESCAPED:
               TextFieldUtil.compactTextField(m_window.screen_mc.title_tf,ZGameUtils.ZlocT("Dialogs","Prison_Camp_Escaped_Title"));
               TextFieldUtil.compactTextField(m_window.screen_mc.body_tf,ZGameUtils.ZlocT("Dialogs","Prison_Camp_Escaped_Body"));
               m_window.screen_mc.explain_tf.visible = false;
         }
      }
      
      protected function setUpExitButton() : void
      {
         m_window.screen_mc.exit_bt.addEventListener(MouseEvent.CLICK,this.onExit,false,0,true);
         this.m_buttonSounds.addButton(m_window.screen_mc.exit_bt,ButtonSound.DEFAULT);
      }
      
      protected function setUpCards() : void
      {
         var _loc1_:Number = (this.m_cards[0] as MovieClip).width;
         var _loc2_:Number = (this.m_cards[this.m_cards.length - 1].x - this.m_cards[0].x - (this.m_cards.length - 1) * _loc1_) / this.m_cards.length;
         this.m_shiftBy = (this.m_cards.length - this.m_cardInfo.length) * (_loc1_ + _loc2_) / 2;
         var _loc3_:int = 0;
         _loc3_ = 0;
         while(_loc3_ < this.m_cards.length && _loc3_ < this.m_cardInfo.length)
         {
            this.m_cards[_loc3_].visible = true;
            TextFieldUtil.compactTextField(this.m_cards[_loc3_].name_tf,this.m_cardInfo[_loc3_].name);
            this.m_loaders.push(ImageLoaderFactory.CreateImageLoader(this.m_cardInfo[_loc3_].icon,this.m_cards[_loc3_].player_mc.icon));
            switch(this.m_type)
            {
               case TYPE_CAPTURED:
                  TextFieldUtil.compactTextField(this.m_cards[_loc3_].green_bt.generic_tf,ZGameUtils.ZlocT("Dialogs","Prison_Camp_ButtonText"));
                  this.m_cards[_loc3_].rescueButton = new ZGameButton(this.m_cards[_loc3_].green_bt,this.onRescueClicked);
                  this.m_cards[_loc3_].invaderID = this.m_cardInfo[_loc3_].uid;
                  break;
               case TYPE_ESCAPED:
                  this.m_cards[_loc3_].green_bt.visible = false;
            }
            this.m_cards[_loc3_].x += this.m_shiftBy;
            _loc3_++;
         }
         while(_loc3_ < this.m_cards.length)
         {
            this.m_cards[_loc3_].visible = false;
            _loc3_++;
         }
      }
      
      protected function onRescueClicked(param1:MouseEvent) : void
      {
         var _loc3_:PVPCombatStartPopup = null;
         var _loc4_:IPVPPlayer = null;
         var _loc2_:String = param1.target.parent.invaderID;
         if(_loc2_)
         {
            _loc4_ = PVPManager.instance.getPVPPlayer(_loc2_);
            if(_loc4_ as Player)
            {
               if(ChallengeModeManager.instance.onSelectChallengerPlayer(_loc2_))
               {
                  _loc3_ = new PVPCombatStartPopup(ZGlobal.player,_loc4_);
                  close();
                  if(this.m_closeCallback != null)
                  {
                     removeEventListener(CLOSED,this.m_closeCallback);
                  }
                  PVPManager.instance.setAndShowCombatPopup(_loc3_);
               }
            }
         }
         param1.stopPropagation();
         param1.stopImmediatePropagation();
      }
      
      public function closeWindow() : void
      {
         close();
      }
      
      protected function deinitButtons() : void
      {
         m_window.screen_mc.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExit);
      }
      
      protected function onExit(param1:MouseEvent) : void
      {
         close();
         if(this.m_closeCallback != null)
         {
            removeEventListener(CLOSED,this.m_closeCallback);
         }
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:ImageLoader = null;
         var _loc2_:MovieClip = null;
         var _loc3_:int = 0;
         super.deinitDialog();
         if(m_window)
         {
            this.deinitButtons();
         }
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         for each(_loc1_ in this.m_loaders)
         {
            _loc1_.destroy();
         }
         _loc2_ = null;
         _loc3_ = 0;
         while(_loc3_ < this.m_cardInfo.length)
         {
            _loc2_ = this.m_cards[_loc3_];
            if(_loc2_.rescueButton)
            {
               (_loc2_.rescueButton as ZGameButton).dispose();
            }
            _loc2_.x -= this.m_shiftBy;
            _loc3_++;
         }
         destroy();
      }
   }
}

