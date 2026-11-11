package zlabs.serialization
{
   import flash.utils.Dictionary;
   import flash.utils.describeType;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   import zlabs.debug.Logger;
   
   public class TypeUtility
   {
      
      private static var _typeDescriptions:Dictionary = new Dictionary();
      
      private static var _instantiators:Dictionary = new Dictionary();
      
      public function TypeUtility()
      {
         super();
      }
      
      public static function registerInstantiator(param1:String, param2:Function) : void
      {
         if(_instantiators[param1])
         {
            Logger.warn("TypeUtility","RegisterInstantiator","An instantiator for " + param1 + " has already been registered. It will be replaced.");
         }
         _instantiators[param1] = param2;
      }
      
      public static function getObjectClassName(param1:*) : String
      {
         return getQualifiedClassName(param1);
      }
      
      public static function getClassFromName(param1:String) : Class
      {
         return getDefinitionByName(param1) as Class;
      }
      
      public static function getClass(param1:*) : Class
      {
         if(param1 is Class || param1 == null)
         {
            return param1;
         }
         return Object(param1).constructor;
      }
      
      public static function instantiate(param1:String, param2:Boolean = false) : *
      {
         var className:String = param1;
         var suppressError:Boolean = param2;
         if(className == "String")
         {
            return "";
         }
         if(className == "Class")
         {
            return Class;
         }
         if(_instantiators[className])
         {
            return _instantiators[className]();
         }
         try
         {
            return new (getDefinitionByName(className))();
         }
         catch(e:Error)
         {
            if(!suppressError)
            {
               Logger.warn(null,"Instantiate","Failed to instantiate " + className + " due to " + e.toString());
               Logger.warn(null,"Instantiate","Is " + className + " included in your SWF? Make sure you call PBE.registerType(" + className + "); somewhere in your project.");
            }
         }
         return null;
      }
      
      public static function getFieldType(param1:*, param2:String) : String
      {
         var _loc4_:XML = null;
         var _loc5_:XML = null;
         var _loc3_:XML = getTypeDescription(param1);
         for each(_loc4_ in _loc3_.child("accessor"))
         {
            if(_loc4_.attribute("name") == param2)
            {
               return _loc4_.attribute("type");
            }
         }
         for each(_loc5_ in _loc3_.child("variable"))
         {
            if(_loc5_.attribute("name") == param2)
            {
               return _loc5_.attribute("type");
            }
         }
         return null;
      }
      
      public static function isDynamic(param1:*) : Boolean
      {
         if(param1 is Class)
         {
            Logger.error(param1,"isDynamic","The object is a Class type, which is always dynamic");
            return true;
         }
         var _loc2_:XML = getTypeDescription(param1);
         return _loc2_.@isDynamic == "true";
      }
      
      public static function getTypeHint(param1:*, param2:String) : String
      {
         var _loc4_:XML = null;
         var _loc5_:XML = null;
         var _loc6_:String = null;
         var _loc3_:XML = getTypeDescription(param1);
         if(!_loc3_)
         {
            return null;
         }
         for each(_loc4_ in _loc3_.*)
         {
            if(_loc4_.@name == param2)
            {
               if(!(_loc4_.name() != "variable" && _loc4_.name() != "accessor"))
               {
                  for each(_loc5_ in _loc4_.*)
                  {
                     if(_loc5_.@name == "TypeHint")
                     {
                        return _loc5_.arg.@value.toString();
                     }
                  }
               }
            }
         }
         return null;
      }
      
      public static function getEditorData(param1:*, param2:String) : XML
      {
         var _loc4_:XML = null;
         var _loc5_:XML = null;
         var _loc3_:XML = getTypeDescription(param1);
         if(!_loc3_)
         {
            return null;
         }
         for each(_loc4_ in _loc3_.*)
         {
            if(_loc4_.@name == param2)
            {
               if(!(_loc4_.name() != "variable" && _loc4_.name() != "accessor"))
               {
                  for each(_loc5_ in _loc4_.*)
                  {
                     if(_loc5_.@name == "EditorData")
                     {
                        return _loc5_;
                     }
                  }
               }
            }
         }
         return null;
      }
      
      public static function getTypeDescription(param1:*) : XML
      {
         var _loc2_:String = getObjectClassName(param1);
         if(!_typeDescriptions[_loc2_])
         {
            _typeDescriptions[_loc2_] = describeType(param1);
         }
         return _typeDescriptions[_loc2_];
      }
      
      public static function getClassDescription(param1:String) : XML
      {
         var className:String = param1;
         if(!_typeDescriptions[className])
         {
            try
            {
               _typeDescriptions[className] = describeType(getDefinitionByName(className));
            }
            catch(error:Error)
            {
               return null;
            }
         }
         return _typeDescriptions[className];
      }
   }
}

