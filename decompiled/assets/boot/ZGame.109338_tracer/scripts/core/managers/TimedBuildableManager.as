package core.managers
{
   import core.ZGlobal;
   import core.entities.components.behaviors.states.BuildingPartsDialogState;
   import core.gameobjects.GameItem;
   import core.managers.autoActionsManager.AutoActionCallFunction;
   import core.managers.autoActionsManager.AutoActionPanToEntity;
   import core.managers.autoActionsManager.AutoActionShowSpeechPopup;
   import dispatchers.UIDispatcher;
   import displays.screens.partsGather.TimedBuildablePartsGather;
   import entity.GameDataComponent;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.utils.Dictionary;
   import utils.ZGameTimeUtil;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   
   public class TimedBuildableManager extends EventDispatcher
   {
      
      private static var m_instance:TimedBuildableManager;
      
      public static const NUMOFPARTS:int = 6;
      
      public static const DAYS_PER_CYCLE:int = 6;
      
      public static const REWARD_DAYS:Array = [6,12,18,24];
      
      public static const TOKEN_REWARD_COIN_COUNT:int = 1000;
      
      public static const DEFAULT_VERSION:int = 1;
      
      public static const PLAY_AGAIN_VERSION:int = 2;
      
      public static const PLAY_AGAIN_CLASS_NAME:String = "TimedBuildablePlayAgain";
      
      private static var m_instances:Array = new Array();
      
      private var m_Xml:XML = null;
      
      protected var m_List:Dictionary = new Dictionary();
      
      public function TimedBuildableManager(param1:IEventDispatcher = null)
      {
         super();
         this.m_Xml = ZGlobal.gameSettings.getTimedBuildable();
         var _loc2_:int = this.m_Xml.reskin.length();
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            this.m_List[this.m_Xml.reskin[_loc3_].@ReskinID.toString()] = this.m_Xml.reskin[_loc3_];
            _loc3_++;
         }
      }
      
      public static function get instance() : TimedBuildableManager
      {
         if(!m_instance)
         {
            m_instance = new TimedBuildableManager();
         }
         return m_instance;
      }
      
      public function getTimedBuildables() : XML
      {
         return this.m_Xml;
      }
      
      public function getHUDItems() : XMLList
      {
         return ZGlobal.gameSettings.getTimedBuildableHudIcons();
      }
      
      public function getTimeRemainingForIndex(param1:String) : int
      {
         var _loc2_:Object = {"stringNotUsed":true};
         var _loc3_:int = ZGameTimeUtil.instance.getDateStatus(_loc2_,this.m_List[param1]);
         if(_loc3_ == ZGameTimeUtil.DATE_STATUS_ACTIVE || _loc3_ == ZGameTimeUtil.DATE_STATUS_EARLY)
         {
            return _loc2_.delta;
         }
         return 0;
      }
      
      public function getNumOfCycles(param1:String) : int
      {
         return int(this.m_List[param1].@noOfCycles);
      }
      
      public function getNumOfDays(param1:String) : int
      {
         return int(this.m_List[param1].@noOfDays);
      }
      
      public function getRewards(param1:String) : XMLList
      {
         return this.m_List[param1].reward;
      }
      
      public function isManyRewards(param1:String) : Boolean
      {
         if(this.m_List[param1].@manyRewards.toString())
         {
            return true;
         }
         return false;
      }
      
      public function manyRewardsURL(param1:String) : String
      {
         return this.m_List[param1].@manyRewards;
      }
      
      public function showStory(param1:String, param2:String) : void
      {
         var _loc4_:AutoActionPanToEntity = null;
         var _loc5_:AutoActionShowSpeechPopup = null;
         var _loc6_:AutoActionCallFunction = null;
         var _loc3_:IEntity = this.getBuildingByCode(param1);
         if(!_loc3_)
         {
            return;
         }
         _loc6_ = new AutoActionCallFunction();
         _loc6_.data = {
            "func":this.openPartsGather,
            "args":param1
         };
         _loc5_ = new AutoActionShowSpeechPopup();
         _loc5_.data = {"speechId":this.m_List[param2].@speechId};
         _loc5_.setNextAction(_loc6_);
         _loc4_ = new AutoActionPanToEntity();
         _loc4_.data = {"target":_loc3_};
         _loc4_.setNextAction(_loc5_);
         _loc4_.nextActionTimeDelay = 2600;
         _loc4_.startAction();
      }
      
      public function getBuildingByCode(param1:String) : IEntity
      {
         var _loc4_:Dictionary = null;
         var _loc5_:Object = null;
         var _loc6_:GameDataComponent = null;
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByCode(param1,GameItem) as GameItem;
         var _loc3_:IEntity = null;
         if(_loc2_)
         {
            _loc4_ = WorldObjectManager.instance.getObjectsBySubType(_loc2_.type,_loc2_.subType);
            for each(_loc5_ in _loc4_)
            {
               _loc6_ = GameDataComponent(_loc5_.lookupComponentByType(GameDataComponent));
               if((Boolean(_loc6_)) && _loc6_.gameData.code == param1)
               {
                  _loc3_ = _loc6_.owner;
                  break;
               }
            }
         }
         return _loc3_;
      }
      
      public function openPartsGather(param1:String) : void
      {
         if(!TimedBuildablePartsGather.isTimedBuildableOpen())
         {
            UIDispatcher.instance.dispatchEvent(new WorldEvent(BuildingPartsDialogState.SHOW_BUILDING_PART_DIALOG + param1));
         }
      }
      
      public function getVersion(param1:String) : int
      {
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByCode(param1,GameItem) as GameItem;
         if(_loc2_.className == PLAY_AGAIN_CLASS_NAME)
         {
            return PLAY_AGAIN_VERSION;
         }
         return DEFAULT_VERSION;
      }
   }
}

