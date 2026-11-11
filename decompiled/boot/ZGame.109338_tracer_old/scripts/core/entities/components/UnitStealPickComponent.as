package core.entities.components
{
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import zlabs.Zlab;
   import zlabs.entity.EntityComponent;
   import zlabs.entity.IEntity;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   import zlabs.resource.SWFResource;
   
   public class UnitStealPickComponent extends EntityComponent
   {
      
      private var m_pick:UnitStealPick = null;
      
      private var m_removed:Boolean;
      
      private var m_iEntity:IEntity = null;
      
      public function UnitStealPickComponent(param1:IEntity)
      {
         super();
         this.m_iEntity = param1;
      }
      
      public function onLoadComplete(param1:SWFResource) : void
      {
         var _loc3_:Class = null;
         var _loc4_:BuildingSpatialComponent = null;
         var _loc5_:Pt = null;
         if(this.m_removed)
         {
            return;
         }
         var _loc2_:IsoViewComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
         _loc3_ = param1.getAssetClass("espionagePick_menu_mc");
         this.m_pick = new UnitStealPick(_loc2_.isoView.currentZoom,_loc3_,this.m_iEntity);
         if(owner != null)
         {
            _loc4_ = BuildingSpatialComponent(owner.lookupComponentByType(BuildingSpatialComponent));
            if(_loc4_)
            {
               _loc5_ = Pt.toPt(_loc4_.position);
               _loc2_.isoView.isoToLocal(_loc5_);
               this.m_pick.position = _loc5_;
               _loc2_.isoView.foregroundContainer.addChild(this.m_pick.mc);
            }
         }
      }
      
      public function onLoadFail(param1:SWFResource) : void
      {
      }
      
      override protected function onAdd() : void
      {
         var _loc1_:String = "assets/displays/screens/Pvp_PicksAndMisc.swf";
         var _loc2_:String = ZGlobal.getAssetURL(_loc1_);
         if(Zlab.resourceManager.validUrl(_loc2_))
         {
            Zlab.resourceManager.load(_loc2_,SWFResource,this.onLoadComplete,this.onLoadFail);
         }
      }
      
      override protected function onRemove() : void
      {
         this.m_removed = true;
         if(this.m_pick)
         {
            this.m_pick.dispose();
            this.m_pick = null;
         }
      }
   }
}

