package events
{
   import flash.events.Event;
   
   public class UpdateEvent extends Event
   {
      
      private var m_oldAmount:int = 0;
      
      private var m_newAmount:int = 0;
      
      public function UpdateEvent(param1:String, param2:int, param3:int)
      {
         super(param1);
         this.m_oldAmount = param2;
         this.m_newAmount = param3;
      }
      
      public function get oldAmount() : int
      {
         return this.m_oldAmount;
      }
      
      public function get newAmount() : int
      {
         return this.m_newAmount;
      }
   }
}

