package displays.popups
{
   import Engine.Managers.TransactionManager;
   import ZQuest.Init.QuestSettingsInit;
   import core.ZGlobal;
   import core.managers.MegaseriesManager;
   import core.managers.questManager.ZGameQuest;
   import core.managers.questManager.ZGameQuestManager;
   import core.player.Megaseries;
   import core.ui.ZGameButton;
   import displays.popups.megaseries.MegaseriesDetailsPopup;
   import flash.events.MouseEvent;
   import transactions.TMegaSeriesReset;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   
   public class MegaseriesPlayAgain extends GallantPopup
   {
      
      protected var m_textIDs:Object;
      
      protected var m_title:String;
      
      protected var m_desc:String;
      
      protected var m_button:ZGameButton;
      
      protected var m_ms:Megaseries;
      
      protected var m_id:String;
      
      protected var m_firstQuest:String;
      
      public function MegaseriesPlayAgain(param1:String)
      {
         this.m_id = param1;
         this.m_firstQuest = ZGlobal.gameSettings.getMegaSeries(this.m_id).stage[0].node[0].@quest.toString();
         super(ZGlobal.getAssetURL(MegaseriesManager.instance.getPlayAgainAssetPopupFile(this.m_id)));
      }
      
      override protected function initializeScreen() : void
      {
         super.initializeScreen();
         this.setupUI();
      }
      
      protected function setupUI() : void
      {
         var _loc1_:Array = MegaseriesManager.instance.getPlayAgainText(this.m_id);
         if(m_window.screen_mc.title_tf)
         {
            TextFieldUtil.compactTextField(m_window.screen_mc.title_tf,ZGameUtils.ZlocT("Megaseries",String(_loc1_[0]).split(":")[1]));
         }
         if(m_window.screen_mc.generic_tf)
         {
            TextFieldUtil.compactTextField(m_window.screen_mc.generic_tf,ZGameUtils.ZlocT("Megaseries",String(_loc1_[1]).split(":")[1]));
         }
         var _loc2_:String = "TimedBuildablePlayAgain";
         this.m_button = new ZGameButton(m_window.screen_mc.playAgain_bt,this.onPlayAgain,1.1,true);
         this.m_button.compactText(ZGameUtils.ZlocT("Megaseries",String(_loc1_[2]).split(":")[1]),null);
         this.m_button.show();
         this.m_button.enable();
      }
      
      protected function onPlayAgain(param1:MouseEvent) : void
      {
         var _loc4_:Object = null;
         var _loc5_:int = 0;
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(this.m_firstQuest) as ZGameQuest;
         if(_loc2_)
         {
            if(_loc2_.hasDate)
            {
               _loc4_ = new Object();
               _loc5_ = ZGameTimeUtil.instance.getDateStatus(_loc4_,_loc2_.xml);
               if(_loc5_ == ZGameTimeUtil.DATE_STATUS_LATE)
               {
                  close();
               }
            }
         }
         var _loc3_:TMegaSeriesReset = new TMegaSeriesReset(this.m_id);
         TransactionManager.addTransaction(_loc3_);
         ZGameQuestManager.instance.megaSeriesReset(this.m_id);
         MegaseriesManager.instance.getMegaseries(this.m_id).setActiveQuest(this.m_firstQuest);
         MegaseriesDetailsPopup.show(MegaseriesManager.instance.getActiveQuest(this.m_id),this.m_id);
         close();
      }
      
      protected function onMSExpiry(param1:MouseEvent) : void
      {
         close();
      }
      
      override protected function deinitDialog() : void
      {
         if(this.m_button)
         {
            this.m_button.dispose();
            this.m_button = null;
         }
         super.deinitDialog();
      }
   }
}

