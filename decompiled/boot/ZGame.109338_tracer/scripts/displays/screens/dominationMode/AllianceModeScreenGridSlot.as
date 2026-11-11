package displays.screens.dominationMode
{
   import Engine.Managers.TransactionManager;
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.managers.AlliancesManager;
   import core.managers.domination.DominationModeManager;
   import core.ui.Tooltip;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.AlarmCountdownClock;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.popups.alliancePopup.FBGroupPostPopup;
   import displays.screens.gridScreen.GridSlot;
   import fl.motion.AdjustColor;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.text.TextField;
   import transactions.clans.TBuyHealth;
   import transactions.clans.TUpdateTauntViewTime;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class AllianceModeScreenGridSlot extends GridSlot
   {
      
      private static const OWN_SLOT_HSBC:Array = [131,0,0,0];
      
      private static const CRUSHED_HSBC:Array = [-19,3,-53,0];
      
      private static const REVERT_HSBC:Array = [0,0,0,0];
      
      private var m_mc:MovieClip = null;
      
      private var m_data:Object = null;
      
      private var m_index:int = 0;
      
      private var m_addButton:ZGameButton = null;
      
      private var m_attackButton:ZGameButton = null;
      
      private var m_tauntButton:ZGameButton = null;
      
      private var m_isOwnClan:Boolean = this.isOwnClan();
      
      private var m_crest:ImageLoader = null;
      
      private var m_isRivalAllianceSlot:Boolean = false;
      
      private var m_isCurrentVictim:Boolean = this.isCurrentVictim();
      
      private var m_rivalCountdown:AlarmCountdownClock = null;
      
      public function AllianceModeScreenGridSlot(param1:SWFResource, param2:MovieClip, param3:int, param4:int, param5:Object, param6:int, param7:Boolean)
      {
         this.m_data = param5;
         this.m_index = param6;
         this.m_isRivalAllianceSlot = param7;
         super(param1,param2,null);
         slot.x = param3 * sizerWidth;
         slot.y = param4 * sizerHeight;
         if(this.m_isOwnClan)
         {
            AlliancesManager.instance.addEventListener(AlliancesManager.CLANS_ZLINGSHOT_MSG,this.onZlingshotUpdate);
         }
         AlliancesManager.instance.addEventListener(AlliancesManager.REFRESH_ALLIANCE_SLOT,this.refreshSlot);
      }
      
      override public function dispose() : void
      {
         if(this.m_addButton)
         {
            this.m_addButton.dispose();
            this.m_addButton = null;
         }
         if(this.m_attackButton)
         {
            this.m_attackButton.dispose();
            this.m_attackButton = null;
         }
         if(this.m_tauntButton)
         {
            this.m_tauntButton.dispose();
            this.m_tauntButton = null;
         }
         if(slot.AddToGroup_bt.visible == true)
         {
            slot.AddToGroup_bt.removeEventListener(MouseEvent.CLICK,this.postGroupFeed);
            slot.AddToGroup_bt = null;
         }
         this.clearEvents();
         this.cleanupRivalCountdown();
         super.dispose();
      }
      
      private function clearEvents() : void
      {
         AlliancesManager.instance.removeEventListener(AlliancesManager.CLANS_ZLINGSHOT_MSG,this.onZlingshotUpdate);
         AlliancesManager.instance.removeEventListener(AlliancesManager.REFRESH_ALLIANCE_SLOT,this.refreshSlot);
      }
      
      override protected function get className() : String
      {
         return "AllianceSlot_mc";
      }
      
      override protected function createSlot(param1:SWFResource) : MovieClip
      {
         var _loc2_:Class = param1.getAssetClass(this.className);
         return new _loc2_();
      }
      
      override public function disable() : void
      {
         if(this.m_attackButton)
         {
            this.m_attackButton.disable_visual();
         }
         if(this.m_addButton)
         {
            this.m_addButton.disable_visual();
         }
         if(this.m_tauntButton)
         {
            this.m_tauntButton.disable_visual();
         }
         super.disable();
      }
      
      override public function enable() : void
      {
         super.enable();
         super.setButtonMode(false);
         super.setUseHandCursor(false);
      }
      
      private function setupText() : void
      {
         var _loc3_:String = null;
         var _loc6_:Object = null;
         var _loc7_:Object = null;
         var _loc8_:Object = null;
         var _loc1_:int = int(this.m_data.numCrowns);
         TextFieldUtil.compactTextField(slot.rank_tf,_loc1_.toString());
         var _loc2_:String = ZGameUtils.ZlocTP("Dialogs","Alliance_Phase3_Member_title",{"Aname":this.m_data.name + " "});
         TextFieldUtil.compactTextField(slot.name_tf,_loc2_);
         if(slot.AddToGroup_bt)
         {
            slot.AddToGroup_bt.visible = false;
         }
         if(ZGlobal.player.uid == this.m_data.leader)
         {
            _loc3_ = ZGlobal.player.firstName;
         }
         else if(Boolean(this.m_data) && Boolean(this.m_data.leaderName))
         {
            _loc3_ = this.m_data.leaderName;
         }
         else if(this.m_isOwnClan)
         {
            _loc6_ = AlliancesManager.instance.memberInfo(AlliancesManager.instance.leaderId);
            if(_loc6_)
            {
               _loc3_ = _loc6_.name;
            }
            else
            {
               _loc3_ = "Timon & Pumba";
            }
         }
         else
         {
            _loc3_ = "Timon & Pumba";
         }
         var _loc4_:String = ZGameUtils.ZlocT("Dialogs","Alliance4WorldDomination_LabelLeader",{"lName":_loc3_});
         TextFieldUtil.compactTextField(slot.leader_tf,_loc4_);
         var _loc5_:int = this.m_data.health ? int(this.m_data.health) : 0;
         TextFieldUtil.compactTextField(slot.strength_mc.strength_tf,_loc5_.toString());
         if(this.m_isOwnClan)
         {
            slot.header_tf.visible = slot.points_tf.visible = slot.bonus_mc.visible = false;
         }
         else
         {
            _loc7_ = AlliancesManager.instance.getBattleDominationScore(this.m_data.members.length,this.m_data.health,this.m_data.max_health);
            TextFieldUtil.compactTextField(slot.header_tf,ZGameUtils.ZlocT("Dialogs","DominationRewardHeader"));
            if(this.m_data.bonus)
            {
               _loc7_["totalBonus"] = this.m_data.bonus;
            }
            else if(Boolean(this.m_data.totalBonus) && Boolean(this.m_data.totalBonus.totalBonus))
            {
               _loc7_["totalBonus"] = this.m_data.totalBonus.totalBonus.toString();
            }
            TextFieldUtil.compactTextField(slot.points_tf,_loc7_["totalBonus"].toString());
            _loc8_ = DominationModeManager.instance.getAllianceInfo(this.m_data.id);
            _loc8_.totalBonus = _loc7_;
            if(this.m_isRivalAllianceSlot)
            {
               TextFieldUtil.compactTextField(slot.bonus_mc.bonus_tf,ZGameUtils.ZlocT("Dialogs","Alliance4WorldDomination_RevengeBonus",{"x":AlliancesManager.REVENGE_BONUS}));
               TextFieldUtil.compactTextField(slot.waitinfo_tf,ZGameUtils.ZlocT("Dialogs","DominationRivalWaitLabel"));
            }
            else
            {
               slot.bonus_mc.visible = false;
            }
         }
      }
      
      private function showMemberIcons() : void
      {
         var _loc1_:int = int(this.m_data.members.length);
         slot.member0.visible = true;
         TextFieldUtil.compactTextField(slot.members_tf,"x" + _loc1_.toString());
      }
      
      private function setupRivalCountdown(param1:int, param2:int) : void
      {
         this.cleanupRivalCountdown();
         this.m_rivalCountdown = new AlarmCountdownClock(slot.clock_mc,param1 + param2);
         this.m_rivalCountdown.alarm.addEventListener(AlarmCountdownClock.TIMER_EXPIRED,this.onRivalCountdownEnd);
      }
      
      private function cleanupRivalCountdown() : void
      {
         if(this.m_rivalCountdown)
         {
            this.m_rivalCountdown.alarm.removeEventListener(AlarmCountdownClock.TIMER_EXPIRED,this.onRivalCountdownEnd);
            this.m_rivalCountdown = null;
         }
      }
      
      private function onRivalCountdownEnd(param1:Event) : void
      {
         this.cleanupRivalCountdown();
      }
      
      private function setBuyHealthButton() : void
      {
         var _loc1_:int = int(this.m_data.health);
         if(!this.m_addButton)
         {
            this.m_addButton = new ZGameButton(slot.add_bt,this.onClickHealthBuy);
         }
         if(!(this.m_isOwnClan && _loc1_ < AlliancesManager.instance.maxHealth * AlliancesManager.HEALTH_BUY_THRESHOLD))
         {
            this.m_addButton.hide();
         }
      }
      
      private function setAttackButton() : void
      {
         if(!this.m_attackButton)
         {
            this.m_attackButton = new ZGameButton(slot.attack_bt,this.onClickAttack);
         }
         if(this.m_isCurrentVictim)
         {
            this.m_attackButton.text = ZGameUtils.ZlocT("Dialogs","DominationContinue");
         }
         else if(this.m_isRivalAllianceSlot)
         {
            this.m_attackButton.text = ZGameUtils.ZlocT("Dialogs","DominationRevenge");
         }
         else
         {
            this.m_attackButton.text = ZGameUtils.ZlocT("Dialogs","DominationAttack");
         }
         if(this.m_isOwnClan)
         {
            this.m_attackButton.hide();
         }
         else if(this.m_data.health <= AlliancesManager.ATTACK_HEALTH_THRESHOLD && !this.m_isCurrentVictim)
         {
            this.m_attackButton.disable_visual();
         }
      }
      
      private function setCrushedVisual() : void
      {
         TextFieldUtil.compactTextField(slot.crushed_tf,ZGameUtils.ZlocT("Dialogs","Alliance4WorldDomination_LabelCrushed"));
         if(this.m_data.health > 0)
         {
            slot.crushed_tf.visible = false;
         }
         else
         {
            this.changeColor(slot.strength_mc,CRUSHED_HSBC);
         }
      }
      
      private function setHealthBarVisual() : void
      {
         var _loc1_:Number = slot.strength_mc.width * (1 * this.m_data.health / this.m_data.max_health);
         _loc1_ = _loc1_ > 5 ? _loc1_ : 5;
         TweenLite.to(slot.strength_mc.mask_mc,0,{"width":_loc1_});
      }
      
      private function setCrestIcon() : void
      {
         this.m_crest = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(AlliancesManager.instance.getPath(this.m_data.crestId,48)),slot.icon);
      }
      
      private function refreshSlot(param1:WorldEvent) : void
      {
         if(!param1 || !param1.eventData)
         {
            return;
         }
         if(param1.eventData == "taunt" && this.m_isRivalAllianceSlot)
         {
            this.setupTauntButton();
         }
      }
      
      override protected function onSlotCreated() : void
      {
         this.setCrestIcon();
         this.setupText();
         this.showMemberIcons();
         this.setBuyHealthButton();
         this.setAttackButton();
         this.setHealthBarVisual();
         this.setCrushedVisual();
         if(this.m_isOwnClan)
         {
            this.changeColor(slot.alliancebg_mc,OWN_SLOT_HSBC);
         }
         this.showRivalSpecificElements();
      }
      
      private function showRivalSpecificElements() : void
      {
         var _loc1_:int = 0;
         if(this.m_isRivalAllianceSlot)
         {
            _loc1_ = int(this.m_data.status);
            if(_loc1_ == DominationModeManager.DOM_VICTIMSTATUS_WAITING)
            {
               slot.clock_mc.visible = false;
               this.m_attackButton.hide();
               slot.waitinfo_tf.visible = true;
               slot.header_tf.visible = false;
               slot.points_tf.visible = false;
               slot.bonus_mc.bonus_tf.visible = false;
               slot.AddToGroup_bt.visible = false;
            }
            else
            {
               this.m_attackButton.show();
               if(AlliancesManager.instance.fbGroupCreated)
               {
                  slot.AddToGroup_bt.visible = true;
                  Tooltip.subscribe(slot.AddToGroup_bt,ZGameUtils.ZlocT("Dialogs","GroupPostPopupHeader"),null,true);
                  slot.AddToGroup_bt.addEventListener(MouseEvent.CLICK,this.postGroupFeed);
               }
               slot.waitinfo_tf.visible = false;
            }
            this.setupTauntButton();
         }
         else
         {
            slot.clock_mc.visible = false;
            slot.waitinfo_tf.visible = false;
            slot.message_bt.visible = false;
         }
         slot.clock_mc.visible = false;
      }
      
      private function setupTauntButton() : void
      {
         if(!this.m_tauntButton)
         {
            slot.message_bt.generic_tf = new TextField();
            this.m_tauntButton = new ZGameButton(slot.message_bt,this.onClickTaunt);
         }
         var _loc1_:Number = AlliancesManager.instance.tauntViewTime;
         var _loc2_:Boolean = this.m_data.taunt_ts > _loc1_ && this.m_data.taunt != "";
         slot.message_bt.new_mc.visible = _loc2_;
         var _loc3_:String = _loc2_ ? "DominanceNewMessageTooltip" : "DominanceChatButtonTooltip";
         this.m_tauntButton.addTooltip(ZGameUtils.ZlocT("Dialogs",_loc3_),DominationModeManager.instance.tooltipOptions);
      }
      
      private function onClickTaunt(param1:MouseEvent) : void
      {
         if(slot.message_bt.new_mc.visible)
         {
            AlliancesManager.instance.updateTauntViewTime();
            TransactionManager.addTransaction(new TUpdateTauntViewTime(),true);
            AlliancesManager.instance.dispatchEvent(new WorldEvent(AlliancesManager.REFRESH_ALLIANCE_SLOT,"taunt"));
         }
         var _loc2_:Object = new Object();
         var _loc3_:Array = new Array();
         _loc2_["msg"] = this.m_data.taunt;
         _loc2_["ts"] = this.m_data.ts;
         _loc2_["name"] = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Member_title",{"Aname":this.m_data.name});
         if(_loc2_["msg"] != "")
         {
            _loc3_.push(_loc2_);
         }
         PopupManager.instance.push(new DominationModeChatHistoryScreen(null,_loc3_,"",true),0,false);
      }
      
      private function onClickHealthBuy(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:GenericPopup = null;
         if(this.m_isOwnClan && AlliancesManager.instance.healthBelowThreshold())
         {
            _loc2_ = AlliancesManager.instance.healthPrice();
            _loc3_ = ZGameUtils.ZlocT("Dialogs","Alliance4HealthPurchasePopup",{"x":_loc2_});
            _loc4_ = "";
            _loc5_ = GenericPopup2B.NewYesNo(_loc3_,_loc4_,this.onHealthBuyConfirm);
            PopupManager.instance.push(_loc5_,0,false);
         }
      }
      
      private function onHealthBuyConfirm(param1:GenericPopupEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:TBuyHealth = null;
         if(param1.button == GenericPopup.YES && slot != null)
         {
            _loc2_ = AlliancesManager.instance.healthPrice();
            if(ZGlobal.player.canBuyCash(_loc2_,true,"",false))
            {
               _loc3_ = new TBuyHealth();
               TransactionManager.addTransaction(_loc3_,true);
               ZGlobal.player.cash -= _loc2_;
               AlliancesManager.instance.giveMaxHealth();
               TextFieldUtil.compactTextField(slot.strength_mc.strength_tf,AlliancesManager.instance.maxHealth.toString());
               this.m_data.health = AlliancesManager.instance.currentHealth;
               if(slot.crushed_tf.visible)
               {
                  slot.crushed_tf.visible = false;
                  this.changeColor(slot.strength_mc,REVERT_HSBC);
               }
               this.setHealthBarVisual();
               this.m_addButton.hide();
            }
         }
      }
      
      private function postGroupFeed(param1:Event) : void
      {
         var _loc2_:String = ZGameUtils.ZlocT("Dialogs","GroupRevengePostBody",{
            "x":ZGlobal.player.name,
            "y":this.m_data.name
         });
         PopupManager.instance.push(new FBGroupPostPopup(AlliancesManager.instance.clanName,_loc2_,"revenge"),0,false);
      }
      
      private function onClickAttack(param1:MouseEvent) : void
      {
         var _loc2_:String = AlliancesManager.instance.loadNextMember(null,this.m_data.id);
         if(DominationModeManager.instance.hasDefenceForceFleet(_loc2_))
         {
            AlliancesManager.instance.battleAllianceName = this.m_data.id;
            DominationModeManager.instance.dispatchEvent(new Event(DominationModeManager.FIGHT_LIST_TARGET_SELECTED));
            AlliancesManager.instance.loadBattle(null,_loc2_,this.m_data.id);
         }
      }
      
      private function isOwnClan() : Boolean
      {
         return this.m_data.id == AlliancesManager.instance.clanId;
      }
      
      private function changeColor(param1:MovieClip, param2:Array) : void
      {
         var _loc4_:ColorMatrixFilter = null;
         var _loc3_:AdjustColor = new AdjustColor();
         var _loc5_:Array = [];
         _loc3_.hue = param2[0];
         _loc3_.saturation = param2[1];
         _loc3_.brightness = param2[2];
         _loc3_.contrast = param2[3];
         _loc5_ = _loc3_.CalculateFinalFlatArray();
         _loc4_ = new ColorMatrixFilter(_loc5_);
         param1.filters = [_loc4_];
      }
      
      private function onZlingshotUpdate(param1:WorldEvent) : void
      {
         if(!param1 || !param1.eventData)
         {
            return;
         }
         this.m_data = AlliancesManager.instance.getAllianceInfo();
         if(param1.eventData == "clan.updateName")
         {
            this.setupText();
         }
         else if(param1.eventData == "clan.updateCrest")
         {
            this.setCrestIcon();
         }
         else if(param1.eventData == "clan.gotKicked")
         {
            this.clearEvents();
         }
         else if(param1.eventData == "clan.healthUpdate")
         {
            this.setupText();
            this.setBuyHealthButton();
            this.setHealthBarVisual();
         }
         else
         {
            this.onSlotCreated();
         }
      }
      
      public function get allianceID() : String
      {
         return this.m_data.id;
      }
      
      private function isCurrentVictim() : Boolean
      {
         return AlliancesManager.instance.allianceBattleInProgress() == this.m_data.id;
      }
   }
}

