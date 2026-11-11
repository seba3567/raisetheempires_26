package core.worlds.battleWorld
{
   import core.ZGameStats;
   import core.ZGlobal;
   import core.gamemode.battle.Battle;
   import core.gamemode.battle.BattleCampaign;
   import core.gamemode.battle.BattleDispatcher;
   import core.gamemode.battle.BattleObject;
   import core.gameobjects.ConsumableItem;
   import core.gameobjects.UnitItem;
   import core.managers.PVPManager;
   import core.managers.WorldResourceManager;
   import core.managers.battleManager.BattleManager;
   import core.managers.rewardPickupManager.RewardPickup;
   import core.resource.ResourceInfo;
   import core.ui.Tooltip;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.popups.HealingSurfacingPopup;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import sound.SoundEvent;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class PlayerUnit extends BattleUnit
   {
      
      private static const SHOW_CONFIRM_POPUP:String = "showconfirmpopup";
      
      private var m_powerItem:ConsumableItem = null;
      
      private var m_activeFromConsumable:Boolean = false;
      
      public function PlayerUnit(param1:int, param2:BattleObject)
      {
         super(param1,param2);
      }
      
      override public function init(param1:Sprite, param2:BattleObject, param3:int, param4:int) : void
      {
         var _loc5_:ImageLoader = null;
         super.init(param1,param2,param3,param4);
         if(bar)
         {
            bar.power_bt.addEventListener(MouseEvent.CLICK,this.onPowerButtonClicked);
            this.m_powerItem = BattleManager.instance.powerItem;
            _loc5_ = ImageLoaderFactory.CreateImageLoader(this.m_powerItem.getCachedImage("bar").url,bar.powerButtonIcon);
            _loc5_.smooth = true;
            imageLoaders.push(_loc5_);
         }
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_WAITING_FOR_PLAYER_CLICK,this.onWaitForPlayerClick);
      }
      
      override public function dispose(param1:Sprite) : void
      {
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_WAITING_FOR_PLAYER_CLICK,this.onWaitForPlayerClick);
         if(bar)
         {
            bar.power_bt.removeEventListener(MouseEvent.CLICK,this.onPowerButtonClicked);
         }
         this.m_powerItem = null;
         super.dispose(param1);
      }
      
      override public function die(param1:BattleObject, param2:BattleObject, param3:Object) : void
      {
         super.die(param1,param2,param3);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_WAITING_FOR_PLAYER_CLICK,this.onWaitForPlayerClick);
      }
      
      override protected function onMouseClick(param1:MouseEvent) : void
      {
         if(this.selectable)
         {
            BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.PLAYER_UNIT_CLICKED,battleObject));
         }
         super.onMouseClick(param1);
      }
      
      override protected function onMouseOver(param1:MouseEvent) : void
      {
         if(this.selectable)
         {
            BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.PLAYER_UNIT_HIGHLIGHTED,battleObject));
            super.onMouseOver(param1);
         }
      }
      
      override protected function doMouseOut() : void
      {
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.PLAYER_UNIT_HIGHLIGHTED,null));
         super.doMouseOut();
      }
      
      private function get selectable() : Boolean
      {
         return this.m_activeFromConsumable || !battleObject.stunned;
      }
      
      private function onWaitForPlayerClick(param1:WorldEvent) : void
      {
         if(param1.eventData.active)
         {
            this.m_activeFromConsumable = param1.eventData.consumable;
            addMouseEvents();
            this.handlePowerButton();
         }
         else
         {
            this.m_activeFromConsumable = false;
            removeMouseEvents(true);
            this.disablePowerButton();
         }
      }
      
      override protected function get hoverColor() : int
      {
         return 10024954;
      }
      
      override protected function get colorIndex() : int
      {
         return m_selected ? PLAYER : HOVER;
      }
      
      override protected function dispatchHighlightedEvent() : void
      {
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_UI_SET_PLAYER_HIGHLIGHTED_UNIT,battleObject));
      }
      
      private function damagedEnoughToShowPowerButton() : Boolean
      {
         var _loc1_:Number = BattleManager.instance.powerButtonHealPercent;
         if(_loc1_ > 0 && battleObject.unit.strength > 0)
         {
            if(battleObject.unit.strength < battleObject.unitItem.getStrength(battleObject.fleet) * _loc1_)
            {
               return true;
            }
         }
         return false;
      }
      
      private function handlePowerButton() : void
      {
         var _loc1_:Boolean = false;
         if(bar)
         {
            _loc1_ = false;
            if(this.damagedEnoughToShowPowerButton())
            {
               if(!ZGlobal.player.checkGate(this.m_powerItem).anyBitSet())
               {
                  _loc1_ = true;
                  Tooltip.subscribe(bar.power_bt,ZGameUtils.ZlocT("Combat","Combat_PowerButtonTooltip",ZGameUtils.CashTokenReplacements(this.m_powerItem.cash)));
               }
            }
            if(_loc1_)
            {
               bar.power_bt.visible = true;
               bar.power_bt.mouseEnabled = true;
               bar.powerButtonIcon.visible = true;
            }
         }
      }
      
      override protected function disablePowerButton() : void
      {
         if(bar)
         {
            super.disablePowerButton();
            Tooltip.unsubscribe(bar.power_bt);
         }
      }
      
      private function onPowerButtonClicked(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:HealingSurfacingPopup = null;
         if(ZGlobal.player.canBuyCash(this.m_powerItem.cash))
         {
            if(!ZGlobal.player.getSeenFlag(SHOW_CONFIRM_POPUP))
            {
               ZGlobal.player.setSeenFlag(SHOW_CONFIRM_POPUP);
               if(BattleManager.instance.powerUseRequiresTurn)
               {
                  _loc2_ = ZGameUtils.ZlocT("Combat","Combat_PowerButtonConfirmTitle");
                  _loc3_ = ZGameUtils.ZlocT("Combat","Combat_PowerButtonConfirmMessage",ZGameUtils.CashTokenReplacements(this.m_powerItem.cash));
                  PopupManager.instance.push(GenericPopup2B.NewYesNo(_loc3_,_loc2_,this.buyPowerConfirmed));
               }
               else
               {
                  _loc4_ = new HealingSurfacingPopup(this.m_powerItem,this.buyPowerConfirmed);
                  PopupManager.instance.push(_loc4_);
               }
            }
            else
            {
               this.buyPower();
            }
         }
      }
      
      private function buyPowerConfirmed(param1:GenericPopupEvent = null) : void
      {
         if(!param1 || param1.button == GenericPopup.YES)
         {
            this.buyPower();
         }
      }
      
      private function buyPower() : void
      {
         var _loc11_:UnitItem = null;
         var _loc1_:Battle = ZGameStats.currentBattle;
         var _loc2_:String = "";
         var _loc3_:BattleObject = battleObject;
         if(_loc3_)
         {
            _loc11_ = _loc3_.unitItem;
            if(_loc11_)
            {
               _loc2_ = _loc11_.code;
            }
         }
         var _loc4_:int = Battle.BATTLE_STATE_ACTIVE;
         var _loc5_:Boolean = _loc1_ is BattleCampaign;
         var _loc6_:Boolean = _loc1_.isQuestTreeBattle;
         var _loc7_:Boolean = _loc1_.isDeathMatchBattle;
         var _loc8_:String = "";
         if(_loc6_ && _loc1_.getQuestId != "")
         {
            _loc8_ = _loc1_.getQuestId;
         }
         var _loc9_:Boolean = _loc1_.isQuestSurvival;
         var _loc10_:Object = {
            "combatPhase":_loc4_,
            "isQuestSurvival":_loc9_,
            "deathmatch":_loc7_,
            "inCampaign":_loc5_,
            "unitCode":_loc2_,
            "gpvp":PVPManager.instance.isVisitGlobalPVP(),
            "questTree":_loc6_,
            "questId":_loc8_
         };
         ZGlobal.player.buyGameItem(this.m_powerItem,true,1,_loc10_);
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_CONSUMABLE_SELECTED,{"consumableItem":this.m_powerItem}));
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.PLAYER_UNIT_CLICKED,_loc3_));
      }
      
      override protected function playDamageXPReward(param1:Object) : void
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         var _loc4_:Array = null;
         var _loc5_:uint = 0;
         var _loc6_:uint = 0;
         var _loc7_:ResourceInfo = null;
         if(param1.damage)
         {
            if(battleObject.unit.dead)
            {
               SoundEvent.getSoundEvent("CriticalHit").play();
               _loc2_ = {
                  "flags":RewardPickup.FLAG_RIGHT_ONLY,
                  "delay":250,
                  "x":x,
                  "y":y
               };
               _loc3_ = battleObject.unitItem.getStrength(battleObject.fleet);
               _loc4_ = battleObject.unitItem.resourceCosts;
               _loc5_ = _loc4_.length;
               _loc6_ = 0;
               while(_loc6_ < _loc5_)
               {
                  _loc7_ = WorldResourceManager.instance.getResourceInfoByType(_loc4_[_loc6_].type);
                  if(_loc7_.isRare)
                  {
                     _loc2_.rareType = _loc7_.type;
                     _loc2_.rareAmount = 1;
                     _loc2_.numRareLoot = 1;
                     break;
                  }
                  _loc6_++;
               }
               _loc2_.flags |= RewardPickup.FLAG_HIGH_BOUNCE;
               _loc2_.coinAmount = getCoinAmount(_loc3_,param1.damage);
               _loc2_.numCoinLoot = 1;
               _loc2_.oilAmount = getOilAmount(_loc3_,param1.damage);
               _loc2_.numOilLoot = 1;
               spawnLoot(_loc2_,false);
               super.playDamageXPReward(param1);
            }
         }
      }
   }
}

