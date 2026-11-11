package zlabs.resource
{
   import flash.utils.describeType;
   import flash.utils.getDefinitionByName;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.resource.provider.EmbeddedResourceProvider;
   
   public class ResourceBundle
   {
      
      public static var ExtensionTypes:Object = {
         "png":"zlabs.resource.ImageResource",
         "jpg":"zlabs.resource.ImageResource",
         "gif":"zlabs.resource.ImageResource",
         "bmp":"zlabs.resource.ImageResource",
         "xml":"zlabs.resource.XMLResource",
         "pbelevel":"zlabs.resource.XMLResource",
         "swf":"zlabs.resource.SWFResource",
         "mp3":"zlabs.resource.MP3Resource"
      };
      
      public function ResourceBundle()
      {
         var desc:XML;
         var res:Class = null;
         var resIsEmbedded:Boolean = false;
         var resSource:String = null;
         var resMimeType:String = null;
         var resTypeName:String = null;
         var v:XML = null;
         var meta:XML = null;
         var resType:Class = null;
         var testResource:* = undefined;
         var arg:XML = null;
         var extArray:Array = null;
         var ext:String = null;
         super();
         if(!Zlab.resourceManager)
         {
            throw new Error("Cannot instantiate a ResourceBundle until you have called PBE.startup(this);. Move the call to new YourResourceBundle(); to occur AFTER the call to PBE.startup().");
         }
         desc = describeType(this);
         new DataResource();
         new ImageResource();
         new XMLResource();
         new MP3Resource();
         for each(v in desc.variable)
         {
            res = this[v.@name];
            resIsEmbedded = false;
            resSource = "";
            resMimeType = "";
            resTypeName = "";
            for each(meta in v.children())
            {
               if(meta.@name == "Embed")
               {
                  resIsEmbedded = true;
                  for each(arg in meta.children())
                  {
                     if(arg.@key == "source")
                     {
                        resSource = arg.@value;
                     }
                     else if(arg.@key == "mimeType")
                     {
                        resMimeType = arg.@value;
                     }
                  }
               }
               else if(meta.@name == "ResourceType")
               {
                  for each(arg in meta.children())
                  {
                     if(arg.@key == "className")
                     {
                        resTypeName = arg.@value;
                     }
                  }
               }
            }
            if(!resIsEmbedded || resSource == "" || res == null)
            {
               Logger.error(this,"ResourceBundle","A resource in the resource bundle with the name \'" + v.@name + "\' has failed to embed properly.  Please ensure that you have the command line option \"--keep-as3-metadata+=TypeHint,EditorData,Embed\" set properly.  Additionally, please check that the [Embed] metadata syntax is correct.");
            }
            else
            {
               if(resTypeName == "")
               {
                  extArray = resSource.split(".");
                  ext = (extArray[extArray.length - 1] as String).toLowerCase();
                  if(!ExtensionTypes.hasOwnProperty(ext))
                  {
                     Logger.warn(this,"ResourceBundle","No resource type specified for extension \'." + ext + "\'.  In the ExtensionTypes parameter, expected to see something like: ResourceBundle.ExtensionTypes.mycustomext = \"com.mydomain.customresource\" where mycustomext is the (lower-case) extension, and \"com.mydomain.customresource\" is a string of the fully qualified resource class name.  Defaulting to generic DataResource.");
                     resTypeName = "com.pblabs.engine.resource.DataResource";
                  }
                  else
                  {
                     resTypeName = ExtensionTypes[ext] as String;
                  }
               }
               try
               {
                  resType = getDefinitionByName(resTypeName) as Class;
               }
               catch(err:Error)
               {
                  resType = null;
               }
               if(resType)
               {
                  testResource = new resType();
                  if(testResource is Resource)
                  {
                     EmbeddedResourceProvider.instance.registerResource(resSource,resType,new res());
                  }
               }
            }
         }
      }
   }
}

