package transactions
{
   import core.managers.visitorManager.VisitorManager;
   import zlabs.entity.IEntity;
   import zlabs.entity.PropertyReference;
   
   public class TVisitorHelpSpeedup extends TWorldState
   {
      
      private var m_params:Object;
      
      public function TVisitorHelpSpeedup(param1:IEntity, param2:String, param3:Number)
      {
         super(param1);
         this.m_params = new Object();
         this.m_params.neighborID = param2;
         this.m_params.elapsed = param3;
      }
      
      override public function perform() : void
      {
         signedWorldAction("visitorSpeedup",this.m_params);
         var _loc1_:PropertyReference = new PropertyReference("@Data.id");
         var _loc2_:int = m_entity.getProperty(_loc1_) as int;
         VisitorManager.instance.helpRedeemed(this.m_params.neighborID,_loc2_);
      }
   }
}

