package core.worlds.battleWorld
{
   import as3isolib.geom.Pt;
   import com.greensock.TweenLite;
   import com.greensock.TweenMax;
   import com.greensock.easing.Bounce;
   import com.greensock.easing.Sine;
   import core.ZGlobal;
   import core.entities.components.DestroyOnCompleteComponent;
   import core.gamemode.battle.BattleDispatcher;
   import core.gamemode.battle.BattleObject;
   import core.gameobjects.ConsumableItem;
   import core.gameobjects.GameItem;
   import core.gameobjects.ItemImage;
   import core.gameobjects.UnitItem;
   import core.managers.ExperimentsManager;
   import core.managers.FXManager.FXManager;
   import core.managers.FlamingUnitManager;
   import core.managers.TierSurfacingManager;
   import core.managers.WorldObjectManager;
   import core.managers.animationManager.FireAndForgetAnimation;
   import core.managers.prisoncamp.PrisonCampManager;
   import core.managers.rewardPickupManager.RewardPickupSpawner;
   import core.managers.tutorialManager.TutorialClassHighlighter;
   import core.managers.tutorialManager.TutorialHighlighter;
   import core.managers.tutorialManager.TutorialManager;
   import core.managers.unitClassManager.UnitClass;
   import core.managers.unitClassManager.UnitClassManager;
   import core.managers.weaponManager.WeaponManager;
   import core.player.PlayerAmmo;
   import core.ui.TextTweener;
   import core.views.ViewManager;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import rendering.rendering2d.AnimationCanvasComponent;
   import rendering.rendering2d.AnimationComponent;
   import rendering.rendering2d.DamageIndicator;
   import rendering.rendering2d.MovieComponent;
   import sound.SoundEvent;
   import utils.ZGameRandom;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.utils.MathUtils;
   import zlabs.utils.StringUtils;
   
   public class BattleUnit extends Sprite
   {
      
      public static const CLASS_ICON_X_OFFSET:int = 16;
      
      public static const CLASS_ICON_Y_OFFSET:int = 7;
      
      private static const TRIGGERED_SOUND_FIRE:int = 1 << 0;
      
      private static const TRIGGERED_SOUND_MISS:int = 1 << 1;
      
      private static const TRIGGERED_SOUND_HIT:int = 1 << 2;
      
      protected static const HOVER:int = 0;
      
      protected static const PLAYER:int = 1;
      
      private static const EXPERIMENT_ENERGY_V3_CONTROL:uint = 0;
      
      private static const EXPERIMENT_ENERGY_V3_VARIANT_1:uint = 1;
      
      private static const EXPERIMENT_ENERGY_V3_VARIANT_2:uint = 2;
      
      private static const EXPERIMENT_ENERGY_V3_VARIANT_3:uint = 3;
      
      private var m_battleObject:BattleObject = null;
      
      private var m_entity:IEntity = null;
      
      private var m_side:int = 0;
      
      private var m_direction:int = 0;
      
      private var m_art:Sprite = null;
      
      private var m_colorMap:Sprite = null;
      
      private var m_image:Bitmap = null;
      
      private var m_imageLoaders:Array = null;
      
      private var m_bar:BattleBar = null;
      
      private var m_barWidth:Number = 0;
      
      private var m_soundsTriggered:int = 0;
      
      private var m_textTweener:TextTweener = null;
      
      private var m_tierTextTweener:TextTweener = null;
      
      private var m_damageClass:Class = null;
      
      private var m_imageDimensions:Pt = null;
      
      private var m_imageOffset:Pt = null;
      
      private var m_commandoBonusClass:Class = null;
      
      private var m_flamingDamageClass:Class = null;
      
      private var m_dead:Boolean = false;
      
      private var m_doneDie:Boolean = false;
      
      private var m_doneDieRewards:Boolean = false;
      
      private var m_glowFilters:Array = null;
      
      private var m_iconTooltips:Array = null;
      
      private var m_animation:String = null;
      
      private var m_mouseStatus:Boolean = false;
      
      protected var m_selected:Boolean = false;
      
      private var m_tutorialDisabled:Boolean = false;
      
      private var m_alwaysShowClassIcon:Boolean = false;
      
      private var m_arrow:TutorialHighlighter = null;
      
      private var m_tutorialClassHighlighter:TutorialClassHighlighter = null;
      
      private var animationComponent:MovieComponent = null;
      
      private var prehitMovieComponent:MovieComponent = null;
      
      private var animationCanvas:AnimationCanvasComponent = null;
      
      private var destroyOnCompleteComponent:DestroyOnCompleteComponent = null;
      
      public function BattleUnit(param1:int, param2:BattleObject)
      {
         super();
         this.m_side = param1;
         this.m_battleObject = param2;
         this.m_glowFilters = new Array(1);
         this.m_glowFilters[HOVER] = ZGameUtils.HighlightFilter;
         this.m_glowFilters[PLAYER] = new GlowFilter(this.hoverColor,1,8,8,20);
      }
      
      public function init(param1:Sprite, param2:BattleObject, param3:int, param4:int) : void
      {
         var _loc8_:AnimationComponent = null;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc11_:Object = null;
         param1.addChild(this);
         x = param3;
         y = param4;
         mouseEnabled = false;
         this.m_art = new Sprite();
         this.m_colorMap = new Sprite();
         addChild(this.m_art);
         this.initBar();
         if(this.m_battleObject.unitItem.broadside)
         {
            if(this.m_side == BattleSide.ENEMY)
            {
               this.m_direction = GameItem.DIRECTION_SE;
            }
            else
            {
               this.m_direction = GameItem.DIRECTION_NW;
            }
         }
         else if(this.m_side == BattleSide.ENEMY)
         {
            this.m_direction = GameItem.DIRECTION_SW;
         }
         else
         {
            this.m_direction = GameItem.DIRECTION_NE;
         }
         this.calculateAnimName(this.m_direction);
         var _loc5_:Object = this.m_battleObject.unitItem.getWake(this.m_animation);
         var _loc6_:ItemImage = this.m_battleObject.unitItem.getCachedImage(this.m_animation);
         this.m_imageOffset = new Pt(_loc6_.offset.x,_loc6_.offset.y);
         x += this.m_imageOffset.x;
         y += this.m_imageOffset.y;
         this.m_imageLoaders = new Array();
         this.m_imageLoaders.push(ImageLoaderFactory.CreateImageLoader(_loc6_.url,null,this.onImageLoaded));
         this.addClassIcon();
         this.setupDrift();
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_OBJECT_SELECTED,this.onSelected);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_UI_DAMAGE_CLASS,this.onDamageClass);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_UI_COMMANDO_BONUS_CLASS,this.onCommandoBonusClass);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_UI_FLAMING_DAMAGE_CLASS,this.onFlamingDamageClass);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.UNIT_DAMAGED,this.onUnitDamaged);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.UNIT_FIRE,this.onUnitFire);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.UNIT_MISS,this.onUnitMiss);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.UNIT_HIT,this.onUnitHit);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.UNIT_CONSUMABLES_UPDATED,this.onUnitConsumable);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_UI_RECALCULATE_HIGHLIGHT,this.onRecalculateHighlight);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_SEQUENCE_COMPLETE,this.onSequenceComplete);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_PRE_START,this.onPreBattleStart);
         this.m_entity = Zlab.allocateEntity();
         var _loc7_:AnimationCanvasComponent = null;
         if(null != _loc5_)
         {
            _loc7_ = new AnimationCanvasComponent(this);
            this.m_entity.addComponent(_loc7_,"animationCanvas");
            _loc8_ = new AnimationComponent(null);
            this.m_entity.addComponent(_loc8_,"animation");
            _loc8_.anchor = StringUtils.parsePoint(_loc5_.anchorPoint);
            _loc8_.anim = _loc5_.animation;
            _loc8_.smooth = true;
            _loc7_.animations.push(_loc8_);
         }
         this.addAnimations(_loc7_);
         this.art.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseStatusOver);
         this.art.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseStatusOut);
         if(TutorialManager.instance.active)
         {
            WorldObjectManager.instance.addEventListener(WorldObjectManager.ATTACH_ARROW,this.onAttachArrow);
            WorldObjectManager.instance.addEventListener(WorldObjectManager.CLEAR_ARROWS,this.onClearArrow);
            TutorialManager.instance.addEventListener(TutorialManager.COMBAT_LOCK_SELECTION,this.onLockSelection);
            TutorialManager.instance.addEventListener(TutorialManager.COMBAT_UNLOCK_SELECTION,this.onUnlockSelection);
            TutorialManager.instance.addEventListener(TutorialManager.COMBAT_ALWAYS_SHOW_CLASS_ICONS,this.onAlwaysShowClassIcon);
            TutorialManager.instance.addEventListener(TutorialManager.COMBAT_HIGHLIGHT_UNIT_CLASS_ICON,this.onHighlightClassIcon);
            TutorialManager.instance.addEventListener(TutorialManager.COMBAT_HIGHLIGHT_CLEAR_UNIT_CLASS_ICON,this.onClearClassIconHighlight);
         }
         this.m_entity.initialize();
         this.m_dead = this.battleObject.unit.dead;
         this.m_iconTooltips = new Array();
         this.updateConsumables(true);
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_RESEARCH_SHIELD_UPGRADE) == ExperimentsManager.VARIANT_RESEARCH_SHIELD_UPGRADE_ON && this.m_battleObject.unit.shields > 0)
         {
            _loc9_ = "Shield";
            _loc10_ = WeaponManager.instance.getPreHitFX(_loc9_);
            _loc11_ = new Object();
            _loc11_.anim = FXManager.instance.getFXAnim(_loc10_);
            if(null != _loc11_.anim)
            {
               _loc11_.attachToObject = true;
               _loc11_.offset = new Pt(25,25);
               _loc11_.background = false;
               _loc11_.anchor = new Pt(0,0);
               this.prehitMovieComponent = MovieComponent.executeMovieClip(this,_loc11_);
            }
            else
            {
               Logger.error(this,"onInit","no FX anim found for weapon.id: " + _loc9_ + " firingFX: " + _loc10_);
            }
         }
      }
      
      public function shieldAnimation() : void
      {
         var _loc1_:String = "Shield";
         var _loc2_:String = WeaponManager.instance.getPreHitFX(_loc1_);
         var _loc3_:Object = new Object();
         _loc3_.anim = FXManager.instance.getFXAnim(_loc2_);
         if(null != _loc3_.anim)
         {
            _loc3_.attachToObject = true;
            _loc3_.offset = new Pt(25,25);
            _loc3_.background = false;
            _loc3_.anchor = new Pt(0,0);
            this.prehitMovieComponent = MovieComponent.executeMovieClip(this,_loc3_);
         }
         else
         {
            Logger.error(this,"onInit","no FX anim found for weapon.id: " + _loc1_ + " firingFX: " + _loc2_);
         }
      }
      
      public function dispose(param1:Sprite) : void
      {
         var _loc2_:ImageLoader = null;
         var _loc3_:BattleUnitIcon = null;
         Zlab.processManager.removeScheduledObject(this);
         TweenLite.killTweensOf(this);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_OBJECT_SELECTED,this.onSelected);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.UNIT_DAMAGED,this.onUnitDamaged);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.UNIT_FIRE,this.onUnitFire);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.UNIT_MISS,this.onUnitMiss);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.UNIT_HIT,this.onUnitHit);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.UNIT_CONSUMABLES_UPDATED,this.onUnitConsumable);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_UI_RECALCULATE_HIGHLIGHT,this.onRecalculateHighlight);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_SEQUENCE_COMPLETE,this.onSequenceComplete);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_UI_FLAMING_DAMAGE_CLASS,this.onFlamingDamageClass);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_PRE_START,this.onPreBattleStart);
         this.art.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseStatusOver);
         this.art.removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseStatusOut);
         WorldObjectManager.instance.removeEventListener(WorldObjectManager.ATTACH_ARROW,this.onAttachArrow);
         WorldObjectManager.instance.removeEventListener(WorldObjectManager.CLEAR_ARROWS,this.onClearArrow);
         TutorialManager.instance.removeEventListener(TutorialManager.COMBAT_LOCK_SELECTION,this.onLockSelection);
         TutorialManager.instance.removeEventListener(TutorialManager.COMBAT_UNLOCK_SELECTION,this.onUnlockSelection);
         TutorialManager.instance.removeEventListener(TutorialManager.COMBAT_ALWAYS_SHOW_CLASS_ICONS,this.onAlwaysShowClassIcon);
         TutorialManager.instance.removeEventListener(TutorialManager.COMBAT_HIGHLIGHT_UNIT_CLASS_ICON,this.onHighlightClassIcon);
         TutorialManager.instance.removeEventListener(TutorialManager.COMBAT_HIGHLIGHT_CLEAR_UNIT_CLASS_ICON,this.onClearClassIconHighlight);
         this.removeMouseEvents(false);
         this.onClearArrow(null);
         this.onClearClassIconHighlight(null);
         for each(_loc2_ in this.m_imageLoaders)
         {
            _loc2_.destroy();
         }
         this.m_imageLoaders = null;
         for each(_loc3_ in this.m_iconTooltips)
         {
            _loc3_.dispose();
         }
         this.m_iconTooltips = null;
         this.disablePowerButton();
         if(this.m_bar)
         {
            TweenLite.killTweensOf(this.m_bar);
            TweenLite.killTweensOf(this.m_bar.bar_mc);
            removeChild(this.m_bar);
            this.m_textTweener.dispose();
            this.m_textTweener = null;
            if(this.m_tierTextTweener)
            {
               this.m_tierTextTweener.dispose();
            }
            this.m_tierTextTweener = null;
            this.m_bar = null;
         }
         this.m_damageClass = null;
         this.stopDrift();
         if(Boolean(this.m_image) && Boolean(this.m_colorMap))
         {
            this.m_colorMap.removeChild(this.m_image);
            this.m_art.removeChild(this.m_colorMap);
         }
         if(this.m_tutorialClassHighlighter)
         {
            this.m_tutorialClassHighlighter.dispose();
            this.m_tutorialClassHighlighter = null;
         }
         this.m_image = null;
         this.m_colorMap = null;
         removeChild(this.m_art);
         this.m_art = null;
         param1.removeChild(this);
         this.m_glowFilters = null;
         this.m_entity.destroy();
         this.m_entity = null;
      }
      
      public function set slideTo(param1:Point) : void
      {
         if(this.centreUnit)
         {
            TweenLite.to(this,5,{
               "x":param1.x + this.m_imageOffset.x - this.m_imageDimensions.x * 0.5,
               "y":param1.y + this.m_imageOffset.y - this.m_imageDimensions.y * 0.5
            });
         }
         else
         {
            TweenLite.to(this,5,{
               "x":param1.x + this.m_imageOffset.x,
               "y":param1.y + this.m_imageOffset.y
            });
         }
      }
      
      public function isBattleObject(param1:BattleObject) : Boolean
      {
         return param1 == this.m_battleObject;
      }
      
      public function set selected(param1:Boolean) : void
      {
         this.m_selected = param1;
      }
      
      public function get side() : int
      {
         return this.m_side;
      }
      
      public function get dead() : Boolean
      {
         return this.m_dead;
      }
      
      protected function initBar() : void
      {
         this.m_bar = new BattleBar();
         this.m_bar.mouseEnabled = false;
         this.m_bar.y -= 15;
         this.tierValueVisible = false;
         var _loc1_:Point = this.battleObject.unitItem.healthBarOffset(this.m_side);
         if(_loc1_)
         {
            this.m_bar.y += _loc1_.y;
         }
         this.m_barWidth = this.m_bar.bar_mc.width;
         addChild(this.m_bar);
         this.disablePowerButton();
         this.m_textTweener = new TextTweener(this.m_bar.strength_tf);
         if(Boolean(this.m_bar.tierRating_mc) && TierSurfacingManager.instance.tierSurfacingEnabled)
         {
            this.m_tierTextTweener = new TextTweener(this.m_bar.tierRating_mc.tier_tf);
         }
         if(ZGameUtils.hideIfExists(this.m_bar.mana_tf))
         {
            this.m_bar.mana_tf.mouseEnabled = false;
         }
      }
      
      protected function addClassIcon() : void
      {
         var _loc2_:String = null;
         var _loc3_:ImageLoader = null;
         var _loc1_:UnitClass = UnitClassManager.instance.unitClassNamed(this.m_battleObject.unitItem.unitClass);
         if(_loc1_)
         {
            _loc2_ = this.m_side == BattleSide.ENEMY ? _loc1_.getAltIconURL() : _loc1_.getIconURL();
            this.m_bar.icon.scaleContent = false;
            _loc3_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(_loc2_),this.m_bar.icon);
            _loc3_.smooth = true;
            this.m_imageLoaders.push(_loc3_);
         }
         this.m_bar.icon.visible = false;
      }
      
      protected function repositionBar() : void
      {
         var _loc2_:int = 0;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:* = 0;
         var _loc1_:Point = null;
         if(this.m_side == BattleSide.ENEMY)
         {
            this.m_bar.x = int((this.m_imageDimensions.x - this.m_barWidth) * 0.4);
            _loc1_ = this.battleObject.unitItem.healthBarOffset(this.m_side);
            if(_loc1_)
            {
               this.m_bar.x += _loc1_.x;
            }
         }
         else
         {
            this.m_bar.x = int((this.m_imageDimensions.x - this.m_barWidth) * 0.33);
            _loc1_ = this.battleObject.unitItem.healthBarOffset(this.m_side);
            if(_loc1_)
            {
               this.m_bar.x += _loc1_.x;
            }
            _loc2_ = x + this.m_bar.x;
            if(_loc2_ < 36)
            {
               this.m_bar.x += 36 - _loc2_;
            }
            _loc3_ = x + this.m_bar.x + this.m_bar.width;
            _loc4_ = y + this.m_bar.y;
            _loc5_ = 760 - _loc3_;
            _loc6_ = 560 - _loc4_;
            _loc7_ = Math.atan2(_loc5_,_loc6_);
            _loc8_ = 10;
            while(_loc8_ >= 0 && _loc7_ < 0.9)
            {
               this.m_bar.x -= 5;
               this.m_bar.y += 5;
               _loc3_ = x + this.m_bar.x + this.m_bar.width;
               _loc4_ = y + this.m_bar.y;
               _loc5_ = 760 - _loc3_;
               _loc6_ = 560 - _loc4_;
               _loc7_ = Math.atan2(_loc5_,_loc6_);
               _loc8_--;
            }
         }
      }
      
      protected function get battleObject() : BattleObject
      {
         return this.m_battleObject;
      }
      
      protected function get imageLoaders() : Array
      {
         return this.m_imageLoaders;
      }
      
      protected function get direction() : int
      {
         return this.m_direction;
      }
      
      public function set classIconVisible(param1:Boolean) : void
      {
         this.m_bar.icon.visible = param1;
      }
      
      public function set tierValueVisible(param1:Boolean) : void
      {
         if(Boolean(this.m_bar) && Boolean(this.m_bar.tierRating_mc))
         {
            this.m_bar.tierRating_mc.visible = param1;
         }
      }
      
      public function set highlight(param1:Boolean) : void
      {
         if(param1)
         {
            this.m_colorMap.filters = [this.m_glowFilters[this.colorIndex]];
            this.classIconVisible = true;
            this.tierValueVisible = TierSurfacingManager.instance.tierSurfacingEnabled;
         }
         else if(!this.m_selected)
         {
            this.m_colorMap.filters = [];
            if(!this.m_alwaysShowClassIcon)
            {
               this.classIconVisible = false;
               this.tierValueVisible = false;
            }
         }
      }
      
      public function set paused(param1:Boolean) : void
      {
         var _loc3_:AnimationComponent = null;
         var _loc2_:Array = this.m_entity.lookupComponentsByType(AnimationComponent);
         for each(_loc3_ in _loc2_)
         {
            _loc3_.paused = param1;
         }
         if(param1)
         {
            this.stopDrift();
         }
         else
         {
            this.setupDrift();
         }
      }
      
      public function get artWidth() : Number
      {
         return this.m_colorMap.width;
      }
      
      public function get artHeight() : Number
      {
         return this.m_colorMap.height;
      }
      
      private function calculateAnimName(param1:int) : void
      {
         var _loc3_:String = null;
         var _loc2_:String = GameItem.DIRECTION_NAMES[param1] + "_run";
         if(this.m_battleObject.unitItem.hasCachedImage(_loc2_))
         {
            _loc3_ = _loc2_ + "_dam";
            if(this.m_battleObject.unit.dead && this.m_battleObject.unitItem.hasCachedImage(_loc3_))
            {
               this.m_animation = _loc3_;
            }
            else
            {
               this.m_animation = _loc2_;
            }
         }
         else
         {
            this.m_animation = GameItem.DIRECTION_NAMES[param1];
         }
      }
      
      private function addAnimations(param1:AnimationCanvasComponent) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc5_:AnimationComponent = null;
         var _loc2_:Array = this.m_battleObject.unitItem.getAnimations(this.m_animation);
         if(null != _loc2_ && _loc2_.length > 0)
         {
            if(null == param1)
            {
               param1 = new AnimationCanvasComponent(this.m_colorMap);
               this.m_entity.addComponent(param1,"animationCanvas");
            }
            _loc3_ = 0;
            for each(_loc4_ in _loc2_)
            {
               _loc5_ = new AnimationComponent(null);
               this.m_entity.addComponent(_loc5_,"animation" + _loc3_.toString());
               param1.animations.push(_loc5_);
               _loc5_.smooth = true;
               _loc3_++;
            }
            param1.animationData = _loc2_;
         }
      }
      
      public function recalculateAnimations() : void
      {
         this.calculateAnimName(this.m_direction);
         var _loc1_:Array = this.m_battleObject.unitItem.getAnimations(this.m_animation);
         var _loc2_:AnimationCanvasComponent = this.m_entity.lookupComponentByType(AnimationCanvasComponent) as AnimationCanvasComponent;
         _loc2_.animationData = _loc1_;
      }
      
      protected function setupDrift() : void
      {
         var _loc1_:Number = 0;
         var _loc2_:Number = this.m_battleObject.unitItem.driftMult;
         if(this.m_battleObject.unitItem.subType == UnitItem.NAVY)
         {
            _loc1_ = MathUtils.randBetween(1,1.5);
            TweenMax.to(this.m_art,_loc1_ * _loc2_,{
               "x":"5",
               "y":"5",
               "yoyo":true,
               "repeat":-1,
               "ease":Sine.easeInOut
            });
         }
         else if(this.m_battleObject.unitItem.subType == UnitItem.ARMY)
         {
            _loc1_ = MathUtils.randBetween(1,1.5);
            TweenMax.to(this.m_art,_loc1_ * _loc2_,{
               "x":"-10",
               "y":"10",
               "yoyo":true,
               "repeat":-1,
               "ease":Sine.easeInOut
            });
         }
         else
         {
            _loc1_ = MathUtils.randBetween(0.9,1.6);
            TweenMax.to(this.m_art,_loc1_ * _loc2_,{
               "y":"10",
               "yoyo":true,
               "repeat":-1,
               "ease":Sine.easeInOut
            });
            _loc1_ = MathUtils.randBetween(0.9,1.6);
            TweenMax.to(this.m_art,_loc1_ * _loc2_,{
               "x":"10",
               "yoyo":true,
               "repeat":-1,
               "ease":Sine.easeInOut
            });
         }
      }
      
      private function stopDrift() : void
      {
         TweenMax.killTweensOf(this.m_art);
      }
      
      protected function get centreUnit() : Boolean
      {
         return true;
      }
      
      protected function onImageLoaded(param1:String, param2:BitmapData) : void
      {
         this.m_image = new Bitmap(param2);
         this.m_colorMap.addChild(this.m_image);
         this.m_art.addChild(this.m_colorMap);
         this.m_imageDimensions = new Pt(param2.width,param2.height);
         if(this.centreUnit)
         {
            x -= this.m_imageDimensions.x * 0.5;
            y -= this.m_imageDimensions.y * 0.5;
         }
         this.repositionBar();
         ZGameUtils.smoothImage(this.m_image);
      }
      
      public function die(param1:BattleObject, param2:BattleObject, param3:Object) : void
      {
         this.removeMouseEvents(true);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_UI_RECALCULATE_HIGHLIGHT,this.onRecalculateHighlight);
         var _loc4_:Number = this.getWeaponHitDelay(param1,param3,true);
         if(_loc4_ > 0)
         {
            Zlab.processManager.schedule(_loc4_ * 1000,this,this.dieDelayComplete);
         }
         else
         {
            this.dieDelayComplete();
         }
      }
      
      public function get art() : DisplayObject
      {
         return this.m_art;
      }
      
      public function get image() : Bitmap
      {
         return this.m_image;
      }
      
      public function get bar() : BattleBar
      {
         return this.m_bar;
      }
      
      public function hitTest(param1:Point) : Boolean
      {
         var _loc3_:AnimationComponent = null;
         if(Boolean(this.m_image) && this.m_image.bitmapData.hitTest(new Point(0,0),1,param1))
         {
            return true;
         }
         var _loc2_:Array = this.m_entity.lookupComponentsByType(AnimationComponent);
         for each(_loc3_ in _loc2_)
         {
            if(_loc3_.mouseHitTest(param1))
            {
               return true;
            }
         }
         return false;
      }
      
      private function onUnitConsumable(param1:WorldEvent) : void
      {
         if(param1.eventData.fleet == this.m_battleObject.fleet)
         {
            this.updateConsumables(false);
         }
      }
      
      private function allocIcons(param1:int) : void
      {
         param1 -= this.m_iconTooltips.length;
         while(param1 > 0)
         {
            this.m_iconTooltips.push(new BattleUnitIcon(this.m_bar));
            param1--;
         }
      }
      
      protected function updateConsumables(param1:Boolean) : void
      {
         var _loc6_:Object = null;
         var _loc7_:ConsumableItem = null;
         var _loc2_:Array = this.m_battleObject.fleet.getConsumables(this.m_battleObject.unit.id);
         var _loc3_:Object = this.m_battleObject.fleet.doubleShot;
         if(_loc3_ != null)
         {
            _loc2_.push(_loc3_);
         }
         var _loc4_:uint = _loc2_.length;
         this.allocIcons(_loc4_);
         var _loc5_:int = 0;
         for each(_loc6_ in _loc2_)
         {
            _loc7_ = ZGlobal.gameSettings.getItemByCode(_loc6_.code,ConsumableItem) as ConsumableItem;
            if(_loc7_.hasCachedImage("bar"))
            {
               this.m_iconTooltips[_loc5_].update(_loc7_,_loc6_,_loc5_,_loc4_);
               _loc5_++;
            }
         }
         while(_loc5_ < this.m_iconTooltips.length)
         {
            this.m_iconTooltips[_loc5_].clear();
            _loc5_++;
         }
         this.updateStrengthUI(param1);
      }
      
      private function onPairChosen(param1:WorldEvent) : void
      {
         if(!this.m_dead)
         {
            if(null != param1.eventData && (param1.eventData.attacker == this.m_battleObject || param1.eventData.defender == this.m_battleObject))
            {
               TweenLite.to(this.m_bar,0.5,{"alpha":1});
            }
            else
            {
               TweenLite.to(this.m_bar,0.5,{"alpha":0.4});
            }
         }
      }
      
      private function onSelected(param1:WorldEvent) : void
      {
         this.selected = param1.eventData == this.m_battleObject;
         this.highlight = this.m_selected;
      }
      
      private function getWeaponHitDelay(param1:BattleObject, param2:Object, param3:Boolean) : Number
      {
         var _loc4_:Number = 0;
         var _loc5_:BattleUnit = this.getOtherUnit(param1);
         var _loc6_:Array = null;
         if(null != param1)
         {
            _loc6_ = param1.unitItem.getWeapons(_loc5_.m_animation,this.m_battleObject.unitItem.subType);
         }
         else if(null != param2)
         {
            _loc6_ = [param2];
         }
         if(null != _loc6_)
         {
            _loc4_ = WeaponManager.instance.getHitDelay(_loc6_[0].id);
            if(param3 && WeaponManager.instance.hasRandDelay(_loc6_[0].id))
            {
               _loc4_ = MathUtils.randBetween(_loc4_ * 0.2,_loc4_);
            }
         }
         return _loc4_;
      }
      
      protected function onUnitDamaged(param1:WorldEvent) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Object = null;
         if(param1.eventData.target == this.m_battleObject)
         {
            _loc2_ = 0;
            if(this.battleObject.unit.shields <= 0)
            {
               if(param1.eventData.damage != 0)
               {
                  _loc2_ = Math.max(1,this.getWeaponHitDelay(param1.eventData.attacker,param1.eventData.weapon,false));
                  _loc2_ *= 1000;
                  this.doDamageUI(_loc2_,param1.eventData);
                  Zlab.processManager.schedule(_loc2_,this,this.updateStrengthUI);
                  if(null == param1.eventData.consumable)
                  {
                     _loc3_ = {"data":param1.eventData};
                     _loc3_.autoSize = true;
                     if(param1.eventData.critical)
                     {
                        if(this.battleObject.unit.dead)
                        {
                           _loc3_.text = ZGameUtils.ZlocT("Combat","CriticalKill");
                        }
                        else
                        {
                           _loc3_.text = ZGameUtils.ZlocT("Combat","CriticalHit");
                        }
                     }
                     else if(param1.eventData.glancing)
                     {
                        _loc3_.text = ZGameUtils.ZlocT("Combat","GlancingHit");
                     }
                     else
                     {
                        _loc3_.text = ZGameUtils.ZlocT("Combat","DirectHit");
                     }
                     this.floatingText(_loc2_ * 0.3,x + this.artWidth * 0.5,y,_loc3_);
                  }
               }
            }
         }
      }
      
      private function doDamageUI(param1:int, param2:Object) : void
      {
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc6_:Number = NaN;
         var _loc7_:String = null;
         var _loc3_:Number = x + this.artWidth * 0.5;
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_RESEARCH_SHIELD_UPGRADE) == ExperimentsManager.VARIANT_RESEARCH_SHIELD_UPGRADE_ON && Boolean(param2.target.unit.shieldHit))
         {
            param2.text = ZGameUtils.ZlocT("Combat","ShieldDestroyed");
            param2.autoSize = true;
            this.floatingText(param1,_loc3_,y,param2);
         }
         else
         {
            if(param2.damage != 0)
            {
               _loc4_ = !isNaN(param2.upgradeDamage) ? int(Math.ceil(param2.damage - param2.upgradeDamage)) : int(Math.ceil(param2.damage));
               _loc5_ = this.getFloatingStringData(_loc4_);
               this.floatingText(param1,_loc3_,y,{
                  "text":_loc5_.string,
                  "data":param2,
                  "float":-100,
                  "invert":_loc5_.invert
               });
            }
            if(FlamingUnitManager.instance.flamingUnitsEnabled && param2.attacker != null && (Boolean(param2.attacker.unitItem.isFlamingUnit == true) || Boolean(param2.attacker.fleet.hasFlameConsumable())))
            {
               _loc6_ = FlamingUnitManager.instance.flamingDamage;
               _loc7_ = "-" + _loc6_.toString() + " " + ZGameUtils.ZlocT("Tooltips","FieryDamage");
               this.flamingDamageFloatingText(param1 + 500,_loc3_ - 100,y + 50,{
                  "text":_loc7_,
                  "float":50
               });
            }
            if(!isNaN(param2.upgradeDamage) && param2.upgradeDamage != 0)
            {
               _loc4_ = int(Math.ceil(param2.upgradeDamage));
               _loc5_ = this.getFloatingStringData(_loc4_);
               this.floatingText(param1 + 200,_loc3_ + 15,y,{
                  "text":_loc5_.string,
                  "data":param2,
                  "float":-100,
                  "invert":_loc5_.invert
               });
            }
            if(param2.commandoAssaultBonus)
            {
               _loc5_ = ZGameUtils.ZlocT("Tooltips","Commando_Assault_Yard_active_tooltip");
               this.commandoFloatingText(param1 + 100,_loc3_ - 100,y + 50,{
                  "text":_loc5_,
                  "float":50
               });
            }
         }
      }
      
      private function getFloatingStringData(param1:int) : Object
      {
         var _loc2_:Boolean = false;
         var _loc3_:String = null;
         if(param1 > 0)
         {
            _loc3_ = "-" + param1.toString();
         }
         else
         {
            _loc3_ = "+" + param1.toString().slice(1);
            _loc2_ = true;
         }
         return {
            "string":_loc3_,
            "invert":_loc2_
         };
      }
      
      public function floatingText(param1:int, param2:Number, param3:Number, param4:Object = null) : void
      {
         var _loc5_:Number = 1;
         var _loc6_:Boolean = false;
         if(param4.data)
         {
            if(param4.data.critical)
            {
               _loc5_ = 2;
            }
            else if(!param4.data.glancing)
            {
               _loc5_ = 1.5;
            }
            if(param4.invert)
            {
               _loc6_ = true;
            }
         }
         var _loc7_:DamageIndicator = new DamageIndicator(this.m_damageClass,parent.parent.parent,_loc6_);
         _loc7_.scale = _loc5_;
         if(null != param4.autoSize)
         {
            _loc7_.autoSize = param4.autoSize;
         }
         if(null != param4.float)
         {
            _loc7_.float = param4.float;
         }
         _loc7_.floatingText(param4.text,param1,param2,param3);
      }
      
      private function commandoFloatingText(param1:int, param2:Number, param3:Number, param4:Object = null) : void
      {
         var _loc5_:DamageIndicator = null;
         if(this.m_commandoBonusClass)
         {
            _loc5_ = new DamageIndicator(this.m_commandoBonusClass,parent.parent.parent,false);
            if(null != param4.float)
            {
               _loc5_.float = param4.float;
            }
            _loc5_.floatingText(param4.text,param1,param2,param3);
         }
      }
      
      private function flamingDamageFloatingText(param1:int, param2:Number, param3:Number, param4:Object = null) : void
      {
         var _loc5_:DamageIndicator = null;
         if(this.m_flamingDamageClass)
         {
            _loc5_ = new DamageIndicator(this.m_flamingDamageClass,parent.parent.parent,false);
            if(null != param4.float)
            {
               _loc5_.float = param4.float;
            }
            _loc5_.floatingText(param4.text,param1,param2,param3);
         }
      }
      
      protected function updateStrengthUI(param1:Boolean = false) : void
      {
         var _loc5_:int = 0;
         var _loc2_:int = int(this.m_battleObject.unit.strength);
         this.m_textTweener.tweenTo(_loc2_,param1 ? 0 : 0.5);
         if(this.m_tierTextTweener)
         {
            _loc5_ = int(this.m_battleObject.unitItem.tier);
            this.m_tierTextTweener.tweenTo(_loc5_,param1 ? 0 : 0.5);
         }
         var _loc3_:Number = this.m_battleObject.unitItem.getStrength(this.m_battleObject.fleet);
         var _loc4_:Number = this.m_barWidth * (this.m_battleObject.unit.strength / _loc3_);
         if(param1)
         {
            this.m_bar.bar_mc.width = _loc4_;
         }
         else
         {
            TweenLite.to(this.m_bar.bar_mc,0.5,{
               "width":_loc4_,
               "ease":Bounce.easeOut
            });
         }
      }
      
      private function addSound(param1:Object, param2:int, param3:String) : void
      {
         var _loc4_:SoundEvent = null;
         param1.sound = null;
         if(null != param3)
         {
            _loc4_ = SoundEvent.getSoundEvent(param3);
            if(null != _loc4_)
            {
               if(!_loc4_.group || (this.m_soundsTriggered & param2) == 0)
               {
                  this.m_soundsTriggered |= param2;
                  param1.sound = param3;
               }
            }
            else
            {
               Logger.error(this,"addSound","missing sound event for " + param3);
            }
         }
      }
      
      private function onUnitFire(param1:WorldEvent) : void
      {
         var _loc2_:Array = null;
         var _loc3_:Object = null;
         var _loc4_:String = null;
         var _loc5_:Object = null;
         var _loc6_:Boolean = false;
         var _loc7_:Number = NaN;
         if(param1.eventData.attacker == this.m_battleObject)
         {
            _loc2_ = this.m_battleObject.unitItem.getWeapons(this.m_animation,param1.eventData.subType ? param1.eventData.subType : param1.eventData.target.unitItem.subType);
            for each(_loc3_ in _loc2_)
            {
               _loc4_ = WeaponManager.instance.getFiringFX(_loc3_.id);
               if(null != _loc4_)
               {
                  _loc5_ = new Object();
                  _loc5_.attachToObject = true;
                  _loc5_.anchor = _loc3_.anchor;
                  _loc5_.anim = FXManager.instance.getFXAnim(_loc4_);
                  if(null != _loc5_.anim)
                  {
                     _loc5_.forceToBack = FXManager.instance.getFXBackground(_loc4_);
                     _loc6_ = FXManager.instance.getFXForeground(_loc4_);
                     _loc5_.sound = FXManager.instance.getFXSound(_loc4_);
                     _loc5_.loopCount = FXManager.instance.getFXLoopCount(_loc4_);
                     if(!_loc6_)
                     {
                        if(this.m_battleObject.unitItem.broadside)
                        {
                           _loc5_.background = this.m_direction == GameItem.DIRECTION_NW || this.m_direction == GameItem.DIRECTION_SW;
                        }
                        else
                        {
                           _loc5_.background = this.m_direction == GameItem.DIRECTION_NE || this.m_direction == GameItem.DIRECTION_NW;
                        }
                        if(!_loc5_.background && Boolean(_loc3_.background))
                        {
                           _loc5_.background = true;
                        }
                     }
                     _loc7_ = _loc3_.delay * 1000;
                     Zlab.processManager.schedule(_loc7_,this,this.playFireFX,_loc5_);
                  }
                  else
                  {
                     Logger.error(this,"onUnitFire","no FX anim found for weapon.id: " + _loc3_.id + " firingFX: " + _loc4_);
                  }
               }
               else
               {
                  Logger.error(this,"onUnitFire","no firing FX  for weapon.id: " + _loc3_.id);
               }
            }
         }
      }
      
      protected function playFireFX(param1:Object) : void
      {
         var _loc3_:BattleRendererComponent = null;
         var _loc2_:Sprite = null;
         if(null != param1.forceToBack && true == param1.forceToBack)
         {
            _loc3_ = ViewManager.instance.getComponentFromView(BattleWorld.ID,BattleRendererComponent) as BattleRendererComponent;
            _loc2_ = _loc3_.getBackground(this.m_side);
            param1.anchor.x += x;
            param1.anchor.y += y;
            param1.background = false;
         }
         else
         {
            _loc2_ = this.art as Sprite;
         }
         this.addSound(param1,TRIGGERED_SOUND_FIRE,param1.sound);
         FireAndForgetAnimation.execute2D(_loc2_,param1);
      }
      
      protected function playDamageXPReward(param1:Object) : void
      {
         if(this.battleObject.unit.dead)
         {
            this.m_doneDieRewards = true;
            this.tryStartDeathFX();
            BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.UNIT_VISUAL_KILL,param1));
         }
         else
         {
            BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.UNIT_VISUAL_HIT,param1));
         }
      }
      
      protected function getRareType(param1:int) : String
      {
         return "nrare" + param1 % 5;
      }
      
      protected function get unitRewardsMultipler() : Number
      {
         return 1;
      }
      
      protected function getCoinAmount(param1:int, param2:int) : int
      {
         var _loc3_:Number = 1;
         if(PlayerAmmo.variantAmmoMasterOn())
         {
            _loc3_ = ZGlobal.gameSettings.getNumber("ammoCombatRewardResourceMultiplier",1);
         }
         var _loc4_:Number = ZGlobal.gameSettings.getNumber("combatRewardCoinsMultiplier",1);
         return int(Math.ceil(param2 * param1 * _loc4_ * this.unitRewardsMultipler * _loc3_));
      }
      
      protected function getRareAmount(param1:int, param2:int) : int
      {
         var _loc3_:Number = 1;
         if(PlayerAmmo.variantAmmoMasterOn())
         {
            _loc3_ = ZGlobal.gameSettings.getNumber("ammoCombatRewardResourceMultiplier",1);
         }
         var _loc4_:Number = ZGlobal.gameSettings.getNumber("combatRewardRareMultiplier",1);
         return int(Math.ceil(param1 * param2 * _loc4_ * this.unitRewardsMultipler * _loc3_));
      }
      
      protected function getOilAmount(param1:int, param2:int) : int
      {
         var _loc3_:Number = 1;
         if(PlayerAmmo.variantAmmoMasterOn())
         {
            _loc3_ = ZGlobal.gameSettings.getNumber("ammoCombatRewardResourceMultiplier",1);
         }
         var _loc4_:Number = ZGlobal.gameSettings.getNumber("combatRewardOilMultiplier",1);
         return int(Math.ceil(param1 * _loc4_ * _loc3_));
      }
      
      protected function addRewards(param1:String, param2:Object, param3:int = 1) : void
      {
         var _loc5_:XML = null;
         var _loc6_:Number = NaN;
         var _loc4_:XMLList = ZGlobal.gameSettings.getCombatReward(param1);
         for each(_loc5_ in _loc4_)
         {
            if(_loc5_.@type == "xp")
            {
               param2.numXPLoot = param3 * parseInt(_loc5_.@count);
            }
            else if(_loc5_.@type == "energy" && !_loc5_.@percent.toString())
            {
               if(this.giveEnergyAsCombatReward())
               {
                  param2.numEnergyLoot = parseInt(_loc5_.@count);
                  if(ZGlobal.energyRewardVariant_v3 == EXPERIMENT_ENERGY_V3_VARIANT_2)
                  {
                     param2.numEnergyLoot = Math.max(0,param2.numEnergyLoot - 1);
                  }
               }
            }
            else if(_loc5_.@type == "energy" && Boolean(_loc5_.@percent.toString()))
            {
               _loc6_ = ZGlobal.player.campaign.currentMasteryScalar;
               if(_loc6_ == 1 && this.shouldGiveReward(_loc5_))
               {
                  if(param2.numEnergyLoot == undefined)
                  {
                     param2.numEnergyLoot = parseInt(_loc5_.@count);
                  }
                  else
                  {
                     param2.numEnergyLoot += parseInt(_loc5_.@count);
                  }
               }
            }
         }
      }
      
      private function shouldGiveReward(param1:XML) : Boolean
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         if(param1.@percent != undefined)
         {
            _loc2_ = Number(param1.@percent);
            _loc3_ = ZGlobal.gameSettings.getCombatEnergyRewardMod();
            _loc2_ *= _loc3_;
            if(PlayerAmmo.variantAmmoMasterOn())
            {
               _loc5_ = ZGlobal.gameSettings.getNumber("ammoCombatRewardEnergyMultiplier",1);
               _loc2_ *= _loc5_;
            }
            _loc4_ = ZGameRandom.rewardInstance.float();
            if(_loc4_ <= _loc2_)
            {
               return true;
            }
         }
         return false;
      }
      
      private function giveEnergyAsCombatReward() : Boolean
      {
         var _loc1_:Boolean = true;
         if(ZGlobal.energyRewardVariant_v2 == ZGlobal.EXPERIMENT_ENERGY_V2_VARIANT_2)
         {
            _loc1_ = false;
         }
         else if(ZGlobal.energyRewardVariant_v3 == EXPERIMENT_ENERGY_V3_VARIANT_3)
         {
            _loc1_ = false;
         }
         return _loc1_;
      }
      
      protected function spawnLoot(param1:Object, param2:Boolean) : void
      {
         var _loc4_:RewardPickupSpawner = null;
         var _loc5_:int = 0;
         var _loc3_:Number = param2 ? ZGlobal.player.campaign.currentMasteryScalar : 1;
         if(_loc3_ > 0)
         {
            _loc4_ = new RewardPickupSpawner(new Pt(param1.x,param1.y));
            param1.numXPLoot = int(Math.ceil(param1.numXPLoot * _loc3_));
            param1.numXPLoot = PrisonCampManager.instance.applyXPMultiplier(param1.numXPLoot,ZGameRandom.rewardInstance);
            while(param1.numXPLoot > 0)
            {
               _loc4_.addLoot({
                  "type":RewardPickupSpawner.XP,
                  "amount":this.battleObject.unitItem.xp
               });
               --param1.numXPLoot;
            }
            while(param1.numCoinLoot > 0)
            {
               _loc5_ = int(Math.round(param1.coinAmount * _loc3_));
               _loc4_.addLoot({
                  "type":RewardPickupSpawner.COINS,
                  "amount":_loc5_
               });
               --param1.numCoinLoot;
            }
            param1.numRareLoot = int(Math.ceil(param1.numRareLoot * _loc3_));
            while(param1.numRareLoot > 0)
            {
               _loc4_.addLoot({
                  "type":RewardPickupSpawner.RESOURCE,
                  "rareType":param1.rareType,
                  "amount":param1.rareAmount
               });
               --param1.numRareLoot;
            }
            param1.numEnergyLoot = _loc3_ == 1 ? param1.numEnergyLoot : 0;
            while(param1.numEnergyLoot > 0)
            {
               if(PlayerAmmo.variantAmmoMasterOn())
               {
                  _loc4_.addLoot({
                     "type":RewardPickupSpawner.AMMO,
                     "amount":param1.energyAmount
                  });
               }
               else
               {
                  _loc4_.addLoot({
                     "type":RewardPickupSpawner.ENERGY,
                     "amount":param1.energyAmount
                  });
               }
               --param1.numEnergyLoot;
            }
            while(param1.numManaLoot > 0)
            {
               _loc4_.addLoot({
                  "type":RewardPickupSpawner.MANA,
                  "amount":param1.manaAmount
               });
               --param1.numManaLoot;
            }
            while(param1.numItemLoot > 0)
            {
               _loc4_.addLoot({
                  "type":RewardPickupSpawner.ITEM,
                  "item":param1.itemLoot[param1.numItemLoot - 1]
               });
               --param1.numItemLoot;
            }
            param1.numOilLoot = int(Math.round(param1.numOilLoot * _loc3_));
            while(param1.numOilLoot > 0)
            {
               _loc4_.addLoot({
                  "type":RewardPickupSpawner.OIL,
                  "amount":param1.oilAmount
               });
               --param1.numOilLoot;
            }
            while(param1.scrap > 0)
            {
               _loc4_.addLoot({
                  "type":RewardPickupSpawner.SCRAP,
                  "amount":param1.scrap
               });
               --param1.scrap;
            }
            _loc4_.delay = param1.delay;
            _loc4_.go(param1.flags);
         }
      }
      
      private function getOtherUnit(param1:BattleObject) : BattleUnit
      {
         var _loc2_:BattleRendererComponent = ViewManager.instance.getComponentFromView(BattleWorld.ID,BattleRendererComponent) as BattleRendererComponent;
         return _loc2_.getBattleUnit(param1);
      }
      
      private function breakShield(param1:WorldEvent) : void
      {
         param1.eventData.target.unit.shieldHit = 0;
         this.prehitMovieComponent.dispatchComplete();
         var _loc2_:String = "Shield";
         var _loc3_:Point = new Point(25,25);
         var _loc4_:String = WeaponManager.instance.getOnHitFX(_loc2_);
         var _loc5_:Object = new Object();
         _loc5_.anim = FXManager.instance.getFXAnim(_loc4_);
         if(null != _loc5_.anim)
         {
            _loc5_.sound = FXManager.instance.getFXSound(_loc4_);
            _loc5_.trigger = TRIGGERED_SOUND_HIT;
            _loc5_.attachToObject = true;
            _loc5_.offset = new Pt(25,25);
            _loc5_.background = false;
            _loc5_.anchor = new Pt(0,0);
            _loc5_.loopCount = 0;
            this.addUnitFX(_loc5_);
         }
         else
         {
            Logger.error(this,"breakShield","no FX anim found for weapon.id: " + _loc2_ + " hitFX: " + _loc4_);
         }
      }
      
      private function onUnitMiss(param1:WorldEvent, param2:Boolean = false) : void
      {
         var _loc3_:BattleUnit = null;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:Boolean = false;
         var _loc7_:int = 0;
         var _loc8_:Object = null;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc11_:Point = null;
         var _loc12_:Point = null;
         var _loc13_:Object = null;
         var _loc14_:Number = NaN;
         if(param1.eventData.target == this.m_battleObject)
         {
            if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_RESEARCH_SHIELD_UPGRADE) == ExperimentsManager.VARIANT_RESEARCH_SHIELD_UPGRADE_ON && param1.eventData.target.unit.shieldHit != 0)
            {
               this.breakShield(param1);
            }
            _loc3_ = this.getOtherUnit(param1.eventData.attacker);
            _loc4_ = param1.eventData.attacker.unitItem.getWeapons(_loc3_.m_animation,param1.eventData.subType ? param1.eventData.subType : this.m_battleObject.unitItem.subType);
            if(null != _loc4_)
            {
               _loc5_ = 0;
               _loc6_ = false;
               _loc7_ = int(_loc4_.length);
               for each(_loc8_ in _loc4_)
               {
                  _loc9_ = null;
                  if(this.m_battleObject.unitItem.subType == UnitItem.ARMY && !this.m_battleObject.unitItem.hasType(UnitItem.MEGA_UNIT))
                  {
                     _loc9_ = WeaponManager.instance.getLandMissFX(_loc8_.id);
                  }
                  else if(this.m_battleObject.unitItem.subType == UnitItem.NAVY)
                  {
                     _loc9_ = WeaponManager.instance.getWaterMissFX(_loc8_.id);
                  }
                  else
                  {
                     _loc9_ = WeaponManager.instance.getAirMissFX(_loc8_.id);
                  }
                  if(null != _loc9_)
                  {
                     _loc10_ = ZGlobal.gameSettings.getCampaignMapDrift(GameItem.DIRECTION_NAMES[this.m_direction]);
                     _loc11_ = StringUtils.parsePoint(_loc10_);
                     _loc12_ = new Point(0,0);
                     if(_loc7_ > 0)
                     {
                        _loc12_ = this.getUnitOffset();
                     }
                     _loc13_ = new Object();
                     _loc13_.anim = FXManager.instance.getFXAnim(_loc9_);
                     if(null != _loc13_.anim)
                     {
                        _loc13_.sound = FXManager.instance.getFXSound(_loc9_);
                        _loc13_.trigger = TRIGGERED_SOUND_MISS;
                        _loc13_.anchor = new Pt(0,0);
                        _loc13_.offset = _loc12_;
                        _loc13_.drift = _loc11_;
                        _loc13_.background = true;
                        _loc14_ = (param1.eventData.delay ? param1.eventData.delay : _loc8_.delay) * 1000;
                        if(_loc5_ == 0)
                        {
                           _loc5_ = _loc14_ + WeaponManager.instance.getHitDelay(_loc8_.id) * 400;
                        }
                        if(_loc7_ > 0 && _loc14_ != 0)
                        {
                           Zlab.processManager.schedule(_loc14_,this,this.addUnitFX,_loc13_);
                        }
                        else
                        {
                           this.addUnitFX(_loc13_);
                        }
                        if(!_loc6_)
                        {
                           _loc6_ = true;
                           if(!param2)
                           {
                              this.floatingText(_loc14_,x + this.artWidth * 0.5,y,{"text":ZGameUtils.ZlocT("Combat","Miss")});
                           }
                        }
                        if(param1.eventData.breakOut)
                        {
                           break;
                        }
                     }
                     else
                     {
                        Logger.error(this,"onUnitMiss","no FX anim found for weapon.id: " + _loc8_.id + " missFX: " + _loc9_);
                     }
                  }
                  else
                  {
                     Logger.error(this,"onUnitMiss","no miss FX found for weapon.id: " + _loc8_.id);
                  }
               }
               if(param2)
               {
                  Zlab.processManager.schedule(_loc5_,this,this.playDamageXPReward,param1.eventData);
               }
            }
         }
      }
      
      private function getUnitOffset(param1:Boolean = false) : Point
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(param1)
         {
            return new Point(this.artWidth * 0.5,this.artHeight * 0.5);
         }
         _loc2_ = this.artWidth;
         _loc3_ = MathUtils.randBetween(_loc2_ * 0.2,_loc2_ * 0.8);
         return new Point(_loc3_,_loc3_);
      }
      
      private function onUnitHit(param1:WorldEvent) : void
      {
         var _loc2_:Array = null;
         var _loc3_:BattleUnit = null;
         var _loc4_:int = 0;
         var _loc5_:Number = NaN;
         var _loc6_:Object = null;
         var _loc7_:String = null;
         var _loc8_:Number = NaN;
         var _loc9_:Point = null;
         var _loc10_:Array = null;
         var _loc11_:String = null;
         var _loc12_:Object = null;
         if(param1.eventData.glancing)
         {
            this.onUnitMiss(param1,true);
         }
         else if(param1.eventData.target == this.m_battleObject)
         {
            if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_RESEARCH_SHIELD_UPGRADE) == ExperimentsManager.VARIANT_RESEARCH_SHIELD_UPGRADE_ON && param1.eventData.target.unit.shieldHit != 0)
            {
               if(param1.eventData.attacker == null)
               {
                  if(Boolean(param1.eventData.consumable) && param1.eventData.consumableItem.di > 0)
                  {
                     this.breakShield(param1);
                  }
               }
               else
               {
                  this.breakShield(param1);
               }
            }
            _loc2_ = null;
            if(null != param1.eventData.attacker)
            {
               _loc3_ = this.getOtherUnit(param1.eventData.attacker);
               _loc2_ = param1.eventData.attacker.unitItem.getWeapons(_loc3_.m_animation,this.m_battleObject.unitItem.subType);
            }
            else if(null != param1.eventData.weapon)
            {
               _loc2_ = [param1.eventData.weapon];
            }
            if(null != _loc2_)
            {
               _loc4_ = int(_loc2_.length);
               _loc5_ = 0;
               for each(_loc6_ in _loc2_)
               {
                  _loc7_ = null;
                  if(Boolean(param1.eventData.consumableItem) && Boolean(param1.eventData.consumableItem.singleHit))
                  {
                     _loc7_ = null;
                  }
                  else if(param1.eventData.chipDamage)
                  {
                     _loc7_ = null;
                  }
                  else
                  {
                     _loc7_ = WeaponManager.instance.getHitFX(_loc6_.id,this.m_battleObject.unitItem);
                  }
                  _loc8_ = _loc6_.delay * 1000;
                  if(_loc5_ == 0)
                  {
                     _loc5_ = _loc8_ + WeaponManager.instance.getHitDelay(_loc6_.id) * 400;
                  }
                  if(_loc7_)
                  {
                     _loc9_ = new Point(0,0);
                     if(_loc4_ > 0)
                     {
                        _loc9_ = this.getUnitOffset(param1.eventData.consumable);
                     }
                     _loc10_ = _loc7_.split(",");
                     for each(_loc11_ in _loc10_)
                     {
                        _loc12_ = new Object();
                        _loc12_.anim = FXManager.instance.getFXAnim(_loc11_);
                        if(null != _loc12_.anim)
                        {
                           if(!this.m_dead)
                           {
                              _loc12_.sound = FXManager.instance.getFXSound(_loc11_);
                              _loc12_.trigger = TRIGGERED_SOUND_HIT;
                              _loc12_.anchor = new Pt(0,0);
                              _loc12_.offset = _loc9_;
                              if(_loc4_ > 0 && _loc8_ != 0)
                              {
                                 Zlab.processManager.schedule(_loc8_,this,this.addUnitFX,_loc12_);
                              }
                              else
                              {
                                 this.addUnitFX(_loc12_);
                              }
                           }
                        }
                        else
                        {
                           Logger.error(this,"onUnitHit","no FX anim found for weapon.id: " + _loc6_.id + " hitFX: " + _loc7_);
                        }
                     }
                  }
                  else
                  {
                     Logger.error(this,"onUnitHit","no hit FX found for weapon.id: " + _loc6_.id);
                  }
               }
               param1.eventData.hit = true;
               if(param1.eventData.attacker)
               {
                  param1.eventData.attackerStrength = param1.eventData.attacker.unit.strength;
               }
               Zlab.processManager.schedule(_loc5_,this,this.playDamageXPReward,param1.eventData);
            }
         }
      }
      
      private function addUnitFX(param1:Object) : void
      {
         this.addSound(param1,param1.trigger,param1.sound);
         FireAndForgetAnimation.execute2D(this,param1);
      }
      
      private function dieDelayComplete() : void
      {
         this.m_doneDie = true;
         this.tryStartDeathFX();
      }
      
      private function tryStartDeathFX() : void
      {
         if(this.m_doneDie && this.m_doneDieRewards)
         {
            this.startDeathFX();
         }
      }
      
      protected function startDeathFX() : void
      {
         TweenLite.to(this.m_bar,0.75,{"alpha":0});
         this.m_dead = true;
         this.deathFX();
         this.startRemovalTimer();
      }
      
      protected function startRemovalTimer() : void
      {
         Zlab.processManager.schedule(250,this,this.onRemove);
      }
      
      private function deathFX() : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         var _loc4_:Point = null;
         var _loc1_:String = this.m_battleObject.unitItem.getFX(UnitItem.FX_DEATH);
         if(_loc1_.length > 0)
         {
            _loc2_ = new Object();
            _loc2_.anim = FXManager.instance.getFXAnim(_loc1_);
            if(null != _loc2_.anim)
            {
               _loc3_ = ZGlobal.gameSettings.getCampaignMapDrift(GameItem.DIRECTION_NAMES[this.m_direction]);
               _loc4_ = StringUtils.parsePoint(_loc3_);
               _loc2_.sound = FXManager.instance.getFXSound(_loc1_);
               _loc2_.anchor = new Pt(0,0);
               _loc2_.offset = new Point(x + this.artWidth * 0.5,y + this.artHeight * 0.5);
               _loc2_.drift = _loc4_;
               FireAndForgetAnimation.execute2D(this.parent as Sprite,_loc2_);
            }
            else
            {
               Logger.error(this,"deathFX","no FX anim found for " + _loc1_);
            }
         }
      }
      
      private function onRemove() : void
      {
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.UNIT_REMOVED,{
            "battleObject":this.m_battleObject,
            "shake":true
         }));
      }
      
      public function addMouseEvents() : void
      {
         if(!this.m_tutorialDisabled)
         {
            this.art.addEventListener(MouseEvent.CLICK,this.onMouseClick);
            this.art.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
            this.art.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         }
      }
      
      protected function removeMouseEvents(param1:Boolean) : void
      {
         this.art.removeEventListener(MouseEvent.CLICK,this.onMouseClick);
         this.art.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         this.art.removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         if(param1)
         {
            this.doMouseOut();
         }
      }
      
      protected function onMouseClick(param1:MouseEvent) : void
      {
         if(TutorialManager.instance.active)
         {
            TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.COMBAT_UNIT_CLICK,{"code":this.battleObject.unit.code}));
         }
      }
      
      protected function onMouseOver(param1:MouseEvent) : void
      {
         this.highlight = true;
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         this.doMouseOut();
      }
      
      protected function doMouseOut() : void
      {
         this.highlight = false;
      }
      
      private function onMouseStatusOver(param1:MouseEvent) : void
      {
         this.m_mouseStatus = true;
      }
      
      private function onMouseStatusOut(param1:MouseEvent) : void
      {
         this.m_mouseStatus = false;
      }
      
      private function onRecalculateHighlight(param1:Event) : void
      {
         if(this.m_mouseStatus)
         {
            this.dispatchHighlightedEvent();
            this.highlight = true;
         }
      }
      
      private function onSequenceComplete(param1:WorldEvent) : void
      {
         this.m_soundsTriggered = 0;
      }
      
      private function onPreBattleStart(param1:Event) : void
      {
         this.classIconVisible = true;
         this.tierValueVisible = TierSurfacingManager.instance.tierSurfacingEnabled;
      }
      
      protected function get hoverColor() : int
      {
         return 0;
      }
      
      protected function get colorIndex() : int
      {
         return HOVER;
      }
      
      protected function dispatchHighlightedEvent() : void
      {
      }
      
      private function onDamageClass(param1:WorldEvent) : void
      {
         this.m_damageClass = param1.eventData as Class;
      }
      
      public function set damageClass(param1:Class) : void
      {
         this.m_damageClass = param1;
      }
      
      public function get damageClass() : Class
      {
         return this.m_damageClass;
      }
      
      private function onCommandoBonusClass(param1:WorldEvent) : void
      {
         this.m_commandoBonusClass = param1.eventData as Class;
      }
      
      private function onFlamingDamageClass(param1:WorldEvent) : void
      {
         this.m_flamingDamageClass = param1.eventData as Class;
      }
      
      private function onAttachArrow(param1:WorldEvent) : void
      {
         if(param1.eventData.codes.indexOf(this.battleObject.unit.code) >= 0)
         {
            this.m_arrow = new TutorialHighlighter();
            this.m_arrow.setArt(this.art as DisplayObjectContainer,param1.eventData.offset);
         }
      }
      
      private function onClearArrow(param1:Event) : void
      {
         if(null != this.m_arrow)
         {
            this.m_arrow.dispose();
            this.m_arrow = null;
         }
      }
      
      private function onLockSelection(param1:WorldEvent) : void
      {
         if(this.battleObject.unit.code != param1.eventData as String)
         {
            this.m_tutorialDisabled = true;
            this.removeMouseEvents(true);
         }
      }
      
      private function onUnlockSelection(param1:WorldEvent) : void
      {
         this.m_tutorialDisabled = false;
         this.addMouseEvents();
      }
      
      protected function disablePowerButton() : void
      {
         this.m_bar.power_bt.visible = false;
         this.m_bar.power_bt.mouseEnabled = false;
         this.m_bar.powerButtonIcon.visible = false;
         this.m_bar.powerButtonIcon.mouseEnabled = false;
         this.m_bar.powerButtonIcon.mouseChildren = false;
      }
      
      private function onAlwaysShowClassIcon(param1:WorldEvent) : void
      {
         if(Boolean(this.m_battleObject.fleet) && this.m_battleObject.fleet.isOwnedByPlayer(ZGlobal.player.uid))
         {
            return;
         }
         if(param1.eventData as String == "true")
         {
            this.m_alwaysShowClassIcon = true;
            this.classIconVisible = true;
         }
         else
         {
            this.m_alwaysShowClassIcon = false;
            this.classIconVisible = false;
         }
      }
      
      private function onHighlightClassIcon(param1:WorldEvent) : void
      {
         var _loc2_:Point = null;
         if(param1.eventData == this.m_battleObject.unit.code)
         {
            _loc2_ = new Point(-CLASS_ICON_X_OFFSET,CLASS_ICON_Y_OFFSET);
            this.m_tutorialClassHighlighter = new TutorialClassHighlighter();
            this.m_tutorialClassHighlighter.setDisplayObject(this.m_bar.icon,_loc2_,1,true);
         }
      }
      
      private function onClearClassIconHighlight(param1:WorldEvent) : void
      {
         if(this.m_tutorialClassHighlighter)
         {
            this.m_tutorialClassHighlighter.dispose();
            this.m_tutorialClassHighlighter = null;
         }
      }
   }
}

