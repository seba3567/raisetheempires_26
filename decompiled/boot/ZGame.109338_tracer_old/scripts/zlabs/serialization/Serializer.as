package zlabs.serialization
{
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   import zlabs.debug.Logger;
   import zlabs.entity.IEntity;
   import zlabs.entity.IEntityComponent;
   
   public class Serializer
   {
      
      private static var _instance:Serializer = null;
      
      private var _currentEntity:IEntity = null;
      
      private var _serializers:Dictionary = new Dictionary();
      
      private var _deserializers:Dictionary = new Dictionary();
      
      private var _deferredReferences:Array = new Array();
      
      private var _resources:Dictionary = new Dictionary();
      
      public function Serializer()
      {
         super();
         this._deserializers["::DefaultSimple"] = this.deserializeSimple;
         this._deserializers["::DefaultComplex"] = this.dserializeComplex;
         this._deserializers["Boolean"] = this.deserializeBoolean;
         this._deserializers["Array"] = this.deserializeDictionary;
         this._deserializers["flash.utils::Dictionary"] = this.deserializeDictionary;
         this._deserializers["Class"] = this.deserializeClass;
         this._serializers["::DefaultSimple"] = this.serializeSimple;
         this._serializers["::DefaultComplex"] = this.serializeComplex;
         this._serializers["Boolean"] = this.serializeBoolean;
         this._serializers["Array"] = this.serializeDictionary;
         this._serializers["flash.utils::Dictionary"] = this.serializeDictionary;
         var _loc1_:TestForMetadata = new TestForMetadata();
         if(TypeUtility.getTypeHint(_loc1_,"someArray") != "Number")
         {
            Logger.print(this,"Metadata is not included in this build of the engine, so serialization will not work!\n" + "Add --keep-as3-metadata+=TypeHint,EditorData,Embed to your compiler arguments to get around this.");
         }
      }
      
      public static function get instance() : Serializer
      {
         if(!_instance)
         {
            _instance = new Serializer();
         }
         return _instance;
      }
      
      public function serialize(param1:*, param2:XML) : void
      {
         var _loc3_:String = null;
         if(param1 is ISerializable)
         {
            (param1 as ISerializable).serialize(param2);
         }
         else if(param1 is IEntity)
         {
            this._currentEntity = param1 as IEntity;
            this._currentEntity.serialize(param2);
         }
         else
         {
            _loc3_ = TypeUtility.getObjectClassName(param1);
            if(!this._serializers[_loc3_])
            {
               _loc3_ = this.isSimpleType(param1) ? "::DefaultSimple" : "::DefaultComplex";
            }
            this._serializers[_loc3_](param1,param2);
         }
      }
      
      public function deserialize(param1:*, param2:XML, param3:String = null) : *
      {
         if(param1 is ISerializable)
         {
            return ISerializable(param1).deserialize(param2);
         }
         if(param1 is IEntity)
         {
            this._currentEntity = param1 as IEntity;
            this._currentEntity.deserialize(param2,true);
            this.resolveReferences();
            return param1 as IEntity;
         }
         var _loc4_:String = TypeUtility.getObjectClassName(param1);
         if(!this._deserializers[_loc4_])
         {
            _loc4_ = param2.hasSimpleContent() ? "::DefaultSimple" : "::DefaultComplex";
         }
         return this._deserializers[_loc4_](param1,param2,param3);
      }
      
      public function setCurrentEntity(param1:IEntity) : void
      {
         this._currentEntity = param1;
      }
      
      public function clearCurrentEntity() : void
      {
         this._currentEntity = null;
      }
      
      public function reportMissingReferences() : void
      {
         var _loc2_:ReferenceNote = null;
         var _loc1_:int = 0;
         while(_loc1_ < this._deferredReferences.length)
         {
            _loc2_ = this._deferredReferences[_loc1_];
            _loc2_.reportMissing();
            _loc1_++;
         }
      }
      
      private function isSimple(param1:XML, param2:String) : Boolean
      {
         if(param2 == "String")
         {
            return true;
         }
         if(param1.hasComplexContent())
         {
            return false;
         }
         if(param1.toString() == "")
         {
            return false;
         }
         return true;
      }
      
      private function isSimpleType(param1:*) : Boolean
      {
         var _loc2_:String = TypeUtility.getObjectClassName(param1);
         if(_loc2_ == "String" || _loc2_ == "int" || _loc2_ == "Number" || _loc2_ == "uint" || _loc2_ == "Boolean")
         {
            return true;
         }
         return false;
      }
      
      private function deserializeSimple(param1:*, param2:XML, param3:String) : *
      {
         if(param2.toString() == "" && !(param1 is String))
         {
            return param1;
         }
         return param2.toString();
      }
      
      private function serializeSimple(param1:*, param2:XML) : void
      {
         param2.appendChild(param1.toString());
      }
      
      private function dserializeComplex(param1:*, param2:XML, param3:String) : *
      {
         var xmlPath:String = null;
         var fieldXML:XML = null;
         var fieldName:String = null;
         var typeName:String = null;
         var decappedFieldName:String = null;
         var foundOffcaseMatch:Boolean = false;
         var potentialField:String = null;
         var child:* = undefined;
         var childTypeHint:String = null;
         var object:* = param1;
         var xml:XML = param2;
         var typeHint:String = param3;
         var isDynamic:Boolean = object is Array || object is Dictionary || TypeUtility.isDynamic(object);
         xmlPath = "";
         for each(fieldXML in xml.*)
         {
            fieldName = fieldXML.name().toString();
            if(!object.hasOwnProperty(fieldName) && !isDynamic)
            {
               decappedFieldName = fieldName.charAt(0).toLowerCase() + fieldName.substr(1);
               if(object.hasOwnProperty(decappedFieldName))
               {
                  fieldName = decappedFieldName;
               }
               else
               {
                  foundOffcaseMatch = false;
                  for(potentialField in object as Object)
                  {
                     if(potentialField.toLowerCase() == fieldName.toLowerCase())
                     {
                        fieldName = potentialField;
                        foundOffcaseMatch = true;
                        break;
                     }
                  }
                  if(foundOffcaseMatch == false)
                  {
                     xmlPath = this.reportXMLPath(fieldXML);
                     Logger.warn(object,"deserialize","The field \'" + fieldName + "\' does not exist on the class " + TypeUtility.getObjectClassName(object) + ". " + xmlPath);
                     continue;
                  }
               }
            }
            typeName = fieldXML.attribute("type");
            if(typeName.length < 1)
            {
               typeName = TypeUtility.getFieldType(object,fieldName);
            }
            if(isDynamic && typeName == null)
            {
               typeName = "String";
            }
            if(!this.getChildReference(object,fieldName,fieldXML) && !this.getResourceObject(object,fieldName,fieldXML))
            {
               child = this.getChildObject(object,fieldName,typeName,fieldXML);
               if(child != null)
               {
                  childTypeHint = TypeUtility.getTypeHint(object,fieldName);
                  child = this.deserialize(child,fieldXML,childTypeHint);
               }
               try
               {
                  object[fieldName] = child;
               }
               catch(e:Error)
               {
                  xmlPath = reportXMLPath(fieldXML);
                  Logger.error(object,"deserialize","The field " + fieldName + " could not be set to \'" + child + "\' due to: " + e.toString() + " " + xmlPath);
               }
            }
         }
         return object;
      }
      
      public function reportXMLPath(param1:*) : String
      {
         var _loc6_:* = undefined;
         var _loc2_:String = "(";
         var _loc3_:Array = [];
         var _loc4_:* = param1;
         while(_loc4_)
         {
            _loc3_.unshift(_loc4_);
            _loc4_ = _loc4_.parent();
         }
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_.length)
         {
            _loc6_ = _loc3_[_loc5_];
            _loc2_ += "<" + _loc6_.name().toString();
            if(_loc6_.hasOwnProperty("@name"))
            {
               _loc2_ += " name=\"" + _loc6_.@name + "\"";
            }
            _loc2_ += ">";
            if(_loc5_ < _loc3_.length - 1)
            {
               _loc2_ += " --> ";
            }
            _loc5_++;
         }
         return _loc2_ + ")";
      }
      
      private function serializeComplex(param1:*, param2:XML) : void
      {
         var _loc4_:XML = null;
         var _loc5_:XML = null;
         var _loc6_:String = null;
         var _loc7_:XML = null;
         var _loc8_:String = null;
         var _loc9_:XML = null;
         if(param1 == null)
         {
            return;
         }
         var _loc3_:XML = TypeUtility.getTypeDescription(param1);
         for each(_loc4_ in _loc3_.child("accessor"))
         {
            if(_loc4_.@access == "readwrite")
            {
               _loc6_ = _loc4_.@name;
               if(param1[_loc6_] != null)
               {
                  _loc7_ = this.serializeProperty(param1,_loc6_);
                  if(_loc7_ != null)
                  {
                     param2.appendChild(_loc7_);
                  }
               }
            }
         }
         for each(_loc5_ in _loc3_.child("variable"))
         {
            _loc8_ = _loc5_.@name;
            if(param1[_loc8_] != null)
            {
               _loc9_ = this.serializeProperty(param1,_loc8_);
               if(_loc9_ != null)
               {
                  param2.appendChild(_loc9_);
               }
            }
         }
      }
      
      private function serializeProperty(param1:*, param2:String) : XML
      {
         var ignore:XMLList = null;
         var defaultValue:XMLList = null;
         var object:* = param1;
         var propertyName:String = param2;
         var propertyXML:XML = new XML("<" + propertyName + "/>");
         var data:XML = TypeUtility.getEditorData(object,propertyName);
         var typeHint:String = TypeUtility.getTypeHint(object,propertyName);
         if(Boolean(typeHint) && typeHint == "dynamic")
         {
            if(!isNaN(object[propertyName]))
            {
               propertyXML.@type = getQualifiedClassName(1);
            }
            else
            {
               propertyXML.@type = getQualifiedClassName(object[propertyName]);
            }
         }
         if(data)
         {
            ignore = data.arg.(@key == "ignore");
            if(Boolean(ignore) && ignore.@value.toString() == "true")
            {
               return null;
            }
         }
         if(!this.setChildReference(object,object[propertyName],propertyXML))
         {
            this.serialize(object[propertyName],propertyXML);
            defaultValue = data ? data.arg.(@key == "defaultValue") : null;
            if(Boolean(defaultValue) && object[propertyName].toString() == defaultValue.@value.toString())
            {
               return null;
            }
         }
         return propertyXML;
      }
      
      private function deserializeBoolean(param1:*, param2:XML, param3:String) : *
      {
         return param2.toString() == "true";
      }
      
      private function serializeBoolean(param1:*, param2:XML) : void
      {
         if(param1)
         {
            param2.appendChild("true");
         }
         else
         {
            param2.appendChild("false");
         }
      }
      
      private function deserializeDictionary(param1:*, param2:XML, param3:String) : *
      {
         var _loc4_:XML = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:* = undefined;
         for each(_loc4_ in param2.*)
         {
            _loc5_ = _loc4_.name().toString();
            if(_loc5_.charAt(0) == "_")
            {
               _loc5_ = _loc5_.slice(1);
            }
            if(_loc5_.length < 1 && !(param1 is Array))
            {
               _loc7_ = this.reportXMLPath(_loc4_);
               Logger.error(param1,"deserialize","Cannot add a value to a dictionary without a key. " + _loc7_);
            }
            else
            {
               _loc6_ = _loc4_.attribute("type");
               if(_loc6_.length < 1)
               {
                  _loc6_ = param2.attribute("childType");
               }
               if(_loc6_ == null || _loc6_ == "")
               {
                  _loc6_ = param3 ? param3 : "String";
               }
               if(!this.getChildReference(param1,_loc5_,_loc4_) && !this.getResourceObject(param1,_loc5_,_loc4_,param3))
               {
                  _loc8_ = this.getChildObject(param1,_loc5_,_loc6_,_loc4_);
                  if(_loc8_ != null)
                  {
                     _loc8_ = this.deserialize(_loc8_,_loc4_);
                  }
                  if(_loc5_.length > 0)
                  {
                     param1[_loc5_] = _loc8_;
                  }
                  else
                  {
                     (param1 as Array).push(_loc8_);
                  }
               }
            }
         }
         return param1;
      }
      
      private function serializeDictionary(param1:*, param2:XML) : void
      {
         var _loc5_:* = undefined;
         var _loc6_:* = undefined;
         var _loc7_:String = null;
         var _loc8_:* = undefined;
         var _loc9_:XML = null;
         if(param1 == null)
         {
            return;
         }
         var _loc3_:Boolean = true;
         var _loc4_:* = null;
         for each(_loc5_ in param1)
         {
            if(_loc4_ == null)
            {
               _loc4_ = _loc5_;
            }
            else if(_loc5_ != null && TypeUtility.getClass(_loc5_) != TypeUtility.getClass(_loc4_))
            {
               _loc3_ = false;
            }
         }
         if(_loc4_ == null)
         {
            return;
         }
         if(_loc3_)
         {
            param2.@childType = TypeUtility.getObjectClassName(_loc4_).replace(/::/,".");
         }
         for(_loc6_ in param1)
         {
            _loc7_ = param1 is Dictionary ? _loc6_ : "_";
            _loc8_ = param1[_loc6_];
            _loc9_ = new XML("<" + _loc7_ + "/>");
            if(!_loc3_)
            {
               _loc9_.@type = TypeUtility.getObjectClassName(_loc8_).replace(/::/,".");
            }
            if(!this.setChildReference(param1,_loc8_,_loc9_))
            {
               this.serialize(_loc8_,_loc9_);
            }
            param2.appendChild(_loc9_);
         }
      }
      
      private function deserializeClass(param1:*, param2:XML, param3:String) : *
      {
         return TypeUtility.getClassFromName(param2.toString());
      }
      
      private function getChildReference(param1:*, param2:String, param3:XML) : Boolean
      {
         var _loc8_:ReferenceNote = null;
         var _loc4_:String = param3.attribute("nameReference");
         var _loc5_:String = param3.attribute("componentReference");
         if(!_loc5_)
         {
            _loc5_ = param3.attribute("entityName");
         }
         var _loc6_:String = param3.attribute("componentName");
         var _loc7_:String = param3.attribute("objectReference");
         if(_loc4_ != "" || _loc5_ != "" || _loc6_ != "" || _loc7_ != "")
         {
            _loc8_ = new ReferenceNote();
            _loc8_.owner = param1;
            _loc8_.fieldName = param2;
            _loc8_.nameReference = _loc4_;
            _loc8_.componentReference = _loc5_;
            _loc8_.componentName = _loc6_;
            _loc8_.objectReference = _loc7_;
            _loc8_.currentEntity = this._currentEntity;
            if(!_loc8_.resolve())
            {
               this._deferredReferences.push(_loc8_);
            }
            return true;
         }
         return false;
      }
      
      private function setChildReference(param1:*, param2:*, param3:XML) : Boolean
      {
         if(param2 is IEntity)
         {
            param3.@nameReference = (param2 as IEntity).name;
            return true;
         }
         if(param2 is IEntityComponent)
         {
            param3.@entityName = (param2 as IEntityComponent).owner.name;
            param3.@componentName = (param2 as IEntityComponent).name;
            return true;
         }
         return false;
      }
      
      private function getChildObject(param1:*, param2:String, param3:String, param4:XML) : *
      {
         var desiredType:Class;
         var childObject:* = undefined;
         var xmlPath:String = null;
         var object:* = param1;
         var fieldName:String = param2;
         var typeName:String = param3;
         var fieldXml:XML = param4;
         try
         {
            childObject = object[fieldName];
         }
         catch(e:Error)
         {
         }
         desiredType = TypeUtility.getClassFromName(typeName);
         if(!(childObject is desiredType) || !childObject)
         {
            childObject = TypeUtility.instantiate(typeName);
         }
         if(childObject == null)
         {
            xmlPath = this.reportXMLPath(fieldXml);
            Logger.error(object,"deserialize","Unable to create type " + typeName + " for the field " + fieldName + ". " + xmlPath);
            return null;
         }
         return childObject;
      }
      
      private function getResourceObject(param1:*, param2:String, param3:XML, param4:String = null) : Boolean
      {
         var _loc5_:String = param3.attribute("filename");
         if(_loc5_ == "")
         {
            _loc5_ = param3.child("filename");
         }
         if(_loc5_ == "")
         {
            return false;
         }
         var _loc6_:Class = null;
         if(param4)
         {
            _loc6_ = TypeUtility.getClassFromName(param4);
         }
         else
         {
            _loc6_ = TypeUtility.getClassFromName(TypeUtility.getFieldType(param1,param2));
         }
         var _loc7_:ResourceNote = new ResourceNote();
         _loc7_.owner = param1;
         _loc7_.fieldName = param2;
         _loc7_.load(_loc5_,_loc6_);
         this._resources[_loc5_] = _loc7_;
         return true;
      }
      
      public function removeResource(param1:String) : void
      {
         this._resources[param1] = null;
         delete this._resources[param1];
      }
      
      public function resolveReferences() : void
      {
         var _loc2_:ReferenceNote = null;
         var _loc1_:* = 0;
         while(_loc1_ < this._deferredReferences.length)
         {
            _loc2_ = this._deferredReferences[_loc1_];
            if(_loc2_.resolve())
            {
               this._deferredReferences.splice(_loc1_,1);
               _loc1_--;
            }
            _loc1_++;
         }
      }
   }
}

