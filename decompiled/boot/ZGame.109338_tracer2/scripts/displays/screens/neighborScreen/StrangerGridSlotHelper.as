package displays.screens.neighborScreen
{
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.managers.PVPManager;
   import core.ui.Tooltip;
   import core.ui.UIManager;
   import core.ui.menuitem.MenuItem;
   import core.ui.menuitem.StrangersBarUIItem;
   import dispatchers.NeighborsDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GenericPopup;
   import displays.popups.PVPSlotMachinePopup;
   import events.FriendBarSlotEvent;
   import fl.containers.UILoader;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   import zlabs.managers.WindowManager;
   
   public class StrangerGridSlotHelper
   {
      
      private static var SLOT_FADE_DURATION:Number = 0.5;
      
      private static var BUTTON_STATE_IDLE:int = 1;
      
      private static var BUTTON_STATE_OVER:int = 2;
      
      private static var BUTTON_STATE_DOWN:int = 3;
      
      private static var BUTTON_STATE_DISABLED:int = 5;
      
      public var m_slot:MovieClip;
      
      public var m_slotIndex:int;
      
      private var m_rewardLoader:ImageLoader;
      
      private var m_fightButtonInitialized:Boolean;
      
      private var m_unlockButtonInitialized:Boolean;
      
      private var m_fightButtonMC:MovieClip;
      
      private var m_fightButtonTF:TextField;
      
      private var m_slotObject:IPlayerSlot;
      
      private var m_uid:String;
      
      private var m_fightButtonEnabled:Boolean = true;
      
      public function StrangerGridSlotHelper(param1:MovieClip, param2:int, param3:IPlayerSlot = null, param4:MovieClip = null, param5:TextField = null, param6:String = null)
      {
         super();
         this.m_slot = param1;
         this.m_slotIndex = param2;
         this.m_fightButtonMC = param4;
         this.m_fightButtonTF = param5;
         this.m_slotObject = param3;
         this.m_uid = param6;
         this.unlockMC.visible = false;
         this.m_slot.profilename_tf.visible = false;
         if(this.m_slot.profileName_tf2)
         {
            this.m_slot.profileName_tf2.visible = false;
         }
         this.m_slot.crosshair_mc.mouseEnabled = false;
         this.m_slot.crosshair_mc.mouseChildren = false;
         this.activateSlotListeners(true);
      }
      
      public function get unlockMC() : MovieClip
      {
         return this.m_slot ? this.m_slot.unlock_bt : null;
      }
      
      public function get rewardLoader() : UILoader
      {
         return this.m_slot ? this.m_slot.door_mc.icon.icon_prize : null;
      }
      
      public function initializeUnlockButton(param1:Boolean) : void
      {
         var _loc2_:String = null;
         if(!this.m_unlockButtonInitialized)
         {
            this.m_unlockButtonInitialized = true;
            _loc2_ = ZGameUtils.ZlocT("Dialogs","GlobalPVPStrangerSlotUnlockText");
            TextFieldUtil.compactTextField(this.unlockMC.generic_tf,_loc2_,{
               "minScale":0.4,
               "filter":"ignore"
            });
            this.unlockButtonVisible = true;
            if(param1)
            {
               this.unlockMC.alpha = 1;
            }
            else
            {
               this.unlockMC.alpha = 0;
               TweenLite.to(this.unlockMC,SLOT_FADE_DURATION,{"alpha":1});
            }
         }
      }
      
      public function set unlockButtonVisible(param1:Boolean) : void
      {
         if(this.unlockMC)
         {
            this.unlockMC.visible = param1;
         }
      }
      
      public function dispose() : void
      {
         this.m_slotObject = null;
         this.disposeRewardImageLoader();
         this.activateSlotListeners(false);
      }
      
      public function set levelsVisible(param1:Boolean) : void
      {
         this.m_slot.heartlevel_tf.visible = param1;
         this.m_slot.profilelevel_tf.visible = param1;
         this.m_slot.rareloader_mc.visible = param1;
         this.m_slot.star_mc.visible = param1;
      }
      
      public function set levelsInteractable(param1:Boolean) : void
      {
         this.m_slot.heartlevel_tf.mouseEnabled = param1;
         this.m_slot.profilelevel_tf.mouseEnabled = param1;
         this.m_slot.rareloader_mc.mouseEnabled = param1;
         this.m_slot.star_mc.mouseEnabled = param1;
      }
      
      public function disposeRewardImageLoader() : void
      {
         if(this.m_rewardLoader)
         {
            this.m_rewardLoader.destroy();
            this.m_rewardLoader = null;
         }
      }
      
      public function set rewardIconVisible(param1:Boolean) : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         if(param1)
         {
            if(!this.m_rewardLoader)
            {
               _loc2_ = PVPManager.instance.getFeaturedRewardInfo(this.m_slotIndex);
               if(_loc2_)
               {
                  _loc3_ = _loc2_.image;
                  this.m_rewardLoader = ImageLoaderFactory.CreateImageLoader(_loc3_,this.rewardLoader);
                  this.m_rewardLoader.smooth = true;
                  _loc4_ = "x" + String(_loc2_.amount);
                  TextFieldUtil.processTextField(this.m_slot.door_mc.num_mc.num_tf,_loc4_);
                  TextFieldUtil.processTextField(this.m_slot.door_mc.num_mc.chance_tf,ZGameUtils.ZlocT("Dialogs","GlobalPVPStrangerSlotChance"));
                  this.m_slot.door_mc.num_mc.num_tf.mouseEnabled = false;
               }
            }
         }
         else if(this.m_rewardLoader)
         {
            this.disposeRewardImageLoader();
         }
         this.m_slot.door_mc.num_mc.visible = param1;
         this.rewardLoader.visible = param1;
      }
      
      public function slideNeighborGrid(param1:int) : void
      {
         var _loc2_:MenuItem = UIManager.instance.getMenuItemByName(StrangersBarUIItem.ITEM_ID);
         var _loc3_:StrangersBarUIItem = _loc2_ as StrangersBarUIItem;
         if(_loc3_)
         {
            _loc3_.makeSlotsVisible(param1);
         }
      }
      
      public function activateSlotListeners(param1:Boolean) : void
      {
         if(this.m_slot)
         {
            if(param1)
            {
               this.m_slot.addEventListener(MouseEvent.ROLL_OVER,this.onSlotRollOver,false,0,true);
               this.m_slot.addEventListener(MouseEvent.ROLL_OUT,this.onSlotRollOut,false,0,true);
               this.m_slot.addEventListener(MouseEvent.MOUSE_DOWN,this.onSlotMouseDown,false,0,true);
               this.m_slot.addEventListener(MouseEvent.MOUSE_UP,this.onSlotMouseUp,false,0,true);
            }
            else
            {
               this.m_slot.removeEventListener(MouseEvent.ROLL_OVER,this.onSlotRollOver);
               this.m_slot.removeEventListener(MouseEvent.ROLL_OUT,this.onSlotRollOut);
               this.m_slot.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSlotMouseDown);
               this.m_slot.removeEventListener(MouseEvent.MOUSE_UP,this.onSlotMouseUp);
            }
         }
      }
      
      private function onSlotRollOver(param1:MouseEvent) : void
      {
         if(Boolean(this.fightButtonMC) && this.m_fightButtonEnabled)
         {
            this.fightButtonMC.gotoAndStop(BUTTON_STATE_OVER);
         }
         if(this.unlockMC)
         {
            this.unlockMC.gotoAndStop(BUTTON_STATE_OVER);
         }
      }
      
      private function onSlotRollOut(param1:MouseEvent = null) : void
      {
         if(Boolean(this.fightButtonMC) && this.m_fightButtonEnabled)
         {
            this.fightButtonMC.gotoAndStop(BUTTON_STATE_IDLE);
         }
         if(this.unlockMC)
         {
            this.unlockMC.gotoAndStop(BUTTON_STATE_IDLE);
         }
      }
      
      private function onSlotMouseDown(param1:MouseEvent) : void
      {
         if(Boolean(this.fightButtonMC) && this.m_fightButtonEnabled)
         {
            this.fightButtonMC.gotoAndStop(BUTTON_STATE_DOWN);
         }
         if(this.unlockMC)
         {
            this.unlockMC.gotoAndStop(BUTTON_STATE_DOWN);
         }
      }
      
      private function onSlotMouseUp(param1:MouseEvent) : void
      {
         if(Boolean(this.fightButtonMC) && this.m_fightButtonEnabled)
         {
            this.fightButtonMC.gotoAndStop(BUTTON_STATE_IDLE);
         }
         if(this.unlockMC)
         {
            this.unlockMC.gotoAndStop(BUTTON_STATE_IDLE);
         }
         var _loc2_:int = this.m_slotIndex;
         if(PVPManager.strangerBarType == PVPManager.STRANGERBAR_COMPACT)
         {
            _loc2_++;
         }
         if(PVPManager.instance.globalPVPSlotClaimable(_loc2_))
         {
            WindowManager.instance.push(new PVPSlotMachinePopup());
         }
         else if(Boolean(this.m_slotObject) && this.canStartFight)
         {
            if(!PVPManager.instance.refreshingTruncatedFightList(this.m_slotIndex))
            {
               this.checkFightConditions();
            }
         }
      }
      
      private function checkFightConditions() : void
      {
         if(PVPManager.instance.canAttackWithImmunityCooldown())
         {
            if(PVPManager.instance.canAttackWithNeighborAssist(this.m_uid))
            {
               if(PVPManager.instance.checkImmunityCancel(this.onImmunityCancelClosed,null))
               {
                  this.doStartFight();
               }
            }
         }
      }
      
      private function onImmunityCancelClosed(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.ACCEPT)
         {
            this.doStartFight();
         }
      }
      
      private function doStartFight() : void
      {
         NeighborsDispatcher.instance.dispatchEvent(new FriendBarSlotEvent(FriendBarSlotEvent.FRIEND_BAR_SLOT_CLICK,FriendBarSlotEvent.BUTTON_ATTACK,this.m_slotObject));
      }
      
      public function get canStartFight() : Boolean
      {
         var _loc1_:int = PVPManager.instance.getGlobalPVPInvasionStatus(this.m_uid);
         var _loc2_:Boolean = _loc1_ != PVPManager.STATUS_OCCUPIED && _loc1_ != PVPManager.STATUS_RETAL_COOLDOWN;
         if(!_loc2_)
         {
            return false;
         }
         var _loc3_:int = PVPManager.instance.globalPVPWinProgress;
         var _loc4_:Boolean = _loc3_ == this.m_slotIndex;
         if(!_loc4_)
         {
            return false;
         }
         if(!this.m_fightButtonEnabled)
         {
            return false;
         }
         var _loc5_:Boolean = PVPManager.instance.globalPVPCurrentAwardClaimed;
         return (_loc5_) || !this.m_slotIndex;
      }
      
      public function initializeFightButton() : void
      {
         var _loc1_:String = null;
         if(!this.m_fightButtonInitialized)
         {
            this.m_fightButtonInitialized = true;
            _loc1_ = ZGameUtils.ZlocT("Dialogs","GlobalPVPStrangerSlotFightText");
            TextFieldUtil.compactTextField(this.fightButtonTF,_loc1_,{"maxLines":1});
            this.fightButtonMC.visible = true;
            if(this.m_slot.door_mc.fight_mc)
            {
               this.m_slot.door_mc.fight_mc.mouseEnabled = false;
               this.m_slot.door_mc.fight_mc.mouseChildren = false;
            }
            if(this.m_slot.door_mc.arrow_mc)
            {
               this.m_slot.door_mc.arrow_mc.mouseEnabled = false;
               this.m_slot.door_mc.arrow_mc.mouseChildren = false;
            }
            if(ZGlobal.hostPlayer.uid == this.m_uid)
            {
               this.fightButtonEnabled = false;
            }
         }
      }
      
      public function set fightButtonEnabled(param1:Boolean) : void
      {
         this.m_fightButtonEnabled = param1;
         if(Boolean(this.fightButtonMC) && !param1)
         {
            this.fightButtonMC.gotoAndStop(BUTTON_STATE_DISABLED);
         }
      }
      
      private function get fightButtonMC() : MovieClip
      {
         return this.m_fightButtonMC;
      }
      
      private function get fightButtonTF() : TextField
      {
         return this.m_fightButtonTF;
      }
      
      public function onDefeated(param1:Boolean) : void
      {
         var _loc2_:String = ZGameUtils.ZlocT("Dialogs","GlobalPVPStrangerSlotDefeatedTooltip");
         Tooltip.subscribe(this.m_slot,_loc2_,{"offsetY":-25});
         this.levelsVisible = false;
         this.activateSlotListeners(false);
         this.m_slot.highlightSelect_mc.enabled = false;
         this.m_slot.useHandCursor = false;
         this.m_slot.buttonMode = false;
      }
   }
}

