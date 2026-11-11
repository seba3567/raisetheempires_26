package core.gamemode.prebattle
{
   import core.ZGlobal;
   import core.gameobjects.ConsumableItem;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import displays.ImageLoaderFactory;
   import flash.display.MovieClip;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class PreBattleEnemySupportTooltipCard extends PreBattleEnemyTooltipCard
   {
      
      public function PreBattleEnemySupportTooltipCard(param1:UnitItem, param2:Class, param3:int, param4:int, param5:String, param6:Array)
      {
         super(param1,param2,param3,param4,param5,param6);
      }
      
      override protected function configureCard(param1:MovieClip) : void
      {
         var _loc2_:ConsumableItem = ZGlobal.gameSettings.getItemByCode(unit.secondaryAbility,ConsumableItem) as ConsumableItem;
         TextFieldUtil.processTextField(param1.abilityName_tf,unit.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         TextFieldUtil.processTextField(param1.description_tf,ZGameUtils.ZlocT("Items",_loc2_.name + "_description"));
         iconLoaders.push(ImageLoaderFactory.CreateImageLoader(_loc2_.getCachedImage("icon").url,param1.abilityIcon));
      }
   }
}

