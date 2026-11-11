package displays.screens.globalpvp
{
   import Engine.Managers.StatsManager;
   import core.ZGlobal;
   import core.managers.PVPManager;
   import core.ui.ZGameButton;
   import displays.popups.GallantPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.displays.popups.IWindow;
   import zlabs.managers.PopupManager;
   
   public class GlobalPVPInfoPopup extends GallantPopup
   {
      
      public static var MODE_OPTIN:int = 0;
      
      public static var MODE_OPTOUT:int = 1;
      
      public static var MODE_FAILOVER:int = 2;
      
      private static var m_titleLabels:Array = ["GlobalPVPInfoOptInTitle","GlobalPVPInfoOptOutTitle","GlobalPVPInfoFailOverTitle"];
      
      private static var m_descLabels:Array = ["GlobalPVPInfoOptInDesc","GlobalPVPInfoOptOutDesc","GlobalPVPInfoFailOverDesc"];
      
      private static var m_button1MCNames:Array = ["optinbutton1_mc","failoverbutton1_mc","failoverbutton1_mc"];
      
      private static var m_button1Labels:Array = ["GlobalPVPInfoOptInButton1","GlobalPVPInfoOptOutButton1","GlobalPVPInfoFailOverButton1"];
      
      private static var m_button2MCNames:Array = ["failoverbutton2_mc","failoverbutton2_mc","failoverbutton2_mc"];
      
      private static var m_button2Labels:Array = ["Cancel","ReturnButton","GlobalPVPInfoFailOverButton2"];
      
      private static var m_button1Actions:Array = ["doOptIn","doFailOver","doOptOut"];
      
      private static var m_statsKingdom:Array = ["optin","optout","optout_confirm"];
      
      private static var m_swfNames:Array = ["PU_BattleBlitzFailover.swf","PU_BattleBlitzFailover.swf","PU_BattleBlitzConfirm.swf"];
      
      private static var m_showMCs:Array = [["cross_in"],["cross_out"],[]];
      
      private static var m_hideMCs:Array = ["optinbutton1_mc","optoutbutton1_mc","failoverbutton1_mc","failoverbutton2_mc","cross_in","cross_out"];
      
      private var m_mode:int;
      
      private var m_clip:MovieClip;
      
      private var m_button1:ZGameButton;
      
      private var m_button2:ZGameButton;
      
      private var m_soundContainer:ButtonMouseEventSoundContainer = new ButtonMouseEventSoundContainer();
      
      public function GlobalPVPInfoPopup(param1:int)
      {
         this.m_mode = param1;
         var _loc2_:String = m_swfNames[this.m_mode];
         super(ZGlobal.getAssetURL("assets/displays/dialogs/" + _loc2_));
      }
      
      override protected function initializeScreen() : void
      {
         var _loc1_:String = null;
         var _loc2_:Object = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:Function = null;
         var _loc6_:String = null;
         this.m_clip = m_window.failover_mc ? m_window.failover_mc : m_window.confirm_mc;
         for each(_loc1_ in m_hideMCs)
         {
            if(this.m_clip[_loc1_])
            {
               this.m_clip[_loc1_].visible = false;
            }
         }
         _loc2_ = {"hours":PVPManager.globalPVPDurationHours};
         _loc3_ = ZGameUtils.ZlocT("Dialogs",m_titleLabels[this.m_mode],_loc2_);
         _loc4_ = ZGameUtils.ZlocT("Dialogs",m_descLabels[this.m_mode],_loc2_);
         TextFieldUtil.compactTextField(this.m_clip.title_tf,_loc3_,{"maxLines":1});
         TextFieldUtil.processTextField(this.m_clip.popup_tf,_loc4_);
         if(Boolean(m_button1MCNames[this.m_mode]) && Boolean(this.m_clip[m_button1MCNames[this.m_mode]]))
         {
            this.m_clip[m_button1MCNames[this.m_mode]].visible = true;
            _loc5_ = this[m_button1Actions[this.m_mode]] ? this[m_button1Actions[this.m_mode]] : this.doClose;
            this.m_button1 = new ZGameButton(this.m_clip[m_button1MCNames[this.m_mode]],_loc5_);
            this.m_button1.text = ZGameUtils.ZlocT("Dialogs",m_button1Labels[this.m_mode]);
            this.m_soundContainer.addButton(this.m_button1.m_overlay,ButtonSound.DEFAULT);
         }
         if(Boolean(m_button2MCNames[this.m_mode]) && Boolean(this.m_clip[m_button2MCNames[this.m_mode]]))
         {
            this.m_clip[m_button2MCNames[this.m_mode]].visible = true;
            this.m_button2 = new ZGameButton(this.m_clip[m_button2MCNames[this.m_mode]],this.doClose);
            this.m_button2.text = ZGameUtils.ZlocT("Dialogs",m_button2Labels[this.m_mode]);
            this.m_soundContainer.addButton(this.m_button2.m_overlay,ButtonSound.DEFAULT);
         }
         if(m_showMCs[this.m_mode] is Array)
         {
            for each(_loc6_ in m_showMCs[this.m_mode])
            {
               if(this.m_clip[_loc6_])
               {
                  this.m_clip[_loc6_].visible = true;
               }
            }
         }
         super.initializeScreen();
      }
      
      override protected function deinitDialog() : void
      {
         super.deinitDialog();
         if(this.m_soundContainer)
         {
            this.m_soundContainer.release();
            this.m_soundContainer = null;
         }
         if(this.m_button1)
         {
            this.m_button1.dispose();
            this.m_button1 = null;
         }
         if(this.m_button2)
         {
            this.m_button2.dispose();
            this.m_button2 = null;
         }
      }
      
      private function doOptIn(param1:MouseEvent) : void
      {
         close();
         this.onMainButtonPressed();
         PVPManager.instance.optInOut(true);
         PVPManager.instance.showGlobalPVPBar();
      }
      
      private function doOptOut(param1:MouseEvent) : void
      {
         close();
         this.onMainButtonPressed();
         PVPManager.instance.optInOut(false);
         PVPManager.instance.hideGlobalPVPBar();
      }
      
      private function doFailOver(param1:MouseEvent) : void
      {
         close();
         this.onMainButtonPressed();
         var _loc2_:IWindow = new GlobalPVPInfoPopup(MODE_FAILOVER);
         PopupManager.instance.push(_loc2_);
      }
      
      private function doClose(param1:MouseEvent) : void
      {
         StatsManager.count("stranger_pvp",m_statsKingdom[this.m_mode],"view","no");
         close();
      }
      
      private function onMainButtonPressed() : void
      {
         StatsManager.count("stranger_pvp",m_statsKingdom[this.m_mode],"view","yes");
      }
   }
}

