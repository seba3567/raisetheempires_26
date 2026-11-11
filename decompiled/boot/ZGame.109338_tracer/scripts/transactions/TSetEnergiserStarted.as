package transactions
{
   import Engine.Transactions.Transaction;
   import core.managers.EnergiserManager;
   import core.managers.WorldObjectManager;
   import zlabs.events.WorldEvent;
   
   public class TSetEnergiserStarted extends Transaction
   {
      
      protected var m_code:String;
      
      protected var m_position:Array;
      
      public function TSetEnergiserStarted(param1:String, param2:Array)
      {
         this.m_code = param1;
         this.m_position = param2;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.setEnergiserAnimationDone",this.m_code,this.m_position);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         WorldObjectManager.instance.dispatchEvent(new WorldEvent(WorldObjectManager.OBJECT_PLACED,this.m_code));
         EnergiserManager.instance.showFirstDialog();
      }
   }
}

