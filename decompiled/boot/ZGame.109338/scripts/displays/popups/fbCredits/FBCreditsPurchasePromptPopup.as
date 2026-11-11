package displays.popups.fbCredits
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GallantPopup;
   import fl.containers.UILoader;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.text.TextField;
   import transactions.TSetTag;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   
   public class FBCreditsPurchasePromptPopup extends GallantPopup
   {
      
      private static const DISCOUNT_PERCENTAGE:int = 80;
      
      private static const FACEBOOK_CREDITS_PURCHASED:int = 50;
      
      private static const TAG_FB_CREDITS_PROMPT_POPUP_VIEWLASTTS:String = "FB_CREDITS_PROMPT_POPUP_VIEWLASTTS";
      
      private static const VIEW_FREQUENCY:String = "2h";
      
      private var m_goButton:ZGameButton = null;
      
      private var m_loaders:Array = null;
      
      private var m_offer1UnitCode:String = null;
      
      private var m_offer2UnitCode:String = null;
      
      public function FBCreditsPurchasePromptPopup(param1:String, param2:String)
      {
         this.m_offer1UnitCode = param1;
         this.m_offer2UnitCode = param2;
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_FacebookDiscount.swf"));
      }
      
      public static function get canShow() : Boolean
      {
         var _loc1_:Number = ZGameTimeUtil.instance.parseTimeAsSeconds(VIEW_FREQUENCY,0);
         var _loc2_:Number = Number(ZGlobal.player.getTag(FBCreditsPurchasePromptPopup.TAG_FB_CREDITS_PROMPT_POPUP_VIEWLASTTS));
         var _loc3_:Number = (GlobalEngine.serverTime - _loc2_) / 1000;
         return _loc3_ + ZGlobal.player.timeWarpSeconds > _loc1_;
      }
      
      override protected function initializeScreen() : void
      {
         super.initializeScreen();
         contentWidth = this.mc.panel_mc.width;
         contentHeight = this.mc.panel_mc.height;
         centerWithinStage(Zlab.mainStage);
         this.m_loaders = new Array();
         this.mc.exit_bt.addEventListener(MouseEvent.CLICK,this.exitButtonClicked,false,0,true);
         this.m_goButton = new ZGameButton(this.mc.buy_bt,this.onGoButton);
         this.m_goButton.text = ZGameUtils.ZlocT("Dialogs","FBCreditsDiscountPromptBuyButton");
         TextFieldUtil.compactTextField(this.mc.percentOff_tf,ZGameUtils.ZlocT("Dialogs","FBCreditsDiscountPromptTitle",{"discount":DISCOUNT_PERCENTAGE}));
         TextFieldUtil.compactTextField(this.mc.info_tf,ZGameUtils.ZlocT("Dialogs","FBCreditsDiscountPromptBody2",{"discount":DISCOUNT_PERCENTAGE}));
         TextFieldUtil.compactTextField(this.mc.specialOffer_tf_01,ZGameUtils.ZlocT("Dialogs","FBCreditsDiscountPromptOffer1",{"amount":FACEBOOK_CREDITS_PURCHASED}));
         TextFieldUtil.compactTextField(this.mc.specialOffer_tf_02,ZGameUtils.ZlocT("Dialogs","FBCreditsDiscountPromptOffer2",{"amount":FACEBOOK_CREDITS_PURCHASED}));
         this.populateUnit(this.m_offer1UnitCode,this.mc.unit_icon_01,this.mc.unitName_tf_01,this.mc.strength_mc_01);
         this.populateUnit(this.m_offer2UnitCode,this.mc.unit_icon_02,this.mc.unitName_tf_02,this.mc.strength_mc_02);
         StatsManager.count("fbcreditsale2012","purchasedialog","view");
         var _loc1_:Number = GlobalEngine.serverTime;
         TransactionManager.addTransaction(new TSetTag(FBCreditsPurchasePromptPopup.TAG_FB_CREDITS_PROMPT_POPUP_VIEWLASTTS,_loc1_));
         ZGlobal.player.setTag(FBCreditsPurchasePromptPopup.TAG_FB_CREDITS_PROMPT_POPUP_VIEWLASTTS,_loc1_);
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:ImageLoader = null;
         if(this.m_goButton)
         {
            this.m_goButton.dispose();
         }
         for each(_loc1_ in this.m_loaders)
         {
            if(_loc1_)
            {
               _loc1_.destroy();
            }
         }
         this.m_loaders = null;
         super.deinitDialog();
      }
      
      private function get mc() : MovieClip
      {
         return m_window.screen_mc;
      }
      
      private function populateUnit(param1:String, param2:UILoader, param3:TextField, param4:MovieClip) : void
      {
         var _loc5_:UnitItem = ZGlobal.gameSettings.getItemByCode(param1,UnitItem) as UnitItem;
         if(_loc5_)
         {
            TextFieldUtil.compactTextField(param3,_loc5_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
            TextFieldUtil.compactTextField(param4.strength_tf,String(_loc5_.getUpgradedStrength()));
            this.m_loaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(_loc5_.name,"icon"),param2));
         }
         param2.visible = _loc5_ != null;
         param4.visible = _loc5_ != null;
      }
      
      private function onGoButton(param1:MouseEvent) : void
      {
         Logger.print(this,"**** onGoButton(), initiating ExternalInterface call to \'creditsAcquisition\'");
         ExternalInterface.call("creditsAcquisition");
         StatsManager.count("fbcreditsale2012","purchasedialog","buy");
         close();
      }
      
      private function exitButtonClicked(param1:MouseEvent) : void
      {
         close();
      }
   }
}

