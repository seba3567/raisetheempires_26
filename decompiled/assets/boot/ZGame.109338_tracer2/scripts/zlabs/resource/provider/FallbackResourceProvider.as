package zlabs.resource.provider
{
   public class FallbackResourceProvider extends ZCacheResourceProvider
   {
      
      private static var _instance:FallbackResourceProvider = null;
      
      public function FallbackResourceProvider()
      {
         super("PBEFallbackProvider",12,false);
      }
      
      public static function get instance() : FallbackResourceProvider
      {
         if(!_instance)
         {
            _instance = new FallbackResourceProvider();
         }
         return _instance;
      }
      
      override public function isResourceKnown(param1:String, param2:Class) : Boolean
      {
         return true;
      }
   }
}

