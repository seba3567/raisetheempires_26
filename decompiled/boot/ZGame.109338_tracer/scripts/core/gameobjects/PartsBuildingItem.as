package core.gameobjects
{
   import core.ZGlobal;
   import core.managers.ExperimentsManager;
   
   public class PartsBuildingItem extends PartsItem
   {
      
      public function PartsBuildingItem(param1:XML)
      {
         super(param1);
      }
      
      public function requiresAnyParts() : Boolean
      {
         var _loc3_:String = null;
         var _loc4_:GameItem = null;
         var _loc5_:int = 0;
         var _loc1_:int = numParts;
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            _loc3_ = getPartCodeForIndex(_loc2_);
            _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc3_,GameItem) as GameItem;
            _loc5_ = this.getPartCountForIndex(_loc2_);
            if(_loc5_ > 0)
            {
               return true;
            }
            _loc2_++;
         }
         return false;
      }
      
      override public function getPartCountForIndex(param1:int) : int
      {
         var _loc4_:int = 0;
         var _loc5_:Number = NaN;
         var _loc6_:Object = null;
         var _loc7_:Number = NaN;
         if(param1 >= numParts)
         {
            return 0;
         }
         if(m_xml.partsAsnCountModifier != undefined && m_xml.partsAsnCountModifier.@experiment != undefined)
         {
            _loc4_ = ExperimentsManager.instance.getExperimentVariant(m_xml.partsAsnCountModifier.@experiment);
            if(_loc4_ == m_xml.partsAsnCountModifier.@variant)
            {
               _loc5_ = ZGlobal.player.asn;
               _loc6_ = ZGlobal.player.partsGatherInitAsn;
               if(name != null && _loc6_ != null && _loc6_[m_xml.partsAsnCountModifier.@asnIdentifier] != undefined)
               {
                  _loc5_ = Number(ZGlobal.player.partsGatherInitAsn[m_xml.partsAsnCountModifier.@asnIdentifier]);
               }
               _loc7_ = _loc5_ * m_xml.partsAsnCountModifier.@asnMultiplier;
               if(_loc7_ < m_xml.partsAsnCountModifier.@min)
               {
                  _loc7_ = Number(m_xml.partsAsnCountModifier.@min);
               }
               else if(_loc7_ > m_xml.partsAsnCountModifier.@max)
               {
                  _loc7_ = Number(m_xml.partsAsnCountModifier.@max);
               }
               return _loc7_;
            }
         }
         if(m_xml.partsExperiment == undefined)
         {
            return m_xml.part[param1].@count;
         }
         var _loc2_:String = m_xml.partsExperiment.toString();
         var _loc3_:int = ExperimentsManager.instance.getExperimentVariant(_loc2_);
         if(_loc3_ == ZGlobal.EXPERIMENT_BUILDING_BUILDABLE_PARTS_V6)
         {
            return m_xml.part[param1].@countv6;
         }
         if(_loc3_ == ZGlobal.EXPERIMENT_BUILDING_BUILDABLE_PARTS_V5)
         {
            return m_xml.part[param1].@countv5;
         }
         if(_loc3_ == ZGlobal.EXPERIMENT_BUILDING_BUILDABLE_PARTS_V4)
         {
            return m_xml.part[param1].@countv4;
         }
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

