package core.gamemode.battle
{
   import flash.events.EventDispatcher;
   
   public class BattleDispatcher extends EventDispatcher
   {
      
      public static var instance:BattleDispatcher = new BattleDispatcher();
      
      public static const BATTLE_START:String = "battlestart";
      
      public static const BATTLE_UPDATE:String = "battleupdate";
      
      public static const BATTLE_ADD:String = "battleadd";
      
      public static const BATTLE_CONTINUE_FROM_CONSUMABLE:String = "battlecontinueconsumable";
      
      public static const BATTLE_PRE_START:String = "battleprestart";
      
      public static const BATTLE_PRE_END:String = "battlepreend";
      
      public static const BATTLE_PLAYER_TURN:String = "battlepturn";
      
      public static const BATTLE_ENEMY_TURN:String = "battleeturn";
      
      public static const BATTLE_RESULT:String = "battleresult";
      
      public static const BATTLE_SEQUENCE_STARTED:String = "battlesequencestarted";
      
      public static const BATTLE_SEQUENCE_COMPLETE:String = "battlesequenceComplete";
      
      public static const BATTLE_PAIR_COMPLETE:String = "battlepaircomplete";
      
      public static const BATTLE_UI_ENEMY_OBJECT_CHOSEN:String = "battleenemyobjchosen";
      
      public static const BATTLE_UI_PLAYER_OBJECT_CHOSEN:String = "battleplayerobjchosen";
      
      public static const BATTLE_UI_PAIR_CHOSEN:String = "battlepairchosen";
      
      public static const BATTLE_UI_RECALCULATE_HIGHLIGHT:String = "battlerecalchighlight";
      
      public static const BATTLE_UI_SET_PLAYER_HIGHLIGHTED_UNIT:String = "battlesetplayerhighlightunit";
      
      public static const BATTLE_UI_SET_ENEMY_HIGHLIGHTED_UNIT:String = "battlesetenemyhighlightunit";
      
      public static const BATTLE_UI_DAMAGE_CLASS:String = "battleuidamageclass";
      
      public static const BATTLE_UI_HIT_PERCENT_CLASS:String = "battleuihitpercentclass";
      
      public static const BATTLE_UI_COMMANDO_BONUS_CLASS:String = "battleuicommandobonusclass";
      
      public static const BATTLE_UI_FLAMING_DAMAGE_CLASS:String = "battleuiflamingdamageclass";
      
      public static const BATTLE_COMPLETE_HOST:String = "battlecompletehost";
      
      public static const BATTLE_COMPLETE_MANUAL_HOST:String = "battlecompletemanualhost";
      
      public static const BATTLE_UPDATE_POINTER_HOST:String = "battleupdatepointerhost";
      
      public static const BATTLE_OBJECT_SELECTED:String = "battleobjectselected";
      
      public static const BATTLE_WAITING_FOR_ENEMY_CLICK:String = "waitforenemyclick";
      
      public static const BATTLE_WAITING_FOR_PLAYER_CLICK:String = "waitforplayerclick";
      
      public static const BATTLE_GROUP_HIGHLIGHT:String = "battlegrouphighlight";
      
      public static const BATTLE_SUBGROUP_HIGHLIGHT:String = "battlesubgrouphighlight";
      
      public static const BATTLE_OR_PREBATTLE_GM_ENTERED:String = "battleOrPrebattleGMEntered";
      
      public static const BATTLE_BACKGROUND_CHANGE:String = "battleBackgroundChange";
      
      public static const ENEMY_UNIT_CLICKED:String = "enemyunitclicked";
      
      public static const ENEMY_UNIT_HIGHLIGHTED:String = "enemyunithilite";
      
      public static const PLAYER_UNIT_CLICKED:String = "playerunitclicked";
      
      public static const PLAYER_UNIT_HIGHLIGHTED:String = "playerunithilite";
      
      public static const BATTLE_CONSUMABLE_SELECTED:String = "cnsumableselected";
      
      public static const UNIT_DAMAGE_FROM_CONSUMABLE:String = "unitdamagefromconsumable";
      
      public static const BATTLE_CONSUMABLE_USED:String = "consumableused";
      
      public static const BATTLE_ALLY_CONSUMABLE_USED:String = "allyconsumableused";
      
      public static const BATTLE_MERC_CONSUMABLE_USED:String = "mercconsumableused";
      
      public static const BATTLE_QUEST_POWER_CONSUMABLE_USED:String = "questpowerconsumableused";
      
      public static const BATTLE_POWERUP_CONSUMABLE_USED:String = "powerupconsumableused";
      
      public static const BATTLE_CANCEL_CONSUMABLE:String = "battlecancelconsumable";
      
      public static const BATTLE_TRIGGER_CONSUMABLE:String = "battletriggerconsumable";
      
      public static const BATTLE_SPECIAL_ABILITY_CLICKED:String = "battlespecialabilityclicked";
      
      public static const BATTLE_SPECIAL_ABILITY_CANCELED:String = "battlespecialabilitycanceled";
      
      public static const BATTLE_RETREAT:String = "battleretreat";
      
      public static const BATTLE_PAUSE:String = "battlepause";
      
      public static const BATTLE_CANCEL:String = "battlecancel";
      
      public static const BATTLE_RESUME:String = "battleresume";
      
      public static const REVIVE_UNITS:String = "reviveunits";
      
      public static const REREGISTER_TITAN_PARTS:String = "revivetitanunits";
      
      public static const READD_REREGISTERED_TITAN_PARTS:String = "revivetitanunitspart2";
      
      public static const PRE_BATTLE_CANCEL:String = "prebattlecancel";
      
      public static const UNIT_DAMAGED:String = "unitdamaged";
      
      public static const UNIT_FIRE:String = "unitfire";
      
      public static const UNIT_MISS:String = "unitmiss";
      
      public static const UNIT_HIT:String = "unithit";
      
      public static const UNIT_KILLED:String = "unitkilled";
      
      public static const UNIT_REMOVED:String = "unitremoved";
      
      public static const UNIT_VISUAL_HIT:String = "unitvisualhit";
      
      public static const UNIT_VISUAL_KILL:String = "unitvisualkill";
      
      public static const UNIT_CONSUMABLES_UPDATED:String = "unitconsumables";
      
      public static const FLEET_CONSUMABLES_UPDATED:String = "fleetconsumables";
      
      public static const UNIT_POWER_USED:String = "unitpowerused";
      
      public static const PLAYER_FLEET_DESTROYED:String = "playerfleetdestroyed";
      
      public static const QUEST_BATTLE_STARTED:String = "questbattlestarted";
      
      public static const BATTLE_RECREATE_PLAYER_GROUP:String = "battlerecreateplayergroup";
      
      public static const BATTLE_UNIT_USED_CONSUMABLE_ENERGY:String = "battleUnitUsedConsumableEnergy";
      
      public static const BATTLE_RANSOM_PAID:String = "battleRansomPaid";
      
      public static const BATTLE_RANSOM_CANCELLED:String = "battleRansomCancelled";
      
      public static const BATTLE_TITAN_MODE:String = "battleTitanMode";
      
      public function BattleDispatcher()
      {
         super();
      }
   }
}

