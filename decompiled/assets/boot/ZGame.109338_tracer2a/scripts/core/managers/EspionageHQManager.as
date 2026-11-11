package core.managers
{
   import Engine.Managers.TransactionManager;
   import Engine.Transactions.Transaction;
   import core.ZGlobal;
   import core.entities.components.UnitStealPickComponent;
   import core.gamemode.battle.BattleDispatcher;
   import core.gameobjects.UnitItem;
   import core.managers.domination.DominationModeManager;
   import core.managers.survivalModeManager.SurvivalModeManager;
   import core.managers.tutorialManager.TutorialHighlighter;
   import core.ui.menuitem.FriendsBarUIItem;
   import entity.GameDataComponent;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import transactions.TEspionageHQUnitStolen;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   
   public class EspionageHQManager extends EventDispatcher
   {
      
      public static const SPY_TYPE_NONE:int = 0;
      
      public static const SPY_TYPE_ONE:int = 1;
      
      public static const SPY_TYPE_TWO:int = 2;
      
      public static const SPY_TYPE_THREE:int = 3;
      
      public static const DISABLE_ESPIONAGE_UNIT_PIC:String = "disableEspionageUnitPic";
      
      public static const ESPIONAGE_HQ_SPY_TYPE:String = "EspionageHQ";
      
      public static const ESPIONAGE_HQ_SPY_SUBTYPE:String = "EspionageHQSpy";
      
      public static const MAX_ALLOWED_BATTLES:int = 5;
      
      public static const MAX_ALLOWED_TIME:int = 24 * 60 * 60;
      
      private static var m_instance:EspionageHQManager = null;
      
      public var isInited:Boolean = false;
      
      private var m_spy_1_Equipped:Boolean = false;
      
      private var m_spy_2_Equipped:Boolean = false;
      
      private var m_spy_3_Equipped:Boolean = false;
      
      private var m_spyDeployedCode:String = null;
      
      private var m_spyTypeDeployed:int = 0;
      
      private var m_battlesFought:int = 0;
      
      private var m_stolenItem:String = null;
      
      private var m_unitUsedInBattle:Boolean = false;
      
      private var m_unitSelectedInPreBattle:Boolean = false;
      
      private var m_spyDeploymentTime:int = 0;
      
      public function EspionageHQManager(param1:IEventDispatcher = null)
      {
         super(param1);
      }
      
      public static function get instance() : EspionageHQManager
      {
         if(m_instance == null)
         {
            m_instance = new EspionageHQManager();
         }
         return m_instance;
      }
      
      public static function showhighlight() : void
      {
         var thl:TutorialHighlighter = null;
         var timer:Timer = null;
         thl = new TutorialHighlighter();
         timer = new Timer(5000);
         thl.setDisplayObject(FriendsBarUIItem.getFriendsBar(),true,0,true);
         timer.addEventListener(TimerEvent.TIMER,function(param1:TimerEvent):void
         {
            thl.dispose();
            timer.stop();
         });
         timer.start();
      }
      
      public function get hasStolenUnit() : Boolean
      {
         if(this.m_stolenItem != null && this.m_stolenItem != "")
         {
            return true;
         }
         return false;
      }
      
      public function get stolenUnit() : String
      {
         return this.m_stolenItem;
      }
      
      public function doIslandLoadedActions() : void
      {
         if(!(ZGlobal.isVisiting() && PVPManager.instance.isNormalVisit()))
         {
            return;
         }
         if(this.m_spyDeployedCode == null || this.m_stolenItem != null)
         {
            return;
         }
         var _loc1_:Dictionary = WorldObjectManager.instance.getObjectsBySubType("Buildable","army");
         var _loc2_:Dictionary = WorldObjectManager.instance.getObjectsBySubType("Buildable","navy");
         var _loc3_:Dictionary = WorldObjectManager.instance.getObjectsBySubType("Buildable","air");
         this.addComponent(_loc1_);
         this.addComponent(_loc2_);
         this.addComponent(_loc3_);
      }
      
      private function addComponent(param1:Dictionary) : void
      {
         var _loc2_:IEntity = null;
         var _loc3_:UnitItem = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         for each(_loc2_ in param1)
         {
            _loc3_ = ZGlobal.gameSettings.getItemByName(_loc2_.alias,UnitItem) as UnitItem;
            _loc4_ = _loc3_.tier;
            _loc5_ = _loc3_.setName.search("LightningDeal");
            if(this.spyStealable(_loc4_) && _loc5_ == -1)
            {
               _loc2_.removeComponent(_loc2_.lookupComponentByName("VisitHostComponent"));
               _loc2_.addComponent(new UnitStealPickComponent(_loc2_),"UnitStealPick");
            }
         }
      }
      
      private function spyStealable(param1:int) : Boolean
      {
         switch(this.m_spyTypeDeployed)
         {
            case SPY_TYPE_ONE:
               if(param1 >= 1 && param1 <= 4)
               {
                  return true;
               }
               break;
            case SPY_TYPE_TWO:
               if(param1 >= 5 && param1 <= 6)
               {
                  return true;
               }
               break;
            case SPY_TYPE_THREE:
               if(param1 >= 7 && param1 <= 10)
               {
                  return true;
               }
               break;
            default:
               return false;
         }
         return false;
      }
      
      public function sendtransaction() : void
      {
         var _loc1_:Transaction = new TEspionageHQUnitStolen(this.m_stolenItem,this.m_spyDeployedCode);
         TransactionManager.addTransaction(_loc1_);
      }
      
      public function set spyDeploy(param1:String) : void
      {
         this.m_spyDeployedCode = param1;
         switch(param1)
         {
            case "SPY1":
               this.m_spyTypeDeployed = SPY_TYPE_ONE;
               this.m_spy_1_Equipped = false;
               break;
            case "SPY2":
               this.m_spyTypeDeployed = SPY_TYPE_TWO;
               this.m_spy_2_Equipped = false;
               break;
            case "SPY3":
               this.m_spyTypeDeployed = SPY_TYPE_THREE;
               this.m_spy_3_Equipped = false;
               break;
            default:
               this.m_spyTypeDeployed = SPY_TYPE_NONE;
         }
         this.sendtransaction();
      }
      
      public function set spyEquip(param1:String) : void
      {
         switch(param1)
         {
            case "SPY1":
               this.m_spy_1_Equipped = true;
               break;
            case "SPY2":
               this.m_spy_2_Equipped = true;
               break;
            case "SPY3":
               this.m_spy_3_Equipped = true;
         }
         this.sendtransaction();
      }
      
      public function set stolenUnit(param1:String) : void
      {
         if(this.m_stolenItem != null)
         {
            ZGlobal.player.removeInventoryItem(this.m_stolenItem);
         }
         this.m_stolenItem = param1;
         this.m_battlesFought = 0;
         this.m_unitUsedInBattle = false;
         this.m_unitSelectedInPreBattle = false;
         if(param1 != null)
         {
            this.m_spyDeploymentTime = GlobalEngine.serverTime / 1000 + ZGlobal.player.timeWarpSeconds;
         }
         else
         {
            this.m_spyDeploymentTime = 0;
            this.m_spyTypeDeployed = SPY_TYPE_NONE;
         }
         ZGlobal.player.addToInventory(this.m_stolenItem);
         this.sendtransaction();
      }
      
      public function set unitInBattle(param1:Boolean) : void
      {
         this.m_unitUsedInBattle = param1;
      }
      
      public function get isUnitInBattle() : Boolean
      {
         return this.m_unitUsedInBattle;
      }
      
      public function set unitInPreBattle(param1:Boolean) : void
      {
         this.m_unitSelectedInPreBattle = param1;
      }
      
      public function get isUnitInPreBattle() : Boolean
      {
         return this.m_unitSelectedInPreBattle;
      }
      
      public function removeStolenUnit() : void
      {
         if(this.m_stolenItem != null)
         {
            ZGlobal.player.removeInventoryItem(this.m_stolenItem);
         }
         this.m_stolenItem = null;
         this.m_battlesFought = 0;
         this.m_unitUsedInBattle = false;
         this.m_unitSelectedInPreBattle = false;
         this.spyDeploy = null;
         this.m_spyDeploymentTime = 0;
         this.sendtransaction();
      }
      
      public function get battlesFought() : int
      {
         return this.m_battlesFought;
      }
      
      public function get battlesRemaining() : int
      {
         return MAX_ALLOWED_BATTLES - this.m_battlesFought;
      }
      
      public function init(param1:GameDataComponent) : void
      {
         if(param1.userData.battlesFought != null)
         {
            this.m_battlesFought = int(param1.userData.battlesFought);
         }
         if(param1.userData.spyTypeDeployed != null)
         {
            this.m_spyTypeDeployed = int(param1.userData.spyTypeDeployed);
         }
         if(param1.userData.spyDeployedCode)
         {
            this.m_spyDeployedCode = param1.userData.spyDeployedCode;
         }
         if(param1.userData.isUnitDeployed != null)
         {
            this.m_unitUsedInBattle = Boolean(param1.userData.isUnitDeployed);
         }
         if(param1.userData.stolenItem)
         {
            this.m_stolenItem = param1.userData.stolenItem;
         }
         if(param1.userData.spyDeploymentTime != null)
         {
            this.m_spyDeploymentTime = int(param1.userData.spyDeploymentTime);
         }
         if(param1.userData.spy1 != null)
         {
            this.m_spy_1_Equipped = Boolean(param1.userData.spy1);
         }
         if(param1.userData.spy2 != null)
         {
            this.m_spy_2_Equipped = Boolean(param1.userData.spy2);
         }
         if(param1.userData.spy3 != null)
         {
            this.m_spy_3_Equipped = Boolean(param1.userData.spy3);
         }
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_COMPLETE_HOST,this.onBattleComplete);
         if(this.m_spyDeploymentTime != 0 && GlobalEngine.serverTime / 1000 - this.m_spyDeploymentTime + ZGlobal.player.timeWarpSeconds > MAX_ALLOWED_TIME)
         {
            if(this.stolenUnit != null)
            {
               this.removeStolenUnit();
            }
         }
         this.isInited = true;
      }
      
      public function onBattleComplete(param1:WorldEvent) : void
      {
         var _loc7_:Object = null;
         var _loc2_:Dictionary = param1.eventData.lostUnits;
         var _loc3_:Array = param1.eventData.remainingUnits as Array;
         var _loc4_:int = int(param1.eventData.result);
         var _loc5_:Boolean = false;
         var _loc6_:Boolean = false;
         if(Boolean(_loc2_ && _loc2_[this.m_stolenItem] >= 1) && Boolean(this.m_spyTypeDeployed != SPY_TYPE_NONE) && this.m_unitUsedInBattle)
         {
            this.m_stolenItem = null;
            this.m_battlesFought = 0;
            this.m_spyDeploymentTime = 0;
            this.spyDeploy = null;
            _loc5_ = true;
            this.m_unitUsedInBattle = false;
            this.m_spyTypeDeployed = SPY_TYPE_NONE;
         }
         for each(_loc7_ in _loc3_)
         {
            if(_loc7_.code == this.m_stolenItem)
            {
               _loc6_ = true;
               this.m_unitUsedInBattle = false;
               _loc5_ = true;
            }
         }
         this.m_unitSelectedInPreBattle = false;
         if(_loc6_)
         {
            ++this.m_battlesFought;
         }
         if(this.m_battlesFought >= MAX_ALLOWED_BATTLES)
         {
            this.removeStolenUnit();
         }
         if(this.m_spyDeploymentTime != 0 && GlobalEngine.serverTime / 1000 - this.m_spyDeploymentTime + ZGlobal.player.timeWarpSeconds > MAX_ALLOWED_TIME)
         {
            if(this.stolenUnit != null)
            {
               this.stolenUnit = null;
               this.spyDeploy = null;
               this.m_unitUsedInBattle = false;
               _loc5_ = true;
            }
         }
         if(_loc5_)
         {
            this.sendtransaction();
         }
      }
      
      public function shouldShowCard() : Boolean
      {
         return this.hasStolenUnit && !this.isUnitInBattle && !DominationModeManager.instance.isInDefenseForceEditMode() && !SurvivalModeManager.instance.isInSurvivalBattle();
      }
      
      public function get spyDeployed() : String
      {
         return this.m_spyDeployedCode;
      }
      
      public function isSpyEquipped(param1:String) : Boolean
      {
         switch(param1)
         {
            case "SPY1":
               return this.m_spy_1_Equipped;
            case "SPY2":
               return this.m_spy_2_Equipped;
            case "SPY3":
               return this.m_spy_3_Equipped;
            default:
               return false;
         }
      }
   }
}

