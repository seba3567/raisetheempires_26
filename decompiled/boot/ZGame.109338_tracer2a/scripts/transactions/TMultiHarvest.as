package transactions
{
   import Engine.Transactions.Transaction;
   import flash.geom.Point;
   
   public class TMultiHarvest extends Transaction
   {
      
      private var m_root:Point;
      
      private var m_cost:int;
      
      private var m_discountedCost:int;
      
      private var m_objIDs:Array;
      
      public function TMultiHarvest(param1:Array, param2:Point, param3:int, param4:int)
      {
         super();
         this.m_objIDs = param1;
         this.m_root = param2;
         this.m_cost = param3;
         this.m_discountedCost = param4;
      }
      
      override public function perform() : void
      {
         signedCall("WorldService.multiHarvest",this.m_objIDs,this.m_root.x,this.m_root.y,this.m_cost,this.m_discountedCost);
      }
   }
}

