package core.entities.components
{
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import flash.events.Event;
   import zlabs.Zlab;
   import zlabs.entity.EntityComponent;
   import zlabs.rendering.renderingISO.IsoSpriteComponent;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   import zlabs.resource.SWFResource;
   
   public class ParliamentPickComponentUpgrade extends EntityComponent
   {
      
      private var m_pick:ParliamentPickUpgrade = null;
      
      private var m_removed:Boolean;
      
      private var m_init:Boolean;
      
      public function ParliamentPickComponentUpgrade(param1:Boolean = true)
      {
         this.m_init = param1;
         super();
      }
      
      override protected function onAdd() : void
      {
         var _loc1_:String = "assets/displays/screens/parliament_shuck_upgrade.swf";
         var _loc2_:String = ZGlobal.getAssetURL(_loc1_);
         if(Zlab.resourceManager.validUrl(_loc2_))
         {
            Zlab.resourceManager.load(_loc2_,SWFResource,this.onLoadComplete,this.onLoadFail);
         }
         owner.eventDispatcher.addEventListener(IsoSpriteComponent.UPDATE_SPRITE,this.onBuildingMove);
      }
      
      override protected function onRemove() : void
      {
         this.m_removed = true;
         if(this.m_pick)
         {
            this.m_pick.dispose();
            this.m_pick = null;
         }
         owner.eventDispatcher.removeEventListener(IsoSpriteComponent.UPDATE_SPRITE,this.onBuildingMove);
      }
      
      public function onLoadComplete(param1:SWFResource) : void
      {
         var _loc2_:Class = null;
         var _loc3_:IsoViewComponent = null;
         if(this.m_removed)
         {
            return;
         }
         if(ZGlobal.isHome())
         {
            _loc3_ = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
            _loc2_ = param1.getAssetClass("ThirdPartyPick_menu_mc");
            this.m_pick = new ParliamentPickUpgrade(_loc3_.isoView.currentZoom,_loc2_,this.m_init);
            _loc3_.isoView.foregroundContainer.addChild(this.m_pick.mc);
            this.RepositionPick();
         }
      }
      
      private function RepositionPick() : void
      {
         if(owner == null || this.m_pick == null)
         {
            return;
         }
         var _loc1_:BuildingSpatialComponent = BuildingSpatialComponent(owner.lookupComponentByType(BuildingSpatialComponent));
         if(_loc1_ == null)
         {
            return;
         }
         var _loc2_:IsoViewComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
         var _loc3_:Pt = Pt.toPt(_loc1_.position);
         _loc2_.isoView.isoToLocal(_loc3_);
         this.m_pick.position = _loc3_;
      }
      
      public function onBuildingMove(param1:Event) : void
      {
         this.RepositionPick();
      }
      
      public function onLoadFail(param1:SWFResource) : void
      {
      }
      
      public function addAgain() : void
      {
         this.m_removed = false;
      }
   }
}

