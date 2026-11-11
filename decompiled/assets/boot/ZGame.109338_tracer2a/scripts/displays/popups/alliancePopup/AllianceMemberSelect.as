package displays.popups.alliancePopup
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.AlliancesManager;
   import core.managers.ExperimentsManager;
   import core.managers.MatchMakingManager;
   import core.managers.PVPManager;
   import core.managers.WorldResourceManager;
   import core.managers.domination.DominationModeManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.managers.viralsManager.ViralsManager;
   import core.player.Player;
   import core.ui.Tooltip;
   import core.ui.ZGameButton;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.FeedPopup;
   import displays.popups.GallantPopup;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.popups.ReactivationGiftPopup;
   import displays.popups.SpeechPopup;
   import displays.screens.requests.RequestAllianceInviteDialog;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import transactions.TWorldLoad;
   import transactions.clans.TBuyHealth;
   import transactions.clans.TBuySlot;
   import transactions.clans.TRemoveMember;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zgame.assets.ui.FriendBar.ContextualMenu2;
   import zgame.assets.ui.FriendBar.FriendBarMenu;
   import zlabs.Zlab;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class AllianceMemberSelect extends GallantPopup
   {
      
      protected var m_displayObject:FriendBarMenu;
      
      protected var m_xadjusted:Number;
      
      protected var m_yadjusted:Number;
      
      private var m_crest:ImageLoader;
      
      private var m_okbutton:ZGameButton = null;
      
      private var m_addpopup:GenericPopup;
      
      private var m_removepopup:GenericPopup;
      
      private var m_invitepopup:GenericPopup;
      
      private var m_contextMenu:MovieClip = null;
      
      private var m_allianceManager:AlliancesManager = AlliancesManager.instance;
      
      private var m_selectbutton:ZGameButton = null;
      
      private var m_infobutton:ZGameButton = null;
      
      private var m_addbutton:ZGameButton = null;
      
      private var m_matchbutton:ZGameButton = null;
      
      private var m_abdbutton:ZGameButton = null;
      
      private var m_battleButton:ZGameButton = null;
      
      private var m_postGroupFeed:ZGameButton = null;
      
      private var m_rightbutton:ZGameButton = null;
      
      private var m_leftbutton:ZGameButton = null;
      
      private var m_rightJumpButton:ZGameButton = null;
      
      private var m_leftJumpButton:ZGameButton = null;
      
      private var m_cardAddButtons:Array = null;
      
      private var m_cardKickButtons:Array = null;
      
      private var m_cardImage:Array = null;
      
      private var m_healthButton:ZGameButton = null;
      
      private var m_members:Array = [];
      
      private var m_startslot:int = 0;
      
      public const MAX_SLOTS:int = 5;
      
      public const MAX_SLOTS_LIMIT:int = 10;
      
      private const SLOT_COST:String = "20";
      
      private var m_callbackFBar:Function = null;
      
      private var m_buttons:Array = [];
      
      public function AllianceMemberSelect(param1:FriendBarMenu, param2:Number, param3:Number, param4:Function = null)
      {
         this.m_callbackFBar = param4;
         this.m_displayObject = param1;
         this.m_xadjusted = param2;
         this.m_yadjusted = param3;
         super(ZGlobal.getAssetURL("assets/displays/dialogs/Alliance_popupP3.swf"));
      }
      
      private function get screen() : MovieClip
      {
         return m_window.screen_mc;
      }
      
      private function get hints() : MovieClip
      {
         return m_window.screen_mc.hints_mc;
      }
      
      protected function setMemberText() : void
      {
         var _loc1_:String = null;
         if(this.m_allianceManager.currentMemberSize > 1)
         {
            _loc1_ = ZGameUtils.ZlocTP("Dialogs","Alliance_Phase3_Member_Below",{"total":this.m_allianceManager.currentMemberSize});
         }
         else
         {
            _loc1_ = ZGameUtils.ZlocTP("Dialogs","Alliance_Phase3_Member_Below1",{"total":this.m_allianceManager.currentMemberSize});
         }
         TextFieldUtil.compactTextField(this.screen.allianceStrength_tf,_loc1_);
         var _loc2_:String = ZGameUtils.ZlocTP("Dialogs","Alliance_Phase3_Member_Above",{
            "range":"" + (this.m_startslot + 1) + "-" + (this.m_startslot + this.MAX_SLOTS),
            "total":this.m_allianceManager.totalMemberSize
         });
         TextFieldUtil.compactTextField(this.screen.instructions_tf,_loc2_);
      }
      
      protected function setupText() : void
      {
         this.setMemberText();
         var _loc1_:String = ZGameUtils.ZlocTP("Dialogs","Alliance_Phase3_Member_title",{"Aname":this.m_allianceManager.clanName + " "});
         TextFieldUtil.compactTextField(this.screen.title_tf,_loc1_);
         var _loc2_:String = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Member_text1");
         TextFieldUtil.compactTextField(this.screen.hint_tf,_loc2_);
         var _loc3_:String = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Member_leave");
         TextFieldUtil.compactTextField(this.screen.abandon_bt.generic_tf,_loc3_);
         var _loc4_:String = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Member_match");
         TextFieldUtil.compactTextField(this.screen.matchmaking_bt.generic_tf,_loc4_);
         var _loc5_:String = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Member_battle");
         TextFieldUtil.compactTextField(this.screen.battle_bt.generic_tf,_loc5_);
         var _loc6_:String = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Member_coming");
         TextFieldUtil.compactTextField(this.screen.ribbon_mc.generic_tf,_loc6_);
         var _loc7_:String = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Member_edit");
         TextFieldUtil.compactTextField(this.screen.edit_bt.generic_tf,_loc7_);
         TextFieldUtil.compactTextField(this.screen.strength_mc.strength_tf,"" + this.m_allianceManager.currentHealth);
         var _loc8_:String = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Member_hint_crest_title");
         TextFieldUtil.compactTextField(this.screen.hints_mc.hint2_mc.title_tf,_loc8_);
         var _loc9_:String = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Member_hint_crest_text");
         TextFieldUtil.compactTextField(this.screen.hints_mc.hint2_mc.generic_tf,_loc9_);
         var _loc10_:String = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Member_hint_abandon_text");
         TextFieldUtil.compactTextField(this.screen.hints_mc.hint1_mc.generic_tf,_loc10_);
         var _loc11_:String = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Member_hint_abandon_title");
         TextFieldUtil.compactTextField(this.screen.hints_mc.hint1_mc.title_tf,_loc11_);
         var _loc12_:String = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Member_hint_strength_text");
         TextFieldUtil.compactTextField(this.screen.hints_mc.hint3_mc.generic_tf,_loc12_);
         var _loc13_:String = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Member_hint_strength_title");
         TextFieldUtil.compactTextField(this.screen.hints_mc.hint3_mc.title_tf,_loc13_);
         var _loc14_:String = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Member_hint_mem_text");
         TextFieldUtil.compactTextField(this.screen.hints_mc.hint4_mc.generic_tf,_loc14_);
         var _loc15_:String = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Member_hint_mem_title");
         TextFieldUtil.compactTextField(this.screen.hints_mc.hint4_mc.title_tf,_loc15_);
         var _loc16_:String = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Member_hint_battle_text");
         TextFieldUtil.compactTextField(this.screen.hints_mc.hint5_mc.generic_tf,_loc16_);
         var _loc17_:String = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Member_hint_battle_title");
         TextFieldUtil.compactTextField(this.screen.hints_mc.hint5_mc.title_tf,_loc17_);
         var _loc18_:String = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Crown_hint_title");
         TextFieldUtil.compactTextField(this.screen.hints_mc.hint6_mc.title_tf,_loc18_);
         var _loc19_:String = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Crown_hint_text");
         TextFieldUtil.compactTextField(this.screen.hints_mc.hint6_mc.generic_tf,_loc19_);
         var _loc20_:String = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Crown_UI_text");
         TextFieldUtil.compactTextField(this.screen.crown_tf,_loc20_);
         TextFieldUtil.compactTextField(this.screen.crownRank_tf,"x" + this.m_allianceManager.numCrowns);
      }
      
      private function clearEvents() : void
      {
         this.clearCardEvents();
         this.screen.AddToGroup_mc.removeEventListener(MouseEvent.CLICK,this.onCreateGroup);
         this.screen.FBGroup_mc.removeEventListener(MouseEvent.CLICK,this.onPostFeedClicked);
         UIDispatcher.instance.removeEventListener(AlliancesManager.FB_GROUP_CREATED,this.removeAddToGroupListener);
         this.screen.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExit);
         if(this.m_abdbutton)
         {
            this.m_abdbutton.dispose();
         }
         if(this.m_selectbutton)
         {
            this.m_selectbutton.dispose();
         }
         if(this.m_infobutton)
         {
            this.m_infobutton.dispose();
         }
         if(this.m_addbutton)
         {
            this.m_addbutton.dispose();
         }
         if(this.m_matchbutton)
         {
            this.m_matchbutton.dispose();
         }
         if(this.m_leftbutton)
         {
            this.m_leftbutton.dispose();
         }
         if(this.m_rightbutton)
         {
            this.m_rightbutton.dispose();
         }
         if(this.m_leftJumpButton)
         {
            this.m_leftJumpButton.dispose();
         }
         if(this.m_rightJumpButton)
         {
            this.m_rightJumpButton.dispose();
         }
         if(this.m_battleButton)
         {
            this.m_battleButton.dispose();
         }
         if(this.m_healthButton)
         {
            this.m_healthButton.dispose();
         }
         AlliancesManager.instance.removeEventListener(AlliancesManager.CLANS_ZLINGSHOT_MSG,this.onZlingshotUpdate);
      }
      
      private function clearCardEvents() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:ImageLoader = null;
         _loc1_ = 0;
         while(_loc1_ < this.MAX_SLOTS)
         {
            this.screen["card" + _loc1_].add_bt.removeEventListener(MouseEvent.CLICK,this.onMemberInvite);
            this.screen["card" + _loc1_].remove_bt.removeEventListener(MouseEvent.CLICK,this.onMemberRemove);
            this.screen["card" + _loc1_].removeEventListener(MouseEvent.CLICK,this.onMemberSelect);
            this.screen["card" + _loc1_].removeEventListener(MouseEvent.ROLL_OVER,this.onMemberOver);
            this.screen["card" + _loc1_].removeEventListener(MouseEvent.ROLL_OUT,this.onMemberOverEnd);
            if(this.m_cardKickButtons[_loc1_])
            {
               this.m_cardKickButtons[_loc1_].dispose();
            }
            if(this.m_cardAddButtons[_loc1_])
            {
               this.m_cardAddButtons[_loc1_].dispose();
            }
            this.m_cardAddButtons = new Array();
            this.m_cardKickButtons = new Array();
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ < this.m_cardImage.length)
         {
            _loc2_ = this.m_cardImage.pop();
            if(_loc2_ != null)
            {
               _loc2_.destroy();
            }
            _loc1_++;
         }
      }
      
      override protected function initializeScreen() : void
      {
         super.initializeScreen();
         this.screen.arrowRt_bt.visible = false;
         this.screen.arrowLtVarient_bt.visible = false;
         this.m_selectbutton = new ZGameButton(this.screen.edit_bt,this.onCrestSelect);
         this.m_infobutton = new ZGameButton(this.screen.info_bt,this.onInfo);
         this.m_addbutton = new ZGameButton(this.screen.add_bt,this.onAddSlot);
         this.m_matchbutton = new ZGameButton(this.screen.matchmaking_bt,this.onMatch);
         this.m_healthButton = new ZGameButton(this.screen.addHealth_bt,this.onBuyHealth);
         if(this.m_allianceManager.currentHealth >= this.m_allianceManager.maxHealth * AlliancesManager.HEALTH_BUY_THRESHOLD)
         {
            this.m_healthButton.hide();
         }
         this.m_leftbutton = new ZGameButton(this.screen.arrowSingleLtVarient_bt,this.onLeft);
         this.m_leftbutton.disable_visual(true);
         this.m_leftJumpButton = new ZGameButton(this.screen.arrowLtVarient_bt,this.onMoreLeft);
         this.screen.arrowLtVarient_bt.visible = true;
         this.m_leftJumpButton.disable_visual(true);
         this.m_rightbutton = new ZGameButton(this.screen.arrowSingleRt_bt,this.onRight);
         this.m_rightJumpButton = new ZGameButton(this.screen.arrowRt_bt,this.onMoreRight);
         this.screen.arrowRt_bt.visible = true;
         if(this.m_startslot + 5 == this.m_allianceManager.totalMemberSize)
         {
            this.m_rightbutton.disable_visual(true);
            this.m_rightJumpButton.disable_visual(true);
         }
         else
         {
            this.m_rightbutton.enable();
            this.m_rightJumpButton.enable();
         }
         if(!(MatchMakingManager.instance.isActive() && MatchMakingManager.instance.isUpgraded()))
         {
            this.m_matchbutton.disable_visual(true);
         }
         else
         {
            this.m_matchbutton.enable();
         }
         this.m_abdbutton = new ZGameButton(this.screen.abandon_bt,this.onAbandon);
         this.m_battleButton = new ZGameButton(this.screen.battle_bt,this.onBattle);
         if(!this.m_allianceManager.fbGroupCreated && this.m_allianceManager.isLeader() && ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_FB_GROUP_MASTER) == 3)
         {
            this.screen.AddToGroup_mc.visible = true;
            Tooltip.subscribe(this.screen.AddToGroup_mc,ZGameUtils.ZlocT("Dialogs","GroupCreateNotice"),null,true);
            this.screen.AddToGroup_mc.addEventListener(MouseEvent.CLICK,this.onCreateGroup);
            UIDispatcher.instance.addEventListener(AlliancesManager.FB_GROUP_CREATED,this.removeAddToGroupListener,false,0,true);
         }
         else
         {
            this.screen.AddToGroup_mc.visible = false;
         }
         if(this.m_allianceManager.fbGroupCreated && ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_FB_GROUP_MASTER) == 3)
         {
            this.screen.FBGroup_mc.visible = true;
            Tooltip.subscribe(this.screen.FBGroup_mc,ZGameUtils.ZlocT("Dialogs","GroupPostPopupHeader"),null,true);
            this.screen.FBGroup_mc.addEventListener(MouseEvent.CLICK,this.onPostFeedClicked);
         }
         else
         {
            this.screen.FBGroup_mc.visible = false;
         }
         this.screen.exit_bt.addEventListener(MouseEvent.CLICK,this.onExit);
         this.m_cardAddButtons = new Array();
         this.m_cardKickButtons = new Array();
         this.m_cardImage = new Array();
         if(this.m_allianceManager.isLeader())
         {
            this.screen.add_bt.visible = true;
            this.screen.edit_bt.visible = true;
            this.m_addbutton.enable();
            this.m_selectbutton.enable();
         }
         else
         {
            this.screen.add_bt.visible = false;
            this.screen.edit_bt.visible = false;
            this.m_addbutton.disable();
            this.m_selectbutton.disable();
         }
         this.populateMembers();
         if(this.m_allianceManager.totalMemberSize >= this.MAX_SLOTS_LIMIT)
         {
            this.m_addbutton.disable();
         }
         this.setHealthBarVisual();
         this.screen.hints_mc.visible = false;
         this.setCards();
         this.setCrestIcon();
         this.setupText();
         centerWithinStage(Zlab.mainStage);
         AlliancesManager.instance.addEventListener(AlliancesManager.CLANS_ZLINGSHOT_MSG,this.onZlingshotUpdate);
         if(AlliancesManager.isPhase4Enabled())
         {
            this.screen.ribbon_mc.visible = false;
         }
         else
         {
            this.screen.ribbon_mc.visible = true;
            this.m_battleButton.disable();
         }
      }
      
      public function onPostFeedClicked(param1:MouseEvent) : void
      {
         var _loc2_:FBGroupPostPopup = new FBGroupPostPopup(this.m_allianceManager.clanName,ZGameUtils.ZlocT("Dialogs","GroupPostPopupHeader"));
         _loc2_.addEventListener(FBGroupPostPopup.POPUP_CLOSED,this.onFeedPosted);
         PopupManager.instance.push(_loc2_,0,false);
      }
      
      public function onFeedPosted(param1:WorldEvent) : void
      {
      }
      
      private function populateMembers() : void
      {
         var _loc2_:String = null;
         this.m_members = new Array();
         var _loc1_:Array = AlliancesManager.instance.members;
         for each(_loc2_ in _loc1_)
         {
            this.m_members.push(_loc2_);
         }
      }
      
      private function setCrestIcon() : void
      {
         if(this.screen.icon)
         {
            this.m_crest = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(this.m_allianceManager.getPath(this.m_allianceManager.crestId,96)),this.screen.icon);
         }
      }
      
      private function setTitleText() : void
      {
         var _loc1_:String = ZGameUtils.ZlocTP("Dialogs","Alliance_Phase3_Member_title",{"Aname":this.m_allianceManager.clanName + " "});
         TextFieldUtil.compactTextField(this.screen.title_tf,_loc1_);
      }
      
      private function setCards() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:String = null;
         this.clearCardEvents();
         this.setMemberText();
         _loc1_ = 0;
         while(_loc1_ < this.MAX_SLOTS)
         {
            _loc2_ = null;
            _loc2_ = this.m_members[_loc1_ + this.m_startslot];
            if(Boolean(_loc2_) && this.memberInfo(_loc2_) == null)
            {
               this.setMemberCard(_loc1_,null);
            }
            else
            {
               this.setMemberCard(_loc1_,_loc2_);
            }
            _loc1_++;
         }
         if(this.m_allianceManager.totalMemberSize >= this.MAX_SLOTS_LIMIT)
         {
            this.m_addbutton.disable_visual(true);
         }
      }
      
      private function memberInfo(param1:String) : Object
      {
         return AlliancesManager.instance.memberInfo(param1);
      }
      
      private function setMemberCard(param1:Number, param2:String) : void
      {
         var _loc4_:Object = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:Player = null;
         var _loc8_:String = null;
         var _loc9_:Object = null;
         this.screen["card" + param1].remove_bt.visible = false;
         this.screen["card" + param1].new_tf.visible = false;
         this.screen["card" + param1].crewRemind_mc.visible = false;
         this.screen["card" + param1].manIcon_mc.visible = false;
         this.screen["card" + param1].tendEnergy_mc.visible = false;
         this.screen["card" + param1].uid = param2;
         var _loc3_:String = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Member_invite");
         TextFieldUtil.compactTextField(this.screen["card" + param1].add_bt.generic_tf,_loc3_);
         if(param2)
         {
            _loc4_ = this.memberInfo(param2);
            this.screen["card" + param1].profilelevel_tf.visible = true;
            this.screen["card" + param1].heartlevel_tf.visible = true;
            TextFieldUtil.compactTextField(this.screen["card" + param1].profilename_tf,_loc4_.name);
            TextFieldUtil.compactTextField(this.screen["card" + param1].profilelevel_tf,_loc4_.level);
            TextFieldUtil.compactTextField(this.screen["card" + param1].heartlevel_tf,_loc4_.dominanceRank);
            this.m_cardKickButtons[param1] = new ZGameButton(this.screen["card" + param1].remove_bt,this.onMemberRemove);
            this.screen["card" + param1].addEventListener(MouseEvent.ROLL_OVER,this.onMemberOver,false,0,true);
            this.screen["card" + param1].addEventListener(MouseEvent.ROLL_OUT,this.onMemberOverEnd,false,0,true);
            this.screen["card" + param1].addEventListener(MouseEvent.CLICK,this.onMemberSelect,false,0,true);
            _loc5_ = "assets/game/PvpGeneralAssetGroup_UI.swf/DominanceStar_32.png";
            _loc6_ = ZGlobal.getAssetURL(_loc5_);
            ImageLoaderFactory.CreateImageLoader(_loc6_,this.screen["card" + param1].rareloader_mc);
            _loc7_ = ZGlobal.player.findFriendById(param2);
            if(_loc7_)
            {
               if(this.m_cardImage[param1] != null)
               {
                  this.m_cardImage[param1].destroy();
               }
               _loc8_ = _loc7_.snUser.picture;
               if(!_loc8_)
               {
                  _loc9_ = this.memberInfo(param2);
                  if(_loc9_)
                  {
                     _loc8_ = _loc9_.image;
                  }
               }
               _loc8_ = _loc8_.replace("sslmux.local:6081","facebook.com");
               this.screen["card" + param1].profileloader_mc.visible = true;
               this.m_cardImage[param1] = ImageLoaderFactory.CreateImageLoader(_loc8_,this.screen["card" + param1].profileloader_mc);
            }
            else
            {
               this.screen["card" + param1].manIcon_mc.visible = true;
            }
            this.screen["card" + param1].add_bt.visible = false;
            this.screen["card" + param1].dominance_mc.visible = true;
            this.screen["card" + param1].level_mc.visible = true;
            this.screen["card" + param1].profilename_tf.visible = true;
            this.m_cardAddButtons[param1] = new ZGameButton(this.screen["card" + param1].add_bt,this.onMemberInvite);
            this.m_cardAddButtons[param1].disable();
            this.screen["card" + param1].add_bt.visible = false;
         }
         else
         {
            TextFieldUtil.compactTextField(this.screen["card" + param1].profilename_tf,"Name" + param1);
            this.screen["card" + param1].profilelevel_tf.visible = false;
            this.screen["card" + param1].profilename_tf.visible = false;
            this.screen["card" + param1].heartlevel_tf.visible = false;
            this.screen["card" + param1].profileloader_mc.visible = false;
            this.screen["card" + param1].manIcon_mc.visible = true;
            this.m_cardAddButtons[param1] = new ZGameButton(this.screen["card" + param1].add_bt,this.onMemberInvite);
            this.screen["card" + param1].add_bt.visible = true;
            this.screen["card" + param1].dominance_mc.visible = false;
            this.screen["card" + param1].level_mc.visible = false;
         }
      }
      
      private function onMemberSelect(param1:MouseEvent) : void
      {
         if(!param1.currentTarget.uid)
         {
            return;
         }
         if(Boolean(this.m_contextMenu) && this.m_contextMenu.zid != param1.currentTarget.uid)
         {
            this.m_contextMenu.visible = false;
            removeChild(this.m_contextMenu);
            this.m_contextMenu = null;
         }
         else if(Boolean(this.m_contextMenu) && this.m_contextMenu.zid == param1.currentTarget.uid)
         {
            this.m_contextMenu.visible = !this.m_contextMenu.visible;
         }
         if(!this.m_contextMenu && param1.currentTarget.uid != ZGlobal.player.uid)
         {
            this.m_contextMenu = this.setContextMenu(param1);
         }
      }
      
      private function setContextMenu(param1:MouseEvent) : MovieClip
      {
         var _loc2_:ImageLoader = null;
         var _loc3_:MovieClip = new ContextualMenu2();
         this.setupTextLink(_loc3_.sendGift,ZGameUtils.ZlocT("Main","ContextMenuSendGiftButton"));
         this.setupTextLink(_loc3_.requestMetal,ZGameUtils.ZlocT("Main","ContextMenuRequestMetalButton"));
         this.setupTextLink(_loc3_.market,ZGameUtils.ZlocT("Main","ContextMenuMarketButton"));
         var _loc4_:Object = this.memberInfo(param1.currentTarget.uid);
         var _loc5_:String = WorldResourceManager.instance.getResourceImageURL(_loc4_.resource,WorldResourceManager.SMALL_ICON);
         _loc2_ = ImageLoaderFactory.CreateImageLoader(_loc5_,_loc3_.requestMetal.icon);
         _loc2_.smooth = true;
         var _loc6_:MovieClip = new contextual1_mc();
         _loc3_.x = param1.currentTarget.x + param1.currentTarget.width - 10;
         _loc3_.y = param1.currentTarget.y + param1.currentTarget.height;
         _loc6_.x = _loc3_.anchor.x;
         _loc6_.y = _loc3_.anchor.y;
         _loc3_.frame.height += _loc6_.height;
         _loc3_.zid = param1.currentTarget.uid;
         var _loc7_:ZGameButton = new ZGameButton(_loc6_.orangeButton_01,this.onVisitClick,1);
         _loc7_.text = ZGameUtils.ZlocT("Main","ContextMenuVisitButton");
         _loc3_.addChild(_loc6_);
         addChild(_loc3_);
         return _loc3_;
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
         var _loc2_:Player = null;
         var _loc3_:Object = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:FeedPopup = null;
         var _loc7_:Object = null;
         this.clearEvents();
         close();
         if(param1.currentTarget == this.m_contextMenu.sendGift)
         {
            if(this.m_contextMenu.zid != ZGlobal.hostPlayer.uid)
            {
               ZGlobal.switchToTab("gifts");
            }
         }
         else if(ZGlobal.neighborReactivationNeeded(this.m_contextMenu.zid))
         {
            ReactivationGiftPopup.show(this.m_contextMenu.zid);
         }
         else if(param1.currentTarget == this.m_contextMenu.requestMetal)
         {
            if(this.m_contextMenu.zid != ZGlobal.player.uid)
            {
               _loc2_ = ZGlobal.player.findFriendById(this.m_contextMenu.zid);
               _loc3_ = this.memberInfo(this.m_contextMenu.zid);
               _loc4_ = WorldResourceManager.instance.getResourceFriendlyNameFromIndex(_loc3_.resource,GameItem.SENTENCE_FRIENDLYNAME);
               _loc5_ = WorldResourceManager.instance.getResourceTypeFromIndex(_loc3_.resource);
               _loc6_ = new FeedPopup(ZGameUtils.ZlocT("FeedPopups","request_resource",{
                  "resource":ZGameUtils.ZlocTk("Items",_loc5_ + "_sentenceName","plural"),
                  "friend":_loc2_.firstName
               }),ZGameUtils.ZlocT("FeedPopups","request_resource_title",{"resource":ZGameUtils.ZlocTk("Items",_loc5_ + "_sentenceName","plural")}),ZGameUtils.ZlocT("FeedPopups","feed_request_bttn"),GenericPopup.TYPE_SHARECANCEL,this.onRequestResourcesClick,WorldResourceManager.instance.getResourceImageURL(_loc3_.resource,WorldResourceManager.XTRA_LARGE_ICON));
               _loc7_ = new Object();
               _loc7_.uid = this.m_contextMenu.zid;
               _loc7_.name = _loc5_;
               _loc7_.localized = _loc4_;
               _loc6_.userData = _loc7_;
               PopupManager.instance.push(_loc6_);
            }
         }
         else if(param1.currentTarget == this.m_contextMenu.market)
         {
            if(TutorialManager.instance.neighborBarEnabled)
            {
               TransactionManager.addTransaction(new TWorldLoad(this.m_contextMenu.zid,PVPManager.VISIT_MODE_NONE,{
                  "dbg":TWorldLoad.DBG_MARKET,
                  "ctx":"VisitOnlyPane"
               },true),true);
            }
            else
            {
               TutorialManager.instance.showInvalidVisitPopup();
            }
         }
      }
      
      private function onRequestResourcesClick(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.ACCEPT)
         {
            ViralsManager.instance.sendResourceRequest(param1.userData.name,param1.userData.uid);
         }
      }
      
      private function onVisitClick(param1:MouseEvent) : void
      {
         this.clearEvents();
         close();
         TransactionManager.addTransaction(new TWorldLoad(this.m_contextMenu.zid,PVPManager.VISIT_MODE_NONE,{
            "dbg":TWorldLoad.DBG_VISIT,
            "ctx":"VisitOnlyPane"
         },false),true);
         if(TutorialManager.instance.active)
         {
            TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.NEIGHBOR_VISIT_CLICKED,this.m_contextMenu.zid));
         }
         if(this.m_contextMenu)
         {
            this.m_contextMenu.visible = false;
            removeChild(this.m_contextMenu);
            this.m_contextMenu = null;
         }
      }
      
      private function afterAddSlot(param1:GenericPopupEvent) : void
      {
         var _loc2_:TBuySlot = null;
         if(param1.button == GenericPopup.YES)
         {
            _loc2_ = new TBuySlot();
            TransactionManager.addTransaction(_loc2_,true);
            this.m_allianceManager.increaseTotalMemberSize();
            this.m_rightbutton.enable();
            this.m_rightJumpButton.enable();
            this.screen.arrowSingleRt_bt.visible = true;
            this.m_leftbutton.enable();
            this.m_leftJumpButton.enable();
            this.screen.arrowSingleLtVarient_bt.visible = true;
            this.setMemberText();
            if(this.m_allianceManager.totalMemberSize >= this.MAX_SLOTS_LIMIT)
            {
               this.m_addbutton.disable_visual(true);
            }
         }
      }
      
      private function afterRemove(param1:GenericPopupEvent) : void
      {
         var _loc2_:TRemoveMember = null;
         if(param1.button == GenericPopup.YES)
         {
            _loc2_ = new TRemoveMember(param1.userData.playerid);
            TransactionManager.addTransaction(_loc2_,true);
            this.m_allianceManager.removeMember(param1.userData.playerid as String);
            this.populateMembers();
            this.setCards();
         }
      }
      
      private function onMemberInvite(param1:MouseEvent) : void
      {
         StatsManager.count("alliances","invite","Requests");
         PopupManager.instance.push(new RequestAllianceInviteDialog(),0,false);
      }
      
      private function onMemberOverEnd(param1:MouseEvent) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:MovieClip = null;
         _loc3_ = param1.currentTarget as MovieClip;
         _loc3_.remove_bt.visible = false;
         if(Boolean(this.m_contextMenu) && (!param1.relatedObject || param1.relatedObject.parent != this.m_contextMenu))
         {
            this.m_contextMenu.visible = false;
            removeChild(this.m_contextMenu);
            this.m_contextMenu = null;
         }
      }
      
      private function onMemberOver(param1:MouseEvent) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:MovieClip = null;
         _loc3_ = param1.currentTarget as MovieClip;
         if(this.m_allianceManager.isLeader() && _loc3_.uid != ZGlobal.player.uid && !_loc3_.remove_bt.visible)
         {
            _loc3_.remove_bt.visible = true;
         }
      }
      
      private function onMemberRemove(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Number = NaN;
         var _loc4_:MovieClip = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         _loc4_ = param1.currentTarget.parent;
         _loc5_ = _loc4_.uid;
         var _loc7_:Object = this.memberInfo(_loc5_);
         _loc6_ = _loc7_.name;
         var _loc8_:Object = {"playerid":_loc5_};
         var _loc9_:String = "player " + _loc2_;
         var _loc10_:String = ZGameUtils.ZlocTP("Dialogs","Alliance_Phase3_Member_kick",{"player":_loc6_});
         var _loc11_:String = "";
         this.m_removepopup = GenericPopup2B.NewYesNo(_loc10_,_loc11_,this.afterRemove);
         this.m_removepopup.userData = _loc8_;
         PopupManager.instance.push(this.m_removepopup,0,false);
      }
      
      private function onMemberClick(param1:MouseEvent) : void
      {
         this.clearEvents();
         close();
      }
      
      private function onAddSlot(param1:MouseEvent) : void
      {
         if(this.m_allianceManager.totalMemberSize >= this.MAX_SLOTS_LIMIT)
         {
            this.m_addbutton.disable_visual(true);
            return;
         }
         var _loc2_:String = ZGameUtils.ZlocTP("Dialogs","Alliance_Phase3_Member_add",{"x":this.SLOT_COST});
         var _loc3_:String = "";
         this.m_addpopup = GenericPopup2B.NewYesNo(_loc2_,_loc3_,this.afterAddSlot);
         PopupManager.instance.push(this.m_addpopup,0,false);
      }
      
      private function onClickOutside(param1:MouseEvent) : void
      {
         Zlab.mainStage.removeEventListener(MouseEvent.CLICK,this.onClickOutside);
         this.screen.hints_mc.visible = false;
      }
      
      private function onInfo(param1:MouseEvent) : void
      {
         if(this.screen.hints_mc.visible == true)
         {
            this.screen.hints_mc.visible = false;
            Zlab.mainStage.removeEventListener(MouseEvent.CLICK,this.onClickOutside);
         }
         else
         {
            this.screen.hints_mc.visible = true;
            Zlab.mainStage.addEventListener(MouseEvent.CLICK,this.onClickOutside);
         }
      }
      
      private function onExit(param1:MouseEvent) : void
      {
         if(this.m_callbackFBar != null)
         {
            this.m_callbackFBar();
         }
         this.clearEvents();
         close();
      }
      
      private function fbGroupDelete(param1:GenericPopupEvent) : void
      {
      }
      
      private function afterAbandonFinal(param1:GenericPopupEvent) : void
      {
         var _loc2_:TRemoveMember = null;
         if(param1.button == GenericPopup.YES)
         {
            this.clearEvents();
            close();
            if(ZGlobal.player.didCompleteQuest("QALL3") && ZGlobal.player.uid == AlliancesManager.instance.firstLeader)
            {
               AlliancesManager.instance.clearQuests();
            }
            _loc2_ = new TRemoveMember(ZGlobal.player.uid);
            TransactionManager.addTransaction(_loc2_,true);
            if(this.m_members.length == 1 && AlliancesManager.instance.fbGroupCreated)
            {
               PopupManager.instance.push(new SpeechPopup("Speech_FB_Group_Delete",this.fbGroupDelete,SpeechPopup.EXIT_TEXT_OK),0,true,false);
            }
            AlliancesManager.instance.fbGroupID = "";
            AlliancesManager.instance.fbGroupCreated = false;
         }
      }
      
      private function afterAbandon(param1:GenericPopupEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:GenericPopup = null;
         var _loc5_:TRemoveMember = null;
         if(param1.button == GenericPopup.YES)
         {
            if(this.m_allianceManager.isLeader())
            {
               _loc2_ = ZGameUtils.ZlocTP("Dialogs","Alliance_Phase3_Exit_Leader_desc",{"Aname":this.m_allianceManager.clanName});
               _loc3_ = "";
               _loc4_ = GenericPopup2B.NewYesNo(_loc2_,_loc3_,this.afterAbandonFinal);
               _loc4_.setAdvisorMood(GenericPopup.MOOD_SURPRISED);
               PopupManager.instance.push(_loc4_,0,false);
            }
            else
            {
               _loc5_ = new TRemoveMember(ZGlobal.player.uid);
               AlliancesManager.instance.fbGroupID = "";
               AlliancesManager.instance.fbGroupCreated = false;
               TransactionManager.addTransaction(_loc5_,true);
               this.clearEvents();
               close();
            }
         }
      }
      
      private function onAbandon(param1:MouseEvent) : void
      {
         var _loc4_:GenericPopup = null;
         var _loc2_:String = ZGameUtils.ZlocTP("Dialogs","Alliance_Phase3_Exit_desc",{"Aname":this.m_allianceManager.clanName});
         var _loc3_:String = "";
         _loc4_ = GenericPopup2B.NewYesNo(_loc2_,_loc3_,this.afterAbandon);
         _loc4_.setAdvisorMood(GenericPopup.MOOD_SURPRISED);
         PopupManager.instance.push(_loc4_,0,false);
      }
      
      private function onMoreLeft(param1:MouseEvent) : void
      {
         this.m_startslot = 1;
         this.onLeft(null);
      }
      
      private function onCreateGroup(param1:MouseEvent) : void
      {
         PopupManager.instance.push(new AllianceChangeLook(this.setCrestIcon,this.setTitleText),0,false);
      }
      
      private function postFeed(param1:MouseEvent) : void
      {
      }
      
      private function onMoreRight(param1:MouseEvent) : void
      {
         this.m_startslot = this.m_allianceManager.totalMemberSize - this.MAX_SLOTS;
         if(this.m_startslot < 0)
         {
            this.m_startslot = 0;
         }
         this.onRight(null);
      }
      
      private function onLeft(param1:MouseEvent) : void
      {
         if(this.m_startslot > 0)
         {
            --this.m_startslot;
            this.m_rightbutton.enable();
            this.m_rightJumpButton.enable();
         }
         if(this.m_startslot == 0)
         {
            this.m_leftbutton.disable_visual(true);
            this.m_leftJumpButton.disable_visual(true);
         }
         this.setCards();
      }
      
      private function onRight(param1:MouseEvent) : void
      {
         var _loc2_:int = this.m_allianceManager.totalMemberSize - this.MAX_SLOTS;
         if(this.m_startslot < _loc2_)
         {
            this.m_startslot += 1;
         }
         if(this.m_startslot + this.MAX_SLOTS == this.m_allianceManager.totalMemberSize)
         {
            this.m_rightbutton.disable_visual(true);
            this.m_rightJumpButton.disable_visual(true);
         }
         if(this.m_startslot > 0)
         {
            this.m_leftbutton.enable();
            this.m_leftJumpButton.enable();
         }
         this.setCards();
      }
      
      private function onMatch(param1:MouseEvent) : void
      {
         this.clearEvents();
         close();
         if(MatchMakingManager.instance.initialized)
         {
            MatchMakingManager.instance.showDialog();
         }
         else
         {
            MatchMakingManager.instance.getMatchMakingData();
         }
      }
      
      private function onBattle(param1:MouseEvent) : void
      {
         if(this.m_callbackFBar != null)
         {
            this.m_callbackFBar();
         }
         this.clearEvents();
         close();
         StatsManager.count("alliances","alliances.battle","defend_button");
         DominationModeManager.instance.launchDominationScreen();
      }
      
      private function onCrestSelect(param1:MouseEvent) : void
      {
         PopupManager.instance.push(new AllianceChangeLook(this.setCrestIcon,this.setTitleText),0,false);
      }
      
      private function onZlingshotUpdate(param1:WorldEvent) : void
      {
         if(!param1 || !param1.eventData)
         {
            return;
         }
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
            close();
         }
         else if(param1.eventData == "clan.healthUpdate")
         {
            this.setupText();
            this.setHealthBarVisual();
         }
         else
         {
            this.populateMembers();
            this.setCards();
            this.setupText();
            this.setHealthBarVisual();
            if(this.m_allianceManager.isLeader())
            {
               this.screen.add_bt.visible = true;
               this.screen.edit_bt.visible = true;
               this.m_addbutton.enable();
               this.m_selectbutton.enable();
            }
            else
            {
               this.screen.add_bt.visible = false;
               this.screen.edit_bt.visible = false;
               this.m_addbutton.disable();
               this.m_selectbutton.disable();
            }
         }
      }
      
      private function setHealthBarVisual() : void
      {
         var _loc1_:Number = this.screen.strength_mc.width * (1 * this.m_allianceManager.currentHealth / AlliancesManager.instance.maxHealth);
         _loc1_ = _loc1_ > 5 ? _loc1_ : 5;
         TweenLite.to(this.screen.strength_mc.mask_mc,0,{"width":_loc1_});
      }
      
      private function onBuyHealth(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:GenericPopup = null;
         if(AlliancesManager.instance.healthBelowThreshold())
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
         if(param1.button == GenericPopup.YES)
         {
            _loc2_ = AlliancesManager.instance.healthPrice();
            if(ZGlobal.player.canBuyCash(_loc2_,true,"",false))
            {
               _loc3_ = new TBuyHealth();
               TransactionManager.addTransaction(_loc3_,true);
               ZGlobal.player.cash -= _loc2_;
               AlliancesManager.instance.giveMaxHealth();
               TextFieldUtil.compactTextField(this.screen.strength_mc.strength_tf,AlliancesManager.instance.maxHealth.toString());
               this.setHealthBarVisual();
               this.m_healthButton.hide();
            }
         }
      }
      
      private function removeAddToGroupListener(param1:Event) : void
      {
         this.screen.AddToGroup_mc.removeEventListener(MouseEvent.CLICK,this.onCreateGroup);
         this.screen.AddToGroup_mc.visible = false;
         this.screen.FBGroup_mc.visible = true;
         Tooltip.subscribe(this.screen.FBGroup_mc,ZGameUtils.ZlocT("Dialogs","GroupPostPopupHeader"),null,true);
         this.screen.FBGroup_mc.addEventListener(MouseEvent.CLICK,this.onPostFeedClicked);
         UIDispatcher.instance.removeEventListener(AlliancesManager.FB_GROUP_CREATED,this.removeAddToGroupListener);
      }
   }
}

