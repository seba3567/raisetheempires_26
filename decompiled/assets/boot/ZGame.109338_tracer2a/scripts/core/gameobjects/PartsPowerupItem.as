package core.gameobjects
{
   import core.ZGlobal;
   import core.managers.ExperimentsManager;
   
   public class PartsPowerupItem extends PartsItem
   {
      
      public function PartsPowerupItem(param1:XML)
      {
         super(param1);
      }
      
      override public function getPartCountForIndex(param1:int) : int
      {
         if(param1 >= numParts)
         {
            return 0;
         }
         var _loc2_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_POWERUP_PARTSCOUNT_TEST);
         if(_loc2_ == ZGlobal.EXPERIMENT_POWERUP_BUILDABLE_PARTS_V4)
         {
            return m_xml.part[param1].@countv4;
         }
         if(_loc2_ == ZGlobal.EXPERIMENT_POWERUP_BUILDABLE_PARTS_V3)
         {
            return m_xml.part[param1].@countv3;
         }
         if(_loc2_ == ZGlobal.EXPERIMENT_POWERUP_BUILDABLE_PARTS_V2)
         {
            return m_xml.part[param1].@countv2;
         }
         return m_xml.part[param1].@countv1;
      }
   }
}

