package transactions
{
   import displays.screens.Market;
   import zlabs.entity.IEntity;
   
   public class TMarketAdd extends TWorldState
   {
      
      private var m_params:Object;
      
      private var m_dialog:Market;
      
      public function TMarketAdd(param1:Market, param2:IEntity, param3:String, param4:int, param5:String)
      {
         super(param2);
         this.m_dialog = param1;
         this.m_params = new Object();
         this.m_params.item = param3;
         this.m_params.units = param4;
         this.m_params.type = param5;
      }
      
      public function get type() : String
      {
         return this.m_params.type;
      }
      
      public function get item() : String
      {
         return this.m_params.item;
      }
      
      public function get units() : int
      {
         return this.m_params.units;
      }
      
      override public function perform() : void
      {
         signedWorldAction("add",this.m_params);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         if(this.m_dialog)
         {
            this.m_dialog.onSuccess();
         }
      }
   }
}

