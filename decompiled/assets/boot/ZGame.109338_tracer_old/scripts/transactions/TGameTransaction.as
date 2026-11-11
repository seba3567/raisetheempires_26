package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TGameTransaction extends Transaction
   {
      
      protected const GOAL_TYPE_ACHIEVEMENT:String = "Achievement";
      
      protected const GOAL_TYPE_MASTERY:String = "Mastery";
      
      public function TGameTransaction()
      {
         super();
      }
      
      final override protected function onAmfComplete(param1:Object) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         super.onAmfComplete(param1);
         if(param1)
         {
            if(param1.goals != null)
            {
               _loc2_ = 0;
               while(_loc2_ < param1.goals.length)
               {
                  switch(param1.goals[_loc2_]["type"])
                  {
                     case this.GOAL_TYPE_ACHIEVEMENT:
                  }
                  _loc2_++;
               }
            }
            if(param1.goalCounters != null)
            {
               _loc3_ = 0;
               while(_loc3_ < param1.goalCounters.length)
               {
                  switch(param1.goalCounters[_loc3_]["type"])
                  {
                     case this.GOAL_TYPE_ACHIEVEMENT:
                  }
                  _loc3_++;
               }
            }
         }
      }
   }
}

