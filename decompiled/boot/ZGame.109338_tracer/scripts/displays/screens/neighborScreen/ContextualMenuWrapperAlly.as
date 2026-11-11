package displays.screens.neighborScreen
{
   import core.ZGlobal;
   import core.managers.AlliancesManager;
   import core.managers.ChallengeModeManager;
   import core.managers.ExperimentsManager;
   import core.managers.PVPManager;
   import core.managers.WorldResourceManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.ui.Tooltip;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.ReactivationGiftPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zgame.assets.ui.FriendBar.ContextualMenu2;
   import zlabs.Zlab;
   
   public class ContextualMenuWrapperAlly extends ContextualMenuWrapperAttack
   {
      
      private static var DEBUGCONTEXT_VISIT_ONLY:String = "VisitOnlyPane";
      
      private static var DEBUGCONTEXT_ICON:String = "IconPane";
      
      private static var DEBUGCONTEXT_MESSAGE:String = "MessagePane";
      
      private static var DEBUGCONTEXT_ATTACK:String = "AttackPane";
      
      private static var DEBUGCONTEXT_DISABLED:String = "DisabledPane";
      
      private static var CONTEXT_PORTION_HEIGHT_ADJUST:int = 10;
      
      private var m_button1:ZGameButton;
      
      private var m_button2:ZGameButton;
      
      private var m_pane:MovieClip;
      
      private var m_iconLoader:ImageLoader = null;
      
      private var m_debugContext:String;
      
      public function ContextualMenuWrapperAlly(param1:NeighborSlot, param2:UserGrid)
      {
         var _loc5_:int = 0;
         var _loc6_:String = null;
         super(param1,param2,ContextualMenu2);
         this.setupTextLink(mc.sendGift,ZGameUtils.ZlocT("Main","ContextMenuSendGiftButton"));
         this.setupTextLink(mc.requestMetal,ZGameUtils.ZlocT("Main","ContextMenuRequestMetalButton"));
         var _loc3_:Object = PVPManager.instance.getPlayerInvasionInfoForNeighbor(uid);
         if(Boolean(_loc3_) && (_loc3_.status == PVPManager.STATUS_OCCUPIED || _loc3_.status == PVPManager.STATUS_INCOMBAT))
         {
            mc.market.filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
            TextFieldUtil.processTextField(mc.market.generic_tf,ZGameUtils.ZlocT("Main","ContextMenuMarketButton"));
         }
         else
         {
            this.setupTextLink(mc.market,ZGameUtils.ZlocT("Main","ContextMenuMarketButton"));
         }
         var _loc4_:Object = ZGlobal.player.neighbors[uid];
         if(_loc4_)
         {
            _loc5_ = int(_loc4_.resource);
            _loc6_ = WorldResourceManager.instance.getResourceImageURL(_loc5_,WorldResourceManager.SMALL_ICON);
            this.m_iconLoader = ImageLoaderFactory.CreateImageLoader(_loc6_,mc.requestMetal.icon);
            this.m_iconLoader.smooth = true;
         }
         if(!ZGlobal.isVisiting() || ZGlobal.hostPlayer.uid != mc.neighborSlot.uid)
         {
            if(mc.shield_bt)
            {
               mc.shield_bt.visible = false;
            }
            if(mc.icon)
            {
               mc.icon.visible = false;
            }
            this.setupContextSensitivePanes(uid);
         }
      }
      
      override protected function onDispose() : void
      {
         super.onDispose();
         if(this.m_button1)
         {
            this.m_button1.dispose();
            this.m_button1 = null;
         }
         if(this.m_button2)
         {
            this.m_button2.dispose();
            this.m_button2 = null;
         }
         if(this.m_pane)
         {
            if(this.m_pane.icon)
            {
               Tooltip.unsubscribe(this.m_pane.icon);
            }
            this.m_pane.parent.removeChild(this.m_pane);
            this.m_pane = null;
         }
         if(this.m_iconLoader)
         {
            this.m_iconLoader.destroy();
         }
         this.m_iconLoader = null;
         Zlab.processManager.removeScheduledObject(this);
      }
      
      override protected function getDebugContext() : String
      {
         return this.m_debugContext;
      }
      
      private function setupTextLink(param1:MovieClip, param2:String) : void
      {
         TextFieldUtil.processTextField(param1.generic_tf,param2);
         param1.addEventListener(MouseEvent.MOUSE_OVER,this.onTextLinkMouseOver,false,0,true);
         param1.addEventListener(MouseEvent.MOUSE_OUT,this.onTextLinksMouseOut,false,0,true);
         param1.addEventListener(MouseEvent.MOUSE_UP,this.onTextLinkMouseUp,false,0,true);
      }
      
      private function onTextLinkMouseOver(param1:MouseEvent) : void
      {
         if(param1.currentTarget.icon)
         {
            param1.currentTarget.icon.scaleX = 1.25;
            param1.currentTarget.icon.scaleY = 1.25;
            param1.currentTarget.icon.x = -4;
         }
         else
         {
            param1.currentTarget.gotoAndStop(2);
         }
      }
      
      private function onTextLinksMouseOut(param1:MouseEvent) : void
      {
         if(param1.currentTarget.icon)
         {
            param1.currentTarget.icon.scaleX = 1;
            param1.currentTarget.icon.scaleY = 1;
            param1.currentTarget.icon.x = 0;
         }
         else
         {
            param1.currentTarget.gotoAndStop(1);
         }
      }
      
      private function onTextLinkMouseUp(param1:MouseEvent) : void
      {
         if(param1.currentTarget == mc.sendGift)
         {
            grid.onGiftClick(mc.neighborSlot);
         }
         else if(ZGlobal.neighborReactivationNeeded(uid))
         {
            ReactivationGiftPopup.show(uid);
         }
         else if(param1.currentTarget == mc.requestMetal)
         {
            grid.onRequestResourceClick(mc.neighborSlot);
         }
         else if(param1.currentTarget == mc.market)
         {
            if(TutorialManager.instance.neighborBarEnabled)
            {
               grid.onMarketClick(mc.neighborSlot);
            }
            else
            {
               TutorialManager.instance.showInvalidVisitPopup();
            }
         }
      }
      
      private function getRemainingPillageTime(param1:int) : int
      {
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_PILLAGE_TIME_EXTEND) == ExperimentsManager.VARIANT_PILLAGE_TIME_EXTEND_ENABLED)
         {
            param1 += ZGlobal.gameSettings.getInt("PVPPillageCooldown") * ZGlobal.gameSettings.getInt("PVPPillageScalar");
         }
         else
         {
            param1 += ZGlobal.gameSettings.getInt("PVPPillageCooldown");
         }
         var _loc2_:int = GlobalEngine.serverTime / 1000;
         return int(Math.max(param1 - _loc2_,0));
      }
      
      private function updatePillageCooldownPane() : void
      {
         var _loc1_:Object = PVPManager.instance.getPlayerInvasionInfoForNeighbor(uid);
         var _loc2_:int = this.getRemainingPillageTime(_loc1_.pillTS);
         var _loc3_:String = ZGameTimeUtil.instance.getClockString(_loc2_,true);
         this.m_pane.timer_tf.text = _loc3_;
         if(_loc2_)
         {
            Zlab.processManager.schedule(1000,this,this.updatePillageCooldownPane);
            if(this.m_button1.enabled)
            {
               this.m_button1.disable_visual();
            }
         }
         else if(!this.m_button1.enabled)
         {
            this.m_button1.enable();
         }
      }
      
      private function setupRetalCooldownPane() : void
      {
         var _loc1_:String = ZGlobal.gameSettings.getString("PVPUIFriendBarCooldownIcon");
         this.setupIconContextMenuPane("ContextMenuFriendCooling",_loc1_,"ContextMenuCooldownIconTooltip",this.onRetalCooldownIconRollOver,this.onRetalCooldownIconRollOut);
      }
      
      private function setupVisitOnlyPane() : void
      {
         this.createAndPositionPane(contextual1_mc);
         this.m_debugContext = DEBUGCONTEXT_VISIT_ONLY;
         this.m_button1 = new ZGameButton(this.m_pane.orangeButton_01,onVisitClick,1);
         this.m_button1.text = ZGameUtils.ZlocT("Main","ContextMenuVisitButton");
         buttonSounds.addButton(this.m_button1.m_overlay,ButtonSound.DEFAULT);
      }
      
      private function setupIconContextMenuPane(param1:String, param2:String, param3:String, param4:Function = null, param5:Function = null) : void
      {
         this.createAndPositionPane(contextual5_mc);
         this.m_debugContext = DEBUGCONTEXT_ICON + "_" + param1;
         this.m_button1 = new ZGameButton(this.m_pane.orangeButton_01,onVisitClick,1);
         this.m_button1.text = ZGameUtils.ZlocT("Main","ContextMenuVisitButton");
         buttonSounds.addButton(this.m_button1.m_overlay,ButtonSound.DEFAULT);
         var _loc6_:String = ZGlobal.getAssetURL(param2);
         ImageLoaderFactory.CreateImageLoader(_loc6_,this.m_pane.icon);
         Tooltip.subscribe(this.m_pane.icon,ZGameUtils.ZlocT("Main",param3));
         if(param4 != null)
         {
            this.m_pane.icon.addEventListener(MouseEvent.ROLL_OVER,param4,false,0,true);
         }
         if(param5 != null)
         {
            this.m_pane.icon.addEventListener(MouseEvent.ROLL_OUT,param5,false,0,true);
         }
         var _loc7_:String = ZGameUtils.ZlocT("Main",param1);
         TextFieldUtil.processTextField(this.m_pane.generic_tf,_loc7_);
      }
      
      private function setupNeighborImmunePane() : void
      {
         var _loc1_:String = ZGlobal.gameSettings.getString("PVPUIFriendBarImmuneIcon");
         this.setupIconContextMenuPane("ContextMenuFriendImmune",_loc1_,"ContextMenuImmunityIconTooltip");
      }
      
      private function setupSingleMessageVisitPane(param1:String) : void
      {
         this.createAndPositionPane(contextual3_mc);
         this.m_debugContext = DEBUGCONTEXT_MESSAGE;
         this.m_button1 = new ZGameButton(this.m_pane.orangeButton_01,onVisitClick,1);
         this.m_button1.text = ZGameUtils.ZlocT("Main","ContextMenuVisitButton");
         buttonSounds.addButton(this.m_button1.m_overlay,ButtonSound.DEFAULT);
         TextFieldUtil.compactTextField(this.m_pane.generic_tf,param1,{
            "maxLines":4,
            "minScale":0.6,
            "onFail":"return"
         });
      }
      
      private function setupTooManyOccupiersPane() : void
      {
         var _loc1_:String = ZGameUtils.ZlocT("Main","ContextMenuTooManyNeighborOccupiers");
         this.setupSingleMessageVisitPane(_loc1_);
      }
      
      private function setupContinueInvasionPane() : void
      {
         if(ZGlobal.neighborReactivationNeeded(uid))
         {
            ReactivationGiftPopup.show(uid);
            return;
         }
         continueInvasion = true;
         this.createAndPositionPane(contextual6_mc);
         this.m_button1 = new ZGameButton(this.m_pane.redButton_01,onAttackClick,1);
         this.m_button1.text = ZGameUtils.ZlocT("Main","ContextMenuContinueAttackButton");
         buttonSounds.addButton(this.m_button1.m_overlay,ButtonSound.DEFAULT);
      }
      
      private function setUpAttackPane() : void
      {
         this.createAndPositionPane(contextual2_mc);
         this.m_debugContext = DEBUGCONTEXT_ATTACK;
         this.m_button1 = new ZGameButton(this.m_pane.orangeButton_01,onVisitClick,1);
         this.m_button1.text = ZGameUtils.ZlocT("Main","ContextMenuVisitButton");
         buttonSounds.addButton(this.m_button1.m_overlay,ButtonSound.DEFAULT);
         this.m_button2 = new ZGameButton(this.m_pane.redButton_01,onAttackClick,1);
         this.m_button2.text = ZGameUtils.ZlocT("Main","ContextMenuAttackButton");
         buttonSounds.addButton(this.m_button2.m_overlay,ButtonSound.DEFAULT);
      }
      
      private function setUpPillagePane() : void
      {
         this.createAndPositionPane(contextual4_mc);
         this.m_button1 = new ZGameButton(this.m_pane.orangeButton_01,this.onPillageClick,1);
         this.m_button1.text = ZGameUtils.ZlocT("Main","ContextMenuPillageButton");
         buttonSounds.addButton(this.m_button1.m_overlay,ButtonSound.DEFAULT);
         TextFieldUtil.processTextField(this.m_pane.generic_tf,ZGameUtils.ZlocT("Main","ContextMenuPillageCooldownLabel"));
         this.updatePillageCooldownPane();
      }
      
      private function createAndPositionPane(param1:Class) : void
      {
         this.m_pane = new param1();
         mc.addChild(this.m_pane);
         this.m_pane.x = mc.anchor.x;
         this.m_pane.y = mc.anchor.y;
         mc.frame.height += this.m_pane.height + CONTEXT_PORTION_HEIGHT_ADJUST;
      }
      
      private function onPillageClick(param1:MouseEvent) : void
      {
         if(ZGlobal.neighborReactivationNeeded(uid))
         {
            ReactivationGiftPopup.show(uid);
         }
         else
         {
            grid.onPillageClick(mc.neighborSlot);
         }
      }
      
      private function canPillage(param1:Object) : Boolean
      {
         return param1.status == PVPManager.STATUS_OCCUPIED && !param1.pillTS;
      }
      
      private function setupDisabledInvadeButton(param1:String) : void
      {
         this.createAndPositionPane(contextual2_mc);
         this.m_debugContext = DEBUGCONTEXT_DISABLED + "_" + param1;
         this.m_button1 = new ZGameButton(this.m_pane.orangeButton_01,onVisitClick,1);
         this.m_button1.text = ZGameUtils.ZlocT("Main","ContextMenuVisitButton");
         buttonSounds.addButton(this.m_button1.m_overlay,ButtonSound.DEFAULT);
         var _loc2_:MovieClip = this.m_pane.redButton_01;
         if(_loc2_.totalFrames >= 5)
         {
            _loc2_.gotoAndStop(5);
         }
         TextFieldUtil.processTextField(_loc2_.generic_tf,ZGameUtils.ZlocT("Main","ContextMenuAttackButton"));
         Tooltip.subscribe(_loc2_,ZGameUtils.ZlocT("Main",param1,{"level":PVPManager.pvpMinLevel}));
      }
      
      private function setupContextSensitivePanes(param1:String) : void
      {
         if(!PVPManager.canLevelParticipate(ZGlobal.player.level))
         {
            this.setupDisabledInvadeButton("ContextMenuAttackerLevelRestricted");
            return;
         }
         if(!PVPManager.canLevelParticipate(ZGlobal.player.neighbors[param1].level))
         {
            this.setupDisabledInvadeButton("ContextMenuVictimLevelRestricted");
            return;
         }
         var _loc2_:Object = PVPManager.instance.getPlayerInvasionInfoForNeighbor(param1);
         if(_loc2_)
         {
            if(_loc2_.status == PVPManager.STATUS_RETAL_COOLDOWN)
            {
               this.setupRetalCooldownPane();
               return;
            }
            if(_loc2_.status == PVPManager.STATUS_AVAILABLE || _loc2_.status == PVPManager.STATUS_INCOMBAT)
            {
               if(_loc2_.status == PVPManager.STATUS_AVAILABLE && PVPManager.instance.isNeighborImmune(param1))
               {
                  this.setupNeighborImmunePane();
                  return;
               }
               if(PVPManager.instance.neighborOccupiersExceeded(param1))
               {
                  this.setupTooManyOccupiersPane();
                  return;
               }
               if(_loc2_.status == PVPManager.STATUS_INCOMBAT)
               {
                  this.setupContinueInvasionPane();
               }
               else
               {
                  this.setUpAttackPane();
               }
               return;
            }
            if(_loc2_.status == PVPManager.STATUS_OCCUPIED)
            {
               this.setUpPillagePane();
               return;
            }
            this.setupVisitOnlyPane();
            return;
         }
         if(PVPManager.instance.isNeighborImmune(param1))
         {
            this.setupNeighborImmunePane();
            return;
         }
         if(PVPManager.instance.neighborOccupiersExceeded(param1))
         {
            this.setupTooManyOccupiersPane();
            return;
         }
         this.setUpAttackPane();
      }
      
      private function onContinueAttack(param1:MouseEvent) : void
      {
         ChallengeModeManager.instance.onSelectNewChallengePlayer(ZGlobal.hostPlayer.uid);
      }
      
      private function get cooldownTooltipString() : String
      {
         var _loc1_:String = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc2_:Object = PVPManager.instance.getPlayerInvasionInfoForNeighbor(uid);
         if(_loc2_)
         {
            _loc3_ = GlobalEngine.serverTime / 1000;
            _loc4_ = _loc2_.ts + ZGlobal.gameSettings.getInt("PVPRetaliationCooldown",600);
            if(_loc2_.status == PVPManager.STATUS_RETAL_COOLDOWN && _loc4_ > _loc3_)
            {
               _loc5_ = _loc4_ - _loc3_;
               _loc6_ = ZGameTimeUtil.instance.getTimeString(_loc5_);
               return ZGameUtils.ZlocT("Main","ContextMenuCooldownIconTimerTooltip",{"time":_loc6_});
            }
         }
         return ZGameUtils.ZlocT("Main","ContextMenuCooldownIconTooltip");
      }
      
      private function onRetalCooldownIconRollOver(param1:MouseEvent) : void
      {
         Tooltip.show(this.cooldownTooltipString,null,this.m_pane.icon);
         Zlab.processManager.schedule(1000,this,this.updateCooldownTooltip);
      }
      
      private function onRetalCooldownIconRollOut(param1:MouseEvent) : void
      {
         if(Tooltip.isCurrDisplayObject(this.m_pane.icon))
         {
            Tooltip.hide();
         }
         Zlab.processManager.removeScheduledObject(this);
      }
      
      private function updateCooldownTooltip() : void
      {
         if(Tooltip.getInstance().visible)
         {
            Tooltip.getInstance().setCurrentProps(this.cooldownTooltipString,null,this.m_pane.icon);
            Tooltip.getInstance().updateText();
         }
         Zlab.processManager.schedule(1000,this,this.updateCooldownTooltip);
      }
      
      private function setupContextAlliancePane(param1:String) : void
      {
         var _loc2_:ZGameButton = null;
         var _loc3_:ZGameButton = null;
         var _loc4_:ZGameButton = null;
         var _loc5_:ZGameButton = null;
         mc.shield_bt.visible = false;
         mc.icon.visible = false;
         if(AlliancesManager.isValid() && AlliancesManager.instance.isValidNeighbor(ZGlobal.player.neighbors[param1]))
         {
            if(Boolean(ZGlobal.player.neighbors[param1].clanId) && Boolean(ZGlobal.player.neighbors[param1].canAddMembers))
            {
               _loc2_ = new ZGameButton(mc.shield_bt,this.onAllianceJoin,1);
               _loc2_.text = ZGameUtils.ZlocT("Main","ContextMenuAllianceJoin");
               mc.frame.height += 25;
               mc.shield_bt.visible = true;
               mc.icon.visible = true;
               this.allianceClanIconLoad(ZGlobal.player.neighbors[param1]);
            }
            else if(!ZGlobal.player.neighbors[param1].clanId || !ZGlobal.player.neighbors[param1].canAddMembers)
            {
               if(!ZGlobal.player.neighbors[param1].clanId && AlliancesManager.instance.canShowInvite())
               {
                  _loc3_ = new ZGameButton(mc.shield_bt,this.onAllianceInvite,1);
                  _loc3_.text = ZGameUtils.ZlocT("Main","ContextMenuAllianceInvite");
                  mc.frame.height += 25;
                  mc.shield_bt.visible = true;
                  mc.icon.visible = true;
                  this.allianceClanIconLoad(ZGlobal.player.neighbors[param1]);
               }
               else
               {
                  _loc4_ = new ZGameButton(mc.shield_bt,this.onAllianceFull,1);
                  _loc4_.disable_visual(true);
                  _loc4_.text = ZGameUtils.ZlocT("Main","ContextMenuAllianceFull");
                  mc.frame.height += 25;
                  mc.shield_bt.visible = true;
                  mc.icon.visible = true;
                  this.allianceClanIconLoad(ZGlobal.player.neighbors[param1]);
               }
            }
         }
         else if(AlliancesManager.isValid() && !AlliancesManager.instance.isValidNeighbor(ZGlobal.player.neighbors[param1]))
         {
            _loc5_ = new ZGameButton(mc.shield_bt,this.onAllianceFull,1);
            _loc5_.disable_visual(true);
            _loc5_.text = ZGameUtils.ZlocT("Main","ContextMenuAllianceLocked");
            mc.frame.height += 25;
            mc.shield_bt.visible = true;
            mc.icon.visible = true;
            this.allianceClanIconLoad(ZGlobal.player.neighbors[param1]);
         }
      }
      
      private function allianceClanIconLoad(param1:Object) : void
      {
         var _loc2_:int = 0;
         if(!param1.crestId)
         {
            _loc2_ = AlliancesManager.instance.crestId;
         }
         else
         {
            _loc2_ = int(param1.crestId);
         }
         var _loc3_:String = AlliancesManager.instance.getPath(_loc2_,48);
         _loc3_ = ZGlobal.getAssetURL(_loc3_);
         ImageLoaderFactory.CreateImageLoader(_loc3_,mc.icon);
      }
      
      private function onAllianceFull(param1:MouseEvent) : void
      {
      }
      
      private function onAllianceInvite(param1:MouseEvent) : void
      {
         grid.onAllianceClick(mc.neighborSlot);
      }
      
      private function onAllianceJoin(param1:MouseEvent) : void
      {
         grid.onAllianceJoinClick(mc.neighborSlot);
      }
   }
}

