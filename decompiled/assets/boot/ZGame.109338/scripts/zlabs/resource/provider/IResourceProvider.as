package zlabs.resource.provider
{
   import zlabs.resource.Resource;
   
   public interface IResourceProvider
   {
      
      function isResourceKnown(param1:String, param2:Class) : Boolean;
      
      function getResource(param1:String, param2:Class, param3:Function, param4:Boolean = false, param5:Boolean = false) : Resource;
   }
}

