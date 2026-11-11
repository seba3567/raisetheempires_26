package core.managers
{
   import core.ZGlobal;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   
   public class CapsuleHousingManager extends EventDispatcher
   {
      
      private static var m_instance:CapsuleHousingManager;
      
      private static var m_visitInstance:CapsuleHousingManager;
      
      protected var m_workers:int = 0;
      
      protected var m_workersCap:int = 0;
      
      public function CapsuleHousingManager(param1:IEventDispatcher = null)
      {
         super(param1);
      }
      
      public static function get instance() : CapsuleHousingManager
      {
         if(!m_instance)
         {
            m_instance = new CapsuleHousingManager();
         }
         return m_instance;
      }
      
      public static function get visitInstance() : CapsuleHousingManager
      {
         if(!m_visitInstance)
         {
            m_visitInstance = new CapsuleHousingManager();
         }
         return m_visitInstance;
      }
      
      public function initWorkers(param1:int, param2:int = 0) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         _loc3_ = param1 - this.m_workers;
         _loc4_ = param2 - this.m_workersCap;
         if(_loc3_ != 0 || _loc4_ != 0)
         {
            this.m_workers = param1;
            this.m_workersCap = param2;
            if(ZGlobal.isVisiting())
            {
               PopulationManager.visitInstance.updateMaxWorkers(_loc3_,_loc4_);
            }
            else
            {
               PopulationManager.instance.updateMaxWorkers(_loc3_,_loc4_);
            }
         }
      }
      
      public function updateWorkers(param1:int, param2:int = 0) : void
      {
         this.m_workers += param1;
         this.m_workersCap += param2;
         if(ZGlobal.isVisiting())
         {
            PopulationManager.visitInstance.updateMaxWorkers(param1,param2);
         }
         else
         {
            PopulationManager.instance.updateMaxWorkers(param1,param2);
         }
      }
      
      public function sell() : void
      {
         PopulationManager.instance.updateMaxWorkers(-this.m_workers,-this.m_workersCap);
         this.m_workers = 0;
         this.m_workersCap = 0;
      }
   }
}

