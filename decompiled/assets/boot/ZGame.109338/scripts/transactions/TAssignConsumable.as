package transactions
{
   import core.ZGlobal;
   
   public class TAssignConsumable extends TZGameTransaction
   {
      
      private var m_name:String = null;
      
      private var m_code:String = null;
      
      private var m_map:String = null;
      
      private var m_enemyFleetName:String = null;
      
      private var m_unitId:int = -1;
      
      private var m_level:int = 0;
      
      public function TAssignConsumable(param1:String, param2:String, param3:int, param4:int, param5:String)
      {
         super();
         this.m_name = param1;
         this.m_code = param2;
         this.m_map = ZGlobal.player.campaign.currentMapName;
         this.m_enemyFleetName = param5;
         this.m_unitId = param3;
         this.m_level = param4;
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function get code() : String
      {
         return this.m_code;
      }
      
      override public function perform() : void
      {
         signedCall("WorldService.assignConsumable",modifiedData({
            "name":this.m_name,
            "map":this.m_map,
            "code":this.m_code,
            "id":this.m_unitId,
            "level":this.m_level,
            "fleet":this.m_enemyFleetName
         }));
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
      }
      
      override protected function onFault(param1:int, param2:String) : void
      {
         super.onFault(param1,param2);
      }
   }
}

