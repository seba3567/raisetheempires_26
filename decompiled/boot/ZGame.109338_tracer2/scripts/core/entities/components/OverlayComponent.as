package core.entities.components
{
   import Engine.Helpers.Vector2;
   import com.greensock.TweenMax;
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateMachine;
   import core.gamemode.GameModeManager;
   import core.gameobjects.GameItem;
   import core.managers.DebugManager;
   import core.managers.WorldResourceManager;
   import core.managers.assetLoadTracker.AssetLoadTracker;
   import core.managers.mayhemManager.MayhemManager;
   import core.managers.visitorManager.VisitorManager;
   import core.resource.WorldResource;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import entity.EntityInit;
   import entity.GameDataComponent;
   import events.IsoViewEvent;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.entity.EntityComponent;
   import zlabs.entity.PropertyReference;
   import zlabs.events.WorldEvent;
   import zlabs.rendering.renderingISO.IsoSpatialComponent;
   import zlabs.rendering.renderingISO.IsoSpriteRenderer;
   import zlabs.resource.Resource;
   import zlabs.resource.SWFResource;
   import zlabs.utils.MathUtils;
   import zlabs.utils.StringUtils;
   
   public class OverlayComponent extends EntityComponent
   {
      
      private static const iconScale:Point = new Point(42,42);
      
      protected var m_overlayData:XML = null;
      
      protected var m_sprite:Sprite = new Sprite();
      
      protected var m_iconName:String = null;
      
      protected var m_backgroundName:String = null;
      
      protected var m_currentResource:SWFResource = null;
      
      private var m_overlayBitmap:Bitmap = null;
      
      private var m_scale:Number = 1;
      
      protected var imageDimensionsProperty:PropertyReference = new PropertyReference("@Image.dimensions");
      
      private var m_assetTracker:AssetLoadTracker = null;
      
      protected var m_iconLoader:ImageLoader;
      
      protected var m_swfResource:Resource;
      
      public function OverlayComponent(param1:EntityInit)
      {
         super();
         UIDispatcher.instance.addEventListener(DebugManager.DEBUG_OVERLAYS,this.onDebugOverlays,false,0,true);
         UIDispatcher.instance.addEventListener(ZGlobal.LOW_QUALITY_MODE,this.onLowQualityToggle,false,0,true);
         if(param1.m_assetLoadTracker)
         {
            this.m_assetTracker = param1.m_assetLoadTracker;
            this.m_assetTracker.addEventListener(Event.COMPLETE,this.onAssetLoadComplete);
         }
      }
      
      protected function getIconName(param1:XML) : String
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:Dictionary = null;
         var _loc5_:WorldResource = null;
         if(ZGlobal.visitMode == ZGlobal.MODE_VISIT)
         {
            _loc2_ = this.getBackgroundName();
            if(Boolean(_loc2_) && _loc2_.length > 0)
            {
               _loc3_ = this.m_overlayData.@visitorHelpType.toString();
               if(VisitorManager.isValidHelpType(_loc3_))
               {
                  if(null != param1)
                  {
                     _loc4_ = WorldResourceManager.instance.findResourceTypesInXML(param1,ZGlobal.hostPlayer.rareResourceType);
                     for each(_loc5_ in _loc4_)
                     {
                        if(_loc5_.visitIcon != null)
                        {
                           return _loc5_.visitIcon;
                        }
                     }
                  }
                  return VisitorManager.getOverlayIcon(_loc3_);
               }
            }
         }
         return this.m_overlayData.@icon.toString();
      }
      
      protected function getBackgroundName() : String
      {
         return this.m_overlayData.@background.toString();
      }
      
      protected function centerOverlay() : Boolean
      {
         return this.m_overlayData.@centerOverlay != undefined;
      }
      
      protected function getBackgroundOffset() : String
      {
         return this.m_overlayData.@backgroundOffset.toString();
      }
      
      protected function getIconOffset() : String
      {
         return this.m_overlayData.@iconOffset.toString();
      }
      
      protected function shouldNotScaleIcon() : Boolean
      {
         return this.m_overlayData.@noScaleIcon != undefined;
      }
      
      protected function getVisitIconAlwaysVisible() : Boolean
      {
         var _loc1_:Boolean = false;
         if(this.m_overlayData)
         {
            _loc1_ = this.m_overlayData.@visitIconAlwaysVisible.toString().toLowerCase() == "true" || this.m_overlayData.@visitIconAlwaysVisible.toString() == "1";
         }
         return _loc1_;
      }
      
      private function getReferenceRare() : String
      {
         return this.m_overlayData.@referenceRare.toString();
      }
      
      public function set iconName(param1:String) : void
      {
         this.m_iconName = param1;
         this.m_backgroundName = this.getBackgroundName();
         this.loadImagePackage();
      }
      
      public function set overlayData(param1:Object) : void
      {
         this.m_overlayData = param1 ? param1.xml : null;
         if(this.m_overlayData == null)
         {
            this.clearOverlay();
            return;
         }
         if(!DebugManager.instance.overlaysActive)
         {
            return;
         }
         var _loc2_:int = parseInt(this.getReferenceRare());
         this.m_iconName = this.getIconName(param1.checkData);
         this.m_backgroundName = this.getBackgroundName();
         if(_loc2_ == 0 && this.m_iconName.length <= 0)
         {
            this.clearOverlay();
            return;
         }
         if(_loc2_ == 1 > 0 || this.m_iconName.length > 0)
         {
            this.loadImagePackage();
         }
         if(_loc2_ > 1)
         {
            this.loadImagePackage();
         }
      }
      
      private function loadImagePackage() : void
      {
         this.loadSwf(ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf"));
      }
      
      public function loadSwf(param1:String) : void
      {
         this.m_swfResource = Zlab.resourceManager.load(param1,SWFResource,this.onSWFLoaded,this.onSWFFailed);
      }
      
      public function updateIconName(param1:WorldEvent) : void
      {
         var _loc2_:GameDataComponent = null;
         var _loc3_:GameItem = null;
         if(!ZGlobal.isVisiting() && MayhemManager.instance.isParliamentDestroyed)
         {
            _loc2_ = GameDataComponent(owner.lookupComponentByType(GameDataComponent));
            _loc3_ = _loc2_.gameData;
            if(Boolean(_loc3_) && (_loc3_.subType == "residential" || _loc3_.subType == "civic"))
            {
               if(this.m_iconName == "assets/game/GeneralAssetGroup_UI.swf/Coins_42.png")
               {
                  this.m_iconName = "assets/game/GeneralAssetGroup_UI.swf/CoinBroken_42.png";
               }
            }
         }
         if(Boolean(param1) && Boolean(param1.eventData.mayhem))
         {
            this.loadIcon();
         }
      }
      
      protected function onSWFLoaded(param1:SWFResource) : void
      {
         var _loc2_:Class = null;
         this.m_currentResource = param1;
         this.checkRareReference();
         if(Boolean(this.m_iconName) && this.m_iconName.length > 0)
         {
            _loc2_ = param1.getAssetClass(this.m_iconName);
            this.updateIconName(null);
            MayhemManager.instance.addEventListener(UIControllerComponent.EVENT_TOOLTIP_UPDATE,this.updateIconName);
            if(_loc2_)
            {
               this.setIcon(new _loc2_(1,1) as BitmapData);
            }
            else
            {
               this.loadIcon();
            }
         }
      }
      
      protected function checkRareReference() : void
      {
         var _loc1_:int = 0;
         var _loc2_:BuildingFSMComponent = null;
         var _loc3_:BehaviorStateMachine = null;
         if(this.m_overlayData)
         {
            _loc1_ = parseInt(this.getReferenceRare());
            if(_loc1_ == 1)
            {
               this.m_iconName = WorldResourceManager.instance.getResourceImageName(ZGlobal.hostPlayer.rareResourceType);
            }
            if(_loc1_ > 1)
            {
               _loc2_ = BuildingFSMComponent(owner.lookupComponentByType(BuildingFSMComponent));
               _loc3_ = _loc2_.stateMachine as BehaviorStateMachine;
               this.m_iconName = WorldResourceManager.instance.getResourceImageName(WorldResourceManager.instance.getResourceIndexFromType(_loc3_.resourceType));
            }
         }
      }
      
      protected function loadIcon() : void
      {
         this.m_iconLoader = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(this.m_iconName),null,this.onIconLoadComplete);
      }
      
      protected function onIconLoadComplete(param1:String, param2:BitmapData) : void
      {
         if(param1.indexOf(this.m_iconName) >= 0)
         {
            this.setIcon(param2);
         }
      }
      
      private function setIcon(param1:BitmapData) : void
      {
         var _loc3_:Point = null;
         var _loc4_:BitmapData = null;
         var _loc6_:Class = null;
         var _loc7_:Bitmap = null;
         var _loc8_:Point = null;
         if(this.m_swfResource == null)
         {
            return;
         }
         if(null == this.m_overlayData)
         {
            return;
         }
         this.clearOverlay();
         if(Boolean(owner) && this.centerOverlay())
         {
            owner.eventDispatcher.addEventListener(IsoSpriteRenderer.IMAGE_UPDATED,this.onMainImageUpdated,false,0,true);
         }
         this.m_overlayBitmap = new Bitmap();
         var _loc2_:Sprite = new Sprite();
         _loc3_ = this.getOffset(this.getBackgroundOffset());
         if(Boolean(this.m_backgroundName) && this.m_backgroundName.length > 0)
         {
            _loc6_ = this.m_currentResource.getAssetClass(this.m_backgroundName);
            _loc4_ = new _loc6_(1,1) as BitmapData;
         }
         if(_loc4_ != null)
         {
            _loc2_.addChild(new Bitmap(_loc4_));
         }
         if(param1)
         {
            _loc7_ = new Bitmap(param1);
            _loc2_.addChild(_loc7_);
            if(!this.shouldNotScaleIcon())
            {
               _loc7_.width = iconScale.x;
               _loc7_.height = iconScale.y;
            }
            _loc8_ = this.getOffset(this.getIconOffset());
            _loc7_.x = _loc8_.x;
            _loc7_.y = _loc8_.y;
         }
         var _loc5_:BitmapData = new BitmapData(_loc2_.width,_loc2_.height,true,16777215);
         _loc5_.draw(_loc2_);
         this.m_overlayBitmap.bitmapData = _loc5_;
         if(this.centerOverlay())
         {
            this.centerOffset();
         }
         else
         {
            this.m_overlayBitmap.x = _loc3_.x;
            this.m_overlayBitmap.y = _loc3_.y;
         }
         this.m_sprite.addChild(this.m_overlayBitmap);
         this.m_sprite.scaleX = this.m_sprite.scaleY = this.m_scale;
         this.tryAddDrift();
      }
      
      protected function getOffset(param1:String) : Point
      {
         if(Boolean(param1) && param1.length > 0)
         {
            return StringUtils.parsePoint(param1);
         }
         return new Point(0,0);
      }
      
      private function onMainImageUpdated(param1:Event) : void
      {
         this.centerOffset();
      }
      
      private function centerOffset() : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Point = null;
         var _loc1_:Vector2 = owner.getProperty(this.imageDimensionsProperty);
         if(_loc1_)
         {
            _loc2_ = _loc1_.x;
            _loc3_ = _loc1_.y;
            _loc4_ = new Point(_loc2_ / 2 - this.m_overlayBitmap.width / 2,_loc3_ / 2 - this.m_overlayBitmap.height);
            this.m_overlayBitmap.x = _loc4_.x;
            this.m_overlayBitmap.y = _loc4_.y;
         }
      }
      
      private function clearBitmap() : void
      {
         if(this.m_overlayBitmap != null && this.m_sprite.contains(this.m_overlayBitmap))
         {
            this.m_sprite.removeChild(this.m_overlayBitmap);
         }
         this.m_overlayBitmap = null;
      }
      
      public function clearOverlay() : void
      {
         this.clearBitmap();
         this.killDrift();
      }
      
      private function onDebugOverlays(param1:WorldEvent) : void
      {
         if(!DebugManager.instance.overlaysActive)
         {
            if(this.m_overlayData != null)
            {
               this.overlayData = null;
            }
         }
      }
      
      private function onLowQualityToggle(param1:WorldEvent) : void
      {
         if(ZGlobal.lowQualityMode)
         {
            this.killDrift();
         }
         else
         {
            this.tryAddDrift();
         }
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         GameModeManager.instance.addEventListener(IsoViewEvent.ISOVIEW_ZOOM,this.onZoom);
         owner.eventDispatcher.addEventListener(IsoSpatialComponent.ACTIVE_DISPLAY,this.onActiveDisplay);
         owner.eventDispatcher.addEventListener(IsoSpatialComponent.INACTIVE_NON_DISPLAY,this.onNonActiveDisplay);
      }
      
      override protected function onRemove() : void
      {
         UIDispatcher.instance.removeEventListener(DebugManager.DEBUG_OVERLAYS,this.onDebugOverlays);
         UIDispatcher.instance.removeEventListener(ZGlobal.LOW_QUALITY_MODE,this.onLowQualityToggle);
         GameModeManager.instance.removeEventListener(IsoViewEvent.ISOVIEW_ZOOM,this.onZoom);
         owner.eventDispatcher.removeEventListener(IsoSpatialComponent.ACTIVE_DISPLAY,this.onActiveDisplay);
         owner.eventDispatcher.removeEventListener(IsoSpatialComponent.INACTIVE_NON_DISPLAY,this.onNonActiveDisplay);
         MayhemManager.instance.removeEventListener(UIControllerComponent.EVENT_TOOLTIP_UPDATE,this.updateIconName);
         if(this.m_assetTracker)
         {
            this.m_assetTracker.removeEventListener(Event.COMPLETE,this.onAssetLoadComplete);
            this.m_assetTracker = null;
         }
         if(Boolean(this.m_overlayData) && this.centerOverlay())
         {
            owner.eventDispatcher.removeEventListener(IsoSpriteRenderer.IMAGE_UPDATED,this.onMainImageUpdated);
         }
         this.clearOverlay();
         this.m_swfResource = null;
         this.m_currentResource = null;
         super.onRemove();
      }
      
      protected function onSWFFailed(param1:SWFResource) : void
      {
         Logger.error(this,"OverlayComponent:onSWFFailed","Failed to load \'" + (param1 ? param1.filename : "(unknown)") + "\'");
      }
      
      public function get sprite() : Sprite
      {
         return this.m_sprite;
      }
      
      private function onActiveDisplay(param1:Event) : void
      {
         this.tryAddDrift();
      }
      
      private function onNonActiveDisplay(param1:Event) : void
      {
         this.killDrift();
      }
      
      private function onZoom(param1:IsoViewEvent) : void
      {
         var _loc2_:Number = param1.value;
         this.m_sprite.visible = _loc2_ > 0.25 || this.shouldAlwaysBeVisible();
      }
      
      protected function shouldAlwaysBeVisible() : Boolean
      {
         var _loc1_:Boolean = false;
         if(ZGlobal.isVisiting() && this.getVisitIconAlwaysVisible())
         {
            _loc1_ = true;
         }
         return _loc1_;
      }
      
      private function tryAddDrift() : void
      {
         var _loc1_:Number = NaN;
         if(null == this.m_assetTracker && !ZGlobal.lowQualityMode)
         {
            if(null != this.m_overlayBitmap)
            {
               this.m_sprite.y = 0;
               _loc1_ = MathUtils.randBetween(0.75,0.9);
               TweenMax.to(this.m_sprite,_loc1_,{
                  "y":"-10",
                  "yoyo":true,
                  "repeat":-1
               });
            }
         }
      }
      
      private function killDrift() : void
      {
         TweenMax.killTweensOf(this.m_sprite);
      }
      
      private function onAssetLoadComplete(param1:Event) : void
      {
         this.m_assetTracker.removeEventListener(Event.COMPLETE,this.onAssetLoadComplete);
         this.m_assetTracker = null;
         this.tryAddDrift();
      }
      
      public function setIconPath(param1:String) : void
      {
         this.m_iconName = param1;
         this.loadImagePackage();
         this.loadIcon();
      }
   }
}

