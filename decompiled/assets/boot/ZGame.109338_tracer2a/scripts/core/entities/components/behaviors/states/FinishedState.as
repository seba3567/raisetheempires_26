package core.entities.components.behaviors.states
{
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.states.IMachine;
   import core.entities.components.states.IState;
   import core.gameobjects.GameItem;
   import core.managers.PVPManager;
   import core.managers.PopulationManager;
   import core.managers.rewardPickupManager.RewardPickupManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.ui.FloatingText;
   import core.ui.feedbacktext.PopulationFeedbackText;
   import flash.display.Sprite;
   import flash.events.Event;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.rendering.renderingISO.IsoSpriteComponent;
   
   public class FinishedState extends BehaviorState
   {
      
      public function FinishedState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override public function enter(param1:IMachine) : void
      {
         super.enter(param1);
         this.updateItem(param1,true);
         if(TutorialManager.instance.active)
         {
            TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.BUILD_FINISHED));
         }
         param1.propertyBag.eventDispatcher.dispatchEvent(new Event(PVPManager.BUILD_FINISHED));
      }
      
      override public function load(param1:IMachine, param2:IState) : void
      {
         var _loc3_:BehaviorState = param2 as BehaviorState;
         if(!_loc3_ || _loc3_.isBuilt())
         {
            this.updateItem(param1,false);
         }
         super.load(param1,param2);
      }
      
      private function updateItem(param1:IMachine, param2:Boolean) : void
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc3_:GameItem = param1.propertyBag.getProperty(dataProperty,null) as GameItem;
         var _loc4_:String = _loc3_.workers;
         var _loc5_:String = _loc3_.workersCap;
         if(Boolean(_loc4_) && _loc4_.length > 0)
         {
            _loc6_ = parseInt(_loc4_);
         }
         if(Boolean(_loc5_) && _loc5_.length > 0)
         {
            _loc7_ = parseInt(_loc5_);
         }
         if(Boolean(_loc6_) || Boolean(_loc7_))
         {
            if(ZGlobal.isVisiting())
            {
               PopulationManager.visitInstance.updateMaxWorkers(_loc6_,_loc7_);
            }
            else
            {
               PopulationManager.instance.updateMaxWorkers(_loc6_,_loc7_);
               if(Boolean(_loc6_) && param2)
               {
                  Zlab.processManager.schedule(850,this,this.onFloatingTextDelay,{
                     "fsm":param1,
                     "value":_loc6_
                  });
               }
            }
         }
      }
      
      private function onFloatingTextDelay(param1:Object) : void
      {
         this.addFloatingText(param1.fsm,param1.value);
      }
      
      private function addFloatingText(param1:IMachine, param2:int) : void
      {
         var _loc3_:IsoSpriteComponent = (param1.propertyBag as IEntity).lookupComponentByType(IsoSpriteComponent) as IsoSpriteComponent;
         var _loc4_:Sprite = _loc3_.isoSprite.container;
         var _loc5_:PopulationFeedbackText = new PopulationFeedbackText(param2);
         var _loc6_:FloatingText = new FloatingText(_loc4_.parent);
         _loc6_.useWorldZoom = true;
         _loc6_.position = new Pt(_loc4_.x,_loc4_.y);
         _loc6_.disposeOnComplete = true;
         _loc6_.color = _loc5_.color;
         _loc6_.scale = RewardPickupManager.instance.floatingTextSizeMultiplier3D;
         _loc6_.text = ZGameUtils.ZlocT("Main","PositiveFeedback",{"feedback":_loc5_.friendlyName});
      }
   }
}

