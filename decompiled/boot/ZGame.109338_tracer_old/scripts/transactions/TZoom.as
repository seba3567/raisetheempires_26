package transactions
{
   import Engine.Transactions.Transaction;
   import core.Zlingshot;
   import flash.utils.ByteArray;
   import mx.utils.Base64Decoder;
   
   public class TZoom extends Transaction
   {
      
      public function TZoom()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("ZlingshotService.zoom");
      }
      
      override protected function onComplete(param1:Object) : void
      {
         var _loc2_:ByteArray = null;
         var _loc3_:Base64Decoder = null;
         if(param1 != null)
         {
            _loc2_ = new ByteArray();
            _loc3_ = new Base64Decoder();
            _loc3_.decode(param1 as String);
            _loc2_ = _loc3_.toByteArray();
            _loc2_.uncompress();
            Zlingshot.instance.setZoomServer(_loc2_.toString());
         }
      }
   }
}

