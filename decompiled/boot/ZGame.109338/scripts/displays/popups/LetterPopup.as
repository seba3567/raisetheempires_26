package displays.popups
{
   import com.greensock.TweenLite;
   import com.greensock.easing.Back;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.tutorialManager.TutorialManager;
   import core.ui.ZGameButton;
   import displays.ImageLoaderFactory;
   import flash.display.BitmapData;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import sound.SoundEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.displays.popups.SWFPopUp;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class LetterPopup extends SWFPopUp
   {
      
      private var m_data:XML = null;
      
      private var m_closeCallback:Function = null;
      
      private var m_acceptBt:ZGameButton = null;
      
      private var m_initialized:Boolean = false;
      
      private var m_letterId:String = null;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      public function LetterPopup(param1:String, param2:Function = null, param3:String = null)
      {
         var _loc4_:String = null;
         switch(param3)
         {
            case "v2":
               _loc4_ = "assets/displays/dialogs/PU_LetterV2.swf";
               break;
            default:
               _loc4_ = "assets/displays/dialogs/PU_Letter.swf";
         }
         super(ZGlobal.getAssetURL(_loc4_));
         this.m_data = ZGlobal.gameSettings.getLetter(param1);
         this.m_letterId = param1;
         if(param2 != null)
         {
            this.m_closeCallback = param2;
            addEventListener(GenericPopupEvent.SELECTED,param2,false,0,true);
         }
      }
      
      public function get letterID() : String
      {
         return this.m_letterId;
      }
      
      public function get letterName() : String
      {
         return this.m_data.@name.toString();
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         if(Boolean(m_window) && Boolean(m_window.letter_mc))
         {
            m_window.letter_mc.gotoAndStop(1);
         }
         PopupManager.instance.notifyLoadComplete(this);
      }
      
      override public function onShow() : void
      {
         super.onShow();
         this.setupScreen();
      }
      
      private function setupScreen() : void
      {
         var _loc2_:GameItem = null;
         if(!m_window || this.m_initialized)
         {
            return;
         }
         this.m_initialized = true;
         if(this.m_data)
         {
            TextFieldUtil.processTextField(m_window.letter_mc.title_tf,ZGameUtils.ZlocT("Letters",this.m_data.@title.toString()));
            if(this.m_data.@name.toString().length > 0)
            {
               TextFieldUtil.processTextField(m_window.letter_mc.name_tf,ZGameUtils.ZlocT("Letters",this.m_data.@name.toString()));
            }
            else
            {
               m_window.letter_mc.name_tf.visible = false;
            }
            if(this.m_data.@height.toString().length > 0)
            {
               TextFieldUtil.processTextField(m_window.letter_mc.height_tf,ZGameUtils.ZlocT("Letters",this.m_data.@height.toString()));
               m_window.letter_mc.height_tf.visible = true;
            }
            else
            {
               m_window.letter_mc.height_tf.visible = false;
            }
            if(this.m_data.@age.toString().length > 0)
            {
               TextFieldUtil.processTextField(m_window.letter_mc.age_tf,ZGameUtils.ZlocT("Letters",this.m_data.@age.toString()));
               m_window.letter_mc.age_tf.visible = true;
            }
            else
            {
               m_window.letter_mc.age_tf.visible = false;
            }
            if(this.m_data.@role.toString().length > 0)
            {
               TextFieldUtil.processTextField(m_window.letter_mc.role_tf,ZGameUtils.ZlocT("Letters",this.m_data.@role.toString()));
               m_window.letter_mc.role_tf.visible = true;
            }
            else
            {
               m_window.letter_mc.role_tf.visible = false;
            }
            if(this.m_data.@role2.toString().length > 0)
            {
               TextFieldUtil.processTextField(m_window.letter_mc.role2_tf,ZGameUtils.ZlocT("Letters",this.m_data.@role2.toString()));
               m_window.letter_mc.role2_tf.visible = true;
            }
            else
            {
               m_window.letter_mc.role2_tf.visible = false;
            }
            TextFieldUtil.processTextField(m_window.letter_mc.generic_tf,ZGameUtils.ZlocT("Letters",this.m_data.@desc.toString(),ZGameUtils.buildLocalizedParams()));
            TextFieldUtil.processTextField(m_window.letter_mc.hint_tf,ZGameUtils.ZlocT("Letters",this.m_data.@hint.toString()));
            if(this.m_data.@showStamp.toString().toLowerCase() == "false")
            {
               m_window.letter_mc.stamp_mc.visible = false;
            }
            else
            {
               TextFieldUtil.processTextField(m_window.letter_mc.stamp_mc.generic_tf,ZGameUtils.ZlocT("Letters",this.m_data.@stampText.toString()));
               m_window.letter_mc.stamp_mc.visible = true;
            }
            if(this.m_data.@villain.toString().length > 0)
            {
               _loc2_ = ZGlobal.gameSettings.getItemByCode(this.m_data.@villain.toString(),GameItem) as GameItem;
               ImageLoaderFactory.CreateImageLoader(_loc2_.getCachedImage("portrait").url,m_window.letter_mc.villainPortrait_mc.villainloader_mc,this.onVillainImageLoaded);
               TextFieldUtil.processTextField(m_window.letter_mc.villainPortrait_mc.generic_tf,ZGameUtils.ZlocT("Items",_loc2_.name + "_firstName"));
            }
            else
            {
               m_window.letter_mc.villainPortrait_mc.visible = false;
            }
         }
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         m_window.letter_mc.exit_bt.addEventListener(MouseEvent.CLICK,this.onExit,false,0,true);
         this.m_buttonSounds.addButton(m_window.letter_mc.exit_bt,ButtonSound.DEFAULT);
         this.m_acceptBt = new ZGameButton(m_window.letter_mc.accept_bt,this.onAccept);
         this.m_acceptBt.text = ZGameUtils.ZlocT("Dialogs","Close");
         this.m_buttonSounds.addButton(this.m_acceptBt.m_overlay,ButtonSound.DEFAULT);
         m_window.x = 0 - m_window.width;
         m_window.y = Zlab.mainStage.stageHeight / 2 - m_window.width / 2;
         addChild(m_window);
         SoundEvent.getSoundEvent("File").play();
         var _loc1_:Number = Zlab.mainStage.stageWidth / 2 - m_window.width / 2 + 50;
         TweenLite.to(m_window,0.5,{
            "x":_loc1_,
            "onComplete":this.onTweenComplete
         });
      }
      
      private function onTweenComplete() : void
      {
         if(Boolean(m_window) && Boolean(m_window.letter_mc))
         {
            m_window.letter_mc.gotoAndPlay(1);
         }
      }
      
      private function onVillainImageLoaded(param1:String, param2:BitmapData) : void
      {
         m_window.letter_mc.villainPortrait_mc.villainloader_mc.source.smoothing = true;
      }
      
      private function animOut() : void
      {
         var _loc1_:Number = Zlab.mainStage.stageWidth + m_window.width;
         TweenLite.to(m_window,0.75,{
            "x":_loc1_,
            "ease":Back.easeIn,
            "onComplete":this.onAnimOutComplete
         });
      }
      
      private function onAnimOutComplete() : void
      {
         this.close();
      }
      
      private function onExit(param1:MouseEvent) : void
      {
         this.animOut();
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,GenericPopup.CANCEL));
         param1.stopPropagation();
      }
      
      private function onAccept(param1:MouseEvent) : void
      {
         this.animOut();
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,GenericPopup.ACCEPT));
         param1.stopPropagation();
      }
      
      override protected function close(param1:Event = null) : void
      {
         super.close(param1);
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         this.m_acceptBt.dispose();
         if(this.m_closeCallback != null)
         {
            removeEventListener(GenericPopupEvent.SELECTED,this.m_closeCallback);
         }
         SoundEvent.getSoundEvent("File").play();
         ZGlobal.player.setSeenDialog("letter",this.m_letterId);
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.LETTER_CLOSE));
      }
      
      override public function centerWithinStage(param1:Stage) : void
      {
         if(!m_window)
         {
            return;
         }
         TweenLite.killTweensOf(m_window);
         m_window.x = Zlab.mainStage.stageWidth / 2 - m_window.width / 2 + 50;
         m_window.y = Zlab.mainStage.stageHeight / 2 - m_window.width / 2;
      }
   }
}

