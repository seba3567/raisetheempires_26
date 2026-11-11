package core.managers
{
   import core.ZGlobal;
   import core.managers.campaignManager.CampaignManager;
   import flash.events.EventDispatcher;
   
   public class ExperimentsManager extends EventDispatcher
   {
      
      public static const EXPERIMENT_FRIEND_FLASH_GIFT_SIZE:String = "empire_friendflash_giftsize";
      
      public static const EXPERIMENT_FRIEND_FLASH_OPTIONS:String = "empire_friendflash_options";
      
      public static const EXPERIMENT_SURVIVALMODE_MASTER:String = "empire_survivalMode_master";
      
      public static const VARIANT_SURVIVALMODE_MASTER:int = 2;
      
      public static const EXPERIMENT_AMMO_MASTER:String = "empire_ammo_master_v2";
      
      public static const VARIANT_AMMO_MASTER_ON:int = 3;
      
      public static const EXPERIMENT_AI_FOCUS_FIRE:String = "empire_ai_focus_fire";
      
      public static const EXPERIMENT_COMBAT_UNIT_HEAL_TURN:String = "empire_combat_unit_heal_turn";
      
      public static const EXPERIMENT_AUTOPOP_STORE:Object = {
         "name":"empire_autopop_store",
         "enabled":"3"
      };
      
      public static const EXPERIMENT_LOWEP_POPUP:Object = {
         "name":"empire_lowep_popup",
         "enabled":"3,4,5"
      };
      
      public static const EXPERIMENT_LOWEP_POPUP_PACKAGES:String = "empire_lowep_popup_packages";
      
      public static const EXPERIMENT_COMBAT_UNIT_HEAL:String = "empire_combat_unit_heal";
      
      public static const EXPERIMENT_COMBAT_UNIT_HEAL_KEEPTURN:String = "empire_combat_unit_heal_keepturn";
      
      public static const EXPERIMENT_PAYER_BUNDLE:String = "empires_payer_bundle";
      
      public static const EXPERIMENT_FREE_GIFT_WITH_PURCHASE:String = "empire_free_gift_with_purchase";
      
      public static const EXPERIMENT_DECORATIONS_MASTER:String = "empire_decorations_master";
      
      public static const EXPERIMENT_DECORATIONS_PAYOUT:String = "empire_decorations_payout";
      
      public static const EXPERIMENT_DECORATIONS_CONTRACT_DURATION:String = "empire_decorations_contract_duration";
      
      public static const EXPERIMENT_DEFENSE_TOWER_BUILDABLE_PARTS:String = "empire_defense_tower_buildable_parts";
      
      public static const EXPERIMENT_POWER_UP_PROMPT:String = "empire_power_up_prompt";
      
      public static const EXPERIMENT_DEFENSE_TOWER_2_BUILDABLE_PARTS:String = "empire_defense_tower_2_buildable_parts";
      
      public static const DEFENSE_TOWER_LEVEL_ONE_ITEM_CODE:String = "DT1";
      
      public static const EXPERIMENT_POWERUP_FACTORY:String = "empire_powerup_factory";
      
      public static const EXPERIMENT_POWERUP_PARTSCOUNT_TEST:String = "empire_powerup_partscount_test";
      
      public static const EXPERIMENT_SPECOPS_PARTS:String = "empires_specops_parts";
      
      public static const EXPERIMENT_BUILDABLE_DISCOUNT:String = "empire_buildable_discount";
      
      public static const VARIANT_BUILDABLE_DISCOUNT_ENABLED:int = 3;
      
      public static const EXPERIMENT_BUNDLE_BY_WALLET:String = "empire_bundle_by_wallet";
      
      public static const EXPERIMENT_BUNDLE_PICK_YOUR_OWN:String = "empire_bundle_pick_your_own";
      
      public static const EXPERIMENT_MECH_LAB_DISCOUNT:String = "empire_mech_lab_discount";
      
      public static const EXPERIMENT_MECH_LAB_GIFT_PARTS:String = "empire_mech_lab_gift_parts";
      
      public static const VARIANT_MECH_LAB_GIFT_PARTS_ENABLED:int = 2;
      
      public static const VARIANT_MECH_LAB_GIFT_PARTS_PACK_ENABLED:int = 3;
      
      public static const EXPERIMENT_BUYABLE_CONTRACTS:String = "empire_buyable_contracts";
      
      public static const VARIANT_BUYABLE_CONTRACTS_ENABLED:int = 3;
      
      public static const EXPERIMENT_IMPULSE_PURCHASE:String = "empire_impulse_purchase";
      
      public static const VARIANT_IMPULSE_PURCHASE_ENABLED:int = 3;
      
      public static const EXPERIMENT_LABORDAY_2011:String = "empire_labor_day_2011";
      
      public static const EXPERIMENT_LABORDAY_2011_PRICING:String = "empire_labor_day_2011_pricing";
      
      public static const EXPERIMENT_REPORT_BUG_POPUP:String = "empire_report_bug_popup";
      
      public static const EXPERIMENT_MOTD_SCROLLING:String = "empire_motd_scrolling";
      
      public static const EXPERIMENT_REPLACE_CREW:String = "empire_replace_crew";
      
      public static const EXPERIMENT_EMPHASIZE_ENERGY_DOOBER:String = "empire_emphasize_energy_doober";
      
      public static const EXPERIMENT_REMEMBER_LAST_BUILD_MENU_PAGE:String = "empire_remember_last_build_menu_page";
      
      public static const COMBATAICANCRITICAL_VARIANT_ENABLED:int = 2;
      
      public static const EXPERIMENT_CAMPV2_ENABLED:String = "empire_campv2_enabled";
      
      public static const EXPERIMENT_CAMPV2_ENABLED_VARIANT_ENABLED:int = 2;
      
      public static const EXPERIMENT_CAMPV3_ENABLED:String = "empire_campv3_enabled";
      
      public static const EXPERIMENT_CAMPV3_ENABLED_VARIANT_ENABLED:int = 2;
      
      public static const EXPERIMENT_CAMPAIGN_MASTERY:String = "empire_campaign_mastery";
      
      public static const EXPERIMENT_CAMPAIGN_MASTERY_UNIT_TIER:String = "empire_campaign_mastery_unit_tiers";
      
      public static const EXPERIMENT_EXPANSION_CREW_MASTER:String = "empire_expansion_crew_master";
      
      public static const EXPERIMENT_EXPANSION_CREW_COST:String = "empire_expansion_crew_cost";
      
      public static const EXPERIMENT_REQUEST2_SORT:String = "empire_request2_sort";
      
      public static const EXPERIMENT_REQUEST2_MASTER:String = "empire_request2_master";
      
      public static const EXPERIMENT_REQUEST2_MFS:String = "empire_request2_mfs";
      
      public static const EXPERIMENT_REQUEST2_MFS_CREW:String = "empire_request2_mfs_crew";
      
      public static const EXPERIMENT_REQUEST2_MFS_GIFT_REQUEST:String = "empire_request2_mfs_gift_request";
      
      public static const EXPERIMENT_REQUEST2_MFS_GIFT:String = "empire_request2_mfs_gift";
      
      public static const EXPERIMENT_REQUEST2_MFS_NEIGHBOR:String = "empire_request2_mfs_neighbor";
      
      public static const EXPERIMENT_REQUEST2_MFS_GIFT_INTERSTITIAL:String = "empire_request2_mfs_gift_interstitial";
      
      public static const EXPERIMENT_REQUEST2_LOGIC:String = "empire_request2_logic";
      
      public static const EXPERIMENT_REQUEST2_PRESELECT:String = "empire_request2_preselect";
      
      public static const EXPERIMENT_REQUEST2_LIMIT:String = "empire_request2_limit";
      
      public static const EXPERIMENT_REQUEST2_SENDCAP:String = "empires_request2_sendcap";
      
      public static const EXPERIMENT_REQUEST2_OPTIMIZE:String = "empire_request2_optimize";
      
      public static const EXPERIMENT_MFS_BUNDLE:String = "empire_mfs_bundle";
      
      public static const EXPERIMENT_MINISERIES025_REWARDS:String = "empire_miniseries_025_rewards";
      
      public static const EXPERIMENT_ZFEED:String = "empire_zfeed";
      
      public static const EXPERIMENT_ZFEED_VARIANT_ENABLED:int = 2;
      
      public static const EXPERIMENT_COMBAT_REVIVE_UNIT:String = "empire_combat_revive_unit";
      
      public static const EXPERIMENT_COMBAT_TOASTER:String = "empire_combat_toaster";
      
      public static const EXPERIMENT_MOTD2:String = "empire_motd2";
      
      public static const EXPERIMENT_DEPOT_AIR_MASTER:String = "empire_depot_air_master";
      
      public static const EXPERIMENT_DEPOT_AIR_PARTS:String = "empire_depot_air_parts";
      
      public static const EXPERIMENT_DEPOT_AIR_PRICE:String = "empire_depot_air_price";
      
      public static const EXPERIMENT_DEPOT_NAVY_PARTS:String = "empire_depot_navy_parts";
      
      public static const EXPERIMENT_WAREHOUSE:String = "empire_warehouse";
      
      public static const EXPERIMENT_WAREHOUSE_ARMY:String = "empire_warehouse_army";
      
      public static const EXPERIMENT_DYNAMIC_QUEST_TASK_PRICING:String = "empire_dynamic_quest_task_pricing";
      
      public static const VARIANT_VALUE_DYNAMIC_QUEST_TASK_PRICING_ENABLED:int = 2;
      
      public static const EXPERIMENT_PRICECURVE_EXPANSION:String = "empire_pricecurve_expansion";
      
      public static const VARIANT_VALUE_PRICECURVE_EXPANSION_ENABLED:int = 3;
      
      public static const EXPERIMENT_RETREAT_COST_MASTER:String = "empire_ransom_retreat";
      
      public static const VARIANT_VALUE_RETREAT_COST_MASTER_ENABLED:int = 3;
      
      public static const EXPERIMENT_RANSOM_ALGORITHM:String = "empire_ransom_algorithm";
      
      public static const EXPERIMENT_MECH_LAB_DAILY_REWARD:String = "empire_mech_lab_daily_reward";
      
      public static const EXPERIMENT_PILLAGE_TIME_EXTEND:String = "empire_pillage_time_extend";
      
      public static const VARIANT_PILLAGE_TIME_EXTEND_ENABLED:int = 3;
      
      public static const EXPERIMENT_ENERGYPINCH_STRUCTUREBUILDCLICKINCREASE:String = "empire_energypinch_structurebuildclickincrease";
      
      public static const VARIANT_ENERGYPINCH_STRUCTUREBUILDCLICKINCREASE_ENABLED:int = 3;
      
      public static const EXPERIMENT_SKIP_NEIGHBOR_PRUNE:String = "empire_skip_unfriendly";
      
      public static const VARIANT_SKIP_NEIGHBOR_PRUNE_ENABLED:int = 1;
      
      public static const EXPERIMENT_STARTER_PACK_V2:String = "empire_starter_pack_v2";
      
      public static const EXPERIMENT_WTE_BOUNTY:String = "empire_wte_bounty";
      
      public static const WTE_BOUNTY_ENABLED_VARIANT:int = 1;
      
      public static const EXPERIMENT_WTE_TARGETING:String = "empire_wte_targeting";
      
      public static const EXPERIMENT_WTE_JS_TARGETING:String = "empire_wte_js_targeting";
      
      public static const VARIANT_VALUE_STARTER_PACK_V2_NON_PAYERS:int = 3;
      
      public static const VARIANT_VALUE_STARTER_PACK_V2_PAYERS:int = 4;
      
      public static const VARIANT_VALUE_STARTER_PACK_V2_ALL_USERS:int = 5;
      
      public static const EXPERIMENT_QUEST_BAR_SORTING:String = "empire_quest_bar_sorting";
      
      public static const VARIANT_VALUE_QUEST_BAR_SORTING_ON:int = 2;
      
      public static const EXPERIMENT_QUEST_BAR_V2:String = "empire_quest_bar_v2";
      
      public static const VARIANT_QUEST_BAR_V2_ON:int = 2;
      
      public static const EXPERIMENT_HIDDEN_CHRONICLES_XPROMO_MOTD:String = "empire_hiddenchronicles_xpromo_motd";
      
      public static const EXPERIMENT_HIDDEN_CHRONICLES_XPROMO_HUD:String = "empire_hiddenchronicles_xpromo_hud_card";
      
      public static const EXPERIMENT_HIDDEN_CHRONICLES_XPROMO_REWARD:String = "empire_hiddenchronicles_xpromo_reward";
      
      public static const EXPERIMENT_HIDDEN_CHRONICLES_XPROMO_ENABLED_VARIANT:int = 2;
      
      public static const VARIANT_VALUE_POWER_UP_PROMPT_ENABLED:int = 3;
      
      public static const VARIANT_VALUE_POWER_UP_PROMPT_ENABLED_EVERY_OTHER_TURN:int = 4;
      
      public static const VARIANT_VALUE_POWER_UP_PROMPT_DISABLED_WITH_CRITICAL_HIT:int = 5;
      
      public static const VARIANT_VALUE_POWER_UP_PROMPT_ENABLED_WITH_CRITICAL_HIT:int = 6;
      
      public static const VARIANT_VALUE_POWER_UP_PROMPT_ENABLED_WITH_CRITICAL_HIT_EVERY_OTHER_TURN:int = 7;
      
      public static const EXPERIMENT_RAREOREPURCHASE_DISABLED:String = "empires_rare_metal_for_coin_disabled";
      
      public static const VARIANT_EXCLUDE_RAREOREPURCHASE:int = 3;
      
      public static const EXPERIMENT_POWERUP_LEVEL_LOCK_IGNORE:String = "empires_power_up_level_lock_ignore";
      
      public static const VARIANT_POWERUPLEVELGATE_IGNORE:int = 3;
      
      public static const EXPERIMENT_STORE_SORTING_REV_ENHANCED:String = "empire_store_sorting_rev_enhanced";
      
      public static const VARIANT_STORE_SORTING_REV_ENHANCED:int = 3;
      
      public static const VARIANT_VALUE_REPORT_BUG_PROMPT_ON:int = 3;
      
      public static const VARIANT_VALUE_MOTD_SCROLLING_ON:int = 3;
      
      public static const VARIANT_VALUE_REPLACE_CREW_ON:int = 3;
      
      public static const VARIANT_VALUE_REMEMBER_LAST_BUILD_MENU_PAGE_ON:int = 3;
      
      public static const VARIANT_VALUE_EMPHASIZE_ENERGY_DOOBER_ON:int = 3;
      
      public static const VARIANT_VALUE_REQUEST2_MASTER_ON:int = 2;
      
      public static const VARIANT_VALUE_COMBAT_TOASTER_ON:int = 3;
      
      public static const VARIANT_VALUE_MOTD2_ON:int = 3;
      
      public static const EXPERIMENT_MECH_LAB_MASTER:String = "empire_mech_lab_master";
      
      public static const VARIANT_VALUE_MECH_LAB_ENABLED:int = 3;
      
      public static const EXPERIMENT_TOGGLE_QUALITY:String = "empire_toggle_quality";
      
      public static const VARIANT_VALUE_TOGGLE_QUALITY_ON:int = 2;
      
      public static const EXPERIMENT_TITAN_FIGHT_MASTER:String = "empire_mech_fight_master";
      
      public static const VARIANT_TITAN_FIGHT_ACTIVE:int = 3;
      
      public static const EXPERIMENT_STARTER_PACK_SURFACING:String = "empires_starter_pack_surfacing";
      
      public static const VARIANT_STARTER_PACK_SURFACING:int = 3;
      
      public static const EXPERIMENT_RESEARCH_SURFACING_MASTER:String = "empire_research_surfacing";
      
      public static const EXPERIMENT_RESEARCH_SURFACING_ON:int = 2;
      
      public static const EXPERIMENT_MYSTERYUNIT_SWITCH_FREE:String = "empire_mysteryunit_switch_free";
      
      public static const EXPERIMENT_MYSTERYUNIT_SWITCH_FREE_ENABLED:int = 2;
      
      public static const EXPERIMENT_DOMINANCE_CHANGE_REVENGE_ICON:String = "empire_dominance_change_revenge_icon";
      
      public static const VARIANT_DOMINANCE_CHANGE_REVENGE_ICON:int = 3;
      
      public static const EXPERIMENT_DOMINATION_MASTER:String = "empire_domination_master";
      
      public static const VARIANT_DOMINATION_MASTER_ENABLED:int = 3;
      
      public static const EXPERIMENT_DOMINATION_WARCHEST:String = "empire_domination_warchest";
      
      public static const EXPERIMENT_DOMINATION_WARCHEST_ENABLED:int = 2;
      
      public static const EXPERIMENT_FLUID_CANVAS:String = "empire_fluid_canvas";
      
      public static const EXPERIMENT_BOUNTY_COOLDOWN_PERIOD:String = "empire_bounty_cooldown_period";
      
      public static const EXPERIMENT_BOUNTY_HUD_CHANGE:String = "empire_bounty_hud_change";
      
      public static const EXPERIMENT_BOUNTY_PAYOUT:String = "empire_bounty_payout";
      
      public static const EXPERIMENT_BOUNTY_ENERGYREQS:String = "empire_bounty_energyreqs";
      
      public static const EXPERIMENT_LEADERBOARD_SUMMARY:String = "empire_leaderboard_summary";
      
      public static const EXPERIMENT_LEADERBOARD_SUMMARY_ENABLED_VARIANT:int = 1;
      
      public static const EMPIRE_PRISONCAMP_MASTER:String = "empire_prisoncamp_master";
      
      public static const EMPIRE_PRISONCAMP_MASTER_VARIANT:int = 3;
      
      public static const EXPERIMENT_BUILDABLE_ENERGYBOOSTER_MASTER:String = "empire_buildable_energybooster_master";
      
      public static const VARIANT_BUILDABLE_ENERGYBOOSTER_ON:int = 3;
      
      public static const EXPERIMENT_BUILDABLE_ENERGYBOOSTER__LOWENERGY_POPUP:String = "empire_buildable_energybooster_lowenergy_popup";
      
      public static const VARIANT_BUILDABLE_ENERGYBOOSTER__LOWENERGY_POPUP_ON:int = 3;
      
      public static const EXPERIMENT_BUILDABLE_ZCOLLIDER_MASTER:String = "empire_buildable_zcollider_master";
      
      public static const EXPERIMENT_BUILDABLE_ZGENERATOR_MASTER:String = "empire_buildable_zgenerator_master";
      
      public static const EXPERIMENT_BUILDABLE_ZGENERATOR_PARTSASN:String = "empire_buildable_zgenerator_partsasn";
      
      public static const EXPERIMENT_BUILDABLE_ZGENERATOR_PRICE:String = "empire_buildable_zgenerator_price";
      
      public static const EXPERIMENT_BUILDABLE_ZGENERATOR_REGENTIME:String = "empire_buildable_zgenerator_regentime";
      
      public static const EXPERIMENT_BUILDABLE_ZGENERATOR_EARLYBIRD:String = "empire_buildable_zgenerator_earlybird";
      
      public static const EXPERIMENT_MATCHMAKING_MASTER:String = "empire_matchmaking_master";
      
      public static const EXPERIMENT_MATCHMAKING_SAME_COUNTRY_SUGGESTIONS:String = "empire_matchmaking_samecountrysuggestions";
      
      public static const EXPERIMENT_MATCHMAKING_ASN_MATCHES:String = "empires_matchmaking_asnmatches";
      
      public static const EXPERIMENT_MATCHMAKING_SHOW_ENGAGEMENT:String = "empires_matchmaking_showengagement";
      
      public static const EXPERIMENT_MATCHMAKING_ADD_FB_BTN_FEEDS:String = "empire_matchmaking_addfbbuttonfeeds";
      
      public static const VARIANT_MATCHMAKING_MASTER_ON:int = 3;
      
      public static const EXPERIMENT_MATCHMAKING_ADD_FB_BTN_FEEDS_ON:int = 1;
      
      public static const EXPERIMENT_RESEARCH_SHIELD_UPGRADE:String = "empire_research_shield_upgrade";
      
      public static const VARIANT_RESEARCH_SHIELD_UPGRADE_ON:int = 2;
      
      public static const EXPERIMENT_SURVIVAL_ELITE:String = "empire_survival_elite";
      
      public static const VARIANT_EXPERIMENT_SURVIVAL_ELITE_ON:int = 2;
      
      public static const EXPERIMENT_MATCHMAKING_REQUESTTHROTTLE:String = "empire_matchmaking_requeststhrottle";
      
      public static const EXPERIMENT_QUEST_REWARD_BUY:String = "empire_quest_reward_buy";
      
      public static const EXPERIMENT_AUTOPROMOTIONS:String = "empire_autopromotions";
      
      public static const EXPERIMENT_LE_DISCOUNT_SALE:String = "empire_le_discount_sale";
      
      public static const EXPERIMENT_LE_DISCOUNT_SALE_ENABLED_VARIANT:int = 3;
      
      public static const EXPERIMENTS_LOADED:String = "ExperimentsLoaded";
      
      public static var instance:ExperimentsManager = new ExperimentsManager();
      
      public static const EXPERIMENT_TIER_8:String = "empire_tier_8";
      
      public static const EXPERIMENT_TIER_8_VARIANT_ENABLE:int = 3;
      
      public static const EXPERIMENT_SPLIT_LOADER:String = "empire_split_loader";
      
      public static const EXPERIMENT_SPLIT_LOADER_VARIANT_ALL_ENABLE:int = 3;
      
      public static const EXPERIMENT_SPLIT_LOADER_VARIANT_7:int = 7;
      
      public static const EXPERIMENT_TIER_SURFACING_2:String = "empire_tier_surfacing_2";
      
      public static const EXPERIMENT_TIER_SURFACING_2_ENABLED_VARIANT:int = 2;
      
      public static const EXPERIMENT_SURVIVALMODE_ENHANCEMENTS:String = "empire_survivalmode_enhancements";
      
      public static const VARIANT_SURVIVALMODE_ENHANCEMENTS_ENABLED:int = 2;
      
      public static const EXPERIMENT_YELLOWUNITS_FLAMEDAMAGE:String = "empires_yellow_units_flame_damage";
      
      public static const EXPERIMENT_RETAINNEIGHBOR_MASTER:String = "empire_retainneighbor_master";
      
      public static const VARIANT_RETAINNEIGHBOR_ENABLED:int = 3;
      
      public static const EXPERIMENT_CAMPAIGN_2_5:String = "empire_campaign_2_5";
      
      public static const EXPERIMENT_CAMPAIGN_2_5_ENABLED_VARIANT:int = 3;
      
      public static const EXPERIMENT_CAMPAIGN_3:String = "empire_campaign_3";
      
      public static const EXPERIMENT_CAMPAIGN_3_ENABLED_VARIANT:int = 3;
      
      public static const EXPERIMENT_POPUP_BLOCKER:String = "empire_popup_blocker";
      
      public static const EXPERIMENT_RAFFLE_TICKETSIZE:String = "empire_raffle_ticketsize";
      
      public static const EXPERIMENT_CAPTURE_ENERGY_STATS:String = "empire_capture_energy_stats";
      
      public static const EXPERIMENT_CAPTURE_ENERGY_STATS_ENABLED:int = 1;
      
      public static const EXPERIMENT_WHITEUNIT_ENERGY_DOOBER:String = "empire_whiteunit_energy_doober";
      
      public static const EXPERIMENT_WHITEUNIT_ENERGY_DOOBER_ENABLED:int = 3;
      
      public static const EXPERIMENT_BOOKMARKSINCENTIVE_MASTER:String = "empires_master_bookmarksincentive";
      
      public static const EXPERIMENT_BLACKMARKET_MASTER:String = "empire_blackmarket_master";
      
      public static const EXPERIMENT_BLACKMARKET_ENABLED_VARIANT:int = 3;
      
      public static const EXPERIEMNT_FULL_HEALER:String = "empire_full_healer";
      
      public static const EXPERIMENT_MFS_UILI:String = "empire_mfs_uili";
      
      public static const EXPERIMENT_FIGHTMETER:String = "empire_fightmeter";
      
      public static const VARIANT_MFS_UILI_OLD_EXHAUSTIVE:int = 3;
      
      public static const VARIANT_MFS_UILI_OLD_CYCLIC:int = 4;
      
      public static const VARIANT_MFS_UILI_NEW_EXHAUSTIVE:int = 5;
      
      public static const VARIANT_MFS_UILI_NEW_CYCLIC:int = 6;
      
      public static const EXPERIMENT_FB_GROUP_MASTER:String = "empire_fb_group_master";
      
      public static const EXPERIMENT_MFSP2_MASTER:String = "empire_mfsp2_master";
      
      public static const VARIANT_MFSP2_MASTER_ON:int = 3;
      
      public static const EXPERIMENT_MFSP2_GAMECLICK:String = "empire_mfsp2_gameclick";
      
      public static const VARIANT_MFSP2_GAMECLICK_3:int = 3;
      
      public static const VARIANT_MFSP2_GAMECLICK_4:int = 4;
      
      public static const EXPERIMENT_MFSP2_TAB:String = "empire_mfsp2_tab";
      
      public static const VARIANT_MFSP2_TAB_ON:int = 3;
      
      public static const EXPERIMENT_MFSP2_SEARCH:String = "empire_mfsp2_search";
      
      public static const VARIANT_MFSP2_SEARCH_ON:int = 3;
      
      public static const EXPERIMENT_MFSP2_REWARDBAR:String = "empire_mfsp2_rewardbar";
      
      public static const VARIANT_MFSP2_REWARDBAR_ON:int = 3;
      
      public static const EXPERIMENT_REVIVE_ALLIES:String = "empire_revive_allies";
      
      public static const VARIANT_REVIVE_ALLIES_ON:int = 2;
      
      public static const VARIANT_FIGHTMETER_ON:int = 3;
      
      private var m_experimentVariants:Object = null;
      
      public function ExperimentsManager()
      {
         super();
      }
      
      public function setExperiments(param1:Object) : void
      {
         this.m_experimentVariants = param1;
      }
      
      public function getExperimentVariant(param1:String) : int
      {
         if(this.m_experimentVariants)
         {
            if(param1 in this.m_experimentVariants)
            {
               return this.m_experimentVariants[param1];
            }
         }
         return 0;
      }
      
      public function getExperimentValue(param1:String, param2:Array, param3:Number, param4:int = -1) : Number
      {
         var _loc5_:int = this.getExperimentVariant(param1);
         if(param2)
         {
            if(_loc5_ < param2.length)
            {
               return param2[_loc5_];
            }
         }
         return param3;
      }
      
      public function allyGateIncrease() : int
      {
         var _loc3_:XML = null;
         var _loc4_:int = 0;
         var _loc1_:int = 0;
         var _loc2_:String = ZGlobal.player.campaign.currentCampaignName;
         if(_loc2_ == "camp001" && !ZGlobal.player.campaign.isMapLocked("C005") || Boolean(_loc2_ == "camp002") && Boolean(ZGlobal.player.isPayingUser()))
         {
            _loc3_ = CampaignManager.instance.getCampaignDefinition(_loc2_);
            _loc4_ = this.getExperimentVariant(_loc3_.@allyGatingExperiment);
            switch(_loc4_)
            {
               case 0:
               case 1:
                  break;
               default:
                  _loc1_ = _loc4_ - 1;
            }
         }
         return _loc1_;
      }
      
      public function validateItem(param1:XML) : Boolean
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:Array = null;
         var _loc5_:String = null;
         if(param1.requiredExperiment != undefined)
         {
            _loc2_ = param1.requiredExperiment.@name;
            _loc3_ = param1.requiredExperiment.@variants;
            _loc4_ = _loc3_.split(",");
            _loc5_ = this.getExperimentVariant(_loc2_).toString();
            if(_loc4_.indexOf(_loc5_) < 0)
            {
               return false;
            }
         }
         return true;
      }
      
      public function experimentGateEnabled(param1:String, param2:String) : Boolean
      {
         var _loc3_:String = this.getExperimentVariant(param1).toString();
         var _loc4_:Array = param2.split(",");
         return _loc4_.indexOf(_loc3_) >= 0;
      }
      
      public function experimentObjectEnabled(param1:Object) : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:Array = null;
         if(Boolean(param1) && Boolean(param1.name != undefined) && param1.name != null)
         {
            _loc2_ = this.getExperimentVariant(param1.name);
            _loc3_ = param1.enabled.toString().split(",");
            return _loc3_.indexOf(String(_loc2_)) >= 0;
         }
         return false;
      }
   }
}

