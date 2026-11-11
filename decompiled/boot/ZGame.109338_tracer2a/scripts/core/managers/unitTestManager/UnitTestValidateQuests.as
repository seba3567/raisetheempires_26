package core.managers.unitTestManager
{
   import flash.events.Event;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import zlabs.debug.Logger;
   
   public class UnitTestValidateQuests
   {
      
      private var m_rawXml:XML;
      
      private var m_validTasks:Array = null;
      
      public function UnitTestValidateQuests()
      {
         super();
         this.m_validTasks = new Array("autoComplete","battleDamage","battleKill","build","buyExpansion","challengeCreate","clear","countPlaced","expandIsland","fight","finishBuilding","fullscreen","genericString","harvest","inventoryAdded","islandWin","marketAdd","marketBuy","move","neighborsAdded","openDialog","ownObjects","ownResource","place","population","pillage","pvpCombat","resourceAdded","seenFlag","select","socialXPAdded","startImmunity","state","tending","tendingRewardDropped","unlockTutorial","useConsumable","visit","zoom");
      }
      
      public function startTest() : void
      {
         var _loc1_:String = Config.BASE_PATH + "questSettings.xml";
         if(Config.usingIndexedSettings)
         {
            _loc1_ = Config.BASE_PATH + "questSettingsIndexed.xml";
         }
         var _loc2_:URLLoader = new URLLoader();
         _loc2_.addEventListener(Event.COMPLETE,this.onQuestSettingsXmlLoaded);
         _loc2_.load(new URLRequest(_loc1_));
      }
      
      public function onQuestSettingsXmlLoaded(param1:Event) : void
      {
         this.m_rawXml = XML(param1.target.data.toString());
         this.validateQuests();
      }
      
      public function validateQuests() : void
      {
         var _loc2_:XML = null;
         var _loc3_:XML = null;
         var _loc1_:Boolean = false;
         for each(_loc2_ in this.m_rawXml.quest)
         {
            if(!_loc2_.@name.toString())
            {
               Logger.error(this,"validateQuests","QUEST VALIDATION ERROR: Quest found without a name field");
               _loc1_ = true;
            }
            for each(_loc3_ in _loc2_.tasks.task)
            {
               if(!this.validateTask(_loc3_,_loc2_))
               {
                  _loc1_ = true;
               }
            }
         }
         if(this.checkForDuplicateQuestIds())
         {
            _loc1_ = true;
         }
         if(_loc1_)
         {
            Logger.error(this,"validateQuests","QUEST VALIDATION Completed with errors please check the log for more information");
         }
         else
         {
            Logger.info(this,"validateQuests","QUEST VALIDATION Completed successfully no errors found");
         }
         UnitTestManager.instance.dispatchEvent(new Event(UnitTestManager.TEST_COMPLETE));
      }
      
      public function validateTask(param1:XML, param2:XML) : Boolean
      {
         if(!param1.@action.toString())
         {
            Logger.error("","","QUEST VALIDATION ERROR: Quest: " + param2.@name.toString() + " task found without a valid action");
            return false;
         }
         if(!this.validateTaskAction(param1.@action.toString()))
         {
            Logger.error("","","QUEST VALIDATION ERROR: Quest: " + param2.@name.toString() + " task found with invalid action: " + param1.@action.toString());
            return false;
         }
         return true;
      }
      
      public function validateTaskAction(param1:String) : Boolean
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.m_validTasks.length)
         {
            if(param1 == this.m_validTasks[_loc2_])
            {
               return true;
            }
            _loc2_++;
         }
         return false;
      }
      
      public function checkForDuplicateQuestIds() : Boolean
      {
         var _loc3_:XML = null;
         var _loc4_:int = 0;
         var _loc1_:Boolean = false;
         var _loc2_:Array = new Array();
         for each(_loc3_ in this.m_rawXml.quest)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc2_.length)
            {
               if(_loc3_.@name.toString() == _loc2_[_loc4_])
               {
                  Logger.error("","","QUEST VALIDATION ERROR: Quest: " + _loc3_.@name.toString() + " has a duplicate entry.  All quests must have a unique name.");
                  _loc1_ = true;
               }
               _loc4_++;
            }
            if(!_loc1_)
            {
               _loc2_.push(_loc3_.@name.toString());
            }
         }
         return _loc1_;
      }
   }
}

