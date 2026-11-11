package core.gamemode.battle
{
   import core.ZGlobal;
   import core.gamemode.GameModeManager;
   import core.gamemode.movie.GMMovie;
   import core.gameobjects.Fleet;
   import core.gameobjects.IslandItem;
   import core.ui.menuitem.ContextualBarUIItem;
   import displays.popups.battlewon.BattleCampaignWonPopup;
   import flash.utils.Dictionary;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class BattleCampaign extends BattleHost
   {
      
      private var m_wonData:Object = null;
      
      public function BattleCampaign(param1:Fleet, param2:Fleet)
      {
         super(param1,param2);
      }
      
      override protected function battleOver(param1:int) : void
      {
         var _loc2_:Fleet = Fleet.getFleet(m_playerFleetName);
         ZGlobal.player.campaign.battleComplete(_loc2_,param1);
         super.battleOver(param1);
      }
      
      override protected function setBattleResult(param1:int) : void
      {
         ZGlobal.player.campaign.setBattleResult(param1);
         super.setBattleResult(param1);
      }
      
      override public function get returnToPreviousView() : Boolean
      {
         return false;
      }
      
      override public function showWonPopup(param1:Array, param2:Array, param3:Dictionary, param4:Function) : void
      {
         var _loc7_:GMMovie = null;
         this.m_wonData = {
            "allies":param1,
            "remainingUnits":param2,
            "lostUnits":param3,
            "popupClosed":param4
         };
         var _loc5_:IslandItem = ZGlobal.player.campaign.currentMap.currentIslandItem;
         var _loc6_:String = _loc5_.endMovie;
         if(_loc6_.length > 0)
         {
            _loc7_ = new GMMovie(_loc6_);
            _loc7_.onComplete = this.displayPopup;
            GameModeManager.instance.addGameMode(_loc7_,false);
            ContextualBarUIItem.getContextualBar().dispatchEvent(new WorldEvent(ContextualBarUIItem.ADD_COMBAT_EVENT));
         }
         else
         {
            this.displayPopup();
         }
      }
      
      override public function rematch() : void
      {
         ZGlobal.player.campaign.rematch = true;
      }
      
      private function displayPopup() : void
      {
         PopupManager.instance.push(new BattleCampaignWonPopup(this.m_wonData.allies,this.m_wonData.remainingUnits,this.m_wonData.lostUnits,this.m_wonData.popupClosed));
         this.m_wonData = null;
      }
   }
}

