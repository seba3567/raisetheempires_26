package displays.popups
{
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.gamemode.GMObjectPlace;
   import core.gamemode.GameModeManager;
   import core.gameobjects.GameItem;
   import core.managers.tutorialManager.TutorialHighlighter;
   import core.managers.tutorialManager.TutorialManager;
   import core.ui.UIManager;
   import core.ui.ZGameButton;
   import core.ui.menuitem.QuestsUIItem;
   import displays.ImageLoaderFactory;
   import displays.screens.WonderHeraquaters;
   import events.MarketEvent;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.displays.popups.SWFPopUp;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class SpeechPopup extends SWFPopUp
   {
      
      public static const EXIT_TEXT_CONTINUE:String = "exitTextContinue";
      
      public static const EXIT_TEXT_OK:String = "exitTextOk";
      
      public static var PLACE_OBJECT:String = "PLACE_OBJECT";
      
      public static var SHOW_WONDERS_DIALOG:String = "SHOW_WONDERS_DIALOG";
      
      public static var SHOW_SPEECH:String = "SHOW_SPEECH";
      
      public static const SHOW_QUEST_TASK_ARROW:String = "SHOW_QUEST_TASK_ARROW";
      
      public static var SHOW_TUTORIAL_UI_ITEM:String = "SHOW_TUTORIAL_ITEM_UI";
      
      private var m_data:XML = null;
      
      private var m_closeCallback:Function = null;
      
      private var m_acceptBt:ZGameButton = null;
      
      private var m_initialized:Boolean = false;
      
      private var m_speechId:String = null;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private var m_exitText:String = null;
      
      private var m_tutorial:TutorialHighlighter;
      
      public function SpeechPopup(param1:String, param2:Function = null, param3:String = "exitTextContinue")
      {
         var _loc4_:String = null;
         this.m_data = ZGlobal.gameSettings.getSpeech(param1);
         if(this.m_data.@asset.toString().length > 0)
         {
            _loc4_ = this.m_data.@asset.toString();
         }
         else
         {
            _loc4_ = "assets/displays/dialogs/PU_Speech.swf";
         }
         super(ZGlobal.getAssetURL(_loc4_));
         this.m_speechId = param1;
         if(param2 != null)
         {
            this.m_closeCallback = param2;
            addEventListener(GenericPopupEvent.SELECTED,param2,false,0,true);
         }
         this.m_exitText = param3;
      }
      
      public function get buttonBehavior() : String
      {
         return this.m_data.attribute("acceptButtonBehavior");
      }
      
      public function get buttonBehaviorData() : String
      {
         return this.m_data.attribute("acceptButtonBehaviorData");
      }
      
      public function hasButtonBehavior() : Boolean
      {
         if(this.m_data)
         {
            return true;
         }
         return false;
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         PopupManager.instance.notifyLoadComplete(this);
      }
      
      override public function onShow() : void
      {
         super.onShow();
         this.setupScreen();
      }
      
      private function setupScreen() : void
      {
         var _loc1_:GameItem = null;
         if(!m_window || this.m_initialized)
         {
            return;
         }
         this.m_initialized = true;
         if(this.m_data)
         {
            if(this.m_data.@villain.toString().length > 0 && this.m_data.@villain != "a01")
            {
               m_window.window_mc.villain_mc.villainloader_mc.scaleContent = false;
               _loc1_ = ZGlobal.gameSettings.getItemByCode(this.m_data.@villain.toString(),GameItem) as GameItem;
               ImageLoaderFactory.CreateImageLoader(_loc1_.getCachedImage("speech").url,m_window.window_mc.villain_mc.villainloader_mc);
               m_window.window_mc.scarlett_mc.visible = false;
               m_window.window_mc.porthole_mc.visible = false;
               m_window.window_mc.villain_mc.visible = true;
            }
            else
            {
               m_window.window_mc.villain_mc.visible = false;
               m_window.window_mc.scarlett_mc.visible = true;
               m_window.window_mc.porthole_mc.visible = true;
               contentHeight = m_window.window_mc.scarlett_mc.y - m_window.window_mc.speechBubble_mc.y + m_window.window_mc.scarlett_mc.height;
            }
            TextFieldUtil.compactTextField(m_window.window_mc.generic_tf,ZGameUtils.ZlocTP("Speeches",this.m_data.@body.toString(),ZGameUtils.buildLocalizedParams()),{"maxLines":10});
            m_window.window_mc.generic_tf.y = m_window.window_mc.center_mc.y - m_window.window_mc.generic_tf.textHeight * 0.5;
         }
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_acceptBt = new ZGameButton(m_window.window_mc.exit_bt,this.onAccept);
         switch(this.m_exitText)
         {
            case SpeechPopup.EXIT_TEXT_OK:
               this.m_acceptBt.text = ZGameUtils.ZlocT("Dialogs","OkButton");
               break;
            case SpeechPopup.EXIT_TEXT_CONTINUE:
               this.m_acceptBt.text = ZGameUtils.ZlocT("Dialogs","Continue");
               break;
            default:
               this.m_acceptBt.text = ZGameUtils.ZlocT("Dialogs","Continue");
         }
         this.m_buttonSounds.addButton(this.m_acceptBt.m_overlay,ButtonSound.DEFAULT);
         initDialog();
         m_window.alpha = 0;
         addChild(m_window);
         TweenLite.to(m_window,0.25,{"alpha":1});
      }
      
      private function showQuestTaskArrow(param1:String) : void
      {
         var _loc2_:QuestsUIItem = UIManager.instance.getMenuItemByName("questsUIItem") as QuestsUIItem;
         _loc2_.showTaskArrowOnQuest(param1);
      }
      
      private function onAccept(param1:MouseEvent) : void
      {
         var _loc2_:WonderHeraquaters = null;
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,GenericPopup.ACCEPT));
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.SPEECH_CONTINUE));
         param1.stopPropagation();
         this.close();
         if(this.hasButtonBehavior())
         {
            switch(this.buttonBehavior)
            {
               case PLACE_OBJECT:
                  this.placeObject();
                  break;
               case SHOW_WONDERS_DIALOG:
                  _loc2_ = new WonderHeraquaters();
                  PopupManager.instance.push(_loc2_);
                  break;
               case SHOW_SPEECH:
                  PopupManager.instance.push(new SpeechPopup(this.buttonBehaviorData),0,true,false);
                  break;
               case SHOW_QUEST_TASK_ARROW:
                  this.showQuestTaskArrow(this.buttonBehaviorData);
                  break;
               case SHOW_TUTORIAL_UI_ITEM:
                  this.showTutorialUIItem();
            }
         }
      }
      
      private function showTutorialUIItem() : void
      {
         var _loc1_:DisplayObject = TutorialManager.instance.getUIItem(this.buttonBehaviorData);
         if(_loc1_)
         {
            this.m_tutorial = new TutorialHighlighter();
            this.m_tutorial.setDisplayObject(_loc1_,true,-90,true);
            Zlab.processManager.schedule(8000,this,this.onTutorialUIItemDone);
         }
      }
      
      private function onTutorialUIItemDone() : void
      {
         if(this.m_tutorial)
         {
            this.m_tutorial.dispose();
            this.m_tutorial = null;
         }
      }
      
      private function placeObject() : void
      {
         var _loc1_:GameItem = null;
         var _loc2_:int = 0;
         if(ZGlobal.isHome())
         {
            _loc1_ = ZGlobal.gameSettings.getItemByCode(this.buttonBehaviorData,GameItem) as GameItem;
            if(_loc1_)
            {
               _loc2_ = ZGlobal.player.getNumberOfInventoryItems(this.buttonBehaviorData);
               if(_loc2_ > 0)
               {
                  GameModeManager.instance.addGameMode(new GMObjectPlace(_loc1_.name,MarketEvent.SOURCE_INVENTORY,true));
               }
            }
         }
      }
      
      override protected function close(param1:Event = null) : void
      {
         super.close(param1);
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         if(this.m_closeCallback != null)
         {
            removeEventListener(GenericPopupEvent.SELECTED,this.m_closeCallback);
         }
         ZGlobal.player.setSeenSpeech(this.m_speechId);
         this.m_acceptBt.dispose();
      }
   }
}

