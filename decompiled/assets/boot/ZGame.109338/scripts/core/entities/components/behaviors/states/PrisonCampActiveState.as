package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.states.IInput;
   import core.entities.components.states.IMachine;
   import core.managers.prisoncamp.PrisonCampManager;
   import dispatchers.UIDispatcher;
   import displays.screens.PrisonCampActivationDialog;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import transactions.TInitUser;
   
   public class PrisonCampActiveState extends BehaviorState implements IInput
   {
      
      private static const ASSET_PATH:String = "assets/game/GeneralAssetGroup_UI.swf/";
      
      public function PrisonCampActiveState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function performEnterActions() : void
      {
         super.performEnterActions();
         UIDispatcher.instance.addEventListener(TInitUser.EVENT_COMPLETE,this.onInitUserComplete,false,0,true);
         stateMachine.propertyBag.eventDispatcher.addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
      }
      
      private function performUpdate() : void
      {
         ZGlobal.player.xpMultiplier = PrisonCampManager.instance.getPotentialXPMultiplier();
      }
      
      override protected function performExitActions(param1:IMachine) : void
      {
         super.performExitActions(param1);
         ZGlobal.player.xpMultiplier = 1;
      }
      
      private function onInitUserComplete(param1:Event = null) : void
      {
         updateOverlay();
      }
      
      override protected function addCustomProgressBarTextReplacements(param1:Object) : void
      {
         super.addCustomProgressBarTextReplacements(param1);
         param1.buffMult = ZGlobal.player.xpMultiplier;
      }
      
      override protected function shouldShowOverlay() : Object
      {
         var _loc2_:Number = NaN;
         var _loc1_:Object = super.shouldShowOverlay();
         if(_loc1_.show)
         {
            _loc2_ = ZGlobal.player.xpMultiplier;
            if(_loc2_ >= PrisonCampManager.MULTIPLIER_20_FLOAT)
            {
               _loc1_.data.@icon = ASSET_PATH + "DoubleXP_60.png";
            }
            else
            {
               if(_loc2_ < PrisonCampManager.MULTIPLIER_15_FLOAT)
               {
                  return {"show":false};
               }
               _loc1_.data.@icon = ASSET_PATH + "OneAndHalfXP_60.png";
            }
         }
         return _loc1_;
      }
      
      public function onClick(param1:Event) : void
      {
         if(ZGlobal.isHome())
         {
            PrisonCampActivationDialog.display(true,this);
         }
      }
      
      public function onRollOver(param1:Event) : void
      {
      }
   }
}

