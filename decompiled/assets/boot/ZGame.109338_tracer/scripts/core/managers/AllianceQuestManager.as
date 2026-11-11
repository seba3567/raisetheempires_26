package core.managers
{
   import Engine.Managers.TransactionManager;
   import ZQuest.Init.QuestSettingsInit;
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.questManager.ZGameQuest;
   import core.managers.rewardPickupManager.RewardPickupManager;
   import core.ui.menuitem.CombatBarUIItem;
   import core.ui.menuitem.ContextualBarUIItem;
   import displays.popups.AllianceQuestsDialog;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import transactions.TAcceptAllianceQuest;
   import transactions.TAllianceQuestComplete;
   import zlabs.managers.PopupManager;
   
   public class AllianceQuestManager extends EventDispatcher
   {
      
      private static var m_instance:AllianceQuestManager = null;
      
      public static const MAX_BUY_ITEMS:int = 5;
      
      public static const SHOW_FLAG:String = "show_allaince_flag";
      
      public static const HIDE_FLAG:String = "hide_allaince_flag";
      
      private var m_questName:String;
      
      public function AllianceQuestManager()
      {
         super(null);
      }
      
      public static function get instance() : AllianceQuestManager
      {
         if(!m_instance)
         {
            m_instance = new AllianceQuestManager();
         }
         return m_instance;
      }
      
      public function setQuest(param1:String) : void
      {
         this.m_questName = param1;
      }
      
      public function grantItems() : void
      {
         var _loc1_:String = null;
         var _loc2_:ZGameQuest = null;
         var _loc3_:Array = null;
         var _loc4_:String = null;
         var _loc5_:GameItem = null;
         var _loc6_:CombatBarUIItem = null;
         for(_loc1_ in ZGlobal.player.m_acceptedAlianceQuests)
         {
            if(!ZGlobal.player.didCompleteQuest(ZGlobal.player.m_acceptedAlianceQuests[_loc1_]))
            {
               _loc2_ = QuestSettingsInit.getInstance().getItemByName(ZGlobal.player.m_acceptedAlianceQuests[_loc1_]) as ZGameQuest;
               if(Boolean(_loc2_) && Boolean(_loc2_.isAllianceQuest) && !_loc2_.isExpired())
               {
                  _loc3_ = _loc2_.createTasks();
                  if(_loc3_.length > 0)
                  {
                     _loc4_ = _loc3_[0].item;
                     if(_loc4_ != null)
                     {
                        _loc5_ = ZGlobal.gameSettings.getItemByCode(_loc4_,GameItem) as GameItem;
                        _loc6_ = ContextualBarUIItem(ContextualBarUIItem.getContextualBar()).getCombatBar();
                        RewardPickupManager.instance.add2DItemReward(new Pt(_loc6_.x / 2,_loc6_.y / 2),_loc5_,0);
                        break;
                     }
                  }
               }
            }
         }
      }
      
      public function showQuest() : void
      {
         var _loc2_:AllianceQuestsDialog = null;
         var _loc3_:TAcceptAllianceQuest = null;
         var _loc1_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(this.m_questName) as ZGameQuest;
         if(_loc1_)
         {
            _loc2_ = new AllianceQuestsDialog(_loc1_);
            PopupManager.instance.push(_loc2_);
            if(!ZGlobal.player.hasAcceptedAllianceQuest(_loc1_.name) || AlliancesManager.instance.isInitialised() && !AlliancesManager.instance.acceptedQuest(_loc1_.name))
            {
               AlliancesManager.instance.setAcceptedQuest(_loc1_.name);
               _loc3_ = new TAcceptAllianceQuest(_loc1_.name);
               TransactionManager.addTransaction(_loc3_);
               ZGlobal.player.acceptAllianceQuest(_loc1_.name);
            }
         }
      }
      
      public function hideFlag() : void
      {
         dispatchEvent(new Event(HIDE_FLAG));
      }
      
      public function showFlag() : void
      {
         dispatchEvent(new Event(SHOW_FLAG));
      }
      
      public function init() : void
      {
         var _loc1_:String = null;
         var _loc2_:ZGameQuest = null;
         var _loc3_:TAllianceQuestComplete = null;
         for(_loc1_ in ZGlobal.player.m_acceptedAlianceQuests)
         {
            if(!ZGlobal.player.didCompleteQuest(ZGlobal.player.m_acceptedAlianceQuests[_loc1_]))
            {
               _loc2_ = QuestSettingsInit.getInstance().getItemByName(ZGlobal.player.m_acceptedAlianceQuests[_loc1_]) as ZGameQuest;
               if(Boolean(_loc2_) && _loc2_.isAllianceQuest)
               {
                  if(_loc2_.isExpired())
                  {
                     _loc3_ = new TAllianceQuestComplete(ZGlobal.player.m_acceptedAlianceQuests[_loc1_]);
                     TransactionManager.addTransaction(_loc3_);
                  }
               }
            }
         }
      }
   }
}

