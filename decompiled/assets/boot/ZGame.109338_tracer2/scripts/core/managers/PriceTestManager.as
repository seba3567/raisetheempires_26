package core.managers
{
   import core.gameobjects.GameItem;
   import utils.ZGameTimeUtil;
   
   public class PriceTestManager
   {
      
      public static const ADDITIONALTYPE_IMPULSE:String = "ip";
      
      public static var instance:PriceTestManager = new PriceTestManager();
      
      private var m_data:Object = null;
      
      private var m_priceCurveEnabled:Boolean;
      
      public function PriceTestManager()
      {
         super();
      }
      
      public function init(param1:Object) : void
      {
         this.m_data = param1;
      }
      
      public function initExperimentVars() : void
      {
         var _loc1_:int = ExperimentsManager.instance.getExperimentVariant("empire_pricecurve_production_buildings");
         this.m_priceCurveEnabled = _loc1_ == 3;
      }
      
      public function get priceCurveEnabled() : Boolean
      {
         return this.m_priceCurveEnabled;
      }
      
      public function costMultiplierByType(param1:String) : Number
      {
         if(this.m_data.hasOwnProperty(param1))
         {
            return this.m_data[param1];
         }
         return 1;
      }
      
      public function costMultiplierByItem(param1:GameItem) : Number
      {
         if(param1.type == GameItem.TYPE_CONSUMABLE && param1.subType == "consumable")
         {
            return this.costMultiplierByType("powerup");
         }
         if(param1.isValidUnitItem() && !ZGameTimeUtil.instance.isLimitedEdition(param1.xml))
         {
            return this.costMultiplierByType("unitsalediscount");
         }
         if(param1.isValidUnitItem() && ZGameTimeUtil.instance.isLimitedEdition(param1.xml))
         {
            return this.costMultiplierByType("leunitpurchase");
         }
         if(param1.isResourceItem() && param1.resourceType == "coins")
         {
            return this.costMultiplierByType("coinspurchase");
         }
         if(param1.isResourceItem() && param1.resourceType == "wood")
         {
            return this.costMultiplierByType("woodpurchase");
         }
         if(param1.isResourceItem() && param1.resourceType == "oil")
         {
            return this.costMultiplierByType("oilpurchase");
         }
         if(param1.isResourceItem() && param1.resourceType == "ore")
         {
            return this.costMultiplierByType("orepurchase");
         }
         if(param1.type == GameItem.TYPE_PART && param1.subType == GameItem.SUBTYPE_UNITPART)
         {
            return this.costMultiplierByType("unitpart");
         }
         if(param1.type == GameItem.TYPE_PART && param1.subType == GameItem.SUBTYPE_BUILDINGPART)
         {
            return this.costMultiplierByType("buildingpart");
         }
         if(param1.type == GameItem.TYPE_PART && param1.subType == GameItem.SUBTYPE_SUPPORTBUILDINGPART)
         {
            return this.costMultiplierByType("supportbuildingpart");
         }
         if(param1.type == GameItem.TYPE_PART && param1.subType == GameItem.SUBTYPE_DEFENSEPART)
         {
            return this.costMultiplierByType("defensepart");
         }
         if(param1.type == GameItem.TYPE_PART && param1.subType == GameItem.SUBTYPE_POWERUPPART)
         {
            return this.costMultiplierByType("poweruppart");
         }
         if(param1.type == "upgrade" && param1.subType == "strength")
         {
            return this.costMultiplierByType("strengthupgrade");
         }
         if(param1.type == GameItem.TYPE_CONSUMABLE && param1.subType == "energy")
         {
            return this.costMultiplierByType("energypurchase");
         }
         return 1;
      }
   }
}

