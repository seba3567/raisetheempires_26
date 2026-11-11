package displays.popups.alliancePopup
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.managers.AlliancesManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GallantPopup;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import transactions.clans.TBuyCrest;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   import zlabs.managers.PopupManager;
   
   public class AllianceCrestSelect extends GallantPopup
   {
      
      protected var m_xadjusted:Number;
      
      protected var m_yadjusted:Number;
      
      private var m_crest:ImageLoader;
      
      private var m_crestId:int;
      
      private var m_okbutton:ZGameButton = null;
      
      private var m_buybutton:ZGameButton = null;
      
      protected var m_totalSlots:Number;
      
      private var m_allianceManager:AlliancesManager = AlliancesManager.instance;
      
      private var m_callback1:Function;
      
      private var m_callback2:Function;
      
      private var m_isCardClicked:int;
      
      private var m_buyPopup:GenericPopup;
      
      private const TOTAL_CRESTS:int = 12;
      
      public function AllianceCrestSelect(param1:Function = null, param2:Function = null)
      {
         this.m_callback1 = param1;
         this.m_callback2 = param2;
         this.m_totalSlots = this.TOTAL_CRESTS;
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_Alliances_CrestSelect.swf"));
      }
      
      private function get screen() : MovieClip
      {
         return m_window.screen_mc;
      }
      
      private function clearCardEvents() : void
      {
         var _loc1_:Number = NaN;
         _loc1_ = 0;
         while(_loc1_ < this.m_totalSlots)
         {
            this.screen["card" + _loc1_].click_mc.removeEventListener(MouseEvent.CLICK,this.onCardClick);
            this.screen["card" + _loc1_].click_mc.removeEventListener(MouseEvent.ROLL_OVER,this.onCardOver);
            this.screen["card" + _loc1_].click_mc.removeEventListener(MouseEvent.ROLL_OUT,this.onCardOverEnd);
            _loc1_++;
         }
      }
      
      private function clearEvents() : void
      {
         this.clearCardEvents();
         this.screen.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExit);
         this.screen.ok_bt.removeEventListener(MouseEvent.CLICK,this.onExit);
      }
      
      override protected function initializeScreen() : void
      {
         var _loc1_:Number = NaN;
         this.screen.arrowRt_bt.visible = false;
         this.screen.arrowSingleRt_bt.visible = false;
         this.screen.arrowLt_bt.visible = false;
         this.screen.arrowSingleLt_bt.visible = false;
         this.m_okbutton = new ZGameButton(this.screen.ok_bt,this.onDone);
         this.m_buybutton = new ZGameButton(this.screen.buy_bt,this.onBuy);
         _loc1_ = 0;
         while(_loc1_ < this.TOTAL_CRESTS)
         {
            this.setupCard(_loc1_);
            _loc1_++;
         }
         this.invisibleAll(-1);
         this.m_isCardClicked = -1;
         this.screen.exit_bt.addEventListener(MouseEvent.CLICK,this.onExit);
         this.m_okbutton.enable();
         this.m_buybutton.disable();
         this.screen.ok_bt.visible = true;
         this.screen.buy_bt.visible = false;
         this.setupText();
         this.m_crestId = this.m_allianceManager.crestId;
         this.setMyCrest(this.m_crestId);
         super.initializeScreen();
      }
      
      protected function setupText() : void
      {
         var _loc1_:String = this.m_allianceManager.clanName;
         TextFieldUtil.compactTextField(this.screen.generic_tf,_loc1_);
         var _loc2_:String = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Member_title",{"Aname":_loc1_});
         TextFieldUtil.compactTextField(this.screen.title_tf,_loc2_);
         var _loc3_:String = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Crest_Button");
         this.m_okbutton.text = _loc3_;
      }
      
      private function onExit(param1:MouseEvent) : void
      {
         this.clearEvents();
         close();
      }
      
      private function onDone(param1:MouseEvent) : void
      {
         this.clearEvents();
         close();
         if(this.m_crestId != this.m_allianceManager.crestId)
         {
            this.m_allianceManager.crestId = this.m_crestId;
            if(this.m_callback1 != null)
            {
               this.m_callback1();
            }
            if(this.m_callback2 != null)
            {
               this.m_callback2();
            }
         }
      }
      
      private function ChangeCrest() : void
      {
         var _loc1_:TBuyCrest = new TBuyCrest(this.m_crestId);
         TransactionManager.addTransaction(_loc1_);
         ZGlobal.player.cash -= this.m_allianceManager.getCrestCost(this.m_crestId);
         this.m_allianceManager.crestId = this.m_crestId;
         if(this.m_callback1 != null)
         {
            this.m_callback1();
         }
         if(this.m_callback2 != null)
         {
            this.m_callback2();
         }
         this.clearEvents();
         close();
      }
      
      private function onBuyConfirmed(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.YES)
         {
            if(ZGlobal.player.canBuyCash(this.m_allianceManager.getCrestCost(this.m_crestId),true,"",false))
            {
               this.ChangeCrest();
            }
         }
      }
      
      private function onBuy(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:Array = null;
         if(this.m_crestId != this.m_allianceManager.crestId)
         {
            if(this.m_allianceManager.getCrestCost(this.m_crestId) > ZGlobal.gameSettings.getInt("minimumCashForConfirmation"))
            {
               _loc2_ = ZGameUtils.ZlocT("Dialogs","QuestTaskBuyConfirmMsg",ZGameUtils.CashTokenReplacements(this.m_allianceManager.getCrestCost(this.m_crestId)));
               _loc3_ = new Array("EmpirePointsConfirm","","","");
               this.m_buyPopup = GenericPopup2B.NewYesNo(_loc2_,null,this.onBuyConfirmed,_loc3_);
               PopupManager.instance.push(this.m_buyPopup,0,false);
            }
            else if(ZGlobal.player.canBuyCash(this.m_allianceManager.getCrestCost(this.m_crestId),true,"",false))
            {
               this.ChangeCrest();
            }
         }
      }
      
      protected function setupCard(param1:int) : void
      {
         var _loc3_:ImageLoader = null;
         var _loc2_:MovieClip = m_window.screen_mc["card" + param1];
         _loc2_.click_mc.addEventListener(MouseEvent.CLICK,this.onCardClick);
         _loc2_.click_mc.addEventListener(MouseEvent.ROLL_OVER,this.onCardOver);
         _loc2_.click_mc.addEventListener(MouseEvent.ROLL_OUT,this.onCardOverEnd);
         _loc2_.highlightSelect_mc.visible = false;
         _loc2_.lock_mc.visible = false;
         if(this.m_allianceManager.getCrestCost(param1) == 0)
         {
            _loc2_.cashIcon_mc.visible = false;
            _loc3_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(this.m_allianceManager.getPath(param1,64)),_loc2_.icon);
         }
         else
         {
            if(this.m_allianceManager.isCrestBought(param1))
            {
               _loc2_.cashIcon_mc.visible = false;
            }
            _loc3_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(this.m_allianceManager.getPath(param1,64)),_loc2_.icon);
         }
      }
      
      protected function setMyCrest(param1:int = 0) : void
      {
         if(this.screen.icon)
         {
            this.m_crest = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(this.m_allianceManager.getPath(param1,150)),this.screen.icon);
         }
      }
      
      private function invisibleAll(param1:int) : void
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < this.TOTAL_CRESTS)
         {
            if(this.m_isCardClicked != _loc2_)
            {
               this.screen["card" + _loc2_].highlightSelect_mc.visible = false;
            }
            _loc2_++;
         }
      }
      
      protected function onCardOverEnd(param1:MouseEvent) : void
      {
         var _loc2_:Number = NaN;
         this.invisibleAll(-1);
      }
      
      protected function onCardOver(param1:MouseEvent) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:MovieClip = null;
         _loc3_ = param1.currentTarget.parent as MovieClip;
         _loc3_.highlightSelect_mc.visible = true;
      }
      
      protected function onCardClick(param1:MouseEvent) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:String = null;
         _loc2_ = 0;
         while(_loc2_ < this.TOTAL_CRESTS)
         {
            if(param1.currentTarget == this.screen["card" + _loc2_].click_mc)
            {
               this.m_isCardClicked = _loc2_;
               this.invisibleAll(_loc2_);
               this.screen["card" + _loc2_].highlightSelect_mc.visible = true;
               this.setMyCrest(_loc2_);
               this.m_crestId = _loc2_;
               if(this.m_crestId > 6 && !this.m_allianceManager.isCrestBought(this.m_crestId))
               {
                  this.m_okbutton.disable();
                  this.m_buybutton.enable();
                  this.screen.buy_bt.visible = true;
                  this.screen.ok_bt.visible = false;
                  _loc3_ = ZGameUtils.ZlocTP("Dialogs","Alliance_Phase3_Crest_Button_Buy",{"x":this.m_allianceManager.getCrestCost(this.m_crestId)});
                  this.m_buybutton.text = _loc3_;
               }
               else
               {
                  this.m_okbutton.enable();
                  this.m_buybutton.disable();
                  this.screen.buy_bt.visible = false;
                  this.screen.ok_bt.visible = true;
               }
            }
            _loc2_++;
         }
      }
   }
}

