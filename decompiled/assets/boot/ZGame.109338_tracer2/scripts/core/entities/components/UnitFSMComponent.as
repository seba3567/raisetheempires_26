package core.entities.components
{
   import as3isolib.geom.Pt;
   
   public class UnitFSMComponent extends BuildingFSMComponent
   {
      
      private var m_targetPosition:Pt = null;
      
      public function UnitFSMComponent()
      {
         super();
      }
      
      public function set targetPosition(param1:Pt) : void
      {
         this.m_targetPosition = param1;
      }
      
      public function get targetPosition() : Pt
      {
         return this.m_targetPosition;
      }
   }
}

