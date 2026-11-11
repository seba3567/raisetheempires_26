package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.states.IMachine;
   import core.gameobjects.GameItem;
   import core.gameobjects.PartsBuildingItem;
   import core.managers.NeighborhoodHelper;
   import core.managers.PopulationManager;
   import displays.popups.NeighborhoodDialog;
   import displays.screens.partsGather.BuildingPartsGather;
   import events.CloseEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class NeighborhoodDialogState extends DialogState
   {
      
      public function NeighborhoodDialogState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override public function enter(param1:IMachine) : void
      {
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         var _loc5_:GameItem = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         super.enter(param1);
         var _loc2_:Object = param1.propertyBag.getProperty(userDataProperty,null);
         if(_loc2_)
         {
            NeighborhoodHelper.instance.addNeighborhood(_loc2_.id);
            NeighborhoodHelper.instance.resetTimer();
            if(_loc2_.blocks)
            {
               for each(_loc3_ in _loc2_.blocks)
               {
                  for each(_loc4_ in _loc3_)
                  {
                     _loc5_ = ZGlobal.gameSettings.getItemByName(_loc4_.itemName,GameItem) as GameItem;
                     _loc6_ = _loc5_.workers;
                     _loc7_ = _loc5_.workersCap;
                     if(Boolean(_loc6_) && _loc6_.length > 0)
                     {
                        _loc8_ = parseInt(_loc6_);
                     }
                     if(Boolean(_loc7_) && _loc7_.length > 0)
                     {
                        _loc9_ = parseInt(_loc7_);
                     }
                     if(Boolean(_loc8_) || Boolean(_loc9_))
                     {
                        if(ZGlobal.isVisiting())
                        {
                           PopulationManager.visitInstance.updateMaxWorkers(_loc8_,_loc9_);
                        }
                        else
                        {
                           PopulationManager.instance.updateMaxWorkers(_loc8_,_loc9_);
                        }
                     }
                  }
               }
            }
         }
      }
      
      override public function exit(param1:IMachine) : void
      {
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         var _loc5_:GameItem = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc2_:Object = param1.propertyBag.getProperty(userDataProperty,null);
         if(_loc2_)
         {
            if(_loc2_.blocks)
            {
               for each(_loc3_ in _loc2_.blocks)
               {
                  for each(_loc4_ in _loc3_)
                  {
                     _loc5_ = ZGlobal.gameSettings.getItemByName(_loc4_.itemName,GameItem) as GameItem;
                     _loc6_ = _loc5_.workers;
                     _loc7_ = _loc5_.workersCap;
                     if(Boolean(_loc6_) && _loc6_.length > 0)
                     {
                        _loc8_ = parseInt(_loc6_);
                     }
                     if(Boolean(_loc7_) && _loc7_.length > 0)
                     {
                        _loc9_ = parseInt(_loc7_);
                     }
                     if(Boolean(_loc8_) || Boolean(_loc9_))
                     {
                        if(ZGlobal.isVisiting())
                        {
                           PopulationManager.visitInstance.updateMaxWorkers(-_loc8_,-_loc9_);
                        }
                        else
                        {
                           PopulationManager.instance.updateMaxWorkers(-_loc8_,-_loc9_);
                        }
                     }
                  }
               }
            }
         }
      }
      
      override protected function showDialog() : void
      {
         if(!ZGlobal.isVisiting())
         {
            NeighborhoodDialog.display(owner,this);
         }
      }
      
      public function showPartDialog() : void
      {
         var _loc1_:PartsBuildingItem = null;
         var _loc2_:String = null;
         if(ZGlobal.isHome())
         {
            _loc1_ = ZGlobal.gameSettings.getItemByName(this.data.@partsFrom,PartsBuildingItem) as PartsBuildingItem;
            if(Boolean(_loc1_) && Boolean(_loc1_.numParts > 0) && _loc1_.requiresAnyParts())
            {
               stateMachine.propertyBag.eventDispatcher.addEventListener(BuildingPartsGather.FINISHED,this.onFinished,false,0,true);
               stateMachine.propertyBag.eventDispatcher.addEventListener(CloseEvent.CLOSE,this.onCloseClick,false,0,true);
               _loc2_ = data.@desc;
               if(_loc1_.xml.@buildingPartsDesc != undefined)
               {
                  _loc2_ = _loc1_.xml.@buildingPartsDesc;
               }
               BuildingPartsGather.display(EventDispatcher(stateMachine.propertyBag.eventDispatcher),_loc1_.code,_loc2_,owner,data.@tit,data.@complete);
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

