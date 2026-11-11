package Engine.Classes
{
   import Engine.Interfaces.IEngineComponent;
   import Engine.Managers.EasterEggManager;
   import Engine.Managers.ZaspManager;
   
   public class ZEngineOptions
   {
      
      public var viewportClass:Class = Viewport;
      
      public var zaspManagerClass:Class = ZaspManager;
      
      public var tileMapClass:Class = null;
      
      public var socialNetworkUserClass:Class = SocialNetworkUser;
      
      public var idleTaskQueue:Class = IdleTaskQueue;
      
      public var sendLoadingManagerStats:Boolean = false;
      
      public var tileWidth:uint = 24;
      
      public var tileHeight:uint = 12;
      
      public var tileScale:Number = 1;
      
      public var baseService:String = "BaseService.dispatchBatch";
      
      public var numShards:int = 16;
      
      public var engineComponents:Vector.<IEngineComponent> = new Vector.<IEngineComponent>();
      
      public var easterEggManager:Class = EasterEggManager;
      
      public function ZEngineOptions()
      {
         super();
      }
      
      public function addComponent(param1:IEngineComponent) : void
      {
         this.engineComponents.push(param1);
      }
   }
}

