package displays.popups
{
   import Engine.Managers.TransactionManager;
   import ZQuest.Managers.QuestManager;
   import core.ZGlobal;
   import core.managers.questManager.ZGameQuest;
   import core.managers.questManager.ZGameQuestManager;
   import core.ui.ZGameButton;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import transactions.TBuyQuestRestartTask;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   
   public class QuestRestartPopup extends GallantPopup
   {
      
      private var m_buyButton:ZGameButton;
      
      private var m_quest:ZGameQuest = null;
      
      public function QuestRestartPopup(param1:ZGameQuest)
      {
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_ExpiredPopup.swf"));
         this.m_quest = param1;
      }
      
      private function get clip() : MovieClip
      {
         return m_window.window_mc;
      }
      
      override protected function initDialog() : void
      {
         var _loc1_:String = null;
         super.initDialog();
         this.clip.exit_bt.addEventListener(MouseEvent.CLICK,this.onCancelClick);
         if(Boolean(this.m_quest) && this.m_quest.hasLifeTime)
         {
            _loc1_ = ZGameTimeUtil.instance.getTimeString(this.m_quest.lifeTime);
            TextFieldUtil.processTextField(this.clip.generic_tf,ZGameUtils.ZlocT("Dialogs","BuyQuestRestartMessage",{"time":_loc1_}));
            this.m_buyButton = new ZGameButton(this.clip.restart_bt,this.onBuyClick);
            this.m_buyButton.text = ZGameUtils.ZlocT("Dialogs","BuyQuestRestartButton",{"amount":this.m_quest.restartCost});
         }
      }
      
      override protected function deinitDialog() : void
      {
         super.deinitDialog();
         this.clip.exit_bt.removeEventListener(MouseEvent.CLICK,this.onCancelClick);
         this.m_buyButton.dispose();
      }
      
      private function onBuyClick(param1:MouseEvent) : void
      {
         var _loc2_:ZGameQuestManager = null;
         if(ZGlobal.player.canBuyCash(this.m_quest.restartCost))
         {
            TransactionManager.addTransaction(new TBuyQuestRestartTask(this.m_quest.name));
            ZGlobal.player.cash -= this.m_quest.restartCost;
            this.m_quest.startTime = GlobalEngine.getTimer() / 1000;
            _loc2_ = QuestManager.getInstance(null) as ZGameQuestManager;
            if(_loc2_)
            {
               _loc2_.dispatchEvent(new WorldEvent(ZGameQuestManager.QUEST_RESTARTED,this.m_quest.name));
            }
         }
         close();
      }
      
      private function onCancelClick(param1:MouseEvent) : void
      {
         close();
      }
   }
}

