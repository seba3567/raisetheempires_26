package core.gameobjects
{
   import core.ZGlobal;
   import core.managers.ExperimentsManager;
   
   public class SuperOreMultiplierPartsItem extends PartsItem
   {
      
      public function SuperOreMultiplierPartsItem(param1:XML)
      {
         super(param1);
      }
      
      override public function getPartCodeForIndex(param1:int) : String
      {
         if(param1 >= this.numParts)
         {
            return null;
         }
         return m_xml.multiplier.part[param1].@code;
      }
      
      override public function get numParts() : int
      {
         return m_xml.multiplier.part.length();
      }
      
      override public function getPartCountForIndex(param1:int) : int
      {
         if(param1 >= this.numParts)
         {
            return 0;
         }
         var _loc2_:String = m_xml.multiplier.partsExperiment.toString();
         var _loc3_:int = ExperimentsManager.instance.getExperimentVariant(_loc2_);
         if(_loc3_ == ZGlobal.EXPERIMENT_BUILDING_BUILDABLE_PARTS_V6)
         {
            return m_xml.multiplier.part[param1].@countv6;
         }
         if(_loc3_ == ZGlobal.EXPERIMENT_BUILDING_BUILDABLE_PARTS_V5)
         {
            return m_xml.multiplier.part[param1].@countv5;
         }
         if(_loc3_ == ZGlobal.EXPERIMENT_BUILDING_BUILDABLE_PARTS_V4)
         {
            return m_xml.multiplier.part[param1].@countv4;
         }
         if(_loc3_ == ZGlobal.EXPERIMENT_BUILDING_BUILDABLE_PARTS_V3)
         {
            return m_xml.multiplier.part[param1].@countv3;
         }
         if(_loc3_ == ZGlobal.EXPERIMENT_BUILDING_BUILDABLE_PARTS_V2)
         {
            return m_xml.multiplier.part[param1].@countv2;
         }
         return m_xml.multiplier.part[param1].@countv1;
      }
      
      override public function getLocked(param1:uint) : Boolean
      {
         if(param1 < this.numParts)
         {
            if(m_xml.multiplier.part[param1].@locked == undefined)
            {
               return false;
            }
            return m_xml.multiplier.part[param1].@locked;
         }
         return true;
      }
      
      override public function getUnlocks(param1:uint) : int
      {
         if(param1 >= this.numParts || m_xml.multiplier.part[param1].@unlocks == undefined)
         {
            return -1;
         }
         return m_xml.multiplier.part[param1].@unlocks;
      }
      
      override public function getPartUnlockCost(param1:int) : int
      {
         if(param1 >= this.numParts || m_xml.multiplier.part[param1].@unlockCost == undefined)
         {
            return -1;
         }
         return m_xml.multiplier.part[param1].@unlockCost;
      }
      
      override public function getPartsAskMethod(param1:int) : String
      {
         if(param1 >= this.numParts || m_xml.multiplier.part[param1].@askMethod == undefined)
         {
            return null;
         }
         return m_xml.multiplier.part[param1].@askMethod;
      }
      
      override public function getPartsAskName(param1:int) : String
      {
         if(param1 >= this.numParts || m_xml.multiplier.part[param1].@askName == undefined)
         {
            return null;
         }
         return m_xml.multiplier.part[param1].@askName;
      }
   }
}

