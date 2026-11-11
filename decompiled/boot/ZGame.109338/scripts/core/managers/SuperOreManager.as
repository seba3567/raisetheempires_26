package core.managers
{
   import core.ZGlobal;
   import core.entities.components.BuildingFSMComponent;
   import core.entities.components.behaviors.BehaviorStateMachine;
   import core.managers.mayhemManager.MayhemManager;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import zlabs.entity.IEntity;
   
   public class SuperOreManager extends EventDispatcher
   {
      
      public static var instance:SuperOreManager = new SuperOreManager();
      
      public static const ITEM_CODE:String = "S01";
      
      protected var m_resourceOrder:Array = new Array();
      
      protected var m_itemCode:String = ITEM_CODE;
      
      public function SuperOreManager(param1:IEventDispatcher = null)
      {
         super(param1);
      }
      
      public function findLastUnlocked() : int
      {
         var _loc2_:String = null;
         var _loc1_:int = -1;
         for each(_loc2_ in this.m_resourceOrder)
         {
            if(!ZGlobal.player.hasResourceUnlock(_loc2_))
            {
               break;
            }
            _loc1_++;
         }
         return _loc1_;
      }
      
      public function set resourceOrder(param1:Array) : void
      {
         this.m_resourceOrder = param1;
      }
      
      public function get resourceOrder() : Array
      {
         return this.m_resourceOrder;
      }
      
      public function unlockResource(param1:uint = 0) : void
      {
         var _loc2_:String = null;
         for each(_loc2_ in this.m_resourceOrder)
         {
            if(!ZGlobal.player.hasResourceUnlock(_loc2_,param1))
            {
               ZGlobal.player.unlockResource(_loc2_,param1);
               break;
            }
         }
      }
      
      public function lastUnlockResource() : String
      {
         var _loc2_:String = null;
         var _loc1_:String = null;
         for each(_loc2_ in this.m_resourceOrder)
         {
            if(!ZGlobal.player.hasResourceUnlock(_loc2_))
            {
               break;
            }
            _loc1_ = _loc2_;
         }
         return _loc1_;
      }
      
      public function getResourceName() : String
      {
         var _loc2_:BuildingFSMComponent = null;
         var _loc3_:BehaviorStateMachine = null;
         var _loc1_:IEntity = MayhemManager.instance.getBuildingByCode(this.m_itemCode);
         if(_loc1_)
         {
            _loc2_ = BuildingFSMComponent(_loc1_.lookupComponentByType(BuildingFSMComponent));
            _loc3_ = _loc2_.stateMachine as BehaviorStateMachine;
            return _loc3_.resourceType;
         }
         return null;
      }
   }
}

