package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.states.IMachine;
   import core.gameobjects.CrewTemplateWrapper;
   import core.gameobjects.GameItem;
   import core.managers.CrewManager;
   import core.managers.visitorManager.VisitorManager;
   import core.player.Player;
   import core.ui.components.PortraitSlidePick.PortraitPick;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import displays.popups.SpeechPopup;
   import displays.screens.CrewGatherOwnerPartial;
   import displays.screens.CrewResizablePopUp;
   import entity.GameDataComponent;
   import events.ProgressBarEvent;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import zgame.assets.ui.NeighborPickBubble;
   import zlabs.displays.popups.PopUpBase;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   
   public class CrewDialogState extends SimpleClickState
   {
      
      protected static var m_window:PopUpBase;
      
      protected var m_crewInfo:Array;
      
      protected var m_wrapper:CrewTemplateWrapper;
      
      protected var m_item:GameItem;
      
      private var m_autoFilledCrewPick:PortraitPick;
      
      public function CrewDialogState(param1:BehaviorStateInit, param2:Boolean = false)
      {
         super(param1);
         this.m_item = param1.m_gameItem;
         var _loc3_:String = this.m_item.getCrewTemplateName(param2);
         var _loc4_:Boolean = param1.m_gameObject == null ? false : (param1.m_gameObject.state == param1.m_stateData.@stateName ? true : false);
         this.m_wrapper = _loc3_ ? ZGlobal.gameSettings.getCrewTemplateWrapper(_loc3_) : null;
         this.m_crewInfo = param1.m_gameObject ? param1.m_gameObject.crewInfo : null;
         if(!this.m_crewInfo)
         {
            this.m_crewInfo = new Array();
         }
         if(_loc4_)
         {
            this.addEmptySlots();
         }
      }
      
      protected function addEmptySlots() : void
      {
         while(this.m_crewInfo.length < this.m_wrapper.numPositions)
         {
            this.m_crewInfo.push(null);
         }
      }
      
      override protected function performEnterActions() : void
      {
         super.performEnterActions();
         if(ZGlobal.isHome() && VisitorManager.instance.wasBuildingAutoFilled(owner))
         {
            this.createAutoFillPick(owner);
         }
         owner.eventDispatcher.addEventListener(GameDataComponent.CREW_UPDATED,this.onCrewUpdated);
         CrewManager.instance.addEventListener(CrewManager.PURCHASED_CREW_SLOT_FULL,this.onPurchasedSlotFull,false,0,true);
         stateMachine.propertyBag.eventDispatcher.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         stateMachine.propertyBag.eventDispatcher.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
      }
      
      override public function stop() : void
      {
         super.stop();
         this.disposePick();
      }
      
      override protected function performExitActions(param1:IMachine) : void
      {
         super.performExitActions(param1);
         this.disposePick();
      }
      
      protected function onPurchasedSlotFull(param1:WorldEvent) : void
      {
         var _loc3_:GameDataComponent = null;
         var _loc2_:IEntity = stateMachine.propertyBag as IEntity;
         if(_loc2_)
         {
            _loc3_ = GameDataComponent.getGameDataComponent(_loc2_);
            if(Boolean(_loc3_) && _loc3_.id == param1.eventData.objid)
            {
               this.m_crewInfo = param1.eventData.crew;
            }
         }
      }
      
      private function disposePick() : void
      {
         if(this.m_autoFilledCrewPick)
         {
            this.m_autoFilledCrewPick.mc.removeEventListener(MouseEvent.CLICK,this.onPickClick);
            this.m_autoFilledCrewPick.mc.removeEventListener(MouseEvent.MOUSE_UP,this.stopEventPropagation);
            this.m_autoFilledCrewPick.dispose();
            this.m_autoFilledCrewPick = null;
         }
      }
      
      override protected function removeListeners() : void
      {
         super.removeListeners();
         owner.eventDispatcher.removeEventListener(GameDataComponent.CREW_UPDATED,this.onCrewUpdated);
         CrewManager.instance.removeEventListener(CrewManager.PURCHASED_CREW_SLOT_FULL,this.onPurchasedSlotFull);
         stateMachine.propertyBag.eventDispatcher.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         stateMachine.propertyBag.eventDispatcher.removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
      }
      
      override public function needsAvatar() : Boolean
      {
         return false;
      }
      
      override public function onClick(param1:Event) : void
      {
         if(this.m_autoFilledCrewPick)
         {
            param1.stopImmediatePropagation();
         }
         else
         {
            this.showCrewDialog();
         }
      }
      
      protected function showCrewDialog() : void
      {
         if(this.m_wrapper)
         {
            m_window = this.createPopup(stateMachine.propertyBag as IEntity);
            m_window.addEventListener(CrewResizablePopUp.BUILT,this.onBuy,false,0,true);
            m_window.addEventListener(CrewResizablePopUp.CLOSED,this.onClosed,false,0,true);
            WindowManager.instance.push(m_window);
         }
      }
      
      protected function createPopup(param1:IEntity) : PopUpBase
      {
         return new CrewGatherOwnerPartial(param1,this.m_wrapper,this.m_item,this.m_crewInfo,this.textInfo);
      }
      
      protected function get textInfo() : Object
      {
         return {
            "title":"CrewDialogTitle",
            "desc":"CrewDialogDesc"
         };
      }
      
      private function stopEventPropagation(param1:MouseEvent) : void
      {
         param1.stopImmediatePropagation();
         param1.stopPropagation();
      }
      
      private function onPickClick(param1:MouseEvent) : void
      {
         var _loc3_:SpeechPopup = null;
         var _loc2_:String = ZGlobal.gameSettings.getString("CrewAutoFillPopupSpeechID");
         if(_loc2_)
         {
            _loc3_ = new SpeechPopup(_loc2_,this.onPickSpeechClose);
            PopupManager.instance.push(_loc3_,0,true,false);
            VisitorManager.instance.removeBuildingAutoFillSeen(stateMachine.propertyBag as IEntity);
            this.stopEventPropagation(param1);
         }
      }
      
      private function onPickSpeechClose(param1:Event) : void
      {
         this.disposePick();
         this.showCrewDialog();
      }
      
      override public function canBeSelected() : Boolean
      {
         if(this.m_autoFilledCrewPick)
         {
            return false;
         }
         return true;
      }
      
      protected function onClosed(param1:Event) : void
      {
         this.disposeWindow();
      }
      
      private function createAutoFillPick(param1:IEntity) : void
      {
         this.disposePick();
         var _loc2_:Player = ZGlobal.player.findFriendById("-1");
         this.m_autoFilledCrewPick = new PortraitPick(param1,_loc2_,NeighborPickBubble);
         this.m_autoFilledCrewPick.mc.addEventListener(MouseEvent.CLICK,this.onPickClick,false,0,true);
         this.m_autoFilledCrewPick.mc.addEventListener(MouseEvent.MOUSE_UP,this.stopEventPropagation,false,0,true);
         this.m_autoFilledCrewPick.updatePosition();
         var _loc3_:IsoViewComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
         _loc3_.isoView.foregroundContainer.addChild(this.m_autoFilledCrewPick.mc);
      }
      
      private function onBuy(param1:Event) : void
      {
         this.disposeWindow();
         clickNextState();
      }
      
      private function disposeWindow() : void
      {
         if(m_window)
         {
            m_window.removeEventListener(CrewResizablePopUp.BUILT,this.onBuy);
            m_window.removeEventListener(CrewResizablePopUp.CLOSED,this.onClosed);
            m_window = null;
         }
      }
      
      protected function onCrewUpdated(param1:WorldEvent) : void
      {
         this.m_crewInfo = param1.eventData.crew;
         if(Boolean(this.m_crewInfo) && this.m_crewInfo.length == 1)
         {
            CrewManager.instance.dispatchEvent(new WorldEvent(CrewManager.CREW_UPDATED,{"crew":this.m_crewInfo}));
         }
         else
         {
            CrewManager.instance.dispatchEvent(new WorldEvent(CrewManager.CREW_UPDATED));
         }
      }
      
      override public function onMouseOver(param1:MouseEvent) : void
      {
         var _loc2_:IEntity = null;
         var _loc3_:ProgressBarEvent = null;
         if(ZGlobal.isHome())
         {
            if(ZGlobal.enhancedProgressBarVariant > 0)
            {
               _loc2_ = stateMachine.propertyBag as IEntity;
               if(Boolean(_loc2_) && CrewManager.isCrewBuildingFull(_loc2_,this.m_crewInfo))
               {
                  _loc3_ = new ProgressBarEvent(ProgressBarEvent.START_PROGRESS_BAR);
                  _loc3_.barType = ProgressBarEvent.TYPE_FINISHBUILDING;
                  stateMachine.propertyBag.eventDispatcher.dispatchEvent(_loc3_);
               }
            }
         }
      }
      
      override public function onMouseOut(param1:MouseEvent) : void
      {
         stateMachine.propertyBag.eventDispatcher.dispatchEvent(new ProgressBarEvent(ProgressBarEvent.STOP_PROGRESS_BAR));
      }
   }
}

