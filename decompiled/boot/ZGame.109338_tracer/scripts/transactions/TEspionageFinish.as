package transactions
{
   import Engine.Transactions.Transaction;
   import entity.GameDataComponent;
   import zlabs.entity.IEntity;
   
   public class TEspionageFinish extends Transaction
   {
      
      private var m_item:String;
      
      private var m_entity:IEntity;
      
      private var m_save:Object;
      
      public function TEspionageFinish(param1:IEntity, param2:String)
      {
         var _loc3_:GameDataComponent = null;
         this.m_item = param2;
         this.m_entity = param1;
         if(this.m_entity)
         {
            _loc3_ = GameDataComponent(this.m_entity.lookupComponentByType(GameDataComponent));
            this.m_save = _loc3_.getSaveObject();
         }
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.finishSpy",this.m_save,this.m_item);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
      }
   }
}

