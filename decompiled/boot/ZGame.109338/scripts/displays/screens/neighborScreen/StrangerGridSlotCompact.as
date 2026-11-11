package displays.screens.neighborScreen
{
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.managers.PVPManager;
   import core.managers.visitorManager.VisitorManager;
   import core.player.Friend;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.text.TextField;
   import utils.TextFieldUtil;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class StrangerGridSlotCompact extends NeighborSlot
   {
      
      private static var SLOT_FADE_DURATION:Number = 0.5;
      
      private var m_userId:String;
      
      private var m_strangerSlotIndex:int;
      
      private var m_helper:StrangerGridSlotHelper;
      
      private var m_portraitLoader:ImageLoader;
      
      public function StrangerGridSlotCompact(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:int, param5:Friend, param6:Class, param7:int)
      {
         this.m_userId = param5.uid;
         this.m_strangerSlotIndex = PVPManager.instance.getStrangerSlotIndex(param5.uid);
         super(param1,param2,param3,param4,param5,param6,param7);
         PVPManager.instance.addEventListener(PVPManager.GPVP_WINS_CHANGED,this.onWinsChanged,false,0,true);
         PVPManager.instance.addEventListener(PVPManager.GPVP_AWARD_CLAIMED,this.onAwardClaimed,false,0,true);
         VisitorManager.instance.addEventListener(VisitorManager.WORLD_LOADED,this.onVisitWorldLoaded,false,0,true);
      }
      
      public function get strangerSlotIndex() : int
      {
         return this.m_strangerSlotIndex;
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.disposePortraitImageLoader();
         this.m_helper.dispose();
         this.m_helper = null;
         PVPManager.instance.removeEventListener(PVPManager.GPVP_WINS_CHANGED,this.onWinsChanged);
         PVPManager.instance.removeEventListener(PVPManager.GPVP_AWARD_CLAIMED,this.onAwardClaimed);
         VisitorManager.instance.removeEventListener(VisitorManager.WORLD_LOADED,this.onVisitWorldLoaded);
      }
      
      public function disposePortraitImageLoader() : void
      {
         if(this.m_portraitLoader)
         {
            this.m_portraitLoader.destroy();
            this.m_portraitLoader = null;
         }
      }
      
      override protected function onSlotCreated() : void
      {
         this.m_helper = new StrangerGridSlotHelper(slot,this.m_strangerSlotIndex,this,this.fightButtonMC,this.fightButtonTF,this.m_userId);
         super.onSlotCreated();
         slot.door_mc.useHandCursor = false;
         slot.neighborVisitSlot_mc.visible = false;
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
         super.configureAppearance();
         this.m_helper.levelsInteractable = false;
         slot.door_mc.visible = false;
         slot.profilename_tf.visible = true;
         slot.spinSlot_mc.visible = false;
         TextFieldUtil.processTextField(slot.profilename_tf,m_firstName);
         if(!slot.neighborVisitSlot_mc.visible)
         {
            slot.cardBack_mc.visible = true;
         }
         slot.door_mc.visible = false;
         slot.fight_bt.visible = false;
         var _loc1_:int = PVPManager.instance.globalPVPWinProgress;
         if(_loc1_ >= 0)
         {
            if(this.m_strangerSlotIndex == _loc1_)
            {
               if(PVPManager.instance.globalPVPCurrentAwardClaimed)
               {
                  this.m_helper.initializeFightButton();
                  this.m_helper.slideNeighborGrid(m_gridIndex);
               }
               else
               {
                  this.initializeLockedDoor();
               }
            }
            else if(this.m_strangerSlotIndex + 1 == _loc1_)
            {
               if(PVPManager.instance.globalPVPCurrentAwardClaimed)
               {
                  this.onDefeated(true);
               }
               else
               {
                  this.activateSpin(true);
               }
            }
            else if(this.m_strangerSlotIndex < _loc1_)
            {
               this.onDefeated(true);
            }
            else if(this.m_strangerSlotIndex > _loc1_)
            {
               this.initializeLockedDoor();
            }
         }
      }
      
      private function initializeLockedDoor() : void
      {
         slot.door_mc.visible = true;
         this.m_helper.levelsVisible = false;
         this.initializeDoorPortrait();
         disable();
         slot.useHandCursor = false;
      }
      
      private function onWinsChanged(param1:WorldEvent) : void
      {
         if(param1.eventData.oldValue == this.m_strangerSlotIndex)
         {
            this.activateSpin(false);
         }
      }
      
      private function onDefeated(param1:Boolean) : void
      {
         disable();
         this.m_helper.onDefeated(param1);
         this.setPortraitVisible(false,param1);
         slot.neighborVisitSlot_mc.visible = true;
         if(param1)
         {
            slot.cardBack_mc.visible = false;
            slot.profilename_tf.visible = false;
         }
         else
         {
            TweenLite.to(slot.cardBack_mc,SLOT_FADE_DURATION,{"alpha":0});
            TweenLite.to(slot.profilename_tf,SLOT_FADE_DURATION,{"alpha":0});
         }
      }
      
      private function onAwardClaimed(param1:WorldEvent) : void
      {
         if(PVPManager.instance.globalPVPWinProgress - 1 == this.m_strangerSlotIndex)
         {
            this.onDefeated(false);
            this.m_helper.unlockButtonVisible = false;
            this.fightButtonMC.visible = false;
         }
         else if(PVPManager.instance.globalPVPWinProgress == this.m_strangerSlotIndex)
         {
            enable();
            this.m_helper.initializeFightButton();
            this.m_helper.levelsVisible = true;
            slot.door_mc.gotoAndPlay("_show0");
            slot.useHandCursor = true;
            slot.buttonMode = true;
         }
      }
      
      override public function get hasContextMenu() : Boolean
      {
         return false;
      }
      
      private function get fightButtonMC() : MovieClip
      {
         return slot ? slot.fight_bt : null;
      }
      
      private function get fightButtonTF() : TextField
      {
         return Boolean(slot) && Boolean(slot.fight_bt) ? slot.fight_bt.generic_tf : null;
      }
      
      private function get unlockButtonMC() : MovieClip
      {
         return this.m_helper.unlockMC;
      }
      
      public function initializeDoorPortrait() : void
      {
         var _loc2_:String = null;
         var _loc1_:Object = PVPManager.instance.getGlobalPVPStrangerInfo(this.m_userId);
         if(Boolean(_loc1_) && Boolean(_loc1_.playerInfo))
         {
            _loc2_ = _loc1_.playerInfo.snUser.picture;
            this.m_portraitLoader = ImageLoaderFactory.CreateImageLoader(_loc2_,slot.door_mc.icon.icon);
         }
      }
      
      public function activateSpin(param1:Boolean) : void
      {
         this.m_helper.initializeUnlockButton(param1);
         this.m_helper.levelsVisible = false;
         slot.profilename_tf.visible = false;
         this.setPortraitVisible(false,param1);
         slot.spinSlot_mc.visible = true;
         if(param1)
         {
            this.fightButtonMC.visible = false;
            slot.cardBack_mc.visible = false;
         }
         else
         {
            TweenLite.to(this.fightButtonMC,SLOT_FADE_DURATION,{"alpha":0});
            TweenLite.to(slot.cardBack_mc,SLOT_FADE_DURATION,{"alpha":0});
         }
         this.m_helper.slideNeighborGrid(m_gridIndex);
      }
      
      private function setPortraitVisible(param1:Boolean, param2:Boolean) : void
      {
         if(param2)
         {
            slot.portraitframe_mc.alpha = 1;
            slot.profileloader_mc.alpha = 1;
            slot.portraitframe_mc.visible = param1;
            slot.profileloader_mc.visible = param1;
         }
         else
         {
            slot.portraitframe_mc.visible = true;
            slot.profileloader_mc.visible = true;
            if(param1)
            {
               slot.portraitframe_mc.alpha = 0;
               slot.profileloader_mc.alpha = 0;
               TweenLite.to(slot.portraitframe_mc,SLOT_FADE_DURATION,{"alpha":1});
               TweenLite.to(slot.profileloader_mc,SLOT_FADE_DURATION,{"alpha":1});
            }
            else
            {
               slot.portraitframe_mc.alpha = 1;
               slot.profileloader_mc.alpha = 1;
               TweenLite.to(slot.portraitframe_mc,SLOT_FADE_DURATION,{"alpha":0});
               TweenLite.to(slot.profileloader_mc,SLOT_FADE_DURATION,{"alpha":0});
            }
         }
      }
      
      private function onVisitWorldLoaded(param1:Event) : void
      {
         if(ZGlobal.hostPlayer.uid == uid)
         {
            this.m_helper.fightButtonEnabled = false;
         }
         else
         {
            this.m_helper.fightButtonEnabled = true;
         }
      }
   }
}

