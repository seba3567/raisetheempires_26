package core.managers
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.gamemode.GameModeManager;
   import core.gamemode.battle.GMBattle;
   import core.gameobjects.Fleet;
   import core.gameobjects.Unit;
   import core.gameobjects.UnitItem;
   import core.managers.domination.DominationModeManager;
   import core.resource.WorldResource;
   import displays.screens.RetreatDialog;
   import displays.screens.RetreatDialogDomination;
   import flash.utils.Dictionary;
   import transactions.TCalculateRansom;
   import utils.ZGameRandom;
   
   public class RetreatManager
   {
      
      public static var instance:RetreatManager = new RetreatManager();
      
      public function RetreatManager()
      {
         super();
      }
      
      private function calcExperimentPercent() : Number
      {
         var _loc1_:Number = 0.002;
         var _loc2_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_RANSOM_ALGORITHM);
         switch(_loc2_)
         {
            case 0:
            case 1:
               _loc1_ = 0.002;
               break;
            case 2:
               _loc1_ = 0.005;
               break;
            case 3:
               _loc1_ = 0.01;
               break;
            case 4:
               _loc1_ = 0.02;
         }
         return _loc1_;
      }
      
      public function resolveDominationRetreat() : void
      {
         var _loc1_:String = DominationModeManager.instance.getDominationEnemyUID();
         RetreatDialogDomination.display(_loc1_);
      }
      
      public function resolveRetreat() : void
      {
         var _loc2_:Fleet = null;
         var _loc3_:Fleet = null;
         var _loc4_:int = 0;
         var _loc5_:TCalculateRansom = null;
         var _loc1_:GMBattle = GameModeManager.instance.getTopGameMode() as GMBattle;
         if(_loc1_)
         {
            _loc2_ = Fleet.getFleet(_loc1_.battle.getPlayerFleetName());
            _loc3_ = Fleet.getFleet(_loc1_.battle.getEnemyFleetName());
            if(_loc2_.ransomAmount == 0)
            {
               this.calculateRansomBasis(_loc2_,_loc3_);
               _loc5_ = new TCalculateRansom(_loc2_.name,_loc3_.name);
               TransactionManager.addTransaction(_loc5_);
            }
            _loc4_ = this.calculateRansom(_loc2_,_loc3_);
            RetreatDialog.display(_loc2_.ransomResource,_loc4_);
         }
      }
      
      public function calculateRansomBasis(param1:Fleet, param2:Fleet) : void
      {
         var _loc7_:int = 0;
         var _loc3_:Number = ZGameRandom.ransomInstance.float();
         var _loc4_:Dictionary = ZGlobal.player.resources.resourceAmounts;
         var _loc5_:int = 0;
         if(_loc4_["coins"])
         {
            _loc5_ += _loc4_["coins"];
         }
         if(_loc4_["wood"])
         {
            _loc5_ += _loc4_["wood"] * 10;
         }
         if(_loc4_["oil"])
         {
            _loc5_ += _loc4_["oil"] * 10;
         }
         if(_loc4_["aluminum"])
         {
            _loc5_ += _loc4_["aluminum"] * 100;
         }
         if(_loc4_["copper"])
         {
            _loc5_ += _loc4_["copper"] * 100;
         }
         if(_loc4_["gold"])
         {
            _loc5_ += _loc4_["gold"] * 100;
         }
         if(_loc4_["iron"])
         {
            _loc5_ += _loc4_["iron"] * 100;
         }
         if(_loc4_["uranium"])
         {
            _loc5_ += _loc4_["uranium"] * 100;
         }
         var _loc6_:String = new String();
         if(_loc3_ <= 0.2)
         {
            _loc6_ = "coins";
         }
         else if(_loc3_ <= 0.5)
         {
            _loc6_ = "wood";
         }
         else if(_loc3_ <= 0.7)
         {
            _loc6_ = "oil";
         }
         else if(_loc3_ <= 0.9)
         {
            _loc6_ = ZGlobal.player.rareResourceName;
         }
         else
         {
            _loc7_ = int(ZGlobal.player.rareResourceType + 4 * _loc3_) % 5;
            _loc6_ = WorldResourceManager.instance.getResourceTypeFromIndex(_loc7_);
         }
         param1.ransomResource = _loc6_;
         param1.ransomAmount = _loc5_;
         param1.ransomRandom = _loc3_;
      }
      
      public function calculateRansom(param1:Fleet, param2:Fleet) : int
      {
         var _loc7_:Unit = null;
         var _loc8_:int = 0;
         var _loc9_:String = null;
         var _loc13_:UnitItem = null;
         var _loc14_:Array = null;
         var _loc15_:WorldResource = null;
         var _loc3_:Number = this.calcExperimentPercent();
         var _loc4_:Array = param1.units;
         var _loc5_:Dictionary = new Dictionary();
         var _loc6_:int = 0;
         for each(_loc7_ in _loc4_)
         {
            if(!_loc7_.dead)
            {
               _loc13_ = ZGlobal.gameSettings.getItemByCode(_loc7_.code,UnitItem) as UnitItem;
               _loc14_ = _loc13_.resourceCosts;
               for each(_loc15_ in _loc14_)
               {
                  if(_loc5_[_loc15_.type] != null)
                  {
                     _loc5_[_loc15_.type] += -_loc15_.amount;
                  }
                  else
                  {
                     _loc5_[_loc15_.type] = -_loc15_.amount;
                  }
               }
               _loc6_ += _loc13_.cash;
            }
         }
         _loc8_ = 0;
         for(_loc9_ in _loc5_)
         {
            if(_loc9_ == "coins")
            {
               _loc8_ += _loc5_[_loc9_];
            }
            else if(_loc9_ == "oil" || _loc9_ == "wood")
            {
               _loc8_ += _loc5_[_loc9_] * 10;
            }
            else
            {
               _loc8_ += _loc5_[_loc9_] * 100;
            }
         }
         if(_loc8_ == 0)
         {
            _loc8_ = _loc6_ * 100;
         }
         var _loc10_:int = _loc8_ * 0.2;
         var _loc11_:Number = int(param1.ransomAmount * (param2.numUnits * 0.2) * _loc3_);
         var _loc12_:Number = int((_loc10_ + _loc11_) * (param1.ransomRandom + 0.5));
         if(param1.ransomRandom <= 0.2)
         {
            _loc12_ = _loc12_;
         }
         else if(param1.ransomRandom <= 0.7)
         {
            _loc12_ /= 10;
         }
         else
         {
            _loc12_ /= 100;
         }
         if(Boolean(ZGlobal.player.combatSpecialBits & Fleet.HALF_RANSOM) && Boolean(ExperimentsManager.instance.getExperimentVariant("empire_combat_half_ransom") > 1) && ZRTManager.instance.isZRTOn(ZGlobal.player.COMBAT_HALF_RANSOM))
         {
            _loc12_ *= 0.5;
         }
         _loc12_ = int(_loc12_);
         if(_loc12_ < 1)
         {
            _loc12_ = 1;
         }
         return _loc12_;
      }
   }
}

