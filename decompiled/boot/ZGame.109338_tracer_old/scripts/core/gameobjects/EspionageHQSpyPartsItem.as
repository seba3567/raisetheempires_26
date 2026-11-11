package core.gameobjects
{
   import core.ZGlobal;
   import core.managers.ExperimentsManager;
   
   public class EspionageHQSpyPartsItem extends PartsItem
   {
      
      public function EspionageHQSpyPartsItem(param1:XML)
      {
         super(param1);
      }
      
      override public function getPartCountForIndex(param1:int) : int
      {
         if(param1 >= numParts)
         {
            return 0;
         }
         if(m_xml.partsExperiment == undefined)
         {
            return m_xml.part[param1].@count;
         }
         var _loc2_:String = m_xml.partsExperiment.toString();
         var _loc3_:int = ExperimentsManager.instance.getExperimentVariant(_loc2_);
         if(_loc3_ == ZGlobal.EXPERIMENT_BUILDING_BUILDABLE_PARTS_V3)
         {
            return m_xml.part[param1].@countv3;
         }
         if(_loc3_ == ZGlobal.EXPERIMENT_BUILDING_BUILDABLE_PARTS_V2)
         {
            return m_xml.part[param1].@countv2;
         }
         return m_xml.part[param1].@countv1;
      }
   }
}

