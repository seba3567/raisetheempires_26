package displays.popups
{
   import Engine.Classes.SocialNetworkUser;
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.ExperimentsManager;
   import core.managers.RaffleManager;
   import core.managers.WorldUpgradeManager;
   import core.managers.questManager.ZGameQuestManager;
   import core.player.Player;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import displays.screens.requests.RequestAskPartsDialog;
   import entity.GameDataComponent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import transactions.TBuyItem;
   import utils.TextFieldUtil;
   import utils.ZGameRandom;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   import zlabs.utils.TimeUtil;
   
   public class RafflePopUp extends ZGamePopUp
   {
      
      private var m_initialised:Boolean = false;
      
      private var m_entity:IEntity = null;
      
      private var m_raffleManager:RaffleManager;
      
      private var m_displayTicketDay:int;
      
      private var gdc:GameDataComponent = null;
      
      private var m_ticketData:Array;
      
      private var askButton:ZGameButton = null;
      
      private var buyButton:ZGameButton = null;
      
      private var dayButtons:Array = new Array();
      
      private var helpButton:ZGameButton = null;
      
      private var helpCloseButton:ZGameButton = null;
      
      private var startDateTimeStamp:Number = 0;
      
      private var sizeVariant:int = -1;
      
      private var m_showHintOnStart:Boolean;
      
      private var m_questId:String = "";
      
      private var m_questTextObj:Object = null;
      
      public function RafflePopUp(param1:IEntity, param2:Boolean = false)
      {
         this.m_entity = param1;
         this.m_showHintOnStart = param2;
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_RaffleDay.swf"));
         this.m_raffleManager = RaffleManager.instance;
         this.m_displayTicketDay = this.m_raffleManager.day;
         this.startDateTimeStamp = TimeUtil.dateToNumber(this.m_raffleManager.startDate,true);
         this.sizeVariant = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_RAFFLE_TICKETSIZE);
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         PopupManager.instance.notifyLoadComplete(this);
      }
      
      override public function onShow() : void
      {
         super.onShow();
         this.setupWindow();
      }
      
      private function setupWindow() : void
      {
         if(Boolean(m_window) && !this.m_initialised)
         {
            this.m_initialised = true;
            this.initDialog();
            addChild(m_window);
         }
      }
      
      override protected function initDialog() : void
      {
         var _loc3_:ImageLoader = null;
         var _loc4_:ZGameButton = null;
         super.initDialog();
         this.screen.exit_bt.addEventListener(MouseEvent.CLICK,this.onExit);
         this.screen.hint_mc.visible = this.m_showHintOnStart;
         TextFieldUtil.compactTextField(this.screen.hint_mc.title_tf,ZGameUtils.ZlocT("Dialogs","Raffle_Tutorial_Title"));
         var _loc1_:int = 1;
         while(_loc1_ <= 4)
         {
            TextFieldUtil.compactTextField(this.screen.hint_mc["step" + _loc1_.toString() + "_mc"].title_tf,ZGameUtils.ZlocT("Dialogs","Raffle_Tutorial_Heading" + _loc1_.toString()));
            this.screen.hint_mc["step" + _loc1_.toString() + "_mc"].addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverHint,false,0,true);
            this.screen.hint_mc["step" + _loc1_.toString() + "_mc"].addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOutHint,false,0,true);
            _loc1_++;
         }
         TextFieldUtil.compactTextField(this.screen.info_bt.generic_tf,"?");
         TextFieldUtil.compactTextField(this.screen.title_tf,ZGameUtils.ZlocT("Dialogs","Raffle_Title"));
         TextFieldUtil.compactTextField(this.screen.generic_tf,ZGameUtils.ZlocT("Dialogs","Raffle_Description_1",{"total":(int(this.m_raffleManager.remainingCollectTime / 86400) + 1).toString()}));
         TextFieldUtil.compactTextField(this.screen.rewardTitle_tf,ZGameUtils.ZlocT("Dialogs","Raffle_Jackpot"));
         TextFieldUtil.compactTextField(this.screen.rewardTitle0_tf,ZGameUtils.ZlocT("Dialogs",this.m_raffleManager.rewards[0].text));
         TextFieldUtil.compactTextField(this.screen.instruction0_tf,"1:" + int(1 / parseFloat(this.m_raffleManager.rewards[0].pBase)).toString());
         TextFieldUtil.compactTextField(this.screen.rewardTitle1_tf,ZGameUtils.ZlocT("Dialogs",this.m_raffleManager.rewards[1].text));
         TextFieldUtil.compactTextField(this.screen.instruction1_tf,"1:" + int(1 / parseFloat(this.m_raffleManager.rewards[1].pBase)).toString());
         TextFieldUtil.compactTextField(this.screen.rewardTitle2_tf,ZGameUtils.ZlocT("Dialogs",this.m_raffleManager.rewards[2].text));
         TextFieldUtil.compactTextField(this.screen.instruction2_tf,"1:" + int(1 / parseFloat(this.m_raffleManager.rewards[2].pBase)).toString());
         TextFieldUtil.compactTextField(this.screen.rewardTitle3_tf,ZGameUtils.ZlocT("Dialogs",this.m_raffleManager.rewards[3].text));
         TextFieldUtil.compactTextField(this.screen.instruction3_tf,"1:" + int(1 / parseFloat(this.m_raffleManager.rewards[3].pBase)).toString());
         TextFieldUtil.compactTextField(this.screen.rewardTitle4_tf,ZGameUtils.ZlocT("Dialogs",this.m_raffleManager.rewards[4].text));
         TextFieldUtil.compactTextField(this.screen.instruction4_tf,"1:" + int(1 / parseFloat(this.m_raffleManager.rewards[4].pBase)).toString());
         TextFieldUtil.compactTextField(this.screen.totalTitle_tf,ZGameUtils.ZlocT("Dialogs","Raffle_Total"));
         TextFieldUtil.compactTextField(this.screen.daysLeft_tf,ZGameUtils.ZlocT("Dialogs","Raffle_Description_1",{"total":(int(this.m_raffleManager.remainingCollectTime / 86400) + 1).toString()}));
         TextFieldUtil.compactTextField(this.screen.instructions_tf,ZGameUtils.ZlocT("Dialogs","Raffle_Instruction",{"buyableCount":this.m_raffleManager.getbuyableCount(this.sizeVariant).toString()}));
         this.askButton = new ZGameButton(this.screen.ask_bt,this.onAskClicked);
         TextFieldUtil.compactTextField(this.screen.ask_bt.generic_tf,ZGameUtils.ZlocT("Dialogs","Raffle_Button_Ask"));
         this.buyButton = new ZGameButton(this.screen.buy_bt,this.onBuyClicked);
         TextFieldUtil.compactTextField(this.screen.buy_bt.generic_tf,ZGameUtils.ZlocT("Dialogs","Raffle_Button_Buy",{
            "total":this.m_raffleManager.getbuyableCount(this.sizeVariant).toString(),
            "cost":(this.m_raffleManager.getbuyableCount(this.sizeVariant) * this.m_raffleManager.buyableTicketCost).toString()
         }));
         this.helpButton = new ZGameButton(this.screen.info_bt,this.onHelpClicked);
         this.helpCloseButton = new ZGameButton(this.screen.hint_mc.start_bt,this.onHelpCloseClicked);
         TextFieldUtil.compactTextField(this.screen.hint_mc.start_bt.generic_tf,ZGameUtils.ZlocT("Dialogs","Raffle_Tutorial_Button"));
         var _loc2_:int = 0;
         while(_loc2_ < this.m_raffleManager.rewardCount)
         {
            _loc3_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(this.m_raffleManager.rewards[_loc2_].icon),this.screen["icon" + _loc2_.toString()]);
            _loc3_.smooth = true;
            TextFieldUtil.compactTextField(this.screen["count" + _loc2_.toString() + "_tf"],"x" + this.m_raffleManager.rewards[_loc2_].count);
            if(this.screen["strength" + _loc2_.toString() + "_mc"])
            {
               TextFieldUtil.compactTextField(this.screen["strength" + _loc2_.toString() + "_mc"].strength_tf,(ZGlobal.gameSettings.getItemByCode(this.m_raffleManager.rewards[_loc2_].itemCode,UnitItem) as UnitItem).getStrength(null,WorldUpgradeManager.instance.getUpgradesByCode(this.m_raffleManager.rewards[_loc2_].itemCode)).toString());
            }
            _loc2_++;
         }
         _loc1_ = 0;
         while(_loc1_ < this.m_raffleManager.collectDuration)
         {
            this.screen["day" + _loc1_.toString() + "_bt"]["generic_tf"] = this.screen["day" + _loc1_.toString() + "_bt"].today_tf;
            TextFieldUtil.compactTextField(this.screen["day" + _loc1_.toString() + "_bt"].today_tf,ZGameUtils.ZlocT("Main","day_" + TimeUtil.days[new Date(this.startDateTimeStamp + 1000 * 86400 * _loc1_).day]));
            _loc4_ = new ZGameButton(this.screen["day" + _loc1_.toString() + "_bt"],this.onDayClicked);
            _loc4_.buttonValue = _loc1_.toString();
            this.dayButtons.push(_loc4_);
            _loc1_++;
         }
         this.m_raffleManager.addEventListener(RaffleManager.RE_DRAW,this.onreDraw);
         this.reDraw();
      }
      
      private function onreDraw(param1:Event) : void
      {
         this.reDraw();
      }
      
      private function reDraw() : void
      {
         var _loc3_:Boolean = false;
         this.updateTicketData();
         TextFieldUtil.compactTextField(this.screen.total_tf,this.gdc.userData.tickets.length);
         var _loc1_:int = 0;
         while(_loc1_ < this.m_raffleManager.collectDuration)
         {
            TextFieldUtil.compactTextField(this.screen["day" + _loc1_.toString() + "_bt"].count_tf,this.m_ticketData[_loc1_] ? this.m_ticketData[_loc1_].length : "0");
            if(_loc1_ >= this.m_raffleManager.day)
            {
               this.screen["day" + _loc1_.toString() + "_bt"].count_tf.visible = false;
               this.dayButtons[_loc1_].disable_visual(false);
            }
            else
            {
               this.screen["day" + _loc1_.toString() + "_bt"].count_tf.visible = true;
               this.dayButtons[_loc1_].enable();
            }
            _loc1_++;
         }
         var _loc2_:Boolean = false;
         this.m_questId = this.m_raffleManager.questCodePrefix + this.m_raffleManager.day.toString();
         this.m_questTextObj = ZGameQuestManager.instance.getTextObject(this.m_questId);
         if(Boolean(this.m_questTextObj.taskComplete) && Boolean(this.m_questTextObj.taskRequestable))
         {
            _loc3_ = Boolean(this.m_questTextObj.taskComplete[0]);
            _loc2_ = !_loc3_ && Boolean(this.m_questTextObj.taskRequestable[0]);
         }
         if(!_loc2_)
         {
            this.askButton.disable_visual(false);
         }
         else
         {
            this.askButton.enable();
         }
         this.drawTickets(this.m_displayTicketDay);
      }
      
      private function drawTickets(param1:int) : void
      {
         var _loc3_:int = 0;
         var _loc4_:ImageLoader = null;
         param1--;
         var _loc2_:int = 0;
         if(this.m_ticketData[param1])
         {
            _loc3_ = 0;
            while(_loc3_ < this.m_ticketData[param1].length)
            {
               if(_loc2_ >= 6)
               {
                  break;
               }
               if(this.m_ticketData[param1][_loc3_].SNID != -1)
               {
                  TextFieldUtil.compactTextField(this.screen["ticket" + _loc2_.toString()].number_tf,this.m_ticketData[param1][_loc3_].number);
                  if(this.m_ticketData[param1][_loc3_].picture)
                  {
                     _loc4_ = ImageLoaderFactory.CreateImageLoader(this.m_ticketData[param1][_loc3_].picture,this.screen["ticket" + _loc2_.toString()].profileloader_mc);
                     _loc4_.smooth = true;
                  }
                  this.screen["ticket" + _loc2_.toString()].visible = true;
                  _loc2_++;
               }
               _loc3_++;
            }
         }
         if(_loc2_ < 6)
         {
            while(_loc2_ < 6)
            {
               this.screen["ticket" + _loc2_.toString()].visible = false;
               _loc2_++;
            }
         }
      }
      
      private function get screen() : MovieClip
      {
         return m_window.screen_mc;
      }
      
      private function updateTicketData() : void
      {
         var _loc1_:int = 0;
         var _loc2_:String = null;
         var _loc3_:Player = null;
         var _loc4_:SocialNetworkUser = null;
         this.gdcRefresh();
         this.m_ticketData = null;
         this.m_ticketData = new Array(this.m_raffleManager.collectDuration);
         if(this.gdc.userData.hasOwnProperty("tickets"))
         {
            _loc1_ = 0;
            while(_loc1_ < this.gdc.userData.tickets.length)
            {
               if(!this.m_ticketData[int(this.gdc.userData.tickets[_loc1_].day)])
               {
                  this.m_ticketData[int(this.gdc.userData.tickets[_loc1_].day)] = new Array();
               }
               _loc2_ = "";
               _loc3_ = ZGlobal.player.findFriendById(this.gdc.userData.tickets[_loc1_].SNID);
               if(_loc3_)
               {
                  _loc4_ = _loc3_.snUser;
                  if(_loc4_)
                  {
                     _loc2_ = _loc4_.picture;
                  }
               }
               this.m_ticketData[int(this.gdc.userData.tickets[_loc1_].day)].push({
                  "number":this.gdc.userData.tickets[_loc1_].number,
                  "picture":_loc2_,
                  "SNID":this.gdc.userData.tickets[_loc1_].SNID
               });
               _loc1_++;
            }
         }
      }
      
      private function gdcRefresh() : void
      {
         if(this.m_entity)
         {
            this.gdc = GameDataComponent.getGameDataComponent(this.m_entity);
            if(!this.gdc.userData.tickets)
            {
               this.gdc.userData.tickets = [];
            }
         }
      }
      
      private function onAskClicked(param1:Event) : void
      {
         var _loc4_:GameItem = null;
         var _loc5_:Array = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         param1.stopImmediatePropagation();
         param1.stopPropagation();
         var _loc2_:String = this.m_questTextObj.taskRequestAction[0];
         var _loc3_:String = this.m_questTextObj.taskItem[0];
         if(_loc3_ != null && _loc3_.length > 0)
         {
            _loc4_ = GameItem(ZGlobal.gameSettings.getItemByCode(_loc3_,GameItem));
            if(WindowManager.isFullScreen())
            {
               WindowManager.toggleFullScreen();
            }
            _loc2_ += _loc4_.name + "&source=quest&quest=" + this.m_questId + "&task=0";
            if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_REQUEST2_MASTER) == ExperimentsManager.VARIANT_VALUE_REQUEST2_MASTER_ON)
            {
               _loc5_ = new Array();
               _loc5_["source"] = "quest";
               _loc5_["quest"] = this.m_questId;
               _loc5_["task"] = 0;
               _loc6_ = ZGameUtils.ZlocT("Dialogs","AskTicketTitle_plural",{"item":ZGameUtils.ZlocTk("Items",_loc4_.name + "_sentenceName","plural")});
               _loc7_ = ZGameUtils.ZlocT("Dialogs","AskTicketBody_plural",{"item":ZGameUtils.ZlocTk("Items",_loc4_.name + "_sentenceName","plural")});
               _loc8_ = "AskTicketToaster";
               PopupManager.instance.push(new RequestAskPartsDialog(_loc4_.name,"",_loc5_,_loc6_,_loc7_,_loc8_),0,false);
            }
            else
            {
               ExternalInterface.call("ZYFrameManager.navigateTo",_loc2_);
            }
         }
      }
      
      private function onBuyClicked(param1:Event) : void
      {
         var _loc4_:int = 0;
         var _loc5_:Number = NaN;
         var _loc6_:int = 0;
         var _loc7_:Number = NaN;
         var _loc8_:int = 0;
         var _loc9_:ZGameRandom = null;
         var _loc10_:uint = 0;
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByCode(this.m_raffleManager.itemCodes[this.m_raffleManager.collectDuration],GameItem) as GameItem;
         var _loc3_:Boolean = false;
         if(_loc2_.usesCash())
         {
            _loc4_ = _loc2_.cash * this.m_raffleManager.getbuyableCount(this.sizeVariant);
            _loc3_ = ZGlobal.player.canBuyCash(_loc4_,true);
         }
         if(_loc3_)
         {
            ZGlobal.player.buyItem(_loc2_,true,this.m_raffleManager.getbuyableCount(this.sizeVariant));
            ZGlobal.player.addToInventory(this.m_raffleManager.itemCodes[this.m_raffleManager.collectDuration],this.m_raffleManager.getbuyableCount(this.sizeVariant),true);
            TransactionManager.addTransaction(new TBuyItem(this.m_raffleManager.itemCodes[this.m_raffleManager.collectDuration],true,this.m_raffleManager.getbuyableCount(this.sizeVariant)),true);
            _loc5_ = this.startDateTimeStamp / 1000;
            _loc6_ = GlobalEngine.getTimer() / 1000;
            _loc6_ = _loc6_ + ZGlobal.player.timeWarpSeconds;
            _loc7_ = int((_loc6_ - _loc5_) / 86400);
            _loc8_ = 0;
            while(_loc8_ < this.m_raffleManager.getbuyableCount(this.sizeVariant))
            {
               if(!this.gdc.userData || !(this.gdc.userData.tickets as Array) || !this.gdc.userData.tickets.length)
               {
                  this.gdc.userData.tickets = [];
                  _loc9_ = new ZGameRandom();
                  _loc9_.init(ZGlobal.player.lastLoginTimestamp,parseInt(ZGlobal.player.uid));
                  this.gdc.userData.tickets.push({
                     "SNID":"-1",
                     "number":int(_loc9_.randBetween(this.m_raffleManager.ticketRangeStart,this.m_raffleManager.ticketRangeEnd)),
                     "day":int(_loc7_)
                  });
               }
               else
               {
                  _loc10_ = uint(this.gdc.userData.tickets.length);
                  this.gdc.userData.tickets.push({
                     "SNID":"-1",
                     "number":int(this.gdc.userData.tickets[_loc10_ - 1].number) + 2,
                     "day":int(_loc7_)
                  });
               }
               _loc8_++;
            }
            RaffleManager.instance.dispatchEvent(new Event(RaffleManager.RE_DRAW));
         }
      }
      
      private function onHelpClicked(param1:Event) : void
      {
         this.screen.hint_mc.visible = true;
      }
      
      private function onHelpCloseClicked(param1:Event) : void
      {
         this.screen.hint_mc.visible = false;
      }
      
      private function onDayClicked(param1:Event) : void
      {
         this.m_displayTicketDay = Number(param1.currentTarget.buttonValue) + 1;
         this.reDraw();
      }
      
      override protected function deinitDialog() : void
      {
         this.askButton = new ZGameButton(this.screen.ask_bt,this.onAskClicked);
         this.buyButton = new ZGameButton(this.screen.buy_bt,this.onBuyClicked);
         this.helpButton = new ZGameButton(this.screen.info_bt,this.onHelpClicked);
         this.helpCloseButton = new ZGameButton(this.screen.hint_mc.start_bt,this.onHelpCloseClicked);
         var _loc1_:int = 0;
         while(_loc1_ < this.m_raffleManager.collectDuration)
         {
            this.dayButtons[_loc1_].dispose();
            _loc1_++;
         }
         this.screen.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExit);
         this.screen.hint_mc.step1_mc.removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOutHint);
         this.screen.hint_mc.step1_mc.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverHint);
         this.screen.hint_mc.step2_mc.removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOutHint);
         this.screen.hint_mc.step2_mc.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverHint);
         this.screen.hint_mc.step3_mc.removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOutHint);
         this.screen.hint_mc.step3_mc.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverHint);
         this.screen.hint_mc.step4_mc.removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOutHint);
         this.screen.hint_mc.step4_mc.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverHint);
         this.m_raffleManager.removeEventListener(RaffleManager.RE_DRAW,this.onreDraw);
         super.deinitDialog();
      }
      
      private function onExit(param1:Event) : void
      {
         close();
      }
      
      private function onMouseOverHint(param1:MouseEvent) : void
      {
         param1.currentTarget.gotoAndStop(2);
         var _loc2_:int = 1;
         for(; _loc2_ <= 4; _loc2_++)
         {
            if(param1.currentTarget.name.toString().indexOf(_loc2_.toString()) < 0)
            {
               continue;
            }
            switch(_loc2_)
            {
               case 1:
                  TextFieldUtil.compactTextField(param1.currentTarget.generic_tf,ZGameUtils.ZlocT("Dialogs","Raffle_Tutorial_Text1"));
                  break;
               case 2:
                  TextFieldUtil.compactTextField(param1.currentTarget.generic_tf,ZGameUtils.ZlocT("Dialogs","Raffle_Tutorial_Text2",{
                     "collectDuration":this.m_raffleManager.collectDuration,
                     "maxCollectable":this.m_raffleManager.maxCollectable,
                     "buyableCount":this.m_raffleManager.getbuyableCount(this.sizeVariant).toString()
                  }));
                  break;
               case 3:
                  TextFieldUtil.compactTextField(param1.currentTarget.generic_tf,ZGameUtils.ZlocT("Dialogs","Raffle_Tutorial_Text3",{
                     "collectDuration":this.m_raffleManager.collectDuration,
                     "rewardCount":this.m_raffleManager.rewardCount - 1
                  }));
                  break;
               case 4:
                  TextFieldUtil.compactTextField(param1.currentTarget.generic_tf,ZGameUtils.ZlocT("Dialogs","Raffle_Tutorial_Text4"));
            }
         }
      }
      
      private function onMouseOutHint(param1:MouseEvent) : void
      {
         param1.currentTarget.gotoAndStop(1);
      }
   }
}

