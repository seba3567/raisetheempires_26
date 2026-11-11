package transactions
{
   import core.managers.visitorManager.VisitorManager;
   import zlabs.entity.IEntity;
   import zlabs.entity.PropertyReference;
   
   public class TVisitorHelpRedeem extends TSetState
   {
      
      public function TVisitorHelpRedeem(param1:IEntity, param2:String)
      {
         super(param1);
         m_params.neighborID = param2;
         m_params.helpRedeem = true;
      }
      
      override public function perform() : void
      {
         super.perform();
         var _loc1_:PropertyReference = new PropertyReference("@Data.id");
         var _loc2_:int = m_entity.getProperty(_loc1_) as int;
         VisitorManager.instance.helpRedeemed(m_params.neighborID,_loc2_);
      }
   }
}

