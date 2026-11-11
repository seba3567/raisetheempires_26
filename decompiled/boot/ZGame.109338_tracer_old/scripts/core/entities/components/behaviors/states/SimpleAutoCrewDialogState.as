package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.states.IInput;
   import core.gameobjects.CrewTemplateWrapper;
   import core.gameobjects.GameItem;
   import core.managers.CrewManager;
   import displays.screens.CrewGatherOwnerComplete;
   import flash.events.Event;
   import zlabs.displays.popups.SWFPopUp;
   import zlabs.entity.IEntity;
   import zlabs.managers.WindowManager;
   
   public class SimpleAutoCrewDialogState extends SimpleAutoState implements IInput
   {
      
      private var m_gameItem:GameItem;
      
      public function SimpleAutoCrewDialogState(param1:BehaviorStateInit)
      {
         this.m_gameItem = param1.m_gameItem;
         super(param1);
      }
      
      public function onClick(param1:Event) : void
      {
         var _loc2_:String = null;
         var _loc3_:CrewTemplateWrapper = null;
         var _loc4_:IEntity = null;
         var _loc5_:Object = null;
         var _loc6_:SWFPopUp = null;
         if(ZGlobal.isHome())
         {
            _loc2_ = this.m_gameItem.getCrewTemplateName();
            _loc3_ = _loc2_ ? ZGlobal.gameSettings.getCrewTemplateWrapper(_loc2_) : null;
            if(_loc3_)
            {
               _loc4_ = stateMachine.propertyBag as IEntity;
               _loc5_ = CrewManager.getCrewInfo(_loc4_);
               if(_loc5_)
               {
                  _loc6_ = new CrewGatherOwnerComplete(_loc4_,_loc3_,this.m_gameItem,_loc5_.crew);
                  CrewGatherOwnerComplete(_loc6_).crewReplaceCount = _loc5_.replaceCount ? int(_loc5_.replaceCount) : 0;
                  WindowManager.instance.push(_loc6_);
               }
            }
         }
      }
      
      public function onRollOver(param1:Event) : void
      {
      }
   }
}

