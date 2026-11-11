package core.entities.components
{
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.gamemode.GMSell;
   import core.managers.PVPManager;
   import core.player.IPVPPlayer;
   import core.ui.components.PortraitSlidePick.PortraitPick;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.events.WorldEvent;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   import zlabs.resource.SWFResource;
   
   public class PVPOccupationMarkerPickOnlyComponent extends PVPOccupationMarkerComponent
   {
      
      protected var m_pick:PortraitPick;
      
      private var m_pickDisposed:Boolean;
      
      public function PVPOccupationMarkerPickOnlyComponent(param1:IPVPPlayer)
      {
         super(param1);
      }
      
      protected function attemptLoadPick() : void
      {
         if(this.shouldLoadPick())
         {
            this.loadPick();
         }
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         this.attemptLoadPick();
         PVPManager.instance.addEventListener(PVPManager.REMOVE_MARKER,this.onRemoveMarker,false,0,true);
      }
      
      protected function shouldLoadPick() : Boolean
      {
         return true;
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         this.disposePick();
         PVPManager.instance.removeEventListener(PVPManager.REMOVE_MARKER,this.onRemoveMarker);
      }
      
      protected function get assetClassString() : String
      {
         return "invasionToken_mc";
      }
      
      protected function get initialPickPortrait() : String
      {
         return null;
      }
      
      protected function onPickLoadComplete(param1:SWFResource) : void
      {
         var _loc2_:IsoViewComponent = null;
         var _loc3_:Class = null;
         var _loc4_:BuildingSpatialComponent = null;
         var _loc5_:Pt = null;
         if(!this.m_pick && !this.m_pickDisposed)
         {
            _loc2_ = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
            _loc3_ = param1.getAssetClass(this.assetClassString);
            this.m_pick = new PortraitPick(owner,pickPlayer,_loc3_,this.initialPickPortrait);
            _loc4_ = BuildingSpatialComponent(owner.lookupComponentByType(BuildingSpatialComponent));
            _loc5_ = Pt.toPt(_loc4_.position);
            _loc2_.isoView.isoToLocal(_loc5_);
            this.m_pick.position = _loc5_;
            _loc2_.isoView.foregroundContainer.addChild(this.m_pick.mc);
         }
      }
      
      private function loadPick() : void
      {
         var _loc1_:String = "assets/displays/screens/Pvp_PicksAndMisc.swf";
         var _loc2_:String = ZGlobal.getAssetURL(_loc1_);
         if(Zlab.resourceManager.validUrl(_loc2_))
         {
            Zlab.resourceManager.load(_loc2_,SWFResource,this.onPickLoadComplete,this.onPickLoadFail);
         }
      }
      
      protected function disposePick() : void
      {
         this.m_pickDisposed = true;
         if(this.m_pick)
         {
            this.m_pick.dispose();
            this.m_pick = null;
         }
      }
      
      protected function onPickLoadFail(param1:SWFResource) : void
      {
         Logger.print(this,"Failed to load image \'" + param1.filename + "\'");
      }
      
      private function onRemoveMarker(param1:WorldEvent) : void
      {
         if(pickPlayer.uid == String(param1.eventData.invaderID))
         {
            if(this.m_pick)
            {
               this.m_pick.startDissolve();
            }
            else
            {
               GMSell.clearObject(owner,true);
            }
            PVPManager.instance.removeEventListener(PVPManager.REMOVE_MARKER,this.onRemoveMarker);
         }
      }
   }
}

