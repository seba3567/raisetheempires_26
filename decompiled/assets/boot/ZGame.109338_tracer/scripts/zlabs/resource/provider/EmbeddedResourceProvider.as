package zlabs.resource.provider
{
   import zlabs.debug.Logger;
   import zlabs.resource.Resource;
   
   public class EmbeddedResourceProvider extends ResourceProviderBase
   {
      
      private static var _instance:EmbeddedResourceProvider = null;
      
      public function EmbeddedResourceProvider()
      {
         super();
      }
      
      public static function get instance() : EmbeddedResourceProvider
      {
         if(!_instance)
         {
            _instance = new EmbeddedResourceProvider();
         }
         return _instance;
      }
      
      public function registerResource(param1:String, param2:Class, param3:*) : void
      {
         var resource:Resource = null;
         var filename:String = param1;
         var resourceType:Class = param2;
         var data:* = param3;
         var resourceIdentifier:String = filename.toLowerCase() + resourceType;
         if(resources[resourceIdentifier])
         {
            Logger.warn(this,"registerEmbeddedResource","A resource from file " + filename + " has already been embedded.");
            return;
         }
         try
         {
            resource = new resourceType();
            resource.filename = filename;
            resource.initialize(data);
            resources[resourceIdentifier] = resource;
         }
         catch(e:Error)
         {
            Logger.error(this,"registerEmbeddedResources","Could not instantiate resource " + filename + " due to error:\n" + e.toString());
            return;
         }
      }
   }
}

