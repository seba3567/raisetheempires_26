package core.entities.components
{
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateMachine;
   import core.entities.components.utils.YieldHelper;
   import core.managers.PVPManager;
   import core.managers.decorationsManager.DecorationsManager;
   import core.player.IPVPPlayer;
   import core.player.Player;
   import core.ui.components.PortraitSlidePick.PortraitSlidePick;
   import core.ui.components.PortraitSlidePick.PortraitSlidePickPVP;
   import core.ui.components.PortraitSlidePick.PortraitSlidePickPVPAlreadyDefended;
   import core.ui.components.PortraitSlidePick.PortraitSlidePickPVPDecoBuildableDefenseRepel;
   import core.ui.components.PortraitSlidePick.PortraitSlidePickPVPDefenseTowerRepel;
   import core.ui.components.PortraitSlidePick.PortraitSlidePickPVPFriendDefend;
   import core.ui.components.PortraitSlidePick.PortraitSlidePickPVPFriendRepel;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import flash.events.Event;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.entity.PropertyReference;
   import zlabs.events.WorldEvent;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   import zlabs.resource.SWFResource;
   
   public class PVPOccupationMarkerHomeComponent extends PVPOccupationMarkerComponent
   {
      
      private var m_pick:PortraitSlidePickPVP;
      
      private var m_repelPick:PortraitSlidePickPVP;
      
      private var m_defender:Player;
      
      private var m_invader:Object;
      
      private var m_removed:Boolean;
      
      public function PVPOccupationMarkerHomeComponent(param1:Object, param2:IPVPPlayer, param3:Player = null)
      {
         super(param2);
         this.m_defender = param3;
         this.m_invader = param1;
         var _loc4_:String = "assets/displays/screens/Pvp_PicksAndMisc.swf";
         var _loc5_:String = ZGlobal.getAssetURL(_loc4_);
         if(Zlab.resourceManager.validUrl(_loc5_))
         {
            Zlab.resourceManager.load(_loc5_,SWFResource,this.onLoadComplete,this.onLoadFail);
         }
      }
      
      private function onLoadComplete(param1:SWFResource) : void
      {
         var _loc3_:Class = null;
         var _loc6_:Class = null;
         var _loc7_:Pt = null;
         if(this.m_removed)
         {
            return;
         }
         var _loc2_:IsoViewComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
         if(ZGlobal.isHome())
         {
            if(this.m_invader.gp)
            {
               _loc3_ = param1.getAssetClass("strangerPick_menu_mc");
            }
            else
            {
               _loc3_ = param1.getAssetClass("invaderPick_menu_mc");
            }
            this.m_pick = new PortraitSlidePickPVP(owner,pickPlayer,_loc2_.isoView.currentZoom,_loc3_,this.m_invader);
         }
         else if(this.m_invader.dID)
         {
            _loc3_ = param1.getAssetClass("ThirdPartyPick_menu_mc");
            this.m_pick = new PortraitSlidePickPVPAlreadyDefended(owner,pickPlayer,_loc2_.isoView.currentZoom,_loc3_,this.m_invader);
         }
         else
         {
            if(this.m_invader.gp)
            {
               _loc3_ = param1.getAssetClass("strangerPick_menu_mc");
            }
            else
            {
               _loc3_ = param1.getAssetClass("ThirdPartyPick_menu_mc");
            }
            this.m_pick = new PortraitSlidePickPVPFriendDefend(owner,pickPlayer,_loc2_.isoView.currentZoom,_loc3_,this.m_invader);
         }
         var _loc4_:BuildingSpatialComponent = BuildingSpatialComponent(owner.lookupComponentByType(BuildingSpatialComponent));
         var _loc5_:Pt = Pt.toPt(_loc4_.position);
         _loc2_.isoView.isoToLocal(_loc5_);
         if(this.m_defender)
         {
            _loc6_ = param1.getAssetClass("defenderPick_menu_mc");
            if(this.m_defender.uid == PVPManager.DEFENSE_TOWER_FAKE_USER_ID.toString())
            {
               this.m_repelPick = new PortraitSlidePickPVPDefenseTowerRepel(owner,this.m_defender,pickPlayer,_loc2_.isoView.currentZoom,_loc6_,this.m_invader);
            }
            else if(this.m_defender.uid == PVPManager.DECO_BUILDABLE_FAKE_USER_ID.toString())
            {
               this.m_repelPick = new PortraitSlidePickPVPDecoBuildableDefenseRepel(owner,this.m_defender,pickPlayer,_loc2_.isoView.currentZoom,_loc6_,this.m_invader);
            }
            else
            {
               this.m_repelPick = new PortraitSlidePickPVPFriendRepel(owner,this.m_defender,pickPlayer,_loc2_.isoView.currentZoom,_loc6_,this.m_invader);
            }
            _loc7_ = new Pt(_loc5_.x + 150,_loc5_.y,_loc5_.z);
            this.m_repelPick.position = _loc7_;
            _loc2_.isoView.foregroundContainer.addChild(this.m_repelPick.mc);
            this.m_repelPick.addEventListener(PortraitSlidePick.PICK_ENTERED,this.onRepelPickEntered,false,0,true);
            this.m_pick.ignoreMouseInput();
         }
         this.m_pick.position = _loc5_;
         _loc2_.isoView.foregroundContainer.addChild(this.m_pick.mc);
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
         var _loc2_:String = String(param1.eventData.invaderID);
         if(Boolean(this.m_defender) && _loc2_ == this.m_defender.uid)
         {
            this.disposeFriendRepelPick();
         }
      }
      
      private function onInvasionRepelHandled(param1:WorldEvent) : void
      {
         var _loc3_:XML = null;
         var _loc4_:PropertyReference = null;
         var _loc5_:BehaviorStateMachine = null;
         var _loc6_:Number = NaN;
         var _loc7_:YieldHelper = null;
         var _loc2_:String = String(param1.eventData.invaderID);
         if(_loc2_ == pickPlayer.uid)
         {
            _loc3_ = ZGlobal.gameSettings.getPVPReward("manualDefend");
            if(_loc3_)
            {
               _loc4_ = new PropertyReference("@StateMachine.stateMachine");
               _loc5_ = owner.getProperty(_loc4_) as BehaviorStateMachine;
               _loc6_ = PVPManager.instance.AccelerationPillageMultiplier();
               _loc6_ = _loc6_ + DecorationsManager.instance.getRepelMultiplier();
               _loc6_ = _loc6_ - 1;
               _loc7_ = new YieldHelper();
               _loc7_.initFromData(_loc3_,_loc6_);
               _loc7_.execute(_loc5_,_loc3_);
            }
            param1.stopPropagation();
            param1.stopImmediatePropagation();
         }
      }
      
      private function disposeFriendRepelPick() : void
      {
         if(this.m_repelPick)
         {
            this.m_repelPick.removeEventListener(PortraitSlidePick.PICK_ENTERED,this.onRepelPickEntered);
            this.m_repelPick.dispose();
            this.m_repelPick = null;
         }
      }
      
      protected function onLoadFail(param1:SWFResource) : void
      {
         Logger.print(this,"Failed to load image \'" + param1.filename + "\'");
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         isoOutlineRectSize = PVPManager.getInvasionAreaFromInvader(this.m_invader);
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
         this.disposeFriendRepelPick();
         PVPManager.instance.removeEventListener(PVPManager.REMOVE_MARKER,this.removeFriendRepelPick);
         PVPManager.instance.removeEventListener(PVPManager.INVASION_REPEL_HANDLED,this.onInvasionRepelHandled);
      }
   }
}

