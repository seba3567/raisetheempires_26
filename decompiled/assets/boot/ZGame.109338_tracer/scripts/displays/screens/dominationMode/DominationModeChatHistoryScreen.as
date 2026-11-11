package displays.screens.dominationMode
{
   import core.ZGameStats;
   import core.ZGlobal;
   import core.managers.domination.DominationModeManager;
   import core.player.IPVPPlayer;
   import displays.popups.GallantPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.text.TextField;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class DominationModeChatHistoryScreen extends GallantPopup
   {
      
      private var m_resource:SWFResource = null;
      
      private var m_chatGrid:DominationModeChatHistoryGrid = null;
      
      private var m_pChat:Array;
      
      private var m_eChat:Array;
      
      private var m_allChat:Array;
      
      private var m_enemyID:String;
      
      private var m_abuseStringColor:uint;
      
      private var m_abuseStringTextField:TextField;
      
      private var m_isAlliance:Boolean = false;
      
      public function DominationModeChatHistoryScreen(param1:Array, param2:Array, param3:String, param4:Boolean = false)
      {
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_Pvp_MessageHistory.swf"));
         this.m_pChat = param1;
         this.m_eChat = param2;
         this.m_enemyID = param3;
         this.m_isAlliance = param4;
         if(this.m_isAlliance)
         {
            this.allianceModeFlow();
         }
         else
         {
            this.dominationModeFlow();
         }
      }
      
      private function allianceModeFlow() : void
      {
         this.m_allChat = this.m_eChat;
      }
      
      private function dominationModeFlow() : void
      {
         var _loc1_:Object = null;
         var _loc2_:String = null;
         var _loc3_:IPVPPlayer = null;
         var _loc4_:Object = null;
         for each(_loc1_ in this.m_pChat)
         {
            _loc1_.name = ZGlobal.player.firstName;
            _loc1_.player = true;
         }
         _loc2_ = ZGameUtils.ZlocT("Items","villain18_firstName");
         _loc3_ = DominationModeManager.instance.getDominationPlayer(this.m_enemyID);
         if(_loc3_)
         {
            _loc2_ = _loc3_.firstName;
         }
         for each(_loc4_ in this.m_eChat)
         {
            _loc4_.name = _loc2_;
         }
         this.m_allChat = this.m_pChat.concat(this.m_eChat);
         this.m_allChat.sortOn("ts",Array.NUMERIC);
      }
      
      private function get mc() : MovieClip
      {
         return m_window.screen_mc;
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         this.m_resource = param1;
         super.onLoadComplete(param1);
      }
      
      override protected function initializeScreen() : void
      {
         super.initializeScreen();
         this.contentWidth = this.mc.background_mc.width;
         this.contentHeight = this.mc.background_mc.height;
         ZGameUtils.hideIfExists(this.mc.background_mc);
         centerWithinStage(Zlab.mainStage);
         this.mc.grid_mc.previous_mc.visible = false;
         this.mc.exit_bt.addEventListener(MouseEvent.CLICK,this.exitButtonClicked,false,0,true);
         TextFieldUtil.processTextField(this.mc.title_tf,ZGameUtils.ZlocT("Dialogs","DominationChatTitle"));
         this.m_abuseStringTextField = this.mc.report_tf;
         this.m_abuseStringColor = this.m_abuseStringTextField.textColor;
         this.m_abuseStringTextField.addEventListener(MouseEvent.ROLL_OVER,this.onAbuseStringRollOver,false,0,true);
         this.m_abuseStringTextField.addEventListener(MouseEvent.ROLL_OUT,this.onAbuseStringRollOut,false,0,true);
         this.m_abuseStringTextField.addEventListener(MouseEvent.CLICK,this.onAbuseStringClick,false,0,true);
         TextFieldUtil.compactTextField(this.m_abuseStringTextField,ZGameUtils.ZlocT("Dialogs","DominationChatAbuse"),{
            "minScale":0.6,
            "maxLines":1
         });
         this.m_abuseStringTextField.height = this.m_abuseStringTextField.textHeight;
         this.m_abuseStringTextField.mouseEnabled = true;
         this.initGrid();
      }
      
      override protected function deinitDialog() : void
      {
         this.deinitGrid();
         if(this.m_abuseStringTextField)
         {
            this.m_abuseStringTextField.removeEventListener(MouseEvent.ROLL_OVER,this.onAbuseStringRollOver);
            this.m_abuseStringTextField.removeEventListener(MouseEvent.ROLL_OUT,this.onAbuseStringRollOut);
            this.m_abuseStringTextField.removeEventListener(MouseEvent.CLICK,this.onAbuseStringClick);
            this.m_abuseStringTextField = null;
         }
         this.mc.exit_bt.removeEventListener(MouseEvent.CLICK,this.exitButtonClicked);
         super.deinitDialog();
      }
      
      private function onAbuseStringRollOver(param1:MouseEvent) : void
      {
         this.m_abuseStringTextField.textColor = 16776960;
      }
      
      private function onAbuseStringRollOut(param1:MouseEvent) : void
      {
         this.m_abuseStringTextField.textColor = this.m_abuseStringColor;
      }
      
      private function onAbuseStringClick(param1:MouseEvent) : void
      {
         navigateToURL(new URLRequest(DominationModeManager.ABUSE_REPORT_URL),null);
      }
      
      private function initGrid() : void
      {
         this.m_chatGrid = new DominationModeChatHistoryGrid(this.mc.grid_mc,this.m_resource,this.m_allChat);
         this.m_chatGrid.show();
      }
      
      private function deinitGrid() : void
      {
         if(this.m_chatGrid)
         {
            this.m_chatGrid.dispose();
            this.m_chatGrid = null;
         }
      }
      
      private function exitButtonClicked(param1:MouseEvent) : void
      {
         var _loc2_:Object = {
            "counter":"dialog",
            "kingdom":"DominationModeChatHistoryScreen",
            "phylum":"close"
         };
         ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_GENERIC_DIALOG_ACTION,_loc2_));
         close();
      }
   }
}

