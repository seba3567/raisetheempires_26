package zlabs.resource
{
   import flash.utils.ByteArray;
   import zlabs.debug.Logger;
   
   public class XMLResource extends Resource
   {
      
      private var _valid:Boolean = true;
      
      private var _xml:XML = null;
      
      public function XMLResource()
      {
         super();
      }
      
      public function get XMLData() : XML
      {
         return this._xml;
      }
      
      override public function initialize(param1:*) : void
      {
         var data:* = param1;
         if(data is ByteArray)
         {
            data = (data as ByteArray).readUTFBytes((data as ByteArray).length);
         }
         try
         {
            this._xml = new XML(data);
         }
         catch(e:TypeError)
         {
            Logger.print(this,"Got type error parsing XML: " + e.toString());
            _valid = false;
         }
         onLoadComplete();
      }
      
      override protected function onContentReady(param1:*) : Boolean
      {
         return this._valid;
      }
   }
}

