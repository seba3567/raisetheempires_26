package zlabs
{
   import flash.display.LoaderInfo;
   import flash.display.Sprite;
   import flash.display.StageAlign;
   import flash.display.StageScaleMode;
   import flash.events.Event;
   import flash.system.Security;
   import zlabs.debug.Logger;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   import zlabs.utils.ZCCComponent;
   
   public class ZGameBase extends Sprite
   {
      
      public static var layerUI:Sprite = null;
      
      public static var layerWindow:Sprite = null;
      
      public static var layerPopUp:Sprite = null;
      
      public var parameters:Object;
      
      public function ZGameBase(param1:Object = null)
      {
         super();
         Security.allowDomain("*.zynga.com");
         this.addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
      }
      
      protected function onAddedToStage(param1:Event) : void
      {
         this.removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         this.stage.scaleMode = StageScaleMode.NO_SCALE;
         this.stage.align = StageAlign.TOP_LEFT;
         if(this.parameters == null)
         {
            this.parameters = LoaderInfo(this.root.loaderInfo).parameters;
         }
         this.parametersLoaded();
         Zlab.startup(this);
         this.initEngine();
         this.init();
      }
      
      protected function parametersLoaded() : void
      {
      }
      
      private function initEngine() : void
      {
         GlobalEngine.stage = Zlab.mainStage;
         Zlab.parseFlashVars(this.parameters);
         layerUI = new Sprite();
         layerWindow = new Sprite();
         layerPopUp = new Sprite();
         Zlab.mainClass.addChild(layerUI);
         Zlab.mainClass.addChild(layerWindow);
         Zlab.mainClass.addChild(layerPopUp);
         WindowManager.instance.initialize(layerWindow);
         PopupManager.instance.initialize(layerPopUp);
         Zlab.inputManager.setupListeners();
         Zlab.processManager.addTickedObject(ZCCComponent.instance);
         Logger.info(this,"Init","Base URL: " + ZConfig.SERVICES_GATEWAY_PATH);
         Logger.info(this,"Init","Asset URL: " + Config.ASSET_PATHS);
      }
      
      protected function init() : void
      {
         throw new Error("this function must be override and not super");
      }
      
      public function disableAllInput() : void
      {
         Zlab.mainStage.mouseChildren = false;
      }
      
      public function enableAllInput() : void
      {
         Zlab.mainStage.mouseChildren = true;
      }
   }
}

