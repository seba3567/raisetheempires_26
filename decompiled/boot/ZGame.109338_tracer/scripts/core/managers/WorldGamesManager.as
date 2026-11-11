package core.managers
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.autoActionsManager.AutoActionPanToEntity;
   import core.managers.autoActionsManager.AutoActionShowSpeechPopup;
   import entity.GameDataComponent;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.utils.Dictionary;
   import zlabs.entity.IEntity;
   
   public class WorldGamesManager extends EventDispatcher
   {
      
      public static const BUILDING_CODE:String = "WGS1";
      
      private static var m_instance:WorldGamesManager = null;
      
      public function WorldGamesManager(param1:IEventDispatcher = null)
      {
         super(param1);
      }
      
      public static function get instance() : WorldGamesManager
      {
         if(!m_instance)
         {
            m_instance = new WorldGamesManager();
         }
         return m_instance;
      }
      
      public function onStart() : void
      {
         var _loc2_:AutoActionPanToEntity = null;
         var _loc3_:AutoActionShowSpeechPopup = null;
         var _loc1_:IEntity = this.getBuildingByCode(BUILDING_CODE);
         if(!_loc1_)
         {
            return;
         }
         _loc3_ = new AutoActionShowSpeechPopup();
         _loc3_.data = {"speechId":"Speech_WorldGames_01"};
         _loc2_ = new AutoActionPanToEntity();
         _loc2_.data = {"target":_loc1_};
         _loc2_.setNextAction(_loc3_);
         _loc2_.nextActionTimeDelay = 3000;
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
   }
}

