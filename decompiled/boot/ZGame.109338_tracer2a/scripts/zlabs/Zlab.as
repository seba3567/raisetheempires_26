package zlabs
{
   import br.com.stimuli.loading.BulkLoader;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.LoaderInfo;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.display.StageAlign;
   import flash.display.StageScaleMode;
   import flash.utils.Timer;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getTimer;
   import zlabs.core.InputKey;
   import zlabs.core.InputManager;
   import zlabs.core.LevelManager;
   import zlabs.core.NameManager;
   import zlabs.core.ObjectTypeManager;
   import zlabs.core.PBGroup;
   import zlabs.core.PBObject;
   import zlabs.core.ProcessManager;
   import zlabs.core.SchemaGenerator;
   import zlabs.core.TemplateManager;
   import zlabs.debug.Logger;
   import zlabs.entity.IEntity;
   import zlabs.entity.IEntityComponent;
   import zlabs.entity.PropertyReference;
   import zlabs.entity.allocateEntity;
   import zlabs.rendering.rendering2D.BasicSpatialManager2D;
   import zlabs.rendering.rendering2D.DisplayObjectScene;
   import zlabs.rendering.rendering2D.IScene2D;
   import zlabs.rendering.rendering2D.ISpatialManager2D;
   import zlabs.rendering.rendering2D.ui.IUITarget;
   import zlabs.resource.ResourceBundle;
   import zlabs.resource.ResourceManager;
   import zlabs.sound.ISoundManager;
   import zlabs.sound.SoundManager;
   
   public class Zlab
   {
      
      protected static var _spatialManager:ISpatialManager2D;
      
      protected static var _scene:DisplayObjectScene;
      
      protected static var m_serverTime:Number;
      
      public static var onFeedCloseCallback:Function;
      
      public static var IS_SHIPPING_BUILD:Boolean = false;
      
      public static var RENDER_DEBUG_MODE:Boolean = false;
      
      public static var stage:Stage = null;
      
      private static var _main:Sprite = null;
      
      private static var _stageQualityStack:Array = [];
      
      private static var _started:Boolean = false;
      
      protected static var _soundManager:SoundManager = null;
      
      protected static var _nameManager:NameManager = null;
      
      protected static var _resourceManager:ResourceManager = null;
      
      protected static var _templateManager:TemplateManager = null;
      
      protected static var _inputManager:InputManager = null;
      
      protected static var _processManager:ProcessManager = null;
      
      protected static var _objectTypeManager:ObjectTypeManager = null;
      
      protected static var _rootGroup:PBGroup = null;
      
      protected static var _currentGroup:PBGroup = null;
      
      public static var bulkLoader:BulkLoader = null;
      
      protected static var m_syncTime:Number = 0;
      
      public static var feedCallbackTimer:Timer = null;
      
      public function Zlab()
      {
         super();
      }
      
      public static function startup(param1:Sprite) : void
      {
         if(_started)
         {
            throw new Error("You can only call Zlab.startup once.");
         }
         if(!param1)
         {
            throw new Error("A mainClass must be specified");
         }
         if(!param1.stage)
         {
            throw new Error("Your mainClass must be added to the stage before you can call startup. If you\'re using MX make sure you call this from the applicationComplete event, not the creationComplete event");
         }
         _main = param1;
         initializeManagers();
         param1.stage.align = StageAlign.TOP_LEFT;
         param1.stage.scaleMode = StageScaleMode.NO_SCALE;
         Logger.print(Zlab,"Welcome! Zlab Startup thank you PBE");
         if(!IS_SHIPPING_BUILD && (Boolean(_main.loaderInfo && _main.loaderInfo.parameters) && Boolean(_main.loaderInfo.parameters["generateSchema"] == "1")))
         {
            SchemaGenerator.instance.generateSchema();
         }
         Logger.startup();
         _started = true;
      }
      
      public static function allocateEntity() : IEntity
      {
         return zlabs.entity.allocateEntity();
      }
      
      public static function registerType(param1:Class) : void
      {
         SchemaGenerator.instance.addClass(getQualifiedClassName(param1),param1);
      }
      
      protected static function initializeManagers() : void
      {
         var _loc1_:PBGroup = null;
         if(!_nameManager)
         {
            _nameManager = new NameManager();
         }
         if(!_rootGroup)
         {
            _loc1_ = new PBGroup();
            _rootGroup = _loc1_;
            _currentGroup = _loc1_;
            _loc1_.initialize("RootGroup");
         }
         if(!_processManager)
         {
            _processManager = new ProcessManager();
         }
         if(!_objectTypeManager)
         {
            _objectTypeManager = new ObjectTypeManager();
         }
         if(!_soundManager)
         {
            _soundManager = new SoundManager();
            processManager.addTickedObject(_soundManager,100);
         }
         if(!_resourceManager)
         {
            _resourceManager = new ResourceManager();
         }
         if(!_templateManager)
         {
            _templateManager = new TemplateManager();
         }
         if(!_inputManager)
         {
            _inputManager = new InputManager();
         }
      }
      
      public static function addResources(param1:ResourceBundle) : void
      {
         if(!_main)
         {
            throw new Error("You can only register ResourceBundles AFTER calling PBE.startup.");
         }
      }
      
      public static function initializeScene(param1:IUITarget, param2:String = "SceneDB", param3:Class = null, param4:Class = null) : IEntity
      {
         var _loc5_:IEntity = allocateEntity();
         _loc5_.initialize(param2);
         if(!param4)
         {
            param4 = BasicSpatialManager2D;
         }
         var _loc6_:ISpatialManager2D = new param4();
         _spatialManager = _loc6_;
         _loc5_.addComponent(_loc6_ as IEntityComponent,"Spatial");
         if(!param3)
         {
            param3 = DisplayObjectScene;
         }
         _scene = new param3();
         _scene.sceneView = param1;
         _loc5_.addComponent(_scene,"Scene");
         return _loc5_;
      }
      
      public static function get spatialManager() : ISpatialManager2D
      {
         return _spatialManager;
      }
      
      public static function get scene() : IScene2D
      {
         return _scene;
      }
      
      public static function getFlashVars() : Object
      {
         return LoaderInfo(mainStage.loaderInfo).parameters;
      }
      
      public static function getLoggedInUserId() : String
      {
         return Zlab.getFlashVar("userId") as String;
      }
      
      public static function getFlashVar(param1:String) : Object
      {
         return getFlashVars()[param1];
      }
      
      public static function parseFlashVars(param1:Object) : void
      {
         if(!param1.noSound)
         {
         }
         if(param1.app_url != null)
         {
            ZConfig.BASE_PATH = param1.app_url;
            ZConfig.GAME_SETTINGS_PATH = param1.app_url;
            ZConfig.SERVICES_GATEWAY_PATH = param1.app_url + "flashservices/gateway.php";
         }
         if(param1.gamesettings_url != null)
         {
            ZConfig.GAME_SETTINGS_PATH = param1.gamesettings_url;
         }
         if(param1.sn_app_url != null)
         {
            ZConfig.SN_APP_URL = param1.sn_app_url;
         }
         if(param1.asset_url != null)
         {
         }
      }
      
      public static function get started() : Boolean
      {
         return _started;
      }
      
      public static function isKeyDown(param1:InputKey) : Boolean
      {
         return _inputManager.isKeyDown(param1.keyCode);
      }
      
      public static function isAnyKeyDown() : Boolean
      {
         return _inputManager.isAnyKeyDown();
      }
      
      public static function lookup(param1:String) : PBObject
      {
         return _nameManager.lookup(param1);
      }
      
      public static function lookupEntity(param1:String) : IEntity
      {
         return _nameManager.lookup(param1) as IEntity;
      }
      
      public static function lookupComponentByName(param1:String, param2:String) : IEntityComponent
      {
         return _nameManager.lookupComponentByName(param1,param2);
      }
      
      public static function lookupComponentByType(param1:String, param2:Class) : IEntityComponent
      {
         return _nameManager.lookupComponentByType(param1,param2);
      }
      
      public static function makeEntity(param1:String, param2:Object = null) : IEntity
      {
         var _loc4_:* = undefined;
         var _loc3_:IEntity = Zlab.templateManager.instantiateEntity(param1);
         if(!_loc3_)
         {
            return null;
         }
         if(!param2)
         {
            return _loc3_;
         }
         for(_loc4_ in param2)
         {
            if(_loc4_ is PropertyReference)
            {
               _loc3_.setProperty(_loc4_,param2[_loc4_]);
            }
            else if(_loc4_ is String)
            {
               if(String(_loc4_).charAt(0) == "@" && String(_loc4_).indexOf(".") == -1)
               {
                  _loc3_.addComponent(IEntityComponent(param2[_loc4_]),String(_loc4_).substring(1));
               }
               else
               {
                  _loc3_.setProperty(new PropertyReference(_loc4_),param2[_loc4_]);
               }
            }
            else
            {
               Logger.error(Zlab,"MakeEntity","Unexpected key \'" + _loc4_ + "\'; can only handle String or PropertyReference.");
            }
         }
         if(_loc3_.deferring)
         {
            _loc3_.deferring = false;
         }
         return _loc3_;
      }
      
      public static function log(param1:*, param2:String) : void
      {
      }
      
      public static function get mainStage() : Stage
      {
         if(!_main)
         {
            throw new Error("Cannot retrieve the global stage instance until mainClass has been set to the startup class!");
         }
         return _main.stage;
      }
      
      public static function get mainClass() : Sprite
      {
         return _main;
      }
      
      public static function get levelManager() : LevelManager
      {
         return LevelManager.instance;
      }
      
      public static function get nameManager() : NameManager
      {
         return _nameManager;
      }
      
      public static function get processManager() : ProcessManager
      {
         return _processManager;
      }
      
      public static function get templateManager() : TemplateManager
      {
         return _templateManager;
      }
      
      public static function get inputManager() : InputManager
      {
         return _inputManager;
      }
      
      public static function get objectTypeManager() : ObjectTypeManager
      {
         return _objectTypeManager;
      }
      
      public static function get resourceManager() : ResourceManager
      {
         return _resourceManager;
      }
      
      public static function get soundManager() : ISoundManager
      {
         return _soundManager;
      }
      
      public static function getHostingDomain() : String
      {
         var _loc1_:String = _main.stage.loaderInfo.url;
         var _loc2_:Array = _loc1_.split("://");
         var _loc3_:Array = _loc2_[1].split("/");
         if(_loc3_.length)
         {
            return _loc3_[0];
         }
         return "[unknown]";
      }
      
      public static function pushStageQuality(param1:String) : void
      {
         _stageQualityStack.push(mainStage.quality);
         mainStage.quality = param1;
      }
      
      public static function popStageQuality() : void
      {
         if(_stageQualityStack.length == 0)
         {
            throw new Error("Bottomed out in stage quality stack! You have mismatched push/pop calls!");
         }
         mainStage.quality = _stageQualityStack.pop();
      }
      
      public static function get rootGroup() : PBGroup
      {
         return _rootGroup;
      }
      
      public static function get currentGroup() : PBGroup
      {
         return _currentGroup;
      }
      
      public static function set currentGroup(param1:PBGroup) : void
      {
         if(param1 == null)
         {
            throw new Error("You cannot set the currentGroup to null; it must always be a valid PBGroup.");
         }
         _currentGroup = param1;
      }
      
      public static function loadResource(param1:String, param2:Class, param3:Function = null, param4:Function = null, param5:Boolean = false) : void
      {
         resourceManager.load(param1,param2,param3,param4,null,param5);
      }
      
      public static function callLater(param1:Function, param2:Array = null) : void
      {
         Zlab.processManager.callLater(param1,param2);
      }
      
      public static function findChild(param1:String, param2:DisplayObject = null) : DisplayObject
      {
         return _findChild(param1,param2 ? param2 : _main);
      }
      
      private static function _findChild(param1:String, param2:DisplayObject) : DisplayObject
      {
         var _loc5_:DisplayObject = null;
         if(!param2)
         {
            return null;
         }
         if(param2.name == param1)
         {
            return param2;
         }
         var _loc3_:DisplayObjectContainer = param2 as DisplayObjectContainer;
         if(!_loc3_)
         {
            return null;
         }
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_.numChildren)
         {
            _loc5_ = _findChild(param1,_loc3_.getChildAt(_loc4_));
            if(_loc5_)
            {
               return _loc5_;
            }
            _loc4_++;
         }
         return null;
      }
      
      public static function setServerTime(param1:Number) : void
      {
         m_serverTime = param1;
         m_syncTime = flash.utils.getTimer();
      }
      
      public static function getTimer() : Number
      {
         return flash.utils.getTimer() - m_syncTime + m_serverTime * 1000;
      }
      
      public static function get serverTime() : Number
      {
         return m_serverTime;
      }
   }
}

