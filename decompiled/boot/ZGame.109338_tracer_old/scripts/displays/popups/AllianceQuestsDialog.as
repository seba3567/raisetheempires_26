package displays.popups
{
   import Engine.Managers.TransactionManager;
   import ZQuest.Managers.QuestManager;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.AllianceQuestManager;
   import core.managers.AlliancesManager;
   import core.managers.questManager.ZGameQuest;
   import core.managers.questManager.ZGameQuestManager;
   import core.managers.questManager.ZGameTask;
   import core.player.Player;
   import core.ui.UIManager;
   import core.ui.ZGameButton;
   import core.ui.menuitem.FriendsBarUIItem;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import displays.screens.requests.RequestGiftDialog;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import transactions.TBuyItem;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class AllianceQuestsDialog extends ZGamePopUp
   {
      
      private var m_quest:ZGameQuest;
      
      private var m_clock:MOTDCountdownClock = null;
      
      private var m_cardImage:Array = null;
      
      private var m_alliance_icon:ImageLoader;
      
      private var m_hint_bt:ZGameButton;
      
      private var m_create_bt:ZGameButton;
      
      private var m_hidehint_bt:ZGameButton;
      
      private var m_hint_inited:Boolean = false;
      
      private var m_buy_bond:ZGameButton;
      
      private var m_buy_number:int;
      
      private var m_startslot:int;
      
      private var m_ask_bt:ZGameButton;
      
      public function AllianceQuestsDialog(param1:ZGameQuest)
      {
         this.m_quest = param1;
         super(ZGlobal.getAssetURL("assets/displays/dialogs/AllianceQuest.swf"));
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         m_window = param1.clip.screen_mc;
         param1.destroy();
         addChild(m_window);
         this.setupUI();
         m_origOffsetX = m_window.panel_mc.x;
         m_origOffsetY = m_window.panel_mc.y;
         this.contentWidth = m_window.width;
         this.contentHeight = m_window.height;
         centerWithinStage(Zlab.mainStage);
         dispatchEvent(new Event(Event.COMPLETE));
         QuestManager.getInstance().addEventListener(ZGameQuestManager.QUEST_PROGRESS,this.setupUI,false,0,true);
         QuestManager.getInstance().addEventListener(ZGameQuestManager.QUEST_COMPLETE,this.questComplete,false,0,true);
      }
      
      private function hideHint(param1:MouseEvent) : void
      {
         m_window.hint_mc.visible = false;
         m_window.hint_mc.removeEventListener(MouseEvent.CLICK,this.hideHint);
         param1.stopImmediatePropagation();
         if(this.m_ask_bt)
         {
            this.m_ask_bt.enable();
         }
      }
      
      private function onHint(param1:MouseEvent) : void
      {
         var event:MouseEvent = param1;
         if(m_window.hint_mc)
         {
            if(!this.m_hidehint_bt)
            {
               this.m_hidehint_bt = new ZGameButton(m_window.hint_mc.start_bt,this.hideHint);
               this.m_hidehint_bt.text = ZGameUtils.ZlocT("Dialogs","Alliance_Quest_Hint_Hide");
               this.m_hidehint_bt.enable();
            }
            TextFieldUtil.compactTextField(m_window.hint_mc.title_tf,ZGameUtils.ZlocT("Dialogs","Alliance_Quest_Hint_Title"));
            if(Boolean(m_window.hint_mc.step1_mc) && !this.m_hint_inited)
            {
               m_window.hint_mc.step1_mc.addEventListener(MouseEvent.MOUSE_OVER,function(param1:Event):void
               {
                  m_window.hint_mc.step1_mc.gotoAndStop(2);
                  TextFieldUtil.compactTextField(m_window.hint_mc.step1_mc.title_tf,ZGameUtils.ZlocT("Dialogs","Alliance_Quest_Help_Title1"));
                  TextFieldUtil.compactTextField(m_window.hint_mc.step1_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","Alliance_Quest_Help_Body1"));
                  m_window.hint_mc.step1_mc.title_tf.visible = true;
               });
               m_window.hint_mc.step1_mc.addEventListener(MouseEvent.MOUSE_OUT,function(param1:Event):void
               {
                  m_window.hint_mc.step1_mc.gotoAndStop(1);
                  TextFieldUtil.compactTextField(m_window.hint_mc.step1_mc.title_tf,ZGameUtils.ZlocT("Dialogs","Alliance_Quest_Help_Title1"));
               });
               m_window.hint_mc.step1_mc.gotoAndStop(1);
               TextFieldUtil.compactTextField(m_window.hint_mc.step1_mc.title_tf,ZGameUtils.ZlocT("Dialogs","Alliance_Quest_Help_Title1"));
            }
            if(Boolean(m_window.hint_mc.step2_mc) && !this.m_hint_inited)
            {
               m_window.hint_mc.step2_mc.addEventListener(MouseEvent.MOUSE_OVER,function(param1:Event):void
               {
                  m_window.hint_mc.step2_mc.gotoAndStop(2);
                  TextFieldUtil.compactTextField(m_window.hint_mc.step2_mc.title_tf,ZGameUtils.ZlocT("Dialogs","Alliance_Quest_Help_Title2"));
                  TextFieldUtil.compactTextField(m_window.hint_mc.step2_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","Alliance_Quest_Help_Body2"));
                  m_window.hint_mc.step2_mc.title_tf.visible = true;
               });
               m_window.hint_mc.step2_mc.addEventListener(MouseEvent.MOUSE_OUT,function(param1:Event):void
               {
                  m_window.hint_mc.step2_mc.gotoAndStop(1);
                  TextFieldUtil.compactTextField(m_window.hint_mc.step2_mc.title_tf,ZGameUtils.ZlocT("Dialogs","Alliance_Quest_Help_Title2"));
               });
               m_window.hint_mc.step2_mc.gotoAndStop(1);
               TextFieldUtil.compactTextField(m_window.hint_mc.step2_mc.title_tf,ZGameUtils.ZlocT("Dialogs","Alliance_Quest_Help_Title2"));
            }
            if(Boolean(m_window.hint_mc.step3_mc) && !this.m_hint_inited)
            {
               m_window.hint_mc.step3_mc.addEventListener(MouseEvent.MOUSE_OVER,function(param1:Event):void
               {
                  m_window.hint_mc.step3_mc.gotoAndStop(2);
                  TextFieldUtil.compactTextField(m_window.hint_mc.step3_mc.title_tf,ZGameUtils.ZlocT("Dialogs","Alliance_Quest_Help_Title3"));
                  TextFieldUtil.compactTextField(m_window.hint_mc.step3_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","Alliance_Quest_Help_Body3"));
                  m_window.hint_mc.step3_mc.title_tf.visible = true;
               });
               m_window.hint_mc.step3_mc.addEventListener(MouseEvent.MOUSE_OUT,function(param1:Event):void
               {
                  m_window.hint_mc.step3_mc.gotoAndStop(1);
                  TextFieldUtil.compactTextField(m_window.hint_mc.step3_mc.title_tf,ZGameUtils.ZlocT("Dialogs","Alliance_Quest_Help_Title3"));
               });
               m_window.hint_mc.step3_mc.gotoAndStop(1);
               TextFieldUtil.compactTextField(m_window.hint_mc.step3_mc.title_tf,ZGameUtils.ZlocT("Dialogs","Alliance_Quest_Help_Title3"));
            }
            if(Boolean(m_window.hint_mc.step4_mc) && !this.m_hint_inited)
            {
               m_window.hint_mc.step4_mc.addEventListener(MouseEvent.MOUSE_OVER,function(param1:Event):void
               {
                  m_window.hint_mc.step4_mc.gotoAndStop(2);
                  TextFieldUtil.compactTextField(m_window.hint_mc.step4_mc.title_tf,ZGameUtils.ZlocT("Dialogs","Alliance_Quest_Help_Title4"));
                  TextFieldUtil.compactTextField(m_window.hint_mc.step4_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","Alliance_Quest_Help_Body4"));
                  m_window.hint_mc.step4_mc.title_tf.visible = true;
               });
               m_window.hint_mc.step4_mc.addEventListener(MouseEvent.MOUSE_OUT,function(param1:Event):void
               {
                  m_window.hint_mc.step4_mc.gotoAndStop(1);
                  TextFieldUtil.compactTextField(m_window.hint_mc.step4_mc.title_tf,ZGameUtils.ZlocT("Dialogs","Alliance_Quest_Help_Title4"));
               });
               m_window.hint_mc.step4_mc.gotoAndStop(1);
               TextFieldUtil.compactTextField(m_window.hint_mc.step4_mc.title_tf,ZGameUtils.ZlocT("Dialogs","Alliance_Quest_Help_Title4"));
            }
            if(this.m_ask_bt)
            {
               this.m_ask_bt.disable_visual();
            }
            m_window.hint_mc.visible = true;
            this.m_hint_inited = true;
         }
      }
      
      private function onLeft(param1:Event) : void
      {
         if(this.m_startslot > 0)
         {
            --this.m_startslot;
         }
         m_window.allianceMembers_mc.arrowLtSingle_bt.removeEventListener(MouseEvent.CLICK,this.onLeft);
         this.checkButtons();
         this.setupAlliance();
      }
      
      private function onRight(param1:Event) : void
      {
         var _loc2_:Dictionary = AlliancesManager.instance.getMembersQuestCount(this.m_quest.name);
         if(_loc2_["members"].length > this.m_startslot + 4)
         {
            this.m_startslot += 1;
         }
         m_window.allianceMembers_mc.arrowRtSingle_bt.removeEventListener(MouseEvent.CLICK,this.onRight);
         this.checkButtons();
         this.setupAlliance();
      }
      
      private function checkButtons() : void
      {
         var _loc1_:Dictionary = AlliancesManager.instance.getMembersQuestCount(this.m_quest.name);
         m_window.allianceMembers_mc.arrowLtSingle_bt.addEventListener(MouseEvent.CLICK,this.onLeft);
         m_window.allianceMembers_mc.arrowRtSingle_bt.addEventListener(MouseEvent.CLICK,this.onRight);
         if(_loc1_["members"].length > this.m_startslot + 4)
         {
            m_window.allianceMembers_mc.arrowRtSingle_bt.visible = true;
         }
         else
         {
            m_window.allianceMembers_mc.arrowRtSingle_bt.visible = false;
         }
         if(this.m_startslot > 0)
         {
            m_window.allianceMembers_mc.arrowLtSingle_bt.visible = true;
         }
         else
         {
            m_window.allianceMembers_mc.arrowLtSingle_bt.visible = false;
         }
      }
      
      private function setupAlliance() : void
      {
         var _loc1_:Dictionary = null;
         var _loc2_:String = null;
         var _loc3_:int = 0;
         var _loc4_:ImageLoader = null;
         if(m_window.allianceMembers_mc)
         {
            TextFieldUtil.compactTextField(m_window.allianceMembers_mc.rating_tf,"");
            _loc1_ = AlliancesManager.instance.getMembersQuestCount(this.m_quest.name);
            if(_loc1_["total"] == 1 || _loc1_["total"] == 0)
            {
               TextFieldUtil.compactTextField(m_window.allianceMembers_mc.information_tf,ZGameUtils.ZlocT("Dialogs","Alliance_Quest_Accept_Count_1"));
            }
            else
            {
               TextFieldUtil.compactTextField(m_window.allianceMembers_mc.information_tf,ZGameUtils.ZlocT("Dialogs","Alliance_Quest_Accept_Count",{"total":_loc1_["total"]}));
            }
            m_window.allianceMembers_mc.visible = true;
            if(this.m_alliance_icon)
            {
               this.m_alliance_icon.destroy();
            }
            this.m_alliance_icon = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(AlliancesManager.instance.getPath(AlliancesManager.instance.crestId,96)),m_window.allianceMembers_mc.allianceIcon);
            this.m_alliance_icon.smooth = true;
            if(this.m_cardImage)
            {
               _loc3_ = 0;
               while(_loc3_ < this.m_cardImage.length)
               {
                  _loc4_ = this.m_cardImage.pop();
                  if(_loc4_ != null)
                  {
                     _loc4_.destroy();
                  }
                  _loc3_++;
               }
            }
            else
            {
               this.m_cardImage = new Array();
            }
            _loc3_ = 0;
            while(_loc3_ < 4)
            {
               if(_loc1_["members"].length > _loc3_ + this.m_startslot)
               {
                  _loc2_ = _loc1_["members"][_loc3_ + this.m_startslot];
               }
               else
               {
                  _loc2_ = null;
               }
               if(Boolean(_loc2_) && this.memberInfo(_loc2_) == null)
               {
                  this.setMemberCard(_loc3_,null);
               }
               else
               {
                  this.setMemberCard(_loc3_,_loc2_);
               }
               _loc3_++;
            }
            m_window.ask_bt.visible = false;
            if(!this.m_ask_bt)
            {
               this.m_ask_bt = new ZGameButton(m_window.ask_bt,this.onAsk);
               this.m_ask_bt.text = ZGameUtils.ZlocT("Dialogs","Alliance_Quest_Ask_Help");
               if(AlliancesManager.instance.members.length > 1)
               {
                  m_window.ask_bt.visible = true;
                  this.m_ask_bt.enable();
               }
               else
               {
                  this.m_ask_bt.disable_visual();
                  m_window.ask_bt.visible = false;
               }
            }
            this.checkButtons();
         }
         if(m_window.noAlliance_mc)
         {
            m_window.noAlliance_mc.visible = false;
         }
      }
      
      private function onAsk(param1:Event) : void
      {
         if(ZGlobal.player.allianceQuestReq > 2)
         {
            return;
         }
         var _loc2_:RequestGiftDialog = new RequestGiftDialog("coins_gift","allianceQuest");
         var _loc3_:Array = AlliancesManager.instance.members.concat();
         var _loc4_:int = _loc3_.indexOf(ZGlobal.player.uid);
         if(_loc4_ > -1)
         {
            _loc3_.splice(_loc4_,1);
         }
         _loc2_.forceRequest(_loc3_);
         ZGlobal.player.allianceQuestReq += 1;
      }
      
      private function setupNoAlliance() : void
      {
         if(m_window.allianceMembers_mc)
         {
            m_window.allianceMembers_mc.visible = false;
            if(this.m_ask_bt)
            {
               this.m_ask_bt.dispose();
               this.m_ask_bt = null;
            }
            m_window.ask_bt.visible = false;
         }
         if(m_window.noAlliance_mc)
         {
            m_window.noAlliance_mc.visible = true;
            TextFieldUtil.compactTextField(m_window.noAlliance_mc.information_tf,ZGameUtils.ZlocT("Dialogs","Alliance_Quest_Text"));
            if(!this.m_create_bt)
            {
               this.m_create_bt = new ZGameButton(m_window.noAlliance_mc.create_bt,this.showAllianceDialog);
               this.m_create_bt.text = ZGameUtils.ZlocT("Dialogs","Alliance_Phase2_Create");
               this.m_create_bt.enable();
            }
            TextFieldUtil.compactTextField(m_window.noAlliance_mc.hint_tf,ZGameUtils.ZlocT("Dialogs","Alliance_Quest_Hint"));
         }
      }
      
      private function showAllianceDialog(param1:Event) : void
      {
         var _loc2_:FriendsBarUIItem = UIManager.instance.getMenuItemByName(FriendsBarUIItem.ITEM_ID) as FriendsBarUIItem;
         if(_loc2_)
         {
            _loc2_.showAllianceUI();
            this.close();
         }
      }
      
      override protected function close(param1:Event = null) : void
      {
         var _loc2_:int = 0;
         var _loc3_:ImageLoader = null;
         QuestManager.getInstance().removeEventListener(ZGameQuestManager.QUEST_PROGRESS,this.setupUI);
         QuestManager.getInstance().removeEventListener(ZGameQuestManager.QUEST_COMPLETE,this.questComplete);
         if(this.m_cardImage)
         {
            _loc2_ = 0;
            while(_loc2_ < this.m_cardImage.length)
            {
               _loc3_ = this.m_cardImage.pop();
               if(_loc3_ != null)
               {
                  _loc3_.destroy();
               }
               _loc2_++;
            }
         }
         super.close(param1);
      }
      
      protected function questComplete(param1:WorldEvent = null) : void
      {
         if(Boolean(param1 != null) && Boolean(param1.eventData) && Boolean(param1.eventData.name))
         {
            if(param1.eventData.name == this.m_quest.name)
            {
               this.close();
            }
         }
      }
      
      protected function setupUI(param1:WorldEvent = null) : void
      {
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:ImageLoader = null;
         var _loc7_:ZGameTask = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:GameItem = null;
         var _loc13_:ImageLoader = null;
         var _loc14_:ImageLoader = null;
         var _loc15_:ImageLoader = null;
         var _loc16_:ImageLoader = null;
         if(param1 != null && Boolean(param1.eventData))
         {
            if(param1.eventData != this.m_quest.name)
            {
               return;
            }
         }
         var _loc2_:Object = (QuestManager.getInstance() as ZGameQuestManager).getTextObject(this.m_quest.name);
         m_window.exit_bt.addEventListener(MouseEvent.CLICK,this.close);
         this.m_hint_bt = new ZGameButton(m_window.info_bt,this.onHint);
         this.m_hint_bt.enable();
         m_window.requirement1_mc.check_mc.visible = false;
         if(m_window.hint_mc)
         {
            m_window.hint_mc.visible = false;
         }
         if(m_window.clock_mc)
         {
            if(this.m_clock)
            {
               this.m_clock.dispose();
               this.m_clock = null;
            }
            this.m_clock = new MOTDCountdownClock(m_window.clock_mc,this.m_quest.xml,true,false,false,0,this.onUpdate);
         }
         if(_loc2_)
         {
            TextFieldUtil.compactTextField(m_window.header_tf,_loc2_.title);
            TextFieldUtil.compactTextField(m_window.popupBox_tf,_loc2_.hint);
            TextFieldUtil.compactTextField(m_window.requirement1_mc.progress_tf,_loc2_.taskProgress[0]);
            m_window.requirement1_mc.check_mc.visible = _loc2_.taskComplete[0];
            if(_loc2_.taskIcons[0])
            {
               _loc6_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURLChecked(_loc2_.taskIcons[0]),m_window.requirement1_mc.icon_mc);
               _loc6_.smooth = true;
            }
            _loc4_ = this.m_quest.createTasks();
            _loc5_ = 0;
            if(_loc4_.length > 0)
            {
               _loc7_ = _loc4_[0];
               _loc8_ = _loc7_.total;
               TextFieldUtil.compactTextField(m_window.requirement1_mc.name_tf,ZGameUtils.ZlocT("Dialogs","Alliance_Quest_Task1",{"total":_loc8_}));
               _loc9_ = _loc8_ - _loc7_.remainingItemAmount;
               this.followBar(_loc9_,_loc8_);
               _loc10_ = int(ZGlobal.player.inventory[_loc7_.item]);
               TextFieldUtil.compactTextField(m_window.progressBar_mc.info_mc.text1_tf,ZGameUtils.ZlocT("Dialogs","Alliance_Quest_Bonds_me",{"total":_loc10_}));
               TextFieldUtil.compactTextField(m_window.progressBar_mc.info_mc.text2_tf,ZGameUtils.ZlocT("Dialogs","Alliance_Quest_Bonds",{"total":_loc9_ - _loc10_}));
               _loc11_ = Math.min(AllianceQuestManager.MAX_BUY_ITEMS,_loc7_.remainingItemAmount);
               if(this.m_buy_bond)
               {
                  this.m_buy_bond.dispose();
                  this.m_buy_bond = null;
               }
               this.m_buy_number = _loc11_;
               _loc12_ = ZGlobal.gameSettings.getItemByCode(_loc7_.item,GameItem) as GameItem;
               this.m_buy_bond = new ZGameButton(m_window.progressBar_mc.info_mc.buy_bt,this.buyBonds);
               this.m_buy_bond.text = ZGameUtils.ZlocT("Dialogs","Alliance_Quest_BuyBonds",{
                  "number":this.m_buy_number,
                  "value":_loc12_.cash * this.m_buy_number
               });
               this.m_buy_bond.enable();
               _loc5_ = _loc9_ / (_loc8_ / 4);
            }
         }
         var _loc3_:Object = this.m_quest.getRewardTextObject();
         if(_loc3_)
         {
            _loc13_ = ImageLoaderFactory.CreateImageLoader(_loc3_.rewardIcons[0],m_window.marker1_mc.icon);
            TextFieldUtil.compactTextField(m_window.marker1_mc.itemname_tf,_loc3_.rewardPairs[0].reward);
            _loc13_.smooth = true;
            m_window.marker1_mc.check_mc.visible = _loc5_ > 0 ? true : false;
            _loc5_--;
            _loc14_ = ImageLoaderFactory.CreateImageLoader(_loc3_.rewardIcons[1],m_window.marker2_mc.icon);
            TextFieldUtil.compactTextField(m_window.marker2_mc.itemname_tf,_loc3_.rewardPairs[1].reward);
            _loc14_.smooth = true;
            m_window.marker2_mc.check_mc.visible = _loc5_ > 0 ? true : false;
            _loc5_--;
            _loc15_ = ImageLoaderFactory.CreateImageLoader(_loc3_.rewardIcons[2],m_window.marker3_mc.icon);
            TextFieldUtil.compactTextField(m_window.marker3_mc.itemname_tf,_loc3_.rewardPairs[2].reward);
            _loc15_.smooth = true;
            m_window.marker3_mc.check_mc.visible = _loc5_ > 0 ? true : false;
            _loc5_--;
            _loc16_ = ImageLoaderFactory.CreateImageLoader(_loc3_.rewardIcons[3],m_window.marker4_mc.icon);
            TextFieldUtil.compactTextField(m_window.marker4_mc.itemname_tf,_loc3_.rewardPairs[3].reward);
            _loc16_.smooth = true;
            m_window.marker4_mc.check_mc.visible = _loc5_ > 0 ? true : false;
         }
         if(AlliancesManager.instance.isInitialised())
         {
            this.setupAlliance();
         }
         else
         {
            this.setupNoAlliance();
         }
      }
      
      private function buyBonds(param1:MouseEvent) : void
      {
         var _loc5_:String = null;
         var _loc6_:Array = null;
         var _loc7_:ZGamePopUp = null;
         this.m_buy_bond.disable_visual(true);
         var _loc2_:Array = this.m_quest.createTasks();
         var _loc3_:ZGameTask = _loc2_[0];
         var _loc4_:GameItem = ZGlobal.gameSettings.getItemByCode(_loc3_.item,GameItem) as GameItem;
         if(ZGlobal.player.canBuyCash(_loc4_.cash * this.m_buy_number,true))
         {
            if(ZGlobal.gameSettings.showConfirmationPopup(_loc4_.cash * this.m_buy_number))
            {
               _loc5_ = ZGameUtils.ZlocT("Dialogs","QuestTaskBuyConfirmMsg",ZGameUtils.CashTokenReplacements(_loc4_.cash * this.m_buy_number));
               _loc6_ = new Array("EmpirePointsConfirm","allianceQuest","","");
               _loc7_ = GenericPopup2B.NewYesNo(_loc5_,null,this.buyBondsConfirmed,_loc6_);
               PopupManager.instance.push(_loc7_,0,false);
            }
            else
            {
               this.buyBondsConfirmed(null);
            }
         }
      }
      
      private function buyBondsConfirmed(param1:GenericPopupEvent) : void
      {
         if(Boolean(param1) && param1.button != GenericPopup.YES)
         {
            this.m_buy_bond.enable();
            return;
         }
         var _loc2_:Array = this.m_quest.createTasks();
         var _loc3_:ZGameTask = _loc2_[0];
         var _loc4_:GameItem = ZGlobal.gameSettings.getItemByCode(_loc3_.item,GameItem) as GameItem;
         ZGlobal.player.buyItem(_loc4_,true,this.m_buy_number);
         ZGlobal.player.addToInventory(_loc4_.code,this.m_buy_number);
         var _loc5_:Object = {"unitCode":_loc4_.code};
         TransactionManager.addTransaction(new TBuyItem(_loc4_.code,true,this.m_buy_number,_loc5_),true);
      }
      
      private function onUpdate() : void
      {
         var _loc1_:Object = new Object();
         var _loc2_:int = ZGameTimeUtil.instance.getDateStatus(_loc1_,this.m_quest.xml);
         if(_loc2_ == ZGameTimeUtil.DATE_STATUS_LATE)
         {
            QuestManager.getInstance().dispatchEvent(new WorldEvent(ZGameQuestManager.QUEST_COMPLETE,{"name":this.m_quest.name}));
            this.close();
            if(this.m_quest.isExpired())
            {
               AllianceQuestManager.instance.hideFlag();
               AllianceQuestManager.instance.init();
            }
         }
      }
      
      private function followBar(param1:int, param2:int) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = param2;
         var _loc5_:int = 550;
         var _loc6_:int = _loc5_ - m_window.progressBar_mc.info_mc.width + 40;
         var _loc7_:int = 13;
         var _loc8_:int = param1;
         var _loc9_:int = _loc5_ / (_loc4_ - _loc3_ + 1) * _loc8_;
         var _loc10_:int = _loc6_ / (_loc4_ - _loc3_ + 1) * _loc8_;
         var _loc11_:int = Math.floor(_loc9_ * _loc4_ / _loc5_);
         m_window.progressBar_mc.mask_mc.width = _loc9_;
         m_window.progressBar_mc.marker_mc.x = _loc9_ + _loc7_;
         m_window.progressBar_mc.info_mc.x = _loc10_;
      }
      
      private function memberInfo(param1:String) : Object
      {
         return AlliancesManager.instance.memberInfo(param1);
      }
      
      private function setMemberCard(param1:Number, param2:String) : void
      {
         var _loc4_:Object = null;
         var _loc5_:Player = null;
         var _loc6_:String = null;
         var _loc7_:Object = null;
         var _loc3_:MovieClip = m_window.allianceMembers_mc.cards_mc;
         TextFieldUtil.compactTextField(_loc3_["slot" + param1].name_tf,"");
         if(param2)
         {
            _loc4_ = this.memberInfo(param2);
            TextFieldUtil.compactTextField(_loc3_["slot" + param1].name_tf,_loc4_.name);
            _loc5_ = ZGlobal.player.findFriendById(param2);
            if(_loc5_)
            {
               if(this.m_cardImage[param1] != null)
               {
                  this.m_cardImage[param1].destroy();
               }
               _loc6_ = _loc5_.snUser.picture;
               if(!_loc6_)
               {
                  _loc7_ = this.memberInfo(param2);
                  if(_loc7_)
                  {
                     _loc6_ = _loc7_.image;
                  }
               }
               _loc6_ = _loc6_.replace("sslmux.local:6081","facebook.com");
               _loc3_["slot" + param1].icon.visible = true;
               this.m_cardImage[param1] = ImageLoaderFactory.CreateImageLoader(_loc6_,_loc3_["slot" + param1].icon.icon);
            }
         }
      }
   }
}

