package transactions
{
   import Engine.Managers.TransactionManager;
   import Engine.Transactions.Transaction;
   import core.managers.mayhemManager.MayhemManager;
   import entity.GameDataComponent;
   import transactions.utils.ZGameTransactionUtils;
   import zlabs.entity.IEntity;
   
   public class TResetParliament extends Transaction
   {
      
      protected var m_save:Object = null;
      
      protected var m_params:Object;
      
      protected var m_entity:IEntity = null;
      
      protected var m_parliamentDestroyed:Boolean;
      
      public function TResetParliament(param1:IEntity, param2:Boolean = false)
      {
         var _loc3_:GameDataComponent = null;
         super();
         this.m_entity = param1;
         this.m_parliamentDestroyed = param2;
         if(this.m_entity)
         {
            _loc3_ = GameDataComponent(this.m_entity.lookupComponentByType(GameDataComponent));
            this.m_save = _loc3_.getSaveObject();
         }
         this.m_params = new Object();
         this.m_params.parliamentDestroyed = this.m_parliamentDestroyed;
      }
      
      override public function perform() : void
      {
         this.signedWorldAction("resetParliament",this.m_params);
      }
      
      override protected function onAmfComplete(param1:Object) : void
      {
         super.onAmfComplete(param1);
         if(param1)
         {
            if(param1.errorType == NO_ERROR)
            {
               if(this.m_parliamentDestroyed)
               {
                  TransactionManager.addTransaction(new TExpireAQuest(MayhemManager.PARLIAMENT_QUEST));
               }
            }
         }
      }
      
      protected function signedWorldAction(param1:String, ... rest) : void
      {
         this.addChecksumToParams(rest);
         signedCall("WorldService.performAction",param1,this.modifiedData(this.m_save),rest);
         m_functionName = "WorldService.performAction:" + param1;
      }
      
      private function addChecksumToParams(param1:Array) : void
      {
         var _loc2_:int = int(param1.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if(null != param1[_loc3_])
            {
               param1[_loc3_].ch = ZGameTransactionUtils.getCheckSum(param1[_loc3_]);
            }
            _loc3_++;
         }
      }
      
      protected function modifiedData(param1:Object) : Object
      {
         param1.ch = ZGameTransactionUtils.getCheckSum(param1);
         return param1;
      }
   }
}

