package core.managers
{
   import core.ZGlobal;
   import core.entities.components.behaviors.states.BuildingPartsDialogState;
   import core.gameobjects.GameItem;
   import core.managers.autoActionsManager.AutoActionCallFunction;
   import core.managers.autoActionsManager.AutoActionPanToEntity;
   import core.managers.autoActionsManager.AutoActionShowSpeechPopup;
   import dispatchers.UIDispatcher;
   import displays.screens.partsGather.VolcanoReskin6PartsGather;
   import entity.GameDataComponent;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.utils.Dictionary;
   import utils.ZGameTimeUtil;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   
   public class VolcanoReskin6Manager extends EventDispatcher
   {
      
      private static var m_instance:VolcanoReskin6Manager;
      
      public static const SHOWDIALOG:String = "show_dialog";
      
      public static const BUILDING_CODE:String = "BB37";
      
      public static const NUMOFPARTS:int = 6;
      
      public static const REWARD_CODE:Array = ["UU72","UU71","UU70","UU66"];
      
      public static const REWARD_MULTI:Array = [4,3,2,1];
      
      public static const REWARD_DAYS:Array = [6,12,18,24];
      
      public static const TOKEN_REWARD_COIN_COUNT:int = 1000;
      
      public function VolcanoReskin6Manager(param1:IEventDispatcher = null)
      {
         super(param1);
      }
      
      public static function get instance() : VolcanoReskin6Manager
      {
         if(!m_instance)
         {
            m_instance = new VolcanoReskin6Manager();
         }
         return m_instance;
      }
      
      public function get timeRemaining() : int
      {
         var _loc1_:XML = ZGlobal.gameSettings.getXML().volcanoReskin6[0];
         var _loc2_:Object = {"stringNotUsed":true};
         var _loc3_:int = ZGameTimeUtil.instance.getDateStatus(_loc2_,_loc1_);
         if(_loc3_ == ZGameTimeUtil.DATE_STATUS_ACTIVE || _loc3_ == ZGameTimeUtil.DATE_STATUS_EARLY)
         {
            return _loc2_.delta;
         }
         return 0;
      }
      
      public function showStory() : void
      {
         var _loc2_:AutoActionPanToEntity = null;
         var _loc3_:AutoActionShowSpeechPopup = null;
         var _loc4_:AutoActionCallFunction = null;
         var _loc1_:IEntity = this.getBuildingByCode(BUILDING_CODE);
         if(!_loc1_)
         {
            return;
         }
         _loc4_ = new AutoActionCallFunction();
         _loc4_.data = {"func":this.openPartsGather};
         _loc3_ = new AutoActionShowSpeechPopup();
         _loc3_.data = {"speechId":"Speech_Volcano_Reskin6_01"};
         _loc3_.setNextAction(_loc4_);
         _loc2_ = new AutoActionPanToEntity();
         _loc2_.data = {"target":_loc1_};
         _loc2_.setNextAction(_loc3_);
         _loc2_.nextActionTimeDelay = 2600;
         _loc2_.startAction();
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
      
      public function openPartsGather() : void
      {
         if(!VolcanoReskin6PartsGather.isVolcanoReskin6Open())
         {
            UIDispatcher.instance.dispatchEvent(new WorldEvent(BuildingPartsDialogState.SHOW_BUILDING_PART_DIALOG + BUILDING_CODE));
         }
      }
   }
}

