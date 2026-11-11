package core.gamemode.battle
{
   import core.ZGlobal;
   import core.gamemode.prebattle.GMPreBattle;
   import core.gameobjects.ConsumableItem;
   import core.gameobjects.Fleet;
   import core.gameobjects.GameItem;
   import core.gameobjects.MercenaryItem;
   import core.gameobjects.questPower.QuestPower;
   import core.managers.AlliancesManager;
   import core.managers.ExperimentsManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.player.Friend;
   import core.player.IAlly;
   import core.player.PlayerAmmo;
   import core.ui.GenericButton;
   import core.ui.Tooltip;
   import core.ui.menuitem.CombatBarUIItem;
   import core.ui.menuitem.ContextualBarUIItem;
   import core.ui.menuitem.FriendsBarUIItem;
   import dispatchers.UIDispatcher;
   import displays.ImageLoaderFactory;
   import displays.popups.buyAmmo.BuyAmmoPopup;
   import displays.popups.buyEnergy.BuyEnergyPopup;
   import events.RepositionEvent;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.FullScreenEvent;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.Point;
   import utils.ZGameUtils;
   import zgame.assets.ui.CombatBar.FriendButton;
   import zlabs.ZGameBase;
   import zlabs.Zlab;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class BattleUI extends Sprite
   {
      
      private static const ALLY_BUTTON_X_ORIGIN:int = 3;
      
      private static const ALLY_BUTTON_Y_ORIGIN:int = -52;
      
      private static const ALLY_BUTTON_X_SPACING:int = 52;
      
      private static const ALLY_BUTTON_Y_SPACING:int = 0;
      
      private var m_ai:BattleAI = null;
      
      private var m_playerUnit:BattleObject = null;
      
      private var m_enemyUnit:BattleObject = null;
      
      private var m_clientOnly:Boolean = false;
      
      private var m_iconSprite:Sprite = null;
      
      private var m_playerFleet:String = null;
      
      private var m_friendButtons:Array = null;
      
      private var m_genericButtons:Array = null;
      
      private var m_allowAlly:Boolean = false;
      
      private var m_enemyType:String = null;
      
      private var m_playerType:String = null;
      
      private var m_iconPosition:Point = new Point(0,0);
      
      public function BattleUI(param1:BattleAI, param2:Boolean = false)
      {
         super();
         this.m_clientOnly = param2;
         this.m_ai = param1;
      }
      
      public function init(param1:String, param2:String) : void
      {
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_UI_PLAYER_OBJECT_CHOSEN,this.onPlayerObjectSelected);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_UI_ENEMY_OBJECT_CHOSEN,this.onEnemyObjectSelected);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.FLEET_CONSUMABLES_UPDATED,this.onFleetConsumablesUpdated);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_PLAYER_TURN,this.onPlayerTurnStarts);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_ENEMY_TURN,this.onEnemyTurnStarts);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_COMPLETE_HOST,this.onBattleComplete);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_CONSUMABLE_SELECTED,this.onConsumableSelected);
         TutorialManager.instance.addEventListener(TutorialManager.UI_STENCIL_COMBAT_ALLY,this.onStencilCombatAlly,false,0,true);
         Zlab.inputManager.addEventListener(FullScreenEvent.FULL_SCREEN,this.onFullscreenEvent,false,0,true);
         UIDispatcher.instance.addEventListener(RepositionEvent.REPOSITION_COMBAT_ALLY_OVERLAY,this.onCombatAllyOverlayReposition,false,0,true);
         this.m_playerFleet = param1;
         this.m_playerType = Fleet.getFleet(param1).type;
         this.m_enemyType = Fleet.getFleet(param2).type;
         this.addAllyConsumables();
         var _loc3_:CombatBarUIItem = ContextualBarUIItem(ContextualBarUIItem.getContextualBar()).getCombatBar();
         this.m_iconPosition.x = _loc3_.x;
         this.m_iconPosition.y = Zlab.mainStage.stageHeight - _loc3_.height;
         this.positionIcons();
      }
      
      public function dispose() : void
      {
         this.m_ai = null;
         this.m_playerUnit = null;
         this.m_enemyUnit = null;
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_UI_PLAYER_OBJECT_CHOSEN,this.onPlayerObjectSelected);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_UI_ENEMY_OBJECT_CHOSEN,this.onEnemyObjectSelected);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.FLEET_CONSUMABLES_UPDATED,this.onFleetConsumablesUpdated);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_PLAYER_TURN,this.onPlayerTurnStarts);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_ENEMY_TURN,this.onEnemyTurnStarts);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_COMPLETE_HOST,this.onBattleComplete);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_CONSUMABLE_SELECTED,this.onConsumableSelected);
         TutorialManager.instance.removeEventListener(TutorialManager.UI_STENCIL_COMBAT_ALLY,this.onStencilCombatAlly);
         Zlab.inputManager.removeEventListener(FullScreenEvent.FULL_SCREEN,this.onFullscreenEvent);
         UIDispatcher.instance.removeEventListener(RepositionEvent.REPOSITION_COMBAT_ALLY_OVERLAY,this.onCombatAllyOverlayReposition);
         this.disposeIcons();
      }
      
      public function set playerUnit(param1:BattleObject) : void
      {
         this.m_playerUnit = param1;
      }
      
      public function set enemyUnit(param1:BattleObject) : void
      {
         this.m_enemyUnit = param1;
      }
      
      public function repopulateUI() : void
      {
         this.addAllyConsumables();
      }
      
      private function disposeIcons() : void
      {
         var _loc1_:FriendButton = null;
         var _loc2_:GenericButton = null;
         if(null != this.m_friendButtons)
         {
            for each(_loc1_ in this.m_friendButtons)
            {
               _loc1_.icon_mc.unload();
            }
            this.m_friendButtons = null;
         }
         if(null != this.m_iconSprite)
         {
            if(this.m_iconSprite.parent)
            {
               ZGameBase.layerUI.removeChild(this.m_iconSprite);
            }
            this.m_iconSprite = null;
         }
         if(null != this.m_genericButtons)
         {
            for each(_loc2_ in this.m_genericButtons)
            {
               Tooltip.unsubscribe(_loc2_.m_overlay);
            }
            this.m_genericButtons = null;
         }
      }
      
      private function onPlayerObjectSelected(param1:WorldEvent) : void
      {
         var _loc2_:Object = new Object();
         var _loc3_:BattleObject = param1.eventData as BattleObject;
         if(null != _loc3_)
         {
            _loc2_.type = CombatBarUIItem.UPDATE_PLAYER_UNIT_STATS_DATA;
            _loc2_.playerUnitName = _loc3_.unitItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
            _loc2_.playerUnitType = _loc3_.unitItem.typeString;
            _loc2_.playerBattleObject = _loc3_;
            _loc2_.playerUnitCode = _loc3_.unit.code;
            _loc2_.playerUnitUpgrades = _loc3_.fleet.upgrades;
         }
         else
         {
            _loc2_.type = CombatBarUIItem.CLEAR_PLAYER_UNIT_STATS_DATA;
         }
         this.updateCombatBar(_loc2_);
      }
      
      private function onEnemyObjectSelected(param1:WorldEvent) : void
      {
         var _loc2_:Object = new Object();
         var _loc3_:BattleObject = param1.eventData as BattleObject;
         if(null != _loc3_)
         {
            _loc2_.type = CombatBarUIItem.UPDATE_ENEMY_UNIT_STATS_DATA;
            _loc2_.enemyUnitName = _loc3_.unitItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
            _loc2_.enemyUnitType = _loc3_.unitItem.typeString;
            _loc2_.enemyUnitCode = _loc3_.unit.code;
            _loc2_.enemyUnitUpgrades = _loc3_.fleet.upgrades;
         }
         else
         {
            _loc2_.type = CombatBarUIItem.CLEAR_ENEMY_UNIT_STATS_DATA;
         }
         this.updateCombatBar(_loc2_);
      }
      
      private function updateCombatBar(param1:Object) : void
      {
         if(this.m_clientOnly)
         {
            return;
         }
         ContextualBarUIItem.getContextualBar().dispatchEvent(new WorldEvent(ContextualBarUIItem.ADD_COMBAT_EVENT,param1));
      }
      
      private function addAllyConsumables() : void
      {
         var _loc2_:String = null;
         var _loc3_:IAlly = null;
         var _loc4_:Boolean = false;
         var _loc5_:Boolean = false;
         var _loc6_:Object = null;
         var _loc7_:String = null;
         var _loc8_:Array = null;
         var _loc9_:XML = null;
         var _loc10_:MercenaryItem = null;
         var _loc11_:FriendButton = null;
         var _loc12_:GenericButton = null;
         this.disposeIcons();
         this.m_iconSprite = new Sprite();
         this.positionIcons();
         this.m_genericButtons = new Array();
         this.m_friendButtons = new Array();
         var _loc1_:Fleet = Fleet.getFleet(this.m_playerFleet);
         for each(_loc2_ in _loc1_.orderedAllies)
         {
            if(_loc1_.allies[_loc2_] == 0)
            {
               _loc3_ = FriendsBarUIItem(FriendsBarUIItem.getFriendsBar()).findNeighborById(_loc2_);
               if(_loc3_ == null)
               {
                  if(AlliancesManager.isPhase4Enabled() && Boolean(AlliancesManager.instance.isAllianceMember(_loc2_)))
                  {
                     _loc6_ = AlliancesManager.instance.memberInfo(_loc2_);
                     if(_loc6_)
                     {
                        if(_loc6_.image == null || _loc6_.image == "")
                        {
                           _loc6_.image = ZGlobal.getAssetURL(ZGameUtils.NoProfileImageUrl);
                        }
                        _loc3_ = new Friend(_loc6_.uid,_loc6_.coins,_loc6_.xp,_loc6_.level,_loc6_.socialXpGood,_loc6_.socialLevelGood,_loc6_.socialXpBad,_loc6_.socialLevelBad,_loc6_.resource,_loc6_.image,_loc6_.name,0);
                     }
                  }
               }
               _loc4_ = false;
               _loc5_ = false;
               if(_loc3_ == null)
               {
                  _loc7_ = QuestPower.getCodeFromId(_loc2_);
                  if(_loc7_)
                  {
                     if(GMPreBattle.ACTIVE && !GMPreBattle.IN_DISABLE_STATE)
                     {
                        return;
                     }
                     _loc5_ = true;
                     _loc3_ = new QuestPower(_loc7_);
                  }
               }
               if(_loc3_ == null)
               {
                  _loc8_ = ZGlobal.gameSettings.getArrayOfItemXMLByType(GameItem.TYPE_MERCENARY);
                  for each(_loc9_ in _loc8_)
                  {
                     _loc10_ = ZGlobal.gameSettings.getItemByCode(_loc9_.@code,MercenaryItem) as MercenaryItem;
                     if(_loc10_.id == _loc2_)
                     {
                        _loc3_ = _loc10_;
                        _loc4_ = true;
                        break;
                     }
                  }
               }
               if(null != _loc3_)
               {
                  _loc11_ = new FriendButton();
                  _loc11_.x = ALLY_BUTTON_X_ORIGIN + ALLY_BUTTON_X_SPACING * this.m_friendButtons.length + 100;
                  _loc11_.y = ALLY_BUTTON_Y_ORIGIN + ALLY_BUTTON_Y_SPACING * this.m_friendButtons.length;
                  _loc11_.ally = _loc2_;
                  _loc11_.btnanim_mc.visible = false;
                  ImageLoaderFactory.CreateImageLoader(_loc3_.imageUrl,_loc11_.icon_mc);
                  this.m_iconSprite.addChild(_loc11_);
                  this.m_friendButtons.push(_loc11_);
                  _loc12_ = null;
                  if(_loc4_)
                  {
                     _loc12_ = new GenericButton(_loc11_,this.onMercClicked);
                     Tooltip.subscribe(_loc12_.m_overlay,ZGameUtils.ZlocT("Combat","MercTooltip",{
                        "ally":ZLoc.tn(_loc3_.firstName,_loc3_.gender == "F" ? ZGlobal.localizer.FEM : ZGlobal.localizer.MASC),
                        "level":_loc3_.level
                     }));
                  }
                  else if(_loc5_)
                  {
                     _loc12_ = new GenericButton(_loc11_,this.onQuestPowerClicked);
                     Tooltip.subscribe(_loc12_.m_overlay,ZGameUtils.ZlocT("QuestTrees","QT08_UsePowerUpBody"));
                  }
                  else
                  {
                     _loc12_ = new GenericButton(_loc11_,this.onPlayerClicked);
                     Tooltip.subscribe(_loc12_.m_overlay,ZGameUtils.ZlocT("Combat","AllyTooltip",{
                        "ally":ZLoc.tn(_loc3_.firstName,_loc3_.gender == "F" ? ZGlobal.localizer.FEM : ZGlobal.localizer.MASC),
                        "level":_loc3_.level
                     }));
                  }
                  _loc12_.name = _loc2_;
                  this.m_genericButtons.push(_loc12_);
               }
            }
         }
         ZGameBase.layerUI.addChild(this.m_iconSprite);
      }
      
      private function onCombatAllyOverlayReposition(param1:RepositionEvent) : void
      {
         this.m_iconPosition.x = param1.x;
         this.m_iconPosition.y = param1.y - param1.height;
         this.positionIcons();
      }
      
      private function onFullscreenEvent(param1:FullScreenEvent) : void
      {
         this.positionIcons();
      }
      
      private function positionIcons() : void
      {
         this.m_iconSprite.x = this.m_iconPosition.x;
         this.m_iconSprite.y = this.m_iconPosition.y;
      }
      
      private function allyAllowed(param1:String) : Boolean
      {
         var _loc3_:Boolean = false;
         if(!this.m_allowAlly)
         {
            return false;
         }
         if(TutorialManager.instance.isLocked(param1))
         {
            return false;
         }
         if(!BattleDispatcher.instance.hasEventListener(BattleDispatcher.BATTLE_MERC_CONSUMABLE_USED))
         {
            return false;
         }
         var _loc2_:int = ExperimentsManager.instance.getExperimentVariant("empire_consumable_energy");
         if(_loc2_ > 2)
         {
            _loc3_ = ZGlobal.player.m_energy.checkEnergy(1);
            if(PlayerAmmo.variantAmmoMasterOn())
            {
               _loc3_ = ZGlobal.player.m_ammo.checkAmmo(1);
            }
            if(!_loc3_)
            {
               if(PlayerAmmo.variantAmmoMasterOn())
               {
                  PopupManager.instance.push(new BuyAmmoPopup());
               }
               else
               {
                  BuyEnergyPopup.enableWatchToEarn();
                  BuyEnergyPopup.show();
               }
               return false;
            }
         }
         return true;
      }
      
      private function onPlayerClicked(param1:MouseEvent) : void
      {
         this.genericConsumableClicked(param1,BattleDispatcher.BATTLE_ALLY_CONSUMABLE_USED);
      }
      
      private function onMercClicked(param1:MouseEvent) : void
      {
         this.genericConsumableClicked(param1,BattleDispatcher.BATTLE_MERC_CONSUMABLE_USED);
      }
      
      private function onQuestPowerClicked(param1:MouseEvent) : void
      {
         this.genericConsumableClicked(param1,BattleDispatcher.BATTLE_QUEST_POWER_CONSUMABLE_USED);
      }
      
      private function genericConsumableClicked(param1:MouseEvent, param2:String) : void
      {
         if(this.allyAllowed(param1.target.buttonPointer.name))
         {
            BattleDispatcher.instance.dispatchEvent(new WorldEvent(param2,param1.target.buttonPointer.name));
            this.addAllyConsumables();
            this.onEnemyTurnStarts();
         }
      }
      
      private function onConsumableClicked(param1:MouseEvent) : void
      {
         var _loc2_:ConsumableItem = ZGlobal.gameSettings.getItemByCode(param1.target.buttonPointer.name,ConsumableItem) as ConsumableItem;
         if(_loc2_ != null)
         {
            BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_CONSUMABLE_SELECTED,{"consumableItem":_loc2_}));
         }
      }
      
      private function onFleetConsumablesUpdated(param1:WorldEvent) : void
      {
         this.addAllyConsumables();
      }
      
      private function onBattleComplete(param1:WorldEvent) : void
      {
         this.m_allowAlly = false;
      }
      
      private function onConsumableSelected(param1:WorldEvent) : void
      {
         if(param1.eventData)
         {
            this.onEnemyTurnStarts();
         }
         else
         {
            this.onPlayerTurnStarts();
         }
      }
      
      private function findFriendButton(param1:String) : FriendButton
      {
         var _loc2_:FriendButton = null;
         for each(_loc2_ in this.m_friendButtons)
         {
            if(_loc2_.ally == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      private function onStencilCombatAlly(param1:WorldEvent) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Point = null;
         var _loc2_:FriendButton = this.findFriendButton(param1.eventData as String);
         if(_loc2_)
         {
            _loc3_ = 25;
            _loc4_ = 27;
            _loc5_ = new Point(_loc3_,_loc4_);
            TutorialManager.instance.addStencilToUIElement(_loc2_.friend_bt,_loc5_,1.5);
            TutorialManager.instance.addArrowToUIElement(_loc2_.friend_bt);
         }
      }
      
      private function onPlayerTurnStarts(param1:Event = null) : void
      {
         var _loc2_:FriendButton = null;
         this.m_allowAlly = true;
         for each(_loc2_ in this.m_friendButtons)
         {
            _loc2_.filters = [];
         }
      }
      
      private function onEnemyTurnStarts(param1:Event = null) : void
      {
         var _loc2_:FriendButton = null;
         this.m_allowAlly = false;
         for each(_loc2_ in this.m_friendButtons)
         {
            _loc2_.filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
         }
      }
   }
}

