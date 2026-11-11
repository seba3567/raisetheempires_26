package core.gameobjects
{
   import core.ZGlobal;
   import core.managers.ExperimentsManager;
   
   public class ManaItem extends GameItem
   {
      
      private static const EXPERIMENT_SUPPORT_UNITS_MANA_COST:String = "empires_support_units_mana_cost";
      
      public static const EXPERIMENT_SUPPORT_UNITS_MANA_INVENTORY:String = "empires_support_units_mana_inventory";
      
      public function ManaItem(param1:XML)
      {
         super(param1);
      }
      
      public static function getCashMultiplier() : int
      {
         return ExperimentsManager.instance.getExperimentValue(EXPERIMENT_SUPPORT_UNITS_MANA_COST,ZGlobal.gameSettings.getManaExperimentValues("exp_su_mana_cost"),1);
      }
      
      override public function get cash() : int
      {
         return super.cash * getCashMultiplier();
      }
   }
}

