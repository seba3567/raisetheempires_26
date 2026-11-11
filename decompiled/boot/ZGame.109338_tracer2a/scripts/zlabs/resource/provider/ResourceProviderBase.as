package zlabs.resource.provider
{
   import flash.utils.Dictionary;
   import zlabs.Zlab;
   import zlabs.resource.Resource;
   
   public class ResourceProviderBase implements IResourceProvider
   {
      
      protected var resources:Dictionary;
      
      public function ResourceProviderBase(param1:Boolean = true)
      {
         super();
         if(!Zlab.resourceManager)
         {
            throw new Error("Cannot instantiate a ResourceBundle until you have called PBE.startup(this);. Move the call to new YourResourceBundle(); to occur AFTER the call to PBE.startup().");
         }
         if(param1)
         {
            Zlab.resourceManager.registerResourceProvider(this);
         }
         this.resources = new Dictionary();
      }
      
      public function isResourceKnown(param1:String, param2:Class) : Boolean
      {
         var _loc3_:String = param1.toLowerCase() + param2;
         return this.resources[_loc3_] != null;
      }
      
      public function getResource(param1:String, param2:Class, param3:Function, param4:Boolean = false, param5:Boolean = false) : Resource
      {
         var _loc6_:String = param1.toLowerCase() + param2;
         return this.resources[_loc6_];
      }
      
      protected function addResource(param1:String, param2:Class, param3:Resource) : void
      {
         var _loc4_:String = param1.toLowerCase() + param2;
         this.resources[_loc4_] = param3;
      }
   }
}

