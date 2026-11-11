package displays.screens.neighborScreen
{
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.managers.PVPManager;
   import core.managers.visitorManager.VisitorManager;
   import core.player.Friend;
   import dispatchers.UIDispatcher;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.filters.ColorMatrixFilter;
   import flash.text.TextField;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class StrangerGridSlot extends NeighborSlot
   {
      
      private static var NAME_STANDARD:int = 0;
      
      private static var NAME_ENHANCED:int = 1;
      
      private static var SLOT_FADE_DURATION:Number = 0.5;
      
      private static var ACTIVATE_NEXT_CARD_LABEL:String = "_revealNextDoor";
      
      private static var FINALIZE_FADEIN_LABEL:String = "_activate1";
      
      private static var REVEAL_CARD:String = "revealCard";
      
      private var m_strangerSlotIndex:int;
      
      private var m_helper:StrangerGridSlotHelper;
      
      public function StrangerGridSlot(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:int, param5:Friend, param6:Class, param7:int)
      {
         this.m_strangerSlotIndex = PVPManager.instance.getStrangerSlotIndex(param5.uid);
         super(param1,param2,param3,param4,param5,param6,param7);
         PVPManager.instance.addEventListener(PVPManager.GPVP_WINS_CHANGED,this.onWinsChanged,false,0,true);
         PVPManager.instance.addEventListener(PVPManager.GPVP_AWARD_CLAIMED,this.onAwardClaimed,false,0,true);
         UIDispatcher.instance.addEventListener(REVEAL_CARD,this.onRevealNextCard,false,0,true);
         VisitorManager.instance.addEventListener(VisitorManager.WORLD_LOADED,this.onVisitWorldLoaded,false,0,true);
      }
      
      public function get strangerSlotIndex() : int
      {
         return this.m_strangerSlotIndex;
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.m_helper.dispose();
         this.m_helper = null;
         if(slot)
         {
            slot.door_mc.removeEventListener(Event.ENTER_FRAME,this.handleRevealNextDoor);
            slot.door_mc.removeEventListener(Event.ENTER_FRAME,this.handleFadeInEnd);
         }
         PVPManager.instance.removeEventListener(PVPManager.GPVP_WINS_CHANGED,this.onWinsChanged);
         PVPManager.instance.removeEventListener(PVPManager.GPVP_AWARD_CLAIMED,this.onAwardClaimed);
         UIDispatcher.instance.removeEventListener(REVEAL_CARD,this.onRevealNextCard);
         VisitorManager.instance.removeEventListener(VisitorManager.WORLD_LOADED,this.onVisitWorldLoaded);
      }
      
      override protected function onSlotCreated() : void
      {
         this.m_helper = new StrangerGridSlotHelper(slot,this.m_strangerSlotIndex,this,this.fightButtonMC,this.fightButtonTF);
         super.onSlotCreated();
      }
      
      override public function updateTendInfo(param1:Friend) : void
      {
      }
      
      override protected function onCrewNeighborsUpdated(param1:WorldEvent) : void
      {
      }
      
      override protected function onUpdatePVPStatus(param1:WorldEvent) : void
      {
      }
      
      override protected function updateCrewInfo() : void
      {
      }
      
      override protected function get alwaysShowBadLevel() : Boolean
      {
         return true;
      }
      
      override protected function get neverShowLabel() : Boolean
      {
         return true;
      }
      
      override public function configureAppearance() : void
      {
         var _loc2_:Boolean = false;
         super.configureAppearance();
         this.m_helper.levelsInteractable = false;
         slot.door_mc.visible = false;
         if(!slot.neighborVisitSlot_mc.visible)
         {
            slot.cardBack_mc.visible = true;
         }
         var _loc1_:int = PVPManager.instance.globalPVPWinProgress;
         if(_loc1_ >= 0)
         {
            _loc2_ = false;
            if(this.m_strangerSlotIndex >= _loc1_)
            {
               if(this.m_strangerSlotIndex == _loc1_)
               {
                  if(PVPManager.instance.globalPVPCurrentAwardClaimed)
                  {
                     this.updateNameTextField(NAME_ENHANCED);
                     slot.door_mc.visible = true;
                     slot.door_mc.gotoAndStop(FINALIZE_FADEIN_LABEL);
                     this.m_helper.initializeFightButton();
                     this.initSpinHint();
                  }
                  else
                  {
                     slot.door_mc.visible = true;
                     slot.door_mc.gotoAndStop("_reveal1");
                     this.m_helper.levelsVisible = false;
                     this.createUnlockButtonIfClaimable();
                     _loc2_ = true;
                  }
               }
               else if(this.m_strangerSlotIndex == _loc1_ + 1)
               {
                  if(PVPManager.instance.globalPVPCurrentAwardClaimed)
                  {
                     this.onNextUnlockable();
                  }
                  else
                  {
                     this.m_helper.levelsVisible = false;
                     slot.door_mc.visible = true;
                  }
                  _loc2_ = true;
               }
               else
               {
                  slot.door_mc.visible = true;
                  this.m_helper.levelsVisible = false;
                  _loc2_ = true;
               }
            }
            if(_loc2_)
            {
               this.m_helper.rewardIconVisible = true;
            }
            if(_loc1_ > 0 && this.m_strangerSlotIndex < _loc1_)
            {
               this.onDefeated(true);
            }
            if(_loc1_ == this.m_strangerSlotIndex)
            {
               this.m_helper.slideNeighborGrid(m_gridIndex);
            }
         }
      }
      
      private function onDefeated(param1:Boolean) : void
      {
         this.updateNameTextField(NAME_STANDARD);
         disable();
         this.m_helper.onDefeated(param1);
         slot.crosshair_mc.visible = true;
         slot.crosshair_mc.gotoAndPlay(param1 ? "_show1" : "_show0");
         slot.profileloader_mc.filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
      }
      
      private function onNextUnlockable() : void
      {
         slot.door_mc.visible = true;
         slot.door_mc.gotoAndStop("_reveal1");
         this.m_helper.levelsVisible = false;
      }
      
      private function updateNameTextField(param1:int) : void
      {
         if(param1 == NAME_STANDARD)
         {
            slot.profilename_tf.visible = true;
            slot.profileName_tf2.visible = false;
            TextFieldUtil.processTextField(slot.profilename_tf,m_firstName);
         }
         else if(param1 == NAME_ENHANCED)
         {
            slot.profilename_tf.visible = false;
            slot.profileName_tf2.visible = true;
            TextFieldUtil.processTextField(slot.profileName_tf2,m_firstName);
         }
      }
      
      private function createUnlockButtonIfClaimable() : void
      {
         if(PVPManager.instance.globalPVPSlotClaimable(this.m_strangerSlotIndex))
         {
            this.m_helper.initializeUnlockButton(true);
         }
      }
      
      private function onWinsChanged(param1:WorldEvent) : void
      {
         if(param1.eventData.oldValue == this.m_strangerSlotIndex)
         {
            slot.door_mc.alpha = 1;
            slot.door_mc.visible = true;
            TweenLite.to(slot.door_mc,SLOT_FADE_DURATION,{
               "alpha":0,
               "onComplete":this.onDoorFadeDone
            });
            this.onDefeated(false);
            this.m_helper.slideNeighborGrid(m_gridIndex);
         }
         else if(param1.eventData.newValue == this.m_strangerSlotIndex)
         {
            this.m_helper.initializeUnlockButton(false);
         }
      }
      
      private function onDoorFadeDone() : void
      {
         slot.door_mc.visible = false;
      }
      
      private function onAwardClaimed(param1:WorldEvent) : void
      {
         if(PVPManager.instance.globalPVPWinProgress == this.m_strangerSlotIndex)
         {
            this.m_helper.unlockButtonVisible = false;
            this.m_helper.levelsVisible = true;
            slot.door_mc.addEventListener(Event.ENTER_FRAME,this.handleRevealNextDoor,false,0,true);
            slot.door_mc.gotoAndPlay("_activate0");
            this.initSpinHint();
            this.m_helper.initializeFightButton();
            this.updateNameTextField(NAME_ENHANCED);
            this.m_helper.slideNeighborGrid(m_gridIndex);
         }
      }
      
      private function onRevealNextCard(param1:WorldEvent) : void
      {
         if(this.m_strangerSlotIndex == param1.eventData.slotIndex)
         {
            slot.door_mc.gotoAndPlay("_reveal0");
         }
      }
      
      private function handleRevealNextDoor(param1:Event) : void
      {
         var _loc2_:WorldEvent = null;
         if(param1.target.currentLabel == ACTIVATE_NEXT_CARD_LABEL)
         {
            slot.door_mc.removeEventListener(Event.ENTER_FRAME,this.handleRevealNextDoor);
            slot.door_mc.addEventListener(Event.ENTER_FRAME,this.handleFadeInEnd,false,0,true);
            _loc2_ = new WorldEvent(REVEAL_CARD,{"slotIndex":this.m_strangerSlotIndex + 1});
            UIDispatcher.instance.dispatchEvent(_loc2_);
         }
      }
      
      private function handleFadeInEnd(param1:Event) : void
      {
         if(param1.target.currentLabel == FINALIZE_FADEIN_LABEL)
         {
            slot.door_mc.removeEventListener(Event.ENTER_FRAME,this.handleFadeInEnd);
            this.m_helper.initializeFightButton();
            this.m_helper.unlockButtonVisible = false;
         }
      }
      
      private function onVisitWorldLoaded(param1:Event) : void
      {
         if(ZGlobal.hostPlayer.uid == uid)
         {
            slot.cardBack_mc.visible = false;
            slot.neighborVisitSlot_mc.visible = true;
            this.m_helper.fightButtonEnabled = false;
         }
         else
         {
            slot.cardBack_mc.visible = true;
            slot.neighborVisitSlot_mc.visible = false;
            this.m_helper.fightButtonEnabled = true;
         }
      }
      
      override public function get hasContextMenu() : Boolean
      {
         return false;
      }
      
      private function get fightButtonMC() : MovieClip
      {
         return Boolean(slot) && Boolean(slot.door_mc) ? slot.door_mc.fight_bt : null;
      }
      
      private function get fightButtonTF() : TextField
      {
         return Boolean(slot) && Boolean(slot.door_mc) && Boolean(slot.door_mc.fight_mc) ? slot.door_mc.fight_mc.generic_tf : null;
      }
      
      private function get unlockButtonMC() : MovieClip
      {
         return this.m_helper.unlockMC;
      }
      
      private function initSpinHint() : void
      {
         var _loc1_:String = null;
         if(Boolean(slot) && Boolean(slot.door_mc) && Boolean(slot.door_mc.spin_mc) && Boolean(slot.door_mc.spin_mc.spin_tf))
         {
            _loc1_ = ZGameUtils.ZlocT("Dialogs","GlobalPVPStrangerSlotHint");
            TextFieldUtil.compactTextField(slot.door_mc.spin_mc.spin_tf,_loc1_,{
               "minScale":0.4,
               "filter":"ignore"
            });
         }
      }
   }
}

