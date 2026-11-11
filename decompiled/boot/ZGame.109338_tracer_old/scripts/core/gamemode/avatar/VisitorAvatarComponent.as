package core.gamemode.avatar
{
   import Engine.Events.TransactionEvent;
   import Engine.Managers.TransactionManager;
   import as3isolib.display.IsoView;
   import as3isolib.geom.Pt;
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.entities.components.BuildingSpatialComponent;
   import core.entities.components.UnitFSMComponent;
   import core.entities.components.behaviors.BehaviorStateMachine;
   import core.entities.components.behaviors.states.BehaviorState;
   import core.entities.components.states.FSMComponent;
   import core.entities.components.utils.YieldHelper;
   import core.gameobjects.GameItem;
   import core.managers.visitorManager.VisitorManager;
   import core.managers.visitorManager.VisitorManagerOrder;
   import core.player.Player;
   import core.ui.components.PortraitSlidePick.PortraitSlidePick;
   import core.ui.components.PortraitSlidePick.PortraitSlidePickTending;
   import dispatchers.MessageDispatcher;
   import flash.events.Event;
   import flash.utils.Dictionary;
   import transactions.TMove;
   import transactions.TVisitorAccept;
   import zlabs.Zlab;
   import zlabs.entity.EntityComponent;
   import zlabs.entity.IEntity;
   import zlabs.entity.PropertyReference;
   import zlabs.events.WorldEvent;
   import zlabs.rendering.renderingISO.IsoSpriteComponent;
   import zlabs.utils.MathUtils;
   
   public class VisitorAvatarComponent extends EntityComponent
   {
      
      private static var AVATAR_FADEOUT_TIME:Number = 500;
      
      private var m_order:VisitorManagerOrder = null;
      
      private var m_visitorPlayer:Player = null;
      
      private var m_pick:PortraitSlidePickTending = null;
      
      private var m_view:IsoView = null;
      
      private var m_currentTarget:int = 0;
      
      private var m_accepted:Boolean;
      
      private var m_blockedHelpUpdates:Array = new Array();
      
      public function VisitorAvatarComponent(param1:Player, param2:GameItem, param3:IsoView, param4:VisitorManagerOrder)
      {
         super();
         this.m_order = param4;
         this.m_visitorPlayer = param1;
         this.m_view = param3;
         TransactionManager.getInstance().addEventListener(TransactionEvent.ADDED,this.onTransactionAdded,false,0,true);
      }
      
      public function get currentTargetId() : int
      {
         var _loc1_:Array = this.m_order.targets;
         var _loc2_:int = this.m_currentTarget;
         if(this.m_currentTarget >= 0 && this.m_currentTarget < _loc1_.length)
         {
            return _loc1_[_loc2_];
         }
         return -1;
      }
      
      public function get currentTarget() : IEntity
      {
         return ZGlobal.game.getObjectByID(this.currentTargetId);
      }
      
      public function onHelpNewTarget(param1:Number) : void
      {
         this.m_pick.actionFeedback(param1);
      }
      
      public function endHelp() : void
      {
         this.startFadeOut();
      }
      
      public function onTargetHelpStateEnded() : Boolean
      {
         var _loc1_:IEntity = null;
         var _loc2_:Pt = null;
         var _loc3_:UnitFSMComponent = null;
         this.performHelpAction();
         while(this.canAdvanceTarget())
         {
            ++this.m_currentTarget;
            _loc1_ = this.currentTarget;
            if(_loc1_)
            {
               _loc2_ = this.m_order.getTargetIndexPos(this.m_currentTarget);
               _loc3_ = owner.lookupComponentByType(UnitFSMComponent) as UnitFSMComponent;
               if(_loc3_)
               {
                  _loc3_.targetPosition = MathUtils.tileToWorld(_loc2_.x,_loc2_.y,_loc2_.z,ZGlobal.cellSize);
               }
               return true;
            }
         }
         return false;
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         this.createMovieClip();
         owner.eventDispatcher.addEventListener(IsoSpriteComponent.UPDATE_SPRITE,this.onUpdate,false,0,true);
         MessageDispatcher.instance.addEventListener(MessageDispatcher.VISITOR_HELP_UPDATE,this.onVisitorHelpUpdate,false,2,true);
      }
      
      override protected function onRemove() : void
      {
         var _loc1_:Dictionary = null;
         super.onRemove();
         TransactionManager.getInstance().removeEventListener(TransactionEvent.ADDED,this.onTransactionAdded);
         this.removeHelperUpdatedListener();
         if(this.m_blockedHelpUpdates.length)
         {
            _loc1_ = new Dictionary();
            _loc1_[this.m_visitorPlayer.uid] = this.m_blockedHelpUpdates;
            VisitorManager.instance.storeNonHomeIslandHelpUpdates(_loc1_);
         }
         this.m_pick.dispose();
         this.m_pick = null;
      }
      
      protected function onUpdate(param1:Event) : void
      {
         this.updatePosition();
      }
      
      private function removeHelperUpdatedListener() : void
      {
         MessageDispatcher.instance.removeEventListener(MessageDispatcher.VISITOR_HELP_UPDATE,this.onVisitorHelpUpdate);
      }
      
      private function updatePosition() : void
      {
         var _loc1_:BuildingSpatialComponent = BuildingSpatialComponent(owner.lookupComponentByType(BuildingSpatialComponent));
         var _loc2_:Pt = Pt.toPt(_loc1_.position);
         this.m_view.isoToLocal(_loc2_);
         this.m_pick.position = _loc2_;
      }
      
      private function createMovieClip() : void
      {
         this.m_pick = new PortraitSlidePickTending(this.m_visitorPlayer,this.m_view.currentZoom);
         this.m_pick.addEventListener(PortraitSlidePick.ACCEPTED,this.onAccept,false,0,true);
         this.m_pick.addEventListener(PortraitSlidePick.REJECTED,this.onReject,false,0,true);
         this.m_pick.addEventListener(PortraitSlidePick.PICK_ENTERED,this.onPickEntered,false,0,true);
         this.m_pick.addEventListener(PortraitSlidePick.PICK_EXITED,this.onPickExited,false,0,true);
         this.updatePosition();
         this.m_view.foregroundContainer.addChild(this.m_pick.mc);
      }
      
      private function onPickEntered(param1:Event) : void
      {
         this.highlightTargets(true,false,true);
      }
      
      private function onPickExited(param1:Event) : void
      {
         this.highlightTargets(false,false,true);
      }
      
      private function onAccept(param1:Event) : void
      {
         this.highlightTargets(true,true,false);
         var _loc2_:FSMComponent = owner.lookupComponentByType(FSMComponent) as FSMComponent;
         if(_loc2_)
         {
            _loc2_.stateMachine.setCurrentState("1");
         }
         TransactionManager.getInstance().removeEventListener(TransactionEvent.ADDED,this.onTransactionAdded);
         TransactionManager.addTransaction(new TVisitorAccept(String(this.m_visitorPlayer.uid)));
         this.m_pick.ignoreMouseInput();
         this.m_accepted = true;
      }
      
      private function onReject(param1:Event) : void
      {
         VisitorManager.instance.rejectTending(String(this.m_visitorPlayer.uid),this.m_order.targets);
         TransactionManager.getInstance().removeEventListener(TransactionEvent.ADDED,this.onTransactionAdded);
         this.startFadeOut();
      }
      
      private function canAdvanceTarget() : Boolean
      {
         return this.m_currentTarget + 1 < this.m_order.targets.length;
      }
      
      private function startFadeOut() : void
      {
         this.removeHelperUpdatedListener();
         Zlab.processManager.schedule(AVATAR_FADEOUT_TIME,this,this.onFadeoutEnded);
         TweenLite.to(this.m_pick.mc,AVATAR_FADEOUT_TIME * 0.001,{"alpha":0});
      }
      
      private function onFadeoutEnded() : void
      {
         var _loc1_:WorldEvent = new WorldEvent(VisitorManager.VISITOR_HELPER_DONE,{
            "id":this.m_visitorPlayer.uid,
            "blockedTargets":this.m_blockedHelpUpdates
         });
         this.m_blockedHelpUpdates = new Array();
         VisitorManager.instance.dispatchEvent(_loc1_);
      }
      
      private function getEntityStateMachine(param1:IEntity) : BehaviorStateMachine
      {
         var _loc2_:FSMComponent = null;
         if(param1 != null)
         {
            _loc2_ = param1.lookupComponentByType(FSMComponent) as FSMComponent;
            if(_loc2_)
            {
               return _loc2_.stateMachine as BehaviorStateMachine;
            }
         }
         return null;
      }
      
      private function getEntityCurrentState(param1:IEntity) : BehaviorState
      {
         var _loc2_:BehaviorStateMachine = this.getEntityStateMachine(param1);
         if(_loc2_)
         {
            return _loc2_.currentState as BehaviorState;
         }
         return null;
      }
      
      private function performHelpAction() : void
      {
         if(this.currentTarget)
         {
            this.currentTarget.eventDispatcher.dispatchEvent(new WorldEvent(VisitorManager.VISITOR_TARGET_HIGHLIGHT,{
               "enable":false,
               "actionLock":true,
               "mouseHoverLock":false
            }));
         }
         var _loc1_:BehaviorStateMachine = this.getEntityStateMachine(this.currentTarget);
         if(Boolean(_loc1_) && _loc1_.canRedeemHelp())
         {
            VisitorManager.instance.dispatchEvent(new WorldEvent(VisitorManager.VISITOR_TARGET_HELPED,{"id":this.currentTargetId}));
            this.performHelpAcceptReward(_loc1_);
            _loc1_.performHelpRedeemRequest(this.currentTarget,String(this.m_visitorPlayer.uid));
         }
         else
         {
            VisitorManager.instance.helpedInvalidTendTarget(this.m_visitorPlayer.uid,this.currentTargetId);
         }
      }
      
      private function performHelpAcceptReward(param1:BehaviorStateMachine) : void
      {
         var _loc8_:YieldHelper = null;
         var _loc2_:Boolean = true;
         var _loc3_:BehaviorState = param1.currentState as BehaviorState;
         var _loc4_:PropertyReference = new PropertyReference("@Data.gameData");
         var _loc5_:GameItem = param1.propertyBag.getProperty(_loc4_,null) as GameItem;
         var _loc6_:String = VisitorManager.getVisitorRewardLabel(owner,_loc5_,_loc3_.visitorHelpType,_loc2_);
         var _loc7_:XML = VisitorManager.getRewardXML(_loc6_);
         if(_loc7_)
         {
            _loc8_ = new YieldHelper();
            _loc8_.initFromData(_loc7_);
            _loc8_.execute(param1,_loc7_);
         }
      }
      
      private function onTransactionAdded(param1:TransactionEvent) : void
      {
         var _loc2_:TMove = null;
         var _loc3_:BuildingSpatialComponent = null;
         var _loc4_:Pt = null;
         if(param1.transaction is TMove)
         {
            _loc2_ = param1.transaction as TMove;
            if(_loc2_.entity == this.currentTarget)
            {
               _loc3_ = this.currentTarget.lookupComponentByType(BuildingSpatialComponent) as BuildingSpatialComponent;
               if(_loc3_)
               {
                  _loc4_ = Pt.toPt(_loc3_.position);
                  this.m_view.isoToLocal(_loc4_);
                  this.m_pick.position = _loc4_;
               }
            }
         }
      }
      
      private function highlightTargets(param1:Boolean, param2:Boolean, param3:Boolean) : void
      {
         var _loc5_:IEntity = null;
         var _loc4_:int = 0;
         while(_loc4_ < this.m_order.targets.length)
         {
            _loc5_ = ZGlobal.game.getObjectByID(this.m_order.targets[_loc4_]);
            if(_loc5_)
            {
               _loc5_.eventDispatcher.dispatchEvent(new WorldEvent(VisitorManager.VISITOR_TARGET_HIGHLIGHT,{
                  "enable":param1,
                  "actionLock":param2,
                  "mouseHoverLock":param3
               }));
            }
            _loc4_++;
         }
      }
      
      private function onVisitorHelpUpdate(param1:WorldEvent) : void
      {
         var _loc2_:IEntity = null;
         if(param1.eventData.helper == this.m_visitorPlayer.uid)
         {
            if(this.m_accepted)
            {
               this.m_blockedHelpUpdates.push(param1.eventData.objid);
            }
            else
            {
               _loc2_ = ZGlobal.game.getObjectByID(param1.eventData.objid);
               if(_loc2_)
               {
                  VisitorManager.instance.addHelpedObject(param1.eventData.helper,param1.eventData.objid);
                  this.m_order.targets.push(param1.eventData.objid);
               }
            }
            VisitorManager.instance.newTendActionFeedback(param1.eventData.helper,param1.eventData.objid);
            param1.stopImmediatePropagation();
         }
      }
   }
}

