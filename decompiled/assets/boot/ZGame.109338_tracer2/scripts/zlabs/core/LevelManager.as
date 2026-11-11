package zlabs.core
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.entity.IEntity;
   import zlabs.resource.XMLResource;
   import zlabs.serialization.ISerializable;
   import zlabs.serialization.Serializer;
   
   [Event(name="LEVEL_UNLOADED_EVENT",type="com.pblabs.engine.core.LevelEvent")]
   [Event(name="LEVEL_LOADED_EVENT",type="com.pblabs.engine.core.LevelEvent")]
   [Event(name="READY_EVENT",type="com.pblabs.engine.core.LevelEvent")]
   public class LevelManager extends EventDispatcher implements ISerializable
   {
      
      private static var _instance:LevelManager = null;
      
      private var _initialLevel:int = -1;
      
      private var _isReady:Boolean = false;
      
      private var _isLevelLoaded:Boolean = false;
      
      private var _currentLevel:int = 0;
      
      private var _levelDescriptions:Array = new Array();
      
      private var _pendingFiles:int = 0;
      
      private var _groupsToLoad:Array;
      
      private var _loadedFiles:Array = new Array();
      
      private var _loadedGroups:Dictionary = new Dictionary();
      
      private var _loadedEntities:Array = new Array();
      
      private var _loadFileCallback:Function = null;
      
      private var _unloadFileCallback:Function = null;
      
      private var _loadGroupCallback:Function = null;
      
      private var _unloadGroupCallback:Function = null;
      
      public function LevelManager()
      {
         super();
      }
      
      public static function get instance() : LevelManager
      {
         if(!_instance)
         {
            _instance = new LevelManager();
         }
         return _instance;
      }
      
      public function get currentLevel() : int
      {
         if(this._isLevelLoaded)
         {
            return this._currentLevel;
         }
         return -1;
      }
      
      public function get levelCount() : int
      {
         var _loc2_:LevelDescription = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this._levelDescriptions)
         {
            _loc1_++;
         }
         return _loc1_;
      }
      
      public function getlevelFiles(param1:int) : Array
      {
         return this._levelDescriptions[param1].Files;
      }
      
      public function getlevelGroups(param1:int) : Array
      {
         return this._levelDescriptions[param1].Groups;
      }
      
      public function getlevelIndexByName(param1:String) : int
      {
         var _loc2_:LevelDescription = null;
         for each(_loc2_ in this._levelDescriptions)
         {
            if(_loc2_.name == param1)
            {
               return _loc2_.index;
            }
         }
         return -1;
      }
      
      public function setLoadFileCallbacks(param1:Function, param2:Function) : void
      {
         this._loadFileCallback = param1;
         this._unloadFileCallback = param2;
      }
      
      public function setLoadGroupCallbacks(param1:Function, param2:Function) : void
      {
         this._loadGroupCallback = param1;
         this._unloadGroupCallback = param2;
      }
      
      public function start(param1:int = -1) : void
      {
         if(this._isReady)
         {
            Logger.error(this,"Start","The LevelManager has already been started.");
            return;
         }
         Zlab.templateManager.addEventListener(TemplateManager.LOADED_EVENT,this.onFileLoaded);
         Zlab.templateManager.addEventListener(TemplateManager.FAILED_EVENT,this.onFileLoadFailed);
         this._isReady = true;
         dispatchEvent(new LevelEvent(LevelEvent.READY_EVENT,-1));
         if(param1 != -1)
         {
            this.loadLevel(param1);
         }
      }
      
      public function load(param1:String, param2:int = -1) : void
      {
         if(this._isReady)
         {
            Logger.error(this,"Load","The LevelManager has already been started.");
            return;
         }
         this._initialLevel = param2;
         Zlab.resourceManager.load(param1,XMLResource,this.onLevelDescriptionsLoaded,this.onLevelDescriptionsLoadFailed);
      }
      
      private function onLevelDescriptionsLoaded(param1:XMLResource) : void
      {
         Serializer.instance.deserialize(this,param1.XMLData);
         Logger.print(this,"Loaded " + this._levelDescriptions.length + " level descriptions.");
      }
      
      private function onLevelDescriptionsLoadFailed(param1:XMLResource) : void
      {
         if(param1)
         {
            Logger.error(this,"Load","Failed to load level descriptions file " + param1.filename + "!");
         }
         else
         {
            Logger.error(this,"Load","Failed to load level descriptions file!");
         }
      }
      
      public function clear() : void
      {
         this.unloadCurrentLevel();
         this._currentLevel = 0;
         this._levelDescriptions = new Array();
         this._isReady = false;
      }
      
      public function serialize(param1:XML) : void
      {
         var _loc2_:LevelDescription = null;
         var _loc3_:XML = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         for each(_loc2_ in this._levelDescriptions)
         {
            _loc3_ = <level/>;
            _loc3_.@index = _loc2_.index;
            _loc3_.@name = _loc2_.name;
            for each(_loc4_ in _loc2_.files)
            {
               _loc3_.appendChild(<file name={_loc4_}/>);
            }
            for each(_loc5_ in _loc2_.groups)
            {
               _loc3_.appendChild(<group name={_loc5_}/>);
            }
         }
      }
      
      public function deserialize(param1:XML) : *
      {
         var _loc2_:XML = null;
         var _loc3_:int = 0;
         var _loc4_:LevelDescription = null;
         var _loc5_:XML = null;
         for each(_loc2_ in param1.*)
         {
            _loc3_ = int(_loc2_.@index);
            _loc4_ = new LevelDescription();
            _loc4_.index = _loc3_;
            _loc4_.name = _loc2_.@name;
            this._levelDescriptions[_loc3_] = _loc4_;
            for each(_loc5_ in _loc2_.*)
            {
               if(_loc5_.name() == "file")
               {
                  this.addFileReference(_loc3_,_loc5_.@filename);
               }
               else if(_loc5_.name() == "group")
               {
                  this.addGroupReference(_loc3_,_loc5_.@name);
               }
               else
               {
                  Logger.error(this,"Load","Encountered unknown tag " + _loc5_.name() + " in level description.");
               }
            }
         }
         this.start(this._initialLevel);
      }
      
      public function loadEntity(param1:String) : IEntity
      {
         if(!this._isReady)
         {
            Logger.error(this,"loadEntity","Cannot load entities. The LevelManager has not been started.");
            return null;
         }
         if(!this._isLevelLoaded)
         {
            Logger.error(this,"loadEntity","Cannot load entities. No level is loaded.");
            return null;
         }
         var _loc2_:IEntity = Zlab.templateManager.instantiateEntity(param1);
         if(!_loc2_)
         {
            Logger.error(this,"loadEntity","Failed to instantiate an entity with name " + param1 + ".");
            return null;
         }
         _loc2_.eventDispatcher.addEventListener("EntityDestroyed",this.onEntityDestroyed);
         this._loadedEntities.push(_loc2_);
         return _loc2_;
      }
      
      public function loadLevel(param1:int, param2:Boolean = false) : void
      {
         var _loc7_:String = null;
         if(!this._isReady)
         {
            Logger.warn(this,"loadLevel","Warning: trying to loadLevel() without having first called start()! This probably won\'t work.");
         }
         if(!this.hasLevelData(param1))
         {
            Logger.error(this,"loadLevel","Level data for level " + param1 + " does not exist.");
            return;
         }
         var _loc3_:Array = new Array();
         var _loc4_:Array = new Array();
         var _loc5_:Boolean = this._isLevelLoaded && this._currentLevel != 0;
         this.getLoadLists(_loc5_ ? this._levelDescriptions[this._currentLevel].files : null,this._levelDescriptions[param1].files,_loc3_,_loc4_);
         this._groupsToLoad = new Array();
         var _loc6_:Array = new Array();
         this.getLoadLists(_loc5_ ? this._levelDescriptions[this._currentLevel].groups : null,this._levelDescriptions[param1].groups,this._groupsToLoad,_loc6_);
         this.unload(_loc4_,_loc6_);
         dispatchEvent(new LevelEvent(LevelEvent.LEVEL_UNLOADED_EVENT,this._currentLevel));
         this._currentLevel = param1;
         this._isLevelLoaded = true;
         this._pendingFiles = 1;
         for each(_loc7_ in _loc3_)
         {
            ++this._pendingFiles;
            if(this._loadFileCallback != null)
            {
               this._loadFileCallback(_loc7_,this.finishLoad);
            }
            else
            {
               Zlab.templateManager.loadFile(_loc7_);
            }
         }
         this.finishLoad();
      }
      
      private function onFileLoaded(param1:Event) : void
      {
         this.finishLoad();
      }
      
      private function onFileLoadFailed(param1:Event) : void
      {
         Logger.error(this,"LoadLevel","One of the files for level " + this._currentLevel + " failed to load.");
         this.finishLoad();
      }
      
      private function finishLoad() : void
      {
         var _loc1_:String = null;
         var _loc2_:Array = null;
         var _loc3_:IEntity = null;
         --this._pendingFiles;
         if(this._pendingFiles > 0)
         {
            return;
         }
         for each(_loc1_ in this._groupsToLoad)
         {
            if(this._loadGroupCallback != null)
            {
               this._loadGroupCallback(_loc1_);
            }
            else
            {
               _loc2_ = Zlab.templateManager.instantiateGroup(_loc1_);
               if(!_loc2_)
               {
                  Logger.error(this,"LoadLevel","Failed to instantiate the group " + _loc1_ + ".");
               }
               else
               {
                  this._loadedGroups[_loc1_] = new Array();
                  for each(_loc3_ in _loc2_)
                  {
                     this._loadedGroups[_loc1_].push(_loc3_);
                  }
               }
            }
         }
         this._groupsToLoad = null;
         dispatchEvent(new LevelEvent(LevelEvent.LEVEL_LOADED_EVENT,this._currentLevel));
      }
      
      public function loadNextLevel() : void
      {
         this.loadLevel(this._currentLevel + 1);
      }
      
      public function unloadCurrentLevel() : void
      {
         if(!this._isLevelLoaded)
         {
            Logger.error(this,"UnloadCurrentLevel","No level is loaded.");
            return;
         }
         var _loc1_:Array = new Array();
         this.getLoadLists(this._levelDescriptions[this._currentLevel].files,null,null,_loc1_);
         var _loc2_:Array = new Array();
         this.getLoadLists(this._levelDescriptions[this._currentLevel].groups,null,null,_loc2_);
         this.unload(_loc1_,_loc2_);
         dispatchEvent(new LevelEvent(LevelEvent.LEVEL_UNLOADED_EVENT,this._currentLevel));
         this._currentLevel = -1;
         this._isLevelLoaded = false;
      }
      
      private function unload(param1:Array, param2:Array) : void
      {
         var _loc3_:IEntity = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:IEntity = null;
         for each(_loc3_ in this._loadedEntities)
         {
            _loc3_.eventDispatcher.removeEventListener("EntityDestroyed",this.onEntityDestroyed);
            _loc3_.destroy();
         }
         this._loadedEntities.splice(0,this._loadedEntities.length);
         for each(_loc4_ in param2)
         {
            if(this._unloadGroupCallback != null)
            {
               this._unloadGroupCallback(_loc4_);
            }
            else
            {
               for each(_loc6_ in this._loadedGroups[_loc4_])
               {
                  if(_loc6_)
                  {
                     _loc6_.destroy();
                  }
               }
               this._loadedGroups[_loc4_] = null;
               delete this._loadedGroups[_loc4_];
            }
         }
         for each(_loc5_ in param1)
         {
            if(this._unloadFileCallback != null)
            {
               this._unloadFileCallback(_loc5_);
            }
            else
            {
               Zlab.templateManager.unloadFile(_loc5_);
               this._loadedFiles[_loc5_] = null;
               delete this._loadedFiles[_loc5_];
            }
         }
      }
      
      private function getLoadLists(param1:Array, param2:Array, param3:Array, param4:Array) : void
      {
         var _loc5_:String = null;
         var _loc6_:String = null;
         if(param2)
         {
            for each(_loc5_ in param2)
            {
               if(!(Boolean(param1) && param1.indexOf(_loc5_) != -1))
               {
                  param3.push(_loc5_);
               }
            }
         }
         if(param1)
         {
            for each(_loc6_ in param1)
            {
               if(!(Boolean(param2) && param2.indexOf(_loc6_) != -1))
               {
                  param4.push(_loc6_);
               }
            }
         }
      }
      
      private function onEntityDestroyed(param1:Event) : void
      {
      }
      
      public function addFileReference(param1:int, param2:String) : void
      {
         if(this._isLevelLoaded && this._currentLevel == param1)
         {
            Logger.error(this,"AddFileReference","Cannot add level information to a level that is loaded.");
            return;
         }
         var _loc3_:LevelDescription = this.getLevelDescription(param1);
         _loc3_.files.push(param2);
      }
      
      public function removeFileReference(param1:int, param2:String) : void
      {
         var _loc4_:LevelDescription = null;
         if(!this.hasLevelData(param1))
         {
            Logger.error(this,"RemoveFileReference","No level data exists for level " + param1 + ".");
            return;
         }
         var _loc3_:int = _loc4_.files.indexOf(param2);
         if(_loc3_ == -1)
         {
            Logger.error(this,"RemoveFileReference","The file " + param2 + " was not found in the level " + param1 + ".");
            return;
         }
         _loc4_ = this.getLevelDescription(param1);
         _loc4_.files.splice(_loc3_,1);
      }
      
      public function addGroupReference(param1:int, param2:String) : void
      {
         if(this._isLevelLoaded && this._currentLevel == param1)
         {
            Logger.error(this,"AddGroupReference","Cannot add level information to a level that is loaded.");
            return;
         }
         var _loc3_:LevelDescription = this.getLevelDescription(param1);
         _loc3_.groups.push(param2);
      }
      
      public function removeGroupReference(param1:int, param2:String) : void
      {
         var _loc4_:LevelDescription = null;
         if(!this.hasLevelData(param1))
         {
            Logger.error(this,"RemoveGroupReference","No level data exists for level " + param1 + ".");
            return;
         }
         var _loc3_:int = _loc4_.groups.indexOf(param2);
         if(_loc3_ == -1)
         {
            Logger.error(this,"RemoveFileReference","The group " + param2 + " was not found in the level " + param1 + ".");
            return;
         }
         _loc4_ = this.getLevelDescription(param1);
         _loc4_.groups.splice(_loc3_,1);
      }
      
      public function removeLevel(param1:int) : void
      {
         if(!this.hasLevelData(param1))
         {
            Logger.error(this,"RemoveLevel","No level data exists for level " + param1 + ".");
            return;
         }
         this._levelDescriptions[param1] = null;
         delete this._levelDescriptions[param1];
      }
      
      private function getLevelDescription(param1:int) : LevelDescription
      {
         var _loc2_:LevelDescription = this._levelDescriptions[param1];
         if(!_loc2_)
         {
            _loc2_ = new LevelDescription();
            _loc2_.index = param1;
            this._levelDescriptions[param1] = _loc2_;
         }
         return _loc2_;
      }
      
      private function hasLevelData(param1:int) : Boolean
      {
         return this._levelDescriptions[param1];
      }
   }
}

class LevelDescription
{
   
   public var name:String = "";
   
   public var index:int = 0;
   
   public var files:Array = new Array();
   
   public var groups:Array = new Array();
   
   public function LevelDescription()
   {
      super();
   }
}
