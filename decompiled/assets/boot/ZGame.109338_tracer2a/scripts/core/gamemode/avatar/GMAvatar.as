package core.gamemode.avatar
{
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.entities.components.BuildingFSMComponent;
   import core.entities.components.behaviors.states.BehaviorState;
   import core.gamemode.GMDefault;
   import core.gamemode.GridPointer;
   import core.gamemode.MoveGridPing;
   import core.gamemode.island.GMIsland;
   import core.managers.WorldObjectManager;
   import core.managers.visitorManager.VisitorManager;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import core.worlds.islandworld.components.Island;
   import core.worlds.islandworld.components.IslandMapComponent;
   import dispatchers.MessageDispatcher;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import utils.TileUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.entity.IEntity;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.WindowManager;
   
   public class GMAvatar extends GMIsland
   {
      
      private var m_ping:MoveGridPing = null;
      
      public function GMAvatar()
      {
         super();
      }
      
      override public function enableMode() : void
      {
         super.enableMode();
         this.m_ping = new MoveGridPing();
         GridPointer.instance.addAttachment(this.m_ping);
      }
      
      override public function disableMode() : void
      {
         if(m_enabled)
         {
            super.disableMode();
            GridPointer.instance.removeAttachments();
            this.m_ping.dispose();
            this.m_ping = null;
            MessageDispatcher.instance.removeEventListener(MessageDispatcher.VISITOR_HELP_UPDATE,this.onVisitorHelpUpdate);
         }
      }
      
      override protected function canBeSelected(param1:IEntity) : Boolean
      {
         var _loc2_:BuildingFSMComponent = BuildingFSMComponent(param1.lookupComponentByType(BuildingFSMComponent));
         if(_loc2_)
         {
            return BehaviorState(_loc2_.stateMachine.getCurrentState()).canBeSelected();
         }
         return super.canBeSelected(param1);
      }
      
      override protected function doHandleClick(param1:MouseEvent) : void
      {
         var _loc7_:AvatarComponent = null;
         var _loc8_:Boolean = false;
         var _loc9_:String = null;
         var _loc10_:GenericPopup = null;
         if(ZGlobal.stencilActive)
         {
            super.doHandleClick(param1);
            return;
         }
         var _loc2_:Point = new Point(Zlab.mainStage.mouseX,Zlab.mainStage.mouseY);
         var _loc3_:Pt = screenToIso(new Pt(_loc2_.x,_loc2_.y,0));
         var _loc4_:IslandMapComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,IslandMapComponent) as IslandMapComponent;
         var _loc5_:Point = TileUtil.worldPointToTilePoint(_loc3_,true);
         var _loc6_:Island = _loc4_.getIslandByPoint(_loc5_.x,_loc5_.y);
         if(m_highlightedObject)
         {
            if(!_loc6_)
            {
               _loc6_ = _loc4_.getIslandByPoint(_loc5_.x,_loc5_.y,false);
            }
            _loc8_ = !ZGlobal.seenPVPActionPenalty && this.doesTargetActionHavePVPPenalty(m_highlightedObject);
            if(_loc8_)
            {
               _loc9_ = ZGameUtils.ZlocT("Dialogs","PVPPenaltyFirstUseWarning");
               _loc10_ = GenericPopup2B.NewAcceptCancel(_loc9_,null,this.onPVPWarningClose);
               _loc10_.userData = {
                  "targetName":m_highlightedObject.name,
                  "event":param1,
                  "island":_loc6_
               };
               WindowManager.instance.push(_loc10_);
               ZGlobal.seenPVPActionPenalty = true;
            }
            else
            {
               this.handleClick_Helper(m_highlightedObject,param1,_loc6_);
            }
         }
         else
         {
            validateExpansion(_loc2_.x,_loc2_.y);
            if(_loc6_)
            {
               WorldObjectManager.instance.dispatchEvent(new WorldEvent(WorldObjectManager.GROUND_SELECTED));
               _loc7_ = _loc6_.avatar;
               if(null != _loc7_)
               {
                  _loc7_.setDestination(_loc3_);
               }
            }
         }
      }
      
      override protected function onDoEnteredMode(param1:Object) : void
      {
         super.onDoEnteredMode(param1);
         MessageDispatcher.instance.addEventListener(MessageDispatcher.VISITOR_HELP_UPDATE,this.onVisitorHelpUpdate,false,1,true);
      }
      
      private function getTargetCurrentState(param1:IEntity) : BehaviorState
      {
         var _loc2_:BuildingFSMComponent = BuildingFSMComponent(param1.lookupComponentByType(BuildingFSMComponent));
         if(_loc2_)
         {
            return BehaviorState(_loc2_.stateMachine.getCurrentState());
         }
         return null;
      }
      
      private function doesTargetActionHavePVPPenalty(param1:IEntity) : Boolean
      {
         var _loc2_:BehaviorState = this.getTargetCurrentState(param1);
         if(_loc2_)
         {
            return _loc2_.actionSuffersPVPPenalty();
         }
         return false;
      }
      
      private function doesTargetNeedAvatar(param1:IEntity) : Boolean
      {
         var _loc2_:BehaviorState = this.getTargetCurrentState(param1);
         if(_loc2_)
         {
            return _loc2_.needsAvatar();
         }
         return false;
      }
      
      private function handleClick_Helper(param1:IEntity, param2:MouseEvent, param3:Island) : void
      {
         var _loc5_:AvatarComponent = null;
         var _loc4_:Boolean = this.doesTargetNeedAvatar(param1);
         if(!_loc4_ || GMDefault.isUnitOwnedByPlayer(param1))
         {
            super.doHandleClick(param2);
         }
         else if(_loc4_)
         {
            if(param3)
            {
               _loc5_ = param3.avatar;
               if(null != _loc5_)
               {
                  _loc5_.setTarget(param1);
               }
            }
            else
            {
               super.doHandleClick(param2);
            }
         }
      }
      
      private function onPVPWarningClose(param1:GenericPopupEvent) : void
      {
         var _loc2_:IEntity = null;
         if(param1.button == GenericPopup.ACCEPT)
         {
            _loc2_ = Zlab.nameManager.lookup(param1.userData.targetName);
            if(_loc2_)
            {
               this.handleClick_Helper(_loc2_,param1.userData.event,param1.userData.island);
            }
         }
      }
      
      private function onVisitorHelpUpdate(param1:WorldEvent) : void
      {
         var _loc2_:String = param1.eventData.helper;
         var _loc3_:int = int(param1.eventData.objid);
         VisitorManager.instance.spawnAvatarInstant(_loc2_,_loc3_);
         VisitorManager.instance.newTendActionFeedback(_loc2_,_loc3_);
         param1.stopImmediatePropagation();
      }
   }
}

