package displays.screens.pickUnitsScreen
{
   import core.ZGlobal;
   import core.gamemode.prebattle.PreBattleUI;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.InventoryList;
   import core.managers.domination.DominationModeManager;
   import core.player.Player;
   import displays.screens.gridScreen.GetCashSlot;
   import displays.screens.gridScreen.GridSlot;
   import displays.screens.mechBattleSetup.MechBattleSetup;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import utils.BitArray;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.resource.SWFResource;
   
   public class PremiumUnitsGrid extends UnitsGrid
   {
      
      public function PremiumUnitsGrid(param1:MovieClip, param2:SWFResource, param3:EventDispatcher, param4:String, param5:String, param6:Array, param7:int, param8:int = 0)
      {
         super(param1,param2,param3,param4,param5,param6,param7,null,param8);
      }
      
      override protected function init(param1:MovieClip, param2:SWFResource) : void
      {
         setDimensions(5,1);
         load(param1,param2);
      }
      
      override protected function createCard(param1:SWFResource, param2:MovieClip, param3:int, param4:int, param5:int = 0) : GridSlot
      {
         var _loc6_:UnitItem = m_units.shift();
         return new PremiumUnitSlot(param1,param2,screen,param3,param4,_loc6_,getMultFactor());
      }
      
      override protected function createSpecialCard(param1:SWFResource, param2:MovieClip, param3:int, param4:int) : GridSlot
      {
         return new GetCashSlot(param1,param2,screen,param3,param4,getMultFactor());
      }
      
      override protected function hasSpecialCard() : Boolean
      {
         return true;
      }
      
      override protected function fillOutHeader() : void
      {
         TextFieldUtil.processTextField(screen.header_tf,ZGameUtils.ZlocT("Dialogs","PickPremiumUnitsHeader"));
      }
      
      override protected function createItemList() : void
      {
         var _loc9_:String = null;
         var _loc10_:UnitItem = null;
         var _loc11_:BitArray = null;
         var _loc12_:Boolean = false;
         var _loc1_:Array = [];
         var _loc2_:Array = [];
         var _loc3_:Array = [];
         var _loc4_:int = ZGlobal.gameSettings.getInt("buyUnitsLevelCap",10);
         var _loc5_:Object = {
            "level":ZGlobal.player.level + _loc4_,
            "dominanceGatedUnitsRequireDomMode":true
         };
         var _loc6_:Boolean = DominationModeManager.instance.enabled;
         var _loc7_:Array = InventoryList.instance.itemsByEffectiveness;
         var _loc8_:* = int(_loc7_.length);
         while(_loc8_--)
         {
            _loc9_ = _loc7_[_loc8_];
            _loc10_ = ZGlobal.gameSettings.getItemByCode(_loc9_,UnitItem) as UnitItem;
            if(_loc10_.type == m_type && _loc10_.subType == m_subtype)
            {
               _loc11_ = ZGlobal.player.checkGate(_loc10_,_loc5_);
               _loc12_ = !_loc6_ && _loc11_.isBitSet(Player.GATE_FAILURE_DOMINANCE);
               if(!_loc12_ && !_loc11_.isBitSet(Player.GATE_FAILURE_QUEST) && !_loc11_.isBitSet(Player.GATE_FAILURE_LEVEL) && !_loc11_.isBitSet(Player.GATE_FAILURE_DATE) && !_loc11_.isBitSet(Player.GATE_FAILURE_EXPERIMENT))
               {
                  if(_loc10_.usesCash() && _loc10_.buyable)
                  {
                     if(_loc10_.xml.@setBonusItem != undefined && _loc10_.xml.@setBonusItem == "true")
                     {
                        if(_loc10_.contractLocked && !ZGlobal.player.hasPurchasedContract(_loc10_.code))
                        {
                           continue;
                        }
                     }
                     if(!(!MechBattleSetup.ENABLED && _loc10_.hasType(UnitItem.MEGA_UNIT)))
                     {
                        _loc11_ = ZGlobal.player.checkGate(_loc10_);
                        _loc11_.resetBit(Player.GATE_FAILURE_CONTRACT_LOCKED);
                        if(!_loc11_.anyBitSet())
                        {
                           if(!_loc10_.hasType("mastery"))
                           {
                              _loc1_.push(_loc10_);
                           }
                        }
                        else if(_loc11_.isBitSet(Player.GATE_FAILURE_DOMINANCE))
                        {
                           _loc3_.push(_loc10_);
                        }
                        else
                        {
                           _loc2_.splice(0,0,_loc10_);
                        }
                     }
                  }
               }
            }
         }
         _loc1_.sort(this.sortItems);
         _loc2_.sort(this.sortItems);
         _loc3_.sort(ZGameUtils.sortRequiredDominanceLevel,Array.DESCENDING);
         m_units = _loc1_.concat(_loc2_).concat(_loc3_);
      }
      
      protected function sortItems(param1:GameItem, param2:GameItem) : int
      {
         var _loc3_:int = 0;
         if(PreBattleUI.TITAN_MODE)
         {
            _loc3_ = ZGameUtils.sortTitanParts(param1,param2);
         }
         if(!_loc3_)
         {
            _loc3_ = ZGameUtils.sortLE(param1,param2);
            if(!_loc3_)
            {
               _loc3_ = ZGameUtils.sortStrongest(param1,param2);
            }
         }
         return _loc3_;
      }
   }
}

