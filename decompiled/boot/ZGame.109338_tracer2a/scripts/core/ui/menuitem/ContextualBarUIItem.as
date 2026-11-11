package core.ui.menuitem
{
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.gameobjects.ConsumableItem;
   import core.gameobjects.PlayerCampaign;
   import core.managers.ExperimentsManager;
   import core.managers.PVPManager;
   import core.ui.UIManager;
   import dispatchers.NeighborsDispatcher;
   import dispatchers.UIDispatcher;
   import events.FriendBarSlotEvent;
   import events.RepositionEvent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Rectangle;
   import utils.BitArray;
   import zlabs.Zlab;
   import zlabs.events.WorldEvent;
   
   public class ContextualBarUIItem extends MenuItem
   {
      
      private static const FRIENDBAR_HEIGHT:int = 168;
      
      private static const STRANGER_BAR_HIDE_MARGIN:int = 100;
      
      private static const COMBAT_BAR_X_OFFSET:int = 6;
      
      public static const ITEM_ID:String = "contextualBarItem";
      
      public static const ADD_COMBAT_EVENT:String = "addcombatevent";
      
      public static const REMOVE_COMBAT_EVENT:String = "removecombatevent";
      
      public static const TWEEN_START:String = "tweenStart";
      
      public static const TWEEN_END:String = "tweenEnd";
      
      private static const NEIGHBOR_BAR_VERTICAL_NUDGE:int = -16;
      
      private static const STRANGER_BAR_VERTICAL_NUDGE:int = -8;
      
      private static const COMBAT_BAR_VERTICAL_NUDGE:int = 8;
      
      private static const m_tweenSeconds:Number = 0.5;
      
      private var m_friendsBar:FriendsBarUIItem = null;
      
      private var m_strangersBar:StrangersBarUIItem = null;
      
      private var m_combatBar:CombatBarUIItem = null;
      
      private var m_hidden:Boolean = false;
      
      private var m_tweening:Boolean = false;
      
      public function ContextualBarUIItem()
      {
         super(ITEM_ID);
         this.m_friendsBar = new FriendsBarUIItem();
         this.m_strangersBar = new StrangersBarUIItem();
         this.m_friendsBar.postInit();
         this.m_strangersBar.postInit();
         this.m_combatBar = new CombatBarUIItem(this);
         this.m_strangersBar.visible = false;
         this.m_friendsBar.visible = true;
         this.m_combatBar.visible = false;
         UIManager.instance.registerComponent(this.m_friendsBar);
         UIManager.instance.registerComponent(this.m_strangersBar);
         UIManager.instance.registerComponent(this.m_combatBar);
         UIDispatcher.instance.addEventListener(RepositionEvent.REPOSITION_HUD,this.onReposition,false,0,true);
         addEventListener(ADD_COMBAT_EVENT,this.onAddCombatEvent);
         addEventListener(REMOVE_COMBAT_EVENT,this.onRemoveCombatEvent);
         NeighborsDispatcher.instance.addEventListener(FriendBarSlotEvent.FRIEND_BAR_SLOT_CLICK,this.onClickOnFriend,false,10);
         PVPManager.instance.addEventListener(PVPManager.GLOBALPVP_UI_STATECHANGE,this.onGlobalPVPUIStateChange,false,0,true);
      }
      
      public static function getContextualBar() : MenuItem
      {
         return UIManager.instance.getMenuItemByName(ContextualBarUIItem.ITEM_ID);
      }
      
      public function isTweening() : Boolean
      {
         return this.m_tweening;
      }
      
      public function getCombatBar() : CombatBarUIItem
      {
         var _loc3_:BitArray = null;
         var _loc1_:ConsumableItem = ZGlobal.gameSettings.getItemByCode(ConsumableItem.HEAL_ALL_ITEM_CODE,ConsumableItem) as ConsumableItem;
         var _loc2_:PlayerCampaign = ZGlobal.player.campaign;
         if(_loc2_)
         {
            _loc3_ = ZGlobal.player.checkGate(_loc1_);
            if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIEMNT_FULL_HEALER) == 2 && !_loc3_.anyBitSet())
            {
               this.m_combatBar.initFullHealer();
            }
         }
         return this.m_combatBar;
      }
      
      public function fadeInStrangerBar() : void
      {
         this.updateFriendBarVisibility();
         var _loc1_:int = this.m_strangersBar.doFadeIn();
         Zlab.processManager.schedule(_loc1_,this,this.onFadeInStrangerBarDone);
      }
      
      public function fadeOutStrangerBar() : void
      {
         this.updateFriendBarVisibility();
         var _loc1_:int = this.m_strangersBar.doFadeOut();
         Zlab.processManager.schedule(_loc1_,this,this.onFadeOutStrangerBarDone);
      }
      
      private function onFadeInStrangerBarDone() : void
      {
         var _loc1_:OptionUIItem = OptionUIItem.instance;
         if(_loc1_)
         {
            _loc1_.doFinalizeStrangerBarFadeIn();
         }
      }
      
      private function onFadeOutStrangerBarDone() : void
      {
         var _loc1_:OptionUIItem = OptionUIItem.instance;
         if(_loc1_)
         {
            _loc1_.doFinalizeStrangerBarFadeOut();
         }
      }
      
      override public function show(param1:Boolean = false) : void
      {
         var _loc3_:Number = NaN;
         this.completeActiveTweens();
         this.m_hidden = false;
         var _loc2_:Number = Zlab.mainStage.stageHeight - this.m_friendsBar.uiHeight + NEIGHBOR_BAR_VERTICAL_NUDGE;
         _loc3_ = Zlab.mainStage.stageHeight - this.m_strangersBar.uiHeight + STRANGER_BAR_VERTICAL_NUDGE;
         var _loc4_:Number = Zlab.mainStage.stageHeight - this.m_combatBar.height + COMBAT_BAR_VERTICAL_NUDGE;
         if(param1)
         {
            TweenLite.to(this.m_friendsBar,this.tweenDurationSeconds,{"y":_loc2_});
            TweenLite.to(this.m_strangersBar,this.tweenDurationSeconds,{"y":_loc3_});
            TweenLite.to(this.m_combatBar,this.tweenDurationSeconds,{"y":_loc4_});
            this.tweeningStarted();
         }
         else
         {
            this.m_friendsBar.y = _loc2_;
            this.m_strangersBar.y = _loc3_;
            this.m_combatBar.y = _loc4_;
         }
         UIDispatcher.instance.dispatchEvent(new RepositionEvent(RepositionEvent.REPOSITION_FRIENDBAR,this.m_friendsBar.x,_loc2_,this.m_friendsBar.uiWidth,this.m_friendsBar.height));
         UIDispatcher.instance.dispatchEvent(new RepositionEvent(RepositionEvent.REPOSITION_COMBAT_ALLY_OVERLAY,this.m_combatBar.x,Zlab.mainStage.stageHeight,this.m_combatBar.width,this.m_combatBar.height));
      }
      
      override public function hide(param1:Boolean = false) : void
      {
         this.completeActiveTweens();
         this.m_hidden = true;
         var _loc2_:Rectangle = this.m_friendsBar.getBounds(this.m_friendsBar);
         var _loc3_:Number = _loc2_.top < 0 ? Math.abs(_loc2_.top) : 0;
         _loc2_ = this.m_combatBar.getBounds(this.m_combatBar);
         var _loc4_:Number = _loc2_.top < 0 ? Math.abs(_loc2_.top) : 0;
         _loc2_ = this.m_strangersBar.getBounds(this.m_strangersBar);
         var _loc5_:Number = _loc2_.top < 0 ? Math.abs(_loc2_.top) : 0;
         if(param1)
         {
            TweenLite.to(this.m_friendsBar,this.tweenDurationSeconds,{"y":Zlab.mainStage.stageHeight + _loc3_});
            TweenLite.to(this.m_strangersBar,this.tweenDurationSeconds,{"y":Zlab.mainStage.stageHeight + _loc5_});
            TweenLite.to(this.m_combatBar,this.tweenDurationSeconds,{"y":Zlab.mainStage.stageHeight + _loc4_});
            this.tweeningStarted();
         }
         else
         {
            this.m_friendsBar.y = Zlab.mainStage.stageHeight + _loc3_;
            this.m_strangersBar.y = Zlab.mainStage.stageHeight + _loc5_;
            this.m_combatBar.y = Zlab.mainStage.stageHeight + _loc4_;
         }
         var _loc6_:Number = Zlab.mainStage.stageHeight - FRIENDBAR_HEIGHT;
         UIDispatcher.instance.dispatchEvent(new RepositionEvent(RepositionEvent.REPOSITION_FRIENDBAR,this.m_friendsBar.x,_loc6_,this.m_friendsBar.uiWidth,this.m_friendsBar.height));
         UIDispatcher.instance.dispatchEvent(new RepositionEvent(RepositionEvent.REPOSITION_COMBAT_ALLY_OVERLAY,this.m_combatBar.x,Zlab.mainStage.stageHeight,this.m_combatBar.width,this.m_combatBar.height));
      }
      
      override public function removeItem() : void
      {
         UIDispatcher.instance.removeEventListener(RepositionEvent.REPOSITION_HUD,this.onReposition);
         removeEventListener(ADD_COMBAT_EVENT,this.onAddCombatEvent);
         removeEventListener(REMOVE_COMBAT_EVENT,this.onRemoveCombatEvent);
         NeighborsDispatcher.instance.removeEventListener(FriendBarSlotEvent.FRIEND_BAR_SLOT_CLICK,this.onClickOnFriend);
         PVPManager.instance.removeEventListener(PVPManager.GLOBALPVP_UI_STATECHANGE,this.onGlobalPVPUIStateChange);
         this.m_friendsBar = null;
         this.m_strangersBar = null;
         this.m_combatBar = null;
      }
      
      private function onClickOnFriend(param1:FriendBarSlotEvent) : void
      {
         if(param1.buttonType == FriendBarSlotEvent.BUTTON_CONTINUE_ATTACK)
         {
            OptionUIItem.instance.visible = false;
            this.hide(true);
         }
      }
      
      private function onAddCombatEvent(param1:WorldEvent) : void
      {
         if(this.m_hidden)
         {
            this.show(true);
         }
         this.m_combatBar.visible = true;
         this.m_combatBar.active = true;
         this.updateFriendBarVisibility();
      }
      
      private function onRemoveCombatEvent(param1:WorldEvent) : void
      {
         this.m_combatBar.visible = false;
         this.m_combatBar.active = false;
         this.updateFriendBarVisibility();
      }
      
      private function updateFriendBarVisibility() : void
      {
         if(this.m_combatBar.visible)
         {
            this.m_friendsBar.visible = false;
            this.m_strangersBar.visible = false;
         }
         else if(PVPManager.instance.globalPVPUIState == PVPManager.GLOBALPVP_UI_NONE)
         {
            this.m_friendsBar.visible = true;
            this.m_strangersBar.visible = false;
         }
         else if(PVPManager.instance.globalPVPUIState == PVPManager.GLOBALPVP_UI_ACTIVE)
         {
            this.m_friendsBar.visible = false;
            this.m_strangersBar.visible = true;
         }
         else
         {
            this.m_friendsBar.visible = true;
            this.m_strangersBar.visible = true;
         }
      }
      
      private function onGlobalPVPUIStateChange(param1:WorldEvent) : void
      {
         if(!PVPManager.isGlobalPVPFadeState(PVPManager.instance.globalPVPUIState))
         {
            this.updateFriendBarVisibility();
         }
      }
      
      protected function onReposition(param1:RepositionEvent) : void
      {
         UIDispatcher.instance.dispatchEvent(new RepositionEvent(RepositionEvent.REPOSITION_FRIENDBAR_RESIZE,param1.x,param1.y,param1.width,param1.height));
         this.m_friendsBar.x = (param1.width - this.m_friendsBar.uiWidth) * 0.5;
         this.m_strangersBar.x = (param1.width - this.m_strangersBar.uiWidth) * 0.5;
         this.m_combatBar.x = (param1.width - this.m_combatBar.width) * 0.5 + COMBAT_BAR_X_OFFSET;
         if(this.m_hidden)
         {
            this.hide();
         }
         else
         {
            this.show();
         }
      }
      
      private function completeActiveTweens() : void
      {
         if(this.m_tweening)
         {
            TweenLite.killTweensOf(this.m_friendsBar,false);
            TweenLite.killTweensOf(this.m_strangersBar,false);
            TweenLite.killTweensOf(this.m_combatBar,false);
            this.onTweenEnd();
         }
      }
      
      private function tweeningStarted() : void
      {
         this.m_tweening = true;
         UIDispatcher.instance.dispatchEvent(new Event(TWEEN_START));
         var _loc1_:int = this.tweenDurationSeconds * 1000;
         Zlab.processManager.schedule(_loc1_,this,this.onTweenEnd);
      }
      
      private function onTweenEnd() : void
      {
         this.m_tweening = false;
         Zlab.processManager.removeScheduledObject(this);
         UIDispatcher.instance.dispatchEvent(new Event(TWEEN_END));
      }
      
      private function get tweenDurationSeconds() : Number
      {
         return m_tweenSeconds;
      }
      
      public function get viralNotificationContainer() : MovieClip
      {
         if(this.m_friendsBar.visible)
         {
            return this.m_friendsBar.viralNotificationContainer;
         }
         if(this.m_strangersBar.visible)
         {
            return this.m_strangersBar.viralNotificationContainer;
         }
         return null;
      }
   }
}

