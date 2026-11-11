package core.gameobjects
{
   import ZQuest.Init.QuestSettingsInit;
   import core.ZGlobal;
   import core.managers.ExperimentsManager;
   import core.managers.questManager.ZGameQuest;
   import dispatchers.StrategicDispatcher;
   import flash.events.Event;
   import flash.geom.Point;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   
   public class IslandGroupItem extends GameItem
   {
      
      private var m_islands:Array = new Array();
      
      private var m_mapNumber:String = null;
      
      public function IslandGroupItem(param1:XML)
      {
         var _loc3_:XML = null;
         var _loc4_:IslandItem = null;
         var _loc2_:XML = param1.copy();
         super(_loc2_);
         for each(_loc3_ in m_xml.island)
         {
            _loc4_ = new IslandItem(_loc3_,code);
            this.m_islands.push(_loc4_);
         }
      }
      
      public function load() : void
      {
         var _loc1_:IslandItem = null;
         StrategicDispatcher.instance.dispatchEvent(new Event(StrategicDispatcher.LOAD_MAP));
         for each(_loc1_ in this.m_islands)
         {
            StrategicDispatcher.instance.dispatchEvent(new WorldEvent(StrategicDispatcher.CREATE_ISLAND,_loc1_));
         }
      }
      
      public function get unlocks() : String
      {
         return m_xml.attribute("unlocks").toString();
      }
      
      public function get title() : String
      {
         return m_xml.attribute("title").toString();
      }
      
      public function get uilocked() : Boolean
      {
         if(m_xml.@experiment != undefined)
         {
            if(ExperimentsManager.instance.getExperimentVariant(m_xml.@experiment.toString()) >= ExperimentsManager.EXPERIMENT_CAMPAIGN_2_5_ENABLED_VARIANT)
            {
               return m_xml.@uilocked.toString().length > 0 && m_xml.@uilocked.toString() == "true";
            }
            return true;
         }
         return m_xml.@uilocked.toString().length > 0 && m_xml.@uilocked.toString() == "true";
      }
      
      public function get ignorehome() : Boolean
      {
         return m_xml.@ignorehome.toString().length > 0 && m_xml.@ignorehome.toString() == "true";
      }
      
      public function get leaderboardId() : String
      {
         return m_xml.@leaderboardId.toString();
      }
      
      public function get islands() : Array
      {
         return this.m_islands;
      }
      
      public function getMapName(param1:Boolean) : String
      {
         return ZGameUtils.ZlocT("Items",villain + "_map") + (param1 ? " " + this.getMapNumber() : "");
      }
      
      public function getMapNumber() : String
      {
         var _loc1_:uint = 0;
         if(null == this.m_mapNumber)
         {
            _loc1_ = uint(this.calculateRegionIndex(villain));
            this.m_mapNumber = this.makeRoman(_loc1_);
         }
         return this.m_mapNumber;
      }
      
      private function makeRoman(param1:uint) : String
      {
         switch(param1)
         {
            case 0:
               return "I";
            case 1:
               return "II";
            case 2:
               return "III";
            case 3:
               return "IV";
            case 4:
               return "V";
            case 5:
               return "VI";
            default:
               return "0000";
         }
      }
      
      override protected function getFriendlyNameLocFile() : String
      {
         return "Campaign";
      }
      
      override public function getFriendlyName(param1:int) : String
      {
         return ZGameUtils.ZlocT(this.getFriendlyNameLocFile(),this.title);
      }
      
      public function get numIslands() : int
      {
         return this.m_islands.length;
      }
      
      public function get background() : String
      {
         var _loc1_:String = m_xml.attribute("background").toString();
         if(_loc1_.length == 0)
         {
            _loc1_ = "SeaBackground";
         }
         return _loc1_;
      }
      
      public function get foreground() : String
      {
         var _loc1_:String = m_xml.attribute("foreground").toString();
         if(_loc1_.length == 0)
         {
            _loc1_ = "SeaForeground";
         }
         return _loc1_;
      }
      
      public function calculateIndex(param1:int = 2147483647) : int
      {
         var _loc4_:XML = null;
         var _loc2_:int = 0;
         var _loc3_:Array = ZGlobal.gameSettings.getArrayOfItemXMLByType("IslandGroup");
         for each(_loc4_ in _loc3_)
         {
            if(_loc4_.@code == code)
            {
               break;
            }
            if(++_loc2_ > param1)
            {
               break;
            }
         }
         return _loc2_;
      }
      
      public function calculateRegionIndex(param1:String) : int
      {
         var _loc5_:XML = null;
         var _loc2_:uint = 0;
         var _loc3_:int = 0;
         var _loc4_:Array = ZGlobal.gameSettings.getArrayOfItemXMLByType("IslandGroup");
         for each(_loc5_ in _loc4_)
         {
            if(_loc5_.@villain == param1)
            {
               if(_loc5_.@code == code)
               {
                  return _loc2_;
               }
               _loc2_++;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function getNextIsland(param1:int) : Object
      {
         var _loc5_:int = 0;
         var _loc2_:Object = new Object();
         var _loc3_:IslandItem = this.getIslandItem(param1);
         var _loc4_:String = _loc3_.unlocks;
         if(_loc4_ != null && _loc4_.length > 0)
         {
            _loc5_ = parseInt(_loc4_);
            _loc2_.map = code;
            _loc2_.island = _loc5_;
         }
         else
         {
            _loc2_.map = this.unlocks;
            _loc2_.island = this.numIslands;
         }
         return _loc2_;
      }
      
      public function getMaxUnits(param1:int) : int
      {
         var _loc2_:IslandItem = this.getIslandItem(param1);
         return _loc2_.maxUnits;
      }
      
      public function getNumAllies(param1:int) : int
      {
         var _loc2_:IslandItem = this.getIslandItem(param1);
         return _loc2_.numAllies;
      }
      
      public function getPlayerType(param1:int) : String
      {
         var _loc2_:IslandItem = this.getIslandItem(param1);
         return _loc2_.playerType;
      }
      
      public function getPosition(param1:int) : Point
      {
         var _loc2_:IslandItem = this.getIslandItem(param1);
         return _loc2_.position;
      }
      
      public function getName(param1:int) : String
      {
         var _loc2_:IslandItem = this.getIslandItem(param1);
         return _loc2_.name;
      }
      
      public function getItem(param1:int, param2:String) : IslandItem
      {
         return this.getIslandItem(param1);
      }
      
      public function deleteIsland(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:IslandItem = null;
         var _loc4_:int = 0;
         if(param1 < this.numIslands)
         {
            this.m_islands.splice(param1,1);
            _loc2_ = param1;
            while(_loc2_ < this.numIslands)
            {
               --this.m_islands[_loc2_].index;
               _loc2_++;
            }
            for each(_loc3_ in this.m_islands)
            {
               if(_loc3_.unlocks != null)
               {
                  _loc4_ = int(_loc3_.unlocks);
                  if(_loc4_ == param1)
                  {
                     _loc3_.unlocks = "";
                  }
                  else if(_loc4_ > param1)
                  {
                     _loc3_.unlocks = String(_loc4_ - 1);
                  }
               }
            }
         }
      }
      
      public function addIsland(param1:IslandItem) : void
      {
         this.m_islands.push(param1);
         StrategicDispatcher.instance.dispatchEvent(new WorldEvent(StrategicDispatcher.CREATE_ISLAND,param1));
      }
      
      public function getIslandItem(param1:int) : IslandItem
      {
         if(param1 < this.numIslands)
         {
            return this.m_islands[param1];
         }
         return null;
      }
      
      public function get questLockedString() : String
      {
         var _loc7_:uint = 0;
         var _loc8_:ZGameQuest = null;
         var _loc9_:String = null;
         var _loc1_:String = m_xml.requiredQuest;
         var _loc2_:Array = _loc1_.split(",");
         var _loc3_:Boolean = _loc2_.length > 1;
         var _loc4_:Object = new Object();
         var _loc5_:String = null;
         if(_loc3_)
         {
            _loc7_ = 0;
            for each(_loc5_ in _loc2_)
            {
               if(ZGlobal.player.didCompleteQuest(_loc5_))
               {
                  _loc2_.splice(_loc7_,1);
               }
               _loc7_++;
            }
            _loc3_ = _loc2_.length > 1;
         }
         var _loc6_:Object = new Object();
         _loc7_ = 0;
         for each(_loc5_ in _loc2_)
         {
            _loc8_ = QuestSettingsInit.getInstance().getItemByName(_loc5_) as ZGameQuest;
            _loc9_ = ZGameUtils.ZlocT("Quests",_loc8_.title);
            if(_loc3_)
            {
               if(_loc7_ == 0)
               {
                  _loc4_.task1 = _loc9_;
               }
               else
               {
                  _loc4_.task2 = _loc9_;
               }
               _loc7_++;
            }
            else
            {
               _loc6_.task = _loc9_;
            }
         }
         if(_loc3_)
         {
            _loc6_.tasks = ZGameUtils.ZlocT("Campaign","Campaign_IslandLockedQuests",_loc4_);
         }
         return ZGameUtils.ZlocT("Campaign",_loc3_ ? "Campaign_IslandLockedMultipleQuestPopupDesc" : "Campaign_IslandLockedSingleQuestPopupDesc",_loc6_);
      }
      
      public function get questLocked() : Boolean
      {
         var _loc2_:Array = null;
         var _loc3_:Boolean = false;
         var _loc4_:Boolean = false;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc1_:String = m_xml.requiredQuest;
         if(_loc1_.length > 0)
         {
            _loc2_ = _loc1_.split(",");
            _loc3_ = m_xml.requiredQuest.@any.toString() != "true";
            _loc5_ = ZGlobal.player.level;
            for each(_loc6_ in _loc2_)
            {
               if(ZGlobal.player.didCompleteQuest(_loc6_))
               {
                  _loc4_ = true;
               }
               else if(_loc3_)
               {
                  if(ExperimentsManager.instance.experimentGateEnabled("empires_quest_dependencies","2") && _loc5_ >= 12)
                  {
                     return false;
                  }
                  return true;
               }
            }
            return !_loc4_;
         }
         return false;
      }
      
      public function get locked() : Boolean
      {
         if(this.questLocked)
         {
            return true;
         }
         return false;
      }
   }
}

