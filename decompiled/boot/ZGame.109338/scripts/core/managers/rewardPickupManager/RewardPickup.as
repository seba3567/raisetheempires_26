package core.managers.rewardPickupManager
{
   import as3isolib.display.IsoView;
   import as3isolib.display.scene.IsoScene;
   import as3isolib.geom.Pt;
   import com.greensock.TweenLite;
   import com.greensock.TweenMax;
   import com.greensock.easing.Sine;
   import core.entities.components.BuildingSpatialComponent;
   import core.gamemode.GameMode;
   import core.gamemode.GameModeManager;
   import core.gamemode.GridPointer;
   import core.managers.AlliancesManager;
   import core.managers.ExperimentsManager;
   import core.ui.FloatingText;
   import core.ui.feedbacktext.FeedbackText;
   import core.ui.menuitem.PlayerStatsUIItem;
   import core.views.ViewManager;
   import core.worlds.battleWorld.BattleRendererComponent;
   import core.worlds.battleWorld.BattleWorld;
   import displays.ImageLoaderFactory;
   import events.IsoViewEvent;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.getTimer;
   import rendering.rendering2d.particles.Particle;
   import sound.SoundEvent;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   import zlabs.utils.MathUtils;
   
   public class RewardPickup extends EventDispatcher
   {
      
      private static var m_rewardLayer:Sprite;
      
      public static const FLAG_NONE:int = 0;
      
      public static const FLAG_LEFT_ONLY:int = 1 << 0;
      
      public static const FLAG_RIGHT_ONLY:int = 1 << 1;
      
      public static const FLAG_HIGH_BOUNCE:int = 1 << 2;
      
      private static var m_direction:Number = 1;
      
      private const USE_HOOBERS:int = 3;
      
      private var m_isoScene:IsoScene = null;
      
      protected var m_sprite:Sprite = null;
      
      protected var m_bitmap:Bitmap = null;
      
      private var m_type:String;
      
      private var m_destinationPos:Number = 0;
      
      private var m_time:Number = 0;
      
      protected var m_amount:int = 0;
      
      private var m_flags:int = 0;
      
      private var m_pulse:Boolean = false;
      
      private var m_startTime:Number = 0;
      
      private var m_totalTime:Number = 0;
      
      private var m_pausedTime:Number = 0;
      
      private var m_useHoobers:Boolean = false;
      
      protected var m_feedbackText:FeedbackText = null;
      
      protected var m_numOnCurveCompleteParticles:int = 5;
      
      public function RewardPickup(param1:int, param2:String, param3:Boolean)
      {
         super();
         this.m_amount = param1;
         this.m_type = param2;
         this.m_pulse = param3;
      }
      
      public function get type() : String
      {
         return this.m_type;
      }
      
      public function init2D(param1:Pt, param2:int) : void
      {
         this.init(param1,param2);
         var _loc3_:BattleRendererComponent = ViewManager.instance.getComponentFromView(BattleWorld.ID,BattleRendererComponent) as BattleRendererComponent;
         Sprite(_loc3_.displayObject).addChild(this.m_sprite);
      }
      
      public function initRewardAtGridPos(param1:Pt, param2:IsoView, param3:IsoScene) : void
      {
         GameModeManager.instance.addEventListener(IsoViewEvent.ISOVIEW_ZOOM,this.onZoom);
         param2.isoToLocal(param1);
         this.m_isoScene = param3;
         this.init(param1,FLAG_NONE);
         this.setScale(param2.currentZoom);
         this.addRewardPickupToIsoView(param2);
      }
      
      public function init3D(param1:IsoView, param2:IsoScene, param3:IEntity) : void
      {
         GameModeManager.instance.addEventListener(IsoViewEvent.ISOVIEW_ZOOM,this.onZoom);
         var _loc4_:BuildingSpatialComponent = BuildingSpatialComponent(param3.lookupComponentByType(BuildingSpatialComponent));
         var _loc5_:Pt = Pt.toPt(_loc4_.position);
         param1.isoToLocal(_loc5_);
         this.m_isoScene = param2;
         this.init(_loc5_,FLAG_NONE);
         this.setScale(param1.currentZoom);
         this.addRewardPickupToIsoView(param1);
      }
      
      protected function get scaleto60() : Boolean
      {
         return false;
      }
      
      private function addRewardPickupToIsoView(param1:IsoView, param2:Boolean = true) : void
      {
         if(param2)
         {
            if(m_rewardLayer == null)
            {
               param1.backgroundContainer;
               param1.foregroundContainer;
               m_rewardLayer = new Sprite();
               param1.mainContainer.addChild(m_rewardLayer);
            }
            m_rewardLayer.addChild(this.m_sprite);
         }
         else
         {
            param1.foregroundContainer.addChild(this.m_sprite);
         }
      }
      
      public function get currPos() : Pt
      {
         return new Pt(this.m_sprite.x,this.m_sprite.y);
      }
      
      private function init(param1:Pt, param2:int) : void
      {
         this.m_bitmap = new Bitmap();
         this.m_sprite = new Sprite();
         this.m_sprite.addChild(this.m_bitmap);
         this.m_sprite.x = param1.x;
         this.m_sprite.y = param1.y;
         this.idleLook();
         var _loc3_:int = ExperimentsManager.instance.getExperimentVariant("empire_doober_pickup");
         if(_loc3_ == this.USE_HOOBERS)
         {
            this.m_useHoobers = true;
         }
         if(!this.m_useHoobers)
         {
            this.m_sprite.addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
         }
         this.m_sprite.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         this.m_sprite.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp,false,0,true);
         Zlab.inputManager.addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove,false,5,true);
         this.m_sprite.addEventListener(MouseEvent.MOUSE_OVER,this.onOver,false,0,true);
         this.m_sprite.addEventListener(MouseEvent.MOUSE_OUT,this.onOut,false,0,true);
         PopupManager.instance.addEventListener(WindowManager.SHOW_SCREEN,this.onShowScreen,false,0,true);
         PopupManager.instance.addEventListener(WindowManager.HIDE_SCREEN,this.onHideScreen,false,0,true);
         this.m_flags = param2;
         var _loc4_:Number = this.getRandDestinationY();
         this.m_destinationPos = param1.y + _loc4_;
         ImageLoaderFactory.CreateImageLoader(this.getImageUrl(this.m_amount),null,this.onImageLoaded);
         this.doReward(this.m_amount);
      }
      
      private function hasFlag(param1:int) : Boolean
      {
         return (this.m_flags & param1) != 0;
      }
      
      private function getRandDestinationY() : Number
      {
         if(this.hasFlag(FLAG_RIGHT_ONLY))
         {
            return MathUtils.randBetween(15,20);
         }
         if(this.hasFlag(FLAG_HIGH_BOUNCE))
         {
            return MathUtils.randBetween(25,100);
         }
         return MathUtils.randBetween(25,50);
      }
      
      private function getRandY() : Number
      {
         if(this.hasFlag(FLAG_HIGH_BOUNCE))
         {
            return MathUtils.randBetween(60,120);
         }
         return MathUtils.randBetween(20,50);
      }
      
      private function getRandX() : Number
      {
         var _loc2_:Number = NaN;
         var _loc1_:Number = 40;
         if(this.hasFlag(FLAG_HIGH_BOUNCE))
         {
            _loc1_ = 190;
         }
         if(this.hasFlag(FLAG_LEFT_ONLY))
         {
            return MathUtils.randBetween(-_loc1_,0);
         }
         if(this.hasFlag(FLAG_RIGHT_ONLY))
         {
            return MathUtils.randBetween(0,_loc1_);
         }
         _loc2_ = MathUtils.randBetween(_loc1_ * 0.25,_loc1_);
         _loc2_ *= m_direction;
         m_direction *= -1;
         return _loc2_;
      }
      
      private function onImageLoaded(param1:String, param2:BitmapData) : void
      {
         var _loc3_:Number = NaN;
         if(null != this.m_bitmap)
         {
            this.m_bitmap.bitmapData = param2;
            this.m_bitmap.smoothing = true;
            if(this.scaleto60)
            {
               _loc3_ = 60 / param2.width;
               this.m_bitmap.scaleX = this.m_bitmap.scaleY = _loc3_;
            }
            this.startMovement();
         }
      }
      
      protected function startMovement() : void
      {
         this.m_time = MathUtils.randBetween(0.5,0.75);
         var _loc1_:Number = this.getRandX();
         TweenLite.to(this.m_sprite,this.m_time,{
            "x":_loc1_.toString(),
            "ease":Sine.easeInOut
         });
         var _loc2_:Number = this.getRandY();
         TweenLite.to(this.m_sprite,this.m_time * 0.5,{
            "y":(-_loc2_).toString(),
            "overwrite":false,
            "ease":Sine.easeOut
         });
         TweenLite.to(this.m_sprite,this.m_time * 0.5,{
            "y":this.m_destinationPos,
            "delay":this.m_time * 0.5,
            "overwrite":false,
            "ease":Sine.easeIn,
            "onComplete":this.onCurveComplete
         });
         var _loc3_:Number = MathUtils.randBetween(8000,10000);
         Zlab.processManager.schedule(_loc3_ - 2000,this,this.onStartTimedJiggling1);
         Zlab.processManager.schedule(_loc3_,this,this.onTimedOut);
         this.m_startTime = getTimer();
         this.m_totalTime = _loc3_;
      }
      
      private function onCurveComplete() : void
      {
         this.createParticles(this.m_numOnCurveCompleteParticles);
         TweenMax.to(this.m_sprite,0.08,{
            "scaleY":this.m_sprite.scaleX * 0.5,
            "y":(this.m_sprite.height * 0.5).toString(),
            "overwrite":false,
            "yoyo":true,
            "repeat":1
         });
      }
      
      protected function createParticles(param1:uint) : void
      {
         while(param1 > 0)
         {
            Particle.Create(new Pt(this.m_sprite.x + MathUtils.randBetween(0,this.m_sprite.width),this.m_sprite.y + MathUtils.randBetween(0,this.m_sprite.height)),this.m_sprite.parent);
            param1--;
         }
      }
      
      protected function onTimedOut() : void
      {
         var _loc1_:Point = RewardPickupManager.instance.getUIPosition(this.uiName);
         var _loc2_:Point = _loc1_;
         var _loc3_:Boolean = null != this.m_isoScene;
         if(_loc3_)
         {
            _loc2_ = this.m_isoScene.container.globalToLocal(_loc1_);
         }
         else
         {
            _loc2_ = this.m_sprite.parent.globalToLocal(_loc1_);
         }
         TweenLite.killTweensOf(this.m_sprite);
         TweenLite.to(this.m_sprite,0.4,{
            "x":_loc2_.x,
            "overwrite":false,
            "onComplete":this.removeFromWorld
         });
         TweenLite.to(this.m_sprite,0.4,{
            "y":_loc2_.y,
            "overwrite":false,
            "ease":Sine.easeIn
         });
      }
      
      private function addFloatingText() : void
      {
         var _loc1_:Boolean = null != this.m_isoScene;
         var _loc2_:FloatingText = new FloatingText(this.m_sprite.parent);
         _loc2_.useWorldZoom = _loc1_;
         _loc2_.position = new Pt(this.m_sprite.x,this.m_sprite.y);
         _loc2_.disposeOnComplete = true;
         _loc2_.color = this.m_feedbackText.color;
         _loc2_.scale = _loc1_ ? RewardPickupManager.instance.floatingTextSizeMultiplier3D : RewardPickupManager.instance.floatingTextSizeMultiplier2D;
         _loc2_.text = this.m_amount > 0 ? ZGameUtils.ZlocT("Main","PositiveFeedback",{"feedback":this.m_feedbackText.friendlyName}) : ZGameUtils.ZlocT("Main","NegativeFeedback",{"feedback":this.m_feedbackText.friendlyName});
      }
      
      protected function jiggle(param1:Number, param2:Number) : void
      {
         TweenMax.killTweensOf(this.m_bitmap);
         var _loc3_:Number = -(param2 - 1);
         var _loc4_:int = this.m_bitmap.width * (_loc3_ * 0.5);
         var _loc5_:int = this.m_bitmap.height * (_loc3_ * 0.5);
         TweenMax.to(this.m_bitmap,param1,{
            "x":_loc4_.toString(),
            "y":_loc5_.toString(),
            "scaleX":param2,
            "scaleY":param2,
            "ease":Sine.easeInOut,
            "yoyo":true,
            "repeat":-1
         });
      }
      
      private function onStartTimedJiggling1() : void
      {
         this.jiggle(0.4,1.1);
         Zlab.processManager.schedule(1000,this,this.onStartTimedJiggling2);
      }
      
      protected function onStartTimedJiggling2() : void
      {
         this.jiggle(0.1,1.2);
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         this.idleLook();
         this.onStopPropagation(param1);
      }
      
      private function onMouseUp(param1:MouseEvent) : void
      {
         GameModeManager.instance.getTopGameMode().focusLost();
         this.onStopPropagation(param1);
      }
      
      private function onStopPropagation(param1:MouseEvent) : void
      {
         param1.stopImmediatePropagation();
         param1.stopPropagation();
      }
      
      protected function onClick(param1:MouseEvent) : void
      {
         this.m_sprite.removeEventListener(MouseEvent.CLICK,this.onClick);
         this.onStopPropagation(param1);
         this.doDooberPickup();
      }
      
      protected function doDooberPickup() : void
      {
         var _loc1_:GameMode = GameModeManager.instance.getTopGameMode();
         this.removeFromScheduler();
         this.onTimedOut();
         this.addFloatingText();
         if(_loc1_.createParticlesOnLootPickup || this.alwaysCreateParticlesOnLootPickup)
         {
            this.createParticles(this.particleCount);
         }
         var _loc2_:String = this.soundEvent;
         if(null != _loc2_)
         {
            SoundEvent.getSoundEvent(_loc2_).play();
         }
         _loc1_.updatePointer();
         GridPointer.instance.update();
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).streakBonus.incProgress(this.m_amount);
      }
      
      private function onMouseMove(param1:MouseEvent) : void
      {
         if(this.m_sprite.hitTestPoint(Zlab.mainStage.mouseX,Zlab.mainStage.mouseY))
         {
            this.onStopPropagation(param1);
         }
      }
      
      protected function onOver(param1:MouseEvent) : void
      {
         this.m_sprite.filters = [ZGameUtils.LootFilter,ZGameUtils.LootShadowFilter,ZGameUtils.HighlightFilter];
         GameModeManager.instance.getTopGameMode().deselect();
         GridPointer.instance.hide = true;
         if(this.m_useHoobers)
         {
            this.m_sprite.removeEventListener(MouseEvent.MOUSE_OVER,this.onOver);
            this.doDooberPickup();
         }
      }
      
      private function onOut(param1:MouseEvent) : void
      {
         this.idleLook();
         GridPointer.instance.hide = false;
         GameModeManager.instance.getTopGameMode().updatePointer();
      }
      
      private function idleLook() : void
      {
         this.m_sprite.filters = [ZGameUtils.LootFilter,ZGameUtils.LootShadowFilter];
      }
      
      protected function removeFromWorld() : void
      {
         this.dispose();
         dispatchEvent(new WorldEvent(Event.REMOVED,this));
      }
      
      protected function removeFromScheduler() : void
      {
         Zlab.processManager.removeScheduledObject(this);
      }
      
      public function dispose() : void
      {
         TweenLite.killTweensOf(this.m_sprite);
         TweenMax.killTweensOf(this.m_sprite);
         TweenMax.killTweensOf(this.m_bitmap);
         this.removeFromScheduler();
         GameModeManager.instance.removeEventListener(IsoViewEvent.ISOVIEW_ZOOM,this.onZoom);
         this.m_sprite.removeEventListener(MouseEvent.CLICK,this.onClick);
         this.m_sprite.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         this.m_sprite.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         Zlab.inputManager.removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
         this.m_sprite.removeEventListener(MouseEvent.MOUSE_OVER,this.onOver);
         this.m_sprite.removeEventListener(MouseEvent.MOUSE_OUT,this.onOut);
         PopupManager.instance.removeEventListener(WindowManager.SHOW_SCREEN,this.onShowScreen);
         PopupManager.instance.removeEventListener(WindowManager.HIDE_SCREEN,this.onHideScreen);
         this.m_sprite.filters = [];
         this.m_sprite.parent.removeChild(this.m_sprite);
         this.m_sprite = null;
         this.m_bitmap = null;
         this.m_isoScene = null;
      }
      
      protected function doReward(param1:int) : void
      {
      }
      
      protected function getImageUrl(param1:int) : String
      {
         return null;
      }
      
      protected function get uiName() : String
      {
         return null;
      }
      
      public function get pickupName() : String
      {
         return null;
      }
      
      protected function get soundEvent() : String
      {
         return null;
      }
      
      protected function get particleCount() : int
      {
         return 2;
      }
      
      protected function get alwaysCreateParticlesOnLootPickup() : Boolean
      {
         return false;
      }
      
      private function onZoom(param1:IsoViewEvent) : void
      {
         this.setScale(param1.value);
      }
      
      private function setScale(param1:Number) : void
      {
         if(param1 < 0.5)
         {
            param1 *= 1 + (0.5 - param1) / 0.25 * 1;
         }
         this.m_sprite.scaleX = this.m_sprite.scaleY = 1 / param1;
      }
      
      private function onShowScreen(param1:Event) : void
      {
         if(!(AlliancesManager.instance.isAllianceBattleEnabled() && AlliancesManager.instance.allianceBattle))
         {
            Zlab.processManager.removeScheduledObject(this);
            this.m_pausedTime = getTimer();
         }
      }
      
      private function onHideScreen(param1:Event) : void
      {
         var _loc2_:Number = this.m_totalTime - (this.m_pausedTime - this.m_startTime);
         var _loc3_:Number = _loc2_ < 2000 ? 2000 : _loc2_;
         Zlab.processManager.schedule(_loc3_ - 2000,this,this.onStartTimedJiggling1);
         Zlab.processManager.schedule(_loc2_,this,this.onTimedOut);
      }
   }
}

