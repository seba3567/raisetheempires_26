package core.gameobjects
{
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   
   public class UpgradeItem extends GameItem
   {
      
      public static const REDUCE_COST:String = "reduceCost";
      
      public static const REDUCE_BUILD_TIME:String = "reduceBuildTime";
      
      public static const STRENGTH:String = "strength";
      
      public static const HEALTH:String = "health";
      
      public static const ACCURACY:String = "accuracy";
      
      public static const DAMAGE:String = "damage";
      
      public static const SHIELDS:String = "shields";
      
      public static const DODGE:String = "dodge";
      
      public static const EFFICIENCY:String = "efficiency";
      
      public static const SHIELDID:String = "shieldID";
      
      public function UpgradeItem(param1:XML)
      {
         super(param1);
      }
      
      public function getShieldWeaponID() : String
      {
         if(this.shieldModifier)
         {
            return m_xml.attribute("shieldID").toString();
         }
         return null;
      }
      
      public function modifiesShields() : Boolean
      {
         var _loc1_:String = m_xml.modifier.attribute(SHIELDS).toString();
         return _loc1_.length > 0;
      }
      
      public function modifiesDodge() : Boolean
      {
         var _loc1_:String = m_xml.modifier.attribute(DODGE).toString();
         return _loc1_.length > 0;
      }
      
      public function modifiesStrength() : Boolean
      {
         var _loc1_:String = m_xml.modifier.attribute(STRENGTH).toString();
         return _loc1_.length > 0;
      }
      
      public function get shieldModifier() : int
      {
         var _loc1_:String = m_xml.modifier.attribute(SHIELDS).toString();
         return parseInt(_loc1_);
      }
      
      public function get dodgeModifier() : int
      {
         var _loc1_:String = m_xml.modifier.attribute(DODGE).toString();
         return parseInt(_loc1_);
      }
      
      public function get strengthModifier() : int
      {
         var _loc1_:String = m_xml.modifier.attribute(STRENGTH).toString();
         return parseInt(_loc1_);
      }
      
      public function modifiesCost() : Boolean
      {
         var _loc1_:String = m_xml.modifier.attribute(REDUCE_COST).toString();
         return _loc1_.length > 0;
      }
      
      public function get costModifier() : int
      {
         var _loc1_:String = m_xml.modifier.attribute(REDUCE_COST).toString();
         return parseInt(_loc1_);
      }
      
      public function modifiesDuration() : Boolean
      {
         var _loc1_:String = m_xml.modifier.attribute(REDUCE_BUILD_TIME).toString();
         return _loc1_.length > 0;
      }
      
      public function get durationModifier() : int
      {
         var _loc1_:String = m_xml.modifier.attribute(REDUCE_BUILD_TIME).toString();
         if(this.isPercentageModifier())
         {
            return parseInt(_loc1_);
         }
         return ZGameTimeUtil.instance.parseTimeAsSeconds(_loc1_,0);
      }
      
      public function modifiesAccuracy() : Boolean
      {
         var _loc1_:String = m_xml.modifier.attribute(ACCURACY).toString();
         return _loc1_.length > 0;
      }
      
      public function get accuracyModifier() : int
      {
         var _loc1_:String = m_xml.modifier.attribute(ACCURACY).toString();
         return parseInt(_loc1_);
      }
      
      public function modifiesDamage() : Boolean
      {
         var _loc1_:String = m_xml.modifier.attribute(DAMAGE).toString();
         return _loc1_.length > 0;
      }
      
      public function get damageModifier() : int
      {
         var _loc1_:String = m_xml.modifier.attribute(DAMAGE).toString();
         return parseInt(_loc1_);
      }
      
      public function modifiesEfficiency() : Boolean
      {
         var _loc1_:String = m_xml.modifier.attribute(EFFICIENCY).toString();
         return _loc1_.length > 0;
      }
      
      public function get efficiencyModifier() : int
      {
         var _loc1_:String = m_xml.modifier.attribute(EFFICIENCY).toString();
         return parseInt(_loc1_);
      }
      
      public function isPercentageModifier() : Boolean
      {
         var _loc1_:String = m_xml.modifier.attribute("percent").toString();
         return _loc1_ == "true";
      }
      
      public function get modifierString() : String
      {
         var _loc1_:String = null;
         if(this.modifiesStrength())
         {
            _loc1_ = this.strengthModifier.toString();
         }
         else if(this.modifiesCost())
         {
            _loc1_ = this.costModifier.toString();
         }
         else if(this.modifiesDuration())
         {
            _loc1_ = this.durationModifier.toString();
         }
         else if(this.modifiesDamage())
         {
            _loc1_ = this.damageModifier.toString();
         }
         else if(this.modifiesAccuracy())
         {
            _loc1_ = this.accuracyModifier.toString();
         }
         else if(this.modifiesEfficiency())
         {
            _loc1_ = this.efficiencyModifier.toString();
         }
         else if(this.modifiesShields())
         {
            _loc1_ = this.shieldModifier.toString();
         }
         else
         {
            _loc1_ = "";
         }
         return _loc1_ + (this.isPercentageModifier() ? "%" : "");
      }
      
      public function get modifierName() : String
      {
         if(this.modifiesStrength())
         {
            return STRENGTH;
         }
         if(this.modifiesCost())
         {
            return REDUCE_COST;
         }
         if(this.modifiesDuration())
         {
            return REDUCE_BUILD_TIME;
         }
         if(this.modifiesDamage())
         {
            return DAMAGE;
         }
         if(this.modifiesAccuracy())
         {
            return ACCURACY;
         }
         if(this.modifiesEfficiency())
         {
            return EFFICIENCY;
         }
         if(this.modifiesShields())
         {
            return SHIELDS;
         }
         return "";
      }
      
      public function get resultText() : String
      {
         var _loc1_:String = this.modifierName + "_Result";
         return ZGameUtils.ZlocT("Tooltips",_loc1_,{"amount":this.modifierString});
      }
   }
}

