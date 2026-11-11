package zlabs.entity
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   import zlabs.Zlab;
   import zlabs.core.PBObject;
   import zlabs.core.PBSet;
   import zlabs.debug.Logger;
   import zlabs.serialization.Serializer;
   import zlabs.serialization.TypeUtility;
   
   internal class Entity extends PBObject implements IEntity
   {
      
      private var _deferring:Boolean = true;
      
      protected var _components:Dictionary = new Dictionary();
      
      protected var _tempPropertyInfo:PropertyInfo = new PropertyInfo();
      
      protected var _deferredComponents:Array = new Array();
      
      protected var _eventDispatcher:EventDispatcher = new EventDispatcher();
      
      public function Entity()
      {
         super();
      }
      
      public function get deferring() : Boolean
      {
         return this._deferring;
      }
      
      public function set deferring(param1:Boolean) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:PendingComponent = null;
         if(this._deferring == true && param1 == false)
         {
            _loc2_ = this._deferredComponents.length > 0;
            while(this._deferredComponents.length)
            {
               _loc3_ = this._deferredComponents.shift() as PendingComponent;
               _loc3_.item.register(this,_loc3_.name);
            }
            this._deferring = false;
            if(_loc2_)
            {
               this.doResetComponents();
            }
         }
         this._deferring = param1;
      }
      
      public function get eventDispatcher() : IEventDispatcher
      {
         return this._eventDispatcher;
      }
      
      override public function initialize(param1:String = null, param2:String = null) : void
      {
         super.initialize(param1,param2);
         this.deferring = false;
      }
      
      override public function destroy() : void
      {
         var _loc1_:IEntityComponent = null;
         var _loc2_:String = null;
         if(this._eventDispatcher.hasEventListener("EntityDestroyed"))
         {
            this._eventDispatcher.dispatchEvent(new Event("EntityDestroyed"));
         }
         for each(_loc1_ in this._components)
         {
            if(_loc1_.isRegistered)
            {
               _loc1_.unregister();
            }
         }
         for(_loc2_ in this._components)
         {
            delete this._components[_loc2_];
         }
         super.destroy();
      }
      
      public function serialize(param1:XML) : void
      {
         var _loc2_:IEntityComponent = null;
         var _loc3_:XML = null;
         for each(_loc2_ in this._components)
         {
            _loc3_ = <component type={getQualifiedClassName(_loc2_).replace(/::/,".")} name={_loc2_.name}/>;
            Serializer.instance.serialize(_loc2_,_loc3_);
            param1.appendChild(_loc3_);
         }
      }
      
      public function deserialize(param1:XML, param2:Boolean = true) : void
      {
         var _loc4_:XML = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:IEntityComponent = null;
         var _loc9_:Array = null;
         var _loc10_:String = null;
         var _loc11_:PBSet = null;
         Serializer.instance.setCurrentEntity(this);
         var _loc3_:Boolean = this.deferring;
         this.deferring = true;
         for each(_loc4_ in param1.*)
         {
            if(_loc4_.name().toString().toLowerCase() != "component")
            {
               Logger.error(this,"deserialize","Found unexpected tag \'" + _loc4_.name().toString() + "\', only <component/> is valid, ignoring tag. Error in entity \'" + name + "\'.");
            }
            else
            {
               _loc6_ = _loc4_.attribute("name");
               _loc7_ = _loc4_.attribute("type");
               _loc8_ = null;
               if(_loc7_.length > 0)
               {
                  _loc8_ = TypeUtility.instantiate(_loc7_) as IEntityComponent;
                  if(!_loc8_)
                  {
                     Logger.error(this,"deserialize","Unable to instantiate component " + _loc6_ + " of type " + _loc7_ + " on entity \'" + name + "\'.");
                     continue;
                  }
                  if(!this.addComponent(_loc8_,_loc6_))
                  {
                     continue;
                  }
               }
               else
               {
                  _loc8_ = this.lookupComponentByName(_loc6_);
                  if(!_loc8_)
                  {
                     Logger.error(this,"deserialize","No type specified for the component " + _loc6_ + " and the component doesn\'t exist on a parent template for entity \'" + name + "\'.");
                     continue;
                  }
               }
               Serializer.instance.deserialize(_loc8_,_loc4_);
            }
         }
         _loc5_ = param1.attribute("sets");
         if(_loc5_)
         {
            _loc9_ = _loc5_.split(",");
            if(_loc9_)
            {
               while(true)
               {
                  _loc10_ = _loc9_.pop();
                  if(!_loc10_)
                  {
                     break;
                  }
                  _loc11_ = Zlab.lookup(_loc10_) as PBSet;
                  if(!_loc11_)
                  {
                     _loc11_ = new PBSet();
                     _loc11_.initialize(_loc10_);
                     Logger.warn(this,"deserialize","Auto-creating set \'" + _loc10_ + "\'.");
                  }
                  _loc11_.add(this as PBObject);
               }
            }
         }
         this.deferring = _loc3_;
      }
      
      public function addComponent(param1:IEntityComponent, param2:String) : Boolean
      {
         var _loc3_:PendingComponent = null;
         if(!this.doAddComponent(param1,param2))
         {
            return false;
         }
         if(this.deferring)
         {
            _loc3_ = new PendingComponent();
            _loc3_.item = param1;
            _loc3_.name = param2;
            this._deferredComponents.push(_loc3_);
            return true;
         }
         param1.register(this,param2);
         this.doResetComponents();
         return true;
      }
      
      public function removeComponent(param1:IEntityComponent) : void
      {
         var _loc2_:int = 0;
         if(!this.doRemoveComponent(param1))
         {
            return;
         }
         if(param1.isRegistered == false)
         {
            _loc2_ = 0;
            while(_loc2_ < this._deferredComponents.length)
            {
               if((this._deferredComponents[_loc2_] as PendingComponent).item == param1)
               {
                  this._deferredComponents.splice(_loc2_,1);
                  break;
               }
               _loc2_++;
            }
            return;
         }
         param1.unregister();
         this.doResetComponents();
      }
      
      public function lookupComponentByType(param1:Class) : IEntityComponent
      {
         var _loc2_:IEntityComponent = null;
         for each(_loc2_ in this._components)
         {
            if(_loc2_ is param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function lookupComponentsByType(param1:Class) : Array
      {
         var _loc3_:IEntityComponent = null;
         var _loc2_:Array = new Array();
         for each(_loc3_ in this._components)
         {
            if(_loc3_ is param1)
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc2_;
      }
      
      public function lookupComponentByName(param1:String) : IEntityComponent
      {
         return this._components[param1];
      }
      
      public function doesPropertyExist(param1:PropertyReference) : Boolean
      {
         return this.findProperty(param1,false,this._tempPropertyInfo,true) != null;
      }
      
      public function getProperty(param1:PropertyReference, param2:* = null) : *
      {
         var _loc3_:PropertyInfo = this.findProperty(param1,false,this._tempPropertyInfo);
         var _loc4_:* = null;
         if(_loc3_)
         {
            _loc4_ = _loc3_.getValue();
         }
         else
         {
            _loc4_ = param2;
         }
         this._tempPropertyInfo.clear();
         return _loc4_;
      }
      
      public function setProperty(param1:PropertyReference, param2:*) : void
      {
         var _loc3_:PropertyInfo = this.findProperty(param1,true,this._tempPropertyInfo);
         if(_loc3_)
         {
            _loc3_.setValue(param2);
         }
         this._tempPropertyInfo.clear();
      }
      
      private function doAddComponent(param1:IEntityComponent, param2:String) : Boolean
      {
         if(param2 == "")
         {
            Logger.warn(this,"AddComponent","A component name was not specified. This might cause problems later.");
         }
         if(param1.owner)
         {
            Logger.error(this,"AddComponent","The component " + param2 + " already has an owner. (" + name + ")");
            return false;
         }
         if(this._components[param2])
         {
            Logger.error(this,"AddComponent","A component with name " + param2 + " already exists on this entity (" + name + ").");
            return false;
         }
         param1.owner = this;
         this._components[param2] = param1;
         return true;
      }
      
      private function doRemoveComponent(param1:IEntityComponent) : Boolean
      {
         if(param1.owner != this)
         {
            Logger.error(this,"AddComponent","The component " + param1.name + " is not owned by this entity. (" + name + ")");
            return false;
         }
         if(!this._components[param1.name])
         {
            Logger.error(this,"AddComponent","The component " + param1.name + " was not found on this entity. (" + name + ")");
            return false;
         }
         delete this._components[param1.name];
         return true;
      }
      
      private function doResetComponents() : void
      {
         var _loc2_:IEntityComponent = null;
         var _loc1_:Boolean = this._deferring;
         this.deferring = true;
         for each(_loc2_ in this._components)
         {
            if(_loc2_.isRegistered)
            {
               _loc2_.reset();
            }
         }
         this.deferring = false;
      }
      
      private function findProperty(param1:PropertyReference, param2:Boolean = false, param3:PropertyInfo = null, param4:Boolean = false) : PropertyInfo
      {
         var propertyName:String;
         var path:Array;
         var isTemplateXML:Boolean;
         var itemName:String;
         var curIdx:int;
         var startChar:String;
         var curLookup:String;
         var parentElem:* = undefined;
         var cl:Array = null;
         var cachedWalk:* = undefined;
         var clLength:uint = 0;
         var i:int = 0;
         var cachedPi:PropertyInfo = null;
         var comLookup:IEntityComponent = null;
         var nextElem:* = undefined;
         var cTag:* = undefined;
         var oldParentElem:* = undefined;
         var gotEmpty:Boolean = false;
         var pi:PropertyInfo = null;
         var reference:PropertyReference = param1;
         var willSet:Boolean = param2;
         var providedPi:PropertyInfo = param3;
         var suppressErrors:Boolean = param4;
         if(!reference || reference.property == null || reference.property == "")
         {
            return null;
         }
         if(!providedPi)
         {
            providedPi = new PropertyInfo();
         }
         if(Boolean(reference.cachedLookup) && reference.cachedLookup.length > 0)
         {
            cl = reference.cachedLookup;
            cachedWalk = this.lookupComponentByName(cl[0]);
            if(!cachedWalk)
            {
               if(!suppressErrors)
               {
                  Logger.warn(this,"findProperty","Could not resolve component named \'" + cl[0] + "\' for property \'" + reference.property + "\' with cached reference. " + Logger.getCallStack());
               }
               return null;
            }
            clLength = cl.length;
            i = 1;
            while(i < clLength - 1)
            {
               cachedWalk = cachedWalk[cl[i]];
               if(cachedWalk == null)
               {
                  if(!suppressErrors)
                  {
                     Logger.warn(this,"findProperty","Could not resolve property \'" + cl[i] + "\' for property reference \'" + reference.property + "\' with cached reference" + Logger.getCallStack());
                  }
                  return null;
               }
               i++;
            }
            cachedPi = providedPi;
            cachedPi.propertyParent = cachedWalk;
            cachedPi.propertyName = clLength > 1 ? cl[clLength - 1] : null;
            return cachedPi;
         }
         propertyName = reference.property;
         path = propertyName.split(".");
         isTemplateXML = false;
         itemName = path[0];
         curIdx = 1;
         startChar = itemName.charAt(0);
         curLookup = itemName.slice(1);
         if(startChar == "@")
         {
            parentElem = this.lookupComponentByName(curLookup);
            if(!parentElem)
            {
               if(!suppressErrors)
               {
                  Logger.warn(this,"findProperty","Could not resolve component named \'" + curLookup + "\' for property \'" + reference.property + "\'");
               }
               return null;
            }
            path[0] = curLookup;
            reference.cachedLookup = path;
         }
         else if(startChar == "#")
         {
            parentElem = Zlab.nameManager.lookup(curLookup);
            if(!parentElem)
            {
               Logger.warn(this,"findProperty","Could not resolve named object named \'" + curLookup + "\' for property \'" + reference.property + "\'");
               return null;
            }
            curIdx++;
            curLookup = path[1];
            comLookup = (parentElem as IEntity).lookupComponentByName(curLookup);
            if(!comLookup)
            {
               Logger.warn(this,"findProperty","Could not find component \'" + curLookup + "\' on named entity \'" + (parentElem as IEntity).name + "\' for property \'" + reference.property + "\'");
               return null;
            }
            parentElem = comLookup;
         }
         else
         {
            if(startChar != "!")
            {
               Logger.warn(this,"findProperty","Got a property path that doesn\'t start with !, #, or @. Started with \'" + startChar + "\' for property \'" + reference.property + "\'");
               return null;
            }
            parentElem = Zlab.templateManager.getXML(curLookup,"template","entity");
            if(!parentElem)
            {
               Logger.warn(this,"findProperty","Could not find XML named \'" + curLookup + "\' for property \'" + reference.property + "\'");
               return null;
            }
            curIdx++;
            nextElem = null;
            for each(cTag in parentElem.*)
            {
               if(cTag.@name == path[1])
               {
                  nextElem = cTag;
                  break;
               }
            }
            if(!nextElem && willSet)
            {
               (parentElem as XML).appendChild(<component name={path[1]}/>);
               for each(cTag in parentElem.*)
               {
                  if(cTag.@name == path[1])
                  {
                     nextElem = cTag;
                     break;
                  }
               }
            }
            if(!nextElem)
            {
               Logger.warn(this,"findProperty","Could not find component \'" + path[1] + "\' in XML template \'" + path[0].slice(1) + "\' for property \'" + reference.property + "\'");
               return null;
            }
            parentElem = nextElem;
            isTemplateXML = true;
         }
         if(curIdx < path.length)
         {
            curLookup = path[curIdx++] as String;
         }
         else
         {
            curLookup = null;
         }
         while(curIdx < path.length && Boolean(parentElem))
         {
            oldParentElem = parentElem;
            try
            {
               if(parentElem is XML || parentElem is XMLList)
               {
                  parentElem = parentElem.child(curLookup);
               }
               else
               {
                  parentElem = parentElem[curLookup];
               }
            }
            catch(e:Error)
            {
               parentElem = null;
            }
            gotEmpty = false;
            if(parentElem == undefined)
            {
               gotEmpty = true;
            }
            if(parentElem == null)
            {
               gotEmpty = true;
            }
            if(parentElem is XMLList && parentElem.length() == 0)
            {
               gotEmpty = true;
            }
            if(willSet && isTemplateXML && gotEmpty && Boolean(oldParentElem))
            {
               oldParentElem.appendChild(new XML("<" + curLookup + "/>"));
               parentElem = oldParentElem.child(curLookup);
               gotEmpty = false;
            }
            if(gotEmpty)
            {
               Logger.warn(this,"findProperty","Could not resolve property \'" + curLookup + "\' for property reference \'" + reference.property + "\'");
               return null;
            }
            curLookup = path[curIdx++] as String;
         }
         if(parentElem)
         {
            pi = providedPi;
            pi.propertyParent = parentElem;
            pi.propertyName = curLookup;
            return pi;
         }
         return null;
      }
   }
}

import zlabs.entity.IEntityComponent;

final class PendingComponent
{
   
   public var item:IEntityComponent;
   
   public var name:String;
   
   public function PendingComponent()
   {
      super();
   }
}
