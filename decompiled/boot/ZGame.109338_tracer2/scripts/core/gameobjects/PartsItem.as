package core.gameobjects
{
   public class PartsItem extends GameItem
   {
      
      public function PartsItem(param1:XML)
      {
         super(param1);
      }
      
      public function get numParts() : int
      {
         return m_xml.part.length();
      }
      
      public function getPartCodeForIndex(param1:int) : String
      {
         if(param1 >= this.numParts)
         {
            return null;
         }
         return m_xml.part[param1].@code;
      }
      
      public function getLocked(param1:uint) : Boolean
      {
         if(param1 < this.numParts)
         {
            if(m_xml.part[param1].@locked == undefined)
            {
               return false;
            }
            return m_xml.part[param1].@locked;
         }
         return true;
      }
      
      public function getUnlocks(param1:uint) : int
      {
         if(param1 >= this.numParts || m_xml.part[param1].@unlocks == undefined)
         {
            return -1;
         }
         return m_xml.part[param1].@unlocks;
      }
      
      public function getPartCountForIndex(param1:int) : int
      {
         return 0;
      }
      
      public function getPartUnlockCost(param1:int) : int
      {
         if(param1 >= this.numParts || m_xml.part[param1].@unlockCost == undefined)
         {
            return -1;
         }
         return m_xml.part[param1].@unlockCost;
      }
      
      public function getPartsType() : String
      {
         if(m_xml.@buildingPartsType != undefined)
         {
            return m_xml.@buildingPartsType;
         }
         return null;
      }
      
      public function getTimedBuidlableFeed() : String
      {
         if(m_xml.@feedOfType != undefined)
         {
            return m_xml.@feedOfType;
         }
         return null;
      }
      
      public function getPartsAskMethod(param1:int) : String
      {
         if(param1 >= this.numParts || m_xml.part[param1].@askMethod == undefined)
         {
            return null;
         }
         return m_xml.part[param1].@askMethod;
      }
      
      public function getPartsAskName(param1:int) : String
      {
         if(param1 >= this.numParts || m_xml.part[param1].@askName == undefined)
         {
            return null;
         }
         return m_xml.part[param1].@askName;
      }
   }
}

