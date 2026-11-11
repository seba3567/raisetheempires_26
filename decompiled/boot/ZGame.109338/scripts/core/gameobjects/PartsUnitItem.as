package core.gameobjects
{
   import core.ZGlobal;
   import core.managers.ExperimentsManager;
   
   public class PartsUnitItem extends PartsItem
   {
      
      public function PartsUnitItem(param1:XML)
      {
         super(param1);
      }
      
      override public function getPartCountForIndex(param1:int) : int
      {
         var _loc3_:String = null;
         if(param1 >= numParts)
         {
            return 0;
         }
         var _loc2_:int = 0;
         if(m_xml.partsExperiment == undefined)
         {
            _loc2_ = ZGlobal.getResearchPartsExperimentVariantByType(subType);
            if(_loc2_ == ZGlobal.EXPERIMENT_RESEARCH_PARTS_VIRAL_VARIANT_1 || _loc2_ == ZGlobal.EXPERIMENT_RESEARCH_PARTS_VIRAL_VARIANT_4)
            {
               return m_xml.part[param1].@countv1;
            }
            if(_loc2_ == ZGlobal.EXPERIMENT_RESEARCH_PARTS_VIRAL_VARIANT_2 || _loc2_ == ZGlobal.EXPERIMENT_RESEARCH_PARTS_VIRAL_VARIANT_5)
            {
               return m_xml.part[param1].@countv2;
            }
            return m_xml.part[param1].@countv3;
         }
         _loc3_ = m_xml.partsExperiment.toString();
         _loc2_ = ExperimentsManager.instance.getExperimentVariant(_loc3_);
         switch(_loc2_)
         {
            case ZGlobal.EXPERIMENT_RESEARCH_PARTS_VIRAL_VARIANT_2:
               return m_xml.part[param1].@countv2;
            case ZGlobal.EXPERIMENT_RESEARCH_PARTS_VIRAL_VARIANT_3:
               return m_xml.part[param1].@countv3;
            case ZGlobal.EXPERIMENT_RESEARCH_PARTS_VIRAL_VARIANT_4:
               return m_xml.part[param1].@countv4;
            case ZGlobal.EXPERIMENT_RESEARCH_PARTS_VIRAL_VARIANT_5:
               return m_xml.part[param1].@countv5;
            case ZGlobal.EXPERIMENT_RESEARCH_PARTS_VIRAL_VARIANT_6:
               return m_xml.part[param1].@countv6;
            case ZGlobal.EXPERIMENT_RESEARCH_PARTS_VIRAL_VARIANT_7:
               return m_xml.part[param1].@countv7;
            case ZGlobal.EXPERIMENT_RESEARCH_PARTS_VIRAL_VARIANT_8:
               return m_xml.part[param1].@countv8;
            default:
               return m_xml.part[param1].@countv1;
         }
      }
   }
}

