package transactions
{
   import zlabs.entity.IEntity;
   
   public class TMarketList extends TWorldState
   {
      
      private var m_params:Object;
      
      private var m_callBack:Function;
      
      public function TMarketList(param1:IEntity, param2:String, param3:Function, param4:Boolean)
      {
         super(param1);
         this.m_callBack = param3;
         this.m_params = new Object();
         this.m_params.hostId = param2;
         this.m_params.all = param4;
      }
      
      override public function perform() : void
      {
         signedWorldAction("list",this.m_params);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         if(this.m_callBack != null)
         {
            this.m_callBack(param1);
         }
      }
      
      public function cancel() : void
      {
         this.m_callBack = null;
      }
   }
}

