package transactions
{
   import core.managers.NeighborhoodHelper;
   import displays.popups.NeighborhoodDialog;
   import zlabs.entity.IEntity;
   
   public class TGetNeighborhoodInfo extends TWorldState
   {
      
      private var m_dialog:NeighborhoodDialog = null;
      
      private var m_objId:int;
      
      public function TGetNeighborhoodInfo(param1:IEntity, param2:NeighborhoodDialog, param3:int)
      {
         super(param1);
         this.m_dialog = param2;
         this.m_objId = param3;
      }
      
      override public function perform() : void
      {
         signedWorldAction("NeighborhoodInfo",{"id":this.m_objId});
      }
      
      override protected function onComplete(param1:Object) : void
      {
         if(this.m_dialog)
         {
            this.m_dialog.setupUI(param1);
         }
         NeighborhoodHelper.instance.resetTimer();
      }
   }
}

