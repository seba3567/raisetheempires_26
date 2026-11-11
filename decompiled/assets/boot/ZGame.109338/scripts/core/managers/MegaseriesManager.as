package core.managers
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateMachine;
   import core.entities.components.behaviors.states.QuestCompletionState;
   import core.gamemode.GMObjectPlace;
   import core.gamemode.GameModeManager;
   import core.gameobjects.GameItem;
   import core.player.Megaseries;
   import events.MarketEvent;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   
   public class MegaseriesManager extends EventDispatcher
   {
      
      private static var m_eventDispatcher:BehaviorStateMachine;
      
      public static const MEGASERIES_REWARD_ACCEPT:String = "megaseries_reward_accept";
      
      public static const MEGASERIES_STATEMACHINE_NAME:String = "MegaSeriesEntryPointPlayAgainStateMachine";
      
      private static var m_instance:MegaseriesManager = new MegaseriesManager();
      
      private static var m_entryPtEventDispatcher:Dictionary = new Dictionary();
      
      private static var m_msList:Dictionary = new Dictionary();
      
      private static var m_xml:XMLList = null;
      
      private static var m_msQuests:Dictionary = new Dictionary();
      
      public var m_completedQuests:Array;
      
      public function MegaseriesManager()
      {
         super();
         this.addEventListener(MEGASERIES_REWARD_ACCEPT,this.megaserisRewardAccept);
      }
      
      public static function get instance() : MegaseriesManager
      {
         return m_instance;
      }
      
      public static function registerEntryPointEventDispatcher(param1:BehaviorStateMachine) : void
      {
         m_eventDispatcher = param1;
      }
      
      public function megaserisRewardAccept(param1:WorldEvent) : void
      {
         var _loc2_:GameItem = null;
         var _loc3_:int = 0;
         if(ZGlobal.isHome())
         {
            _loc2_ = ZGlobal.gameSettings.getItemByCode(param1.eventData.item,GameItem) as GameItem;
            if(_loc2_)
            {
               _loc3_ = ZGlobal.player.getNumberOfInventoryItems(param1.eventData.item);
               if(_loc3_ > 0)
               {
                  GameModeManager.instance.addGameMode(new GMObjectPlace(_loc2_.name,MarketEvent.SOURCE_INVENTORY,true));
               }
            }
         }
      }
      
      public function setCompletedQuest(param1:Array) : void
      {
         this.m_completedQuests = param1;
      }
      
      public function didCompleteQuest(param1:String) : Boolean
      {
         var _loc2_:String = null;
         if(null == this.m_completedQuests)
         {
            return false;
         }
         for each(_loc2_ in this.m_completedQuests)
         {
            if(_loc2_ == param1)
            {
               return true;
            }
         }
         return false;
      }
      
      public function isMegaseriesReward(param1:String) : String
      {
         var _loc2_:Megaseries = null;
         for each(_loc2_ in m_msList)
         {
            if(param1 == _loc2_.msRewardQuest)
            {
               return _loc2_.id;
            }
         }
         return null;
      }
      
      public function getMegaSeriesID(param1:String) : String
      {
         var _loc2_:Megaseries = null;
         for each(_loc2_ in m_msList)
         {
            if(param1 == _loc2_.displayReward)
            {
               return _loc2_.id;
            }
         }
         return null;
      }
      
      public function isMegaseriesStageCompletion(param1:String) : Boolean
      {
         var _loc2_:Megaseries = null;
         for each(_loc2_ in m_msList)
         {
            if(_loc2_.isStageCompletionQuest(param1))
            {
               return true;
            }
         }
         return false;
      }
      
      public function getStateMachineName(param1:String) : String
      {
         var _loc2_:Megaseries = this.getMegaseries(param1);
         if(_loc2_ != null)
         {
            return _loc2_.stateMachineName;
         }
         return null;
      }
      
      public function getPlayAgainText(param1:String) : Array
      {
         var _loc2_:Megaseries = this.getMegaseries(param1);
         if(_loc2_ != null)
         {
            return _loc2_.playAgainText;
         }
         return null;
      }
      
      public function notifyMSStageCompletion(param1:String, param2:Object) : void
      {
         this.getMegaseries(param1).notifyStageCompletion(param2);
      }
      
      public function setBuildableEntity(param1:String, param2:IEntity) : void
      {
         this.getMegaseries(param1).setBuildableEntity(param2);
      }
      
      public function isMegaseriesQuestComplete(param1:String) : Boolean
      {
         if(this.getMegaseries(param1) != null)
         {
            return this.getMegaseries(param1).isMegaseriesQuestCompleted();
         }
         return false;
      }
      
      public function notifyMSCompletion(param1:Object) : void
      {
         m_eventDispatcher.propertyBag.eventDispatcher.dispatchEvent(new WorldEvent(QuestCompletionState.QUEST_COMPLETE,param1));
      }
      
      public function initFromSettings(param1:XMLList) : void
      {
         m_xml = param1;
      }
      
      public function setActiveMS(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:XML = null;
         for(_loc2_ in param1.megaseriesList)
         {
            for each(_loc3_ in m_xml.megaSeries)
            {
               if(_loc2_ == _loc3_.@id.toString())
               {
                  m_msList[_loc2_.toString()] = new Megaseries(_loc3_,param1.megaseriesList[_loc2_]);
               }
            }
         }
      }
      
      public function getAssetPopupFile(param1:String) : String
      {
         var _loc2_:Megaseries = this.getMegaseries(param1);
         if(_loc2_ != null)
         {
            return _loc2_.msAssetPopup;
         }
         return null;
      }
      
      public function getPlayAgainAssetPopupFile(param1:String) : String
      {
         var _loc2_:Megaseries = this.getMegaseries(param1);
         if(_loc2_ != null)
         {
            return _loc2_.msplayAgainAssetPopup;
         }
         return null;
      }
      
      public function getQuestPopupFile(param1:String) : String
      {
         var _loc2_:Megaseries = this.getMegaseries(param1);
         if(_loc2_ != null)
         {
            return _loc2_.questPopup;
         }
         return null;
      }
      
      public function getStageReward(param1:String) : Array
      {
         var _loc2_:Megaseries = this.getMegaseries(param1);
         if(_loc2_ != null)
         {
            return _loc2_.stageReward;
         }
         return null;
      }
      
      public function getActiveQuest(param1:String) : String
      {
         var _loc2_:Megaseries = this.getMegaseries(param1);
         return _loc2_.getActiveQuest();
      }
      
      public function getMegaseries(param1:String) : Megaseries
      {
         if(m_msList.hasOwnProperty(param1))
         {
            return m_msList[param1];
         }
         return null;
      }
      
      public function doProgressMegaseries(param1:String) : void
      {
         var _loc2_:String = this.isMegaseriesQuest(param1);
         if(_loc2_ != null)
         {
            m_msList[_loc2_].doProgress();
         }
      }
      
      public function setMSQuest(param1:String, param2:String) : void
      {
         m_msQuests[param1] = param2;
      }
      
      public function isMegaseriesQuest(param1:String) : String
      {
         if(m_msQuests.hasOwnProperty(param1.toString()) && Boolean(m_msQuests[param1.toString()]))
         {
            return m_msQuests[param1.toString()];
         }
         return null;
      }
   }
}

