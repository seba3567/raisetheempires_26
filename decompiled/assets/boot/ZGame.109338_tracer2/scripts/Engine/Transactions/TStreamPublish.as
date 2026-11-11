package Engine.Transactions
{
   import Engine.Classes.SNAPISocialNetwork;
   
   public class TStreamPublish extends Transaction
   {
      
      protected var m_type:String;
      
      protected var m_data:Object;
      
      protected var m_targetId:String;
      
      protected var m_autoPublish:Boolean;
      
      protected var m_comment:String;
      
      public function TStreamPublish(param1:String, param2:Object, param3:String = null, param4:String = null, param5:Boolean = false)
      {
         super();
         this.m_type = param1;
         this.m_data = param2;
         this.m_targetId = param3;
         this.m_comment = param4;
         this.m_autoPublish = param5;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.streamPublish",this.m_type,this.m_data,this.m_targetId);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         if(GlobalEngine.socialNetwork is SNAPISocialNetwork)
         {
            if(this.m_autoPublish)
            {
               param1.auto_publish = true;
            }
            if(this.m_comment != null)
            {
               param1.full.message = this.m_comment;
               param1.simple.message = this.m_comment;
            }
            (GlobalEngine.socialNetwork as SNAPISocialNetwork).snapiStreamPublish(param1);
         }
         else
         {
            GlobalEngine.socialNetwork.streamPublish(param1.attachment,param1.action_link,param1.target_id,param1.user_message_prompt);
         }
      }
   }
}

