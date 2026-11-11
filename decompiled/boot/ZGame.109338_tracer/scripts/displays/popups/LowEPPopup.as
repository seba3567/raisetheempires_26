package displays.popups
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.managers.ExperimentsManager;
   import core.ui.ZGameButton;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import transactions.TSetTag;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   
   public class LowEPPopup extends GallantPopup
   {
      
      private static const VARIANT_SHOW_GOLD_MIDDLE:int = 3;
      
      private static const VARIANT_SHOW_GOLD_HIGHEST:int = 4;
      
      public static const TAG_LOW_EP_POPUP_VIEWCOUNT:String = "LOW_EP_POPUP_VIEWCOUNT";
      
      public static const TAG_LOW_EP_POPUP_VIEWLASTTS:String = "LOW_EP_POPUP_VIEWLASTTS";
      
      private var m_offers:Array = null;
      
      private var m_cards:Array = null;
      
      private var m_buttons:Array = null;
      
      public function LowEPPopup(param1:Array)
      {
         this.m_offers = param1;
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_LowEP.swf"));
      }
      
      override protected function initializeScreen() : void
      {
         var _loc4_:Boolean = false;
         super.initializeScreen();
         contentWidth = this.mc.bg_mc.width;
         contentHeight = this.mc.bg_mc.height;
         centerWithinStage(Zlab.mainStage);
         this.mc.exit_bt.addEventListener(MouseEvent.CLICK,this.exitButtonClicked,false,0,true);
         this.m_buttons = new Array();
         var _loc1_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_LOWEP_POPUP.name);
         this.m_cards = [this.mc.card0,this.mc.card1,this.mc.card2];
         var _loc2_:int = 0;
         while(_loc2_ < this.m_cards.length)
         {
            _loc4_ = _loc2_ == 1 && _loc1_ == VARIANT_SHOW_GOLD_MIDDLE || _loc2_ == 2 && _loc1_ == VARIANT_SHOW_GOLD_HIGHEST;
            this.initCard(this.m_cards[_loc2_],this.m_offers[_loc2_],_loc4_);
            _loc2_++;
         }
         TextFieldUtil.compactTextField(this.mc.title_tf,ZGameUtils.ZlocT("Dialogs","LowEPPopup_Title"));
         TextFieldUtil.compactTextField(this.mc.popupBox_tf,ZGameUtils.ZlocT("Dialogs","LowEPPopup_Description"));
         StatsManager.count("low_ep_popup","display",String(ZGlobal.player.cash));
         var _loc3_:TSetTag = new TSetTag(LowEPPopup.TAG_LOW_EP_POPUP_VIEWCOUNT);
         _loc3_.doAsIncrement();
         TransactionManager.addTransaction(_loc3_);
         TransactionManager.addTransaction(new TSetTag(LowEPPopup.TAG_LOW_EP_POPUP_VIEWLASTTS,GlobalEngine.serverTime));
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:ZGameButton = null;
         var _loc2_:MovieClip = null;
         for each(_loc1_ in this.m_buttons)
         {
            if(_loc1_)
            {
               _loc1_.dispose();
            }
         }
         this.m_buttons = null;
         for each(_loc2_ in this.m_cards)
         {
            this.disposeCard(_loc2_);
         }
         super.deinitDialog();
      }
      
      private function get mc() : MovieClip
      {
         return m_window.dialog_mc;
      }
      
      private function initCard(param1:MovieClip, param2:XML, param3:Boolean = false) : void
      {
         var _loc4_:ZGameButton = null;
         if(param2)
         {
            param1.bg_mc_gold.visible = param3;
            TextFieldUtil.processTextField(param1.points_tf,String(param2.@ep));
            TextFieldUtil.compactTextField(param1.price_tf,ZGameUtils.ZlocT("Dialogs","LowEPPopup_CardPrice",{"cost":"$" + String(param2.@cost)}));
            _loc4_ = new ZGameButton(param1.accept_bt,this.onPurchase);
            _loc4_.text = ZGameUtils.ZlocT("Dialogs","LowEPPopup_ButtonPurchase");
            this.m_buttons.push(_loc4_);
            param1.visible = true;
            param1.addEventListener(MouseEvent.CLICK,this.onPurchase,false,0,true);
         }
         else
         {
            param1.visible = false;
         }
      }
      
      private function disposeCard(param1:MovieClip) : void
      {
         param1.removeEventListener(MouseEvent.CLICK,this.onPurchase);
      }
      
      private function onPurchase(param1:MouseEvent) : void
      {
         var _loc3_:XML = null;
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc2_:int = this.indexOfCardContaining(param1.target as DisplayObject);
         if(_loc2_ >= 0 && Boolean(this.m_offers[_loc2_]))
         {
            _loc3_ = this.m_offers[_loc2_];
            _loc4_ = "low_ep_popup";
            ExternalInterface.call("openInAppPurchaseAPI",ZGlobal.GAME_ID.toString(),ZGlobal.snid.toString(),ZGlobal.snuid,ZGlobal.clientID,String(_loc3_.@paymentsItem),String(_loc3_.@paymentsQty),_loc4_);
            _loc5_ = 1;
            StatsManager.count("low_ep_popup","package_click",String(_loc2_),String(_loc3_.@cost),String(_loc5_));
         }
         close();
      }
      
      private function indexOfCardContaining(param1:DisplayObject) : int
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.m_cards.length)
         {
            if(this.m_cards[_loc2_].contains(param1))
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
      
      private function exitButtonClicked(param1:MouseEvent) : void
      {
         close();
      }
   }
}

