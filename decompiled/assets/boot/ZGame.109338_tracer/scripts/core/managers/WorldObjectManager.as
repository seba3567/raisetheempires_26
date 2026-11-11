package core.managers
{
   import core.ZGlobal;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import zlabs.debug.Logger;
   import zlabs.events.WorldEvent;
   
   public class WorldObjectManager extends EventDispatcher
   {
      
      public static var GROUND_SELECTED:String = "groundSelected";
      
      public static var OBJECT_PLACED:String = "objectplaced";
      
      public static var OBJECT_PLACE_CANCELLED:String = "objectplaceCancelled";
      
      public static var OBJECT_PLACED_CLIENT:String = "objectPlacedClient";
      
      public static var OBJECT_REMOVED:String = "objectremoved";
      
      public static var OBJECT_BUILT:String = "objectbuilt";
      
      public static var OBJECT_CLEARED:String = "objectcleared";
      
      public static var OBJECT_SOLD:String = "objectsold";
      
      public static var OBJECT_SELECTED:String = "objectselected";
      
      public static var OBJECT_STATE_COMPLETE:String = "objectstate";
      
      public static var ITEM_PURCHASED:String = "itempurchased";
      
      public static var ITEM_HARVESTED:String = "itemharvested";
      
      public static var ATTACH_ARROW:String = "attacharrow";
      
      public static var CLEAR_ARROWS:String = "cleararrows";
      
      public static var ATTACH_STENCIL:String = "attachstencil";
      
      public static var CLEAR_STENCIL:String = "clearstencil";
      
      public static var instance:WorldObjectManager = new WorldObjectManager();
      
      private var m_typeDictionary:Dictionary = new Dictionary();
      
      private var m_codeDictionary:Dictionary = new Dictionary();
      
      private var m_builtDictionary:Dictionary = new Dictionary();
      
      private var m_categoryDictionary:Dictionary = new Dictionary();
      
      private var m_homeBuiltDictionary:Dictionary;
      
      public function WorldObjectManager()
      {
         super();
      }
      
      public function resetTypeDictionary() : void
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         var _loc3_:String = null;
         for(_loc1_ in this.m_typeDictionary)
         {
            for(_loc2_ in this.m_typeDictionary[_loc1_])
            {
               for(_loc3_ in this.m_typeDictionary[_loc1_][_loc2_])
               {
                  this.m_typeDictionary[_loc1_][_loc2_][_loc3_] = null;
               }
               this.m_typeDictionary[_loc1_][_loc2_] = null;
            }
            this.m_typeDictionary[_loc1_] = null;
         }
         this.m_typeDictionary = new Dictionary();
         this.m_codeDictionary = new Dictionary();
         if(ZGlobal.isHome())
         {
            this.m_homeBuiltDictionary = null;
         }
         else if(!this.m_homeBuiltDictionary)
         {
            this.m_homeBuiltDictionary = this.m_builtDictionary;
         }
         this.m_builtDictionary = new Dictionary();
         this.m_categoryDictionary = new Dictionary();
      }
      
      public function addObjectToTypeDictionary(param1:String, param2:String, param3:String, param4:Object) : void
      {
         if(this.m_typeDictionary[param1] == null)
         {
            this.m_typeDictionary[param1] = new Dictionary();
         }
         if(this.m_typeDictionary[param1][param2] == null)
         {
            this.m_typeDictionary[param1][param2] = new Dictionary();
         }
         this.m_typeDictionary[param1][param2][param3] = param4;
      }
      
      public function removeObject(param1:String, param2:String, param3:String, param4:String, param5:String) : void
      {
         this.removeObjectFromTypeDictionary(param1,param2,param3);
         this.removeObjectFromCodeDictionary(param4);
         this.removeObjectFromBuiltDictionary(param4);
         this.removeObjectFromCategoryDictionary(param5);
         dispatchEvent(new WorldEvent(OBJECT_REMOVED,param4));
      }
      
      private function removeObjectFromTypeDictionary(param1:String, param2:String, param3:String) : void
      {
         if(Boolean(this.m_typeDictionary[param1]) && Boolean(this.m_typeDictionary[param1][param2]))
         {
            delete this.m_typeDictionary[param1][param2][param3];
         }
      }
      
      public function addObjectToBuiltDictionary(param1:String) : void
      {
         if(this.m_builtDictionary[param1] == null)
         {
            this.m_builtDictionary[param1] = 0;
         }
         this.m_builtDictionary[param1] += 1;
         dispatchEvent(new WorldEvent(OBJECT_BUILT,param1));
      }
      
      private function removeObjectFromBuiltDictionary(param1:String) : void
      {
         this.m_builtDictionary[param1] = this.m_builtDictionary[param1] - 1;
         if(this.m_builtDictionary[param1] < 0)
         {
            Logger.error(this,"removeObjectFromBuiltDictionary","Count has gone negative");
         }
      }
      
      public function addObjectToCodeDictionary(param1:String) : void
      {
         if(this.m_codeDictionary[param1] == null)
         {
            this.m_codeDictionary[param1] = 0;
         }
         this.m_codeDictionary[param1] += 1;
      }
      
      private function removeObjectFromCodeDictionary(param1:String) : void
      {
         this.m_codeDictionary[param1] = this.m_codeDictionary[param1] - 1;
         if(this.m_codeDictionary[param1] < 0)
         {
            Logger.error(this,"removeObjectFromCodeDictionary","Count has gone negative");
         }
      }
      
      public function getNumberObjectsWithCategoryLimit(param1:String) : int
      {
         if(this.m_categoryDictionary[param1] == null)
         {
            return 0;
         }
         return this.m_categoryDictionary[param1];
      }
      
      public function addObjectToCategoryDictionary(param1:String) : void
      {
         if(this.m_categoryDictionary[param1] == null)
         {
            this.m_categoryDictionary[param1] = 0;
         }
         this.m_categoryDictionary[param1] += 1;
      }
      
      private function removeObjectFromCategoryDictionary(param1:String) : void
      {
         this.m_categoryDictionary[param1] = this.m_categoryDictionary[param1] - 1;
         if(this.m_categoryDictionary[param1] < 0)
         {
            Logger.error(this,"removeObjectFromCategoryDictionary","Count has gone negative");
         }
      }
      
      public function getNumberObjectsWithCode(param1:String) : int
      {
         if(this.m_codeDictionary[param1] == null)
         {
            return 0;
         }
         return this.m_codeDictionary[param1];
      }
      
      public function getNumberBuiltObjectsWithCode(param1:String) : int
      {
         if(this.m_builtDictionary[param1] == null)
         {
            return 0;
         }
         return this.m_builtDictionary[param1];
      }
      
      public function getNumberHomeBuiltObjectsWithCode(param1:String) : int
      {
         if(!this.m_homeBuiltDictionary || this.m_homeBuiltDictionary[param1] == null)
         {
            return 0;
         }
         return this.m_homeBuiltDictionary[param1];
      }
      
      public function getObjectsByType(param1:String) : Dictionary
      {
         return this.m_typeDictionary[param1];
      }
      
      public function getObjectsBySubType(param1:String, param2:String) : Dictionary
      {
         if(this.m_typeDictionary[param1])
         {
            return this.m_typeDictionary[param1][param2];
         }
         return null;
      }
      
      public function get typeDictionary() : Dictionary
      {
         return this.m_typeDictionary;
      }
   }
}

