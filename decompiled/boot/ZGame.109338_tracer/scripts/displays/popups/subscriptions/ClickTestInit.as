package displays.popups.subscriptions
{
   import Engine.Managers.StatsManager;
   import core.ZGlobal;
   import core.ui.ZGameButton;
   import dispatchers.UIDispatcher;
   import displays.popups.GallantPopup;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class ClickTestInit extends GallantPopup
   {
      
      private static const SUBS_CLICK_TEST_DONE:String = "subs_click_test_done";
      
      private static const PRICE1:Number = 24.99;
      
      private static const PRICE2:Number = 22.99;
      
      private static const PRICE3:Number = 20.99;
      
      private static const DURATION1:int = 1;
      
      private static const DURATION2:int = 3;
      
      private static const DURATION3:int = 6;
      
      private static const CLICK_TEST_FLAG:String = "subscriptions_click_test_played";
      
      private var m_subscribeBt:ZGameButton = null;
      
      public function ClickTestInit()
      {
         super(ZGlobal.getAssetURL("assets/displays/screens/subscriptionClickTest.swf"));
      }
      
      override protected function initializeScreen() : void
      {
         super.initializeScreen();
         this.initDialogs();
         this.setupButtons();
         this.setupText();
         StatsManager.count("Subscription","Click test One","Dialog","MOTD","View");
      }
      
      private function initDialogs() : void
      {
         this.screen1.visible = true;
         this.screen2.visible = false;
         this.screen3.visible = false;
      }
      
      private function get screen1() : MovieClip
      {
         return m_window.dialog1_mc;
      }
      
      private function get screen2() : MovieClip
      {
         return m_window.dialog2_mc;
      }
      
      private function get screen3() : MovieClip
      {
         return m_window.dialog3_mc;
      }
      
      private function setupText() : void
      {
         var _loc1_:MovieClip = this.screen1;
         var _loc2_:String = ZGameUtils.ZlocT("MessageOfTheDay","motd_subscriptions_ctest_title_new");
         TextFieldUtil.compactTextField(_loc1_.title_tf,_loc2_);
         var _loc3_:String = ZGameUtils.ZlocT("MessageOfTheDay","motd_subscriptions_ctest_subtitle_new");
         TextFieldUtil.compactTextField(_loc1_.subtitle_tf,_loc3_);
         var _loc4_:String = ZGameUtils.ZlocT("MessageOfTheDay","motd_subscriptions_ctest_body1");
         var _loc5_:String = ZGameUtils.ZlocT("MessageOfTheDay","motd_subscriptions_ctest_body2_new");
         var _loc6_:String = ZGameUtils.ZlocT("MessageOfTheDay","motd_subscriptions_ctest_body3_new");
         var _loc7_:String = ZGameUtils.ZlocT("MessageOfTheDay","motd_subscriptions_ctest_body4_new");
         TextFieldUtil.compactTextField(_loc1_.generic1_tf,_loc4_);
         TextFieldUtil.compactTextField(_loc1_.generic2_tf,_loc5_);
         TextFieldUtil.compactTextField(_loc1_.generic3_tf,_loc6_);
         TextFieldUtil.compactTextField(_loc1_.generic4_tf,_loc7_);
         _loc1_ = this.screen3;
         _loc4_ = ZGameUtils.ZlocT("Dialogs","Subscriptions_ctest_confirm_body1");
         _loc5_ = ZGameUtils.ZlocT("Dialogs","Subscriptions_ctest_confirm_body2");
         _loc6_ = ZGameUtils.ZlocT("Dialogs","Subscriptions_ctest_confirm_body3");
         TextFieldUtil.compactTextField(_loc1_.title_tf,_loc4_);
         TextFieldUtil.compactTextField(_loc1_.generic1_tf,_loc5_);
         TextFieldUtil.compactTextField(_loc1_.generic2_tf,_loc6_);
      }
      
      private function setupButtons() : void
      {
         this.m_subscribeBt = new ZGameButton(this.screen1.subscribe_bt,this.onClickSubscribe);
         this.m_subscribeBt.text = ZGameUtils.ZlocT("MessageOfTheDay","motd_subscriptions_ctest_button_new");
         this.setExitButton(this.screen1.exit_bt);
         this.setExitButton(this.screen3.exit_bt);
      }
      
      private function clearEvents() : void
      {
         if(this.m_subscribeBt)
         {
            this.m_subscribeBt.dispose();
         }
         this.screen1.exit_bt.removeEventListener(MouseEvent.CLICK,this.onClose);
         this.screen3.exit_bt.removeEventListener(MouseEvent.CLICK,this.onClose);
      }
      
      private function onClose(param1:Event) : void
      {
         if(param1.currentTarget == this.screen1.exit_bt)
         {
            StatsManager.count("Subscription","Click test One","Dialog","MOTD","Close");
         }
         else if(param1.currentTarget == this.screen2.exit_bt)
         {
            StatsManager.count("Subscription","Click test One","Dialog","Confirmation","Close");
         }
         ZGlobal.player.setSeenFlag(CLICK_TEST_FLAG);
         UIDispatcher.instance.dispatchEvent(new Event(SUBS_CLICK_TEST_DONE));
         this.clearEvents();
         close();
      }
      
      private function onClickSubscribe(param1:Event) : void
      {
         this.screen1.visible = false;
         this.screen3.visible = true;
         this.screen2.visible = false;
         StatsManager.count("Subscription","Click test One","Dialog","MOTD","Yes");
         StatsManager.count("Subscription","Click test One","Dialog","Thank you","View");
      }
      
      private function setExitButton(param1:MovieClip) : void
      {
         param1.addEventListener(MouseEvent.CLICK,this.onClose);
         param1.buttonMode = true;
         param1.useHandCursor = true;
      }
   }
}

