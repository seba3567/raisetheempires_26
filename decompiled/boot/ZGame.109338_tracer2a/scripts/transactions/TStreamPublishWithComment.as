package transactions
{
   import Engine.Managers.TransactionManager;
   import Engine.Transactions.TStreamPublish;
   import Engine.Transactions.Transaction;
   import core.ZGlobal;
   import zlabs.debug.Logger;
   
   public class TStreamPublishWithComment extends Transaction
   {
      
      private static const STREAM_PUBLISH_ERROR_PUBLISH_FAILED:int = -100;
      
      private static const STREAM_PUBLISH_ERROR_POST_FAILED:int = -101;
      
      private static const STREAM_PUBLISH_ERROR_COMMENT_FAILED:int = -102;
      
      protected var m_type:String;
      
      protected var m_data:Object;
      
      protected var m_targetId:String;
      
      protected var m_comment:String;
      
      public function TStreamPublishWithComment(param1:String, param2:Object, param3:String, param4:String = null)
      {
         super();
         this.m_type = param1;
         this.m_data = param2;
         this.m_targetId = param4;
         this.m_comment = param3;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.streamPublishWithComment",this.m_type,this.m_data,this.m_comment,this.m_targetId);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         if(param1.result)
         {
            Logger.info(this,"onComplete","TStreamPublishWithComment result: " + param1.result as String);
            if(param1.result == STREAM_PUBLISH_ERROR_PUBLISH_FAILED || param1.result == STREAM_PUBLISH_ERROR_POST_FAILED)
            {
               if(ZGlobal.publishFeedPermissionVarient > 0)
               {
                  ZGlobal.hasPublishPermission = 0;
               }
               TransactionManager.addTransaction(new TStreamPublish(this.m_type,this.m_data,this.m_targetId,this.m_comment));
            }
         }
      }
   }
}

