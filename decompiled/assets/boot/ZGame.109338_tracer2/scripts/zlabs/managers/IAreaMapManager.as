package zlabs.managers
{
   import flash.events.Event;
   
   public interface IAreaMapManager
   {
      
      function removeItem(param1:IPositionItem) : Boolean;
      
      function insert(param1:IPositionItem, param2:Boolean = false) : void;
      
      function scalar(param1:Number) : int;
      
      function onCullScene(param1:Event = null) : void;
   }
}

