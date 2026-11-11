package core.worlds.battleWorld
{
   import core.ZGlobal;
   import core.gamemode.battle.BattleDispatcher;
   import core.gamemode.battle.BattleObject;
   import core.gamemode.prebattle.GMPreBattle;
   import core.gameobjects.Fleet;
   import core.managers.ChallengeModeManager;
   import core.managers.domination.DominationModeManager;
   import core.managers.leaderboardManager.LeaderboardManager;
   import core.managers.survivalModeManager.SurvivalModeManager;
   import core.ui.UIManager;
   import core.ui.menuitem.MenuItem;
   import core.ui.menuitem.OptionUIItem;
   import core.ui.menuitem.QuestsUIItem;
   import core.views.ViewManager;
   import dispatchers.UIDispatcher;
   import events.RepositionEvent;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.FullScreenEvent;
   import flash.geom.Point;
   import rendering.rendering2d.FullScreenBorders;
   import rendering.rendering2d.FullScreenHorizontalBorders;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.entity.EntityComponent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class BattleRendererComponent extends EntityComponent
   {
      
      public static const WIDTH:int = 760;
      
      public static const HEIGHT:int = 640;
      
      private var m_resource:SWFResource = null;
      
      private var m_displayObject:Sprite = null;
      
      private var m_hiddenUIItems:Array = null;
      
      private var m_sides:Array = null;
      
      private var m_text:BattleText = null;
      
      private var m_splitScreen:MovieClip = null;
      
      private var m_maskA:MovieClip = null;
      
      private var m_maskB:MovieClip = null;
      
      private var m_consumableWipe:BattleConsumableWipe = null;
      
      private var m_borders_ver:FullScreenBorders = null;
      
      private var m_borders_hor:FullScreenHorizontalBorders = null;
      
      private var m_dynamicBattleBackgroundUrl:String;
      
      private var m_isABackgroundLoadingOrLoaded:Boolean;
      
      private var m_uIOffset:Point = new Point(0,0);
      
      public function BattleRendererComponent()
      {
         super();
         this.m_isABackgroundLoadingOrLoaded = false;
      }
      
      public function get displayObject() : DisplayObject
      {
         return this.m_displayObject as DisplayObject;
      }
      
      public function getBattleUnit(param1:BattleObject) : BattleUnit
      {
         var _loc2_:BattleSide = null;
         var _loc3_:BattleUnit = null;
         for each(_loc2_ in this.m_sides)
         {
            _loc3_ = _loc2_.getBattleUnit(param1);
            if(null != _loc3_)
            {
               return _loc3_;
            }
         }
         return null;
      }
      
      public function getSidePosition(param1:int) : Point
      {
         var _loc2_:Array = [new Point(225,410),new Point(540,220)];
         return _loc2_[param1];
      }
      
      public function getEnemySide() : BattleSide
      {
         return this.m_sides[BattleSide.ENEMY];
      }
      
      public function getSurface(param1:int) : Sprite
      {
         return this.m_sides[param1].middleEarth;
      }
      
      public function getBackground(param1:int) : Sprite
      {
         return this.m_sides[param1].background;
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         this.m_displayObject = new Sprite();
         owner.eventDispatcher.addEventListener(ViewManager.ACTIVATE,this.onActivated);
         owner.eventDispatcher.addEventListener(ViewManager.DEACTIVATE,this.onDeactivated);
         owner.eventDispatcher.addEventListener(BattleWorld.REGISTER_FLEETS,this.onRegisterFleets);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_BACKGROUND_CHANGE,this.onBackgroundChange);
         Zlab.mainStage.addEventListener(FullScreenEvent.FULL_SCREEN,this.onFullScreen);
         Zlab.mainStage.addEventListener(Event.RESIZE,this.onReposition);
         this.reposition(false);
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         owner.eventDispatcher.removeEventListener(ViewManager.ACTIVATE,this.onActivated);
         owner.eventDispatcher.removeEventListener(ViewManager.DEACTIVATE,this.onDeactivated);
         owner.eventDispatcher.removeEventListener(BattleWorld.REGISTER_FLEETS,this.onRegisterFleets);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_BACKGROUND_CHANGE,this.onBackgroundChange);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_START,this.onCreateBattleUIClasses);
         Zlab.mainStage.removeEventListener(FullScreenEvent.FULL_SCREEN,this.onFullScreen);
         Zlab.mainStage.removeEventListener(Event.RESIZE,this.onReposition);
      }
      
      private function isActive() : Boolean
      {
         return null != this.m_resource;
      }
      
      private function onFullScreen(param1:FullScreenEvent) : void
      {
         this.reposition(param1.fullScreen);
      }
      
      private function onReposition(param1:Event) : void
      {
         this.reposition(false);
      }
      
      private function reposition(param1:Boolean) : void
      {
         var _loc2_:Number = 1;
         var _loc3_:Number = -(Zlab.mainStage.stageWidth - (this.m_displayObject.x + WIDTH * _loc2_));
         if(Zlab.mainStage.stageWidth - 200 > Zlab.mainStage.stageHeight)
         {
            _loc2_ = Math.max(1,Zlab.mainStage.stageHeight / HEIGHT);
            this.m_displayObject.scaleX = this.m_displayObject.scaleY = _loc2_;
            this.m_displayObject.x = Zlab.mainStage.stageWidth / 2;
            this.m_displayObject.x -= WIDTH * _loc2_ / 2;
            this.m_displayObject.y = 0;
            if(null != this.m_borders_ver)
            {
               this.m_borders_hor.removeBorders();
               this.m_borders_ver.addBorders();
            }
            _loc3_ = -(Zlab.mainStage.stageWidth - (this.m_displayObject.x + WIDTH * _loc2_));
            this.m_uIOffset.x = _loc3_ <= 0 ? _loc3_ : 0;
            this.m_uIOffset.y = 0;
         }
         else
         {
            _loc2_ = Math.max(1,Zlab.mainStage.stageWidth / WIDTH);
            this.m_displayObject.scaleX = this.m_displayObject.scaleY = _loc2_;
            this.m_displayObject.y = Zlab.mainStage.stageHeight / 2;
            this.m_displayObject.y -= HEIGHT * _loc2_ / 2;
            this.m_displayObject.x = 0;
            if(null != this.m_borders_hor)
            {
               this.m_borders_ver.removeBorders();
               this.m_borders_hor.addBorders();
            }
            _loc3_ = -(Zlab.mainStage.stageWidth - (this.m_displayObject.x + WIDTH * _loc2_));
            this.m_uIOffset.x = _loc3_ <= 0 ? _loc3_ : 0;
            this.m_uIOffset.y = -(Zlab.mainStage.stageHeight - (this.m_displayObject.y + HEIGHT * _loc2_));
         }
         this.updateUIOffset(false);
      }
      
      private function onActivated(param1:Event) : void
      {
         this.m_sides = new Array(2);
         var _loc2_:BattleSide = null;
         _loc2_ = new PlayerSide(owner);
         _loc2_.init(this.m_displayObject);
         this.m_sides[BattleSide.PLAYER] = _loc2_;
         _loc2_ = new EnemySide(owner);
         _loc2_.init(this.m_displayObject);
         this.m_sides[BattleSide.ENEMY] = _loc2_;
         Zlab.resourceManager.load(ZGlobal.getAssetURL("assets/game/combat/CombatUI.swf"),SWFResource,this.onCombatUILoadComplete,this.onSWFLoadFailed);
         this.m_hiddenUIItems = new Array();
         this.m_hiddenUIItems.push(UIManager.instance.getMenuItemByName(QuestsUIItem.ITEM_ID));
         this.m_hiddenUIItems.push(UIManager.instance.getMenuItemByName(OptionUIItem.ITEM_ID));
         this.updateUIOffset(false);
         this.hideUI(true);
      }
      
      private function updateUIOffset(param1:Boolean) : void
      {
         if(param1)
         {
            UIDispatcher.instance.dispatchEvent(new RepositionEvent(UIDispatcher.UI_WIDTH_OFFSET,0,0));
            LeaderboardManager.instance.dispatchEvent(new WorldEvent(LeaderboardManager.LEADERBOARD_UPDATE_POSITION,-1));
         }
         else if(null != this.m_borders_ver)
         {
            UIDispatcher.instance.dispatchEvent(new RepositionEvent(UIDispatcher.UI_WIDTH_OFFSET,this.m_uIOffset.x,this.m_uIOffset.y));
            LeaderboardManager.instance.dispatchEvent(new WorldEvent(LeaderboardManager.LEADERBOARD_UPDATE_POSITION,this.m_displayObject.x));
         }
      }
      
      private function onBackgroundChange(param1:WorldEvent) : void
      {
         if(param1.eventData.battleBackgroundUrl)
         {
            this.m_dynamicBattleBackgroundUrl = param1.eventData.battleBackgroundUrl;
         }
         if(Boolean(this.m_dynamicBattleBackgroundUrl) && this.m_isABackgroundLoadingOrLoaded)
         {
            Zlab.resourceManager.load(ZGlobal.getAssetURL(this.m_dynamicBattleBackgroundUrl),SWFResource,this.onBackgroundLoadComplete,this.onSWFLoadFailed);
         }
      }
      
      private function onRegisterFleets(param1:WorldEvent) : void
      {
         var _loc2_:String = param1.eventData.player;
         var _loc3_:String = param1.eventData.enemy;
         var _loc4_:Fleet = Fleet.getFleet(_loc2_);
         var _loc5_:Fleet = Fleet.getFleet(_loc3_);
         var _loc6_:Boolean = _loc4_.units.length == 0;
         this.m_sides[BattleSide.PLAYER].setFleet(_loc4_,0,_loc6_);
         this.m_sides[BattleSide.ENEMY].setFleet(_loc5_,1,_loc6_);
         if(ChallengeModeManager.instance.isInChallengeBattle() && ChallengeModeManager.instance.currentChallengeHasStatus(ChallengeModeManager.CHALLENGE_FLAG_GLOBAL_PVP))
         {
            Zlab.resourceManager.load(ZGlobal.getAssetURL("assets/game/combat/CombatBackgroundJungleWar.swf"),SWFResource,this.onBackgroundLoadComplete,this.onSWFLoadFailed);
         }
         else if(DominationModeManager.instance.isInDominationBattle())
         {
            Zlab.resourceManager.load(ZGlobal.getAssetURL(this.dominationBackgroundAssetName),SWFResource,this.onBackgroundLoadComplete,this.onSWFLoadFailed);
         }
         else if(SurvivalModeManager.instance.isInSurvivalBattle())
         {
            Zlab.resourceManager.load(ZGlobal.getAssetURL(this.survivalBackgroundAssetName),SWFResource,this.onBackgroundLoadComplete,this.onSWFLoadFailed);
         }
         else if(this.m_dynamicBattleBackgroundUrl)
         {
            Zlab.resourceManager.load(ZGlobal.getAssetURL(this.m_dynamicBattleBackgroundUrl),SWFResource,this.onBackgroundLoadComplete,this.onSWFLoadFailed);
         }
         else
         {
            Zlab.resourceManager.load(ZGlobal.getAssetURL(this.backgroundAssetName),SWFResource,this.onBackgroundLoadComplete,this.onSWFLoadFailed);
         }
         this.m_isABackgroundLoadingOrLoaded = true;
      }
      
      private function get dominationBackgroundAssetName() : String
      {
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc1_:String = DominationModeManager.instance.getDominationEnemyUID();
         var _loc2_:int = 0;
         var _loc3_:int = _loc1_.length;
         if(_loc3_)
         {
            _loc2_ = int(_loc1_.substr(_loc3_ - 1));
         }
         var _loc4_:Object = DominationModeManager.instance.getDominationInfo(_loc1_);
         if((Boolean(_loc4_)) && _loc4_.int >= 2)
         {
            _loc6_ = _loc4_.int / 2;
            _loc2_ += _loc6_;
         }
         _loc2_ %= 4;
         switch(_loc2_)
         {
            case 0:
               _loc5_ = "assets/game/combat/CombatBackgroundDefault.swf";
               break;
            case 1:
               _loc5_ = "assets/game/combat/CombatBackgroundJungleWar.swf";
               break;
            case 2:
               _loc5_ = "assets/game/combat/CombatBackgroundSnow.swf";
               break;
            default:
            case 3:
               _loc5_ = "assets/game/combat/CombatBackgroundLava.swf";
         }
         return _loc5_;
      }
      
      private function get survivalBackgroundAssetName() : String
      {
         var _loc1_:int = SurvivalModeManager.instance.getCurrentRound() % 4;
         var _loc2_:String = "assets/game/combat/CombatBackgroundDefault.swf";
         switch(_loc1_)
         {
            case 1:
               _loc2_ = "assets/game/combat/CombatBackgroundJungleWar.swf";
               break;
            case 2:
               _loc2_ = "assets/game/combat/CombatBackgroundLava.swf";
               break;
            case 3:
               _loc2_ = "assets/game/combat/CombatBackgroundSnow.swf";
         }
         return _loc2_;
      }
      
      private function get backgroundAssetName() : String
      {
         var _loc2_:String = null;
         var _loc1_:String = "assets/game/combat/CombatBackgroundDefault.swf";
         if(Boolean(ZGlobal.player.campaign.currentMap) && Boolean(ZGlobal.player.campaign.currentMap.currentIslandItem))
         {
            _loc2_ = ZGlobal.player.campaign.currentMap.currentIslandItem.xml.@background.toString();
            if(_loc2_.length)
            {
               switch(_loc2_)
               {
                  case "lava":
                     _loc1_ = "assets/game/combat/CombatBackgroundLava.swf";
                     break;
                  case "moon":
                     _loc1_ = "assets/game/combat/CombatBackgroundMoon.swf";
                     break;
                  default:
                     _loc1_ = "assets/game/combat/CombatBackgroundDefault.swf";
               }
            }
         }
         return _loc1_;
      }
      
      private function onDeactivated(param1:WorldEvent) : void
      {
         var _loc2_:BattleSide = null;
         this.hideUI(false);
         this.m_dynamicBattleBackgroundUrl = null;
         this.m_isABackgroundLoadingOrLoaded = false;
         if(null != this.m_resource)
         {
            for each(_loc2_ in this.m_sides)
            {
               _loc2_.mask = null;
               _loc2_.dispose(this.m_displayObject);
            }
            this.m_displayObject.removeChild(this.m_splitScreen);
            this.m_splitScreen = null;
            this.m_displayObject.removeChild(this.m_maskA);
            this.m_maskA = null;
            this.m_displayObject.removeChild(this.m_maskB);
            this.m_maskB = null;
            this.m_consumableWipe.dispose();
            this.m_consumableWipe = null;
            this.m_text.dispose();
            this.m_text = null;
            this.m_borders_ver.dispose();
            this.m_borders_ver = null;
            this.m_borders_hor.dispose();
            this.m_borders_hor = null;
            this.m_hiddenUIItems = null;
            this.m_resource = null;
         }
         this.updateUIOffset(true);
         this.m_sides = null;
      }
      
      private function onSWFLoadFailed(param1:SWFResource) : void
      {
         Logger.error(this,"onSWFLoadFailed","unable to load " + param1.filename);
      }
      
      private function onBackgroundLoadComplete(param1:SWFResource) : void
      {
         if(this.m_sides)
         {
            this.m_sides[BattleSide.PLAYER].loadBackgrounds(param1,0);
            this.m_sides[BattleSide.ENEMY].loadBackgrounds(param1,1);
         }
      }
      
      private function onCombatUILoadComplete(param1:SWFResource) : void
      {
         if(null == this.m_sides)
         {
            return;
         }
         this.m_resource = param1;
         var _loc2_:Class = param1.getAssetClass("SplitScreenLine");
         this.m_splitScreen = new _loc2_();
         this.m_displayObject.addChild(this.m_splitScreen);
         var _loc3_:Class = param1.getAssetClass("CombatMaskA");
         this.m_maskA = new _loc3_();
         this.m_displayObject.addChild(this.m_maskA);
         this.m_sides[BattleSide.PLAYER].mask = this.m_maskA;
         _loc3_ = param1.getAssetClass("CombatMaskB");
         this.m_maskB = new _loc3_();
         this.m_displayObject.addChild(this.m_maskB);
         this.m_sides[BattleSide.ENEMY].mask = this.m_maskB;
         this.m_text = new BattleText(this.m_displayObject,param1);
         this.m_consumableWipe = new BattleConsumableWipe(this.m_displayObject,param1);
         this.m_borders_ver = new FullScreenBorders(this.m_displayObject,WIDTH);
         this.m_borders_hor = new FullScreenHorizontalBorders(this.m_displayObject,HEIGHT);
         this.reposition(WindowManager.isFullScreen());
         var _loc4_:Class = this.m_resource.getAssetClass("HitPercentageText");
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_UI_HIT_PERCENT_CLASS,_loc4_));
         if(GMPreBattle.ACTIVE)
         {
            BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_START,this.onCreateBattleUIClasses);
         }
         else
         {
            this.onCreateBattleUIClasses(null);
            BattleDispatcher.instance.dispatchEvent(new Event(BattleDispatcher.BATTLE_START));
         }
      }
      
      private function onCreateBattleUIClasses(param1:Event) : void
      {
         var _loc2_:Class = this.m_resource.getAssetClass("DamageIndicator");
         var _loc3_:Class = this.m_resource.getAssetClass("commandoDamage");
         var _loc4_:Class = this.m_resource.getAssetClass("flameDamage");
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_UI_DAMAGE_CLASS,_loc2_));
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_UI_COMMANDO_BONUS_CLASS,_loc3_));
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_UI_FLAMING_DAMAGE_CLASS,_loc4_));
      }
      
      private function hideUI(param1:Boolean) : void
      {
         var _loc2_:MenuItem = null;
         for each(_loc2_ in this.m_hiddenUIItems)
         {
            if(_loc2_ != null)
            {
               _loc2_.visible = param1 == false;
            }
         }
      }
   }
}

