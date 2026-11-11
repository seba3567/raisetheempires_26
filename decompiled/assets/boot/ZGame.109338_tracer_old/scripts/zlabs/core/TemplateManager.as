package zlabs.core
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.entity.IEntity;
   import zlabs.entity.allocateEntity;
   import zlabs.resource.XMLResource;
   import zlabs.serialization.Serializer;
   
   [Event(name="GROUP_LOADED",type="com.pblabs.engine.core.TemplateEvent")]
   public class TemplateManager extends EventDispatcher
   {
      
      public static const LOADED_EVENT:String = "LOADED_EVENT";
      
      public static const FAILED_EVENT:String = "FAILED_EVENT";
      
      public static var VERBOSE_LOGGING:Boolean = false;
      
      private var _inGroup:Boolean = false;
      
      private var _entityType:Class = null;
      
      private var _things:Dictionary = new Dictionary();
      
      public function TemplateManager()
      {
         super();
      }
      
      public function set entityType(param1:Class) : void
      {
         this._entityType = param1;
      }
      
      public function loadFile(param1:String) : void
      {
         Zlab.resourceManager.load(param1,XMLResource,this.onLoaded,this.onFailed);
      }
      
      public function unloadFile(param1:String) : void
      {
         this.removeXML(param1);
         Zlab.resourceManager.unload(param1,XMLResource);
      }
      
      public function instantiateEntity(param1:String) : IEntity
      {
         var xml:XML = null;
         var entity:IEntity = null;
         var instantiated:IEntity = null;
         var name:String = param1;
         try
         {
            if(this._things[name])
            {
               if(this._things[name].groupCallback)
               {
                  throw new Error("Thing \'" + name + "\' is a group callback!");
               }
               if(this._things[name].entityCallback)
               {
                  instantiated = this._things[name].entityCallback();
                  return instantiated;
               }
            }
            xml = this.getXML(name,"template","entity");
            if(!xml)
            {
               Logger.error(this,"instantiateEntity","Unable to find a template or entity with the name " + name + ".");
               return null;
            }
            entity = this.instantiateEntityFromXML(xml);
         }
         catch(e:Error)
         {
            Logger.error(this,"instantiateEntity","Failed instantiating \'" + name + "\' due to: " + e.toString() + "\n" + e.getStackTrace());
            entity = null;
         }
         return entity;
      }
      
      public function instantiateEntityFromXML(param1:XML) : IEntity
      {
         var name:String = null;
         var alias:String = null;
         var entity:IEntity = null;
         var xml:XML = param1;
         try
         {
            name = xml.attribute("name");
            if(xml.name() == "template")
            {
               name = "";
            }
            alias = xml.attribute("alias");
            if(alias == "")
            {
               alias = null;
            }
            if(!this._entityType)
            {
               entity = allocateEntity();
            }
            else
            {
               entity = new this._entityType();
            }
            entity.initialize(name,alias);
            entity.deferring = true;
            if(!this.doInstantiateTemplate(entity,xml.attribute("template"),new Dictionary()))
            {
               entity.destroy();
               return null;
            }
            Serializer.instance.deserialize(entity,xml);
            Serializer.instance.clearCurrentEntity();
            entity.deferring = false;
            if(!this._inGroup)
            {
               Serializer.instance.reportMissingReferences();
            }
         }
         catch(e:Error)
         {
            Logger.error(this,"instantiateEntity","Failed instantiating \'" + name + "\' due to: " + e.toString() + "\n" + e.getStackTrace());
            entity = null;
         }
         return entity;
      }
      
      public function instantiateGroup(param1:String) : Array
      {
         var group:Array = null;
         var entity:IEntity = null;
         var name:String = param1;
         if(this._things[name])
         {
            if(this._things[name].entityCallback)
            {
               throw new Error("Thing \'" + name + "\' is an entity callback!");
            }
            if(this._things[name].groupCallback)
            {
               return this._things[name].groupCallback();
            }
         }
         try
         {
            group = new Array();
            if(!this.doInstantiateGroup(name,group,new Dictionary()))
            {
               for each(entity in group)
               {
                  entity.destroy();
               }
               return null;
            }
            if(hasEventListener(TemplateEvent.GROUP_LOADED))
            {
               dispatchEvent(new TemplateEvent(TemplateEvent.GROUP_LOADED,name));
            }
            return group;
         }
         catch(e:Error)
         {
            Logger.error(this,"instantiateGroup","Failed to instantiate group \'" + name + "\' due to: " + e.toString());
            return null;
         }
      }
      
      public function addXML(param1:XML, param2:String, param3:int) : void
      {
         var _loc4_:String = param1.attribute("name");
         if(_loc4_.length == 0)
         {
            Logger.warn(this,"AddXML","XML object description added without a \'name\' attribute.");
            return;
         }
         if(this._things[_loc4_])
         {
            Logger.warn(this,"AddXML","An XML object description with name " + _loc4_ + " has already been added.");
            return;
         }
         var _loc5_:ThingReference = new ThingReference();
         _loc5_.xmlData = param1;
         _loc5_.identifier = param2;
         _loc5_.version = param3;
         this._things[_loc4_] = _loc5_;
      }
      
      public function removeXML(param1:String) : void
      {
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc5_:ThingReference = null;
         var _loc2_:Array = new Array();
         for(_loc3_ in this._things)
         {
            _loc5_ = this._things[_loc3_];
            if(_loc5_.identifier == param1)
            {
               _loc2_[_loc2_.length] = _loc3_;
            }
         }
         _loc4_ = 0;
         while(_loc4_ < _loc2_.length)
         {
            this._things[_loc2_[_loc4_]] = null;
            delete this._things[_loc2_[_loc4_]];
            _loc4_++;
         }
      }
      
      public function getXML(param1:String, param2:String = null, param3:String = null) : XML
      {
         var _loc4_:ThingReference = this.doGetXML(param1,param2,param3);
         return _loc4_ ? _loc4_.xmlData : null;
      }
      
      public function hasEntityCallback(param1:String) : Boolean
      {
         return this._things[param1];
      }
      
      public function registerEntityCallback(param1:String, param2:Function) : void
      {
         if(param2 == null)
         {
            throw new Error("Must pass a callback function!");
         }
         if(this._things[param1])
         {
            throw new Error("Already have a thing registered under \'" + param1 + "\'!");
         }
         var _loc3_:ThingReference = new ThingReference();
         _loc3_.entityCallback = param2;
         this._things[param1] = _loc3_;
      }
      
      public function unregisterEntityCallback(param1:String) : void
      {
         if(!this._things[param1])
         {
            Logger.warn(this,"unregisterEntityCallback","No such template \'" + param1 + "\'!");
            return;
         }
         if(!this._things[param1].entityCallback)
         {
            throw new Error("Thing \'" + param1 + "\' is not an entity callback!");
         }
         this._things[param1] = null;
         delete this._things[param1];
      }
      
      public function registerGroupCallback(param1:String, param2:Function) : void
      {
         if(param2 == null)
         {
            throw new Error("Must pass a callback function!");
         }
         if(this._things[param1])
         {
            throw new Error("Already have a thing registered under \'" + param1 + "\'!");
         }
         var _loc3_:ThingReference = new ThingReference();
         _loc3_.groupCallback = param2;
         this._things[param1] = _loc3_;
      }
      
      public function unregisterGroupCallback(param1:String) : void
      {
         if(!this._things[param1])
         {
            throw new Error("No such thing \'" + param1 + "\'!");
         }
         if(!this._things[param1].groupCallback)
         {
            throw new Error("Thing \'" + param1 + "\' is not a group callback!");
         }
         this._things[param1] = null;
         delete this._things[param1];
      }
      
      private function doGetXML(param1:String, param2:String, param3:String) : ThingReference
      {
         var _loc5_:String = null;
         var _loc4_:ThingReference = this._things[param1];
         if(!_loc4_)
         {
            return null;
         }
         if(_loc4_.entityCallback != null || _loc4_.groupCallback != null)
         {
            return null;
         }
         if(param2)
         {
            _loc5_ = _loc4_.xmlData.name();
            if(_loc5_ != param2 && _loc5_ != param3)
            {
               return null;
            }
         }
         return _loc4_;
      }
      
      private function doInstantiateTemplate(param1:IEntity, param2:String, param3:Dictionary) : Boolean
      {
         if(param2 == null || param2.length == 0)
         {
            return true;
         }
         if(param3[param2])
         {
            Logger.warn(this,"instantiateTemplate","Cyclical template detected. " + param2 + " has already been instantiated.");
            return false;
         }
         var _loc4_:XML = this.getXML(param2,"template");
         if(!_loc4_)
         {
            Logger.warn(this,"instantiate","Unable to find the template " + param2 + ".");
            return false;
         }
         param3[param2] = true;
         if(!this.doInstantiateTemplate(param1,_loc4_.attribute("template"),param3))
         {
            return false;
         }
         param1.deserialize(_loc4_,false);
         return true;
      }
      
      private function doInstantiateGroup(param1:String, param2:Array, param3:Dictionary) : Boolean
      {
         var objectXML:XML = null;
         var childName:String = null;
         var name:String = param1;
         var group:Array = param2;
         var tree:Dictionary = param3;
         var xml:XML = this.getXML(name,"group");
         if(!xml)
         {
            throw new Error("Could not find group \'" + name + "\'");
         }
         for each(objectXML in xml.*)
         {
            childName = objectXML.attribute("name");
            if(objectXML.name() == "groupReference")
            {
               if(tree[childName])
               {
                  throw new Error("Cyclical group detected. " + childName + " has already been instantiated.");
               }
               tree[childName] = true;
               try
               {
                  if(!this.doInstantiateGroup(childName,group,tree))
                  {
                     return false;
                  }
               }
               catch(err:*)
               {
                  Logger.warn(this,"instantiateGroup","Failed to instantiate group \'" + childName + "\' from groupReference in \'" + name + "\' due to: " + err);
                  return false;
               }
            }
            else if(objectXML.name() == "objectReference")
            {
               this._inGroup = true;
               group.push(this.instantiateEntity(childName));
               this._inGroup = false;
            }
            else
            {
               Logger.warn(this,"instantiateGroup","Encountered unknown tag " + objectXML.name() + " in group.");
            }
         }
         Serializer.instance.reportMissingReferences();
         return true;
      }
      
      private function onLoaded(param1:XMLResource) : void
      {
         var _loc4_:XML = null;
         var _loc2_:int = int(param1.XMLData.attribute("version"));
         var _loc3_:int = 0;
         for each(_loc4_ in param1.XMLData.*)
         {
            _loc3_++;
            this.addXML(_loc4_,param1.filename,_loc2_);
         }
         Logger.print(this,"Loaded " + _loc3_ + " from " + param1.filename);
         dispatchEvent(new Event(LOADED_EVENT));
      }
      
      private function onFailed(param1:XMLResource) : void
      {
         dispatchEvent(new Event(FAILED_EVENT));
      }
   }
}

class ThingReference
{
   
   public var version:int = 0;
   
   public var xmlData:XML = null;
   
   public var entityCallback:Function = null;
   
   public var groupCallback:Function = null;
   
   public var identifier:String = "";
   
   public function ThingReference()
   {
      super();
   }
}
