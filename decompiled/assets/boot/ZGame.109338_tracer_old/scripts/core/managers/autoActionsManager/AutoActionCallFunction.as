package core.managers.autoActionsManager
{
   import flash.events.IEventDispatcher;
   
   public class AutoActionCallFunction extends AutoAction
   {
      
      public function AutoActionCallFunction(param1:IEventDispatcher = null)
      {
         super(param1);
      }
      
      override protected function performAction() : void
      {
         var _loc1_:Function = null;
         var _loc2_:String = null;
         doDisableInput();
         _loc1_ = data.func;
         if(data.args)
         {
            _loc2_ = data.args;
            _loc1_(_loc2_);
         }
         else
         {
            _loc1_();
         }
         startEndAction();
      }
   }
}

