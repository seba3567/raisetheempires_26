package transactions
{
   import zlabs.entity.IEntity;
   
   public class TPartUnlock extends TWorldState
   {
      
      private var m_partCode:String;
      
      public function TPartUnlock(param1:IEntity, param2:String)
      {
         super(param1);
         this.m_partCode = param2;
      }
      
      override public function perform() : void
      {
         var _loc1_:Object = new Object();
         _loc1_.partCode = this.m_partCode;
         signedWorldAction("partUnlock",_loc1_);
      }
   }
}

