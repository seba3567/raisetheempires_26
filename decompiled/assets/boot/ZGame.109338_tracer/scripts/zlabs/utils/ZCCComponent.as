package zlabs.utils
{
   import zlabs.components.TickedComponent;
   
   public class ZCCComponent extends TickedComponent
   {
      
      public static var instance:ZCCComponent = new ZCCComponent();
      
      public function ZCCComponent()
      {
         super();
      }
      
      override public function onTick(param1:Number) : void
      {
         super.onTick(param1);
         GlobalEngine.updateTimers();
      }
   }
}

