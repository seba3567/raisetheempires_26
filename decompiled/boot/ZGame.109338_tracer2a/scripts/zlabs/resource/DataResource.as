package zlabs.resource
{
   import flash.utils.ByteArray;
   
   public class DataResource extends Resource
   {
      
      private var _data:ByteArray = null;
      
      public function DataResource()
      {
         super();
      }
      
      public function get data() : ByteArray
      {
         return this._data;
      }
      
      override public function initialize(param1:*) : void
      {
         if(!(param1 is ByteArray))
         {
            throw new Error("DataResource can only handle ByteArrays.");
         }
         this._data = param1;
         onLoadComplete();
      }
      
      override protected function onContentReady(param1:*) : Boolean
      {
         return this._data != null;
      }
   }
}

