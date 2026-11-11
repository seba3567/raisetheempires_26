package core.ui.components.PortraitSlidePick
{
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.entities.components.BuildingSpatialComponent;
   import core.gamemode.GMSell;
   import core.gamemode.GameModeManager;
   import core.player.IPVPPlayer;
   import core.ui.PickManager;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import displays.ImageLoaderFactory;
   import events.IsoViewEvent;
   import fl.containers.UILoader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import sound.SoundEvent;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.rendering.renderingISO.IsoSpriteComponent;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   
   public class PortraitPick extends EventDispatcher
   {
      
      private var m_owner:IEntity;
      
      private var m_pick:MovieClip;
      
      private var m_neighbor:IPVPPlayer;
      
      private var m_dissolveHelper:PortraitPickDissolveHelperAlpha;
      
      public function PortraitPick(param1:IEntity, param2:IPVPPlayer, param3:Class, param4:String = null)
      {
         super();
         this.m_owner = param1;
         this.m_neighbor = param2;
         this.createPickAsset(param3,param4);
         param1.eventDispatcher.addEventListener(IsoSpriteComponent.UPDATE_SPRITE,this.onUpdateSprite,false,0,true);
      }
      
      public function dispose() : void
      {
         GameModeManager.instance.removeEventListener(IsoViewEvent.ISOVIEW_ZOOM,this.onZoom);
         this.m_pick.removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         this.m_owner.eventDispatcher.removeEventListener(IsoSpriteComponent.UPDATE_SPRITE,this.onUpdateSprite);
         if(this.m_pick)
         {
            if(this.m_pick.parent)
            {
               this.m_pick.parent.removeChild(this.m_pick);
            }
            this.m_pick = null;
         }
         if(this.m_dissolveHelper)
         {
            this.m_dissolveHelper.removeEventListener(PortraitPickDissolveHelper.DONE,this.onDissolveDone);
            this.m_dissolveHelper.dispose();
            this.m_dissolveHelper = null;
         }
         PickManager.instance.removeEventListener(PickManager.PICKS_ACTIVE_UPDATED,this.onPicksActiveUpdated);
      }
      
      public function get mc() : MovieClip
      {
         return this.m_pick;
      }
      
      public function set position(param1:Pt) : void
      {
         this.m_pick.x = param1.x;
         this.m_pick.y = param1.y + this.yOffset;
      }
      
      public function startDissolve() : void
      {
         SoundEvent.getSoundEvent("InvasionDefeat").play();
         this.m_dissolveHelper = new PortraitPickDissolveHelperAlpha(this.m_pick);
         this.m_dissolveHelper.addEventListener(PortraitPickDissolveHelper.DONE,this.onDissolveDone,false,0,true);
      }
      
      public function overridePortrait(param1:String) : void
      {
         if(!param1)
         {
            param1 = this.neighborPortrait;
         }
         ImageLoaderFactory.CreateImageLoader(param1,this.portraitUILoader);
      }
      
      public function updatePosition() : void
      {
         var _loc1_:BuildingSpatialComponent = BuildingSpatialComponent(this.m_owner.lookupComponentByType(BuildingSpatialComponent));
         var _loc2_:Pt = Pt.toPt(_loc1_.position);
         var _loc3_:IsoViewComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
         _loc3_.isoView.isoToLocal(_loc2_);
         this.position = _loc2_;
      }
      
      private function setPickZoom(param1:Number) : void
      {
         var _loc2_:Number = 1 / param1;
         this.m_pick.scaleX = this.m_pick.scaleY = _loc2_;
      }
      
      protected function get yOffset() : int
      {
         return -60;
      }
      
      protected function get portraitUILoader() : UILoader
      {
         if(Boolean(this.m_pick.player) && Boolean(this.m_pick.player.portrait_mc))
         {
            return this.m_pick.player.portrait_mc;
         }
         if(this.m_pick.portrait_mc)
         {
            return this.m_pick.portrait_mc;
         }
         return null;
      }
      
      private function createPickAsset(param1:Class, param2:String) : void
      {
         this.m_pick = new param1();
         if(Boolean(this.m_pick.player) && Boolean(this.m_pick.player.mindControlSwirl_mc))
         {
            this.m_pick.player.mindControlSwirl_mc.visible = false;
         }
         var _loc3_:IsoViewComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
         this.setPickZoom(_loc3_.isoView.currentZoom);
         var _loc4_:String = param2 ? param2 : this.neighborPortrait;
         ImageLoaderFactory.CreateImageLoader(_loc4_,this.portraitUILoader);
         GameModeManager.instance.addEventListener(IsoViewEvent.ISOVIEW_ZOOM,this.onZoom,false,0,true);
         this.m_pick.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver,false,0,true);
         PickManager.instance.addEventListener(PickManager.PICKS_ACTIVE_UPDATED,this.onPicksActiveUpdated,false,0,true);
      }
      
      private function get neighborPortrait() : String
      {
         return this.m_neighbor ? this.m_neighbor.portraitURL : ZGlobal.getAssetURL(ZGameUtils.NoProfileImageUrl);
      }
      
      private function onZoom(param1:IsoViewEvent) : void
      {
         this.setPickZoom(param1.value);
      }
      
      private function onRollOver(param1:MouseEvent) : void
      {
         this.bringToFront();
      }
      
      public function bringToFront() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(Boolean(this.m_pick) && Boolean(this.m_pick.parent))
         {
            _loc1_ = this.m_pick.parent.numChildren;
            if(_loc1_ > 1)
            {
               _loc2_ = _loc1_ - 1;
               this.m_pick.parent.setChildIndex(this.m_pick,_loc2_);
            }
         }
      }
      
      private function onDissolveDone(param1:Event) : void
      {
         GMSell.clearObject(this.m_owner,true);
      }
      
      private function onPicksActiveUpdated(param1:Event = null) : void
      {
         if(PickManager.enabled)
         {
            this.mc.mouseEnabled = true;
            this.mc.mouseChildren = true;
            this.mc.alpha = 1;
         }
         else
         {
            this.mc.mouseEnabled = false;
            this.mc.mouseChildren = false;
            this.mc.alpha = 0.15;
         }
      }
      
      private function onUpdateSprite(param1:Event = null) : void
      {
         this.updatePosition();
      }
   }
}

