package core.entities.components
{
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateMachine;
   import core.entities.components.utils.YieldHelper;
   import core.managers.PVPManager;
   import core.player.PlayerDummy;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import entity.GameDataComponent;
   import flash.events.Event;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.entity.PropertyReference;
   import zlabs.events.WorldEvent;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   import zlabs.resource.SWFResource;
   
   public class MysteryUnitMarkerComponent extends PVPOccupationMarkerComponent
   {
      
      private var m_pick:MysteryUnitPick;
      
      private var m_repelPick:MysteryUnitPick;
      
      private var m_removed:Boolean;
      
      private var m_gdc:GameDataComponent;
      
      private var isRare:Boolean;
      
      public function MysteryUnitMarkerComponent(param1:GameDataComponent = null, param2:Boolean = false)
      {
         this.m_gdc = param1;
         this.isRare = param2;
         super(new PlayerDummy("-1"));
         var _loc3_:String = "assets/displays/screens/Pvp_PicksAndMisc.swf";
         var _loc4_:String = ZGlobal.getAssetURL(_loc3_);
         if(Zlab.resourceManager.validUrl(_loc4_))
         {
            Zlab.resourceManager.load(_loc4_,SWFResource,this.onLoadComplete,this.onLoadFail);
         }
      }
      
      private function onLoadComplete(param1:SWFResource) : void
      {
         var _loc3_:Class = null;
         var _loc4_:BuildingSpatialComponent = null;
         var _loc5_:Pt = null;
         if(this.m_removed)
         {
            return;
         }
         var _loc2_:IsoViewComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
         if(ZGlobal.isHome())
         {
            _loc3_ = param1.getAssetClass("mysteryPick_menu_mc");
            this.m_pick = new MysteryUnitPick(pickPlayer,_loc2_.isoView.currentZoom,_loc3_,this.m_gdc,this.isRare);
         }
         if(owner != null)
         {
            _loc4_ = BuildingSpatialComponent(owner.lookupComponentByType(BuildingSpatialComponent));
            _loc5_ = Pt.toPt(_loc4_.position);
            _loc2_.isoView.isoToLocal(_loc5_);
            this.m_pick.position = _loc5_;
            _loc2_.isoView.foregroundContainer.addChild(this.m_pick.mc);
         }
      }
      
      private function onRepelPickEntered(param1:Event) : void
      {
         if(this.m_pick)
         {
            this.m_pick.bringToFront();
         }
      }
      
      private function removeFriendRepelPick(param1:WorldEvent) : void
      {
      }
      
      private function onInvasionRepelHandled(param1:WorldEvent) : void
      {
         var _loc3_:XML = null;
         var _loc4_:PropertyReference = null;
         var _loc5_:BehaviorStateMachine = null;
         var _loc6_:YieldHelper = null;
         var _loc2_:String = String(param1.eventData.invaderID);
         if(_loc2_ == pickPlayer.uid)
         {
            _loc3_ = ZGlobal.gameSettings.getPVPReward("manualDefend");
            if(_loc3_)
            {
               _loc4_ = new PropertyReference("@StateMachine.stateMachine");
               _loc5_ = owner.getProperty(_loc4_) as BehaviorStateMachine;
               _loc6_ = new YieldHelper();
               _loc6_.initFromData(_loc3_);
               _loc6_.execute(_loc5_,_loc3_);
            }
            param1.stopPropagation();
            param1.stopImmediatePropagation();
         }
      }
      
      protected function onLoadFail(param1:SWFResource) : void
      {
         Logger.print(this,"Failed to load image \'" + param1.filename + "\'");
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         PVPManager.instance.addEventListener(PVPManager.REMOVE_MARKER,this.removeFriendRepelPick,false,0,true);
         PVPManager.instance.addEventListener(PVPManager.INVASION_REPEL_HANDLED,this.onInvasionRepelHandled,false,0,true);
      }
      
      override protected function onRemove() : void
      {
         this.m_removed = true;
         super.onRemove();
         if(this.m_pick)
         {
            this.m_pick.dispose();
            this.m_pick = null;
         }
         PVPManager.instance.removeEventListener(PVPManager.REMOVE_MARKER,this.removeFriendRepelPick);
         PVPManager.instance.removeEventListener(PVPManager.INVASION_REPEL_HANDLED,this.onInvasionRepelHandled);
      }
   }
}

