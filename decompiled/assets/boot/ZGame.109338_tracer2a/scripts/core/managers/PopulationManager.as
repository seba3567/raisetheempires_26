package core.managers
{
   import core.ZGlobal;
   import events.PopulationEvent;
   import flash.events.EventDispatcher;
   
   public class PopulationManager extends EventDispatcher
   {
      
      public static var instance:PopulationManager = new PopulationManager();
      
      public static var visitInstance:PopulationManager = new PopulationManager();
      
      public const MEDIUM_ICON:String = "assets/game/GeneralAssetGroup_UI.swf/Population.png";
      
      private var m_maxWorkers:int = 0;
      
      private var m_staticWorkers:int = 0;
      
      private var m_maxWorkersCap:int = 0;
      
      private var m_staticWorkersCap:int = 0;
      
      public function PopulationManager()
      {
         super();
         this.reset();
      }
      
      public function set staticWorkers(param1:int) : void
      {
         this.m_staticWorkers = param1;
         this.reset();
      }
      
      public function set staticWorkersCap(param1:int) : void
      {
         this.m_staticWorkersCap = param1;
         this.reset();
      }
      
      public function reset() : void
      {
         this.m_maxWorkers = 0;
         this.m_maxWorkersCap = 0;
         this.updateMaxWorkers(ZGlobal.gameSettings.getInt("startingPopulation",0) + this.m_staticWorkers,ZGlobal.gameSettings.getInt("startingPopulationCap",0) + this.m_staticWorkersCap);
      }
      
      public function updateMaxWorkers(param1:int, param2:int = 0) : void
      {
         this.m_maxWorkers += param1;
         this.m_maxWorkersCap += param2;
         dispatchEvent(new PopulationEvent(PopulationEvent.MAX_POPULATION_CHANGE,this.m_maxWorkers,this.m_maxWorkersCap));
      }
      
      public function get maxWorkers() : int
      {
         return this.m_maxWorkers;
      }
      
      public function get maxWorkersCap() : int
      {
         return this.m_maxWorkersCap;
      }
   }
}

