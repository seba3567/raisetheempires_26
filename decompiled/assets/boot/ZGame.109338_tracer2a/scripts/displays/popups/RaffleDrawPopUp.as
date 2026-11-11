package displays.popups
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.ExperimentsManager;
   import core.managers.RaffleManager;
   import core.managers.WorldUpgradeManager;
   import core.player.Player;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import entity.GameDataComponent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import transactions.TBuyItem;
   import utils.TextFieldUtil;
   import utils.ZGameRandom;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   import zlabs.utils.TimeUtil;
   
   public class RaffleDrawPopUp extends ZGamePopUp
   {
      
      private var m_initialised:Boolean = false;
      
      private var m_numDigits:int = -1;
      
      private var m_entity:IEntity = null;
      
      private var m_raffleManager:RaffleManager;
      
      private var gdc:GameDataComponent = null;
      
      private var m_ticketData:Array;
      
      private var startButton:ZGameButton = null;
      
      private var buyButton:ZGameButton = null;
      
      private var skipButton:ZGameButton = null;
      
      private var nextButton:ZGameButton = null;
      
      private var helpButton:ZGameButton = null;
      
      private var helpCloseButton:ZGameButton = null;
      
      private var m_drawingFor:int = -1;
      
      private var m_tempWinningNumber:int = 0;
      
      private var sizeVariant:int = -1;
      
      private var m_timer:Timer = null;
      
      private var currentString:String = "";
      
      private var m_showHintOnStart:Boolean;
      
      public function RaffleDrawPopUp(param1:IEntity, param2:Boolean = false)
      {
         this.m_showHintOnStart = param2;
         this.m_entity = param1;
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_RaffleDayDraw.swf"));
         this.m_raffleManager = RaffleManager.instance;
         this.m_numDigits = Math.log(this.m_raffleManager.ticketRangeEnd) * Math.LOG10E + 1;
         this.sizeVariant = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_RAFFLE_TICKETSIZE);
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         m_window = getWindowInstance(param1);
         param1.destroy();
         this.contentWidth = 802.05;
         this.contentHeight = 615.9;
         dispatchEvent(new Event(Event.COMPLETE));
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
         super.initDialog();
         this.screen.exit_bt.addEventListener(MouseEvent.CLICK,this.onExit);
         this.screen.hint_mc.visible = this.m_showHintOnStart;
         this.m_raffleManager.addEventListener(RaffleManager.RE_DRAW,this.onreDraw);
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
         TextFieldUtil.compactTextField(this.screen.generic_tf,ZGameUtils.ZlocT("Dialogs","Raffle_Description_2"));
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
         TextFieldUtil.compactTextField(this.screen.Raffle_mc.instructions_tf,ZGameUtils.ZlocT("Dialogs","Raffle_Numbers"));
         TextFieldUtil.compactTextField(this.screen.preRaffle_mc.instructions_tf,ZGameUtils.ZlocT("Dialogs","Raffle_LastMinute"));
         TextFieldUtil.compactTextField(this.screen.preRaffle_mc.hint_tf,ZGameUtils.ZlocT("Dialogs","Raffle_LastMinuteHint"));
         this.startButton = new ZGameButton(this.screen.preRaffle_mc.start_bt,this.onStartRaffleClicked);
         TextFieldUtil.compactTextField(this.screen.preRaffle_mc.start_bt.generic_tf,ZGameUtils.ZlocT("Dialogs","Raffle_Button_Start"));
         this.buyButton = new ZGameButton(this.screen.preRaffle_mc.buy_bt,this.onBuyClicked);
         TextFieldUtil.compactTextField(this.screen.preRaffle_mc.buy_bt.generic_tf,ZGameUtils.ZlocT("Dialogs","Raffle_Button_Buy2",{
            "total":this.m_raffleManager.getbuyableCount(this.sizeVariant).toString(),
            "cost":(this.m_raffleManager.getbuyableCount(this.sizeVariant) * this.m_raffleManager.buyableTicketCost).toString()
         }));
         this.skipButton = new ZGameButton(this.screen.Raffle_mc.skip_bt,this.onRollComplete);
         TextFieldUtil.compactTextField(this.screen.Raffle_mc.skip_bt.generic_tf,ZGameUtils.ZlocT("Dialogs","Raffle_Button_Skip"));
         this.nextButton = new ZGameButton(this.screen.Raffle_mc.next_bt,this.onNextClicked);
         TextFieldUtil.compactTextField(this.screen.Raffle_mc.next_bt.generic_tf,ZGameUtils.ZlocT("Dialogs","Raffle_Button_Next"));
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
         this.reDraw();
      }
      
      private function onreDraw(param1:Event) : void
      {
         this.reDraw();
      }
      
      private function reDraw() : void
      {
         this.gdcRefresh();
         TextFieldUtil.compactTextField(this.screen.total_tf,this.gdc.userData.tickets.length);
         var _loc1_:int = 1;
         while(_loc1_ <= this.m_raffleManager.rewardCount)
         {
            this.screen["target" + _loc1_.toString() + "_mc"].visible = false;
            this.screen["hit" + (_loc1_ - 1).toString() + "_mc"].visible = false;
            this.screen["miss" + (_loc1_ - 1).toString() + "_mc"].visible = false;
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ < this.gdc.userData.winningTickets.length)
         {
            if(this.gdc.userData.winningTickets[_loc1_] != -1)
            {
               this.screen["hit" + (this.m_raffleManager.rewardCount - 1 - _loc1_).toString() + "_mc"].visible = true;
            }
            else
            {
               this.screen["miss" + (this.m_raffleManager.rewardCount - 1 - _loc1_).toString() + "_mc"].visible = true;
            }
            _loc1_++;
         }
         this.screen["target" + (this.m_raffleManager.rewardCount - this.gdc.userData.winningTickets.length).toString() + "_mc"].visible = true;
         this.m_drawingFor = this.m_raffleManager.rewardCount - this.gdc.userData.winningTickets.length;
         this.screen.preRaffle_mc.visible = true;
         this.screen.Raffle_mc.visible = false;
      }
      
      private function get screen() : MovieClip
      {
         return m_window.screen_mc;
      }
      
      private function gdcRefresh() : void
      {
         if(this.m_entity)
         {
            this.gdc = GameDataComponent.getGameDataComponent(this.m_entity);
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
            _loc5_ = TimeUtil.dateToNumber(this.m_raffleManager.startDate,true) / 1000;
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
      
      private function onStartRaffleClicked(param1:Event) : void
      {
         this.hideAllTickets();
         var _loc2_:int = 0;
         while(_loc2_ < this.m_numDigits)
         {
            this.screen.Raffle_mc["slot" + _loc2_.toString()].gotoAndPlay(1);
            _loc2_++;
         }
         this.m_raffleManager.dispatchEvent(new Event(RaffleManager.START_CLICK));
         this.screen.preRaffle_mc.visible = false;
         this.screen.Raffle_mc.visible = true;
         this.screen.Raffle_mc.info_tf.visible = false;
         this.nextButton.hide();
         StatsManager.count("game_actions","Raffle","start_raffle",int(this.m_raffleManager.rewardCount - this.m_drawingFor + 1).toString());
         this.RaffleRoll();
         this.skipButton.show();
         this.m_timer = new Timer(1500);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.m_timer.start();
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         var _loc5_:Player = null;
         var _loc6_:ImageLoader = null;
         var _loc2_:int = this.currentString.length;
         if(_loc2_ == this.m_numDigits)
         {
            if(this.m_timer)
            {
               this.m_timer.stop();
               this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
               this.m_timer = null;
            }
            this.onRollComplete();
            return;
         }
         this.screen.Raffle_mc["slot" + _loc2_.toString()].gotoAndPlay("_" + this.getDigit(_loc2_).toString());
         this.currentString += this.getDigit(_loc2_).toString();
         this.hideAllTickets();
         var _loc3_:int = 1;
         var _loc4_:int = 0;
         while(_loc4_ < this.gdc.userData.tickets.length)
         {
            if(this.gdc.userData.tickets[_loc4_].number.toString().indexOf(this.currentString) == 0)
            {
               if(this.screen.Raffle_mc["ticket" + _loc3_.toString()])
               {
                  TextFieldUtil.compactTextField(this.screen.Raffle_mc["ticket" + _loc3_.toString()].number_tf,this.gdc.userData.tickets[_loc4_].number);
                  _loc5_ = ZGlobal.player.findFriendById(this.gdc.userData.tickets[_loc4_].SNID);
                  _loc6_ = ImageLoaderFactory.CreateImageLoader(_loc5_.snUser.picture,this.screen.Raffle_mc["ticket" + _loc3_.toString()].profileloader_mc);
                  _loc6_.smooth = true;
                  this.screen.Raffle_mc["ticket" + _loc3_.toString()].visible = true;
               }
               _loc3_++;
            }
            _loc4_++;
         }
         TextFieldUtil.compactTextField(this.screen.Raffle_mc.info_tf,ZGameUtils.ZlocT("Dialogs","Raffle_Matching_1",{"total":(_loc3_ - 1).toString()}));
         this.screen.Raffle_mc.info_tf.visible = true;
      }
      
      private function onRollComplete(param1:Event = null) : void
      {
         var _loc3_:Player = null;
         var _loc4_:ImageLoader = null;
         this.skipButton.hide();
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer = null;
         }
         this.hideAllTickets();
         var _loc2_:int = this.currentString.length;
         while(_loc2_ < this.m_numDigits)
         {
            this.screen.Raffle_mc["slot" + _loc2_.toString()].gotoAndPlay("_" + this.getDigit(_loc2_).toString());
            _loc2_++;
         }
         if(this.gdc.userData.winningTickets[this.m_raffleManager.rewardCount - this.m_drawingFor] != -1)
         {
            this.screen.Raffle_mc.ticket1.visible = true;
            this.screen.Raffle_mc.ticket1.starburst_mc.visible = true;
            TextFieldUtil.compactTextField(this.screen.Raffle_mc.ticket1.number_tf,this.gdc.userData.tickets[this.gdc.userData.winningTickets[this.m_raffleManager.rewardCount - this.m_drawingFor]].number);
            _loc3_ = ZGlobal.player.findFriendById(this.gdc.userData.tickets[this.gdc.userData.winningTickets[this.m_raffleManager.rewardCount - this.m_drawingFor]].SNID);
            _loc4_ = ImageLoaderFactory.CreateImageLoader(_loc3_.snUser.picture,this.screen.Raffle_mc.ticket1.profileloader_mc);
            _loc4_.smooth = true;
            this.m_raffleManager.addReward(this.m_drawingFor - 1);
            if(this.gdc.userData.tickets[this.gdc.userData.winningTickets[this.m_raffleManager.rewardCount - this.m_drawingFor]].SNID != "-1")
            {
               PopupManager.instance.push(new RaffleRewardSharePopUp(this.gdc.userData.tickets[this.gdc.userData.winningTickets[this.m_raffleManager.rewardCount - this.m_drawingFor]].SNID,this.m_raffleManager.rewards[this.m_drawingFor - 1].giftCode,int(this.m_raffleManager.rewardCount - this.m_drawingFor + 1)),0,true,false);
            }
            TextFieldUtil.compactTextField(this.screen.Raffle_mc.info_tf,ZGameUtils.ZlocT("Dialogs","Raffle_Matching_3"));
            this.screen.Raffle_mc.info_tf.visible = true;
            this.screen["hit" + (this.m_drawingFor - 1).toString() + "_mc"].visible = true;
         }
         else
         {
            TextFieldUtil.compactTextField(this.screen.Raffle_mc.info_tf,ZGameUtils.ZlocT("Dialogs","Raffle_Matching_2"));
            this.screen.Raffle_mc.info_tf.visible = true;
            this.screen["miss" + (this.m_drawingFor - 1).toString() + "_mc"].visible = true;
         }
         this.screen["target" + this.m_drawingFor.toString() + "_mc"].visible = false;
         if(this.gdc.userData.winningTickets.length < 5)
         {
            this.nextButton.show();
         }
      }
      
      private function onNextClicked(param1:Event) : void
      {
         close();
         this.m_raffleManager.dispatchEvent(new Event(RaffleManager.ROLL_COMPLETE));
      }
      
      override protected function deinitDialog() : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer = null;
         }
         this.nextButton.dispose();
         this.startButton.dispose();
         this.buyButton.dispose();
         this.skipButton.dispose();
         this.nextButton.dispose();
         this.helpButton.dispose();
         this.helpCloseButton.dispose();
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
      
      private function onHelpClicked(param1:Event) : void
      {
         this.screen.hint_mc.visible = true;
      }
      
      private function onHelpCloseClicked(param1:Event) : void
      {
         this.screen.hint_mc.visible = false;
      }
      
      private function onExit(param1:Event) : void
      {
         close();
      }
      
      private function RaffleRoll() : void
      {
         if(!(this.gdc.userData.winningTickets as Array) || !this.gdc.userData.winningTickets.length)
         {
            this.gdc.userData.winningTickets = [];
         }
         var _loc1_:ZGameRandom = new ZGameRandom();
         _loc1_.init(ZGlobal.player.lastLoginTimestamp,parseInt(ZGlobal.player.uid));
         var _loc2_:Object = this.m_raffleManager.rewards[this.m_raffleManager.rewards.length - this.gdc.userData.winningTickets.length - 1];
         var _loc3_:Number = parseFloat(_loc2_.pBase) + parseFloat(_loc2_.pExtra) * this.gdc.userData.tickets.length;
         var _loc4_:int = -1;
         if(_loc1_.float() <= _loc3_)
         {
            StatsManager.count("game_actions","Raffle","prize_won",int(this.m_raffleManager.rewardCount - this.m_drawingFor + 1).toString());
            ZGlobal.player.addToInventory(_loc2_.code,1,true);
            _loc4_ = _loc1_.randBetween(0,this.gdc.userData.tickets.length);
            while(this.checkIfWinningTicket(_loc4_))
            {
               _loc4_ = _loc1_.randBetween(0,this.gdc.userData.tickets.length);
            }
            this.gdc.userData.winningTickets.push(_loc4_);
            this.m_tempWinningNumber = this.gdc.userData.tickets[_loc4_].number;
         }
         else
         {
            this.gdc.userData.winningTickets.push(-1);
            _loc4_ = _loc1_.randBetween(0,this.gdc.userData.tickets.length);
            this.m_tempWinningNumber = this.gdc.userData.tickets[_loc4_].number + 1;
         }
      }
      
      private function checkIfWinningTicket(param1:int) : Boolean
      {
         var _loc2_:int = 0;
         for each(_loc2_ in this.gdc.userData.winningTickets)
         {
            if(param1 == _loc2_)
            {
               return true;
            }
         }
         return false;
      }
      
      private function hideAllTickets() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < 100)
         {
            if(this.screen.Raffle_mc["ticket" + _loc1_.toString()])
            {
               this.screen.Raffle_mc["ticket" + _loc1_.toString()].visible = false;
               this.screen.Raffle_mc["ticket" + _loc1_.toString()].starburst_mc.visible = false;
            }
            _loc1_++;
         }
         this.screen.Raffle_mc.info_tf.visible = false;
      }
      
      private function getDigit(param1:int) : int
      {
         if(param1 < 0 || param1 >= this.m_numDigits)
         {
            return -1;
         }
         return this.m_tempWinningNumber / Math.pow(10,this.m_numDigits - param1 - 1) % 10;
      }
      
      private function getDigitForNumber(param1:int, param2:int) : int
      {
         if(param1 < 0 || param1 > this.m_numDigits)
         {
            return -1;
         }
         return param2 / Math.pow(10,this.m_numDigits - param1) % 10;
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

