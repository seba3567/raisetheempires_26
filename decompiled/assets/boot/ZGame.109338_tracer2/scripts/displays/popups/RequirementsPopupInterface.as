package displays.popups
{
   import zlabs.events.GenericPopupEvent;
   
   public interface RequirementsPopupInterface
   {
      
      function callback(param1:GenericPopupEvent) : void;
      
      function get mainButtonText() : String;
      
      function get titleText() : String;
      
      function get bubbleText() : String;
      
      function get descriptionText() : String;
      
      function get iconArray() : Array;
   }
}

