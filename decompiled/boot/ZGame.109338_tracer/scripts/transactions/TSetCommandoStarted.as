package transactions
{
   import Engine.Transactions.Transaction;
   import core.managers.CommandoManager;
   import core.managers.WorldObjectManager;
   import zlabs.events.WorldEvent;
   
   public class TSetCommandoStarted extends Transaction
   {
      
      protected var m_code:String;
      
      protected var m_position:Array;
      
      public function TSetCommandoStarted(param1:String, param2:Array)
      {
         this.m_code = param1;
         this.m_position = param2;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.setCommandoAnimationDone",this.m_code,this.m_position);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         WorldObjectManager.instance.dispatchEvent(new WorldEvent(WorldObjectManager.OBJECT_PLACED,this.m_code));
         CommandoManager.instance.showFirstDialog();
      }
   }
}

