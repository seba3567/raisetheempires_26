package core.managers.questManager
{
   import core.ZGlobal;
   import core.gamemode.battle.Battle;
   import core.gameobjects.fleet.FleetComposition;
   import utils.ZGameUtils;
   import zlabs.debug.Logger;
   
   public class SurvivalFightTask extends ZGameTask
   {
      
      public function SurvivalFightTask(param1:int, param2:XML, param3:String, param4:Number)
      {
         super(param1,param2,param3,param4);
         if(param2.@item.toString().length == 0)
         {
            Logger.error(this,"FightItemTask","type: \'fight\' does not have recognised subtype (item)");
         }
      }
      
      public function get regenerateOnRetreat() : Boolean
      {
         return m_xml.@regenerateOnRetreat.toString() == "true";
      }
      
      public function get isPVE() : Boolean
      {
         return m_xml.@isPVE.toString() == "true";
      }
      
      public function get winPopupUsesFirstVictory() : Boolean
      {
         return m_xml.@winPopupUsesFirstVictory.toString() == "true";
      }
      
      public function get episodeDialog() : String
      {
         return m_xml.@showEpisodeDialog.toString();
      }
      
      public function get defaultSelectSlot() : String
      {
         return m_xml.@defaultSelectSlot.toString();
      }
      
      override public function get fleetComposition() : Array
      {
         var _loc1_:FleetComposition = new FleetComposition(m_xml);
         return _loc1_.units;
      }
      
      override public function get hasCombatSetup() : Boolean
      {
         return m_xml.combat != undefined;
      }
      
      override public function get combatSetup() : Object
      {
         var _loc1_:Object = new Object();
         _loc1_.maxUnits = parseInt(m_xml.combat.@maxUnits);
         _loc1_.numAllies = parseInt(m_xml.combat.@numAllies);
         _loc1_.playerType = m_xml.combat.@playerType.toString();
         return _loc1_;
      }
      
      override public function get combatAllies() : Array
      {
         return ZGameUtils.callFunctionFromXml(m_xml.survivalFight.@allies);
      }
      
      public function get percentageRetreat() : Number
      {
         return m_xml.survivalFight.@percentageRetreat;
      }
      
      override public function buyCompletion() : void
      {
         if(!m_complete)
         {
            ZGlobal.player.fleets.fightItemTaskComplete(this.fleetName,Battle.BATTLE_RESULT_NONE);
         }
      }
   }
}