import zlabs.Zlab;
import zlabs.entity.IEntity;
import zlabs.entity.IEntityComponent;
import zlabs.resource.Resource;
import zlabs.serialization.Serializer;
import zlabs.serialization.TypeUtility;

class ResourceNote
{
   
   public var owner:* = null;
   
   public var fieldName:String = null;
   
   public function ResourceNote()
   {
      super();
   }
   
   public function load(param1:String, param2:Class) : void
   {
      var _loc3_:Resource = Zlab.resourceManager.load(param1,param2,this.onLoaded,this.onFailed);
      if(_loc3_)
      {
         this.owner[this.fieldName] = _loc3_;
      }
   }
   
   public function onLoaded(param1:Resource) : void
   {
      Serializer.instance.removeResource(param1.filename);
   }
   
   public function onFailed(param1:Resource) : void
   {
      Serializer.instance.removeResource(param1.filename);
   }
}

class ReferenceNote
{
   
   public var owner:* = null;
   
   public var fieldName:String = null;
   
   public var nameReference:String = null;
   
   public var componentReference:String = null;
   
   public var componentName:String = null;
   
   public var objectReference:String = null;
   
   public var currentEntity:IEntity = null;
   
   public var reportedMissing:Boolean = false;
   
   public function ReferenceNote()
   {
      super();
   }
   
