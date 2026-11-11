package core.entities.components.behaviors.states
{
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.entities.components.BuildingSpatialComponent;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.gameobjects.GameItem;
   import core.gameobjects.PartsBuildingItem;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import core.worlds.islandworld.components.CineCameraComponent;
   import dispatchers.UIDispatcher;
   import displays.screens.partsGather.BuildingPartsGather;
   import events.CloseEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import zlabs.events.WorldEvent;
   import zlabs.utils.MathUtils;
   
   public class BuildingPartsDialogState extends DialogState
   {
      
      public static const SHOW_BUILDING_PART_DIALOG:String = "SHOW_BUILDING_PART_DIALOG_";
      
      public function BuildingPartsDialogState(param1:BehaviorStateInit)
      {
         super(param1);
         if(Boolean(param1.m_gameItem) && param1.m_gameItem.code.length > 0)
         {
            UIDispatcher.instance.addEventListener(SHOW_BUILDING_PART_DIALOG + param1.m_gameItem.code,this.showDialogEvent);
         }
      }
      
      private function showDialogEvent(param1:WorldEvent) : void
      {
         var _loc2_:BuildingSpatialComponent = null;
         var _loc3_:Pt = null;
         var _loc4_:CineCameraComponent = null;
         if(param1)
         {
            param1.stopPropagation();
         }
         if(Boolean(stateMachine.currentStateName) && Boolean(stateMachine.states[stateMachine.currentStateName]) && stateMachine.states[stateMachine.currentStateName] is BuildingPartsDialogState)
         {
            this.showDialog();
         }
         else
         {
            _loc2_ = BuildingSpatialComponent(owner.lookupComponentByType(BuildingSpatialComponent));
            if(_loc2_)
            {
               _loc3_ = new Pt(_loc2_.position.x,_loc2_.position.y);
               _loc3_ = MathUtils.worldToTile(_loc3_,ZGlobal.cellSize);
               _loc4_ = ViewManager.instance.getComponentFromView(IslandWorld.ID,CineCameraComponent) as CineCameraComponent;
               _loc4_.moveTo(_loc3_);
            }
         }
      }
      
      override protected function showDialog() : void
      {
         var _loc1_:GameItem = null;
         var _loc2_:PartsBuildingItem = null;
         var _loc3_:String = null;
         if(ZGlobal.isHome())
         {
            _loc1_ = stateMachine.propertyBag.getProperty(dataProperty,null) as GameItem;
            _loc2_ = ZGlobal.gameSettings.getItemByCode(_loc1_.code,PartsBuildingItem) as PartsBuildingItem;
            if(Boolean(_loc2_) && Boolean(_loc2_.numParts > 0) && _loc2_.requiresAnyParts())
            {
               stateMachine.propertyBag.eventDispatcher.addEventListener(BuildingPartsGather.FINISHED,this.onFinished,false,0,true);
               stateMachine.propertyBag.eventDispatcher.addEventListener(CloseEvent.CLOSE,this.onCloseClick,false,0,true);
               _loc3_ = data.@desc;
               if(_loc2_.xml.@buildingPartsDesc != undefined)
               {
                  _loc3_ = _loc2_.xml.@buildingPartsDesc;
               }
               BuildingPartsGather.display(EventDispatcher(stateMachine.propertyBag.eventDispatcher),_loc2_.code,_loc3_,owner,data.@tit,null,data.@hint);
               return;
            }
            this.onFinished(null);
         }
      }
      
      protected function onFinished(param1:Event) : void
      {
         this.onCloseClick(null);
         clickNextState();
      }
      
      override protected function onCloseClick(param1:CloseEvent) : void
      {
         stateMachine.propertyBag.eventDispatcher.removeEventListener(BuildingPartsGather.FINISHED,this.onFinished);
         stateMachine.propertyBag.eventDispatcher.removeEventListener(CloseEvent.CLOSE,this.onCloseClick);
      }
   }
}

