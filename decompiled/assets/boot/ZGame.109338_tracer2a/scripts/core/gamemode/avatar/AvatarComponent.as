package core.gamemode.avatar
{
   import core.gamemode.orders.OrdersComponent;
   import core.ui.menuitem.OptionUIItem;
   import dispatchers.UIDispatcher;
   import flash.events.Event;
   import rendering.rendering2d.AnimationCanvasComponent;
   
   public class AvatarComponent extends OrdersComponent
   {
      
      public static const CANCEL_AVATAR_ORDERS:String = "cancelAvatarOrders";
      
      public function AvatarComponent()
      {
         super();
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         UIDispatcher.instance.addEventListener(OptionUIItem.EXIT,this.cancelAvatarOrders,false,0,true);
         UIDispatcher.instance.addEventListener(CANCEL_AVATAR_ORDERS,this.cancelAvatarOrders,false,0,true);
         var _loc1_:AnimationCanvasComponent = owner.lookupComponentByType(AnimationCanvasComponent) as AnimationCanvasComponent;
         _loc1_.forceAnimation = true;
      }
      
      override public function get snapToDestination() : Boolean
      {
         return false;
      }
      
      private function cancelAvatarOrders(param1:Event) : void
      {
         clearExistingOrders();
         resetStates();
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         UIDispatcher.instance.removeEventListener(OptionUIItem.EXIT,this.cancelAvatarOrders);
         UIDispatcher.instance.removeEventListener(CANCEL_AVATAR_ORDERS,this.cancelAvatarOrders);
      }
      
      override protected function get canInterrupt() : Boolean
      {
         return true;
      }
   }
}