   public function resolve() : Boolean
   {
      var _loc1_:IEntity = null;
      var _loc2_:IEntity = null;
      var _loc3_:IEntityComponent = null;
      var _loc4_:String = null;
      var _loc5_:IEntityComponent = null;
      if(this.nameReference != "")
      {
         _loc1_ = Zlab.nameManager.lookup(this.nameReference);
         if(!_loc1_)
         {
            return false;
         }
         this.owner[this.fieldName] = _loc1_;
         this.reportSuccess();
         return true;
      }
      if(this.componentReference != "")
      {
         _loc2_ = Zlab.nameManager.lookup(this.componentReference);
         if(!_loc2_)
         {
            return false;
         }
         _loc3_ = null;
         if(this.componentName != "")
         {
            _loc3_ = _loc2_.lookupComponentByName(this.componentName);
            if(!_loc3_)
            {
               return false;
            }
         }
         else
         {
            _loc4_ = TypeUtility.getFieldType(this.owner,this.fieldName);
            _loc3_ = _loc2_.lookupComponentByType(TypeUtility.getClassFromName(_loc4_));
            if(!_loc3_)
            {
               return false;
            }
         }
         this.owner[this.fieldName] = _loc3_;
         this.reportSuccess();
         return true;
      }
      if(this.componentName != "")
      {
         _loc5_ = this.currentEntity.lookupComponentByName(this.componentName);
         if(!_loc5_)
         {
            return false;
         }
         this.owner[this.fieldName] = _loc5_;
         this.reportSuccess();
         return true;
      }
      if(this.objectReference != "")
      {
         this.owner[this.fieldName] = Zlab.templateManager.instantiateEntity(this.objectReference);
         this.reportSuccess();
         return true;
      }
      return false;
   }
   
   public function reportMissing() : void
   {
      if(this.reportedMissing)
      {
         return;
      }
      this.reportedMissing = true;
      var _loc1_:String = this.owner.toString() + "[" + this.fieldName + "] on entity \'" + this.currentEntity.name + "\' - ";
      if(this.nameReference)
      {
         return;
      }
      if(this.componentReference != "")
      {
         return;
      }
      if(this.componentName != "")
      {
         return;
      }
   }
   
   private function reportSuccess() : void
   {
      if(!this.reportedMissing)
      {
         return;
      }
      var _loc1_:String = this.owner.toString() + "[" + this.fieldName + "] on entity \'" + this.currentEntity.name + "\' - ";
      if(this.nameReference)
      {
         return;
      }
      if(this.componentReference != "")
      {
         return;
      }
      if(this.componentName != "")
      {
         return;
      }
   }
}
