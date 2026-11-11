package displays.popups.battlelost
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.ui.ZGameButton;
   import displays.ImageLoaderFactory;
   import displays.popups.battlebase.BattleBasePopup;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import sound.SoundEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.events.GenericPopupEvent;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class BattleLostPopup extends BattleBasePopup
   {
      
      private var m_closeCallback:Function = null;
      
      private var m_buttons:Array = null;
      
      private var m_initialised:Boolean = false;
      
      protected var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      public function BattleLostPopup(param1:Array, param2:Dictionary, param3:Function = null)
      {
         this.m_closeCallback = param3;
         super(param1,param2);
      }
      
      override protected function assetStr() : String
      {
         if(allowUnitBuyBack())
         {
            return "assets/displays/dialogs/PU_Defeat_Retreat2.swf";
         }
         return "assets/displays/dialogs/PU_Defeat_Retreat.swf";
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         this.setContentDimentions();
         PopupManager.instance.notifyLoadComplete(this);
      }
      
      protected function setContentDimentions() : void
      {
         this.contentWidth = 650;
         this.contentHeight = 382;
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
            m_origOffsetX = m_window.x;
            m_origOffsetY = m_window.y;
            this.setUpPopupUI();
         }
      }
      
      protected function get buttons() : Array
      {
         return this.m_buttons;
      }
      
      protected function setUpPopupUI() : void
      {
         initDialog();
         if(m_window.Defeat)
         {
            m_window.Defeat.visible = false;
         }
         if(m_window.Retreat)
         {
            m_window.Retreat.visible = false;
         }
         screen.visible = true;
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_buttons = new Array(1);
         this.m_buttons[0] = new ZGameButton(screen.orangeButton_01,this.onButton1Clicked,1.1,true);
         this.m_buttonSounds.addButton(this.m_buttons[0].m_overlay,ButtonSound.DEFAULT);
         if(null != this.m_closeCallback)
         {
            addEventListener(GenericPopupEvent.SELECTED,this.m_closeCallback,false,0,true);
         }
         screen.exit_bt.addEventListener(MouseEvent.CLICK,onExit,false,0,true);
         this.m_buttonSounds.addButton(screen.exit_bt,ButtonSound.DEFAULT);
      }
      
      override protected function get villainMovie() : String
      {
         return "victory";
      }
      
      private function getCrossOrder() : Array
      {
         switch(numLostUnits)
         {
            case 1:
               return [2,0,1,3,4];
            case 2:
               return [1,2,0,3];
            case 3:
               return [1,2,3,0,4];
            case 4:
               return [0,1,2,3];
            case 5:
               return [0,1,2,3,4];
            default:
               return [];
         }
      }
      
      private function getRewardClips() : Array
      {
         var _loc1_:Array = null;
         if(numLostUnits == 0)
         {
            _loc1_ = [];
            screen.units_even.visible = false;
            screen.units_odd.visible = false;
         }
         else if(numLostUnits % 2 == 0)
         {
            _loc1_ = [screen.units_even.reward1_mc,screen.units_even.reward2_mc,screen.units_even.reward3_mc,screen.units_even.reward4_mc];
            screen.units_even.visible = true;
            screen.units_odd.visible = false;
         }
         else
         {
            _loc1_ = [screen.units_odd.reward1_mc,screen.units_odd.reward2_mc,screen.units_odd.reward3_mc,screen.units_odd.reward4_mc,screen.units_odd.reward5_mc];
            screen.units_even.visible = false;
            screen.units_odd.visible = true;
         }
         return _loc1_;
      }
      
      protected function setupRewards() : void
      {
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc8_:GameItem = null;
         var _loc9_:int = 0;
         if(allowUnitBuyBack())
         {
            return;
         }
         var _loc1_:Array = this.getRewardClips();
         var _loc2_:int = 1000;
         var _loc3_:int = 0;
         var _loc4_:Array = this.getCrossOrder();
         var _loc5_:Boolean = false;
         for(_loc6_ in lostUnits)
         {
            _loc7_ = 0;
            while(_loc7_ < lostUnits[_loc6_])
            {
               _loc8_ = ZGlobal.gameSettings.getItemByCode(_loc6_,GameItem) as GameItem;
               _loc9_ = int(_loc4_[_loc3_]);
               _loc1_[_loc9_].visible = true;
               _loc1_[_loc9_].check_mc.visible = false;
               TextFieldUtil.processTextField(_loc1_[_loc9_].name_tf,_loc8_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
               ZGameUtils.hideIfExists(_loc1_[_loc9_].count_mc);
               ZGameUtils.hideIfExists(_loc1_[_loc9_].emp_bt);
               loaders.push(ImageLoaderFactory.CreateImageLoader(_loc8_.getCachedImage("icon").url,_loc1_[_loc9_].uiloader_mc));
               Zlab.processManager.schedule(_loc2_,this,this.onShowCheck,_loc1_[_loc9_]);
               _loc3_++;
               _loc5_ = true;
               _loc2_ += 500;
               _loc7_++;
            }
         }
         while(_loc3_ < _loc1_.length)
         {
            _loc1_[_loc4_[_loc3_]].visible = false;
            _loc3_++;
         }
         if(null != screen.noUnits_tf)
         {
            if(_loc5_)
            {
               screen.noUnits_tf.visible = false;
            }
            else
            {
               TextFieldUtil.processTextField(screen.noUnits_tf,ZGameUtils.ZlocT("Dialogs","RetreatNoLostUnits"));
               screen.noUnits_tf.visible = true;
            }
         }
      }
      
      private function onShowCheck(param1:Object) : void
      {
         param1.check_mc.visible = true;
         param1.check_mc.gotoAndPlay(1);
         SoundEvent.getSoundEvent("CrossOut").play();
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:ZGameButton = null;
         super.deinitDialog();
         Zlab.processManager.removeScheduledObject(this);
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
         screen.exit_bt.removeEventListener(MouseEvent.CLICK,onExit);
         for each(_loc1_ in this.m_buttons)
         {
            _loc1_.dispose();
         }
         this.m_buttons = null;
      }
      
      override protected function close(param1:Event = null) : void
      {
         this.deinitDialog();
         super.close();
      }
      
      protected function onButton1Clicked(param1:MouseEvent) : void
      {
         this.close();
      }
      
      protected function onButton2Clicked(param1:MouseEvent) : void
      {
         this.close();
      }
      
      protected function onButton3Clicked(param1:MouseEvent) : void
      {
         this.close();
      }
   }
}

