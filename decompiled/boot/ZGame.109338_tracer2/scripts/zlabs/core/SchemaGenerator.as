package zlabs.core
{
   import flash.events.StatusEvent;
   import flash.net.LocalConnection;
   import flash.utils.Dictionary;
   import flash.utils.describeType;
   import flash.utils.getDefinitionByName;
   import zlabs.Zlab;
   
   public class SchemaGenerator
   {
      
      private static var _instance:SchemaGenerator = null;
      
      private var _failed:Boolean = false;
      
      private var _classes:Dictionary = new Dictionary();
      
      private var _connection:LocalConnection;
      
      public function SchemaGenerator()
      {
         super();
         this.addClassName("flash.geom.Point");
         this.addClassName("flash.geom.Rectangle");
         this.addClassName("Array");
         this.addClassName("flash.utils.Dictionary");
         this.addClassName("int");
         this.addClassName("uint");
         this.addClassName("Number");
         this.addClassName("Boolean");
         this.addClassName("String");
      }
      
      public static function get instance() : SchemaGenerator
      {
         if(!_instance)
         {
            _instance = new SchemaGenerator();
         }
         return _instance;
      }
      
      public function addClass(param1:String, param2:Class) : void
      {
         this._classes[param1.replace("::",".")] = param2;
      }
      
      public function addClassName(param1:String) : void
      {
         this.addClass(param1,getDefinitionByName(param1) as Class);
      }
      
      public function generateSchema() : void
      {
         var dependentClasses:Dictionary;
         var classObject:Class = null;
         var description:XML = null;
         if(Zlab.IS_SHIPPING_BUILD)
         {
            return;
         }
         this._connection = new LocalConnection();
         this._connection.addEventListener(StatusEvent.STATUS,this.onConnectionStatus);
         this._connection.send("_SchemaConnection","OnSchemaReceived","START","");
         this._failed = false;
         dependentClasses = new Dictionary();
         for each(classObject in this._classes)
         {
            description = describeType(classObject);
            try
            {
               this._connection.send("_SchemaConnection","OnSchemaReceived","TYPE",description.toString());
            }
            catch(error:Error)
            {
               _connection.send("_SchemaConnection","OnSchemaReceived","ERROR","Schema data for " + description.@name + " is too big!");
            }
         }
         this._connection.send("_SchemaConnection","OnSchemaReceived","END","");
      }
      
      private function onConnectionStatus(param1:StatusEvent) : void
      {
         if(this._failed)
         {
            return;
         }
         switch(param1.level)
         {
            case "error":
               this._failed = true;
         }
         if(this._failed)
         {
         }
      }
   }
}

