package transactions
{
   import core.ZGlobal;
   
   public class TAddFleet extends TZGameTransaction
   {
      
      private var m_serialisableFleet:Object = null;
      
      public function TAddFleet(param1:String, param2:Array = null)
      {
         super();
         this.m_serialisableFleet = ZGlobal.player.fleets.getSerialisableFleet(param1,param2);
      }
      
      override public function perform() : void
      {
         signedCall("WorldService.addFleet",modifiedData(this.m_serialisableFleet));
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

