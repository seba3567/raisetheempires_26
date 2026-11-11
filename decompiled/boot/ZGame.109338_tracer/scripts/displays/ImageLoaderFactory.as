package displays
{
   import fl.containers.UILoader;
   
   public class ImageLoaderFactory
   {
      
      public function ImageLoaderFactory()
      {
         super();
      }
      
      public static function CreateImageLoader(param1:String, param2:UILoader = null, param3:Function = null, param4:Function = null) : ImageLoader
      {
         if(param1)
         {
            if(param1.indexOf(".swf") >= 0)
            {
               return new SWFImageLoader(param1,param2,param3,param4);
            }
            return new ImageLoader(param1,param2,param3,param4);
         }
         return null;
      }
   }
}

