package core.gamemode.prebattle
{
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.formationManager.FormationManager;
   import core.managers.unitClassManager.UnitClass;
   import core.managers.unitClassManager.UnitClassManager;
   import core.worlds.battleWorld.BattleSide;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.screens.researchScreens.UpgradesDisplay;
   import fl.containers.UILoader;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class PreBattleEnemyTooltipCard implements IPreBattleEnemyCard
   {
      
      private static const TOOLTIP_TWEEN_TIME:Number = 0.3;
      
      private var m_unitItem:UnitItem = null;
      
      private var m_movieClip:MovieClip = null;
      
      private var m_tooltip:MovieClip = null;
      
      private var m_theater:String = null;
      
      private var m_iconLoaders:Array = new Array();
      
      private var m_unitUpgrades:Array = new Array();
      
      private var m_upgradesDisplay:UpgradesDisplay = null;
      
      public function PreBattleEnemyTooltipCard(param1:UnitItem, param2:Class, param3:int, param4:int, param5:String, param6:Array)
      {
         super();
         this.m_unitItem = param1;
         this.m_theater = param5;
         this.m_unitUpgrades = param6;
         var _loc7_:Point = FormationManager.instance.getLocalOffset(BattleSide.ENEMY.toString() + "_" + param3.toString(),param4,1);
         this.m_movieClip = new param2();
         this.m_movieClip.x = _loc7_.x;
         this.m_movieClip.y = _loc7_.y;
         this.m_movieClip.hit_mc.addEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
         this.m_movieClip.hit_mc.addEventListener(MouseEvent.ROLL_OUT,this.onMouseExit);
         this.configureCard(this.m_movieClip.window_lt);
         this.m_tooltip = this.m_movieClip.window_lt;
         this.m_tooltip.alpha = 0;
         this.m_movieClip.window_rt.visible = false;
      }
      
      public function dispose() : void
      {
         var _loc1_:ImageLoader = null;
         TweenLite.killTweensOf(this.m_tooltip);
         this.m_movieClip.hit_mc.removeEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
         this.m_movieClip.hit_mc.removeEventListener(MouseEvent.ROLL_OUT,this.onMouseExit);
         if(this.m_upgradesDisplay)
         {
            this.m_upgradesDisplay.dispose();
         }
         for each(_loc1_ in this.m_iconLoaders)
         {
            if(_loc1_)
            {
               _loc1_.destroy();
            }
         }
         this.m_iconLoaders = null;
         this.m_unitItem = null;
         this.m_tooltip = null;
         this.m_movieClip = null;
      }
      
      public function get art() : MovieClip
      {
         return this.m_movieClip;
      }
      
      public function set visible(param1:Boolean) : void
      {
         this.m_movieClip.visible = param1;
      }
      
      protected function get unit() : UnitItem
      {
         return this.m_unitItem;
      }
      
      protected function get iconLoaders() : Array
      {
         return this.m_iconLoaders;
      }
      
      protected function configureCard(param1:MovieClip) : void
      {
         param1.visible = false;
         param1.mouseEnabled = false;
         param1.mouseChildren = false;
         TextFieldUtil.processTextField(param1.text_mc.weakInfo_tf,ZGameUtils.ZlocT("Dialogs","EnemyTooltipGoodAgainst"));
         TextFieldUtil.processTextField(param1.text_mc.itemName_tf,this.m_unitItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         var _loc2_:Array = this.m_unitItem.goodAgainst;
         var _loc3_:int = int(_loc2_.length);
         switch(_loc3_)
         {
            case 1:
               param1.icon_mc.x = param1.anchor1_mc.x;
               break;
            case 2:
               param1.icon_mc.x = param1.anchor2_mc.x;
               break;
            default:
               param1.icon_mc.x = param1.anchor3_mc.x;
         }
         switch(_loc3_)
         {
            case 3:
            case 4:
               this.loadUnitClassImage(_loc2_[2],param1.icon_mc.icon2);
            case 2:
               this.loadUnitClassImage(_loc2_[1],param1.icon_mc.icon1);
            case 1:
               this.loadUnitClassImage(_loc2_[0],param1.icon_mc.icon0);
         }
         var _loc4_:Array = [param1.text_mc.upgrades_mc.icon0,param1.text_mc.upgrades_mc.icon1,param1.text_mc.upgrades_mc.icon2,param1.text_mc.upgrades_mc.icon3,param1.text_mc.upgrades_mc.icon4];
         this.m_upgradesDisplay = new UpgradesDisplay(_loc4_,param1.text_mc.upgrades_mc,null,null,this.m_unitItem,this.m_unitUpgrades,true);
      }
      
      private function loadUnitClassImage(param1:String, param2:UILoader) : void
      {
         var _loc4_:ImageLoader = null;
         var _loc3_:UnitClass = UnitClassManager.instance.unitClassNamed(param1);
         if(_loc3_)
         {
            _loc4_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(_loc3_.getIconURL()),param2);
            _loc4_.smooth = true;
            this.m_iconLoaders.push(_loc4_);
         }
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(!this.m_tooltip.visible)
         {
            this.m_tooltip.visible = true;
         }
         TweenLite.killTweensOf(this.m_tooltip);
         TweenLite.to(this.m_tooltip,TOOLTIP_TWEEN_TIME,{"alpha":1});
      }
      
      private function onMouseExit(param1:MouseEvent) : void
      {
         TweenLite.killTweensOf(this.m_tooltip);
         TweenLite.to(this.m_tooltip,TOOLTIP_TWEEN_TIME,{
            "alpha":0,
            "onComplete":this.onAlphaTweenedToZero
         });
      }
      
      private function onAlphaTweenedToZero() : void
      {
         this.m_tooltip.visible = false;
      }
   }
}

