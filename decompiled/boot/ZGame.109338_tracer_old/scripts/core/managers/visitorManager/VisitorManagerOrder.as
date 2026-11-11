package core.managers.visitorManager
{
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import flash.geom.Vector3D;
   import zlabs.entity.IEntity;
   import zlabs.entity.PropertyReference;
   import zlabs.utils.MathUtils;
   
   public class VisitorManagerOrder
   {
      
      public static const UNCLAIMED:String = "unclaimed";
      
      public static const DECLINED:String = "declined";
      
      public static const CLAIMED:String = "claimed";
      
      private var m_positionReference:PropertyReference = new PropertyReference("@IsoSpatial.position");
      
      private var m_targets:Array = new Array();
      
      private var m_initialPos:Pt = null;
      
      public function VisitorManagerOrder(param1:Array)
      {
         super();
         this.processTargets(param1);
         this.m_initialPos = this.getTargetIndexPos(0);
      }
      
      public function get targets() : Array
      {
         return this.m_targets;
      }
      
      public function get initialPos() : Pt
      {
         return this.m_initialPos;
      }
      
      public function initialPosValid() : Boolean
      {
         return this.m_initialPos != null;
      }
      
      public function getTargetIndexPos(param1:int) : Pt
      {
         var _loc2_:IEntity = null;
         var _loc3_:Vector3D = null;
         var _loc4_:Pt = null;
         var _loc5_:Pt = null;
         if(param1 >= 0 && param1 < this.targets.length)
         {
            _loc2_ = ZGlobal.game.getObjectByID(this.targets[param1]);
            if(_loc2_)
            {
               _loc3_ = _loc2_.getProperty(this.m_positionReference);
               _loc4_ = Pt.toPt(_loc3_);
               return MathUtils.worldToTile(_loc4_,ZGlobal.cellSize);
            }
         }
         return null;
      }
      
      private function processTargets(param1:Array) : void
      {
         var _loc2_:int = 0;
         var _loc3_:IEntity = null;
         for each(_loc2_ in param1)
         {
            _loc3_ = ZGlobal.game.getObjectByID(_loc2_);
            if(_loc3_)
            {
               this.m_targets.push(_loc2_);
            }
         }
      }
   }
}

