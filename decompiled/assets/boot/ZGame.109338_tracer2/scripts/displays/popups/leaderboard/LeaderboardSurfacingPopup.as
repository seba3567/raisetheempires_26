package displays.popups.leaderboard
{
   import core.ZGameStats;
   import core.ZGlobal;
   import core.managers.leaderboardManager.Leaderboard;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.UI;
   import core.ui.ZGameButton;
   import dispatchers.StrategicDispatcher;
   import displays.popups.buyEnergy.BuyEnergyPopup;
   import displays.screens.Store;
   import displays.screens.leaderboard.Board;
   import displays.screens.leaderboard.SurfacingBoard;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.utils.MathUtils;
   
   public class LeaderboardSurfacingPopup extends LeaderboardPopup
   {
      
      private static var m_hints:Array = [["Leaderboards_CampaignHintText1","Leaderboards_CampaignHintText2","Leaderboards_CampaignHintText3","Leaderboards_CampaignHintText4"],["Leaderboards_DamageHint1","Leaderboards_DamageHint2","Leaderboards_DamageHint3"],["Leaderboards_OreHint1","Leaderboards_OreHint3"],["Leaderboards_HonorDashHint1","Leaderboards_HonorDashHint2"],["Leaderboards_InfamyDashHint1","Leaderboards_InfamyDashHint2"],["Leaderboards_XPDashHint1","Leaderboards_XPDashHint2"],["Leaderboards_GPVPDamageHint1","Leaderboards_GPVPDamageHint2","Leaderboards_GPVPDamageHint3"],["Leaderboards_UnitsKilledHint1","Leaderboards_UnitsKilledHint2"],["Leaderboards_CriticalHitsHint1","Leaderboards_CriticalHitsHint2"],["Leaderboards_ExpansionsHint1","Leaderboards_ExpansionsHint2"],["Leaderboards_NeighborTendsHint1"],["Leaderboards_ResearchUpgradesHint1"],["Leaderboards_SurvivalHint1"],["Leaderboards_CoinsHint1","Leaderboards_CoinsHint2"],["Leaderboards_ResourcesHint1","Leaderboards_ResourcesHint2"],["Leaderboards_DamageHint1"
      ,"Leaderboards_DamageHint2","Leaderboards_DamageHint3"]];
      
      private static var m_buttonLabels:Array = [["Leaderboards_CampaignHintButton1","Leaderboards_CampaignHintButton2","Leaderboards_CampaignHintButton3","Leaderboards_CampaignHintButton4"],["Leaderboards_DamageHintButton1","Leaderboards_DamageHintButton2","Leaderboards_DamageHintButton3"],["Leaderboards_OreHintButton1","Leaderboards_OreHintButton3"],["Leaderboards_HonorDashHintButton1","Leaderboards_HonorDashHintButton2"],["Leaderboards_InfamyDashButton1","Leaderboards_InfamyDashHintButton2"],["Leaderboards_XPDashHintButton1","Leaderboards_XPDashHintButton2"],["Leaderboards_GPVPDamageHintButton1","Leaderboards_GPVPDamageHintButton2","Leaderboards_GPVPDamageHintButton3"],["Leaderboards_UnitsKilledButton1","Leaderboards_UnitsKilledButton2"],["Leaderboards_CriticalHitsButton1","Leaderboards_CriticalHitsButton2"],["Leaderboards_ExpansionsButton1","Leaderboards_ExpansionsButton2"],["Leaderboards_NeighborTendsButton1"],["Leaderboards_ResearchUpgradesButton1"],["Leaderboards_SurvivalButton1"],["Leaderboards_CoinsHintButton1"
      ,"Leaderboards_CoinsHintButton2"],["Leaderboards_ResourcesHintButton1","Leaderboards_ResourcesHintButton2"],["Leaderboards_DamageHintButton1","Leaderboards_DamageHintButton2","Leaderboards_DamageHintButton3"]];
      
      private static var m_stats:Array = [["lb_campaign_hint_buy_energy","lb_campaign_hint_ask_energy","lb_campaign_hint_buy_consumable","lb_campaign_hint_invite_friends"],["lb_damage_hint_ask_parts","lb_damage_hint_buy_units","lb_damage_hint_buy_consumable"],["lb_ore_hint_buy_ore","lb_ore_hint_build_structures"],["lb_honor_hint_invite_friends","lb_honor_hint_buy_units"],["lb_infamy_hint_buy_consumable","lb_infamy_hint_ask_parts"],["lb_xp_hint_buy_consumable","lb_xp_hint_ask_parts"],["lb_gpvp_damage_hint_ask_parts","lb_gpvp_damage_hint_buy_units","lb_gpvp_damage_hint_buy_consumable"],["lb_units_killed_hint_ask_parts","lb_units_killed_hint_buy_consumable"],["lb_critical_hits_hint_buy_powerups","lb_critical_hits_hint_ask_energy"],["lb_expansions_hint_ask_energy","lb_expansions_hint_buy_coins"],["lb_neighbor_tends_hint_buy_powerups"],["lb_research_upgrades_ask_energy"],["lb_survival_ask_energy"],["lb_coins_hint_buy_coins","lb_coins_hint_build_structures"],["lb_woodoil_hint_buy_woodoil","lb_woodoil_hint_build_structures"]
      ,["lb_survival_damage_hint_ask_parts","lb_survival_damage_hint_buy_units","lb_survival_damage_hint_buy_consumable"]];
      
      private static var m_buttonCallbacks:Array = ["onCampaign","onDamage","onResource","onHonor","onInfamy","onXp","onDamage","onUnitsKilled","onCriticalHits","onExpansions","onNeighborTends","onResearchUpgrades","onSurvival","onCoins","onWoodOil","onDamage"];
      
      private var m_board:Board = null;
      
      private var m_leaderboard:Leaderboard = null;
      
      private var m_button:ZGameButton = null;
      
      private var m_hintType:int = 0;
      
      private var m_hintIndex:int = 0;
      
      private const HINT_INDEX_CAMPAIGN:int = 0;
      
      private const HINT_INDEX_DAMAGE:int = 1;
      
      private const HINT_INDEX_ORE:int = 2;
      
      private const HINT_INDEX_HONOR:int = 3;
      
      private const HINT_INDEX_INFAMY:int = 4;
      
      private const HINT_INDEX_XP:int = 5;
      
      private const HINT_INDEX_GPVPDAMAGE:int = 6;
      
      private const HINT_INDEX_UNITS_KILLED:int = 7;
      
      private const HINT_INDEX_CRITICAL_HITS:int = 8;
      
      private const HINT_INDEX_EXPANSIONS:int = 9;
      
      private const HINT_INDEX_SURVIVAL:int = 12;
      
      private const HINT_INDEX_COINS:int = 13;
      
      private const HINT_INDEX_RESOURCES:int = 14;
      
      private const HINT_INDEX_SURVIVALDAMAGE:int = 15;
      
      public function LeaderboardSurfacingPopup(param1:Leaderboard)
      {
         super();
         this.m_leaderboard = param1;
         this.m_board = new SurfacingBoard(param1,false);
         this.initHints();
      }
      
      override public function get statsData() : Object
      {
         return {
            "counter":"dialog",
            "kingdom":m_stats[this.m_hintType][this.m_hintIndex]
         };
      }
      
      override protected function get screen() : MovieClip
      {
         return m_window.standings_mc;
      }
      
      override protected function initializeScreen() : void
      {
         this.contentWidth = this.screen.panel_mc.width;
         this.contentHeight = this.screen.panel_mc.height;
         super.initializeScreen();
         this.screen.exit_bt.addEventListener(MouseEvent.CLICK,onExit,false,0,true);
         TextFieldUtil.compactTextField(this.screen.heading_tf,ZGameUtils.ZlocT("Leaderboards","Leaderboards_SurfacingTitle",{"title":this.m_board.title}),{"minScale":0.7});
         TextFieldUtil.processTextField(this.screen.subHeading_tf,ZGameUtils.ZlocT("Leaderboards","Leaderboards_SurfacingRanking",{
            "rank":this.m_board.rank,
            "amount":this.m_board.numValidEntries
         }));
         TextFieldUtil.processTextField(this.screen.subHeading2_tf,ZGameUtils.ZlocT("Leaderboards","Leaderboards_SurfacingHintTitle"));
         this.m_button = new ZGameButton(this.screen.return_mc,this.onAccept);
         var _loc1_:String = m_hints[this.m_hintType][this.m_hintIndex];
         var _loc2_:String = m_buttonLabels[this.m_hintType][this.m_hintIndex];
         TextFieldUtil.compactTextField(this.screen.hints_tf,ZGameUtils.ZlocT("Leaderboards",_loc1_));
         this.m_button.text = ZGameUtils.ZlocT("Leaderboards",_loc2_);
         updateTitleTrophies();
         this.populateBars();
      }
      
      private function initHints() : void
      {
         if(this.m_leaderboard.type == Leaderboard.TYPE_CAMPAIGN)
         {
            this.m_hintType = this.HINT_INDEX_CAMPAIGN;
         }
         else if(this.m_leaderboard.type == Leaderboard.TYPE_RESOURCE)
         {
            if(this.m_leaderboard.matchesMetric("coins"))
            {
               this.m_hintType = this.HINT_INDEX_COINS;
            }
            else if(this.m_leaderboard.matchesMetric("wood") && this.m_leaderboard.matchesMetric("oil"))
            {
               this.m_hintType = this.HINT_INDEX_RESOURCES;
            }
            else
            {
               this.m_hintType = this.HINT_INDEX_ORE;
            }
         }
         else if(this.m_leaderboard.type == Leaderboard.TYPE_DAMAGE)
         {
            this.m_hintType = this.HINT_INDEX_DAMAGE;
         }
         else if(this.m_leaderboard.type == Leaderboard.TYPE_HONOR)
         {
            this.m_hintType = this.HINT_INDEX_HONOR;
         }
         else if(this.m_leaderboard.type == Leaderboard.TYPE_INFAMY)
         {
            this.m_hintType = this.HINT_INDEX_INFAMY;
         }
         else if(this.m_leaderboard.type == Leaderboard.TYPE_XP)
         {
            this.m_hintType = this.HINT_INDEX_XP;
         }
         else if(this.m_leaderboard.type == Leaderboard.TYPE_GPVP_DAMAGE)
         {
            this.m_hintType = this.HINT_INDEX_DAMAGE;
         }
         else if(this.m_leaderboard.type == Leaderboard.TYPE_UNITS_KILLED)
         {
            this.m_hintType = this.HINT_INDEX_UNITS_KILLED;
         }
         else if(this.m_leaderboard.type == Leaderboard.TYPE_CRITICAL_HITS)
         {
            this.m_hintType = this.HINT_INDEX_CRITICAL_HITS;
         }
         else if(this.m_leaderboard.type == Leaderboard.TYPE_EXPANSIONS)
         {
            this.m_hintType = this.HINT_INDEX_EXPANSIONS;
         }
         else if(this.m_leaderboard.type == Leaderboard.TYPE_SURVIVAL || this.m_leaderboard.type == Leaderboard.TYPE_SURVIVAL2)
         {
            this.m_hintType = this.HINT_INDEX_SURVIVAL;
         }
         else if(this.m_leaderboard.type == Leaderboard.TYPE_SURVIVAL_DAMAGE)
         {
            this.m_hintType = this.HINT_INDEX_SURVIVALDAMAGE;
         }
         this.m_hintIndex = int(Math.round(MathUtils.randBetween(0,m_hints[this.m_hintType].length - 1)));
      }
      
      override protected function deinitDialog() : void
      {
         this.screen.exit_bt.removeEventListener(MouseEvent.CLICK,onExit);
         this.m_button.dispose();
         this.m_button = null;
         super.deinitDialog();
      }
      
      private function get bars() : Array
      {
         return [this.screen.bar1_mc,this.screen.bar2_mc,this.screen.bar3_mc,this.screen.bar4_mc];
      }
      
      private function populateBars() : void
      {
         var _loc5_:int = 0;
         var _loc1_:Array = this.bars;
         this.m_board.beginPopulation(_loc1_);
         var _loc2_:int = int(_loc1_.length);
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_)
         {
            _loc1_[_loc4_].visible = true;
            _loc5_ = this.m_board.populateBar(_loc1_[_loc4_],_loc3_);
            if(_loc5_ == Board.ERROR)
            {
               break;
            }
            if(_loc5_ != Board.SKIP_ENTRY)
            {
               _loc4_++;
            }
            _loc3_++;
         }
         while(_loc4_ < _loc2_)
         {
            _loc1_[_loc4_].visible = false;
            _loc4_++;
         }
      }
      
      private function onAccept(param1:MouseEvent) : void
      {
         close();
         var _loc2_:Object = this.statsData;
         _loc2_.phylum = "yes";
         ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_GENERIC_BUTTON_CLICKED,_loc2_));
         this[m_buttonCallbacks[this.m_hintType]](this.m_hintIndex);
      }
      
      private function onCampaign(param1:int) : void
      {
         switch(param1)
         {
            case 0:
               if(ZGlobal.player.m_energy.canAcceptEnergy(1))
               {
                  BuyEnergyPopup.enableWatchToEarn();
                  BuyEnergyPopup.show(null,false,["lb_campaign_hint_buy_energy","","",""],"leaderboard");
               }
               else
               {
                  this.sendEnergyFeed();
               }
               break;
            case 1:
               this.sendEnergyFeed();
               break;
            case 2:
               this.showStore(Store.TAB_POWERUP_LABEL);
               break;
            case 3:
               ZGlobal.switchToTab("invite");
         }
      }
      
      private function sendEnergyFeed() : void
      {
         ViralsManager.instance.sendFeed("LB_AskForEnergy",{
            "user":ZGlobal.player.firstName,
            "title":this.m_board.title
         });
      }
      
      private function onDamage(param1:int) : void
      {
         switch(param1)
         {
            case 0:
               ViralsManager.instance.sendFeed("LB_AskForParts",{
                  "user":ZGlobal.player.firstName,
                  "title":this.m_board.title
               });
               break;
            case 1:
               this.showStore(Store.TAB_UNITS_LABEL);
               break;
            case 2:
               this.showStore(Store.TAB_POWERUP_LABEL);
         }
      }
      
      private function onResource(param1:int) : void
      {
         switch(param1)
         {
            case 0:
               this.showStore(Store.TAB_RESOURCES_LABEL,"RS11");
               break;
            case 1:
               this.showStore(Store.TAB_INDUSTRY_LABEL);
         }
      }
      
      private function onCoins(param1:int) : void
      {
         switch(param1)
         {
            case 0:
               this.showStore(Store.TAB_RESOURCES_LABEL,"EN1");
               break;
            case 1:
               this.showStore(Store.TAB_INDUSTRY_LABEL);
         }
      }
      
      private function onWoodOil(param1:int) : void
      {
         switch(param1)
         {
            case 0:
               this.showStore(Store.TAB_RESOURCES_LABEL,"RS01");
               break;
            case 1:
               this.showStore(Store.TAB_INDUSTRY_LABEL);
         }
      }
      
      private function onHonor(param1:int) : void
      {
         switch(param1)
         {
            case 0:
               ZGlobal.switchToTab("invite");
               break;
            case 1:
               this.showStore(Store.TAB_UNITS_LABEL);
         }
      }
      
      private function onInfamy(param1:int) : void
      {
         switch(param1)
         {
            case 0:
               this.showStore(Store.TAB_POWERUP_LABEL);
               break;
            case 1:
               ViralsManager.instance.sendFeed("LB_AskForParts",{
                  "user":ZGlobal.player.firstName,
                  "title":this.m_board.title
               });
         }
      }
      
      private function onXp(param1:int) : void
      {
         switch(param1)
         {
            case 0:
               this.sendEnergyFeed();
               break;
            case 1:
               ZGlobal.switchToTab("invite");
         }
      }
      
      private function onUnitsKilled(param1:int) : void
      {
         switch(param1)
         {
            case 0:
               ViralsManager.instance.sendFeed("LB_AskForParts",{
                  "user":ZGlobal.player.firstName,
                  "title":this.m_board.title
               });
               break;
            case 1:
               this.showStore(Store.TAB_POWERUP_LABEL);
         }
      }
      
      private function onCriticalHits(param1:int) : void
      {
         switch(param1)
         {
            case 0:
               this.showStore(Store.TAB_POWERUP_LABEL);
               break;
            case 1:
               this.sendEnergyFeed();
         }
      }
      
      private function onExpansions(param1:int) : void
      {
         switch(param1)
         {
            case 0:
               this.sendEnergyFeed();
               break;
            case 1:
               this.showStore(Store.TAB_RESOURCES_LABEL);
         }
      }
      
      private function onNeighborTends(param1:int) : void
      {
         switch(param1)
         {
            case 0:
               ZGlobal.switchToTab("invite");
               break;
            case 1:
         }
      }
      
      private function onResearchUpgrades(param1:int) : void
      {
         switch(param1)
         {
            case 0:
               ViralsManager.instance.sendFeed("LB_AskForParts",{
                  "user":ZGlobal.player.firstName,
                  "title":this.m_board.title
               });
               break;
            case 1:
         }
      }
      
      private function onSurvival(param1:int) : void
      {
         switch(param1)
         {
            case 0:
               this.sendEnergyFeed();
               break;
            case 1:
         }
      }
      
      private function showStore(param1:String, param2:String = null) : void
      {
         StrategicDispatcher.instance.dispatchEvent(new Event(StrategicDispatcher.DISPLAYING_LEADERBOARD_SCREEN));
         var _loc3_:Object = {
            "tab":param1,
            "genus":"leaderboard"
         };
         if(param2)
         {
            _loc3_.focusGameItemCode = param2;
         }
         UI.instance.displayStoreDialog(_loc3_);
      }
   }
}

