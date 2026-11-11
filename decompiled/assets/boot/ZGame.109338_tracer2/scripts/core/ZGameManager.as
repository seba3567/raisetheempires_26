package core
{
   import Engine.Init.InitializationManager;
   import core.gamemode.GameModeManager;
   import core.gameobjects.GameItem;
   import core.managers.UnitDropManager;
   import core.managers.visitorManager.VisitorManager;
   import core.views.ViewManager;
   import core.worlds.AbstractWorld;
   import core.worlds.battleWorld.BattleWorld;
   import core.worlds.islandworld.IslandWorld;
   import core.worlds.strategicWorld.StrategicWorld;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.FullScreenEvent;
   import flash.events.IEventDispatcher;
   import flash.utils.Dictionary;
   import init.ActionQueue;
   import zlabs.Zlab;
   import zlabs.core.PBGroup;
   import zlabs.debug.Logger;
   import zlabs.entity.IEntity;
   import zlabs.rendering.rendering2D.SceneAlignment;
   import zlabs.rendering.rendering2D.ui.SceneView;
   import zlabs.rendering.renderingISO.IsoSpatialManager;
   
   public class ZGameManager extends EventDispatcher
   {
      
      public static const WORLD_OBJECT_GROUP_NAME:String = "WorldObjectGroup";
      
      public static const SCENE_GROUND_LAYER:String = "gameScene";
      
      public static const MAIN_VIEW:String = "mainGameVeiw";
      
      private var m_worlds:Dictionary;
      
      public function ZGameManager(param1:IEventDispatcher = null)
      {
         super(param1);
      }
      
      public function initialize() : void
      {
         InitializationManager.getInstance().addEventListener(Event.COMPLETE,this.onGameInitComplete,false,0,true);
         GameItem.initDirectionRays();
         Zlab.inputManager.addEventListener(FullScreenEvent.FULL_SCREEN,this.onScreenEvent);
         var _loc1_:SceneView = new SceneView();
         _loc1_.name = MAIN_VIEW;
         _loc1_.x = 0;
         _loc1_.y = 0;
         Zlab.mainClass.addChildAt(_loc1_,0);
         Zlab.initializeScene(_loc1_,"MainScene",null,IsoSpatialManager);
         Zlab.scene.sceneAlignment = SceneAlignment.TOP_LEFT;
         var _loc2_:PBGroup = new PBGroup();
         _loc2_.initialize(ViewManager.VIEW_GROUP_NAME);
         this.m_worlds = new Dictionary();
         VisitorManager.initialize();
         UnitDropManager.initialize();
         var _loc3_:IslandWorld = new IslandWorld();
         _loc3_.initialize();
         this.addWorld(_loc3_);
         var _loc4_:BattleWorld = new BattleWorld();
         _loc4_.initialize();
         this.addWorld(_loc4_);
         var _loc5_:AbstractWorld = new StrategicWorld();
         _loc5_.initialize();
         this.addWorld(_loc5_);
         GameModeManager.instance.setDefaultGameMode();
         ViewManager.instance.goToView(IslandWorld.ID);
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      private function addWorld(param1:AbstractWorld) : void
      {
         this.m_worlds[param1.id] = param1;
      }
      
      private function removeWorld(param1:String) : Boolean
      {
         var _loc2_:AbstractWorld = null;
         if(this.m_worlds[param1])
         {
            _loc2_ = this.m_worlds[param1];
            _loc2_.dispose();
            this.m_worlds[param1] = null;
            delete this.m_worlds[param1];
            return true;
         }
         return false;
      }
      
      public function getWorld(param1:String) : AbstractWorld
      {
         return this.m_worlds[param1];
      }
      
      public function getObjectGroup(param1:String) : PBGroup
      {
         var _loc3_:PBGroup = null;
         var _loc2_:PBGroup = Zlab.nameManager.lookup(param1);
         if(null == _loc2_)
         {
            _loc2_ = new PBGroup();
            _loc2_.initialize(param1);
            _loc3_ = Zlab.nameManager.lookup(WORLD_OBJECT_GROUP_NAME);
            _loc2_.owningGroup = _loc3_;
         }
         return _loc2_;
      }
      
      private function onScreenEvent(param1:FullScreenEvent) : void
      {
         var _loc3_:IEntity = null;
         var _loc2_:Dictionary = ViewManager.instance.views;
         for each(_loc3_ in _loc2_)
         {
            _loc3_.eventDispatcher.dispatchEvent(param1);
         }
      }
      
      public function getObjectByID(param1:int) : IEntity
      {
         var _loc2_:String = "entity_" + String(param1);
         return Zlab.nameManager.lookup(_loc2_) as IEntity;
      }
      
      protected function onGameInitComplete(param1:Event) : void
      {
         InitializationManager.getInstance().removeEventListener(Event.COMPLETE,this.onGameInitComplete);
         Logger.info(this,"onGameInitComplete"," run action queue");
         ActionQueue.instance.addEventListener(Event.COMPLETE,this.onPostActionComplete,false,0,true);
         ActionQueue.instance.execute();
      }
      
      private function onPostActionComplete(param1:Event) : void
      {
      }
   }
}

