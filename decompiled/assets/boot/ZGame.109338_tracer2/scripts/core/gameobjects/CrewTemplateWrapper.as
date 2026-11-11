package core.gameobjects
{
   import core.ZGlobal;
   import core.managers.ExpansionPriceExperimentManager;
   import init.GameSettingsInit;
   
   public class CrewTemplateWrapper
   {
      
      private var m_name:String;
      
      private var m_cost:int;
      
      private var m_positions:Array = new Array();
      
      private var m_unbuyableSlots:uint = 0;
      
      private var m_xml:XML = null;
      
      public function CrewTemplateWrapper(param1:XML, param2:int)
      {
         super();
         this.m_xml = param1;
         this.m_name = param1.@name;
         this.m_cost = param2;
         this.m_unbuyableSlots = param1.@numUnbuyableSlots;
         this.buildPositionsArray(this.m_xml.position.length());
      }
      
      public function get numUnbuyableSlots() : uint
      {
         return this.m_unbuyableSlots;
      }
      
      public function get numPositions() : int
      {
         return Math.min(GameSettingsInit.NUM_CREW_SLOTS,this.m_positions.length);
      }
      
      public function getPositionName(param1:int) : String
      {
         if(param1 < this.numPositions)
         {
            return this.m_positions[param1].key;
         }
         return null;
      }
      
      public function get price() : int
      {
         return this.m_cost;
      }
      
      private function buildPositionsArray(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         if(this.m_positions.length > 0)
         {
            this.m_positions.splice(0,this.m_positions.length);
         }
         while(_loc2_ < param1)
         {
            _loc3_ = new Object();
            _loc3_.key = this.m_xml.position[_loc2_].@key.toString();
            this.m_positions.push(_loc3_);
            _loc2_++;
         }
      }
      
      public function updateDataForCrewableExpansions() : void
      {
         var _loc1_:String = ZGlobal.gameSettings.getString("startingExpansionIndexes");
         var _loc2_:Array = _loc1_.split(",");
         var _loc3_:uint = _loc2_.length;
         var _loc4_:uint = ZGlobal.player.expansions.numBitsSet() - _loc3_;
         this.m_cost = int(ExpansionPriceExperimentManager.instance.getExpansionData(_loc4_,"cashPerCrew"));
         var _loc5_:int = int(ExpansionPriceExperimentManager.instance.getExpansionData(_loc4_,"crewRequired"));
         this.buildPositionsArray(_loc5_);
      }
   }
}

