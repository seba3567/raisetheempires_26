package core.ui.menuitem
{
   import Engine.Managers.StatsManager;
   import core.ZGlobal;
   import core.managers.ExperimentsManager;
   import core.managers.MOTDManager.MessageOfTheDayManager;
   import core.ui.Tooltip;
   import flash.display.BitmapData;
   import flash.events.MouseEvent;
   import utils.ZGameUtils;
   
   public class DirectReliefPromoUIItem extends PromoMenuItem
   {
      
      public static const ITEM_ID:String = "DirectReliefPromoUIItem";
      
      public static const DIRECT_RELIEF_MOTD:String = "motd_DefenseTower03_Sep2011";
      
      public static const DIRECT_RELIEF_MOTD_LASTCHANCE:String = "motd_DefenseTower03_Sep2011_LastChance";
      
      public static const EXPERIMENT_DEFENSE_TOWER_3_FEATURE:String = "empire_defense_tower_3_feature";
      
      private static const EXPERIMENT_DEFENSE_TOWER_3_FEATURE_CONTROL:int = 0;
      
      private static const EXPERIMENT_DEFENSE_TOWER_3_FEATURE_V1:int = 1;
      
      private static const EXPERIMENT_DEFENSE_TOWER_3_FEATURE_V2:int = 2;
      
      public static const EXPERIMENT_DEFENSE_TOWER_3_FEATURE_ON:int = EXPERIMENT_DEFENSE_TOWER_3_FEATURE_V2;
      
      public static const EXPERIMENT_DEFENSE_TOWER_PRICING:String = "empire_defense_tower_pricing";
      
      public static const EXPERIMENT_DEFENSE_TOWER_PRICING_CONTROL:int = 0;
      
      public static const EXPERIMENT_DEFENSE_TOWER_PRICING_V1:int = 1;
      
      public static const EXPERIMENT_DEFENSE_TOWER_PRICING_V2:int = 2;
      
      public static const EXPERIMENT_DEFENSE_TOWER_PRICING_V3:int = 3;
      
      public static const EXPERIMENT_DEFENSE_TOWER_PRICING_V4:int = 4;
      
      public static const EXPERIMENT_DEFENSE_TOWER_PRICING_V5:int = 5;
      
      public static const EXPERIMENT_DIRECT_RELIEF_HUD:String = "empire_direct_relief_hud";
      
      private static const EXPERIMENT_DIRECT_RELIEF_HUD_CONTROL:int = 0;
      
      private static const EXPERIMENT_DIRECT_RELIEF_HUD_V1:int = 1;
      
      private static const EXPERIMENT_DIRECT_RELIEF_HUD_V2:int = 2;
      
      public static const EXPERIMENT_DIRECT_RELIEF_HUD_ON:int = EXPERIMENT_DIRECT_RELIEF_HUD_V2;
      
      public static const DEFENSETOWER_3_ITEM_CODE:String = "DT3";
      
      public function DirectReliefPromoUIItem()
      {
         swfPath = "assets/game/season/Seasons_September.swf/Bldg_Civ_DTower_DRelief_Activated_96.png";
         toolTipFileName = "MessageOfTheDay";
         toolTipText = "motd_DefenseTower03_Sep2011_HUD_tooltip";
         visible = false;
         tweenTimeSeconds = 2;
         var _loc1_:Boolean = true;
         super(ITEM_ID,_loc1_);
         priority = 1;
      }
      
      public static function isEnabled() : Boolean
      {
         var _loc1_:Boolean = false;
         return ExperimentsManager.instance.getExperimentVariant(EXPERIMENT_DEFENSE_TOWER_3_FEATURE) == EXPERIMENT_DEFENSE_TOWER_3_FEATURE_ON && ExperimentsManager.instance.getExperimentVariant(EXPERIMENT_DIRECT_RELIEF_HUD) == EXPERIMENT_DIRECT_RELIEF_HUD_ON && (MessageOfTheDayManager.instance.isRelevantMOTDByName(DIRECT_RELIEF_MOTD,_loc1_) || MessageOfTheDayManager.instance.isRelevantMOTDByName(DIRECT_RELIEF_MOTD_LASTCHANCE,_loc1_));
      }
      
      override public function show(param1:Boolean = false) : void
      {
         super.show(param1);
         StatsManager.count("HUD","Direct_relief_hud","view");
      }
      
      override protected function onLoadComplete(param1:String, param2:BitmapData) : void
      {
         super.onLoadComplete(param1,param2);
         var _loc3_:String = ZGameUtils.ZlocT(toolTipFileName,toolTipText);
         Tooltip.subscribe(m_uiloader,_loc3_);
      }
      
      override protected function onClicked(param1:MouseEvent) : void
      {
         super.onClicked(param1);
         ZGlobal.player.setSeenFlag(PromoMenuItemContainer.FLAG_DIRECT_RELIEF_HUD);
         var _loc2_:Boolean = false;
         var _loc3_:Boolean = false;
         if(MessageOfTheDayManager.instance.isRelevantMOTDByName(DIRECT_RELIEF_MOTD,_loc2_))
         {
            MessageOfTheDayManager.instance.openMOTDPopupByName(DIRECT_RELIEF_MOTD,_loc3_);
         }
         else if(MessageOfTheDayManager.instance.isRelevantMOTDByName(DIRECT_RELIEF_MOTD_LASTCHANCE,_loc2_))
         {
            MessageOfTheDayManager.instance.openMOTDPopupByName(DIRECT_RELIEF_MOTD_LASTCHANCE,_loc3_);
         }
         StatsManager.count("HUD","Direct_relief_hud","click");
      }
   }
}

