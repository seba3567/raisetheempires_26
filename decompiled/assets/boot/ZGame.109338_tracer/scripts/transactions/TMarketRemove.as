package transactions
{
   import displays.screens.Market;
   import zlabs.entity.IEntity;
   
   public class TMarketRemove extends TWorldState
   {
      
      private var m_params:Object;
      
      private var m_dialog:Market;
      
      public function TMarketRemove(param1:Market, param2:IEntity, param3:String, param4:int)
      {
         super(param2);
         this.m_dialog = param1;
         this.m_params = new Object();
         this.m_params.units = param4;
         this.m_params.item = param3;
      }
      
      override public function perform() : void
      {
         signedWorldAction("remove",this.m_params);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         if(this.m_dialog)
         {
            if(param1[0].toString() == "success")
            {
               this.m_dialog.onSuccess();
            }
            else
            {
               this.m_dialog.onFail();
            }
         }
      }
   }
}

